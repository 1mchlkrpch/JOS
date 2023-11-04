#ifndef JOS_INC_E1000_H
#define JOS_INC_E1000_H

#include <inc/types.h>
#include <kern/picirq.h>

// TODO: SOMEONE MAKE THIS HEADER BEAUTIFUL PLSSS

static const unsigned int PCI_CONFIGURATION_ADDRESS_PORT = 0xCF8;
static const unsigned int PCI_CONFIGURATION_DATA_PORT = 0xCFC;

// TODO: make some or all constants - macroses
// e1000.pdf::238
static const uint16_t CTRL_REG_OFFSET    = 0x0000;
//static const uint16_t STATUS_REG_OFFSET  = 0x0008;

static const uint16_t RCTL_REG_OFFSET    = 0x0100;

static const uint32_t RCTL_ENABLE = 1 << 1;
// we will receive interrupts while free buffer threshold would be 1/x of rdlen
// could be removed if we wont support such interrupts
static const uint32_t RCTL_RDMTS_OFFSET  = 8;
static const uint32_t RCTL_BAM    = 1 << 15;
static const uint32_t RCTL_BSIZE_OFFSET = 16;

//? we need this or not
//static const uint32_t RCTL_LONG_PACKET = 1 << 5;
//static const uint32_t RCTL_MULTICAST_OFFSET = 1 << 12;
//      • Set the Strip Ethernet CRC (RCTL.SECRC) bit if the desire is for hardware to strip the CRC prior to DMA-ing the receive packet to host memory
//static const uint32_t RCTL_SECRC = 1 << 26;

// also we dont write in ims register because e1000 is not 82541xx or 82547gi/ei family

static const uint16_t EECD_REG_OFFSET    = 0x0010;
static const uint16_t EEPROM_REG_OFFSET  = 0x0014;

static const uint16_t RAL_REG_OFFSET     = 0x5400;
static const uint16_t RAH_REG_OFFSET     = 0x5404;

static const uint16_t MTA_REG_OFFSET     = 0x5200;

static const uint16_t ICR_REG_OFFSET     = 0x00C0;
static const uint16_t IMS_REG_OFFSET     = 0x00D0;

static const uint16_t RDBAL_REG_OFFSET   = 0x2800;
static const uint16_t RDBAH_REG_OFFSET   = 0x2804;
static const uint16_t RDLEN_REG_OFFSET   = 0x2808;

static const uint16_t RDH_REG_OFFSET     = 0x2810;
static const uint16_t RDT_REG_OFFSET     = 0x2818;

static const uint16_t RDTR_REG_OFFSET    = 0x2820;

#define TCTL_REG_OFFSET  0x0400

#define TCTL_ENABLE  1 << 1
#define TCTL_PAD_SHORT_PACKETS 1 << 3
#define TCTL_COLL_TRESHOLD_OFFSET 4
#define TCTL_COLL_DIST_OFFSET 12

#define TDBAL_REG_OFFSET 0x3800
#define TDBAH_REG_OFFSET 0x3804
#define TDLEN_REG_OFFSET 0x3808

#define TDH_REG_OFFSET   0x3810
#define TDT_REG_OFFSET   0x3818

#define TIPG_REG_OFFSET 0x0410

// TODO: write meaning of these bytes.
static const uint16_t PCI_CMD_REG_IO_RESPONSE_MASK     = 1 << 0;
static const uint16_t PCI_CMD_REG_MEMORY_RESPONSE_MASK = 1 << 1;
static const uint16_t PCI_CMD_REG_BUS_MASTERING_MASK   = 1 << 2;


// TODO: remove comment
/* From osdev.
Common fields for all PCI devices (all of configuration space headers):
Register    Offset  Bits 31-24  Bits 23-16  Bits 15-8     Bits 7-0
     0x0       0x0         Device ID               Vendor ID 
     0x1       0x4         Status                  Command
     0x2       0x8  Class code  Subclass    Prog IF       Revision ID
     0x3       0xC  BIST        Header type Latency Timer Cache Line Size
Device ID: Identifies the particular device. Where valid IDs are allocated by the vendor.
Vendor ID: Identifies the manufacturer of the device. Where valid IDs are allocated by
  PCI-SIG (the list is here) to ensure uniqueness and 0xFFFF is an invalid value that
  will be returned on read accesses to Configuration Space registers of non-existent devices.
Status: A register used to record status information for PCI bus related events.
Command: Provides control over a device's ability to generate and respond to PCI cycles.
  Where the only functionality guaranteed to be supported by all devices is, when a 0 is
  written to this register, the device is disconnected from the PCI bus for all accesses
  except Configuration Space access.
Class Code: A read-only register that specifies the type of function the device performs.
Subclass: A read-only register that specifies the specific function the device performs.
Prog IF(Programming Interface Byte): A read-only register that specifies a register-level
  programming interface the device has, if it has any at all.
Revision ID: Specifies a revision identifier for a particular device. Where valid IDs are
  allocated by the vendor.
BIST: Represents that status and allows control of a devices BIST (built-in self test).
Header Type: Identifies the layout of the rest of the header beginning at byte 0x10 of
  the header and also specifies whether or not the device has multiple functions. Where a
  value of 0x0 specifies a general device, a value of 0x1 specifies a PCI-to-PCI bridge,
  and a value of 0x2 specifies a CardBus bridge. If bit 7 of this register is set, the
  device has multiple functions; otherwise, it is a single function device.
Latency Timer: Specifies the latency timer in units of PCI bus clocks.
Cache Line Size: Specifies the system cache line size in 32-bit units. A device can limit
  the number of cacheline sizes it can support, if a unsupported value is written to this
  field, the device will behave as if a value of 0 was written.
*/

// Common fields of PCI device header have many fields of the same size adjacent.
//   I think it's better to count offset + line.
//   The reader could find the value in the table above quickier. And calculated
//   addresses are written on the right, in comments. I think
//   writing raw hex addresses discouarages a person, who reads
//   them, when one wants to compare it with the source of information.
//   I think that this way it'll be a more pleasant thing.
// <offset in line> + line * 4 (line in osdev table and in our local table)
// <offset in reg>  +  reg * 4, every reg is 4 bytes.
static uint8_t PCI_CONFIG_SPACE_VENDOR_ID_OFFSET   =  0 + 0 * 4; // 00 = 0x00
static uint8_t PCI_CONFIG_SPACE_DEVICE_ID_OFFSET   =  2 + 0 * 4; // 02 = 0x02
static uint8_t PCI_CONFIG_SPACE_CMD_REG_OFFSET     =  0 + 1 * 4; // 04 = 0x04
//static uint8_t PCI_CONFIG_SPACE_STATUS_OFFSET      =  2 + 1 * 4; // 06 = 0x06
//static uint8_t PCI_CONFIG_SPACE_SUBCLASS_OFFSET    =  2 + 2 * 4; // 09 = 0x09
//static uint8_t PCI_CONFIG_SPACE_CLASS_CODE_OFFSET  =  3 + 2 * 4; // 11 = 0x0B
static uint8_t PCI_CONFIG_SPACE_HEADER_TYPE_OFFSET =  2 + 3 * 4; // 14 = 0x0E

static uint8_t PCI_CONFIG_SPACE_HEADER_INT_LINE_OFFSET =  0x3C; // 14 = 0x0E

static const uint16_t PCI_VENDOR_ID_DEVICE_NOT_EXISTS = 0xFFFF;

static const uint8_t PCI_DEVICE_HEADER_TYPE = 0x0;
// static const uint8_t PCI_BRIDGE_HEADER_TYPE = 0x1;
// static const uint8_t PCI_CARDBUS_BRIDGE_HEADER_TYPE = 0x2;

// Only valid for header type 0x0 (pci_device) and 0x1
// Only valid for header type 0x0 (pci_device_config_space) and 0x1 (pci_bridge_config_space)
//   Use this comment, when this is turned into a library.
static const uint8_t PCI_CONFIG_SPACE_BAR0_OFFSET = 0 + 4 * 4; // 16 = 0x10
static const uint8_t PCI_CONFIG_SPACE_BAR1_OFFSET = 0 + 5 * 4; // 20 = 0x14
// static const uint8_t PCI_CONFIG_SPACE_BAR2_OFFSET = 0 + 6 * 4; // 24 = 0x18
// static const uint8_t PCI_CONFIG_SPACE_BAR3_OFFSET = 0 + 7 * 4; // 28 = 0x1C
static const uint8_t PCI_CONFIG_SPACE_BAR4_OFFSET = 0 + 8 * 4; // 32 = 0x20
// static const uint8_t PCI_CONFIG_SPACE_BAR5_OFFSET = 0 + 9 * 4; // 32 = 0x24

struct net_device {
    bool (*recv)(const uint8_t* buffer, size_t size);
    bool (*send)(const uint8_t* buffer, size_t size);

    /*
    enum {
        NET_DEVICE_TYPE_PCI = 0,
        // NET_DEVICE_TYPE_USB = 1,

    } device_type;
    */
    // Or
    // struct device;
    /* struct dev_device { id..; { union {struct pci_device}}};*/
};

struct e1000_data {
    // struct net_device net_device;

    // struct pci_device pci_device;
    uint8_t bus;
    uint8_t slot;
    uint8_t function;

    enum {
        E1000_REG_ACCESS_TYPE_IO_PORTS,
        E1000_REG_ACCESS_TYPE_MMIO
    } reg_access_type;

    // MMIO address of registers. All pointer reads
    //   must be done through volatile pointers.
    //   The compiler must not cache it, because the
    //   device itself may change values there.
    uintptr_t mmio_base_address;

    uint32_t ioport_for_addr;
    uint32_t ioport_for_data;

    uint64_t mac_addr;

    uint8_t int_line;
};

#define N_RECEIVE_DESCRIPTORS 32
#define N_TRANSMIT_DESCRIPTORS 8

//? volatile??
struct rec_descriptor{

    volatile uint64_t buff_addr;
    volatile uint16_t len;
    volatile uint16_t checksum;
    volatile uint8_t  status;
    volatile uint8_t  errors;
    volatile uint16_t special;
} __attribute__((packed));

struct trn_descriptor{

    volatile uint64_t buff_addr;
    volatile uint16_t len;
    volatile uint8_t  checksum_offset;
    volatile uint8_t  cmd;
    volatile uint8_t  status : 4;
    volatile uint8_t  reserved : 4;
    volatile uint8_t  checksum_start_field;
    volatile uint16_t special;
} __attribute__((packed));

__attribute__((aligned(16))) static struct rec_descriptor rec_descriptor_buffer[N_RECEIVE_DESCRIPTORS] = {};
__attribute__((aligned(16))) static struct trn_descriptor trn_descriptor_buffer[N_TRANSMIT_DESCRIPTORS] = {};

#endif // JOS_INC_E1000_H
