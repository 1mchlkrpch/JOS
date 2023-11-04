#include <inc/types.h>
#include <inc/inttypes.h>
#include <inc/stdio.h>
#include <inc/x86.h>

#include <kern/net.h>
#include <inc/assert.h>
#include <kern/e1000.h>
#include "pmap.h" // FIXME: should be <pmap.h>

// e1000.pdf: https://courses.cs.washington.edu/courses/cse451/16au/readings/e1000.pdf
// Reference to e1000 spec are in format `e1000.pdf::page`

// TODO: IO read / write implement

static uint32_t rec_descriptor_head = 0;
static uint32_t trn_descriptor_head = 0;

// TODO: maybe implement pci_device_read_dword(). If we see we need to read 32 bits.
// https://wiki.osdev.org/PCI#Configuration_Space_Access_Mechanism_.231
static uint32_t
pci_device_read_dword(uint8_t bus, uint8_t slot, uint8_t func, uint8_t offset) {
    // From osdev.org:
    //   The CONFIG_ADDRESS is a 32-bit register with the format shown in following
    //   figure. Bit 31 is an enable flag for determining when accesses to
    //   CONFIG_DATA should be translated to configuration cycles.
    //   Bits 23 through 16 allow the configuration software to choose a specific
    //   PCI bus in the system.
    //   Bits 15 through 11 select the specific device on the PCI Bus.
    //   Bits 10 through 8 choose a specific function in a device (if the device
    //   supports multiple functions).
    // I assume if we need to read device vendor id, we just need to use function 0.
    //   I think it should be always present.
    static const uint32_t PCI_CONFIG_ADDR_ENABLE_BIT_MASK = ((uint32_t) 1) << 31;

    uint32_t config_address = 0;

    // Сборка адреса конфигурации по шине, слоту, функции и смещению.
    config_address |= PCI_CONFIG_ADDR_ENABLE_BIT_MASK;
    config_address |= ((uint32_t)  bus) << 16;
    config_address |= ((uint32_t) slot) << 11;
    config_address |= ((uint32_t) func) <<  8;

    // Register Offset has to point to consecutive DWORDs, ie. bits 1:0 are
    //   always 0b00 (they are still part of the Register Offset). 
    // assert((offset & 0x3) == 0); // assert((offset & 0x3) == 0); // Undefined reference to __assert_fail

    config_address |= offset;

    outl(PCI_CONFIGURATION_ADDRESS_PORT, config_address);
    uint32_t result = inl(PCI_CONFIGURATION_DATA_PORT);

    return result;
}

static uint16_t
pci_device_read_word(uint8_t bus, uint8_t slot, uint8_t func, uint8_t offset) {
    // Assuming little endian. TODO: check if it is specified in spec.
    // Aligning to 4 bytes boundary, to read a dword.
    uint32_t result = pci_device_read_dword(bus, slot, func, offset & ~((uint8_t) 0x3));
    if (offset % 4 == 0) {
        // Select lower word.
        result &= 0xFFFF;
        return (uint16_t) result;
    } else {
        // Select higher word.
        result >>= 16;
        result &= 0xFFFF;
        return (uint16_t) result;
    }
}

static void
pci_device_write_dword(uint8_t bus, uint8_t slot, uint8_t func, uint8_t offset, uint32_t value) {
    // From osdev.org:
    //   The CONFIG_ADDRESS is a 32-bit register with the format shown in following
    //   figure. Bit 31 is an enable flag for determining when accesses to
    //   CONFIG_DATA should be translated to configuration cycles.
    //   Bits 23 through 16 allow the configuration software to choose a specific
    //   PCI bus in the system.
    //   Bits 15 through 11 select the specific device on the PCI Bus.
    //   Bits 10 through 8 choose a specific function in a device (if the device
    //   supports multiple functions).
    // I assume if we need to read device vendor id, we just need to use function 0.
    //   I think it should be always present.
    static const uint32_t PCI_CONFIG_ADDR_ENABLE_BIT_MASK = ((uint32_t) 1) << 31;

    uint32_t config_address = 0;

    // Сборка адреса конфигурации по шине, слоту, функции и смещению.
    config_address |= PCI_CONFIG_ADDR_ENABLE_BIT_MASK;
    config_address |= ((uint32_t)  bus) << 16;
    config_address |= ((uint32_t) slot) << 11;
    config_address |= ((uint32_t) func) <<  8;

    // Register Offset has to point to consecutive DWORDs, ie. bits 1:0 are
    //   always 0b00 (they are still part of the Register Offset). 
    // assert((offset & 0x3) == 0); // Undefined reference to __assert_fail
    config_address |= offset;

    outl(PCI_CONFIGURATION_ADDRESS_PORT, config_address);
    outl(PCI_CONFIGURATION_DATA_PORT, value);
}

static void
pci_device_write_word(uint8_t bus, uint8_t slot, uint8_t func, uint8_t offset, uint16_t value) {
    // WARNING: value can be modified beetween read and write. It may be source of bugs.
    uint32_t original_value = pci_device_read_dword(bus, slot, func, offset & ~((uint8_t) 0x3));
    if (offset % 4 == 0) {
        original_value = ((original_value >> 16) << 16) | value;
    } else {
        original_value = (((uint32_t) value) << 16) | (original_value & 0xFFFF);
    }
    pci_device_write_dword(bus, slot, func, offset & ~((uint8_t) 0x3), original_value);
}

static uint8_t
pci_device_read_byte(uint8_t bus, uint8_t slot, uint8_t func, uint8_t offset) {
    uint8_t dword_offset = offset & (~0x01); // Unset the last bit, to make it even.
    uint16_t result = pci_device_read_word(bus, slot, func, dword_offset);
    if (offset % 2 == 0) {
        result &= 0xFF;
        return (uint8_t) result;
    } else {
        result >>= 8;
        result &= 0xFF;
        return (uint8_t) result;
    }
}

// https://wiki.osdev.org/PCI#PCI_Device_Structure
// From osdev:
//   The PCI Specification defines the organization of the 256-byte
//   Configuration Space registers and imposes a specific
//   template for the space. Figures 2 & 3 show the layout of the
//   256-byte Configuration space. All PCI compliant devices must
//   support the Vendor ID, Device ID, Command and Status,
//   Revision ID, Class Code and Header Type fields.
//   Implementation of the other registers is optional, depending
//   upon the devices functionality. 
// All devices should have vendor id in their configuration space
//   and if a device is not present at bus and slot, then 0xFFFF
//   is returned for all reads. This way we can check if device
//   is present, as there's no vendor with id 0xFFFF. Found this
//   in the osdev's article.
// If returns PCI_VENDOR_ID_DEVICE_NOT_EXISTS, the device is not present.
static uint16_t
pci_read_vendor_id(uint8_t bus, uint8_t slot, uint8_t function) {
    // Vendor id goes first in the configuration space and device id is second.
    return pci_device_read_word(bus, slot, function, PCI_CONFIG_SPACE_VENDOR_ID_OFFSET);
}

// Similar to pci_read_vendor_id. For symmetricity and also
//   both of these values are needed to find a particular
//   device, so makes sense to have functions for both of
//   them.
static uint16_t
pci_read_device_id(uint8_t bus, uint8_t slot, uint8_t function) {
    // Device id is straight after vendor id, which goes first in the configuration space.
    return pci_device_read_word(bus, slot, function, PCI_CONFIG_SPACE_DEVICE_ID_OFFSET);
}

static uint8_t
pci_read_header_type(uint8_t bus, uint8_t slot, uint8_t function) {
    // Header type also has a bit that says if this device has multiple functions.
    //   We have to discard it.
    uint8_t value = pci_device_read_byte(bus, slot, function, PCI_CONFIG_SPACE_HEADER_TYPE_OFFSET);
    // Unset the multiple function bit. Could be checked other ways.
    //   We consider different functions of a device as different devices.
    uint8_t header_type = value & (~(1U << 7));
    return header_type;
}

// TODO: remove commment
// It may be needed to read headers fully.
//   But for e1000 it's not needed so far, because
//   we'll just read a couple of fields for mmio
//   and other stuff.
// If needed for other devices or it's refactored
//   to a pci library, it may be considered. Although
//   there should be a way to update both the struct
//   and device configuration space.
// It could be done with a struct pci_device, that would
//   contain header type, header itself, bus, slot function.
// And functions would accept such a struct with a value to change.
// static uint8_t
// pci_device_set_status(struct pci_device* device, uint8_t new_status);
// For device discovery, it could be done with public function pci_detect_device,
//   that takes vendor_id and device_id.
// And it'd use pci_raw_read_device_id(), pci_raw_read_vendor_id(), pci_raw_read_header_type,
//   those functions would be static, internal.
// bool
// pci_detect_device(uint16_t device_id, uint16_t vendor_id, struct pci_device* device);
// struct pci_device { bus, slot, function; header_type; union { struct pci_device_header; struct pci_bridge_header; struct pci_cardbus_bridge_header; }}
// Header type 0x0.
/*
struct pci_device_config_header {
    uint16_t vendor_id;
    uint16_t device_id;

    uint16_t command_reg;
    uint16_t status_reg;

    uint8_t revision_id;
    uint8_t prog_interface;

    uint8_t subclass;
    uint8_t class;

    uint8_t cache_line_size;
    uint8_t latency_timer;

    uint8_t multifunction:1;
    uint8_t header_type:7; // Must be 0x0

    Register    Offset  Bits 31-24  Bits 23-16  Bits 15-8   Bits 7-0
0x0     0x0     Device ID   Vendor ID
0x1     0x4     Status  Command
0x2     0x8     Class code  Subclass    Prog IF     Revision ID
0x3     0xC     BIST    Header type     Latency Timer   Cache Line Size
0x4     0x10    CardBus Socket/ExCa base address
0x5     0x14    Secondary status    Reserved    Offset of capabilities list
0x6     0x18    CardBus latency timer   Subordinate bus number  CardBus bus number  PCI bus number
0x7     0x1C    Memory Base Address 0
0x8     0x20    Memory Limit 0
0x9     0x24    Memory Base Address 1
0xA     0x28    Memory Limit 1
0xB     0x2C    I/O Base Address 0
0xC     0x30    I/O Limit 0
0xD     0x34    I/O Base Address 1
0xE     0x38    I/O Limit 1
0xF     0x3C    Bridge Control  Interrupt PIN   Interrupt Line
0x10    0x40    Subsystem Vendor ID     Subsystem Device ID
0x11    0x44    16-bit PC Card legacy mode base address 
};

// Header type 0x1.
// struct pci_bridge_config_header;

// Header type 0x2
// Long name means it's not widely used :)
// struct pci_cardbus_bridge_config_header;

static void
pci_read_device_config_header(uint8_t bus, uint8_t slot, uint8_t function, struct pci_device_config_header* header) {
    for ()
}
*/

//static bool trace_pci = true;

static bool
pci_detect_device(uint16_t vendor_id, uint16_t device_id, uint8_t* bus, uint8_t* slot, uint8_t* function) {
    // We try to enumerate all possible buses and slots to find the device.
    //  That's the easiest way and we don't need something more complex
    //  right now.
    //  https://wiki.osdev.org/PCI#Enumerating_PCI_Buses

    // This vendor is should not exist anyway and we won't find this device.
    assert(vendor_id != PCI_VENDOR_ID_DEVICE_NOT_EXISTS);

    uint16_t target_vendor_id = vendor_id;
    uint16_t target_device_id = device_id;

    for (uint16_t cur_bus = 0; cur_bus < UINT8_MAX; ++cur_bus) {
        for (uint16_t cur_slot = 0; cur_slot < UINT8_MAX; ++cur_slot) {
            // One device may have many functions. These functions technically
            //   may have different vendor ids and device ids...
            //   In qemu there is a device with many (more than one) functions,
            //   it has different device id for each function. I think, such
            //   situation may also happen on real hardware, we have to scan
            //   all of the functions to find our vendor_id and device_id pair.
            // Not more than 8 functions though. Function is only 3 bits wide.
            for (uint8_t cur_function = 0; cur_function < 8; ++cur_function) {
                uint16_t dev_vendor_id = pci_read_vendor_id(cur_bus, cur_slot, cur_function);
                if (dev_vendor_id == PCI_VENDOR_ID_DEVICE_NOT_EXISTS) {
                    continue;
                }

                // Warning: may not print every device, as it stops when the request is fullfilled.
               
                if (dev_vendor_id != target_vendor_id) {
                    continue;
                }
            
                uint16_t dev_device_id = pci_read_device_id(cur_bus, cur_slot, cur_function);
                if (dev_device_id != target_device_id) {
                    continue;
                }

                *bus = cur_bus;
                *slot = cur_slot;
                *function = cur_function;
                return true;
            }
        }
    }

    return false;
}

static bool
drv_e1000_detect(struct e1000_data* e1000_data) {
    // Got info about what vendor id I should enter from these links:
    //   https://wiki.osdev.org/PCI#Common_Header_Fields
    //   https://pcisig.com/membership/member-companies?combine=Intel
    // Intel e1000 is a family of ethernet controllers, so there's
    //   no single device id to look for. Add them to an array you
    //   encounter them. It should work for our purposes for now, we
    //   won't be running this operating system on real hardware with
    //   variety values for device id any time soon.
    // To see list of emulated devices in QEMU, use info from here
    //   https://serverfault.com/questions/587189/how-to-list-all-devices-emulated-in-a-qemu-virtual-machine
    //   Also, there's a command "info pci".
    // To see more device ids, you could use this database:
    //   https://pci-ids.ucw.cz/read/PC
    //   https://pci-ids.ucw.cz/read/PC/8086

    //? e1000.pdf::86 should be downloaded from eeprom
    static const uint16_t NET_E1000_VENDOR_ID = 0x8086;
    static const uint16_t NET_E1000_DEVICE_IDS[] = {0x100E};

    uint8_t bus = 0;
    uint8_t slot = 0;
    uint8_t function = 0;

    bool found = false;
    for (size_t i = 0; i < sizeof(NET_E1000_DEVICE_IDS) / sizeof(*NET_E1000_DEVICE_IDS); ++i) {
        if (pci_detect_device(NET_E1000_VENDOR_ID, NET_E1000_DEVICE_IDS[i], &bus, &slot, &function)) {
            // Log level could be info.
            cprintf("Found e1000 of id %02" PRIx16 ":%02" PRIx16 " at pci %02" PRIu8 ":%02" PRIu8 ".%" PRIu8 ".\n", NET_E1000_VENDOR_ID, NET_E1000_DEVICE_IDS[i], bus, slot, function);
            found = true;
            break;
        }
    }
    if (!found) {
        return false;
    }

    // Header type other than PCI_DEVICE_HEADER_TYPE (0x0) should be only for pci-to-pci bridges and pci-to-cardbus bridges.
    uint8_t header_type = pci_read_header_type(bus, slot, function);
    if (header_type != PCI_DEVICE_HEADER_TYPE) {
        // Log level could be warning.
        cprintf("The E1000 header type is invalid (not a device header, has header type %" PRIx8 ".\n", header_type);
        return false;
    }

    e1000_data->bus = bus;
    e1000_data->slot = slot;
    e1000_data->function = function;

    uint32_t bar0 = pci_device_read_dword(bus, slot, function, PCI_CONFIG_SPACE_BAR0_OFFSET);
    uint32_t bar1 = pci_device_read_dword(bus, slot, function, PCI_CONFIG_SPACE_BAR1_OFFSET);

    bool register_access_is_ports = bar0 & 0x1;
    if (register_access_is_ports) {
        e1000_data->reg_access_type = E1000_REG_ACCESS_TYPE_IO_PORTS;
    } else {
        e1000_data->reg_access_type = E1000_REG_ACCESS_TYPE_MMIO;        
        cprintf("E1000 uses mmio.\n");
    }

    uintptr_t mmio_base_address = (((uint64_t) bar1) << 32) | bar0;
    bool address_space_size_is_64bit = (bar0 & 0x2) >> 1;
    if (!address_space_size_is_64bit) {
        // Log level could be info.
        cprintf("E1000 requests 32-bit addressing.\n");
        mmio_base_address &= (((uint64_t) 1) << 32) - 1; // Unset the higher 32 bits.
    }

    bool prefetch = (bar0 & 0x4) >> 2;
    (void) prefetch;

    mmio_base_address &= ~((uint64_t) 0xF);

    // We do have virtual memory, it's enabled. It's just preconfigured
    //   by our professors for some regions.
    // Meanwhile the address we get is not mapped. And qemu will just
    //   hang, because the read is to an unmapped virtual address.
    // `help tlb` in qemu command prompt (`C-x c` to get it in qemu-nox)
    //   says there's no entry in the page table, that says where to map
    //   this address as virtual address. So qemu doesn't know how to
    //   handle this read. It happened so that we succeeded with acpi,
    //   because it happened to be mapped. But it's just a conincidence
    //   or UEFI did it for us.
    mmio_map_region(mmio_base_address, 4 * 1024 * 1024); // TODO: figure out the constant here.

    e1000_data->mmio_base_address = mmio_base_address;
    cprintf("mmio_base_address = %p.\n", (void*) mmio_base_address);

    uint32_t bar4 = pci_device_read_dword(bus, slot, function, PCI_CONFIG_SPACE_BAR4_OFFSET);
    uint32_t ioport_for_addr  = bar4 & ~((uint32_t) 0x7); // Unset the lowest 3 bits, although 2 of them are zeros by the docs.
    // e1000.pdf::218 code sample to get ioports for reading and writing.
    uint32_t ioport_for_data = ioport_for_addr + 4;

    e1000_data->ioport_for_addr = ioport_for_addr;
    e1000_data->ioport_for_data = ioport_for_data;

    // Enable DMA for the device.
    uint16_t cmd_reg = pci_device_read_word(bus, slot, function, PCI_CONFIG_SPACE_CMD_REG_OFFSET);
    cmd_reg |= PCI_CMD_REG_BUS_MASTERING_MASK;
    cmd_reg |= PCI_CMD_REG_MEMORY_RESPONSE_MASK;
    cmd_reg |= PCI_CMD_REG_IO_RESPONSE_MASK;
    pci_device_write_word(bus, slot, function, PCI_CONFIG_SPACE_CMD_REG_OFFSET, cmd_reg);

    e1000_data->int_line = pci_device_read_byte(bus, slot, function, PCI_CONFIG_SPACE_HEADER_INT_LINE_OFFSET);

    cprintf("pci int line value: %x\n", e1000_data->int_line);

    return true;
}

static void
mmio_write32(uintptr_t address, uint32_t value) {
    uint32_t volatile* value_ptr = (uint32_t volatile*) address;
    *value_ptr = value;
    //cprintf("address = %llx.\n", (unsigned long long) address);
}

// e1000.pdf::233
// static uint16_t E1000_REG_EEPROM_READ = 0x0014; // Not applicable for (82544GC/EI)

static uint32_t
mmio_read32(uintptr_t address) {
    uint32_t volatile* value_ptr = (uint32_t volatile*) address;
    uint32_t value = *value_ptr;
    // cprintf("address = %llx.\n", (unsigned long long) address);
    return value;
}

static void
drv_e1000_cmd_send(struct e1000_data* e1000_data, uint16_t address, uint32_t value) {
    if (e1000_data->reg_access_type == E1000_REG_ACCESS_TYPE_MMIO) {
        // cprintf("mmio access.\n");  
        mmio_write32(e1000_data->mmio_base_address + address, value);
    } else {
        outl(e1000_data->ioport_for_addr, address);
        outl(e1000_data->ioport_for_data, value);
    }
}

static uint32_t
drv_e1000_cmd_recv_result(struct e1000_data* e1000_data, uint16_t address) {
    uint32_t result = 0;
    if (e1000_data->reg_access_type == E1000_REG_ACCESS_TYPE_MMIO) {
        result = mmio_read32(e1000_data->mmio_base_address + address);
    } else {
        outw(e1000_data->ioport_for_addr, address);
        result = inl(e1000_data->ioport_for_data);
    }
    return result;
}

// TODO: check hints from https://wiki.osdev.org/Intel_8254x#Example_driver.
//? make improvements
// TODO: implement locking functions so that only one function has access to the application in a certain period of time 
static uint16_t
drv_e1000_read_eeprom_word(struct e1000_data* e1000_data, uint8_t offset) {
    // e1000.pdf::96
    // e1000.pdf::248

    drv_e1000_cmd_send(e1000_data, EEPROM_REG_OFFSET, 1 | (((uint32_t)(offset)) << 8));

    uint32_t reg_val = 0;

    while(!((reg_val = drv_e1000_cmd_recv_result(e1000_data, EEPROM_REG_OFFSET)) & (1 << 4))){
        // Waiting, until reading is done.
        ;
    }
    
    return (reg_val >> 16) & 0xFFFF;
}

static bool
detect_eeprom(struct e1000_data* e1000_data) {
    static const uint32_t EEPROM_REG_EEPROM_PRESENT = 1 << 8;
    if ((drv_e1000_cmd_recv_result(e1000_data, EECD_REG_OFFSET) & EEPROM_REG_EEPROM_PRESENT) == 0) {
        //cprintf("EECD = %" PRIb32 ".\n", drv_e1000_cmd_recv_result(e1000_data, EECD_REG_OFFSET));
        cprintf("EECD = %x.\n", drv_e1000_cmd_recv_result(e1000_data, EECD_REG_OFFSET));
        return false;
    }
    return true;

    uint32_t val = 0;

    drv_e1000_cmd_send(e1000_data, EEPROM_REG_OFFSET, 0x1);

    for(int cnt = 0; cnt < 10000000; cnt++){
        if((val = drv_e1000_cmd_recv_result(e1000_data, EEPROM_REG_OFFSET)) & (1 << 4)){
            return true;
        }
    }

    return false;
}

static bool
read_mac(struct e1000_data* e1000_data){
    // e1000.pdf::117

    uint64_t tmp = 0;

    if (detect_eeprom(e1000_data)) {

        tmp = drv_e1000_read_eeprom_word(e1000_data, 0);
        e1000_data->mac_addr |= (tmp & 0xFF);
        e1000_data->mac_addr |= ((tmp >> 8) & 0xFF) << 8;

        tmp = drv_e1000_read_eeprom_word(e1000_data, 1);
        e1000_data->mac_addr |= (tmp & 0xFF) << 16;
        e1000_data->mac_addr |= ((tmp >> 8) & 0xFF) << 24;

        tmp = drv_e1000_read_eeprom_word(e1000_data, 2);
        e1000_data->mac_addr |= (tmp & 0xFF) << 32;
        e1000_data->mac_addr |= ((tmp >> 8) & 0xFF) << 40;
    } else {
        return false;
    }

    return true;
}

//! mac should be valid
static void 
print_mac(struct e1000_data* e1000_data){

    cprintf("mac: ");
    for(int n_b = 0; n_b < 5; n_b++){
        cprintf("%02x::", (uint8_t)(((e1000_data->mac_addr) >> (8 * n_b)) & 0xFF));
    }
    cprintf("%02x\n", (uint8_t)(((e1000_data->mac_addr) >> (8 * 5)) & 0xFF));

    return;
}

static void 
drv_e1000_receive_init(struct e1000_data* e1000_data){
    // e1000.pdf::390

    drv_e1000_cmd_send(e1000_data, RAL_REG_OFFSET, e1000_data->mac_addr & 0xFFFFFFFF);
    drv_e1000_cmd_send(e1000_data, RAH_REG_OFFSET, (e1000_data->mac_addr >> 32) & 0xFFFF);
    
    // TODO: figure out what is mta and why we have to clear it
    for(int offset = 0; offset < (128 / 4); offset++){
        drv_e1000_cmd_send(e1000_data, MTA_REG_OFFSET + offset * 4, 0);
    }

    // enabling LSC, RXSEQ, RXDMT, RSX0, RSXT interrupts
    drv_e1000_cmd_send(e1000_data, IMS_REG_OFFSET, (1 << 2) | (1 << 3) | (1 << 4) | (1 << 6) | (1 << 7));

    drv_e1000_cmd_send(e1000_data, RDBAL_REG_OFFSET, ((uint64_t)(uint64_t*)rec_descriptor_buffer) & 0xFFFFFFFF);
    drv_e1000_cmd_send(e1000_data, RDBAH_REG_OFFSET, ((uint64_t)(uint64_t*)rec_descriptor_buffer) >> 32);

    drv_e1000_cmd_send(e1000_data, RDLEN_REG_OFFSET, (N_RECEIVE_DESCRIPTORS * sizeof(struct rec_descriptor)) << 7);

    drv_e1000_cmd_send(e1000_data, RDH_REG_OFFSET, 0);

    //? ok
    drv_e1000_cmd_send(e1000_data, RDT_REG_OFFSET, N_RECEIVE_DESCRIPTORS);
    
    drv_e1000_cmd_send(e1000_data, RCTL_REG_OFFSET, RCTL_ENABLE | (0x3 << RCTL_RDMTS_OFFSET) | (0x0 << RCTL_RDMTS_OFFSET));

    // TODO: init rec regs

    // TODO: set valid rdtr time
    drv_e1000_cmd_send(e1000_data, RDTR_REG_OFFSET, 100);

    return;
}

// TODO:
static void 
drv_e1000_transmit_init(struct e1000_data* e1000_data){
    // e1000.pdf::391
    drv_e1000_cmd_send(e1000_data, TDBAL_REG_OFFSET, ((uint64_t)(uint64_t*)trn_descriptor_buffer) & 0xFFFFFFFF);
    drv_e1000_cmd_send(e1000_data, TDBAH_REG_OFFSET, ((uint64_t)(uint64_t*)trn_descriptor_buffer) >> 32);

    drv_e1000_cmd_send(e1000_data, TDLEN_REG_OFFSET, (N_TRANSMIT_DESCRIPTORS * sizeof(struct trn_descriptor)) << 7);
    
    drv_e1000_cmd_send(e1000_data, TDH_REG_OFFSET, 0);
    drv_e1000_cmd_send(e1000_data, TDT_REG_OFFSET, 0);
    
    // TODO: figure out valid vals for cold and ct
    drv_e1000_cmd_send(e1000_data, TCTL_REG_OFFSET, TCTL_ENABLE | TCTL_PAD_SHORT_PACKETS | (0xF << TCTL_COLL_TRESHOLD_OFFSET) | (0x40 << TCTL_COLL_DIST_OFFSET));

    // TODO: figure out valid data for tipg
    drv_e1000_cmd_send(e1000_data, TIPG_REG_OFFSET,  0x0060200A);

    return;
}

// TODO: remove
static struct e1000_data* cur_e1000_data = NULL;

void
send_packet(void* buff_addr, uint16_t size){
    
    trn_descriptor_buffer[trn_descriptor_head].buff_addr = (uint64_t)buff_addr;
    trn_descriptor_buffer[trn_descriptor_head].len = size;
    trn_descriptor_buffer[trn_descriptor_head].status = 0;
    trn_descriptor_buffer[trn_descriptor_head].cmd = (1 << 0) | (1 << 1) | (1 << 3);
    
    cprintf("send packet item %p", (uint64_t*)trn_descriptor_buffer[trn_descriptor_head].buff_addr);

    rec_descriptor_buffer[rec_descriptor_head].status = 0;
    uint32_t tmp = rec_descriptor_head;

    trn_descriptor_head = (trn_descriptor_head + 1) % N_TRANSMIT_DESCRIPTORS;
    drv_e1000_cmd_send(cur_e1000_data, TDT_REG_OFFSET, trn_descriptor_head);

    // TODO: checks
    while(!(trn_descriptor_buffer[tmp].status & 0xFF)){
        cprintf("%x\n", trn_descriptor_buffer[tmp].status & 0xFF);
    }

    cprintf("sending completed\n");
    return;
}

static void
receive_packet(struct e1000_data* e1000_data){

    while(rec_descriptor_buffer[rec_descriptor_head].status & 0x1){

        cprintf("received packet item %p", (uint64_t*)rec_descriptor_buffer[rec_descriptor_head].buff_addr);

        // TODO: network stack
        rec_descriptor_buffer[rec_descriptor_head].status = 0;
        drv_e1000_cmd_send(e1000_data, RDT_REG_OFFSET, rec_descriptor_head);

        rec_descriptor_head = (rec_descriptor_head + 1) % N_RECEIVE_DESCRIPTORS;
    }

    return;
}

/// @brief 
/// @return 0 if init was suucces, -1 otherwise 
static int
drv_e1000_init() {
    // https://courses.cs.washington.edu/courses/cse451/16au/readings/e1000.pdf
    //   Chapter ...: initialization.

    // TODO: implement 
    struct e1000_data e1000_data = {};
    if (!drv_e1000_detect(&e1000_data)) {
        return -1;
    }

    cur_e1000_data = &e1000_data;

    // drv_e1000_cmd_send(&e1000_data, EECD_REG_OFFSET, 0x7 | (1 << 7));
    cprintf("ecd reg = %" PRIx32 ".\n", drv_e1000_cmd_recv_result(&e1000_data, EECD_REG_OFFSET));

    drv_e1000_cmd_send(&e1000_data, CTRL_REG_OFFSET, 1 << 26);
    drv_e1000_cmd_send(&e1000_data, CTRL_REG_OFFSET, 0);

    drv_e1000_cmd_send(&e1000_data, EEPROM_REG_OFFSET, drv_e1000_cmd_recv_result(&e1000_data, EEPROM_REG_OFFSET) | 0x2);

    if (!detect_eeprom(&e1000_data)) {
        cprintf("E1000 doesn't have eeprom. :( Skipping it.\n");
        return -1;
    } else {
        cprintf("E1000 has eeprom..\n");        
    }

    if(!read_mac(&e1000_data)) return -1;

    print_mac(&e1000_data);

    drv_e1000_receive_init(&e1000_data);
    drv_e1000_transmit_init(&e1000_data);

    pic_irq_unmask(e1000_data.int_line);

    // There are e1000 network cards without eeprom, we don't delect and don't support it.
    // FIXME: support them. Buy or emulate the one that doesn't have an eeprom.
    //   Consult the docs e1000.pdf::

    return 0;
}

void 
net_interrupt_handler(){

    //? we need this or not?
    drv_e1000_cmd_send(cur_e1000_data, IMS_REG_OFFSET, 1);

    uint32_t status = drv_e1000_cmd_recv_result(cur_e1000_data, ICR_REG_OFFSET);
    if(status & 0x80){
        receive_packet(cur_e1000_data);
    }
    else if(status & 0x10){
        cprintf("treshold interrupt received\n");
    }

    return;
}

void
net_init() {
    drv_e1000_init();
}
