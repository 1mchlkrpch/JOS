
obj/kern/kernel:     file format elf64-x86-64


Disassembly of section .bootstrap:

0000000001500000 <_head64>:

.text
.globl _head64
_head64:
    # Disable interrupts.
    cli
 1500000:	fa                   	cli    

    # Save Loader_block pointer from Bootloader.c in r12
    movq %rcx, %r12
 1500001:	49 89 cc             	mov    %rcx,%r12

    # Build an early boot pml4 at pml4phys (physical = virtual for it)

    # Initialize the page tables.
    movq $pml4, %rdi
 1500004:	48 c7 c7 00 10 50 01 	mov    $0x1501000,%rdi
    xorl %eax, %eax
 150000b:	31 c0                	xor    %eax,%eax
    movq $PML_SIZE, %rcx  # moving these many words to the 11 pages
 150000d:	48 c7 c1 00 16 00 00 	mov    $0x1600,%rcx
    rep stosq
 1500014:	f3 48 ab             	rep stos %rax,%es:(%rdi)

    # Creating a 4G boot page table...

    # Setting the 4-level page table with only the second entry needed (PML4)
    movq $pml4, %rdi
 1500017:	48 c7 c7 00 10 50 01 	mov    $0x1501000,%rdi
    movq $(pdpt1 + (PTE_P | PTE_W)), %rax
 150001e:	48 c7 c0 03 20 50 01 	mov    $0x1502003,%rax
    stosq
 1500025:	48 ab                	stos   %rax,%es:(%rdi)
    movq %rax, (%rdi)
 1500027:	48 89 07             	mov    %rax,(%rdi)
    movq $(pdpt2 + (PTE_P | PTE_W)), %rax
 150002a:	48 c7 c0 03 30 50 01 	mov    $0x1503003,%rax
    stosq
 1500031:	48 ab                	stos   %rax,%es:(%rdi)

    # Setting the 3rd level page table (PDPE)
    # 4 entries (counter in ecx), point to the next four physical pages (pgdirs)
    # pgdirs in 0xA0000--0xD000
    movq $pdpt1, %rdi
 1500033:	48 c7 c7 00 20 50 01 	mov    $0x1502000,%rdi
    movq $(pde1 + (PTE_P | PTE_W)), %rax
 150003a:	48 c7 c0 03 40 50 01 	mov    $0x1504003,%rax
    stosq
 1500041:	48 ab                	stos   %rax,%es:(%rdi)

    movq $(pdpt2 + 8), %rdi
 1500043:	48 c7 c7 08 30 50 01 	mov    $0x1503008,%rdi
    movq $(pde2 + (PTE_P | PTE_W)), %rax
 150004a:	48 c7 c0 03 50 50 01 	mov    $0x1505003,%rax
    stosq
 1500051:	48 ab                	stos   %rax,%es:(%rdi)

    # Setting the pgdir so that the LA=PA
    # Mapping first 1024mb of mem at KERN_BASE_ADDR
    movq $-PDP_ENTRY_COUNT, %rcx
 1500053:	48 c7 c1 00 fe ff ff 	mov    $0xfffffffffffffe00,%rcx
    movq $pde1, %rdi
 150005a:	48 c7 c7 00 40 50 01 	mov    $0x1504000,%rdi
    movq $pde2, %rsi
 1500061:	48 c7 c6 00 50 50 01 	mov    $0x1505000,%rsi
    movl $(PTE_P|PTE_W|PTE_MBZ), %eax
 1500068:	b8 83 01 00 00       	mov    $0x183,%eax
1:
    movq %rax, PAGE_SIZE(%rsi,%rcx,8)
 150006d:	48 89 84 ce 00 10 00 	mov    %rax,0x1000(%rsi,%rcx,8)
 1500074:	00 
    movq %rax, PAGE_SIZE(%rdi,%rcx,8)
 1500075:	48 89 84 cf 00 10 00 	mov    %rax,0x1000(%rdi,%rcx,8)
 150007c:	00 
    addq $HUGE_PAGE_SIZE, %rax
 150007d:	48 05 00 00 20 00    	add    $0x200000,%rax
    incq %rcx
 1500083:	48 ff c1             	inc    %rcx
    jnz 1b
 1500086:	75 e5                	jne    150006d <_head64+0x6d>

    # Update CR3 register
    movq $pml4, %rax
 1500088:	48 c7 c0 00 10 50 01 	mov    $0x1501000,%rax
    movq %rax, %cr3
 150008f:	0f 22 d8             	mov    %rax,%cr3

    # Transition to high mem entry code and pass LoadParams address
    movabs $entry, %rax
 1500092:	48 b8 00 00 60 41 80 	movabs $0x8041600000,%rax
 1500099:	00 00 00 
    movq %r12, %rcx
 150009c:	4c 89 e1             	mov    %r12,%rcx
    jmpq *%rax
 150009f:	ff e0                	jmp    *%rax
 15000a1:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15000a8:	00 00 00 
 15000ab:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15000b2:	00 00 00 
 15000b5:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15000bc:	00 00 00 
 15000bf:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15000c6:	00 00 00 
 15000c9:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15000d0:	00 00 00 
 15000d3:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15000da:	00 00 00 
 15000dd:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15000e4:	00 00 00 
 15000e7:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15000ee:	00 00 00 
 15000f1:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15000f8:	00 00 00 
 15000fb:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500102:	00 00 00 
 1500105:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150010c:	00 00 00 
 150010f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500116:	00 00 00 
 1500119:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500120:	00 00 00 
 1500123:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150012a:	00 00 00 
 150012d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500134:	00 00 00 
 1500137:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150013e:	00 00 00 
 1500141:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500148:	00 00 00 
 150014b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500152:	00 00 00 
 1500155:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150015c:	00 00 00 
 150015f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500166:	00 00 00 
 1500169:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500170:	00 00 00 
 1500173:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150017a:	00 00 00 
 150017d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500184:	00 00 00 
 1500187:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150018e:	00 00 00 
 1500191:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500198:	00 00 00 
 150019b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15001a2:	00 00 00 
 15001a5:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15001ac:	00 00 00 
 15001af:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15001b6:	00 00 00 
 15001b9:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15001c0:	00 00 00 
 15001c3:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15001ca:	00 00 00 
 15001cd:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15001d4:	00 00 00 
 15001d7:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15001de:	00 00 00 
 15001e1:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15001e8:	00 00 00 
 15001eb:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15001f2:	00 00 00 
 15001f5:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15001fc:	00 00 00 
 15001ff:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500206:	00 00 00 
 1500209:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500210:	00 00 00 
 1500213:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150021a:	00 00 00 
 150021d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500224:	00 00 00 
 1500227:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150022e:	00 00 00 
 1500231:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500238:	00 00 00 
 150023b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500242:	00 00 00 
 1500245:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150024c:	00 00 00 
 150024f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500256:	00 00 00 
 1500259:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500260:	00 00 00 
 1500263:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150026a:	00 00 00 
 150026d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500274:	00 00 00 
 1500277:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150027e:	00 00 00 
 1500281:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500288:	00 00 00 
 150028b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500292:	00 00 00 
 1500295:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150029c:	00 00 00 
 150029f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15002a6:	00 00 00 
 15002a9:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15002b0:	00 00 00 
 15002b3:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15002ba:	00 00 00 
 15002bd:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15002c4:	00 00 00 
 15002c7:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15002ce:	00 00 00 
 15002d1:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15002d8:	00 00 00 
 15002db:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15002e2:	00 00 00 
 15002e5:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15002ec:	00 00 00 
 15002ef:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15002f6:	00 00 00 
 15002f9:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500300:	00 00 00 
 1500303:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150030a:	00 00 00 
 150030d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500314:	00 00 00 
 1500317:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150031e:	00 00 00 
 1500321:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500328:	00 00 00 
 150032b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500332:	00 00 00 
 1500335:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150033c:	00 00 00 
 150033f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500346:	00 00 00 
 1500349:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500350:	00 00 00 
 1500353:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150035a:	00 00 00 
 150035d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500364:	00 00 00 
 1500367:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150036e:	00 00 00 
 1500371:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500378:	00 00 00 
 150037b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500382:	00 00 00 
 1500385:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150038c:	00 00 00 
 150038f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500396:	00 00 00 
 1500399:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15003a0:	00 00 00 
 15003a3:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15003aa:	00 00 00 
 15003ad:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15003b4:	00 00 00 
 15003b7:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15003be:	00 00 00 
 15003c1:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15003c8:	00 00 00 
 15003cb:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15003d2:	00 00 00 
 15003d5:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15003dc:	00 00 00 
 15003df:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15003e6:	00 00 00 
 15003e9:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15003f0:	00 00 00 
 15003f3:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15003fa:	00 00 00 
 15003fd:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500404:	00 00 00 
 1500407:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150040e:	00 00 00 
 1500411:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500418:	00 00 00 
 150041b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500422:	00 00 00 
 1500425:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150042c:	00 00 00 
 150042f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500436:	00 00 00 
 1500439:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500440:	00 00 00 
 1500443:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150044a:	00 00 00 
 150044d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500454:	00 00 00 
 1500457:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150045e:	00 00 00 
 1500461:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500468:	00 00 00 
 150046b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500472:	00 00 00 
 1500475:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150047c:	00 00 00 
 150047f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500486:	00 00 00 
 1500489:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500490:	00 00 00 
 1500493:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150049a:	00 00 00 
 150049d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15004a4:	00 00 00 
 15004a7:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15004ae:	00 00 00 
 15004b1:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15004b8:	00 00 00 
 15004bb:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15004c2:	00 00 00 
 15004c5:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15004cc:	00 00 00 
 15004cf:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15004d6:	00 00 00 
 15004d9:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15004e0:	00 00 00 
 15004e3:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15004ea:	00 00 00 
 15004ed:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15004f4:	00 00 00 
 15004f7:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15004fe:	00 00 00 
 1500501:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500508:	00 00 00 
 150050b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500512:	00 00 00 
 1500515:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150051c:	00 00 00 
 150051f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500526:	00 00 00 
 1500529:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500530:	00 00 00 
 1500533:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150053a:	00 00 00 
 150053d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500544:	00 00 00 
 1500547:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150054e:	00 00 00 
 1500551:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500558:	00 00 00 
 150055b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500562:	00 00 00 
 1500565:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150056c:	00 00 00 
 150056f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500576:	00 00 00 
 1500579:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500580:	00 00 00 
 1500583:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150058a:	00 00 00 
 150058d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500594:	00 00 00 
 1500597:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150059e:	00 00 00 
 15005a1:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15005a8:	00 00 00 
 15005ab:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15005b2:	00 00 00 
 15005b5:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15005bc:	00 00 00 
 15005bf:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15005c6:	00 00 00 
 15005c9:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15005d0:	00 00 00 
 15005d3:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15005da:	00 00 00 
 15005dd:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15005e4:	00 00 00 
 15005e7:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15005ee:	00 00 00 
 15005f1:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15005f8:	00 00 00 
 15005fb:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500602:	00 00 00 
 1500605:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150060c:	00 00 00 
 150060f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500616:	00 00 00 
 1500619:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500620:	00 00 00 
 1500623:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150062a:	00 00 00 
 150062d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500634:	00 00 00 
 1500637:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150063e:	00 00 00 
 1500641:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500648:	00 00 00 
 150064b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500652:	00 00 00 
 1500655:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150065c:	00 00 00 
 150065f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500666:	00 00 00 
 1500669:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500670:	00 00 00 
 1500673:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150067a:	00 00 00 
 150067d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500684:	00 00 00 
 1500687:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150068e:	00 00 00 
 1500691:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500698:	00 00 00 
 150069b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15006a2:	00 00 00 
 15006a5:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15006ac:	00 00 00 
 15006af:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15006b6:	00 00 00 
 15006b9:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15006c0:	00 00 00 
 15006c3:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15006ca:	00 00 00 
 15006cd:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15006d4:	00 00 00 
 15006d7:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15006de:	00 00 00 
 15006e1:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15006e8:	00 00 00 
 15006eb:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15006f2:	00 00 00 
 15006f5:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15006fc:	00 00 00 
 15006ff:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500706:	00 00 00 
 1500709:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500710:	00 00 00 
 1500713:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150071a:	00 00 00 
 150071d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500724:	00 00 00 
 1500727:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150072e:	00 00 00 
 1500731:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500738:	00 00 00 
 150073b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500742:	00 00 00 
 1500745:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150074c:	00 00 00 
 150074f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500756:	00 00 00 
 1500759:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500760:	00 00 00 
 1500763:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150076a:	00 00 00 
 150076d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500774:	00 00 00 
 1500777:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150077e:	00 00 00 
 1500781:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500788:	00 00 00 
 150078b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500792:	00 00 00 
 1500795:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150079c:	00 00 00 
 150079f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15007a6:	00 00 00 
 15007a9:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15007b0:	00 00 00 
 15007b3:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15007ba:	00 00 00 
 15007bd:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15007c4:	00 00 00 
 15007c7:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15007ce:	00 00 00 
 15007d1:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15007d8:	00 00 00 
 15007db:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15007e2:	00 00 00 
 15007e5:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15007ec:	00 00 00 
 15007ef:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15007f6:	00 00 00 
 15007f9:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500800:	00 00 00 
 1500803:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150080a:	00 00 00 
 150080d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500814:	00 00 00 
 1500817:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150081e:	00 00 00 
 1500821:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500828:	00 00 00 
 150082b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500832:	00 00 00 
 1500835:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150083c:	00 00 00 
 150083f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500846:	00 00 00 
 1500849:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500850:	00 00 00 
 1500853:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150085a:	00 00 00 
 150085d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500864:	00 00 00 
 1500867:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150086e:	00 00 00 
 1500871:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500878:	00 00 00 
 150087b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500882:	00 00 00 
 1500885:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150088c:	00 00 00 
 150088f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500896:	00 00 00 
 1500899:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15008a0:	00 00 00 
 15008a3:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15008aa:	00 00 00 
 15008ad:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15008b4:	00 00 00 
 15008b7:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15008be:	00 00 00 
 15008c1:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15008c8:	00 00 00 
 15008cb:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15008d2:	00 00 00 
 15008d5:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15008dc:	00 00 00 
 15008df:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15008e6:	00 00 00 
 15008e9:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15008f0:	00 00 00 
 15008f3:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15008fa:	00 00 00 
 15008fd:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500904:	00 00 00 
 1500907:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150090e:	00 00 00 
 1500911:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500918:	00 00 00 
 150091b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500922:	00 00 00 
 1500925:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150092c:	00 00 00 
 150092f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500936:	00 00 00 
 1500939:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500940:	00 00 00 
 1500943:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150094a:	00 00 00 
 150094d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500954:	00 00 00 
 1500957:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150095e:	00 00 00 
 1500961:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500968:	00 00 00 
 150096b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500972:	00 00 00 
 1500975:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150097c:	00 00 00 
 150097f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500986:	00 00 00 
 1500989:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500990:	00 00 00 
 1500993:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 150099a:	00 00 00 
 150099d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15009a4:	00 00 00 
 15009a7:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15009ae:	00 00 00 
 15009b1:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15009b8:	00 00 00 
 15009bb:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15009c2:	00 00 00 
 15009c5:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15009cc:	00 00 00 
 15009cf:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15009d6:	00 00 00 
 15009d9:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15009e0:	00 00 00 
 15009e3:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15009ea:	00 00 00 
 15009ed:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15009f4:	00 00 00 
 15009f7:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 15009fe:	00 00 00 
 1500a01:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500a08:	00 00 00 
 1500a0b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500a12:	00 00 00 
 1500a15:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500a1c:	00 00 00 
 1500a1f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500a26:	00 00 00 
 1500a29:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500a30:	00 00 00 
 1500a33:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500a3a:	00 00 00 
 1500a3d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500a44:	00 00 00 
 1500a47:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500a4e:	00 00 00 
 1500a51:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500a58:	00 00 00 
 1500a5b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500a62:	00 00 00 
 1500a65:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500a6c:	00 00 00 
 1500a6f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500a76:	00 00 00 
 1500a79:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500a80:	00 00 00 
 1500a83:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500a8a:	00 00 00 
 1500a8d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500a94:	00 00 00 
 1500a97:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500a9e:	00 00 00 
 1500aa1:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500aa8:	00 00 00 
 1500aab:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500ab2:	00 00 00 
 1500ab5:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500abc:	00 00 00 
 1500abf:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500ac6:	00 00 00 
 1500ac9:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500ad0:	00 00 00 
 1500ad3:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500ada:	00 00 00 
 1500add:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500ae4:	00 00 00 
 1500ae7:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500aee:	00 00 00 
 1500af1:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500af8:	00 00 00 
 1500afb:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500b02:	00 00 00 
 1500b05:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500b0c:	00 00 00 
 1500b0f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500b16:	00 00 00 
 1500b19:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500b20:	00 00 00 
 1500b23:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500b2a:	00 00 00 
 1500b2d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500b34:	00 00 00 
 1500b37:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500b3e:	00 00 00 
 1500b41:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500b48:	00 00 00 
 1500b4b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500b52:	00 00 00 
 1500b55:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500b5c:	00 00 00 
 1500b5f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500b66:	00 00 00 
 1500b69:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500b70:	00 00 00 
 1500b73:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500b7a:	00 00 00 
 1500b7d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500b84:	00 00 00 
 1500b87:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500b8e:	00 00 00 
 1500b91:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500b98:	00 00 00 
 1500b9b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500ba2:	00 00 00 
 1500ba5:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500bac:	00 00 00 
 1500baf:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500bb6:	00 00 00 
 1500bb9:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500bc0:	00 00 00 
 1500bc3:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500bca:	00 00 00 
 1500bcd:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500bd4:	00 00 00 
 1500bd7:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500bde:	00 00 00 
 1500be1:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500be8:	00 00 00 
 1500beb:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500bf2:	00 00 00 
 1500bf5:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500bfc:	00 00 00 
 1500bff:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500c06:	00 00 00 
 1500c09:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500c10:	00 00 00 
 1500c13:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500c1a:	00 00 00 
 1500c1d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500c24:	00 00 00 
 1500c27:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500c2e:	00 00 00 
 1500c31:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500c38:	00 00 00 
 1500c3b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500c42:	00 00 00 
 1500c45:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500c4c:	00 00 00 
 1500c4f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500c56:	00 00 00 
 1500c59:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500c60:	00 00 00 
 1500c63:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500c6a:	00 00 00 
 1500c6d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500c74:	00 00 00 
 1500c77:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500c7e:	00 00 00 
 1500c81:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500c88:	00 00 00 
 1500c8b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500c92:	00 00 00 
 1500c95:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500c9c:	00 00 00 
 1500c9f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500ca6:	00 00 00 
 1500ca9:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500cb0:	00 00 00 
 1500cb3:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500cba:	00 00 00 
 1500cbd:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500cc4:	00 00 00 
 1500cc7:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500cce:	00 00 00 
 1500cd1:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500cd8:	00 00 00 
 1500cdb:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500ce2:	00 00 00 
 1500ce5:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500cec:	00 00 00 
 1500cef:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500cf6:	00 00 00 
 1500cf9:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500d00:	00 00 00 
 1500d03:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500d0a:	00 00 00 
 1500d0d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500d14:	00 00 00 
 1500d17:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500d1e:	00 00 00 
 1500d21:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500d28:	00 00 00 
 1500d2b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500d32:	00 00 00 
 1500d35:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500d3c:	00 00 00 
 1500d3f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500d46:	00 00 00 
 1500d49:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500d50:	00 00 00 
 1500d53:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500d5a:	00 00 00 
 1500d5d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500d64:	00 00 00 
 1500d67:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500d6e:	00 00 00 
 1500d71:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500d78:	00 00 00 
 1500d7b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500d82:	00 00 00 
 1500d85:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500d8c:	00 00 00 
 1500d8f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500d96:	00 00 00 
 1500d99:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500da0:	00 00 00 
 1500da3:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500daa:	00 00 00 
 1500dad:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500db4:	00 00 00 
 1500db7:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500dbe:	00 00 00 
 1500dc1:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500dc8:	00 00 00 
 1500dcb:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500dd2:	00 00 00 
 1500dd5:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500ddc:	00 00 00 
 1500ddf:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500de6:	00 00 00 
 1500de9:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500df0:	00 00 00 
 1500df3:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500dfa:	00 00 00 
 1500dfd:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500e04:	00 00 00 
 1500e07:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500e0e:	00 00 00 
 1500e11:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500e18:	00 00 00 
 1500e1b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500e22:	00 00 00 
 1500e25:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500e2c:	00 00 00 
 1500e2f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500e36:	00 00 00 
 1500e39:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500e40:	00 00 00 
 1500e43:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500e4a:	00 00 00 
 1500e4d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500e54:	00 00 00 
 1500e57:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500e5e:	00 00 00 
 1500e61:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500e68:	00 00 00 
 1500e6b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500e72:	00 00 00 
 1500e75:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500e7c:	00 00 00 
 1500e7f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500e86:	00 00 00 
 1500e89:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500e90:	00 00 00 
 1500e93:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500e9a:	00 00 00 
 1500e9d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500ea4:	00 00 00 
 1500ea7:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500eae:	00 00 00 
 1500eb1:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500eb8:	00 00 00 
 1500ebb:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500ec2:	00 00 00 
 1500ec5:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500ecc:	00 00 00 
 1500ecf:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500ed6:	00 00 00 
 1500ed9:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500ee0:	00 00 00 
 1500ee3:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500eea:	00 00 00 
 1500eed:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500ef4:	00 00 00 
 1500ef7:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500efe:	00 00 00 
 1500f01:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500f08:	00 00 00 
 1500f0b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500f12:	00 00 00 
 1500f15:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500f1c:	00 00 00 
 1500f1f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500f26:	00 00 00 
 1500f29:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500f30:	00 00 00 
 1500f33:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500f3a:	00 00 00 
 1500f3d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500f44:	00 00 00 
 1500f47:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500f4e:	00 00 00 
 1500f51:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500f58:	00 00 00 
 1500f5b:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500f62:	00 00 00 
 1500f65:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500f6c:	00 00 00 
 1500f6f:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500f76:	00 00 00 
 1500f79:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500f80:	00 00 00 
 1500f83:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500f8a:	00 00 00 
 1500f8d:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500f94:	00 00 00 
 1500f97:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500f9e:	00 00 00 
 1500fa1:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500fa8:	00 00 00 
 1500fab:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500fb2:	00 00 00 
 1500fb5:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500fbc:	00 00 00 
 1500fbf:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500fc6:	00 00 00 
 1500fc9:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500fd0:	00 00 00 
 1500fd3:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500fda:	00 00 00 
 1500fdd:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500fe4:	00 00 00 
 1500fe7:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500fee:	00 00 00 
 1500ff1:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 1500ff8:	00 00 00 
 1500ffb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

0000000001501000 <pml4phys>:
	...

0000000001502000 <pdpt1>:
	...

0000000001503000 <pdpt2>:
	...

0000000001504000 <pde1>:
	...

0000000001505000 <pde2>:
	...

0000000001506000 <pdefreestart>:
	...

Disassembly of section .text:

0000008041600000 <__text_start>:
.text

.globl entry
entry:
    # Set up kernel stack
    leaq bootstacktop(%rip),%rsp
  8041600000:	48 8d 25 f9 cf 01 00 	lea    0x1cff9(%rip),%rsp        # 804161d000 <bootstacktop>
    xor %ebp, %ebp
  8041600007:	31 ed                	xor    %ebp,%ebp

    # Save LoadParams in uefi_lp.
    movq %rcx, uefi_lp(%rip)
  8041600009:	48 89 0d f0 cf 02 00 	mov    %rcx,0x2cff0(%rip)        # 804162d000 <pfstacktop>

    # Invoke C code
    call i386_init
  8041600010:	e8 6d 05 00 00       	call   8041600582 <i386_init>
    # Should never reach this place
    jmp .
  8041600015:	eb fe                	jmp    8041600015 <__text_start+0x15>

0000008041600017 <save_trapframe_trap>:

#ifdef CONFIG_KSPACE

.global save_trapframe_trap
save_trapframe_trap:
    popq save_trapframe_ret(%rip)
  8041600017:	8f 05 eb cf 02 00    	pop    0x2cfeb(%rip)        # 804162d008 <save_trapframe_ret>
    popq saved_rip(%rip)
  804160001d:	8f 05 b5 cf 01 00    	pop    0x1cfb5(%rip)        # 804161cfd8 <saved_rip>
    popq saved_cs(%rip)
  8041600023:	8f 05 b7 cf 01 00    	pop    0x1cfb7(%rip)        # 804161cfe0 <saved_cs>
    popq saved_rflags(%rip)
  8041600029:	8f 05 b9 cf 01 00    	pop    0x1cfb9(%rip)        # 804161cfe8 <saved_rflags>
    popq saved_rsp(%rip)
  804160002f:	8f 05 bb cf 01 00    	pop    0x1cfbb(%rip)        # 804161cff0 <saved_rsp>
    popq saved_ss(%rip)
  8041600035:	8f 05 bd cf 01 00    	pop    0x1cfbd(%rip)        # 804161cff8 <saved_ss>
    jmp save_trapframe
  804160003b:	eb 30                	jmp    804160006d <save_trapframe>

000000804160003d <save_trapframe_syscall>:

save_trapframe_syscall:
    popq save_trapframe_ret(%rip)
  804160003d:	8f 05 c5 cf 02 00    	pop    0x2cfc5(%rip)        # 804162d008 <save_trapframe_ret>
    popq saved_rip(%rip)
  8041600043:	8f 05 8f cf 01 00    	pop    0x1cf8f(%rip)        # 804161cfd8 <saved_rip>
    movq %rsp, saved_rsp(%rip)
  8041600049:	48 89 25 a0 cf 01 00 	mov    %rsp,0x1cfa0(%rip)        # 804161cff0 <saved_rsp>
    pushfq
  8041600050:	9c                   	pushf  
    movq $GD_KD, saved_ss(%rip)
  8041600051:	48 c7 05 9c cf 01 00 	movq   $0x10,0x1cf9c(%rip)        # 804161cff8 <saved_ss>
  8041600058:	10 00 00 00 
    movq $GD_KT, saved_cs(%rip)
  804160005c:	48 c7 05 79 cf 01 00 	movq   $0x8,0x1cf79(%rip)        # 804161cfe0 <saved_cs>
  8041600063:	08 00 00 00 
    popq saved_rflags(%rip)
  8041600067:	8f 05 7b cf 01 00    	pop    0x1cf7b(%rip)        # 804161cfe8 <saved_rflags>

000000804160006d <save_trapframe>:
    # fallthrough

save_trapframe:
    orl $FL_IF, saved_rflags(%rip)
  804160006d:	81 0d 71 cf 01 00 00 	orl    $0x200,0x1cf71(%rip)        # 804161cfe8 <saved_rflags>
  8041600074:	02 00 00 

    # We already pushed ss,rsp,rflags,cs,rip
    # implicitly
    leaq (bootstacktop-0x28)(%rip), %rsp
  8041600077:	48 8d 25 5a cf 01 00 	lea    0x1cf5a(%rip),%rsp        # 804161cfd8 <saved_rip>

    pushq $0x0
  804160007e:	6a 00                	push   $0x0
    pushq $0x0
  8041600080:	6a 00                	push   $0x0
    pushq $0x0 # %ds
  8041600082:	6a 00                	push   $0x0
    pushq $0x0 # %es
  8041600084:	6a 00                	push   $0x0

    PUSHA
  8041600086:	48 83 ec 78          	sub    $0x78,%rsp
  804160008a:	48 89 44 24 70       	mov    %rax,0x70(%rsp)
  804160008f:	48 89 5c 24 68       	mov    %rbx,0x68(%rsp)
  8041600094:	48 89 4c 24 60       	mov    %rcx,0x60(%rsp)
  8041600099:	48 89 54 24 58       	mov    %rdx,0x58(%rsp)
  804160009e:	48 89 6c 24 50       	mov    %rbp,0x50(%rsp)
  80416000a3:	48 89 7c 24 48       	mov    %rdi,0x48(%rsp)
  80416000a8:	48 89 74 24 40       	mov    %rsi,0x40(%rsp)
  80416000ad:	4c 89 44 24 38       	mov    %r8,0x38(%rsp)
  80416000b2:	4c 89 4c 24 30       	mov    %r9,0x30(%rsp)
  80416000b7:	4c 89 54 24 28       	mov    %r10,0x28(%rsp)
  80416000bc:	4c 89 5c 24 20       	mov    %r11,0x20(%rsp)
  80416000c1:	4c 89 64 24 18       	mov    %r12,0x18(%rsp)
  80416000c6:	4c 89 6c 24 10       	mov    %r13,0x10(%rsp)
  80416000cb:	4c 89 74 24 08       	mov    %r14,0x8(%rsp)
  80416000d0:	4c 89 3c 24          	mov    %r15,(%rsp)

    xor %ebp, %ebp
  80416000d4:	31 ed                	xor    %ebp,%ebp
    movq %rsp, %rdi
  80416000d6:	48 89 e7             	mov    %rsp,%rdi
    jmp *save_trapframe_ret(%rip)
  80416000d9:	ff 25 29 cf 02 00    	jmp    *0x2cf29(%rip)        # 804162d008 <save_trapframe_ret>

00000080416000df <sys_yield>:

.globl sys_yield
.type  sys_yield, @function
sys_yield:
    cli
  80416000df:	fa                   	cli    
    call save_trapframe_syscall
  80416000e0:	e8 58 ff ff ff       	call   804160003d <save_trapframe_syscall>
    call csys_yield
  80416000e5:	e8 bf 69 00 00       	call   8041606aa9 <csys_yield>
    jmp .
  80416000ea:	eb fe                	jmp    80416000ea <sys_yield+0xb>

00000080416000ec <sys_exit>:

# LAB 3: Your code here:
.globl sys_exit
.type  sys_exit, @function
sys_exit:
    cli
  80416000ec:	fa                   	cli    
    leaq bootstacktop(%rip),%rsp
  80416000ed:	48 8d 25 0c cf 01 00 	lea    0x1cf0c(%rip),%rsp        # 804161d000 <bootstacktop>

    call csys_exit
  80416000f4:	e8 60 69 00 00       	call   8041606a59 <csys_exit>
    jmp .
  80416000f9:	eb fe                	jmp    80416000f9 <sys_exit+0xd>

00000080416000fb <timers_init>:
#include <kern/kdebug.h>
#include <kern/traceopt.h>
#include <kern/net.h>

void
timers_init(void) {
  80416000fb:	f3 0f 1e fa          	endbr64 
  80416000ff:	55                   	push   %rbp
  8041600100:	48 89 e5             	mov    %rsp,%rbp
  8041600103:	41 56                	push   %r14
  8041600105:	41 55                	push   %r13
  8041600107:	41 54                	push   %r12
  8041600109:	53                   	push   %rbx
    timertab[0] = timer_rtc;
  804160010a:	48 b8 a0 54 e4 41 80 	movabs $0x8041e454a0,%rax
  8041600111:	00 00 00 
  8041600114:	48 ba 40 d7 62 41 80 	movabs $0x804162d740,%rdx
  804160011b:	00 00 00 
  804160011e:	48 8b 0a             	mov    (%rdx),%rcx
  8041600121:	48 89 08             	mov    %rcx,(%rax)
  8041600124:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  8041600128:	48 89 48 08          	mov    %rcx,0x8(%rax)
  804160012c:	48 8b 4a 10          	mov    0x10(%rdx),%rcx
  8041600130:	48 89 48 10          	mov    %rcx,0x10(%rax)
  8041600134:	48 8b 4a 18          	mov    0x18(%rdx),%rcx
  8041600138:	48 89 48 18          	mov    %rcx,0x18(%rax)
  804160013c:	48 8b 52 20          	mov    0x20(%rdx),%rdx
  8041600140:	48 89 50 20          	mov    %rdx,0x20(%rax)
    timertab[1] = timer_pit;
  8041600144:	48 ba e0 d8 62 41 80 	movabs $0x804162d8e0,%rdx
  804160014b:	00 00 00 
  804160014e:	48 8b 0a             	mov    (%rdx),%rcx
  8041600151:	48 89 48 28          	mov    %rcx,0x28(%rax)
  8041600155:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  8041600159:	48 89 48 30          	mov    %rcx,0x30(%rax)
  804160015d:	48 8b 4a 10          	mov    0x10(%rdx),%rcx
  8041600161:	48 89 48 38          	mov    %rcx,0x38(%rax)
  8041600165:	48 8b 4a 18          	mov    0x18(%rdx),%rcx
  8041600169:	48 89 48 40          	mov    %rcx,0x40(%rax)
  804160016d:	48 8b 52 20          	mov    0x20(%rdx),%rdx
  8041600171:	48 89 50 48          	mov    %rdx,0x48(%rax)
    timertab[2] = timer_acpipm;
  8041600175:	48 ba 00 d8 62 41 80 	movabs $0x804162d800,%rdx
  804160017c:	00 00 00 
  804160017f:	48 8b 0a             	mov    (%rdx),%rcx
  8041600182:	48 89 48 50          	mov    %rcx,0x50(%rax)
  8041600186:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  804160018a:	48 89 48 58          	mov    %rcx,0x58(%rax)
  804160018e:	48 8b 4a 10          	mov    0x10(%rdx),%rcx
  8041600192:	48 89 48 60          	mov    %rcx,0x60(%rax)
  8041600196:	48 8b 4a 18          	mov    0x18(%rdx),%rcx
  804160019a:	48 89 48 68          	mov    %rcx,0x68(%rax)
  804160019e:	48 8b 52 20          	mov    0x20(%rdx),%rdx
  80416001a2:	48 89 50 70          	mov    %rdx,0x70(%rax)
    timertab[3] = timer_hpet0;
  80416001a6:	48 ba 80 d8 62 41 80 	movabs $0x804162d880,%rdx
  80416001ad:	00 00 00 
  80416001b0:	48 8b 0a             	mov    (%rdx),%rcx
  80416001b3:	48 89 48 78          	mov    %rcx,0x78(%rax)
  80416001b7:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  80416001bb:	48 89 88 80 00 00 00 	mov    %rcx,0x80(%rax)
  80416001c2:	48 8b 4a 10          	mov    0x10(%rdx),%rcx
  80416001c6:	48 89 88 88 00 00 00 	mov    %rcx,0x88(%rax)
  80416001cd:	48 8b 4a 18          	mov    0x18(%rdx),%rcx
  80416001d1:	48 89 88 90 00 00 00 	mov    %rcx,0x90(%rax)
  80416001d8:	48 8b 52 20          	mov    0x20(%rdx),%rdx
  80416001dc:	48 89 90 98 00 00 00 	mov    %rdx,0x98(%rax)
    timertab[4] = timer_hpet1;
  80416001e3:	48 ba 40 d8 62 41 80 	movabs $0x804162d840,%rdx
  80416001ea:	00 00 00 
  80416001ed:	48 8b 0a             	mov    (%rdx),%rcx
  80416001f0:	48 89 88 a0 00 00 00 	mov    %rcx,0xa0(%rax)
  80416001f7:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  80416001fb:	48 89 88 a8 00 00 00 	mov    %rcx,0xa8(%rax)
  8041600202:	48 8b 4a 10          	mov    0x10(%rdx),%rcx
  8041600206:	48 89 88 b0 00 00 00 	mov    %rcx,0xb0(%rax)
  804160020d:	48 8b 4a 18          	mov    0x18(%rdx),%rcx
  8041600211:	48 89 88 b8 00 00 00 	mov    %rcx,0xb8(%rax)
  8041600218:	48 8b 52 20          	mov    0x20(%rdx),%rdx
  804160021c:	48 89 90 c0 00 00 00 	mov    %rdx,0xc0(%rax)

    for (int i = 0; i < MAX_TIMERS; i++) {
  8041600223:	48 89 c3             	mov    %rax,%rbx
  8041600226:	4c 8d a0 c8 00 00 00 	lea    0xc8(%rax),%r12
        if (timertab[i].timer_init) {
            timertab[i].timer_init();
            if (trace_init) cprintf("Initialized timer %s\n", timertab[i].timer_name);
  804160022d:	49 be 10 a1 60 41 80 	movabs $0x804160a110,%r14
  8041600234:	00 00 00 
  8041600237:	49 bd b7 6f 60 41 80 	movabs $0x8041606fb7,%r13
  804160023e:	00 00 00 
  8041600241:	eb 09                	jmp    804160024c <timers_init+0x151>
    for (int i = 0; i < MAX_TIMERS; i++) {
  8041600243:	48 83 c3 28          	add    $0x28,%rbx
  8041600247:	4c 39 e3             	cmp    %r12,%rbx
  804160024a:	74 1b                	je     8041600267 <timers_init+0x16c>
        if (timertab[i].timer_init) {
  804160024c:	48 8b 43 08          	mov    0x8(%rbx),%rax
  8041600250:	48 85 c0             	test   %rax,%rax
  8041600253:	74 ee                	je     8041600243 <timers_init+0x148>
            timertab[i].timer_init();
  8041600255:	ff d0                	call   *%rax
            if (trace_init) cprintf("Initialized timer %s\n", timertab[i].timer_name);
  8041600257:	48 8b 33             	mov    (%rbx),%rsi
  804160025a:	4c 89 f7             	mov    %r14,%rdi
  804160025d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600262:	41 ff d5             	call   *%r13
  8041600265:	eb dc                	jmp    8041600243 <timers_init+0x148>
        }
    }
}
  8041600267:	5b                   	pop    %rbx
  8041600268:	41 5c                	pop    %r12
  804160026a:	41 5d                	pop    %r13
  804160026c:	41 5e                	pop    %r14
  804160026e:	5d                   	pop    %rbp
  804160026f:	c3                   	ret    

0000008041600270 <alloc_pd_early_boot>:

    panic("Timer %s does not exist\n", name);
}

pde_t *
alloc_pd_early_boot(void) {
  8041600270:	f3 0f 1e fa          	endbr64 
    /* Assume pde1, pde2 is already used */
    extern uintptr_t pdefreestart, pdefreeend;
    static uintptr_t pdefree = (uintptr_t)&pdefreestart;

    if (pdefree >= (uintptr_t)&pdefreeend) return NULL;
  8041600274:	48 a1 10 d0 62 41 80 	movabs 0x804162d010,%rax
  804160027b:	00 00 00 
  804160027e:	48 ba 00 c0 50 01 00 	movabs $0x150c000,%rdx
  8041600285:	00 00 00 
  8041600288:	48 39 d0             	cmp    %rdx,%rax
  804160028b:	73 17                	jae    80416002a4 <alloc_pd_early_boot+0x34>

    pde_t *ret = (pde_t *)pdefree;
  804160028d:	48 89 c2             	mov    %rax,%rdx
    pdefree += PAGE_SIZE;
  8041600290:	48 05 00 10 00 00    	add    $0x1000,%rax
  8041600296:	48 a3 10 d0 62 41 80 	movabs %rax,0x804162d010
  804160029d:	00 00 00 
    return ret;
}
  80416002a0:	48 89 d0             	mov    %rdx,%rax
  80416002a3:	c3                   	ret    
    if (pdefree >= (uintptr_t)&pdefreeend) return NULL;
  80416002a4:	ba 00 00 00 00       	mov    $0x0,%edx
  80416002a9:	eb f5                	jmp    80416002a0 <alloc_pd_early_boot+0x30>

00000080416002ab <map_addr_early_boot>:

void
map_addr_early_boot(uintptr_t va, uintptr_t pa, size_t sz) {
  80416002ab:	f3 0f 1e fa          	endbr64 
  80416002af:	55                   	push   %rbp
  80416002b0:	48 89 e5             	mov    %rsp,%rbp
  80416002b3:	41 57                	push   %r15
  80416002b5:	41 56                	push   %r14
  80416002b7:	41 55                	push   %r13
  80416002b9:	41 54                	push   %r12
  80416002bb:	53                   	push   %rbx
  80416002bc:	48 83 ec 18          	sub    $0x18,%rsp

    pml4e_t *pml4 = &pml4phys;
    pdpe_t *pdp;
    pde_t *pd;

    uintptr_t vstart = ROUNDDOWN(va, HUGE_PAGE_SIZE);
  80416002c0:	48 89 f8             	mov    %rdi,%rax
  80416002c3:	48 25 00 00 e0 ff    	and    $0xffffffffffe00000,%rax
    uintptr_t vend = ROUNDUP(va + sz, HUGE_PAGE_SIZE);
  80416002c9:	4c 8d bc 17 ff ff 1f 	lea    0x1fffff(%rdi,%rdx,1),%r15
  80416002d0:	00 
  80416002d1:	49 81 e7 00 00 e0 ff 	and    $0xffffffffffe00000,%r15
    uintptr_t pstart = ROUNDDOWN(pa, HUGE_PAGE_SIZE);
  80416002d8:	48 81 e6 00 00 e0 ff 	and    $0xffffffffffe00000,%rsi

    pdp = (pdpe_t *)PTE_ADDR(pml4[PML4_INDEX(vstart)]);
  80416002df:	48 c1 ef 24          	shr    $0x24,%rdi
  80416002e3:	81 e7 f8 0f 00 00    	and    $0xff8,%edi
  80416002e9:	48 ba 00 10 50 01 00 	movabs $0x1501000,%rdx
  80416002f0:	00 00 00 
  80416002f3:	48 b9 00 f0 ff ff ff 	movabs $0x7ffffffffffff000,%rcx
  80416002fa:	ff ff 7f 
  80416002fd:	48 23 0c 3a          	and    (%rdx,%rdi,1),%rcx
  8041600301:	48 89 4d c8          	mov    %rcx,-0x38(%rbp)
    for (; vstart < vend; vstart += HUGE_PAGE_SIZE, pstart += HUGE_PAGE_SIZE) {
  8041600305:	49 39 c7             	cmp    %rax,%r15
  8041600308:	76 70                	jbe    804160037a <map_addr_early_boot+0xcf>
    uintptr_t vstart = ROUNDDOWN(va, HUGE_PAGE_SIZE);
  804160030a:	49 89 c4             	mov    %rax,%r12
  804160030d:	48 29 c6             	sub    %rax,%rsi
  8041600310:	48 89 75 c0          	mov    %rsi,-0x40(%rbp)
        pd = (pde_t *)PTE_ADDR(pdp[PDP_INDEX(vstart)]);
  8041600314:	49 be 00 f0 ff ff ff 	movabs $0x7ffffffffffff000,%r14
  804160031b:	ff ff 7f 
  804160031e:	eb 21                	jmp    8041600341 <map_addr_early_boot+0x96>
        if (!pd) {
            pd = alloc_pd_early_boot();
            pdp[PDP_INDEX(vstart)] = (uintptr_t)pd | PTE_P | PTE_W;
        }
        pd[PD_INDEX(vstart)] = pstart | PTE_P | PTE_W | PTE_PS;
  8041600320:	4c 89 e2             	mov    %r12,%rdx
  8041600323:	48 c1 ea 15          	shr    $0x15,%rdx
  8041600327:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
  804160032d:	41 80 cd 83          	or     $0x83,%r13b
  8041600331:	4c 89 2c d0          	mov    %r13,(%rax,%rdx,8)
    for (; vstart < vend; vstart += HUGE_PAGE_SIZE, pstart += HUGE_PAGE_SIZE) {
  8041600335:	49 81 c4 00 00 20 00 	add    $0x200000,%r12
  804160033c:	4d 39 e7             	cmp    %r12,%r15
  804160033f:	76 39                	jbe    804160037a <map_addr_early_boot+0xcf>
  8041600341:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8041600345:	4e 8d 2c 20          	lea    (%rax,%r12,1),%r13
        pd = (pde_t *)PTE_ADDR(pdp[PDP_INDEX(vstart)]);
  8041600349:	4c 89 e3             	mov    %r12,%rbx
  804160034c:	48 c1 eb 1b          	shr    $0x1b,%rbx
  8041600350:	81 e3 f8 0f 00 00    	and    $0xff8,%ebx
  8041600356:	48 03 5d c8          	add    -0x38(%rbp),%rbx
        if (!pd) {
  804160035a:	4c 89 f0             	mov    %r14,%rax
  804160035d:	48 23 03             	and    (%rbx),%rax
  8041600360:	75 be                	jne    8041600320 <map_addr_early_boot+0x75>
            pd = alloc_pd_early_boot();
  8041600362:	48 b8 70 02 60 41 80 	movabs $0x8041600270,%rax
  8041600369:	00 00 00 
  804160036c:	ff d0                	call   *%rax
            pdp[PDP_INDEX(vstart)] = (uintptr_t)pd | PTE_P | PTE_W;
  804160036e:	48 89 c2             	mov    %rax,%rdx
  8041600371:	48 83 ca 03          	or     $0x3,%rdx
  8041600375:	48 89 13             	mov    %rdx,(%rbx)
  8041600378:	eb a6                	jmp    8041600320 <map_addr_early_boot+0x75>
    }
}
  804160037a:	48 83 c4 18          	add    $0x18,%rsp
  804160037e:	5b                   	pop    %rbx
  804160037f:	41 5c                	pop    %r12
  8041600381:	41 5d                	pop    %r13
  8041600383:	41 5e                	pop    %r14
  8041600385:	41 5f                	pop    %r15
  8041600387:	5d                   	pop    %rbp
  8041600388:	c3                   	ret    

0000008041600389 <early_boot_pml4_init>:
extern char end[];

/* Additionally maps pml4 memory so that we dont get memory errors on accessing
 * uefi_lp, MemMap, KASAN functions. */
void
early_boot_pml4_init(void) {
  8041600389:	f3 0f 1e fa          	endbr64 
  804160038d:	55                   	push   %rbp
  804160038e:	48 89 e5             	mov    %rsp,%rbp
  8041600391:	41 54                	push   %r12
  8041600393:	53                   	push   %rbx
    map_addr_early_boot((uintptr_t)uefi_lp, (uintptr_t)uefi_lp, sizeof(LOADER_PARAMS));
  8041600394:	49 bc 00 d0 62 41 80 	movabs $0x804162d000,%r12
  804160039b:	00 00 00 
  804160039e:	49 8b 3c 24          	mov    (%r12),%rdi
  80416003a2:	ba e8 00 00 00       	mov    $0xe8,%edx
  80416003a7:	48 89 fe             	mov    %rdi,%rsi
  80416003aa:	48 bb ab 02 60 41 80 	movabs $0x80416002ab,%rbx
  80416003b1:	00 00 00 
  80416003b4:	ff d3                	call   *%rbx
    map_addr_early_boot((uintptr_t)uefi_lp->MemoryMap, (uintptr_t)uefi_lp->MemoryMap, uefi_lp->MemoryMapSize);
  80416003b6:	49 8b 04 24          	mov    (%r12),%rax
  80416003ba:	48 8b 78 28          	mov    0x28(%rax),%rdi
  80416003be:	48 8b 50 38          	mov    0x38(%rax),%rdx
  80416003c2:	48 89 fe             	mov    %rdi,%rsi
  80416003c5:	ff d3                	call   *%rbx
     * it with other shadow memory would cause weird memory errors */
    map_shadow_early_boot(SHADOW_ADDR(KERN_STACK_TOP - KERN_STACK_SIZE), HUGE_PAGE_SIZE, one_page_raw);
#endif

#if LAB <= 6
    map_addr_early_boot(FRAMEBUFFER, uefi_lp->FrameBufferBase, uefi_lp->FrameBufferSize);
  80416003c7:	49 8b 04 24          	mov    (%r12),%rax
  80416003cb:	8b 50 48             	mov    0x48(%rax),%edx
  80416003ce:	48 8b 70 40          	mov    0x40(%rax),%rsi
  80416003d2:	48 bf 00 00 e0 1f 80 	movabs $0x801fe00000,%rdi
  80416003d9:	00 00 00 
  80416003dc:	ff d3                	call   *%rbx
#endif
}
  80416003de:	5b                   	pop    %rbx
  80416003df:	41 5c                	pop    %r12
  80416003e1:	5d                   	pop    %rbp
  80416003e2:	c3                   	ret    

00000080416003e3 <_panic>:
const char *panicstr = NULL;

/* Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor. */
_Noreturn void
_panic(const char *file, int line, const char *fmt, ...) {
  80416003e3:	f3 0f 1e fa          	endbr64 
  80416003e7:	55                   	push   %rbp
  80416003e8:	48 89 e5             	mov    %rsp,%rbp
  80416003eb:	41 54                	push   %r12
  80416003ed:	53                   	push   %rbx
  80416003ee:	48 83 ec 50          	sub    $0x50,%rsp
  80416003f2:	48 89 4d d8          	mov    %rcx,-0x28(%rbp)
  80416003f6:	4c 89 45 e0          	mov    %r8,-0x20(%rbp)
  80416003fa:	4c 89 4d e8          	mov    %r9,-0x18(%rbp)
    va_list ap;

    if (panicstr) goto dead;
  80416003fe:	48 b8 00 00 80 41 80 	movabs $0x8041800000,%rax
  8041600405:	00 00 00 
  8041600408:	48 83 38 00          	cmpq   $0x0,(%rax)
  804160040c:	74 13                	je     8041600421 <_panic+0x3e>
    cprintf("\n");
    va_end(ap);

dead:
    /* Break into the kernel monitor */
    for (;;) monitor(NULL);
  804160040e:	48 bb 6f 47 60 41 80 	movabs $0x804160476f,%rbx
  8041600415:	00 00 00 
  8041600418:	bf 00 00 00 00       	mov    $0x0,%edi
  804160041d:	ff d3                	call   *%rbx
  804160041f:	eb f7                	jmp    8041600418 <_panic+0x35>
  8041600421:	48 89 d3             	mov    %rdx,%rbx
    panicstr = fmt;
  8041600424:	48 89 d0             	mov    %rdx,%rax
  8041600427:	48 a3 00 00 80 41 80 	movabs %rax,0x8041800000
  804160042e:	00 00 00 
    asm volatile("cli; cld");
  8041600431:	fa                   	cli    
  8041600432:	fc                   	cld    
    va_start(ap, fmt);
  8041600433:	c7 45 a8 18 00 00 00 	movl   $0x18,-0x58(%rbp)
  804160043a:	48 8d 45 10          	lea    0x10(%rbp),%rax
  804160043e:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  8041600442:	48 8d 45 c0          	lea    -0x40(%rbp),%rax
  8041600446:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    cprintf("kernel panic at %s:%d: ", file, line);
  804160044a:	89 f2                	mov    %esi,%edx
  804160044c:	48 89 fe             	mov    %rdi,%rsi
  804160044f:	48 bf 26 a1 60 41 80 	movabs $0x804160a126,%rdi
  8041600456:	00 00 00 
  8041600459:	b8 00 00 00 00       	mov    $0x0,%eax
  804160045e:	49 bc b7 6f 60 41 80 	movabs $0x8041606fb7,%r12
  8041600465:	00 00 00 
  8041600468:	41 ff d4             	call   *%r12
    vcprintf(fmt, ap);
  804160046b:	48 8d 75 a8          	lea    -0x58(%rbp),%rsi
  804160046f:	48 89 df             	mov    %rbx,%rdi
  8041600472:	48 b8 7f 6f 60 41 80 	movabs $0x8041606f7f,%rax
  8041600479:	00 00 00 
  804160047c:	ff d0                	call   *%rax
    cprintf("\n");
  804160047e:	48 bf f0 a1 60 41 80 	movabs $0x804160a1f0,%rdi
  8041600485:	00 00 00 
  8041600488:	b8 00 00 00 00       	mov    $0x0,%eax
  804160048d:	41 ff d4             	call   *%r12
    va_end(ap);
  8041600490:	e9 79 ff ff ff       	jmp    804160040e <_panic+0x2b>

0000008041600495 <timers_schedule>:
timers_schedule(const char *name) {
  8041600495:	f3 0f 1e fa          	endbr64 
  8041600499:	55                   	push   %rbp
  804160049a:	48 89 e5             	mov    %rsp,%rbp
  804160049d:	41 56                	push   %r14
  804160049f:	41 55                	push   %r13
  80416004a1:	41 54                	push   %r12
  80416004a3:	53                   	push   %rbx
  80416004a4:	49 89 fd             	mov    %rdi,%r13
    for (int i = 0; i < MAX_TIMERS; i++) {
  80416004a7:	49 bc a0 54 e4 41 80 	movabs $0x8041e454a0,%r12
  80416004ae:	00 00 00 
  80416004b1:	bb 00 00 00 00       	mov    $0x0,%ebx
        if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  80416004b6:	49 be a6 92 60 41 80 	movabs $0x80416092a6,%r14
  80416004bd:	00 00 00 
  80416004c0:	eb 3a                	jmp    80416004fc <timers_schedule+0x67>
                panic("Timer %s does not support interrupts\n", name);
  80416004c2:	4c 89 e9             	mov    %r13,%rcx
  80416004c5:	48 ba c0 a1 60 41 80 	movabs $0x804160a1c0,%rdx
  80416004cc:	00 00 00 
  80416004cf:	be 2c 00 00 00       	mov    $0x2c,%esi
  80416004d4:	48 bf 3e a1 60 41 80 	movabs $0x804160a13e,%rdi
  80416004db:	00 00 00 
  80416004de:	b8 00 00 00 00       	mov    $0x0,%eax
  80416004e3:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  80416004ea:	00 00 00 
  80416004ed:	41 ff d0             	call   *%r8
    for (int i = 0; i < MAX_TIMERS; i++) {
  80416004f0:	83 c3 01             	add    $0x1,%ebx
  80416004f3:	49 83 c4 28          	add    $0x28,%r12
  80416004f7:	83 fb 05             	cmp    $0x5,%ebx
  80416004fa:	74 58                	je     8041600554 <timers_schedule+0xbf>
        if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  80416004fc:	49 8b 3c 24          	mov    (%r12),%rdi
  8041600500:	48 85 ff             	test   %rdi,%rdi
  8041600503:	74 eb                	je     80416004f0 <timers_schedule+0x5b>
  8041600505:	4c 89 ee             	mov    %r13,%rsi
  8041600508:	41 ff d6             	call   *%r14
  804160050b:	85 c0                	test   %eax,%eax
  804160050d:	75 e1                	jne    80416004f0 <timers_schedule+0x5b>
            if (!timertab[i].enable_interrupts) {
  804160050f:	48 63 c3             	movslq %ebx,%rax
  8041600512:	48 8d 14 80          	lea    (%rax,%rax,4),%rdx
  8041600516:	48 b8 a0 54 e4 41 80 	movabs $0x8041e454a0,%rax
  804160051d:	00 00 00 
  8041600520:	48 8b 54 d0 18       	mov    0x18(%rax,%rdx,8),%rdx
  8041600525:	48 85 d2             	test   %rdx,%rdx
  8041600528:	74 98                	je     80416004c2 <timers_schedule+0x2d>
            timer_for_schedule = &timertab[i];
  804160052a:	48 63 db             	movslq %ebx,%rbx
  804160052d:	48 8d 0c 9b          	lea    (%rbx,%rbx,4),%rcx
  8041600531:	48 b8 a0 54 e4 41 80 	movabs $0x8041e454a0,%rax
  8041600538:	00 00 00 
  804160053b:	48 8d 04 c8          	lea    (%rax,%rcx,8),%rax
  804160053f:	48 a3 80 54 e4 41 80 	movabs %rax,0x8041e45480
  8041600546:	00 00 00 
            timertab[i].enable_interrupts();
  8041600549:	ff d2                	call   *%rdx
}
  804160054b:	5b                   	pop    %rbx
  804160054c:	41 5c                	pop    %r12
  804160054e:	41 5d                	pop    %r13
  8041600550:	41 5e                	pop    %r14
  8041600552:	5d                   	pop    %rbp
  8041600553:	c3                   	ret    
    panic("Timer %s does not exist\n", name);
  8041600554:	4c 89 e9             	mov    %r13,%rcx
  8041600557:	48 ba 4a a1 60 41 80 	movabs $0x804160a14a,%rdx
  804160055e:	00 00 00 
  8041600561:	be 35 00 00 00       	mov    $0x35,%esi
  8041600566:	48 bf 3e a1 60 41 80 	movabs $0x804160a13e,%rdi
  804160056d:	00 00 00 
  8041600570:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600575:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  804160057c:	00 00 00 
  804160057f:	41 ff d0             	call   *%r8

0000008041600582 <i386_init>:
i386_init(void) {
  8041600582:	f3 0f 1e fa          	endbr64 
  8041600586:	55                   	push   %rbp
  8041600587:	48 89 e5             	mov    %rsp,%rbp
  804160058a:	53                   	push   %rbx
  804160058b:	48 83 ec 08          	sub    $0x8,%rsp
    early_boot_pml4_init();
  804160058f:	48 b8 89 03 60 41 80 	movabs $0x8041600389,%rax
  8041600596:	00 00 00 
  8041600599:	ff d0                	call   *%rax
    cons_init();
  804160059b:	48 b8 60 0d 60 41 80 	movabs $0x8041600d60,%rax
  80416005a2:	00 00 00 
  80416005a5:	ff d0                	call   *%rax
    tsc_calibrate();
  80416005a7:	48 b8 52 96 60 41 80 	movabs $0x8041609652,%rax
  80416005ae:	00 00 00 
  80416005b1:	ff d0                	call   *%rax
        cprintf("6828 decimal is %o octal!\n", 6828);
  80416005b3:	be ac 1a 00 00       	mov    $0x1aac,%esi
  80416005b8:	48 bf 63 a1 60 41 80 	movabs $0x804160a163,%rdi
  80416005bf:	00 00 00 
  80416005c2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416005c7:	48 bb b7 6f 60 41 80 	movabs $0x8041606fb7,%rbx
  80416005ce:	00 00 00 
  80416005d1:	ff d3                	call   *%rbx
        cprintf("END: %p\n", end);
  80416005d3:	48 be 00 60 e4 41 80 	movabs $0x8041e46000,%rsi
  80416005da:	00 00 00 
  80416005dd:	48 bf 7e a1 60 41 80 	movabs $0x804160a17e,%rdi
  80416005e4:	00 00 00 
  80416005e7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416005ec:	ff d3                	call   *%rbx
    init_memory();
  80416005ee:	48 b8 d9 5d 60 41 80 	movabs $0x8041605dd9,%rax
  80416005f5:	00 00 00 
  80416005f8:	ff d0                	call   *%rax
    pic_init();
  80416005fa:	48 b8 ca 6d 60 41 80 	movabs $0x8041606dca,%rax
  8041600601:	00 00 00 
  8041600604:	ff d0                	call   *%rax
    timers_init();
  8041600606:	48 b8 fb 00 60 41 80 	movabs $0x80416000fb,%rax
  804160060d:	00 00 00 
  8041600610:	ff d0                	call   *%rax
    fb_init();
  8041600612:	48 b8 31 0c 60 41 80 	movabs $0x8041600c31,%rax
  8041600619:	00 00 00 
  804160061c:	ff d0                	call   *%rax
    if (trace_init) cprintf("Framebuffer initialised\n");
  804160061e:	48 bf 87 a1 60 41 80 	movabs $0x804160a187,%rdi
  8041600625:	00 00 00 
  8041600628:	b8 00 00 00 00       	mov    $0x0,%eax
  804160062d:	ff d3                	call   *%rbx
    env_init();
  804160062f:	48 b8 24 63 60 41 80 	movabs $0x8041606324,%rax
  8041600636:	00 00 00 
  8041600639:	ff d0                	call   *%rax
    net_init();
  804160063b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600640:	48 ba 7e 9c 60 41 80 	movabs $0x8041609c7e,%rdx
  8041600647:	00 00 00 
  804160064a:	ff d2                	call   *%rdx
    timers_schedule("hpet0");
  804160064c:	48 bf a0 a1 60 41 80 	movabs $0x804160a1a0,%rdi
  8041600653:	00 00 00 
  8041600656:	48 b8 95 04 60 41 80 	movabs $0x8041600495,%rax
  804160065d:	00 00 00 
  8041600660:	ff d0                	call   *%rax
    ENV_CREATE_KERNEL_TYPE(prog_test1);
  8041600662:	48 bf 10 d9 62 41 80 	movabs $0x804162d910,%rdi
  8041600669:	00 00 00 
  804160066c:	48 be e8 10 63 41 80 	movabs $0x80416310e8,%rsi
  8041600673:	00 00 00 
  8041600676:	48 29 fe             	sub    %rdi,%rsi
  8041600679:	ba 01 00 00 00       	mov    $0x1,%edx
  804160067e:	48 bb f9 64 60 41 80 	movabs $0x80416064f9,%rbx
  8041600685:	00 00 00 
  8041600688:	ff d3                	call   *%rbx
    ENV_CREATE_KERNEL_TYPE(prog_test2);
  804160068a:	48 bf f0 10 63 41 80 	movabs $0x80416310f0,%rdi
  8041600691:	00 00 00 
  8041600694:	48 be b8 49 63 41 80 	movabs $0x80416349b8,%rsi
  804160069b:	00 00 00 
  804160069e:	48 29 fe             	sub    %rdi,%rsi
  80416006a1:	ba 01 00 00 00       	mov    $0x1,%edx
  80416006a6:	ff d3                	call   *%rbx
    ENV_CREATE_KERNEL_TYPE(prog_test3);
  80416006a8:	48 bf c0 49 63 41 80 	movabs $0x80416349c0,%rdi
  80416006af:	00 00 00 
  80416006b2:	48 be 18 82 63 41 80 	movabs $0x8041638218,%rsi
  80416006b9:	00 00 00 
  80416006bc:	48 29 fe             	sub    %rdi,%rsi
  80416006bf:	ba 01 00 00 00       	mov    $0x1,%edx
  80416006c4:	ff d3                	call   *%rbx
    ENV_CREATE_KERNEL_TYPE(prog_test4);
  80416006c6:	48 bf 20 82 63 41 80 	movabs $0x8041638220,%rdi
  80416006cd:	00 00 00 
  80416006d0:	48 be e8 b8 63 41 80 	movabs $0x804163b8e8,%rsi
  80416006d7:	00 00 00 
  80416006da:	48 29 fe             	sub    %rdi,%rsi
  80416006dd:	ba 01 00 00 00       	mov    $0x1,%edx
  80416006e2:	ff d3                	call   *%rbx
    ENV_CREATE_KERNEL_TYPE(prog_test5);
  80416006e4:	48 bf f0 b8 63 41 80 	movabs $0x804163b8f0,%rdi
  80416006eb:	00 00 00 
  80416006ee:	48 be 70 fd 63 41 80 	movabs $0x804163fd70,%rsi
  80416006f5:	00 00 00 
  80416006f8:	48 29 fe             	sub    %rdi,%rsi
  80416006fb:	ba 01 00 00 00       	mov    $0x1,%edx
  8041600700:	ff d3                	call   *%rbx
    ENV_CREATE_KERNEL_TYPE(prog_test6);
  8041600702:	48 bf 80 fd 63 41 80 	movabs $0x804163fd80,%rdi
  8041600709:	00 00 00 
  804160070c:	48 be 00 42 64 41 80 	movabs $0x8041644200,%rsi
  8041600713:	00 00 00 
  8041600716:	48 29 fe             	sub    %rdi,%rsi
  8041600719:	ba 01 00 00 00       	mov    $0x1,%edx
  804160071e:	ff d3                	call   *%rbx
   sched_yield();
  8041600720:	48 b8 2d 84 60 41 80 	movabs $0x804160842d,%rax
  8041600727:	00 00 00 
  804160072a:	ff d0                	call   *%rax

000000804160072c <_warn>:
}

/* Like panic, but don't */
void
_warn(const char *file, int line, const char *fmt, ...) {
  804160072c:	f3 0f 1e fa          	endbr64 
  8041600730:	55                   	push   %rbp
  8041600731:	48 89 e5             	mov    %rsp,%rbp
  8041600734:	41 54                	push   %r12
  8041600736:	53                   	push   %rbx
  8041600737:	48 83 ec 50          	sub    $0x50,%rsp
  804160073b:	48 89 d3             	mov    %rdx,%rbx
  804160073e:	48 89 4d d8          	mov    %rcx,-0x28(%rbp)
  8041600742:	4c 89 45 e0          	mov    %r8,-0x20(%rbp)
  8041600746:	4c 89 4d e8          	mov    %r9,-0x18(%rbp)
    va_list ap;

    va_start(ap, fmt);
  804160074a:	c7 45 a8 18 00 00 00 	movl   $0x18,-0x58(%rbp)
  8041600751:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8041600755:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  8041600759:	48 8d 45 c0          	lea    -0x40(%rbp),%rax
  804160075d:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    cprintf("kernel warning at %s:%d: ", file, line);
  8041600761:	89 f2                	mov    %esi,%edx
  8041600763:	48 89 fe             	mov    %rdi,%rsi
  8041600766:	48 bf a6 a1 60 41 80 	movabs $0x804160a1a6,%rdi
  804160076d:	00 00 00 
  8041600770:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600775:	49 bc b7 6f 60 41 80 	movabs $0x8041606fb7,%r12
  804160077c:	00 00 00 
  804160077f:	41 ff d4             	call   *%r12
    vcprintf(fmt, ap);
  8041600782:	48 8d 75 a8          	lea    -0x58(%rbp),%rsi
  8041600786:	48 89 df             	mov    %rbx,%rdi
  8041600789:	48 b8 7f 6f 60 41 80 	movabs $0x8041606f7f,%rax
  8041600790:	00 00 00 
  8041600793:	ff d0                	call   *%rax
    cprintf("\n");
  8041600795:	48 bf f0 a1 60 41 80 	movabs $0x804160a1f0,%rdi
  804160079c:	00 00 00 
  804160079f:	b8 00 00 00 00       	mov    $0x0,%eax
  80416007a4:	41 ff d4             	call   *%r12
    va_end(ap);
}
  80416007a7:	48 83 c4 50          	add    $0x50,%rsp
  80416007ab:	5b                   	pop    %rbx
  80416007ac:	41 5c                	pop    %r12
  80416007ae:	5d                   	pop    %rbp
  80416007af:	c3                   	ret    

00000080416007b0 <serial_proc_data>:
    inb(0x84);
    inb(0x84);
}

static int
serial_proc_data(void) {
  80416007b0:	f3 0f 1e fa          	endbr64 
}

static inline uint8_t __attribute__((always_inline))
inb(int port) {
    uint8_t data;
    asm volatile("inb %w1,%0"
  80416007b4:	ba fd 03 00 00       	mov    $0x3fd,%edx
  80416007b9:	ec                   	in     (%dx),%al
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) return -1;
  80416007ba:	a8 01                	test   $0x1,%al
  80416007bc:	74 0a                	je     80416007c8 <serial_proc_data+0x18>
  80416007be:	ba f8 03 00 00       	mov    $0x3f8,%edx
  80416007c3:	ec                   	in     (%dx),%al
    return inb(COM1 + COM_RX);
  80416007c4:	0f b6 c0             	movzbl %al,%eax
  80416007c7:	c3                   	ret    
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) return -1;
  80416007c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  80416007cd:	c3                   	ret    

00000080416007ce <cons_intr>:
} cons;

/* called by device interrupt routines to feed input characters
 * into the circular console input buffer */
static void
cons_intr(int (*proc)(void)) {
  80416007ce:	f3 0f 1e fa          	endbr64 
  80416007d2:	55                   	push   %rbp
  80416007d3:	48 89 e5             	mov    %rsp,%rbp
  80416007d6:	41 54                	push   %r12
  80416007d8:	53                   	push   %rbx
  80416007d9:	49 89 fc             	mov    %rdi,%r12
    int ch;

    while ((ch = (*proc)()) != -1) {
        if (!ch) continue;
        cons.buf[cons.wpos++] = ch;
  80416007dc:	48 bb 40 00 80 41 80 	movabs $0x8041800040,%rbx
  80416007e3:	00 00 00 
    while ((ch = (*proc)()) != -1) {
  80416007e6:	eb 22                	jmp    804160080a <cons_intr+0x3c>
        cons.buf[cons.wpos++] = ch;
  80416007e8:	8b 8b 04 02 00 00    	mov    0x204(%rbx),%ecx
  80416007ee:	8d 51 01             	lea    0x1(%rcx),%edx
  80416007f1:	89 c9                	mov    %ecx,%ecx
  80416007f3:	88 04 0b             	mov    %al,(%rbx,%rcx,1)
        if (cons.wpos == CONSBUFSIZE) cons.wpos = 0;
  80416007f6:	81 fa 00 02 00 00    	cmp    $0x200,%edx
  80416007fc:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600801:	0f 44 d0             	cmove  %eax,%edx
  8041600804:	89 93 04 02 00 00    	mov    %edx,0x204(%rbx)
    while ((ch = (*proc)()) != -1) {
  804160080a:	41 ff d4             	call   *%r12
  804160080d:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041600810:	74 06                	je     8041600818 <cons_intr+0x4a>
        if (!ch) continue;
  8041600812:	85 c0                	test   %eax,%eax
  8041600814:	75 d2                	jne    80416007e8 <cons_intr+0x1a>
  8041600816:	eb f2                	jmp    804160080a <cons_intr+0x3c>
    }
}
  8041600818:	5b                   	pop    %rbx
  8041600819:	41 5c                	pop    %r12
  804160081b:	5d                   	pop    %rbp
  804160081c:	c3                   	ret    

000000804160081d <kbd_proc_data>:
kbd_proc_data(void) {
  804160081d:	f3 0f 1e fa          	endbr64 
  8041600821:	55                   	push   %rbp
  8041600822:	48 89 e5             	mov    %rsp,%rbp
  8041600825:	53                   	push   %rbx
  8041600826:	48 83 ec 08          	sub    $0x8,%rsp
  804160082a:	ba 64 00 00 00       	mov    $0x64,%edx
  804160082f:	ec                   	in     (%dx),%al
    if (!(inb(KBSTATP) & KBS_DIB)) return -1;
  8041600830:	a8 01                	test   $0x1,%al
  8041600832:	0f 84 30 01 00 00    	je     8041600968 <kbd_proc_data+0x14b>
  8041600838:	ba 60 00 00 00       	mov    $0x60,%edx
  804160083d:	ec                   	in     (%dx),%al
  804160083e:	89 c2                	mov    %eax,%edx
  8041600840:	89 c1                	mov    %eax,%ecx
    if (data == 0xE0) {
  8041600842:	3c e0                	cmp    $0xe0,%al
  8041600844:	0f 84 83 00 00 00    	je     80416008cd <kbd_proc_data+0xb0>
    } else if (data & 0x80) {
  804160084a:	84 c0                	test   %al,%al
  804160084c:	0f 88 95 00 00 00    	js     80416008e7 <kbd_proc_data+0xca>
    } else if (shift & E0ESC) {
  8041600852:	a1 20 00 80 41 80 00 	movabs 0x8041800020,%eax
  8041600859:	00 00 
  804160085b:	a8 40                	test   $0x40,%al
  804160085d:	74 0f                	je     804160086e <kbd_proc_data+0x51>
        data |= 0x80;
  804160085f:	83 c9 80             	or     $0xffffff80,%ecx
        shift &= ~E0ESC;
  8041600862:	83 e0 bf             	and    $0xffffffbf,%eax
  8041600865:	a3 20 00 80 41 80 00 	movabs %eax,0x8041800020
  804160086c:	00 00 
    shift |= shiftcode[data];
  804160086e:	0f b6 f1             	movzbl %cl,%esi
  8041600871:	48 b8 40 a3 60 41 80 	movabs $0x804160a340,%rax
  8041600878:	00 00 00 
  804160087b:	0f b6 04 30          	movzbl (%rax,%rsi,1),%eax
  804160087f:	48 ba 20 00 80 41 80 	movabs $0x8041800020,%rdx
  8041600886:	00 00 00 
  8041600889:	0b 02                	or     (%rdx),%eax
    shift ^= togglecode[data];
  804160088b:	48 bf 40 a2 60 41 80 	movabs $0x804160a240,%rdi
  8041600892:	00 00 00 
  8041600895:	0f b6 34 37          	movzbl (%rdi,%rsi,1),%esi
  8041600899:	31 f0                	xor    %esi,%eax
  804160089b:	89 02                	mov    %eax,(%rdx)
    c = charcode[shift & (CTL | SHIFT)][data];
  804160089d:	89 c6                	mov    %eax,%esi
  804160089f:	83 e6 03             	and    $0x3,%esi
  80416008a2:	0f b6 c9             	movzbl %cl,%ecx
  80416008a5:	48 ba 20 a2 60 41 80 	movabs $0x804160a220,%rdx
  80416008ac:	00 00 00 
  80416008af:	48 8b 14 f2          	mov    (%rdx,%rsi,8),%rdx
  80416008b3:	0f b6 14 0a          	movzbl (%rdx,%rcx,1),%edx
  80416008b7:	0f b6 da             	movzbl %dl,%ebx
    if (shift & CAPSLOCK) {
  80416008ba:	a8 08                	test   $0x8,%al
  80416008bc:	74 71                	je     804160092f <kbd_proc_data+0x112>
        if ('a' <= c && c <= 'z')
  80416008be:	89 da                	mov    %ebx,%edx
  80416008c0:	8d 4b 9f             	lea    -0x61(%rbx),%ecx
  80416008c3:	83 f9 19             	cmp    $0x19,%ecx
  80416008c6:	77 5b                	ja     8041600923 <kbd_proc_data+0x106>
            c += 'A' - 'a';
  80416008c8:	83 eb 20             	sub    $0x20,%ebx
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  80416008cb:	eb 12                	jmp    80416008df <kbd_proc_data+0xc2>
        shift |= E0ESC;
  80416008cd:	48 b8 20 00 80 41 80 	movabs $0x8041800020,%rax
  80416008d4:	00 00 00 
  80416008d7:	83 08 40             	orl    $0x40,(%rax)
        return 0;
  80416008da:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  80416008df:	89 d8                	mov    %ebx,%eax
  80416008e1:	48 8b 5d f8          	mov    -0x8(%rbp),%rbx
  80416008e5:	c9                   	leave  
  80416008e6:	c3                   	ret    
        data = (shift & E0ESC ? data : data & 0x7F);
  80416008e7:	a1 20 00 80 41 80 00 	movabs 0x8041800020,%eax
  80416008ee:	00 00 
  80416008f0:	83 e2 7f             	and    $0x7f,%edx
  80416008f3:	a8 40                	test   $0x40,%al
  80416008f5:	0f 44 ca             	cmove  %edx,%ecx
        shift &= ~(shiftcode[data] | E0ESC);
  80416008f8:	0f b6 c9             	movzbl %cl,%ecx
  80416008fb:	48 ba 40 a3 60 41 80 	movabs $0x804160a340,%rdx
  8041600902:	00 00 00 
  8041600905:	0f b6 14 0a          	movzbl (%rdx,%rcx,1),%edx
  8041600909:	83 ca 40             	or     $0x40,%edx
  804160090c:	0f b6 d2             	movzbl %dl,%edx
  804160090f:	f7 d2                	not    %edx
  8041600911:	21 d0                	and    %edx,%eax
  8041600913:	a3 20 00 80 41 80 00 	movabs %eax,0x8041800020
  804160091a:	00 00 
        return 0;
  804160091c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041600921:	eb bc                	jmp    80416008df <kbd_proc_data+0xc2>
        else if ('A' <= c && c <= 'Z')
  8041600923:	83 ea 41             	sub    $0x41,%edx
            c += 'a' - 'A';
  8041600926:	8d 4b 20             	lea    0x20(%rbx),%ecx
  8041600929:	83 fa 1a             	cmp    $0x1a,%edx
  804160092c:	0f 42 d9             	cmovb  %ecx,%ebx
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  804160092f:	f7 d0                	not    %eax
  8041600931:	a8 06                	test   $0x6,%al
  8041600933:	75 aa                	jne    80416008df <kbd_proc_data+0xc2>
  8041600935:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
  804160093b:	75 a2                	jne    80416008df <kbd_proc_data+0xc2>
        cprintf("Rebooting!\n");
  804160093d:	48 bf e6 a1 60 41 80 	movabs $0x804160a1e6,%rdi
  8041600944:	00 00 00 
  8041600947:	b8 00 00 00 00       	mov    $0x0,%eax
  804160094c:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  8041600953:	00 00 00 
  8041600956:	ff d2                	call   *%rdx
                 : "memory", "cc");
}

static inline void __attribute__((always_inline))
outb(int port, uint8_t data) {
    asm volatile("outb %0,%w1" ::"a"(data), "d"(port));
  8041600958:	b8 03 00 00 00       	mov    $0x3,%eax
  804160095d:	ba 92 00 00 00       	mov    $0x92,%edx
  8041600962:	ee                   	out    %al,(%dx)
}
  8041600963:	e9 77 ff ff ff       	jmp    80416008df <kbd_proc_data+0xc2>
    if (!(inb(KBSTATP) & KBS_DIB)) return -1;
  8041600968:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  804160096d:	e9 6d ff ff ff       	jmp    80416008df <kbd_proc_data+0xc2>

0000008041600972 <draw_char>:
draw_char(uint32_t *buffer, uint32_t x, uint32_t y, uint32_t color, uint8_t charcode) {
  8041600972:	f3 0f 1e fa          	endbr64 
  8041600976:	49 89 f9             	mov    %rdi,%r9
  8041600979:	41 89 d2             	mov    %edx,%r10d
  804160097c:	89 cf                	mov    %ecx,%edi
    uint32_t *buf = buffer + uefi_stride * SYMBOL_SIZE * y + SYMBOL_SIZE * x;
  804160097e:	a1 54 02 80 41 80 00 	movabs 0x8041800254,%eax
  8041600985:	00 00 
    char *chr = font8x8_basic[(unsigned)charcode];
  8041600987:	45 0f b6 c0          	movzbl %r8b,%r8d
  804160098b:	48 ba 20 d3 62 41 80 	movabs $0x804162d320,%rdx
  8041600992:	00 00 00 
  8041600995:	4a 8d 14 c2          	lea    (%rdx,%r8,8),%rdx
  8041600999:	41 89 c0             	mov    %eax,%r8d
  804160099c:	49 c1 e0 02          	shl    $0x2,%r8
    uint32_t *buf = buffer + uefi_stride * SYMBOL_SIZE * y + SYMBOL_SIZE * x;
  80416009a0:	41 0f af c2          	imul   %r10d,%eax
  80416009a4:	c1 e0 03             	shl    $0x3,%eax
  80416009a7:	89 c0                	mov    %eax,%eax
  80416009a9:	8d 0c f5 00 00 00 00 	lea    0x0(,%rsi,8),%ecx
  80416009b0:	89 c9                	mov    %ecx,%ecx
  80416009b2:	48 01 c8             	add    %rcx,%rax
  80416009b5:	49 8d 34 81          	lea    (%r9,%rax,4),%rsi
  80416009b9:	4c 8d 4a 08          	lea    0x8(%rdx),%r9
        for (size_t width = 0; width < 8; width++) {
  80416009bd:	b9 00 00 00 00       	mov    $0x0,%ecx
            buf[uefi_stride * heigth + width] = color * ((chr[heigth] >> width) & 1);
  80416009c2:	0f be 02             	movsbl (%rdx),%eax
  80416009c5:	d3 f8                	sar    %cl,%eax
  80416009c7:	83 e0 01             	and    $0x1,%eax
  80416009ca:	0f af c7             	imul   %edi,%eax
  80416009cd:	89 04 8e             	mov    %eax,(%rsi,%rcx,4)
        for (size_t width = 0; width < 8; width++) {
  80416009d0:	48 83 c1 01          	add    $0x1,%rcx
  80416009d4:	48 83 f9 08          	cmp    $0x8,%rcx
  80416009d8:	75 e8                	jne    80416009c2 <draw_char+0x50>
    for (size_t heigth = 0; heigth < 8; heigth++) {
  80416009da:	48 83 c2 01          	add    $0x1,%rdx
  80416009de:	4c 01 c6             	add    %r8,%rsi
  80416009e1:	4c 39 ca             	cmp    %r9,%rdx
  80416009e4:	75 d7                	jne    80416009bd <draw_char+0x4b>
}
  80416009e6:	c3                   	ret    

00000080416009e7 <fb_putc>:
fb_putc(int c) {
  80416009e7:	f3 0f 1e fa          	endbr64 
    if (!graphics_exists) return;
  80416009eb:	48 b8 5c 02 80 41 80 	movabs $0x804180025c,%rax
  80416009f2:	00 00 00 
  80416009f5:	80 38 00             	cmpb   $0x0,(%rax)
  80416009f8:	0f 84 32 02 00 00    	je     8041600c30 <fb_putc+0x249>
fb_putc(int c) {
  80416009fe:	55                   	push   %rbp
  80416009ff:	48 89 e5             	mov    %rsp,%rbp
  8041600a02:	41 55                	push   %r13
  8041600a04:	41 54                	push   %r12
  8041600a06:	53                   	push   %rbx
  8041600a07:	48 83 ec 08          	sub    $0x8,%rsp
    if (!(c & ~0xFF)) c |= 0x0700;
  8041600a0b:	89 f8                	mov    %edi,%eax
  8041600a0d:	80 cc 07             	or     $0x7,%ah
  8041600a10:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
  8041600a16:	0f 44 f8             	cmove  %eax,%edi
    switch (c & 0xFF) {
  8041600a19:	44 0f b6 c7          	movzbl %dil,%r8d
  8041600a1d:	40 80 ff 0a          	cmp    $0xa,%dil
  8041600a21:	0f 84 01 01 00 00    	je     8041600b28 <fb_putc+0x141>
  8041600a27:	41 83 f8 0a          	cmp    $0xa,%r8d
  8041600a2b:	7f 43                	jg     8041600a70 <fb_putc+0x89>
  8041600a2d:	41 83 f8 08          	cmp    $0x8,%r8d
  8041600a31:	0f 84 93 00 00 00    	je     8041600aca <fb_putc+0xe3>
  8041600a37:	41 83 f8 09          	cmp    $0x9,%r8d
  8041600a3b:	0f 85 02 01 00 00    	jne    8041600b43 <fb_putc+0x15c>
            fb_putc(' ');
  8041600a41:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a46:	48 bb e7 09 60 41 80 	movabs $0x80416009e7,%rbx
  8041600a4d:	00 00 00 
  8041600a50:	ff d3                	call   *%rbx
  8041600a52:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a57:	ff d3                	call   *%rbx
  8041600a59:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a5e:	ff d3                	call   *%rbx
  8041600a60:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a65:	ff d3                	call   *%rbx
  8041600a67:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a6c:	ff d3                	call   *%rbx
        for (size_t i = 0; i < TABW; i++)
  8041600a6e:	eb 30                	jmp    8041600aa0 <fb_putc+0xb9>
    switch (c & 0xFF) {
  8041600a70:	41 83 f8 0d          	cmp    $0xd,%r8d
  8041600a74:	0f 85 c9 00 00 00    	jne    8041600b43 <fb_putc+0x15c>
        crt_pos -= (crt_pos % crt_cols);
  8041600a7a:	48 be 4a 02 80 41 80 	movabs $0x804180024a,%rsi
  8041600a81:	00 00 00 
  8041600a84:	0f b7 0e             	movzwl (%rsi),%ecx
  8041600a87:	0f b7 c1             	movzwl %cx,%eax
  8041600a8a:	48 bb 50 02 80 41 80 	movabs $0x8041800250,%rbx
  8041600a91:	00 00 00 
  8041600a94:	ba 00 00 00 00       	mov    $0x0,%edx
  8041600a99:	f7 33                	divl   (%rbx)
  8041600a9b:	29 d1                	sub    %edx,%ecx
  8041600a9d:	66 89 0e             	mov    %cx,(%rsi)
    if (crt_pos >= crt_size) {
  8041600aa0:	48 b8 4a 02 80 41 80 	movabs $0x804180024a,%rax
  8041600aa7:	00 00 00 
  8041600aaa:	0f b7 10             	movzwl (%rax),%edx
  8041600aad:	48 b8 4c 02 80 41 80 	movabs $0x804180024c,%rax
  8041600ab4:	00 00 00 
  8041600ab7:	3b 10                	cmp    (%rax),%edx
  8041600ab9:	0f 83 d7 00 00 00    	jae    8041600b96 <fb_putc+0x1af>
}
  8041600abf:	48 83 c4 08          	add    $0x8,%rsp
  8041600ac3:	5b                   	pop    %rbx
  8041600ac4:	41 5c                	pop    %r12
  8041600ac6:	41 5d                	pop    %r13
  8041600ac8:	5d                   	pop    %rbp
  8041600ac9:	c3                   	ret    
        if (crt_pos > 0) {
  8041600aca:	66 a1 4a 02 80 41 80 	movabs 0x804180024a,%ax
  8041600ad1:	00 00 00 
  8041600ad4:	66 85 c0             	test   %ax,%ax
  8041600ad7:	74 c7                	je     8041600aa0 <fb_putc+0xb9>
            crt_pos--;
  8041600ad9:	83 e8 01             	sub    $0x1,%eax
  8041600adc:	66 a3 4a 02 80 41 80 	movabs %ax,0x804180024a
  8041600ae3:	00 00 00 
            draw_char(crt_buf, crt_pos % crt_cols, crt_pos / crt_cols, 0x0, 0x8);
  8041600ae6:	0f b7 d0             	movzwl %ax,%edx
  8041600ae9:	48 b8 50 02 80 41 80 	movabs $0x8041800250,%rax
  8041600af0:	00 00 00 
  8041600af3:	8b 08                	mov    (%rax),%ecx
  8041600af5:	89 d0                	mov    %edx,%eax
  8041600af7:	ba 00 00 00 00       	mov    $0x0,%edx
  8041600afc:	f7 f1                	div    %ecx
  8041600afe:	89 d6                	mov    %edx,%esi
  8041600b00:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041600b06:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041600b0b:	89 c2                	mov    %eax,%edx
  8041600b0d:	48 bf 00 00 e0 1f 80 	movabs $0x801fe00000,%rdi
  8041600b14:	00 00 00 
  8041600b17:	48 b8 72 09 60 41 80 	movabs $0x8041600972,%rax
  8041600b1e:	00 00 00 
  8041600b21:	ff d0                	call   *%rax
  8041600b23:	e9 78 ff ff ff       	jmp    8041600aa0 <fb_putc+0xb9>
        crt_pos += crt_cols;
  8041600b28:	48 ba 4a 02 80 41 80 	movabs $0x804180024a,%rdx
  8041600b2f:	00 00 00 
  8041600b32:	a1 50 02 80 41 80 00 	movabs 0x8041800250,%eax
  8041600b39:	00 00 
  8041600b3b:	66 01 02             	add    %ax,(%rdx)
  8041600b3e:	e9 37 ff ff ff       	jmp    8041600a7a <fb_putc+0x93>
        draw_char(crt_buf, crt_pos % crt_cols, crt_pos / crt_cols, 0xFFFFFFFF, (uint8_t)c);
  8041600b43:	49 bc 4a 02 80 41 80 	movabs $0x804180024a,%r12
  8041600b4a:	00 00 00 
  8041600b4d:	41 0f b7 1c 24       	movzwl (%r12),%ebx
  8041600b52:	0f b7 d3             	movzwl %bx,%edx
  8041600b55:	48 b8 50 02 80 41 80 	movabs $0x8041800250,%rax
  8041600b5c:	00 00 00 
  8041600b5f:	8b 08                	mov    (%rax),%ecx
  8041600b61:	89 d0                	mov    %edx,%eax
  8041600b63:	ba 00 00 00 00       	mov    $0x0,%edx
  8041600b68:	f7 f1                	div    %ecx
  8041600b6a:	89 d6                	mov    %edx,%esi
  8041600b6c:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  8041600b71:	89 c2                	mov    %eax,%edx
  8041600b73:	48 bf 00 00 e0 1f 80 	movabs $0x801fe00000,%rdi
  8041600b7a:	00 00 00 
  8041600b7d:	48 b8 72 09 60 41 80 	movabs $0x8041600972,%rax
  8041600b84:	00 00 00 
  8041600b87:	ff d0                	call   *%rax
        crt_pos++;
  8041600b89:	83 c3 01             	add    $0x1,%ebx
  8041600b8c:	66 41 89 1c 24       	mov    %bx,(%r12)
  8041600b91:	e9 0a ff ff ff       	jmp    8041600aa0 <fb_putc+0xb9>
                      uefi_stride * (uefi_vres - SYMBOL_SIZE) * sizeof(uint32_t));
  8041600b96:	49 bc 54 02 80 41 80 	movabs $0x8041800254,%r12
  8041600b9d:	00 00 00 
  8041600ba0:	41 8b 04 24          	mov    (%r12),%eax
  8041600ba4:	49 bd 58 02 80 41 80 	movabs $0x8041800258,%r13
  8041600bab:	00 00 00 
  8041600bae:	41 8b 75 00          	mov    0x0(%r13),%esi
  8041600bb2:	8d 56 f8             	lea    -0x8(%rsi),%edx
  8041600bb5:	0f af d0             	imul   %eax,%edx
        nosan_memmove(crt_buf, crt_buf + uefi_stride * SYMBOL_SIZE,
  8041600bb8:	48 c1 e2 02          	shl    $0x2,%rdx
  8041600bbc:	c1 e0 03             	shl    $0x3,%eax
  8041600bbf:	89 c0                	mov    %eax,%eax
  8041600bc1:	48 bb 00 00 e0 1f 80 	movabs $0x801fe00000,%rbx
  8041600bc8:	00 00 00 
  8041600bcb:	48 8d 34 83          	lea    (%rbx,%rax,4),%rsi
  8041600bcf:	48 89 df             	mov    %rbx,%rdi
  8041600bd2:	48 b8 0c 94 60 41 80 	movabs $0x804160940c,%rax
  8041600bd9:	00 00 00 
  8041600bdc:	ff d0                	call   *%rax
        size_t i = (uefi_vres - (uefi_vres % SYMBOL_SIZE) - SYMBOL_SIZE);
  8041600bde:	41 8b 45 00          	mov    0x0(%r13),%eax
  8041600be2:	89 c1                	mov    %eax,%ecx
  8041600be4:	83 e1 f8             	and    $0xfffffff8,%ecx
  8041600be7:	83 e9 08             	sub    $0x8,%ecx
  8041600bea:	89 c9                	mov    %ecx,%ecx
        nosan_memset(crt_buf + i * uefi_stride, 0, uefi_stride * (uefi_vres - i) * sizeof(uint32_t));
  8041600bec:	41 8b 3c 24          	mov    (%r12),%edi
  8041600bf0:	48 c1 e7 02          	shl    $0x2,%rdi
  8041600bf4:	89 c2                	mov    %eax,%edx
  8041600bf6:	48 29 ca             	sub    %rcx,%rdx
  8041600bf9:	48 0f af d7          	imul   %rdi,%rdx
  8041600bfd:	48 0f af f9          	imul   %rcx,%rdi
  8041600c01:	48 01 df             	add    %rbx,%rdi
  8041600c04:	be 00 00 00 00       	mov    $0x0,%esi
  8041600c09:	48 b8 5e 93 60 41 80 	movabs $0x804160935e,%rax
  8041600c10:	00 00 00 
  8041600c13:	ff d0                	call   *%rax
        crt_pos -= crt_cols;
  8041600c15:	48 ba 4a 02 80 41 80 	movabs $0x804180024a,%rdx
  8041600c1c:	00 00 00 
  8041600c1f:	a1 50 02 80 41 80 00 	movabs 0x8041800250,%eax
  8041600c26:	00 00 
  8041600c28:	66 29 02             	sub    %ax,(%rdx)
  8041600c2b:	e9 8f fe ff ff       	jmp    8041600abf <fb_putc+0xd8>
  8041600c30:	c3                   	ret    

0000008041600c31 <fb_init>:
fb_init(void) {
  8041600c31:	f3 0f 1e fa          	endbr64 
  8041600c35:	55                   	push   %rbp
  8041600c36:	48 89 e5             	mov    %rsp,%rbp
    LOADER_PARAMS *lp = (LOADER_PARAMS *)uefi_lp;
  8041600c39:	48 b8 00 d0 62 41 80 	movabs $0x804162d000,%rax
  8041600c40:	00 00 00 
  8041600c43:	48 8b 30             	mov    (%rax),%rsi
    uefi_vres = lp->VerticalResolution;
  8041600c46:	8b 56 50             	mov    0x50(%rsi),%edx
  8041600c49:	89 d0                	mov    %edx,%eax
  8041600c4b:	a3 58 02 80 41 80 00 	movabs %eax,0x8041800258
  8041600c52:	00 00 
    uefi_stride = lp->PixelsPerScanLine;
  8041600c54:	8b 46 4c             	mov    0x4c(%rsi),%eax
  8041600c57:	a3 54 02 80 41 80 00 	movabs %eax,0x8041800254
  8041600c5e:	00 00 
    crt_cols = uefi_hres / SYMBOL_SIZE;
  8041600c60:	8b 4e 54             	mov    0x54(%rsi),%ecx
  8041600c63:	c1 e9 03             	shr    $0x3,%ecx
  8041600c66:	89 c8                	mov    %ecx,%eax
  8041600c68:	a3 50 02 80 41 80 00 	movabs %eax,0x8041800250
  8041600c6f:	00 00 
    crt_rows = uefi_vres / SYMBOL_SIZE;
  8041600c71:	89 d0                	mov    %edx,%eax
  8041600c73:	c1 e8 03             	shr    $0x3,%eax
    crt_size = crt_rows * crt_cols;
  8041600c76:	0f af c1             	imul   %ecx,%eax
  8041600c79:	a3 4c 02 80 41 80 00 	movabs %eax,0x804180024c
  8041600c80:	00 00 
    crt_pos = crt_cols;
  8041600c82:	89 c8                	mov    %ecx,%eax
  8041600c84:	66 a3 4a 02 80 41 80 	movabs %ax,0x804180024a
  8041600c8b:	00 00 00 
    memset(crt_buf, 0, lp->FrameBufferSize);
  8041600c8e:	8b 56 48             	mov    0x48(%rsi),%edx
  8041600c91:	be 00 00 00 00       	mov    $0x0,%esi
  8041600c96:	48 bf 00 00 e0 1f 80 	movabs $0x801fe00000,%rdi
  8041600c9d:	00 00 00 
  8041600ca0:	48 b8 5e 93 60 41 80 	movabs $0x804160935e,%rax
  8041600ca7:	00 00 00 
  8041600caa:	ff d0                	call   *%rax
    graphics_exists = true;
  8041600cac:	48 b8 5c 02 80 41 80 	movabs $0x804180025c,%rax
  8041600cb3:	00 00 00 
  8041600cb6:	c6 00 01             	movb   $0x1,(%rax)
}
  8041600cb9:	5d                   	pop    %rbp
  8041600cba:	c3                   	ret    

0000008041600cbb <serial_intr>:
serial_intr(void) {
  8041600cbb:	f3 0f 1e fa          	endbr64 
    if (serial_exists) cons_intr(serial_proc_data);
  8041600cbf:	48 b8 48 02 80 41 80 	movabs $0x8041800248,%rax
  8041600cc6:	00 00 00 
  8041600cc9:	80 38 00             	cmpb   $0x0,(%rax)
  8041600ccc:	75 01                	jne    8041600ccf <serial_intr+0x14>
  8041600cce:	c3                   	ret    
serial_intr(void) {
  8041600ccf:	55                   	push   %rbp
  8041600cd0:	48 89 e5             	mov    %rsp,%rbp
    if (serial_exists) cons_intr(serial_proc_data);
  8041600cd3:	48 bf b0 07 60 41 80 	movabs $0x80416007b0,%rdi
  8041600cda:	00 00 00 
  8041600cdd:	48 b8 ce 07 60 41 80 	movabs $0x80416007ce,%rax
  8041600ce4:	00 00 00 
  8041600ce7:	ff d0                	call   *%rax
}
  8041600ce9:	5d                   	pop    %rbp
  8041600cea:	c3                   	ret    

0000008041600ceb <kbd_intr>:
kbd_intr(void) {
  8041600ceb:	f3 0f 1e fa          	endbr64 
  8041600cef:	55                   	push   %rbp
  8041600cf0:	48 89 e5             	mov    %rsp,%rbp
    cons_intr(kbd_proc_data);
  8041600cf3:	48 bf 1d 08 60 41 80 	movabs $0x804160081d,%rdi
  8041600cfa:	00 00 00 
  8041600cfd:	48 b8 ce 07 60 41 80 	movabs $0x80416007ce,%rax
  8041600d04:	00 00 00 
  8041600d07:	ff d0                	call   *%rax
}
  8041600d09:	5d                   	pop    %rbp
  8041600d0a:	c3                   	ret    

0000008041600d0b <cons_getc>:

/* Return the next input character from the console, or 0 if none waiting */
int
cons_getc(void) {
  8041600d0b:	f3 0f 1e fa          	endbr64 
  8041600d0f:	55                   	push   %rbp
  8041600d10:	48 89 e5             	mov    %rsp,%rbp

    /* Poll for any pending input characters,
     * so that this function works even when interrupts are disabled
     * (e.g., when called from the kernel monitor) */
    serial_intr();
  8041600d13:	48 b8 bb 0c 60 41 80 	movabs $0x8041600cbb,%rax
  8041600d1a:	00 00 00 
  8041600d1d:	ff d0                	call   *%rax
    kbd_intr();
  8041600d1f:	48 b8 eb 0c 60 41 80 	movabs $0x8041600ceb,%rax
  8041600d26:	00 00 00 
  8041600d29:	ff d0                	call   *%rax

    /* Grab the next character from the input buffer */
    if (cons.rpos != cons.wpos) {
  8041600d2b:	48 ba 40 00 80 41 80 	movabs $0x8041800040,%rdx
  8041600d32:	00 00 00 
  8041600d35:	8b 82 00 02 00 00    	mov    0x200(%rdx),%eax
        uint8_t ch = cons.buf[cons.rpos++];
        cons.rpos %= CONSBUFSIZE;
        return ch;
    }
    return 0;
  8041600d3b:	b9 00 00 00 00       	mov    $0x0,%ecx
    if (cons.rpos != cons.wpos) {
  8041600d40:	3b 82 04 02 00 00    	cmp    0x204(%rdx),%eax
  8041600d46:	74 14                	je     8041600d5c <cons_getc+0x51>
        uint8_t ch = cons.buf[cons.rpos++];
  8041600d48:	89 c1                	mov    %eax,%ecx
  8041600d4a:	83 c0 01             	add    $0x1,%eax
        cons.rpos %= CONSBUFSIZE;
  8041600d4d:	25 ff 01 00 00       	and    $0x1ff,%eax
  8041600d52:	89 82 00 02 00 00    	mov    %eax,0x200(%rdx)
        return ch;
  8041600d58:	0f b6 0c 0a          	movzbl (%rdx,%rcx,1),%ecx
}
  8041600d5c:	89 c8                	mov    %ecx,%eax
  8041600d5e:	5d                   	pop    %rbp
  8041600d5f:	c3                   	ret    

0000008041600d60 <cons_init>:
    fb_putc(c);
}

/* Initialize the console devices */
void
cons_init(void) {
  8041600d60:	f3 0f 1e fa          	endbr64 
    asm volatile("outb %0,%w1" ::"a"(data), "d"(port));
  8041600d64:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041600d69:	bf fa 03 00 00       	mov    $0x3fa,%edi
  8041600d6e:	89 c8                	mov    %ecx,%eax
  8041600d70:	89 fa                	mov    %edi,%edx
  8041600d72:	ee                   	out    %al,(%dx)
  8041600d73:	41 b9 fb 03 00 00    	mov    $0x3fb,%r9d
  8041600d79:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
  8041600d7e:	44 89 ca             	mov    %r9d,%edx
  8041600d81:	ee                   	out    %al,(%dx)
  8041600d82:	be f8 03 00 00       	mov    $0x3f8,%esi
  8041600d87:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041600d8c:	89 f2                	mov    %esi,%edx
  8041600d8e:	ee                   	out    %al,(%dx)
  8041600d8f:	41 b8 f9 03 00 00    	mov    $0x3f9,%r8d
  8041600d95:	89 c8                	mov    %ecx,%eax
  8041600d97:	44 89 c2             	mov    %r8d,%edx
  8041600d9a:	ee                   	out    %al,(%dx)
  8041600d9b:	b8 03 00 00 00       	mov    $0x3,%eax
  8041600da0:	44 89 ca             	mov    %r9d,%edx
  8041600da3:	ee                   	out    %al,(%dx)
  8041600da4:	ba fc 03 00 00       	mov    $0x3fc,%edx
  8041600da9:	89 c8                	mov    %ecx,%eax
  8041600dab:	ee                   	out    %al,(%dx)
  8041600dac:	b8 01 00 00 00       	mov    $0x1,%eax
  8041600db1:	44 89 c2             	mov    %r8d,%edx
  8041600db4:	ee                   	out    %al,(%dx)
    asm volatile("inb %w1,%0"
  8041600db5:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600dba:	ec                   	in     (%dx),%al
  8041600dbb:	89 c1                	mov    %eax,%ecx
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  8041600dbd:	3c ff                	cmp    $0xff,%al
  8041600dbf:	0f 95 c0             	setne  %al
  8041600dc2:	a2 48 02 80 41 80 00 	movabs %al,0x8041800248
  8041600dc9:	00 00 
  8041600dcb:	89 fa                	mov    %edi,%edx
  8041600dcd:	ec                   	in     (%dx),%al
  8041600dce:	89 f2                	mov    %esi,%edx
  8041600dd0:	ec                   	in     (%dx),%al
    kbd_init();
    serial_init();

    if (!serial_exists)
  8041600dd1:	80 f9 ff             	cmp    $0xff,%cl
  8041600dd4:	74 01                	je     8041600dd7 <cons_init+0x77>
  8041600dd6:	c3                   	ret    
cons_init(void) {
  8041600dd7:	55                   	push   %rbp
  8041600dd8:	48 89 e5             	mov    %rsp,%rbp
        cprintf("Serial port does not exist!\n");
  8041600ddb:	48 bf f2 a1 60 41 80 	movabs $0x804160a1f2,%rdi
  8041600de2:	00 00 00 
  8041600de5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600dea:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  8041600df1:	00 00 00 
  8041600df4:	ff d2                	call   *%rdx
}
  8041600df6:	5d                   	pop    %rbp
  8041600df7:	c3                   	ret    

0000008041600df8 <cputchar>:

/* `High'-level console I/O.  Used by readline and cprintf. */

void
cputchar(int c) {
  8041600df8:	f3 0f 1e fa          	endbr64 
  8041600dfc:	55                   	push   %rbp
  8041600dfd:	48 89 e5             	mov    %rsp,%rbp
    c &= 0x7F;
  8041600e00:	83 e7 7f             	and    $0x7f,%edi
  8041600e03:	41 89 f8             	mov    %edi,%r8d
  8041600e06:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600e0b:	ec                   	in     (%dx),%al
        if (inb(COM1 + COM_LSR) & COM_LSR_TXRDY) break;
  8041600e0c:	a8 20                	test   $0x20,%al
  8041600e0e:	75 22                	jne    8041600e32 <cputchar+0x3a>
  8041600e10:	be 00 32 00 00       	mov    $0x3200,%esi
  8041600e15:	b9 84 00 00 00       	mov    $0x84,%ecx
  8041600e1a:	bf fd 03 00 00       	mov    $0x3fd,%edi
  8041600e1f:	89 ca                	mov    %ecx,%edx
  8041600e21:	ec                   	in     (%dx),%al
  8041600e22:	ec                   	in     (%dx),%al
  8041600e23:	ec                   	in     (%dx),%al
  8041600e24:	ec                   	in     (%dx),%al
    for (size_t i = 0; i < 12800; i++) {
  8041600e25:	48 83 ee 01          	sub    $0x1,%rsi
  8041600e29:	74 07                	je     8041600e32 <cputchar+0x3a>
  8041600e2b:	89 fa                	mov    %edi,%edx
  8041600e2d:	ec                   	in     (%dx),%al
        if (inb(COM1 + COM_LSR) & COM_LSR_TXRDY) break;
  8041600e2e:	a8 20                	test   $0x20,%al
  8041600e30:	74 ed                	je     8041600e1f <cputchar+0x27>
    outb(COM1 + COM_TX, c);
  8041600e32:	45 89 c1             	mov    %r8d,%r9d
    asm volatile("outb %0,%w1" ::"a"(data), "d"(port));
  8041600e35:	ba f8 03 00 00       	mov    $0x3f8,%edx
  8041600e3a:	44 89 c0             	mov    %r8d,%eax
  8041600e3d:	ee                   	out    %al,(%dx)
    asm volatile("inb %w1,%0"
  8041600e3e:	ba 79 03 00 00       	mov    $0x379,%edx
  8041600e43:	ec                   	in     (%dx),%al
        if (inb(0x378 + 1) & 0x80) break;
  8041600e44:	84 c0                	test   %al,%al
  8041600e46:	78 22                	js     8041600e6a <cputchar+0x72>
  8041600e48:	be 00 32 00 00       	mov    $0x3200,%esi
  8041600e4d:	b9 84 00 00 00       	mov    $0x84,%ecx
  8041600e52:	bf 79 03 00 00       	mov    $0x379,%edi
  8041600e57:	89 ca                	mov    %ecx,%edx
  8041600e59:	ec                   	in     (%dx),%al
  8041600e5a:	ec                   	in     (%dx),%al
  8041600e5b:	ec                   	in     (%dx),%al
  8041600e5c:	ec                   	in     (%dx),%al
    for (size_t i = 0; i < 12800; i++) {
  8041600e5d:	48 83 ee 01          	sub    $0x1,%rsi
  8041600e61:	74 07                	je     8041600e6a <cputchar+0x72>
  8041600e63:	89 fa                	mov    %edi,%edx
  8041600e65:	ec                   	in     (%dx),%al
        if (inb(0x378 + 1) & 0x80) break;
  8041600e66:	84 c0                	test   %al,%al
  8041600e68:	79 ed                	jns    8041600e57 <cputchar+0x5f>
    asm volatile("outb %0,%w1" ::"a"(data), "d"(port));
  8041600e6a:	ba 78 03 00 00       	mov    $0x378,%edx
  8041600e6f:	44 89 c8             	mov    %r9d,%eax
  8041600e72:	ee                   	out    %al,(%dx)
  8041600e73:	ba 7a 03 00 00       	mov    $0x37a,%edx
  8041600e78:	b8 0d 00 00 00       	mov    $0xd,%eax
  8041600e7d:	ee                   	out    %al,(%dx)
  8041600e7e:	b8 08 00 00 00       	mov    $0x8,%eax
  8041600e83:	ee                   	out    %al,(%dx)
    fb_putc(c);
  8041600e84:	44 89 c7             	mov    %r8d,%edi
  8041600e87:	48 b8 e7 09 60 41 80 	movabs $0x80416009e7,%rax
  8041600e8e:	00 00 00 
  8041600e91:	ff d0                	call   *%rax
    cons_putc(c);
}
  8041600e93:	5d                   	pop    %rbp
  8041600e94:	c3                   	ret    

0000008041600e95 <getchar>:

int
getchar(void) {
  8041600e95:	f3 0f 1e fa          	endbr64 
  8041600e99:	55                   	push   %rbp
  8041600e9a:	48 89 e5             	mov    %rsp,%rbp
  8041600e9d:	53                   	push   %rbx
  8041600e9e:	48 83 ec 08          	sub    $0x8,%rsp
    int ch;

    while (!(ch = cons_getc()))
  8041600ea2:	48 bb 0b 0d 60 41 80 	movabs $0x8041600d0b,%rbx
  8041600ea9:	00 00 00 
  8041600eac:	ff d3                	call   *%rbx
  8041600eae:	85 c0                	test   %eax,%eax
  8041600eb0:	74 fa                	je     8041600eac <getchar+0x17>
        /* nothing */;

    return ch;
}
  8041600eb2:	48 8b 5d f8          	mov    -0x8(%rbp),%rbx
  8041600eb6:	c9                   	leave  
  8041600eb7:	c3                   	ret    

0000008041600eb8 <iscons>:

int
iscons(int fdnum) {
  8041600eb8:	f3 0f 1e fa          	endbr64 
    /* Used by readline */

    return 1;
}
  8041600ebc:	b8 01 00 00 00       	mov    $0x1,%eax
  8041600ec1:	c3                   	ret    

0000008041600ec2 <dwarf_read_abbrev_entry>:
    return -E_BAD_DWARF;
}

/* Read value from .debug_abbrev table in buf. Returns number of bytes read */
static int
dwarf_read_abbrev_entry(const void *entry, unsigned form, void *buf, int bufsize, size_t address_size) {
  8041600ec2:	f3 0f 1e fa          	endbr64 
  8041600ec6:	55                   	push   %rbp
  8041600ec7:	48 89 e5             	mov    %rsp,%rbp
  8041600eca:	41 56                	push   %r14
  8041600ecc:	41 55                	push   %r13
  8041600ece:	41 54                	push   %r12
  8041600ed0:	53                   	push   %rbx
  8041600ed1:	48 83 ec 30          	sub    $0x30,%rsp
  8041600ed5:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
    int bytes = 0;
    switch (form) {
  8041600ed9:	83 fe 20             	cmp    $0x20,%esi
  8041600edc:	0f 87 5d 0a 00 00    	ja     804160193f <dwarf_read_abbrev_entry+0xa7d>
  8041600ee2:	49 89 d4             	mov    %rdx,%r12
  8041600ee5:	41 89 cd             	mov    %ecx,%r13d
  8041600ee8:	4c 89 c3             	mov    %r8,%rbx
  8041600eeb:	89 f6                	mov    %esi,%esi
  8041600eed:	48 b8 c0 a4 60 41 80 	movabs $0x804160a4c0,%rax
  8041600ef4:	00 00 00 
  8041600ef7:	3e ff 24 f0          	notrack jmp *(%rax,%rsi,8)
    case DW_FORM_addr: {
        uintptr_t data = 0;
  8041600efb:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041600f02:	00 
        memcpy(&data, entry, address_size);
  8041600f03:	4c 89 c2             	mov    %r8,%rdx
  8041600f06:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  8041600f0a:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041600f0e:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041600f15:	00 00 00 
  8041600f18:	ff d0                	call   *%rax
        entry += address_size;
  8041600f1a:	48 01 5d b8          	add    %rbx,-0x48(%rbp)
        if (buf && bufsize >= sizeof(uintptr_t))
  8041600f1e:	4d 85 e4             	test   %r12,%r12
  8041600f21:	74 06                	je     8041600f29 <dwarf_read_abbrev_entry+0x67>
  8041600f23:	41 83 fd 07          	cmp    $0x7,%r13d
  8041600f27:	77 07                	ja     8041600f30 <dwarf_read_abbrev_entry+0x6e>
            put_unaligned(data, (uintptr_t *)buf);
        bytes = address_size;
  8041600f29:	89 d8                	mov    %ebx,%eax
    } break;
  8041600f2b:	e9 14 0a 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
            put_unaligned(data, (uintptr_t *)buf);
  8041600f30:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600f34:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600f38:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600f3d:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600f41:	4c 89 e7             	mov    %r12,%rdi
  8041600f44:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041600f4b:	00 00 00 
  8041600f4e:	ff d0                	call   *%rax
  8041600f50:	eb d7                	jmp    8041600f29 <dwarf_read_abbrev_entry+0x67>
    case DW_FORM_block2: {
        /* Read block of 2-byte length followed by 0 to 65535 contiguous information bytes */
        // LAB 2: Your code here
        Dwarf_Half length = get_unaligned(entry, Dwarf_Half);
  8041600f52:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600f57:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  8041600f5b:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600f5f:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041600f66:	00 00 00 
  8041600f69:	ff d0                	call   *%rax
  8041600f6b:	0f b7 5d d0          	movzwl -0x30(%rbp),%ebx
        entry += sizeof(Dwarf_Half);
  8041600f6f:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041600f73:	48 83 c0 02          	add    $0x2,%rax
  8041600f77:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
        struct Slice slice = {
  8041600f7b:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600f7f:	0f b7 c3             	movzwl %bx,%eax
  8041600f82:	89 45 d8             	mov    %eax,-0x28(%rbp)
                .mem = entry,
                .len = length,
        };
        if(buf) memcpy(buf, &slice, sizeof(struct Slice));
  8041600f85:	4d 85 e4             	test   %r12,%r12
  8041600f88:	74 18                	je     8041600fa2 <dwarf_read_abbrev_entry+0xe0>
  8041600f8a:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600f8f:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600f93:	4c 89 e7             	mov    %r12,%rdi
  8041600f96:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041600f9d:	00 00 00 
  8041600fa0:	ff d0                	call   *%rax
        entry += length;
        bytes = sizeof(Dwarf_Half) + length;
  8041600fa2:	0f b7 db             	movzwl %bx,%ebx
  8041600fa5:	8d 43 02             	lea    0x2(%rbx),%eax
    } break;
  8041600fa8:	e9 97 09 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
    case DW_FORM_block4: {
        uint32_t length = get_unaligned(entry, uint32_t);
  8041600fad:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600fb2:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  8041600fb6:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600fba:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041600fc1:	00 00 00 
  8041600fc4:	ff d0                	call   *%rax
  8041600fc6:	8b 5d d0             	mov    -0x30(%rbp),%ebx
        entry += sizeof(uint32_t);
  8041600fc9:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041600fcd:	48 83 c0 04          	add    $0x4,%rax
  8041600fd1:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
        struct Slice slice = {
  8041600fd5:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600fd9:	89 5d d8             	mov    %ebx,-0x28(%rbp)
                .mem = entry,
                .len = length,
        };
        if (buf) memcpy(buf, &slice, sizeof(struct Slice));
  8041600fdc:	4d 85 e4             	test   %r12,%r12
  8041600fdf:	74 18                	je     8041600ff9 <dwarf_read_abbrev_entry+0x137>
  8041600fe1:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600fe6:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600fea:	4c 89 e7             	mov    %r12,%rdi
  8041600fed:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041600ff4:	00 00 00 
  8041600ff7:	ff d0                	call   *%rax
        entry += length;
        bytes = sizeof(uint32_t) + length;
  8041600ff9:	8d 43 04             	lea    0x4(%rbx),%eax
    } break;
  8041600ffc:	e9 43 09 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
    case DW_FORM_data2: {
        Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
  8041601001:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601006:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  804160100a:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160100e:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041601015:	00 00 00 
  8041601018:	ff d0                	call   *%rax
        entry += sizeof(Dwarf_Half);
  804160101a:	48 83 45 b8 02       	addq   $0x2,-0x48(%rbp)
        if (buf && bufsize >= sizeof(Dwarf_Half))
  804160101f:	4d 85 e4             	test   %r12,%r12
  8041601022:	74 06                	je     804160102a <dwarf_read_abbrev_entry+0x168>
  8041601024:	41 83 fd 01          	cmp    $0x1,%r13d
  8041601028:	77 0a                	ja     8041601034 <dwarf_read_abbrev_entry+0x172>
            put_unaligned(data, (Dwarf_Half *)buf);
        bytes = sizeof(Dwarf_Half);
  804160102a:	b8 02 00 00 00       	mov    $0x2,%eax
  804160102f:	e9 10 09 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
            put_unaligned(data, (Dwarf_Half *)buf);
  8041601034:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601039:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160103d:	4c 89 e7             	mov    %r12,%rdi
  8041601040:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041601047:	00 00 00 
  804160104a:	ff d0                	call   *%rax
        bytes = sizeof(Dwarf_Half);
  804160104c:	b8 02 00 00 00       	mov    $0x2,%eax
            put_unaligned(data, (Dwarf_Half *)buf);
  8041601051:	e9 ee 08 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
    } break;
    case DW_FORM_data4: {
        uint32_t data = get_unaligned(entry, uint32_t);
  8041601056:	ba 04 00 00 00       	mov    $0x4,%edx
  804160105b:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  804160105f:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601063:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  804160106a:	00 00 00 
  804160106d:	ff d0                	call   *%rax
        entry += sizeof(uint32_t);
  804160106f:	48 83 45 b8 04       	addq   $0x4,-0x48(%rbp)
        if (buf && bufsize >= sizeof(uint32_t))
  8041601074:	4d 85 e4             	test   %r12,%r12
  8041601077:	74 06                	je     804160107f <dwarf_read_abbrev_entry+0x1bd>
  8041601079:	41 83 fd 03          	cmp    $0x3,%r13d
  804160107d:	77 0a                	ja     8041601089 <dwarf_read_abbrev_entry+0x1c7>
            put_unaligned(data, (uint32_t *)buf);
        bytes = sizeof(uint32_t);
  804160107f:	b8 04 00 00 00       	mov    $0x4,%eax
  8041601084:	e9 bb 08 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
            put_unaligned(data, (uint32_t *)buf);
  8041601089:	ba 04 00 00 00       	mov    $0x4,%edx
  804160108e:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601092:	4c 89 e7             	mov    %r12,%rdi
  8041601095:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  804160109c:	00 00 00 
  804160109f:	ff d0                	call   *%rax
        bytes = sizeof(uint32_t);
  80416010a1:	b8 04 00 00 00       	mov    $0x4,%eax
            put_unaligned(data, (uint32_t *)buf);
  80416010a6:	e9 99 08 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
    } break;
    case DW_FORM_data8: {
        uint64_t data = get_unaligned(entry, uint64_t);
  80416010ab:	ba 08 00 00 00       	mov    $0x8,%edx
  80416010b0:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  80416010b4:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416010b8:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416010bf:	00 00 00 
  80416010c2:	ff d0                	call   *%rax
        entry += sizeof(uint64_t);
  80416010c4:	48 83 45 b8 08       	addq   $0x8,-0x48(%rbp)
        if (buf && bufsize >= sizeof(uint64_t))
  80416010c9:	4d 85 e4             	test   %r12,%r12
  80416010cc:	74 06                	je     80416010d4 <dwarf_read_abbrev_entry+0x212>
  80416010ce:	41 83 fd 07          	cmp    $0x7,%r13d
  80416010d2:	77 0a                	ja     80416010de <dwarf_read_abbrev_entry+0x21c>
            put_unaligned(data, (uint64_t *)buf);
        bytes = sizeof(uint64_t);
  80416010d4:	b8 08 00 00 00       	mov    $0x8,%eax
  80416010d9:	e9 66 08 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
            put_unaligned(data, (uint64_t *)buf);
  80416010de:	ba 08 00 00 00       	mov    $0x8,%edx
  80416010e3:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416010e7:	4c 89 e7             	mov    %r12,%rdi
  80416010ea:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416010f1:	00 00 00 
  80416010f4:	ff d0                	call   *%rax
        bytes = sizeof(uint64_t);
  80416010f6:	b8 08 00 00 00       	mov    $0x8,%eax
            put_unaligned(data, (uint64_t *)buf);
  80416010fb:	e9 44 08 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
    } break;
    case DW_FORM_string: {
        if (buf && bufsize >= sizeof(char *))
  8041601100:	48 85 d2             	test   %rdx,%rdx
  8041601103:	74 05                	je     804160110a <dwarf_read_abbrev_entry+0x248>
  8041601105:	83 f9 07             	cmp    $0x7,%ecx
  8041601108:	77 18                	ja     8041601122 <dwarf_read_abbrev_entry+0x260>
            memcpy(buf, &entry, sizeof(char *));
        bytes = strlen(entry) + 1;
  804160110a:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  804160110e:	48 b8 ac 91 60 41 80 	movabs $0x80416091ac,%rax
  8041601115:	00 00 00 
  8041601118:	ff d0                	call   *%rax
  804160111a:	83 c0 01             	add    $0x1,%eax
    } break;
  804160111d:	e9 22 08 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
            memcpy(buf, &entry, sizeof(char *));
  8041601122:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601127:	48 8d 75 b8          	lea    -0x48(%rbp),%rsi
  804160112b:	4c 89 e7             	mov    %r12,%rdi
  804160112e:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041601135:	00 00 00 
  8041601138:	ff d0                	call   *%rax
  804160113a:	eb ce                	jmp    804160110a <dwarf_read_abbrev_entry+0x248>
    case DW_FORM_block: {
        uint64_t length = 0;
        uint32_t count = dwarf_read_uleb128(entry, &length);
  804160113c:	4c 8b 45 b8          	mov    -0x48(%rbp),%r8
  8041601140:	4c 89 c2             	mov    %r8,%rdx
/* Decode an unsigned LEB128 encoded datum. The algorithm is taken from Appendix C
 * of the DWARF 4 spec. Return the number of bytes read */
static inline uint64_t
dwarf_read_uleb128(const uint8_t *addr, uint64_t *ret) {
    uint64_t result = 0;
    size_t shift = 0, count = 0;
  8041601143:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601148:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  804160114d:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    uint8_t byte;

    do {
        byte = *addr++;
  8041601153:	48 83 c2 01          	add    $0x1,%rdx
  8041601157:	0f b6 7a ff          	movzbl -0x1(%rdx),%edi
        result |= (byte & 0x7FULL) << shift;
  804160115b:	48 89 fe             	mov    %rdi,%rsi
  804160115e:	83 e6 7f             	and    $0x7f,%esi
  8041601161:	48 d3 e6             	shl    %cl,%rsi
  8041601164:	49 09 f5             	or     %rsi,%r13
        shift += 7;
  8041601167:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  804160116b:	48 89 c6             	mov    %rax,%rsi
  804160116e:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  8041601172:	40 84 ff             	test   %dil,%dil
  8041601175:	79 06                	jns    804160117d <dwarf_read_abbrev_entry+0x2bb>
  8041601177:	48 83 f9 3f          	cmp    $0x3f,%rcx
  804160117b:	76 d6                	jbe    8041601153 <dwarf_read_abbrev_entry+0x291>

    while (byte & 0x80) {
  804160117d:	40 84 ff             	test   %dil,%dil
  8041601180:	79 12                	jns    8041601194 <dwarf_read_abbrev_entry+0x2d2>
        byte = *addr++;
  8041601182:	48 f7 d6             	not    %rsi
  8041601185:	48 01 f2             	add    %rsi,%rdx
  8041601188:	0f b6 0c 02          	movzbl (%rdx,%rax,1),%ecx
        count++;
  804160118c:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  8041601190:	84 c9                	test   %cl,%cl
  8041601192:	78 f4                	js     8041601188 <dwarf_read_abbrev_entry+0x2c6>
  8041601194:	89 c3                	mov    %eax,%ebx
        entry += count;
  8041601196:	89 c0                	mov    %eax,%eax
  8041601198:	49 01 c0             	add    %rax,%r8
  804160119b:	4c 89 45 b8          	mov    %r8,-0x48(%rbp)
        struct Slice slice = {
  804160119f:	4c 89 45 d0          	mov    %r8,-0x30(%rbp)
  80416011a3:	44 89 6d d8          	mov    %r13d,-0x28(%rbp)
                .mem = entry,
                .len = length,
        };
        if (buf) memcpy(buf, &slice, sizeof(struct Slice));
  80416011a7:	4d 85 e4             	test   %r12,%r12
  80416011aa:	74 18                	je     80416011c4 <dwarf_read_abbrev_entry+0x302>
  80416011ac:	ba 10 00 00 00       	mov    $0x10,%edx
  80416011b1:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416011b5:	4c 89 e7             	mov    %r12,%rdi
  80416011b8:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416011bf:	00 00 00 
  80416011c2:	ff d0                	call   *%rax
        entry += length;
        bytes = count + length;
  80416011c4:	42 8d 04 2b          	lea    (%rbx,%r13,1),%eax
    } break;
  80416011c8:	e9 77 07 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
    case DW_FORM_block1: {
        uint32_t length = get_unaligned(entry, Dwarf_Small);
  80416011cd:	ba 01 00 00 00       	mov    $0x1,%edx
  80416011d2:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  80416011d6:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416011da:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416011e1:	00 00 00 
  80416011e4:	ff d0                	call   *%rax
  80416011e6:	0f b6 5d d0          	movzbl -0x30(%rbp),%ebx
        entry += sizeof(Dwarf_Small);
  80416011ea:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80416011ee:	48 83 c0 01          	add    $0x1,%rax
  80416011f2:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
        struct Slice slice = {
  80416011f6:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  80416011fa:	89 5d d8             	mov    %ebx,-0x28(%rbp)
                .mem = entry,
                .len = length,
        };
        if (buf) memcpy(buf, &slice, sizeof(struct Slice));
  80416011fd:	4d 85 e4             	test   %r12,%r12
  8041601200:	74 18                	je     804160121a <dwarf_read_abbrev_entry+0x358>
  8041601202:	ba 10 00 00 00       	mov    $0x10,%edx
  8041601207:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160120b:	4c 89 e7             	mov    %r12,%rdi
  804160120e:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041601215:	00 00 00 
  8041601218:	ff d0                	call   *%rax
        entry += length;
        bytes = length + sizeof(Dwarf_Small);
  804160121a:	8d 43 01             	lea    0x1(%rbx),%eax
    } break;
  804160121d:	e9 22 07 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
    case DW_FORM_data1: {
        Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
  8041601222:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601227:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  804160122b:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160122f:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041601236:	00 00 00 
  8041601239:	ff d0                	call   *%rax
  804160123b:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
        entry += sizeof(Dwarf_Small);
        if (buf && bufsize >= sizeof(Dwarf_Small)) {
  804160123f:	4d 85 e4             	test   %r12,%r12
  8041601242:	0f 84 09 07 00 00    	je     8041601951 <dwarf_read_abbrev_entry+0xa8f>
  8041601248:	45 85 ed             	test   %r13d,%r13d
  804160124b:	0f 84 00 07 00 00    	je     8041601951 <dwarf_read_abbrev_entry+0xa8f>
            put_unaligned(data, (Dwarf_Small *)buf);
  8041601251:	41 88 04 24          	mov    %al,(%r12)
        }
        bytes = sizeof(Dwarf_Small);
  8041601255:	b8 01 00 00 00       	mov    $0x1,%eax
            put_unaligned(data, (Dwarf_Small *)buf);
  804160125a:	e9 e5 06 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
    } break;
    case DW_FORM_flag: {
        bool data = get_unaligned(entry, Dwarf_Small);
  804160125f:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601264:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  8041601268:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160126c:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041601273:	00 00 00 
  8041601276:	ff d0                	call   *%rax
  8041601278:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
        entry += sizeof(Dwarf_Small);
        if (buf && bufsize >= sizeof(bool)) {
  804160127c:	4d 85 e4             	test   %r12,%r12
  804160127f:	0f 84 d3 06 00 00    	je     8041601958 <dwarf_read_abbrev_entry+0xa96>
  8041601285:	45 85 ed             	test   %r13d,%r13d
  8041601288:	0f 84 ca 06 00 00    	je     8041601958 <dwarf_read_abbrev_entry+0xa96>
        bool data = get_unaligned(entry, Dwarf_Small);
  804160128e:	84 c0                	test   %al,%al
            put_unaligned(data, (bool *)buf);
  8041601290:	41 0f 95 04 24       	setne  (%r12)
        }
        bytes = sizeof(Dwarf_Small);
  8041601295:	b8 01 00 00 00       	mov    $0x1,%eax
            put_unaligned(data, (bool *)buf);
  804160129a:	e9 a5 06 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
    } break;
    case DW_FORM_sdata: {
        int64_t data = 0;
        uint32_t count = dwarf_read_leb128(entry, &data);
  804160129f:	4c 8b 45 b8          	mov    -0x48(%rbp),%r8
  80416012a3:	4c 89 c0             	mov    %r8,%rax
/* Decode signed LEB128 data. The Algorithm is taken from Appendix C
 * of the DWARF 4 spec. Return the number of bytes read */
static inline uint64_t
dwarf_read_leb128(const char *addr, int64_t *ret) {
    size_t shift = 0, count = 0;
    uint64_t result = 0;
  80416012a6:	bf 00 00 00 00       	mov    $0x0,%edi
    size_t shift = 0, count = 0;
  80416012ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416012b0:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint8_t byte;

    do {
        byte = *addr++;
  80416012b5:	48 83 c0 01          	add    $0x1,%rax
  80416012b9:	0f b6 70 ff          	movzbl -0x1(%rax),%esi
        result |= (byte & 0x7FULL) << shift;
  80416012bd:	48 89 f2             	mov    %rsi,%rdx
  80416012c0:	83 e2 7f             	and    $0x7f,%edx
  80416012c3:	48 d3 e2             	shl    %cl,%rdx
  80416012c6:	48 09 d7             	or     %rdx,%rdi
        shift += 7;
  80416012c9:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  80416012cd:	48 89 da             	mov    %rbx,%rdx
  80416012d0:	48 83 c3 01          	add    $0x1,%rbx
    } while (byte & 0x80 && shift < 64);
  80416012d4:	40 84 f6             	test   %sil,%sil
  80416012d7:	79 06                	jns    80416012df <dwarf_read_abbrev_entry+0x41d>
  80416012d9:	48 83 f9 3f          	cmp    $0x3f,%rcx
  80416012dd:	76 d6                	jbe    80416012b5 <dwarf_read_abbrev_entry+0x3f3>

    while (byte & 0x80) {
  80416012df:	40 84 f6             	test   %sil,%sil
  80416012e2:	79 2d                	jns    8041601311 <dwarf_read_abbrev_entry+0x44f>
        byte = *addr++;
  80416012e4:	48 f7 d2             	not    %rdx
  80416012e7:	48 01 d0             	add    %rdx,%rax
  80416012ea:	0f b6 14 18          	movzbl (%rax,%rbx,1),%edx
        count++;
  80416012ee:	48 83 c3 01          	add    $0x1,%rbx
    while (byte & 0x80) {
  80416012f2:	84 d2                	test   %dl,%dl
  80416012f4:	78 f4                	js     80416012ea <dwarf_read_abbrev_entry+0x428>
        entry += count;
  80416012f6:	89 d8                	mov    %ebx,%eax
  80416012f8:	49 01 c0             	add    %rax,%r8
  80416012fb:	4c 89 45 b8          	mov    %r8,-0x48(%rbp)
        if (buf && bufsize >= sizeof(int32_t))
  80416012ff:	4d 85 e4             	test   %r12,%r12
  8041601302:	74 06                	je     804160130a <dwarf_read_abbrev_entry+0x448>
  8041601304:	41 83 fd 03          	cmp    $0x3,%r13d
  8041601308:	77 1f                	ja     8041601329 <dwarf_read_abbrev_entry+0x467>
            put_unaligned(data, (int32_t *)buf);
        bytes = count;
  804160130a:	89 d8                	mov    %ebx,%eax
    } break;
  804160130c:	e9 33 06 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
    }

    /* The number of bits in a signed integer. */
    if (shift < 8 * sizeof(result) && byte & 0x40)
  8041601311:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041601315:	77 df                	ja     80416012f6 <dwarf_read_abbrev_entry+0x434>
  8041601317:	40 f6 c6 40          	test   $0x40,%sil
  804160131b:	74 d9                	je     80416012f6 <dwarf_read_abbrev_entry+0x434>
        result |= (-1U << shift);
  804160131d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8041601322:	d3 e0                	shl    %cl,%eax
  8041601324:	48 09 c7             	or     %rax,%rdi
  8041601327:	eb cd                	jmp    80416012f6 <dwarf_read_abbrev_entry+0x434>
            put_unaligned(data, (int32_t *)buf);
  8041601329:	89 7d d0             	mov    %edi,-0x30(%rbp)
  804160132c:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601331:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601335:	4c 89 e7             	mov    %r12,%rdi
  8041601338:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  804160133f:	00 00 00 
  8041601342:	ff d0                	call   *%rax
  8041601344:	eb c4                	jmp    804160130a <dwarf_read_abbrev_entry+0x448>
    case DW_FORM_strp: {
        uint64_t length = 0;
        uint32_t count = dwarf_entry_len(entry, &length);
  8041601346:	4c 8b 75 b8          	mov    -0x48(%rbp),%r14
    uint64_t initial_len = get_unaligned(addr, uint32_t);
  804160134a:	ba 04 00 00 00       	mov    $0x4,%edx
  804160134f:	4c 89 f6             	mov    %r14,%rsi
  8041601352:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601356:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  804160135d:	00 00 00 
  8041601360:	ff d0                	call   *%rax
  8041601362:	8b 55 d0             	mov    -0x30(%rbp),%edx
    if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601365:	48 b8 10 00 00 00 ff 	movabs $0xffffffff00000010,%rax
  804160136c:	ff ff ff 
  804160136f:	48 01 d0             	add    %rdx,%rax
    uint64_t count = sizeof(uint32_t);
  8041601372:	bb 04 00 00 00       	mov    $0x4,%ebx
    if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601377:	48 83 f8 0f          	cmp    $0xf,%rax
  804160137b:	77 2f                	ja     80416013ac <dwarf_read_abbrev_entry+0x4ea>
        if (initial_len == DW_EXT_DWARF64) {
  804160137d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8041601382:	48 39 c2             	cmp    %rax,%rdx
  8041601385:	74 3b                	je     80416013c2 <dwarf_read_abbrev_entry+0x500>
            cprintf("Unknown DWARF extension\n");
  8041601387:	48 bf 40 a4 60 41 80 	movabs $0x804160a440,%rdi
  804160138e:	00 00 00 
  8041601391:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601396:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  804160139d:	00 00 00 
  80416013a0:	ff d2                	call   *%rdx
        uint64_t length = 0;
  80416013a2:	ba 00 00 00 00       	mov    $0x0,%edx
            count = 0;
  80416013a7:	bb 00 00 00 00       	mov    $0x0,%ebx
        entry += count;
  80416013ac:	48 01 5d b8          	add    %rbx,-0x48(%rbp)
        if (buf && bufsize >= sizeof(uint64_t))
  80416013b0:	4d 85 e4             	test   %r12,%r12
  80416013b3:	74 06                	je     80416013bb <dwarf_read_abbrev_entry+0x4f9>
  80416013b5:	41 83 fd 07          	cmp    $0x7,%r13d
  80416013b9:	77 2b                	ja     80416013e6 <dwarf_read_abbrev_entry+0x524>
            put_unaligned(length, (uint64_t *)buf);
        bytes = count;
  80416013bb:	89 d8                	mov    %ebx,%eax
    } break;
  80416013bd:	e9 82 05 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
            *len = get_unaligned((uint64_t *)addr + sizeof(uint32_t), uint64_t);
  80416013c2:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416013c6:	ba 08 00 00 00       	mov    $0x8,%edx
  80416013cb:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416013cf:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416013d6:	00 00 00 
  80416013d9:	ff d0                	call   *%rax
  80416013db:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
            count += sizeof(uint64_t);
  80416013df:	bb 0c 00 00 00       	mov    $0xc,%ebx
  80416013e4:	eb c6                	jmp    80416013ac <dwarf_read_abbrev_entry+0x4ea>
            put_unaligned(length, (uint64_t *)buf);
  80416013e6:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  80416013ea:	ba 08 00 00 00       	mov    $0x8,%edx
  80416013ef:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416013f3:	4c 89 e7             	mov    %r12,%rdi
  80416013f6:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416013fd:	00 00 00 
  8041601400:	ff d0                	call   *%rax
  8041601402:	eb b7                	jmp    80416013bb <dwarf_read_abbrev_entry+0x4f9>
    case DW_FORM_udata: {
        uint64_t data = 0;
        uint32_t count = dwarf_read_uleb128(entry, &data);
  8041601404:	4c 8b 45 b8          	mov    -0x48(%rbp),%r8
  8041601408:	4c 89 c0             	mov    %r8,%rax
    size_t shift = 0, count = 0;
  804160140b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041601410:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041601415:	bf 00 00 00 00       	mov    $0x0,%edi
        byte = *addr++;
  804160141a:	48 83 c0 01          	add    $0x1,%rax
  804160141e:	0f b6 70 ff          	movzbl -0x1(%rax),%esi
        result |= (byte & 0x7FULL) << shift;
  8041601422:	48 89 f2             	mov    %rsi,%rdx
  8041601425:	83 e2 7f             	and    $0x7f,%edx
  8041601428:	48 d3 e2             	shl    %cl,%rdx
  804160142b:	48 09 d7             	or     %rdx,%rdi
        shift += 7;
  804160142e:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041601432:	48 89 da             	mov    %rbx,%rdx
  8041601435:	48 83 c3 01          	add    $0x1,%rbx
    } while (byte & 0x80 && shift < 64);
  8041601439:	40 84 f6             	test   %sil,%sil
  804160143c:	79 06                	jns    8041601444 <dwarf_read_abbrev_entry+0x582>
  804160143e:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041601442:	76 d6                	jbe    804160141a <dwarf_read_abbrev_entry+0x558>
    while (byte & 0x80) {
  8041601444:	40 84 f6             	test   %sil,%sil
  8041601447:	79 12                	jns    804160145b <dwarf_read_abbrev_entry+0x599>
        byte = *addr++;
  8041601449:	48 f7 d2             	not    %rdx
  804160144c:	48 01 d0             	add    %rdx,%rax
  804160144f:	0f b6 14 18          	movzbl (%rax,%rbx,1),%edx
        count++;
  8041601453:	48 83 c3 01          	add    $0x1,%rbx
    while (byte & 0x80) {
  8041601457:	84 d2                	test   %dl,%dl
  8041601459:	78 f4                	js     804160144f <dwarf_read_abbrev_entry+0x58d>
        entry += count;
  804160145b:	89 d8                	mov    %ebx,%eax
  804160145d:	49 01 c0             	add    %rax,%r8
  8041601460:	4c 89 45 b8          	mov    %r8,-0x48(%rbp)
        if (buf && bufsize >= sizeof(uint32_t))
  8041601464:	4d 85 e4             	test   %r12,%r12
  8041601467:	74 06                	je     804160146f <dwarf_read_abbrev_entry+0x5ad>
  8041601469:	41 83 fd 03          	cmp    $0x3,%r13d
  804160146d:	77 07                	ja     8041601476 <dwarf_read_abbrev_entry+0x5b4>
            put_unaligned(data, (uint32_t *)buf);
        bytes = count;
  804160146f:	89 d8                	mov    %ebx,%eax
    } break;
  8041601471:	e9 ce 04 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
            put_unaligned(data, (uint32_t *)buf);
  8041601476:	89 7d d0             	mov    %edi,-0x30(%rbp)
  8041601479:	ba 04 00 00 00       	mov    $0x4,%edx
  804160147e:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601482:	4c 89 e7             	mov    %r12,%rdi
  8041601485:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  804160148c:	00 00 00 
  804160148f:	ff d0                	call   *%rax
  8041601491:	eb dc                	jmp    804160146f <dwarf_read_abbrev_entry+0x5ad>
    case DW_FORM_ref_addr: {
        uint64_t length = 0;
        uint32_t count = dwarf_entry_len(entry, &length);
  8041601493:	4c 8b 75 b8          	mov    -0x48(%rbp),%r14
    uint64_t initial_len = get_unaligned(addr, uint32_t);
  8041601497:	ba 04 00 00 00       	mov    $0x4,%edx
  804160149c:	4c 89 f6             	mov    %r14,%rsi
  804160149f:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416014a3:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416014aa:	00 00 00 
  80416014ad:	ff d0                	call   *%rax
  80416014af:	8b 55 d0             	mov    -0x30(%rbp),%edx
    if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416014b2:	48 b8 10 00 00 00 ff 	movabs $0xffffffff00000010,%rax
  80416014b9:	ff ff ff 
  80416014bc:	48 01 d0             	add    %rdx,%rax
    uint64_t count = sizeof(uint32_t);
  80416014bf:	bb 04 00 00 00       	mov    $0x4,%ebx
    if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416014c4:	48 83 f8 0f          	cmp    $0xf,%rax
  80416014c8:	77 2f                	ja     80416014f9 <dwarf_read_abbrev_entry+0x637>
        if (initial_len == DW_EXT_DWARF64) {
  80416014ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80416014cf:	48 39 c2             	cmp    %rax,%rdx
  80416014d2:	74 3b                	je     804160150f <dwarf_read_abbrev_entry+0x64d>
            cprintf("Unknown DWARF extension\n");
  80416014d4:	48 bf 40 a4 60 41 80 	movabs $0x804160a440,%rdi
  80416014db:	00 00 00 
  80416014de:	b8 00 00 00 00       	mov    $0x0,%eax
  80416014e3:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  80416014ea:	00 00 00 
  80416014ed:	ff d2                	call   *%rdx
        uint64_t length = 0;
  80416014ef:	ba 00 00 00 00       	mov    $0x0,%edx
            count = 0;
  80416014f4:	bb 00 00 00 00       	mov    $0x0,%ebx
        entry += count;
  80416014f9:	48 01 5d b8          	add    %rbx,-0x48(%rbp)
        if (buf && bufsize >= sizeof(uint64_t))
  80416014fd:	4d 85 e4             	test   %r12,%r12
  8041601500:	74 06                	je     8041601508 <dwarf_read_abbrev_entry+0x646>
  8041601502:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601506:	77 2b                	ja     8041601533 <dwarf_read_abbrev_entry+0x671>
            put_unaligned(length, (uint64_t *)buf);
        bytes = count;
  8041601508:	89 d8                	mov    %ebx,%eax
    } break;
  804160150a:	e9 35 04 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
            *len = get_unaligned((uint64_t *)addr + sizeof(uint32_t), uint64_t);
  804160150f:	49 8d 76 20          	lea    0x20(%r14),%rsi
  8041601513:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601518:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160151c:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041601523:	00 00 00 
  8041601526:	ff d0                	call   *%rax
  8041601528:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
            count += sizeof(uint64_t);
  804160152c:	bb 0c 00 00 00       	mov    $0xc,%ebx
  8041601531:	eb c6                	jmp    80416014f9 <dwarf_read_abbrev_entry+0x637>
            put_unaligned(length, (uint64_t *)buf);
  8041601533:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  8041601537:	ba 08 00 00 00       	mov    $0x8,%edx
  804160153c:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601540:	4c 89 e7             	mov    %r12,%rdi
  8041601543:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  804160154a:	00 00 00 
  804160154d:	ff d0                	call   *%rax
  804160154f:	eb b7                	jmp    8041601508 <dwarf_read_abbrev_entry+0x646>
    case DW_FORM_ref1: {
        Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
  8041601551:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601556:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  804160155a:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160155e:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041601565:	00 00 00 
  8041601568:	ff d0                	call   *%rax
  804160156a:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
        entry += sizeof(Dwarf_Small);
        if (buf && bufsize >= sizeof(Dwarf_Small))
  804160156e:	4d 85 e4             	test   %r12,%r12
  8041601571:	0f 84 e8 03 00 00    	je     804160195f <dwarf_read_abbrev_entry+0xa9d>
  8041601577:	45 85 ed             	test   %r13d,%r13d
  804160157a:	0f 84 df 03 00 00    	je     804160195f <dwarf_read_abbrev_entry+0xa9d>
            put_unaligned(data, (Dwarf_Small *)buf);
  8041601580:	41 88 04 24          	mov    %al,(%r12)
        bytes = sizeof(Dwarf_Small);
  8041601584:	b8 01 00 00 00       	mov    $0x1,%eax
            put_unaligned(data, (Dwarf_Small *)buf);
  8041601589:	e9 b6 03 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
    } break;
    case DW_FORM_ref2: {
        Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
  804160158e:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601593:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  8041601597:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160159b:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416015a2:	00 00 00 
  80416015a5:	ff d0                	call   *%rax
        entry += sizeof(Dwarf_Half);
  80416015a7:	48 83 45 b8 02       	addq   $0x2,-0x48(%rbp)
        if (buf && bufsize >= sizeof(Dwarf_Half))
  80416015ac:	4d 85 e4             	test   %r12,%r12
  80416015af:	74 06                	je     80416015b7 <dwarf_read_abbrev_entry+0x6f5>
  80416015b1:	41 83 fd 01          	cmp    $0x1,%r13d
  80416015b5:	77 0a                	ja     80416015c1 <dwarf_read_abbrev_entry+0x6ff>
            put_unaligned(data, (Dwarf_Half *)buf);
        bytes = sizeof(Dwarf_Half);
  80416015b7:	b8 02 00 00 00       	mov    $0x2,%eax
  80416015bc:	e9 83 03 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
            put_unaligned(data, (Dwarf_Half *)buf);
  80416015c1:	ba 02 00 00 00       	mov    $0x2,%edx
  80416015c6:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416015ca:	4c 89 e7             	mov    %r12,%rdi
  80416015cd:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416015d4:	00 00 00 
  80416015d7:	ff d0                	call   *%rax
        bytes = sizeof(Dwarf_Half);
  80416015d9:	b8 02 00 00 00       	mov    $0x2,%eax
            put_unaligned(data, (Dwarf_Half *)buf);
  80416015de:	e9 61 03 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
    } break;
    case DW_FORM_ref4: {
        uint32_t data = get_unaligned(entry, uint32_t);
  80416015e3:	ba 04 00 00 00       	mov    $0x4,%edx
  80416015e8:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  80416015ec:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416015f0:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416015f7:	00 00 00 
  80416015fa:	ff d0                	call   *%rax
        entry += sizeof(uint32_t);
  80416015fc:	48 83 45 b8 04       	addq   $0x4,-0x48(%rbp)
        if (buf && bufsize >= sizeof(uint32_t))
  8041601601:	4d 85 e4             	test   %r12,%r12
  8041601604:	74 06                	je     804160160c <dwarf_read_abbrev_entry+0x74a>
  8041601606:	41 83 fd 03          	cmp    $0x3,%r13d
  804160160a:	77 0a                	ja     8041601616 <dwarf_read_abbrev_entry+0x754>
            put_unaligned(data, (uint32_t *)buf);
        bytes = sizeof(uint32_t);
  804160160c:	b8 04 00 00 00       	mov    $0x4,%eax
  8041601611:	e9 2e 03 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
            put_unaligned(data, (uint32_t *)buf);
  8041601616:	ba 04 00 00 00       	mov    $0x4,%edx
  804160161b:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160161f:	4c 89 e7             	mov    %r12,%rdi
  8041601622:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041601629:	00 00 00 
  804160162c:	ff d0                	call   *%rax
        bytes = sizeof(uint32_t);
  804160162e:	b8 04 00 00 00       	mov    $0x4,%eax
            put_unaligned(data, (uint32_t *)buf);
  8041601633:	e9 0c 03 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
    } break;
    case DW_FORM_ref8: {
        uint64_t data = get_unaligned(entry, uint64_t);
  8041601638:	ba 08 00 00 00       	mov    $0x8,%edx
  804160163d:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  8041601641:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601645:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  804160164c:	00 00 00 
  804160164f:	ff d0                	call   *%rax
        entry += sizeof(uint64_t);
  8041601651:	48 83 45 b8 08       	addq   $0x8,-0x48(%rbp)
        if (buf && bufsize >= sizeof(uint64_t))
  8041601656:	4d 85 e4             	test   %r12,%r12
  8041601659:	74 06                	je     8041601661 <dwarf_read_abbrev_entry+0x79f>
  804160165b:	41 83 fd 07          	cmp    $0x7,%r13d
  804160165f:	77 0a                	ja     804160166b <dwarf_read_abbrev_entry+0x7a9>
            put_unaligned(data, (uint64_t *)buf);
        bytes = sizeof(uint64_t);
  8041601661:	b8 08 00 00 00       	mov    $0x8,%eax
  8041601666:	e9 d9 02 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
            put_unaligned(data, (uint64_t *)buf);
  804160166b:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601670:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601674:	4c 89 e7             	mov    %r12,%rdi
  8041601677:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  804160167e:	00 00 00 
  8041601681:	ff d0                	call   *%rax
        bytes = sizeof(uint64_t);
  8041601683:	b8 08 00 00 00       	mov    $0x8,%eax
            put_unaligned(data, (uint64_t *)buf);
  8041601688:	e9 b7 02 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
    } break;
    case DW_FORM_ref_udata: {
        uint64_t data = 0;
        uint32_t count = dwarf_read_uleb128(entry, &data);
  804160168d:	4c 8b 45 b8          	mov    -0x48(%rbp),%r8
  8041601691:	4c 89 c0             	mov    %r8,%rax
    size_t shift = 0, count = 0;
  8041601694:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041601699:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  804160169e:	bf 00 00 00 00       	mov    $0x0,%edi
        byte = *addr++;
  80416016a3:	48 83 c0 01          	add    $0x1,%rax
  80416016a7:	0f b6 70 ff          	movzbl -0x1(%rax),%esi
        result |= (byte & 0x7FULL) << shift;
  80416016ab:	48 89 f2             	mov    %rsi,%rdx
  80416016ae:	83 e2 7f             	and    $0x7f,%edx
  80416016b1:	48 d3 e2             	shl    %cl,%rdx
  80416016b4:	48 09 d7             	or     %rdx,%rdi
        shift += 7;
  80416016b7:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  80416016bb:	48 89 da             	mov    %rbx,%rdx
  80416016be:	48 83 c3 01          	add    $0x1,%rbx
    } while (byte & 0x80 && shift < 64);
  80416016c2:	40 84 f6             	test   %sil,%sil
  80416016c5:	79 06                	jns    80416016cd <dwarf_read_abbrev_entry+0x80b>
  80416016c7:	48 83 f9 3f          	cmp    $0x3f,%rcx
  80416016cb:	76 d6                	jbe    80416016a3 <dwarf_read_abbrev_entry+0x7e1>
    while (byte & 0x80) {
  80416016cd:	40 84 f6             	test   %sil,%sil
  80416016d0:	79 12                	jns    80416016e4 <dwarf_read_abbrev_entry+0x822>
        byte = *addr++;
  80416016d2:	48 f7 d2             	not    %rdx
  80416016d5:	48 01 d0             	add    %rdx,%rax
  80416016d8:	0f b6 14 18          	movzbl (%rax,%rbx,1),%edx
        count++;
  80416016dc:	48 83 c3 01          	add    $0x1,%rbx
    while (byte & 0x80) {
  80416016e0:	84 d2                	test   %dl,%dl
  80416016e2:	78 f4                	js     80416016d8 <dwarf_read_abbrev_entry+0x816>
        entry += count;
  80416016e4:	89 d8                	mov    %ebx,%eax
  80416016e6:	49 01 c0             	add    %rax,%r8
  80416016e9:	4c 89 45 b8          	mov    %r8,-0x48(%rbp)
        if (buf && bufsize >= sizeof(unsigned int))
  80416016ed:	4d 85 e4             	test   %r12,%r12
  80416016f0:	74 06                	je     80416016f8 <dwarf_read_abbrev_entry+0x836>
  80416016f2:	41 83 fd 03          	cmp    $0x3,%r13d
  80416016f6:	77 07                	ja     80416016ff <dwarf_read_abbrev_entry+0x83d>
            put_unaligned(data, (unsigned int *)buf);
        bytes = count;
  80416016f8:	89 d8                	mov    %ebx,%eax
    } break;
  80416016fa:	e9 45 02 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
            put_unaligned(data, (unsigned int *)buf);
  80416016ff:	89 7d d0             	mov    %edi,-0x30(%rbp)
  8041601702:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601707:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160170b:	4c 89 e7             	mov    %r12,%rdi
  804160170e:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041601715:	00 00 00 
  8041601718:	ff d0                	call   *%rax
  804160171a:	eb dc                	jmp    80416016f8 <dwarf_read_abbrev_entry+0x836>
    case DW_FORM_indirect: {
        uint64_t form = 0;
        uint32_t count = dwarf_read_uleb128(entry, &form);
  804160171c:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8041601720:	48 89 f8             	mov    %rdi,%rax
    size_t shift = 0, count = 0;
  8041601723:	41 be 00 00 00 00    	mov    $0x0,%r14d
  8041601729:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  804160172e:	be 00 00 00 00       	mov    $0x0,%esi
        byte = *addr++;
  8041601733:	48 83 c0 01          	add    $0x1,%rax
  8041601737:	44 0f b6 40 ff       	movzbl -0x1(%rax),%r8d
        result |= (byte & 0x7FULL) << shift;
  804160173c:	4c 89 c2             	mov    %r8,%rdx
  804160173f:	83 e2 7f             	and    $0x7f,%edx
  8041601742:	48 d3 e2             	shl    %cl,%rdx
  8041601745:	48 09 d6             	or     %rdx,%rsi
        shift += 7;
  8041601748:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  804160174c:	4c 89 f2             	mov    %r14,%rdx
  804160174f:	49 83 c6 01          	add    $0x1,%r14
    } while (byte & 0x80 && shift < 64);
  8041601753:	45 84 c0             	test   %r8b,%r8b
  8041601756:	79 06                	jns    804160175e <dwarf_read_abbrev_entry+0x89c>
  8041601758:	48 83 f9 3f          	cmp    $0x3f,%rcx
  804160175c:	76 d5                	jbe    8041601733 <dwarf_read_abbrev_entry+0x871>
    while (byte & 0x80) {
  804160175e:	45 84 c0             	test   %r8b,%r8b
  8041601761:	79 13                	jns    8041601776 <dwarf_read_abbrev_entry+0x8b4>
        byte = *addr++;
  8041601763:	48 f7 d2             	not    %rdx
  8041601766:	48 01 d0             	add    %rdx,%rax
  8041601769:	42 0f b6 14 30       	movzbl (%rax,%r14,1),%edx
        count++;
  804160176e:	49 83 c6 01          	add    $0x1,%r14
    while (byte & 0x80) {
  8041601772:	84 d2                	test   %dl,%dl
  8041601774:	78 f3                	js     8041601769 <dwarf_read_abbrev_entry+0x8a7>
        entry += count;
  8041601776:	44 89 f0             	mov    %r14d,%eax
  8041601779:	48 01 c7             	add    %rax,%rdi
  804160177c:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
        uint32_t read = dwarf_read_abbrev_entry(entry, form, buf, bufsize, address_size);
  8041601780:	49 89 d8             	mov    %rbx,%r8
  8041601783:	44 89 e9             	mov    %r13d,%ecx
  8041601786:	4c 89 e2             	mov    %r12,%rdx
  8041601789:	48 b8 c2 0e 60 41 80 	movabs $0x8041600ec2,%rax
  8041601790:	00 00 00 
  8041601793:	ff d0                	call   *%rax
        bytes = count + read;
  8041601795:	44 01 f0             	add    %r14d,%eax
    } break;
  8041601798:	e9 a7 01 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
    case DW_FORM_sec_offset: {
        uint64_t length = 0;
        uint32_t count = dwarf_entry_len(entry, &length);
  804160179d:	4c 8b 75 b8          	mov    -0x48(%rbp),%r14
    uint64_t initial_len = get_unaligned(addr, uint32_t);
  80416017a1:	ba 04 00 00 00       	mov    $0x4,%edx
  80416017a6:	4c 89 f6             	mov    %r14,%rsi
  80416017a9:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416017ad:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416017b4:	00 00 00 
  80416017b7:	ff d0                	call   *%rax
  80416017b9:	8b 55 d0             	mov    -0x30(%rbp),%edx
    if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416017bc:	48 b8 10 00 00 00 ff 	movabs $0xffffffff00000010,%rax
  80416017c3:	ff ff ff 
  80416017c6:	48 01 d0             	add    %rdx,%rax
    uint64_t count = sizeof(uint32_t);
  80416017c9:	bb 04 00 00 00       	mov    $0x4,%ebx
    if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416017ce:	48 83 f8 0f          	cmp    $0xf,%rax
  80416017d2:	77 2f                	ja     8041601803 <dwarf_read_abbrev_entry+0x941>
        if (initial_len == DW_EXT_DWARF64) {
  80416017d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80416017d9:	48 39 c2             	cmp    %rax,%rdx
  80416017dc:	74 3b                	je     8041601819 <dwarf_read_abbrev_entry+0x957>
            cprintf("Unknown DWARF extension\n");
  80416017de:	48 bf 40 a4 60 41 80 	movabs $0x804160a440,%rdi
  80416017e5:	00 00 00 
  80416017e8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416017ed:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  80416017f4:	00 00 00 
  80416017f7:	ff d2                	call   *%rdx
        uint64_t length = 0;
  80416017f9:	ba 00 00 00 00       	mov    $0x0,%edx
            count = 0;
  80416017fe:	bb 00 00 00 00       	mov    $0x0,%ebx
        entry += count;
  8041601803:	48 01 5d b8          	add    %rbx,-0x48(%rbp)
        if (buf && bufsize >= sizeof(unsigned long))
  8041601807:	4d 85 e4             	test   %r12,%r12
  804160180a:	74 06                	je     8041601812 <dwarf_read_abbrev_entry+0x950>
  804160180c:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601810:	77 2b                	ja     804160183d <dwarf_read_abbrev_entry+0x97b>
            put_unaligned(length, (unsigned long *)buf);
        bytes = count;
  8041601812:	89 d8                	mov    %ebx,%eax
    } break;
  8041601814:	e9 2b 01 00 00       	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
            *len = get_unaligned((uint64_t *)addr + sizeof(uint32_t), uint64_t);
  8041601819:	49 8d 76 20          	lea    0x20(%r14),%rsi
  804160181d:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601822:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601826:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  804160182d:	00 00 00 
  8041601830:	ff d0                	call   *%rax
  8041601832:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
            count += sizeof(uint64_t);
  8041601836:	bb 0c 00 00 00       	mov    $0xc,%ebx
  804160183b:	eb c6                	jmp    8041601803 <dwarf_read_abbrev_entry+0x941>
            put_unaligned(length, (unsigned long *)buf);
  804160183d:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  8041601841:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601846:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160184a:	4c 89 e7             	mov    %r12,%rdi
  804160184d:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041601854:	00 00 00 
  8041601857:	ff d0                	call   *%rax
  8041601859:	eb b7                	jmp    8041601812 <dwarf_read_abbrev_entry+0x950>
    case DW_FORM_exprloc: {
        uint64_t length = 0;
        uint64_t count = dwarf_read_uleb128(entry, &length);
  804160185b:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  804160185f:	48 89 f0             	mov    %rsi,%rax
    size_t shift = 0, count = 0;
  8041601862:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041601867:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  804160186c:	41 be 00 00 00 00    	mov    $0x0,%r14d
        byte = *addr++;
  8041601872:	48 83 c0 01          	add    $0x1,%rax
  8041601876:	0f b6 78 ff          	movzbl -0x1(%rax),%edi
        result |= (byte & 0x7FULL) << shift;
  804160187a:	48 89 fa             	mov    %rdi,%rdx
  804160187d:	83 e2 7f             	and    $0x7f,%edx
  8041601880:	48 d3 e2             	shl    %cl,%rdx
  8041601883:	49 09 d6             	or     %rdx,%r14
        shift += 7;
  8041601886:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  804160188a:	48 89 da             	mov    %rbx,%rdx
  804160188d:	48 83 c3 01          	add    $0x1,%rbx
    } while (byte & 0x80 && shift < 64);
  8041601891:	40 84 ff             	test   %dil,%dil
  8041601894:	79 06                	jns    804160189c <dwarf_read_abbrev_entry+0x9da>
  8041601896:	48 83 f9 3f          	cmp    $0x3f,%rcx
  804160189a:	76 d6                	jbe    8041601872 <dwarf_read_abbrev_entry+0x9b0>
    while (byte & 0x80) {
  804160189c:	40 84 ff             	test   %dil,%dil
  804160189f:	79 12                	jns    80416018b3 <dwarf_read_abbrev_entry+0x9f1>
        byte = *addr++;
  80416018a1:	48 f7 d2             	not    %rdx
  80416018a4:	48 01 d0             	add    %rdx,%rax
  80416018a7:	0f b6 14 18          	movzbl (%rax,%rbx,1),%edx
        count++;
  80416018ab:	48 83 c3 01          	add    $0x1,%rbx
    while (byte & 0x80) {
  80416018af:	84 d2                	test   %dl,%dl
  80416018b1:	78 f4                	js     80416018a7 <dwarf_read_abbrev_entry+0x9e5>
        entry += count;
  80416018b3:	48 01 de             	add    %rbx,%rsi
  80416018b6:	48 89 75 b8          	mov    %rsi,-0x48(%rbp)
        if (buf) memcpy(buf, entry, MIN(length, bufsize));
  80416018ba:	4d 85 e4             	test   %r12,%r12
  80416018bd:	74 1c                	je     80416018db <dwarf_read_abbrev_entry+0xa19>
  80416018bf:	4d 63 ed             	movslq %r13d,%r13
  80416018c2:	4d 39 f5             	cmp    %r14,%r13
  80416018c5:	4c 89 ea             	mov    %r13,%rdx
  80416018c8:	49 0f 47 d6          	cmova  %r14,%rdx
  80416018cc:	4c 89 e7             	mov    %r12,%rdi
  80416018cf:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416018d6:	00 00 00 
  80416018d9:	ff d0                	call   *%rax
        entry += length;
        bytes = count + length;
  80416018db:	42 8d 04 33          	lea    (%rbx,%r14,1),%eax
    } break;
  80416018df:	eb 63                	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
    case DW_FORM_flag_present:
        if (buf && sizeof(buf) >= sizeof(bool)) {
            put_unaligned(true, (bool *)buf);
        }
        bytes = 0;
  80416018e1:	b8 00 00 00 00       	mov    $0x0,%eax
        if (buf && sizeof(buf) >= sizeof(bool)) {
  80416018e6:	48 85 d2             	test   %rdx,%rdx
  80416018e9:	74 59                	je     8041601944 <dwarf_read_abbrev_entry+0xa82>
            put_unaligned(true, (bool *)buf);
  80416018eb:	c6 02 01             	movb   $0x1,(%rdx)
  80416018ee:	eb 54                	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
        break;
    case DW_FORM_ref_sig8: {
        uint64_t data = get_unaligned(entry, uint64_t);
  80416018f0:	ba 08 00 00 00       	mov    $0x8,%edx
  80416018f5:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  80416018f9:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416018fd:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041601904:	00 00 00 
  8041601907:	ff d0                	call   *%rax
        entry += sizeof(uint64_t);
  8041601909:	48 83 45 b8 08       	addq   $0x8,-0x48(%rbp)
        if (buf && bufsize >= sizeof(uint64_t))
  804160190e:	4d 85 e4             	test   %r12,%r12
  8041601911:	74 06                	je     8041601919 <dwarf_read_abbrev_entry+0xa57>
  8041601913:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601917:	77 07                	ja     8041601920 <dwarf_read_abbrev_entry+0xa5e>
            put_unaligned(data, (uint64_t *)buf);
        bytes = sizeof(uint64_t);
  8041601919:	b8 08 00 00 00       	mov    $0x8,%eax
    } break;
    }
    return bytes;
  804160191e:	eb 24                	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
            put_unaligned(data, (uint64_t *)buf);
  8041601920:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601925:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601929:	4c 89 e7             	mov    %r12,%rdi
  804160192c:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041601933:	00 00 00 
  8041601936:	ff d0                	call   *%rax
        bytes = sizeof(uint64_t);
  8041601938:	b8 08 00 00 00       	mov    $0x8,%eax
            put_unaligned(data, (uint64_t *)buf);
  804160193d:	eb 05                	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
    switch (form) {
  804160193f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041601944:	48 83 c4 30          	add    $0x30,%rsp
  8041601948:	5b                   	pop    %rbx
  8041601949:	41 5c                	pop    %r12
  804160194b:	41 5d                	pop    %r13
  804160194d:	41 5e                	pop    %r14
  804160194f:	5d                   	pop    %rbp
  8041601950:	c3                   	ret    
        bytes = sizeof(Dwarf_Small);
  8041601951:	b8 01 00 00 00       	mov    $0x1,%eax
  8041601956:	eb ec                	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
        bytes = sizeof(Dwarf_Small);
  8041601958:	b8 01 00 00 00       	mov    $0x1,%eax
  804160195d:	eb e5                	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>
        bytes = sizeof(Dwarf_Small);
  804160195f:	b8 01 00 00 00       	mov    $0x1,%eax
  8041601964:	eb de                	jmp    8041601944 <dwarf_read_abbrev_entry+0xa82>

0000008041601966 <info_by_address>:
    return -E_NO_ENT;
}

//?
int
info_by_address(const struct Dwarf_Addrs *addrs, uintptr_t addr, Dwarf_Off *store) {
  8041601966:	f3 0f 1e fa          	endbr64 
  804160196a:	55                   	push   %rbp
  804160196b:	48 89 e5             	mov    %rsp,%rbp
  804160196e:	41 57                	push   %r15
  8041601970:	41 56                	push   %r14
  8041601972:	41 55                	push   %r13
  8041601974:	41 54                	push   %r12
  8041601976:	53                   	push   %rbx
  8041601977:	48 83 ec 48          	sub    $0x48,%rsp
  804160197b:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  804160197f:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  8041601983:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
    const uint8_t *set = addrs->aranges_begin;
  8041601987:	48 8b 5f 10          	mov    0x10(%rdi),%rbx
    while ((unsigned char *)set < addrs->aranges_end) {
  804160198b:	48 3b 5f 18          	cmp    0x18(%rdi),%rbx
  804160198f:	72 25                	jb     80416019b6 <info_by_address+0x50>
    const uint8_t *entry = addrs->info_begin;
  8041601991:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041601995:	48 8b 58 20          	mov    0x20(%rax),%rbx
  8041601999:	48 89 5d b8          	mov    %rbx,-0x48(%rbp)
    while (entry < addrs->info_end) {
  804160199d:	48 39 58 28          	cmp    %rbx,0x28(%rax)
  80416019a1:	0f 86 b4 03 00 00    	jbe    8041601d5b <info_by_address+0x3f5>
                entry += dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);
  80416019a7:	49 bf c2 0e 60 41 80 	movabs $0x8041600ec2,%r15
  80416019ae:	00 00 00 
  80416019b1:	e9 df 02 00 00       	jmp    8041601c95 <info_by_address+0x32f>
    uint64_t initial_len = get_unaligned(addr, uint32_t);
  80416019b6:	ba 04 00 00 00       	mov    $0x4,%edx
  80416019bb:	48 89 de             	mov    %rbx,%rsi
  80416019be:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416019c2:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416019c9:	00 00 00 
  80416019cc:	ff d0                	call   *%rax
  80416019ce:	8b 55 c8             	mov    -0x38(%rbp),%edx
    if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416019d1:	48 b8 10 00 00 00 ff 	movabs $0xffffffff00000010,%rax
  80416019d8:	ff ff ff 
  80416019db:	48 01 d0             	add    %rdx,%rax
  80416019de:	48 83 f8 0f          	cmp    $0xf,%rax
  80416019e2:	77 ad                	ja     8041601991 <info_by_address+0x2b>
        if (initial_len == DW_EXT_DWARF64) {
  80416019e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80416019e9:	48 39 c2             	cmp    %rax,%rdx
  80416019ec:	74 1d                	je     8041601a0b <info_by_address+0xa5>
            cprintf("Unknown DWARF extension\n");
  80416019ee:	48 bf 40 a4 60 41 80 	movabs $0x804160a440,%rdi
  80416019f5:	00 00 00 
  80416019f8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416019fd:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  8041601a04:	00 00 00 
  8041601a07:	ff d2                	call   *%rdx
            count = 0;
  8041601a09:	eb 86                	jmp    8041601991 <info_by_address+0x2b>
            *len = get_unaligned((uint64_t *)addr + sizeof(uint32_t), uint64_t);
  8041601a0b:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041601a0f:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601a14:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601a18:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041601a1f:	00 00 00 
  8041601a22:	ff d0                	call   *%rax
            count += sizeof(uint64_t);
  8041601a24:	e9 68 ff ff ff       	jmp    8041601991 <info_by_address+0x2b>
            *len = get_unaligned((uint64_t *)addr + sizeof(uint32_t), uint64_t);
  8041601a29:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041601a2d:	48 8d 70 20          	lea    0x20(%rax),%rsi
  8041601a31:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601a36:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601a3a:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041601a41:	00 00 00 
  8041601a44:	ff d0                	call   *%rax
  8041601a46:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
            count += sizeof(uint64_t);
  8041601a4a:	41 bc 0c 00 00 00    	mov    $0xc,%r12d
  8041601a50:	e9 13 03 00 00       	jmp    8041601d68 <info_by_address+0x402>
        assert(version == 4 || version == 2);
  8041601a55:	48 b9 59 a4 60 41 80 	movabs $0x804160a459,%rcx
  8041601a5c:	00 00 00 
  8041601a5f:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041601a66:	00 00 00 
  8041601a69:	be 1f 01 00 00       	mov    $0x11f,%esi
  8041601a6e:	48 bf 8b a4 60 41 80 	movabs $0x804160a48b,%rdi
  8041601a75:	00 00 00 
  8041601a78:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601a7d:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041601a84:	00 00 00 
  8041601a87:	41 ff d0             	call   *%r8
        assert(address_size == sizeof(uintptr_t));
  8041601a8a:	48 b9 c8 a5 60 41 80 	movabs $0x804160a5c8,%rcx
  8041601a91:	00 00 00 
  8041601a94:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041601a9b:	00 00 00 
  8041601a9e:	be 24 01 00 00       	mov    $0x124,%esi
  8041601aa3:	48 bf 8b a4 60 41 80 	movabs $0x804160a48b,%rdi
  8041601aaa:	00 00 00 
  8041601aad:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601ab2:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041601ab9:	00 00 00 
  8041601abc:	41 ff d0             	call   *%r8
        assert(abbrev_code);
  8041601abf:	48 b9 98 a4 60 41 80 	movabs $0x804160a498,%rcx
  8041601ac6:	00 00 00 
  8041601ac9:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041601ad0:	00 00 00 
  8041601ad3:	be 29 01 00 00       	mov    $0x129,%esi
  8041601ad8:	48 bf 8b a4 60 41 80 	movabs $0x804160a48b,%rdi
  8041601adf:	00 00 00 
  8041601ae2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601ae7:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041601aee:	00 00 00 
  8041601af1:	41 ff d0             	call   *%r8
        assert(table_abbrev_code == abbrev_code);
  8041601af4:	48 b9 f0 a5 60 41 80 	movabs $0x804160a5f0,%rcx
  8041601afb:	00 00 00 
  8041601afe:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041601b05:	00 00 00 
  8041601b08:	be 2f 01 00 00       	mov    $0x12f,%esi
  8041601b0d:	48 bf 8b a4 60 41 80 	movabs $0x804160a48b,%rdi
  8041601b14:	00 00 00 
  8041601b17:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601b1c:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041601b23:	00 00 00 
  8041601b26:	41 ff d0             	call   *%r8
        assert(tag == DW_TAG_compile_unit);
  8041601b29:	48 b9 a4 a4 60 41 80 	movabs $0x804160a4a4,%rcx
  8041601b30:	00 00 00 
  8041601b33:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041601b3a:	00 00 00 
  8041601b3d:	be 32 01 00 00       	mov    $0x132,%esi
  8041601b42:	48 bf 8b a4 60 41 80 	movabs $0x804160a48b,%rdi
  8041601b49:	00 00 00 
  8041601b4c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601b51:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041601b58:	00 00 00 
  8041601b5b:	41 ff d0             	call   *%r8
                entry += dwarf_read_abbrev_entry(entry, form, &low_pc, sizeof(low_pc), address_size);
  8041601b5e:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601b64:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601b69:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041601b6d:	44 89 e6             	mov    %r12d,%esi
  8041601b70:	4c 89 f7             	mov    %r14,%rdi
  8041601b73:	41 ff d7             	call   *%r15
  8041601b76:	48 98                	cltq   
  8041601b78:	49 01 c6             	add    %rax,%r14
    uint64_t result = 0;
  8041601b7b:	48 89 da             	mov    %rbx,%rdx
    size_t shift = 0, count = 0;
  8041601b7e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601b83:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041601b88:	41 bd 00 00 00 00    	mov    $0x0,%r13d
        byte = *addr++;
  8041601b8e:	48 83 c2 01          	add    $0x1,%rdx
  8041601b92:	0f b6 7a ff          	movzbl -0x1(%rdx),%edi
        result |= (byte & 0x7FULL) << shift;
  8041601b96:	48 89 fe             	mov    %rdi,%rsi
  8041601b99:	83 e6 7f             	and    $0x7f,%esi
  8041601b9c:	48 d3 e6             	shl    %cl,%rsi
  8041601b9f:	49 09 f5             	or     %rsi,%r13
        shift += 7;
  8041601ba2:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041601ba6:	48 89 c6             	mov    %rax,%rsi
  8041601ba9:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  8041601bad:	40 84 ff             	test   %dil,%dil
  8041601bb0:	79 06                	jns    8041601bb8 <info_by_address+0x252>
  8041601bb2:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041601bb6:	76 d6                	jbe    8041601b8e <info_by_address+0x228>
    while (byte & 0x80) {
  8041601bb8:	40 84 ff             	test   %dil,%dil
  8041601bbb:	79 12                	jns    8041601bcf <info_by_address+0x269>
        byte = *addr++;
  8041601bbd:	48 f7 d6             	not    %rsi
  8041601bc0:	48 01 f2             	add    %rsi,%rdx
  8041601bc3:	0f b6 0c 02          	movzbl (%rdx,%rax,1),%ecx
        count++;
  8041601bc7:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  8041601bcb:	84 c9                	test   %cl,%cl
  8041601bcd:	78 f4                	js     8041601bc3 <info_by_address+0x25d>
            abbrev_entry += dwarf_read_uleb128(abbrev_entry, &name);
  8041601bcf:	48 8d 14 03          	lea    (%rbx,%rax,1),%rdx
  8041601bd3:	48 89 d6             	mov    %rdx,%rsi
    size_t shift = 0, count = 0;
  8041601bd6:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601bdb:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041601be0:	41 bc 00 00 00 00    	mov    $0x0,%r12d
        byte = *addr++;
  8041601be6:	48 83 c6 01          	add    $0x1,%rsi
  8041601bea:	44 0f b6 46 ff       	movzbl -0x1(%rsi),%r8d
        result |= (byte & 0x7FULL) << shift;
  8041601bef:	4c 89 c7             	mov    %r8,%rdi
  8041601bf2:	83 e7 7f             	and    $0x7f,%edi
  8041601bf5:	48 d3 e7             	shl    %cl,%rdi
  8041601bf8:	49 09 fc             	or     %rdi,%r12
        shift += 7;
  8041601bfb:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041601bff:	48 89 c7             	mov    %rax,%rdi
  8041601c02:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  8041601c06:	45 84 c0             	test   %r8b,%r8b
  8041601c09:	79 06                	jns    8041601c11 <info_by_address+0x2ab>
  8041601c0b:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041601c0f:	76 d5                	jbe    8041601be6 <info_by_address+0x280>
    while (byte & 0x80) {
  8041601c11:	45 84 c0             	test   %r8b,%r8b
  8041601c14:	79 12                	jns    8041601c28 <info_by_address+0x2c2>
        byte = *addr++;
  8041601c16:	48 f7 d7             	not    %rdi
  8041601c19:	48 01 fe             	add    %rdi,%rsi
  8041601c1c:	0f b6 0c 06          	movzbl (%rsi,%rax,1),%ecx
        count++;
  8041601c20:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  8041601c24:	84 c9                	test   %cl,%cl
  8041601c26:	78 f4                	js     8041601c1c <info_by_address+0x2b6>
            abbrev_entry += dwarf_read_uleb128(abbrev_entry, &form);
  8041601c28:	48 8d 1c 02          	lea    (%rdx,%rax,1),%rbx
            if (name == DW_AT_low_pc) {
  8041601c2c:	49 83 fd 11          	cmp    $0x11,%r13
  8041601c30:	0f 84 28 ff ff ff    	je     8041601b5e <info_by_address+0x1f8>
            } else if (name == DW_AT_high_pc) {
  8041601c36:	49 83 fd 12          	cmp    $0x12,%r13
  8041601c3a:	0f 84 c6 00 00 00    	je     8041601d06 <info_by_address+0x3a0>
                entry += dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);
  8041601c40:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601c46:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601c4b:	ba 00 00 00 00       	mov    $0x0,%edx
  8041601c50:	44 89 e6             	mov    %r12d,%esi
  8041601c53:	4c 89 f7             	mov    %r14,%rdi
  8041601c56:	41 ff d7             	call   *%r15
  8041601c59:	48 98                	cltq   
  8041601c5b:	49 01 c6             	add    %rax,%r14
        } while (name || form);
  8041601c5e:	4d 09 ec             	or     %r13,%r12
  8041601c61:	0f 85 14 ff ff ff    	jne    8041601b7b <info_by_address+0x215>
        if (p >= low_pc && p <= high_pc) {
  8041601c67:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041601c6b:	48 3b 45 c0          	cmp    -0x40(%rbp),%rax
  8041601c6f:	72 0a                	jb     8041601c7b <info_by_address+0x315>
  8041601c71:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  8041601c75:	0f 86 bf 00 00 00    	jbe    8041601d3a <info_by_address+0x3d4>
    while (entry < addrs->info_end) {
  8041601c7b:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041601c7f:	48 8b 5d b0          	mov    -0x50(%rbp),%rbx
  8041601c83:	48 3b 58 28          	cmp    0x28(%rax),%rbx
  8041601c87:	0f 83 c7 00 00 00    	jae    8041601d54 <info_by_address+0x3ee>
        entry = entry_end;
  8041601c8d:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041601c91:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    uint64_t initial_len = get_unaligned(addr, uint32_t);
  8041601c95:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601c9a:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  8041601c9e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601ca2:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041601ca9:	00 00 00 
  8041601cac:	ff d0                	call   *%rax
  8041601cae:	8b 45 c8             	mov    -0x38(%rbp),%eax
    if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601cb1:	48 bb 10 00 00 00 ff 	movabs $0xffffffff00000010,%rbx
  8041601cb8:	ff ff ff 
  8041601cbb:	48 8d 14 18          	lea    (%rax,%rbx,1),%rdx
  8041601cbf:	48 83 fa 0f          	cmp    $0xf,%rdx
  8041601cc3:	0f 87 99 00 00 00    	ja     8041601d62 <info_by_address+0x3fc>
        if (initial_len == DW_EXT_DWARF64) {
  8041601cc9:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8041601cce:	48 39 d0             	cmp    %rdx,%rax
  8041601cd1:	0f 84 52 fd ff ff    	je     8041601a29 <info_by_address+0xc3>
            cprintf("Unknown DWARF extension\n");
  8041601cd7:	48 bf 40 a4 60 41 80 	movabs $0x804160a440,%rdi
  8041601cde:	00 00 00 
  8041601ce1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601ce6:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  8041601ced:	00 00 00 
  8041601cf0:	ff d2                	call   *%rdx
        if (!count) return -E_BAD_DWARF;
  8041601cf2:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
    int res = info_by_address_debug_aranges(addrs, addr, store);
    if (res < 0) res = info_by_address_debug_info(addrs, addr, store);
    return res;
}
  8041601cf7:	48 83 c4 48          	add    $0x48,%rsp
  8041601cfb:	5b                   	pop    %rbx
  8041601cfc:	41 5c                	pop    %r12
  8041601cfe:	41 5d                	pop    %r13
  8041601d00:	41 5e                	pop    %r14
  8041601d02:	41 5f                	pop    %r15
  8041601d04:	5d                   	pop    %rbp
  8041601d05:	c3                   	ret    
                entry += dwarf_read_abbrev_entry(entry, form, &high_pc, sizeof(high_pc), address_size);
  8041601d06:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601d0c:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601d11:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041601d15:	44 89 e6             	mov    %r12d,%esi
  8041601d18:	4c 89 f7             	mov    %r14,%rdi
  8041601d1b:	41 ff d7             	call   *%r15
  8041601d1e:	48 98                	cltq   
  8041601d20:	49 01 c6             	add    %rax,%r14
                if (form != DW_FORM_addr) high_pc += low_pc;
  8041601d23:	49 83 fc 01          	cmp    $0x1,%r12
  8041601d27:	0f 84 4e fe ff ff    	je     8041601b7b <info_by_address+0x215>
  8041601d2d:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8041601d31:	48 01 45 c8          	add    %rax,-0x38(%rbp)
  8041601d35:	e9 41 fe ff ff       	jmp    8041601b7b <info_by_address+0x215>
            *store = (const unsigned char *)header - addrs->info_begin;
  8041601d3a:	48 8b 5d a8          	mov    -0x58(%rbp),%rbx
  8041601d3e:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041601d42:	48 2b 43 20          	sub    0x20(%rbx),%rax
  8041601d46:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
  8041601d4a:	48 89 03             	mov    %rax,(%rbx)
            return 0;
  8041601d4d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601d52:	eb a3                	jmp    8041601cf7 <info_by_address+0x391>
    return -E_NO_ENT;
  8041601d54:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8041601d59:	eb 9c                	jmp    8041601cf7 <info_by_address+0x391>
  8041601d5b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
    return res;
  8041601d60:	eb 95                	jmp    8041601cf7 <info_by_address+0x391>
    uint64_t count = sizeof(uint32_t);
  8041601d62:	41 bc 04 00 00 00    	mov    $0x4,%r12d
        entry += count = dwarf_entry_len(entry, &len);
  8041601d68:	4c 03 65 b8          	add    -0x48(%rbp),%r12
        const uint8_t *entry_end = entry + len;
  8041601d6c:	4c 01 e0             	add    %r12,%rax
  8041601d6f:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
        Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041601d73:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601d78:	4c 89 e6             	mov    %r12,%rsi
  8041601d7b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601d7f:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041601d86:	00 00 00 
  8041601d89:	ff d0                	call   *%rax
        entry += sizeof(Dwarf_Half);
  8041601d8b:	49 8d 74 24 02       	lea    0x2(%r12),%rsi
        assert(version == 4 || version == 2);
  8041601d90:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041601d94:	83 e8 02             	sub    $0x2,%eax
  8041601d97:	66 a9 fd ff          	test   $0xfffd,%ax
  8041601d9b:	0f 85 b4 fc ff ff    	jne    8041601a55 <info_by_address+0xef>
        Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041601da1:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601da6:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601daa:	49 be 77 94 60 41 80 	movabs $0x8041609477,%r14
  8041601db1:	00 00 00 
  8041601db4:	41 ff d6             	call   *%r14
  8041601db7:	8b 5d c8             	mov    -0x38(%rbp),%ebx
        entry += sizeof(uint32_t);
  8041601dba:	49 8d 74 24 06       	lea    0x6(%r12),%rsi
        Dwarf_Small address_size = get_unaligned(entry, Dwarf_Small);
  8041601dbf:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601dc4:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601dc8:	41 ff d6             	call   *%r14
        entry += sizeof(Dwarf_Small);
  8041601dcb:	4d 8d 74 24 07       	lea    0x7(%r12),%r14
        assert(address_size == sizeof(uintptr_t));
  8041601dd0:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041601dd4:	0f 85 b0 fc ff ff    	jne    8041601a8a <info_by_address+0x124>
  8041601dda:	4c 89 f0             	mov    %r14,%rax
    size_t shift = 0, count = 0;
  8041601ddd:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041601de2:	be 00 00 00 00       	mov    $0x0,%esi
        byte = *addr++;
  8041601de7:	48 83 c0 01          	add    $0x1,%rax
  8041601deb:	0f b6 78 ff          	movzbl -0x1(%rax),%edi
        result |= (byte & 0x7FULL) << shift;
  8041601def:	48 89 fa             	mov    %rdi,%rdx
  8041601df2:	83 e2 7f             	and    $0x7f,%edx
  8041601df5:	48 d3 e2             	shl    %cl,%rdx
  8041601df8:	48 09 d6             	or     %rdx,%rsi
        shift += 7;
  8041601dfb:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041601dff:	4c 8d 40 f9          	lea    -0x7(%rax),%r8
  8041601e03:	4c 89 c2             	mov    %r8,%rdx
  8041601e06:	4c 29 e2             	sub    %r12,%rdx
    } while (byte & 0x80 && shift < 64);
  8041601e09:	40 84 ff             	test   %dil,%dil
  8041601e0c:	79 06                	jns    8041601e14 <info_by_address+0x4ae>
  8041601e0e:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041601e12:	76 d3                	jbe    8041601de7 <info_by_address+0x481>
    while (byte & 0x80) {
  8041601e14:	40 84 ff             	test   %dil,%dil
  8041601e17:	79 12                	jns    8041601e2b <info_by_address+0x4c5>
        byte = *addr++;
  8041601e19:	4d 29 c4             	sub    %r8,%r12
  8041601e1c:	4c 01 e0             	add    %r12,%rax
  8041601e1f:	0f b6 0c 10          	movzbl (%rax,%rdx,1),%ecx
        count++;
  8041601e23:	48 83 c2 01          	add    $0x1,%rdx
    while (byte & 0x80) {
  8041601e27:	84 c9                	test   %cl,%cl
  8041601e29:	78 f4                	js     8041601e1f <info_by_address+0x4b9>
        entry += dwarf_read_uleb128(entry, &abbrev_code);
  8041601e2b:	49 01 d6             	add    %rdx,%r14
        assert(abbrev_code);
  8041601e2e:	48 85 f6             	test   %rsi,%rsi
  8041601e31:	0f 84 88 fc ff ff    	je     8041601abf <info_by_address+0x159>
        const uint8_t *abbrev_entry = addrs->abbrev_begin + abbrev_offset;
  8041601e37:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041601e3b:	48 03 18             	add    (%rax),%rbx
  8041601e3e:	48 89 da             	mov    %rbx,%rdx
    size_t shift = 0, count = 0;
  8041601e41:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601e46:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041601e4b:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        byte = *addr++;
  8041601e51:	48 83 c2 01          	add    $0x1,%rdx
  8041601e55:	44 0f b6 4a ff       	movzbl -0x1(%rdx),%r9d
        result |= (byte & 0x7FULL) << shift;
  8041601e5a:	4c 89 cf             	mov    %r9,%rdi
  8041601e5d:	83 e7 7f             	and    $0x7f,%edi
  8041601e60:	48 d3 e7             	shl    %cl,%rdi
  8041601e63:	49 09 f8             	or     %rdi,%r8
        shift += 7;
  8041601e66:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041601e6a:	48 89 c7             	mov    %rax,%rdi
  8041601e6d:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  8041601e71:	45 84 c9             	test   %r9b,%r9b
  8041601e74:	79 06                	jns    8041601e7c <info_by_address+0x516>
  8041601e76:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041601e7a:	76 d5                	jbe    8041601e51 <info_by_address+0x4eb>
    while (byte & 0x80) {
  8041601e7c:	45 84 c9             	test   %r9b,%r9b
  8041601e7f:	79 12                	jns    8041601e93 <info_by_address+0x52d>
        byte = *addr++;
  8041601e81:	48 f7 d7             	not    %rdi
  8041601e84:	48 01 fa             	add    %rdi,%rdx
  8041601e87:	0f b6 0c 02          	movzbl (%rdx,%rax,1),%ecx
        count++;
  8041601e8b:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  8041601e8f:	84 c9                	test   %cl,%cl
  8041601e91:	78 f4                	js     8041601e87 <info_by_address+0x521>
        abbrev_entry += dwarf_read_uleb128(abbrev_entry, &table_abbrev_code);
  8041601e93:	48 8d 3c 03          	lea    (%rbx,%rax,1),%rdi
        assert(table_abbrev_code == abbrev_code);
  8041601e97:	4c 39 c6             	cmp    %r8,%rsi
  8041601e9a:	0f 85 54 fc ff ff    	jne    8041601af4 <info_by_address+0x18e>
  8041601ea0:	48 89 fa             	mov    %rdi,%rdx
    size_t shift = 0, count = 0;
  8041601ea3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601ea8:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041601ead:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        byte = *addr++;
  8041601eb3:	48 83 c2 01          	add    $0x1,%rdx
  8041601eb7:	44 0f b6 4a ff       	movzbl -0x1(%rdx),%r9d
        result |= (byte & 0x7FULL) << shift;
  8041601ebc:	4c 89 ce             	mov    %r9,%rsi
  8041601ebf:	83 e6 7f             	and    $0x7f,%esi
  8041601ec2:	48 d3 e6             	shl    %cl,%rsi
  8041601ec5:	49 09 f0             	or     %rsi,%r8
        shift += 7;
  8041601ec8:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041601ecc:	48 89 c6             	mov    %rax,%rsi
  8041601ecf:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  8041601ed3:	45 84 c9             	test   %r9b,%r9b
  8041601ed6:	79 06                	jns    8041601ede <info_by_address+0x578>
  8041601ed8:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041601edc:	76 d5                	jbe    8041601eb3 <info_by_address+0x54d>
    while (byte & 0x80) {
  8041601ede:	45 84 c9             	test   %r9b,%r9b
  8041601ee1:	79 12                	jns    8041601ef5 <info_by_address+0x58f>
        byte = *addr++;
  8041601ee3:	48 f7 d6             	not    %rsi
  8041601ee6:	48 01 f2             	add    %rsi,%rdx
  8041601ee9:	0f b6 0c 02          	movzbl (%rdx,%rax,1),%ecx
        count++;
  8041601eed:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  8041601ef1:	84 c9                	test   %cl,%cl
  8041601ef3:	78 f4                	js     8041601ee9 <info_by_address+0x583>
        assert(tag == DW_TAG_compile_unit);
  8041601ef5:	49 83 f8 11          	cmp    $0x11,%r8
  8041601ef9:	0f 85 2a fc ff ff    	jne    8041601b29 <info_by_address+0x1c3>
        abbrev_entry += sizeof(Dwarf_Small);
  8041601eff:	48 8d 5c 07 01       	lea    0x1(%rdi,%rax,1),%rbx
        uintptr_t low_pc = 0, high_pc = 0;
  8041601f04:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041601f0b:	00 
  8041601f0c:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041601f13:	00 
  8041601f14:	e9 62 fc ff ff       	jmp    8041601b7b <info_by_address+0x215>

0000008041601f19 <file_name_by_info>:
                              
int
file_name_by_info(const struct Dwarf_Addrs *addrs, Dwarf_Off offset, char **buf, Dwarf_Off *line_off) {
  8041601f19:	f3 0f 1e fa          	endbr64 
  8041601f1d:	55                   	push   %rbp
  8041601f1e:	48 89 e5             	mov    %rsp,%rbp
  8041601f21:	41 57                	push   %r15
  8041601f23:	41 56                	push   %r14
  8041601f25:	41 55                	push   %r13
  8041601f27:	41 54                	push   %r12
  8041601f29:	53                   	push   %rbx
  8041601f2a:	48 83 ec 38          	sub    $0x38,%rsp
  8041601f2e:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  8041601f32:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  8041601f36:	48 89 4d b0          	mov    %rcx,-0x50(%rbp)
    if (offset > addrs->info_end - addrs->info_begin) return -E_INVAL;
  8041601f3a:	48 8b 5f 20          	mov    0x20(%rdi),%rbx
  8041601f3e:	48 8b 47 28          	mov    0x28(%rdi),%rax
  8041601f42:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
  8041601f46:	48 29 d8             	sub    %rbx,%rax
  8041601f49:	48 39 f0             	cmp    %rsi,%rax
  8041601f4c:	0f 82 34 03 00 00    	jb     8041602286 <file_name_by_info+0x36d>

    const uint8_t *entry = addrs->info_begin + offset;
  8041601f52:	48 01 f3             	add    %rsi,%rbx
    uint64_t initial_len = get_unaligned(addr, uint32_t);
  8041601f55:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601f5a:	48 89 de             	mov    %rbx,%rsi
  8041601f5d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601f61:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041601f68:	00 00 00 
  8041601f6b:	ff d0                	call   *%rax
  8041601f6d:	8b 55 c8             	mov    -0x38(%rbp),%edx
    if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601f70:	48 b8 10 00 00 00 ff 	movabs $0xffffffff00000010,%rax
  8041601f77:	ff ff ff 
  8041601f7a:	48 01 d0             	add    %rdx,%rax
  8041601f7d:	48 83 f8 0f          	cmp    $0xf,%rax
  8041601f81:	0f 87 09 03 00 00    	ja     8041602290 <file_name_by_info+0x377>
        if (initial_len == DW_EXT_DWARF64) {
  8041601f87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8041601f8c:	48 39 c2             	cmp    %rax,%rdx
  8041601f8f:	74 25                	je     8041601fb6 <file_name_by_info+0x9d>
            cprintf("Unknown DWARF extension\n");
  8041601f91:	48 bf 40 a4 60 41 80 	movabs $0x804160a440,%rdi
  8041601f98:	00 00 00 
  8041601f9b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601fa0:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  8041601fa7:	00 00 00 
  8041601faa:	ff d2                	call   *%rdx
    uint32_t count;
    uint64_t len = 0;
    entry += count = dwarf_entry_len(entry, &len);
    if (!count) return -E_BAD_DWARF;
  8041601fac:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  8041601fb1:	e9 41 02 00 00       	jmp    80416021f7 <file_name_by_info+0x2de>
            *len = get_unaligned((uint64_t *)addr + sizeof(uint32_t), uint64_t);
  8041601fb6:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041601fba:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601fbf:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601fc3:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041601fca:	00 00 00 
  8041601fcd:	ff d0                	call   *%rax
            count += sizeof(uint64_t);
  8041601fcf:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041601fd4:	e9 bc 02 00 00       	jmp    8041602295 <file_name_by_info+0x37c>

    /* Parse compilation unit header */
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
    entry += sizeof(Dwarf_Half);
    assert(version == 4 || version == 2);
  8041601fd9:	48 b9 59 a4 60 41 80 	movabs $0x804160a459,%rcx
  8041601fe0:	00 00 00 
  8041601fe3:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041601fea:	00 00 00 
  8041601fed:	be 63 01 00 00       	mov    $0x163,%esi
  8041601ff2:	48 bf 8b a4 60 41 80 	movabs $0x804160a48b,%rdi
  8041601ff9:	00 00 00 
  8041601ffc:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602001:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041602008:	00 00 00 
  804160200b:	41 ff d0             	call   *%r8
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
    entry += sizeof(uint32_t);
    Dwarf_Small address_size = get_unaligned(entry, Dwarf_Small);
    entry += sizeof(Dwarf_Small);
    assert(address_size == sizeof(uintptr_t));
  804160200e:	48 b9 c8 a5 60 41 80 	movabs $0x804160a5c8,%rcx
  8041602015:	00 00 00 
  8041602018:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  804160201f:	00 00 00 
  8041602022:	be 68 01 00 00       	mov    $0x168,%esi
  8041602027:	48 bf 8b a4 60 41 80 	movabs $0x804160a48b,%rdi
  804160202e:	00 00 00 
  8041602031:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602036:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  804160203d:	00 00 00 
  8041602040:	41 ff d0             	call   *%r8

    /* Read abbreviation code */
    uint64_t abbrev_code = 0;
    entry += dwarf_read_uleb128(entry, &abbrev_code);
    assert(abbrev_code);
  8041602043:	48 b9 98 a4 60 41 80 	movabs $0x804160a498,%rcx
  804160204a:	00 00 00 
  804160204d:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041602054:	00 00 00 
  8041602057:	be 6d 01 00 00       	mov    $0x16d,%esi
  804160205c:	48 bf 8b a4 60 41 80 	movabs $0x804160a48b,%rdi
  8041602063:	00 00 00 
  8041602066:	b8 00 00 00 00       	mov    $0x0,%eax
  804160206b:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041602072:	00 00 00 
  8041602075:	41 ff d0             	call   *%r8

    /* Read abbreviations table */
    const uint8_t *abbrev_entry = addrs->abbrev_begin + abbrev_offset;
    uint64_t table_abbrev_code = 0;
    abbrev_entry += dwarf_read_uleb128(abbrev_entry, &table_abbrev_code);
    assert(table_abbrev_code == abbrev_code);
  8041602078:	48 b9 f0 a5 60 41 80 	movabs $0x804160a5f0,%rcx
  804160207f:	00 00 00 
  8041602082:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041602089:	00 00 00 
  804160208c:	be 73 01 00 00       	mov    $0x173,%esi
  8041602091:	48 bf 8b a4 60 41 80 	movabs $0x804160a48b,%rdi
  8041602098:	00 00 00 
  804160209b:	b8 00 00 00 00       	mov    $0x0,%eax
  80416020a0:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  80416020a7:	00 00 00 
  80416020aa:	41 ff d0             	call   *%r8
    uint64_t tag = 0;
    abbrev_entry += dwarf_read_uleb128(abbrev_entry, &tag);
    assert(tag == DW_TAG_compile_unit);
  80416020ad:	48 b9 a4 a4 60 41 80 	movabs $0x804160a4a4,%rcx
  80416020b4:	00 00 00 
  80416020b7:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  80416020be:	00 00 00 
  80416020c1:	be 76 01 00 00       	mov    $0x176,%esi
  80416020c6:	48 bf 8b a4 60 41 80 	movabs $0x804160a48b,%rdi
  80416020cd:	00 00 00 
  80416020d0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416020d5:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  80416020dc:	00 00 00 
  80416020df:	41 ff d0             	call   *%r8
    uint64_t name = 0, form = 0;
    do {
        abbrev_entry += dwarf_read_uleb128(abbrev_entry, &name);
        abbrev_entry += dwarf_read_uleb128(abbrev_entry, &form);
        if (name == DW_AT_name) {
            if (form == DW_FORM_strp) {
  80416020e2:	49 83 fc 0e          	cmp    $0xe,%r12
  80416020e6:	0f 84 1a 01 00 00    	je     8041602206 <file_name_by_info+0x2ed>
                uint64_t offset = 0;
                entry += dwarf_read_abbrev_entry(entry, form, &offset, sizeof(uint64_t), address_size);
                if (buf) put_unaligned((const uint8_t *)addrs->str_begin + offset, buf);
            } else {
                entry += dwarf_read_abbrev_entry(entry, form, buf, sizeof(char *), address_size);
  80416020ec:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416020f2:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416020f7:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  80416020fb:	44 89 e6             	mov    %r12d,%esi
  80416020fe:	4c 89 f7             	mov    %r14,%rdi
  8041602101:	41 ff d7             	call   *%r15
  8041602104:	48 98                	cltq   
  8041602106:	49 01 c6             	add    %rax,%r14
    uint64_t result = 0;
  8041602109:	48 89 da             	mov    %rbx,%rdx
    size_t shift = 0, count = 0;
  804160210c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602111:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041602116:	41 bd 00 00 00 00    	mov    $0x0,%r13d
        byte = *addr++;
  804160211c:	48 83 c2 01          	add    $0x1,%rdx
  8041602120:	0f b6 7a ff          	movzbl -0x1(%rdx),%edi
        result |= (byte & 0x7FULL) << shift;
  8041602124:	48 89 fe             	mov    %rdi,%rsi
  8041602127:	83 e6 7f             	and    $0x7f,%esi
  804160212a:	48 d3 e6             	shl    %cl,%rsi
  804160212d:	49 09 f5             	or     %rsi,%r13
        shift += 7;
  8041602130:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041602134:	48 89 c6             	mov    %rax,%rsi
  8041602137:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  804160213b:	40 84 ff             	test   %dil,%dil
  804160213e:	79 06                	jns    8041602146 <file_name_by_info+0x22d>
  8041602140:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041602144:	76 d6                	jbe    804160211c <file_name_by_info+0x203>
    while (byte & 0x80) {
  8041602146:	40 84 ff             	test   %dil,%dil
  8041602149:	79 12                	jns    804160215d <file_name_by_info+0x244>
        byte = *addr++;
  804160214b:	48 f7 d6             	not    %rsi
  804160214e:	48 01 f2             	add    %rsi,%rdx
  8041602151:	0f b6 0c 02          	movzbl (%rdx,%rax,1),%ecx
        count++;
  8041602155:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  8041602159:	84 c9                	test   %cl,%cl
  804160215b:	78 f4                	js     8041602151 <file_name_by_info+0x238>
        abbrev_entry += dwarf_read_uleb128(abbrev_entry, &name);
  804160215d:	48 01 d8             	add    %rbx,%rax
  8041602160:	48 89 c2             	mov    %rax,%rdx
    size_t shift = 0, count = 0;
  8041602163:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041602168:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  804160216d:	41 bc 00 00 00 00    	mov    $0x0,%r12d
        byte = *addr++;
  8041602173:	48 83 c2 01          	add    $0x1,%rdx
  8041602177:	0f b6 7a ff          	movzbl -0x1(%rdx),%edi
        result |= (byte & 0x7FULL) << shift;
  804160217b:	48 89 fe             	mov    %rdi,%rsi
  804160217e:	83 e6 7f             	and    $0x7f,%esi
  8041602181:	48 d3 e6             	shl    %cl,%rsi
  8041602184:	49 09 f4             	or     %rsi,%r12
        shift += 7;
  8041602187:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  804160218b:	48 89 de             	mov    %rbx,%rsi
  804160218e:	48 83 c3 01          	add    $0x1,%rbx
    } while (byte & 0x80 && shift < 64);
  8041602192:	40 84 ff             	test   %dil,%dil
  8041602195:	79 06                	jns    804160219d <file_name_by_info+0x284>
  8041602197:	48 83 f9 3f          	cmp    $0x3f,%rcx
  804160219b:	76 d6                	jbe    8041602173 <file_name_by_info+0x25a>
    while (byte & 0x80) {
  804160219d:	40 84 ff             	test   %dil,%dil
  80416021a0:	79 12                	jns    80416021b4 <file_name_by_info+0x29b>
        byte = *addr++;
  80416021a2:	48 f7 d6             	not    %rsi
  80416021a5:	48 01 f2             	add    %rsi,%rdx
  80416021a8:	0f b6 0c 1a          	movzbl (%rdx,%rbx,1),%ecx
        count++;
  80416021ac:	48 83 c3 01          	add    $0x1,%rbx
    while (byte & 0x80) {
  80416021b0:	84 c9                	test   %cl,%cl
  80416021b2:	78 f4                	js     80416021a8 <file_name_by_info+0x28f>
        abbrev_entry += dwarf_read_uleb128(abbrev_entry, &form);
  80416021b4:	48 01 c3             	add    %rax,%rbx
        if (name == DW_AT_name) {
  80416021b7:	49 83 fd 03          	cmp    $0x3,%r13
  80416021bb:	0f 84 21 ff ff ff    	je     80416020e2 <file_name_by_info+0x1c9>
            }
        } else if (name == DW_AT_stmt_list) {
  80416021c1:	49 83 fd 10          	cmp    $0x10,%r13
  80416021c5:	0f 84 99 00 00 00    	je     8041602264 <file_name_by_info+0x34b>
            entry += dwarf_read_abbrev_entry(entry, form, line_off, sizeof(Dwarf_Off), address_size);
        } else {
            entry += dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);
  80416021cb:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416021d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416021d6:	ba 00 00 00 00       	mov    $0x0,%edx
  80416021db:	44 89 e6             	mov    %r12d,%esi
  80416021de:	4c 89 f7             	mov    %r14,%rdi
  80416021e1:	41 ff d7             	call   *%r15
  80416021e4:	48 98                	cltq   
  80416021e6:	49 01 c6             	add    %rax,%r14
        }
    } while (name || form);
  80416021e9:	4d 09 ec             	or     %r13,%r12
  80416021ec:	0f 85 17 ff ff ff    	jne    8041602109 <file_name_by_info+0x1f0>

    return 0;
  80416021f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80416021f7:	48 83 c4 38          	add    $0x38,%rsp
  80416021fb:	5b                   	pop    %rbx
  80416021fc:	41 5c                	pop    %r12
  80416021fe:	41 5d                	pop    %r13
  8041602200:	41 5e                	pop    %r14
  8041602202:	41 5f                	pop    %r15
  8041602204:	5d                   	pop    %rbp
  8041602205:	c3                   	ret    
                uint64_t offset = 0;
  8041602206:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  804160220d:	00 
                entry += dwarf_read_abbrev_entry(entry, form, &offset, sizeof(uint64_t), address_size);
  804160220e:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602214:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602219:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  804160221d:	be 0e 00 00 00       	mov    $0xe,%esi
  8041602222:	4c 89 f7             	mov    %r14,%rdi
  8041602225:	41 ff d7             	call   *%r15
  8041602228:	48 98                	cltq   
  804160222a:	49 01 c6             	add    %rax,%r14
                if (buf) put_unaligned((const uint8_t *)addrs->str_begin + offset, buf);
  804160222d:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8041602231:	48 85 ff             	test   %rdi,%rdi
  8041602234:	0f 84 cf fe ff ff    	je     8041602109 <file_name_by_info+0x1f0>
  804160223a:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  804160223e:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  8041602242:	48 03 42 40          	add    0x40(%rdx),%rax
  8041602246:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  804160224a:	ba 08 00 00 00       	mov    $0x8,%edx
  804160224f:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  8041602253:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  804160225a:	00 00 00 
  804160225d:	ff d0                	call   *%rax
  804160225f:	e9 a5 fe ff ff       	jmp    8041602109 <file_name_by_info+0x1f0>
            entry += dwarf_read_abbrev_entry(entry, form, line_off, sizeof(Dwarf_Off), address_size);
  8041602264:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160226a:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160226f:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  8041602273:	44 89 e6             	mov    %r12d,%esi
  8041602276:	4c 89 f7             	mov    %r14,%rdi
  8041602279:	41 ff d7             	call   *%r15
  804160227c:	48 98                	cltq   
  804160227e:	49 01 c6             	add    %rax,%r14
  8041602281:	e9 83 fe ff ff       	jmp    8041602109 <file_name_by_info+0x1f0>
    if (offset > addrs->info_end - addrs->info_begin) return -E_INVAL;
  8041602286:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160228b:	e9 67 ff ff ff       	jmp    80416021f7 <file_name_by_info+0x2de>
    uint64_t count = sizeof(uint32_t);
  8041602290:	b8 04 00 00 00       	mov    $0x4,%eax
    entry += count = dwarf_entry_len(entry, &len);
  8041602295:	48 01 c3             	add    %rax,%rbx
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041602298:	ba 02 00 00 00       	mov    $0x2,%edx
  804160229d:	48 89 de             	mov    %rbx,%rsi
  80416022a0:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416022a4:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416022ab:	00 00 00 
  80416022ae:	ff d0                	call   *%rax
    entry += sizeof(Dwarf_Half);
  80416022b0:	48 8d 73 02          	lea    0x2(%rbx),%rsi
    assert(version == 4 || version == 2);
  80416022b4:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416022b8:	83 e8 02             	sub    $0x2,%eax
  80416022bb:	66 a9 fd ff          	test   $0xfffd,%ax
  80416022bf:	0f 85 14 fd ff ff    	jne    8041601fd9 <file_name_by_info+0xc0>
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  80416022c5:	ba 04 00 00 00       	mov    $0x4,%edx
  80416022ca:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416022ce:	49 bc 77 94 60 41 80 	movabs $0x8041609477,%r12
  80416022d5:	00 00 00 
  80416022d8:	41 ff d4             	call   *%r12
  80416022db:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
    entry += sizeof(uint32_t);
  80416022df:	48 8d 73 06          	lea    0x6(%rbx),%rsi
    Dwarf_Small address_size = get_unaligned(entry, Dwarf_Small);
  80416022e3:	ba 01 00 00 00       	mov    $0x1,%edx
  80416022e8:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416022ec:	41 ff d4             	call   *%r12
    entry += sizeof(Dwarf_Small);
  80416022ef:	4c 8d 73 07          	lea    0x7(%rbx),%r14
    assert(address_size == sizeof(uintptr_t));
  80416022f3:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  80416022f7:	0f 85 11 fd ff ff    	jne    804160200e <file_name_by_info+0xf5>
  80416022fd:	4c 89 f0             	mov    %r14,%rax
    size_t shift = 0, count = 0;
  8041602300:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041602305:	be 00 00 00 00       	mov    $0x0,%esi
        byte = *addr++;
  804160230a:	48 83 c0 01          	add    $0x1,%rax
  804160230e:	0f b6 78 ff          	movzbl -0x1(%rax),%edi
        result |= (byte & 0x7FULL) << shift;
  8041602312:	48 89 fa             	mov    %rdi,%rdx
  8041602315:	83 e2 7f             	and    $0x7f,%edx
  8041602318:	48 d3 e2             	shl    %cl,%rdx
  804160231b:	48 09 d6             	or     %rdx,%rsi
        shift += 7;
  804160231e:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041602322:	4c 8d 40 f9          	lea    -0x7(%rax),%r8
  8041602326:	4c 89 c2             	mov    %r8,%rdx
  8041602329:	48 29 da             	sub    %rbx,%rdx
    } while (byte & 0x80 && shift < 64);
  804160232c:	40 84 ff             	test   %dil,%dil
  804160232f:	79 06                	jns    8041602337 <file_name_by_info+0x41e>
  8041602331:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041602335:	76 d3                	jbe    804160230a <file_name_by_info+0x3f1>
    while (byte & 0x80) {
  8041602337:	40 84 ff             	test   %dil,%dil
  804160233a:	79 12                	jns    804160234e <file_name_by_info+0x435>
        byte = *addr++;
  804160233c:	4c 29 c3             	sub    %r8,%rbx
  804160233f:	48 01 d8             	add    %rbx,%rax
  8041602342:	0f b6 0c 10          	movzbl (%rax,%rdx,1),%ecx
        count++;
  8041602346:	48 83 c2 01          	add    $0x1,%rdx
    while (byte & 0x80) {
  804160234a:	84 c9                	test   %cl,%cl
  804160234c:	78 f4                	js     8041602342 <file_name_by_info+0x429>
    entry += dwarf_read_uleb128(entry, &abbrev_code);
  804160234e:	49 01 d6             	add    %rdx,%r14
    assert(abbrev_code);
  8041602351:	48 85 f6             	test   %rsi,%rsi
  8041602354:	0f 84 e9 fc ff ff    	je     8041602043 <file_name_by_info+0x12a>
    const uint8_t *abbrev_entry = addrs->abbrev_begin + abbrev_offset;
  804160235a:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  804160235e:	4d 89 e8             	mov    %r13,%r8
  8041602361:	4c 03 00             	add    (%rax),%r8
  8041602364:	4c 89 c2             	mov    %r8,%rdx
    size_t shift = 0, count = 0;
  8041602367:	b8 00 00 00 00       	mov    $0x0,%eax
  804160236c:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041602371:	41 b9 00 00 00 00    	mov    $0x0,%r9d
        byte = *addr++;
  8041602377:	48 83 c2 01          	add    $0x1,%rdx
  804160237b:	44 0f b6 52 ff       	movzbl -0x1(%rdx),%r10d
        result |= (byte & 0x7FULL) << shift;
  8041602380:	4c 89 d7             	mov    %r10,%rdi
  8041602383:	83 e7 7f             	and    $0x7f,%edi
  8041602386:	48 d3 e7             	shl    %cl,%rdi
  8041602389:	49 09 f9             	or     %rdi,%r9
        shift += 7;
  804160238c:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041602390:	48 89 c7             	mov    %rax,%rdi
  8041602393:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  8041602397:	45 84 d2             	test   %r10b,%r10b
  804160239a:	79 06                	jns    80416023a2 <file_name_by_info+0x489>
  804160239c:	48 83 f9 3f          	cmp    $0x3f,%rcx
  80416023a0:	76 d5                	jbe    8041602377 <file_name_by_info+0x45e>
    while (byte & 0x80) {
  80416023a2:	45 84 d2             	test   %r10b,%r10b
  80416023a5:	79 12                	jns    80416023b9 <file_name_by_info+0x4a0>
        byte = *addr++;
  80416023a7:	48 f7 d7             	not    %rdi
  80416023aa:	48 01 fa             	add    %rdi,%rdx
  80416023ad:	0f b6 0c 02          	movzbl (%rdx,%rax,1),%ecx
        count++;
  80416023b1:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  80416023b5:	84 c9                	test   %cl,%cl
  80416023b7:	78 f4                	js     80416023ad <file_name_by_info+0x494>
    abbrev_entry += dwarf_read_uleb128(abbrev_entry, &table_abbrev_code);
  80416023b9:	49 01 c0             	add    %rax,%r8
    assert(table_abbrev_code == abbrev_code);
  80416023bc:	4c 39 ce             	cmp    %r9,%rsi
  80416023bf:	0f 85 b3 fc ff ff    	jne    8041602078 <file_name_by_info+0x15f>
  80416023c5:	4c 89 c2             	mov    %r8,%rdx
    size_t shift = 0, count = 0;
  80416023c8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416023cd:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  80416023d2:	41 b9 00 00 00 00    	mov    $0x0,%r9d
        byte = *addr++;
  80416023d8:	48 83 c2 01          	add    $0x1,%rdx
  80416023dc:	0f b6 7a ff          	movzbl -0x1(%rdx),%edi
        result |= (byte & 0x7FULL) << shift;
  80416023e0:	48 89 fe             	mov    %rdi,%rsi
  80416023e3:	83 e6 7f             	and    $0x7f,%esi
  80416023e6:	48 d3 e6             	shl    %cl,%rsi
  80416023e9:	49 09 f1             	or     %rsi,%r9
        shift += 7;
  80416023ec:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  80416023f0:	48 89 c6             	mov    %rax,%rsi
  80416023f3:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  80416023f7:	40 84 ff             	test   %dil,%dil
  80416023fa:	79 06                	jns    8041602402 <file_name_by_info+0x4e9>
  80416023fc:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041602400:	76 d6                	jbe    80416023d8 <file_name_by_info+0x4bf>
    while (byte & 0x80) {
  8041602402:	40 84 ff             	test   %dil,%dil
  8041602405:	79 12                	jns    8041602419 <file_name_by_info+0x500>
        byte = *addr++;
  8041602407:	48 f7 d6             	not    %rsi
  804160240a:	48 01 f2             	add    %rsi,%rdx
  804160240d:	0f b6 0c 02          	movzbl (%rdx,%rax,1),%ecx
        count++;
  8041602411:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  8041602415:	84 c9                	test   %cl,%cl
  8041602417:	78 f4                	js     804160240d <file_name_by_info+0x4f4>
    assert(tag == DW_TAG_compile_unit);
  8041602419:	49 83 f9 11          	cmp    $0x11,%r9
  804160241d:	0f 85 8a fc ff ff    	jne    80416020ad <file_name_by_info+0x194>
    abbrev_entry += sizeof(Dwarf_Small);
  8041602423:	49 8d 5c 00 01       	lea    0x1(%r8,%rax,1),%rbx
            entry += dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);
  8041602428:	49 bf c2 0e 60 41 80 	movabs $0x8041600ec2,%r15
  804160242f:	00 00 00 
  8041602432:	e9 d2 fc ff ff       	jmp    8041602109 <file_name_by_info+0x1f0>

0000008041602437 <function_by_info>:

int
function_by_info(const struct Dwarf_Addrs *addrs, uintptr_t p, Dwarf_Off cu_offset, char **buf, uintptr_t *offset) {
  8041602437:	f3 0f 1e fa          	endbr64 
  804160243b:	55                   	push   %rbp
  804160243c:	48 89 e5             	mov    %rsp,%rbp
  804160243f:	41 57                	push   %r15
  8041602441:	41 56                	push   %r14
  8041602443:	41 55                	push   %r13
  8041602445:	41 54                	push   %r12
  8041602447:	53                   	push   %rbx
  8041602448:	48 83 ec 68          	sub    $0x68,%rsp
  804160244c:	48 89 7d 98          	mov    %rdi,-0x68(%rbp)
  8041602450:	48 89 b5 78 ff ff ff 	mov    %rsi,-0x88(%rbp)
  8041602457:	48 89 4d 88          	mov    %rcx,-0x78(%rbp)
  804160245b:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
    uint64_t len = 0;
    uint32_t count;

    const void *entry = addrs->info_begin + cu_offset;
  8041602462:	48 03 57 20          	add    0x20(%rdi),%rdx
  8041602466:	49 89 d6             	mov    %rdx,%r14
    uint64_t initial_len = get_unaligned(addr, uint32_t);
  8041602469:	ba 04 00 00 00       	mov    $0x4,%edx
  804160246e:	4c 89 f6             	mov    %r14,%rsi
  8041602471:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602475:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  804160247c:	00 00 00 
  804160247f:	ff d0                	call   *%rax
  8041602481:	8b 45 c8             	mov    -0x38(%rbp),%eax
    if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041602484:	48 ba 10 00 00 00 ff 	movabs $0xffffffff00000010,%rdx
  804160248b:	ff ff ff 
  804160248e:	48 01 c2             	add    %rax,%rdx
  8041602491:	48 83 fa 0f          	cmp    $0xf,%rdx
  8041602495:	0f 87 09 06 00 00    	ja     8041602aa4 <function_by_info+0x66d>
        if (initial_len == DW_EXT_DWARF64) {
  804160249b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80416024a0:	48 39 d0             	cmp    %rdx,%rax
  80416024a3:	74 25                	je     80416024ca <function_by_info+0x93>
            cprintf("Unknown DWARF extension\n");
  80416024a5:	48 bf 40 a4 60 41 80 	movabs $0x804160a440,%rdi
  80416024ac:	00 00 00 
  80416024af:	b8 00 00 00 00       	mov    $0x0,%eax
  80416024b4:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  80416024bb:	00 00 00 
  80416024be:	ff d2                	call   *%rdx
    entry += count = dwarf_entry_len(entry, &len);
    if (!count) return -E_BAD_DWARF;
  80416024c0:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  80416024c5:	e9 cb 05 00 00       	jmp    8041602a95 <function_by_info+0x65e>
            *len = get_unaligned((uint64_t *)addr + sizeof(uint32_t), uint64_t);
  80416024ca:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416024ce:	ba 08 00 00 00       	mov    $0x8,%edx
  80416024d3:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416024d7:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416024de:	00 00 00 
  80416024e1:	ff d0                	call   *%rax
  80416024e3:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
            count += sizeof(uint64_t);
  80416024e7:	ba 0c 00 00 00       	mov    $0xc,%edx
  80416024ec:	e9 b8 05 00 00       	jmp    8041602aa9 <function_by_info+0x672>
    const void *entry_end = entry + len;

    /* Parse compilation unit header */
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
    entry += sizeof(Dwarf_Half);
    assert(version == 4 || version == 2);
  80416024f1:	48 b9 59 a4 60 41 80 	movabs $0x804160a459,%rcx
  80416024f8:	00 00 00 
  80416024fb:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041602502:	00 00 00 
  8041602505:	be 9d 01 00 00       	mov    $0x19d,%esi
  804160250a:	48 bf 8b a4 60 41 80 	movabs $0x804160a48b,%rdi
  8041602511:	00 00 00 
  8041602514:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602519:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041602520:	00 00 00 
  8041602523:	41 ff d0             	call   *%r8
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
    entry += sizeof(uint32_t);
    Dwarf_Small address_size = get_unaligned(entry, Dwarf_Small);
    entry += sizeof(Dwarf_Small);
    assert(address_size == sizeof(uintptr_t));
  8041602526:	48 b9 c8 a5 60 41 80 	movabs $0x804160a5c8,%rcx
  804160252d:	00 00 00 
  8041602530:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041602537:	00 00 00 
  804160253a:	be a2 01 00 00       	mov    $0x1a2,%esi
  804160253f:	48 bf 8b a4 60 41 80 	movabs $0x804160a48b,%rdi
  8041602546:	00 00 00 
  8041602549:	b8 00 00 00 00       	mov    $0x0,%eax
  804160254e:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041602555:	00 00 00 
  8041602558:	41 ff d0             	call   *%r8
    while (byte & 0x80) {
  804160255b:	40 84 ff             	test   %dil,%dil
  804160255e:	79 12                	jns    8041602572 <function_by_info+0x13b>
        byte = *addr++;
  8041602560:	48 f7 d6             	not    %rsi
  8041602563:	48 01 f2             	add    %rsi,%rdx
  8041602566:	0f b6 0c 02          	movzbl (%rdx,%rax,1),%ecx
        count++;
  804160256a:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  804160256e:	84 c9                	test   %cl,%cl
  8041602570:	78 f4                	js     8041602566 <function_by_info+0x12f>
    uint64_t table_abbrev_code = 0;
    const uint8_t *abbrev_entry = addrs->abbrev_begin + abbrev_offset;

    while (entry < entry_end) {
        /* Read info abbreviation code */
        entry += dwarf_read_uleb128(entry, &abbrev_code);
  8041602572:	49 01 c6             	add    %rax,%r14
        if (!abbrev_code) continue;
  8041602575:	4d 85 c0             	test   %r8,%r8
  8041602578:	75 49                	jne    80416025c3 <function_by_info+0x18c>
    while (entry < entry_end) {
  804160257a:	4c 3b 75 80          	cmp    -0x80(%rbp),%r14
  804160257e:	0f 83 0c 05 00 00    	jae    8041602a90 <function_by_info+0x659>
  8041602584:	4c 89 f2             	mov    %r14,%rdx
    size_t shift = 0, count = 0;
  8041602587:	b8 00 00 00 00       	mov    $0x0,%eax
  804160258c:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041602591:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        byte = *addr++;
  8041602597:	48 83 c2 01          	add    $0x1,%rdx
  804160259b:	0f b6 7a ff          	movzbl -0x1(%rdx),%edi
        result |= (byte & 0x7FULL) << shift;
  804160259f:	48 89 fe             	mov    %rdi,%rsi
  80416025a2:	83 e6 7f             	and    $0x7f,%esi
  80416025a5:	48 d3 e6             	shl    %cl,%rsi
  80416025a8:	49 09 f0             	or     %rsi,%r8
        shift += 7;
  80416025ab:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  80416025af:	48 89 c6             	mov    %rax,%rsi
  80416025b2:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  80416025b6:	40 84 ff             	test   %dil,%dil
  80416025b9:	79 a0                	jns    804160255b <function_by_info+0x124>
  80416025bb:	48 83 f9 3f          	cmp    $0x3f,%rcx
  80416025bf:	76 d6                	jbe    8041602597 <function_by_info+0x160>
  80416025c1:	eb 98                	jmp    804160255b <function_by_info+0x124>
        const uint8_t *curr_abbrev_entry = abbrev_entry;
        uint64_t name = 0, form = 0, tag = 0;

        /* Find abbreviation in abbrev section */
        /* UNSAFE Needs to be replaced */
        while (curr_abbrev_entry < addrs->abbrev_end) {
  80416025c3:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80416025c7:	4c 8b 48 08          	mov    0x8(%rax),%r9
  80416025cb:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  80416025cf:	4c 39 c8             	cmp    %r9,%rax
  80416025d2:	0f 82 d2 00 00 00    	jb     80416026aa <function_by_info+0x273>
        const uint8_t *curr_abbrev_entry = abbrev_entry;
  80416025d8:	48 8b 5d 90          	mov    -0x70(%rbp),%rbx
  80416025dc:	e9 10 04 00 00       	jmp    80416029f1 <function_by_info+0x5ba>
    while (byte & 0x80) {
  80416025e1:	45 84 e4             	test   %r12b,%r12b
  80416025e4:	79 12                	jns    80416025f8 <function_by_info+0x1c1>
        byte = *addr++;
  80416025e6:	49 f7 d3             	not    %r11
  80416025e9:	4c 01 de             	add    %r11,%rsi
  80416025ec:	0f b6 0c 06          	movzbl (%rsi,%rax,1),%ecx
        count++;
  80416025f0:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  80416025f4:	84 c9                	test   %cl,%cl
  80416025f6:	78 f4                	js     80416025ec <function_by_info+0x1b5>
            if (table_abbrev_code == abbrev_code) break;

            /* Skip attributes */
            do {
                curr_abbrev_entry += dwarf_read_uleb128(curr_abbrev_entry, &name);
                curr_abbrev_entry += dwarf_read_uleb128(curr_abbrev_entry, &form);
  80416025f8:	48 01 d0             	add    %rdx,%rax
            } while (name != 0 || form != 0);
  80416025fb:	4c 09 d3             	or     %r10,%rbx
  80416025fe:	0f 84 9d 00 00 00    	je     80416026a1 <function_by_info+0x26a>
    uint64_t result = 0;
  8041602604:	48 89 c6             	mov    %rax,%rsi
    size_t shift = 0, count = 0;
  8041602607:	ba 00 00 00 00       	mov    $0x0,%edx
  804160260c:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041602611:	41 ba 00 00 00 00    	mov    $0x0,%r10d
        byte = *addr++;
  8041602617:	48 83 c6 01          	add    $0x1,%rsi
  804160261b:	0f b6 5e ff          	movzbl -0x1(%rsi),%ebx
        result |= (byte & 0x7FULL) << shift;
  804160261f:	49 89 db             	mov    %rbx,%r11
  8041602622:	41 83 e3 7f          	and    $0x7f,%r11d
  8041602626:	49 d3 e3             	shl    %cl,%r11
  8041602629:	4d 09 da             	or     %r11,%r10
        shift += 7;
  804160262c:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041602630:	49 89 d3             	mov    %rdx,%r11
  8041602633:	48 83 c2 01          	add    $0x1,%rdx
    } while (byte & 0x80 && shift < 64);
  8041602637:	84 db                	test   %bl,%bl
  8041602639:	79 06                	jns    8041602641 <function_by_info+0x20a>
  804160263b:	48 83 f9 3f          	cmp    $0x3f,%rcx
  804160263f:	76 d6                	jbe    8041602617 <function_by_info+0x1e0>
    while (byte & 0x80) {
  8041602641:	84 db                	test   %bl,%bl
  8041602643:	79 12                	jns    8041602657 <function_by_info+0x220>
        byte = *addr++;
  8041602645:	49 f7 d3             	not    %r11
  8041602648:	4c 01 de             	add    %r11,%rsi
  804160264b:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
        count++;
  804160264f:	48 83 c2 01          	add    $0x1,%rdx
    while (byte & 0x80) {
  8041602653:	84 c9                	test   %cl,%cl
  8041602655:	78 f4                	js     804160264b <function_by_info+0x214>
                curr_abbrev_entry += dwarf_read_uleb128(curr_abbrev_entry, &name);
  8041602657:	48 01 c2             	add    %rax,%rdx
  804160265a:	48 89 d6             	mov    %rdx,%rsi
    size_t shift = 0, count = 0;
  804160265d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602662:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041602667:	bb 00 00 00 00       	mov    $0x0,%ebx
        byte = *addr++;
  804160266c:	48 83 c6 01          	add    $0x1,%rsi
  8041602670:	44 0f b6 66 ff       	movzbl -0x1(%rsi),%r12d
        result |= (byte & 0x7FULL) << shift;
  8041602675:	4d 89 e3             	mov    %r12,%r11
  8041602678:	41 83 e3 7f          	and    $0x7f,%r11d
  804160267c:	49 d3 e3             	shl    %cl,%r11
  804160267f:	4c 09 db             	or     %r11,%rbx
        shift += 7;
  8041602682:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041602686:	49 89 c3             	mov    %rax,%r11
  8041602689:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  804160268d:	45 84 e4             	test   %r12b,%r12b
  8041602690:	0f 89 4b ff ff ff    	jns    80416025e1 <function_by_info+0x1aa>
  8041602696:	48 83 f9 3f          	cmp    $0x3f,%rcx
  804160269a:	76 d0                	jbe    804160266c <function_by_info+0x235>
  804160269c:	e9 40 ff ff ff       	jmp    80416025e1 <function_by_info+0x1aa>
        while (curr_abbrev_entry < addrs->abbrev_end) {
  80416026a1:	4c 39 c8             	cmp    %r9,%rax
  80416026a4:	0f 83 b8 00 00 00    	jae    8041602762 <function_by_info+0x32b>
        const uint8_t *curr_abbrev_entry = abbrev_entry;
  80416026aa:	48 89 c6             	mov    %rax,%rsi
    size_t shift = 0, count = 0;
  80416026ad:	ba 00 00 00 00       	mov    $0x0,%edx
  80416026b2:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  80416026b7:	41 ba 00 00 00 00    	mov    $0x0,%r10d
        byte = *addr++;
  80416026bd:	48 83 c6 01          	add    $0x1,%rsi
  80416026c1:	44 0f b6 5e ff       	movzbl -0x1(%rsi),%r11d
        result |= (byte & 0x7FULL) << shift;
  80416026c6:	4c 89 df             	mov    %r11,%rdi
  80416026c9:	83 e7 7f             	and    $0x7f,%edi
  80416026cc:	48 d3 e7             	shl    %cl,%rdi
  80416026cf:	49 09 fa             	or     %rdi,%r10
        shift += 7;
  80416026d2:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  80416026d6:	48 89 d7             	mov    %rdx,%rdi
  80416026d9:	48 83 c2 01          	add    $0x1,%rdx
    } while (byte & 0x80 && shift < 64);
  80416026dd:	45 84 db             	test   %r11b,%r11b
  80416026e0:	79 06                	jns    80416026e8 <function_by_info+0x2b1>
  80416026e2:	48 83 f9 3f          	cmp    $0x3f,%rcx
  80416026e6:	76 d5                	jbe    80416026bd <function_by_info+0x286>
    while (byte & 0x80) {
  80416026e8:	45 84 db             	test   %r11b,%r11b
  80416026eb:	79 12                	jns    80416026ff <function_by_info+0x2c8>
        byte = *addr++;
  80416026ed:	48 f7 d7             	not    %rdi
  80416026f0:	48 01 fe             	add    %rdi,%rsi
  80416026f3:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
        count++;
  80416026f7:	48 83 c2 01          	add    $0x1,%rdx
    while (byte & 0x80) {
  80416026fb:	84 c9                	test   %cl,%cl
  80416026fd:	78 f4                	js     80416026f3 <function_by_info+0x2bc>
            curr_abbrev_entry += dwarf_read_uleb128(curr_abbrev_entry, &table_abbrev_code);
  80416026ff:	48 01 c2             	add    %rax,%rdx
  8041602702:	48 89 d6             	mov    %rdx,%rsi
    size_t shift = 0, count = 0;
  8041602705:	b8 00 00 00 00       	mov    $0x0,%eax
  804160270a:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  804160270f:	bf 00 00 00 00       	mov    $0x0,%edi
        byte = *addr++;
  8041602714:	48 83 c6 01          	add    $0x1,%rsi
  8041602718:	0f b6 5e ff          	movzbl -0x1(%rsi),%ebx
        result |= (byte & 0x7FULL) << shift;
  804160271c:	49 89 db             	mov    %rbx,%r11
  804160271f:	41 83 e3 7f          	and    $0x7f,%r11d
  8041602723:	49 d3 e3             	shl    %cl,%r11
  8041602726:	4c 09 df             	or     %r11,%rdi
        shift += 7;
  8041602729:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  804160272d:	49 89 c3             	mov    %rax,%r11
  8041602730:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  8041602734:	84 db                	test   %bl,%bl
  8041602736:	79 06                	jns    804160273e <function_by_info+0x307>
  8041602738:	48 83 f9 3f          	cmp    $0x3f,%rcx
  804160273c:	76 d6                	jbe    8041602714 <function_by_info+0x2dd>
    while (byte & 0x80) {
  804160273e:	84 db                	test   %bl,%bl
  8041602740:	79 12                	jns    8041602754 <function_by_info+0x31d>
        byte = *addr++;
  8041602742:	49 f7 d3             	not    %r11
  8041602745:	4c 01 de             	add    %r11,%rsi
  8041602748:	0f b6 0c 06          	movzbl (%rsi,%rax,1),%ecx
        count++;
  804160274c:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  8041602750:	84 c9                	test   %cl,%cl
  8041602752:	78 f4                	js     8041602748 <function_by_info+0x311>
            curr_abbrev_entry += sizeof(Dwarf_Small);
  8041602754:	48 8d 44 02 01       	lea    0x1(%rdx,%rax,1),%rax
            if (table_abbrev_code == abbrev_code) break;
  8041602759:	4d 39 d0             	cmp    %r10,%r8
  804160275c:	0f 85 a2 fe ff ff    	jne    8041602604 <function_by_info+0x1cd>
        }
        /* Parse subprogram DIE */
        if (tag == DW_TAG_subprogram) {
  8041602762:	48 89 c3             	mov    %rax,%rbx
  8041602765:	48 83 ff 2e          	cmp    $0x2e,%rdi
  8041602769:	0f 85 82 02 00 00    	jne    80416029f1 <function_by_info+0x5ba>
            uintptr_t low_pc = 0, high_pc = 0;
  804160276f:	48 c7 45 b0 00 00 00 	movq   $0x0,-0x50(%rbp)
  8041602776:	00 
  8041602777:	48 c7 45 b8 00 00 00 	movq   $0x0,-0x48(%rbp)
  804160277e:	00 
            const uint8_t *fn_name_entry = 0;
            uint64_t name_form = 0;
  804160277f:	48 c7 45 a0 00 00 00 	movq   $0x0,-0x60(%rbp)
  8041602786:	00 
            const uint8_t *fn_name_entry = 0;
  8041602787:	48 c7 45 a8 00 00 00 	movq   $0x0,-0x58(%rbp)
  804160278e:	00 
  804160278f:	eb 72                	jmp    8041602803 <function_by_info+0x3cc>
  8041602791:	45 84 c0             	test   %r8b,%r8b
  8041602794:	79 12                	jns    80416027a8 <function_by_info+0x371>
        byte = *addr++;
  8041602796:	48 f7 d7             	not    %rdi
  8041602799:	48 01 fe             	add    %rdi,%rsi
  804160279c:	0f b6 0c 06          	movzbl (%rsi,%rax,1),%ecx
        count++;
  80416027a0:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  80416027a4:	84 c9                	test   %cl,%cl
  80416027a6:	78 f4                	js     804160279c <function_by_info+0x365>
            do {
                curr_abbrev_entry += dwarf_read_uleb128(curr_abbrev_entry, &name);
                curr_abbrev_entry += dwarf_read_uleb128(curr_abbrev_entry, &form);
  80416027a8:	48 8d 1c 02          	lea    (%rdx,%rax,1),%rbx
                if (name == DW_AT_low_pc) {
  80416027ac:	49 83 fc 11          	cmp    $0x11,%r12
  80416027b0:	0f 84 ec 00 00 00    	je     80416028a2 <function_by_info+0x46b>
                    entry += dwarf_read_abbrev_entry(entry, form, &low_pc, sizeof(low_pc), address_size);
                } else if (name == DW_AT_high_pc) {
  80416027b6:	49 83 fc 12          	cmp    $0x12,%r12
  80416027ba:	0f 84 04 01 00 00    	je     80416028c4 <function_by_info+0x48d>
        result |= (byte & 0x7FULL) << shift;
  80416027c0:	49 83 fc 03          	cmp    $0x3,%r12
  80416027c4:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  80416027c8:	49 0f 44 c5          	cmove  %r13,%rax
  80416027cc:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
  80416027d0:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80416027d4:	49 0f 44 c6          	cmove  %r14,%rax
  80416027d8:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
                } else {
                    if (name == DW_AT_name) {
                        fn_name_entry = entry;
                        name_form = form;
                    }
                    entry += dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);
  80416027dc:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416027e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416027e7:	ba 00 00 00 00       	mov    $0x0,%edx
  80416027ec:	44 89 ee             	mov    %r13d,%esi
  80416027ef:	4c 89 f7             	mov    %r14,%rdi
  80416027f2:	41 ff d7             	call   *%r15
  80416027f5:	48 98                	cltq   
  80416027f7:	49 01 c6             	add    %rax,%r14
                }
            } while (name || form);
  80416027fa:	4d 09 e5             	or     %r12,%r13
  80416027fd:	0f 84 f5 00 00 00    	je     80416028f8 <function_by_info+0x4c1>
            const uint8_t *fn_name_entry = 0;
  8041602803:	48 89 da             	mov    %rbx,%rdx
    size_t shift = 0, count = 0;
  8041602806:	b8 00 00 00 00       	mov    $0x0,%eax
  804160280b:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041602810:	41 bc 00 00 00 00    	mov    $0x0,%r12d
        byte = *addr++;
  8041602816:	48 83 c2 01          	add    $0x1,%rdx
  804160281a:	0f b6 7a ff          	movzbl -0x1(%rdx),%edi
        result |= (byte & 0x7FULL) << shift;
  804160281e:	48 89 fe             	mov    %rdi,%rsi
  8041602821:	83 e6 7f             	and    $0x7f,%esi
  8041602824:	48 d3 e6             	shl    %cl,%rsi
  8041602827:	49 09 f4             	or     %rsi,%r12
        shift += 7;
  804160282a:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  804160282e:	48 89 c6             	mov    %rax,%rsi
  8041602831:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  8041602835:	40 84 ff             	test   %dil,%dil
  8041602838:	79 06                	jns    8041602840 <function_by_info+0x409>
  804160283a:	48 83 f9 3f          	cmp    $0x3f,%rcx
  804160283e:	76 d6                	jbe    8041602816 <function_by_info+0x3df>
    while (byte & 0x80) {
  8041602840:	40 84 ff             	test   %dil,%dil
  8041602843:	79 12                	jns    8041602857 <function_by_info+0x420>
        byte = *addr++;
  8041602845:	48 f7 d6             	not    %rsi
  8041602848:	48 01 f2             	add    %rsi,%rdx
  804160284b:	0f b6 0c 02          	movzbl (%rdx,%rax,1),%ecx
        count++;
  804160284f:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  8041602853:	84 c9                	test   %cl,%cl
  8041602855:	78 f4                	js     804160284b <function_by_info+0x414>
                curr_abbrev_entry += dwarf_read_uleb128(curr_abbrev_entry, &name);
  8041602857:	48 8d 14 03          	lea    (%rbx,%rax,1),%rdx
  804160285b:	48 89 d6             	mov    %rdx,%rsi
    size_t shift = 0, count = 0;
  804160285e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602863:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041602868:	41 bd 00 00 00 00    	mov    $0x0,%r13d
        byte = *addr++;
  804160286e:	48 83 c6 01          	add    $0x1,%rsi
  8041602872:	44 0f b6 46 ff       	movzbl -0x1(%rsi),%r8d
        result |= (byte & 0x7FULL) << shift;
  8041602877:	4c 89 c7             	mov    %r8,%rdi
  804160287a:	83 e7 7f             	and    $0x7f,%edi
  804160287d:	48 d3 e7             	shl    %cl,%rdi
  8041602880:	49 09 fd             	or     %rdi,%r13
        shift += 7;
  8041602883:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041602887:	48 89 c7             	mov    %rax,%rdi
  804160288a:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  804160288e:	45 84 c0             	test   %r8b,%r8b
  8041602891:	0f 89 fa fe ff ff    	jns    8041602791 <function_by_info+0x35a>
  8041602897:	48 83 f9 3f          	cmp    $0x3f,%rcx
  804160289b:	76 d1                	jbe    804160286e <function_by_info+0x437>
  804160289d:	e9 ef fe ff ff       	jmp    8041602791 <function_by_info+0x35a>
                    entry += dwarf_read_abbrev_entry(entry, form, &low_pc, sizeof(low_pc), address_size);
  80416028a2:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416028a8:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416028ad:	48 8d 55 b0          	lea    -0x50(%rbp),%rdx
  80416028b1:	44 89 ee             	mov    %r13d,%esi
  80416028b4:	4c 89 f7             	mov    %r14,%rdi
  80416028b7:	41 ff d7             	call   *%r15
  80416028ba:	48 98                	cltq   
  80416028bc:	49 01 c6             	add    %rax,%r14
  80416028bf:	e9 3f ff ff ff       	jmp    8041602803 <function_by_info+0x3cc>
                    entry += dwarf_read_abbrev_entry(entry, form, &high_pc, sizeof(high_pc), address_size);
  80416028c4:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416028ca:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416028cf:	48 8d 55 b8          	lea    -0x48(%rbp),%rdx
  80416028d3:	44 89 ee             	mov    %r13d,%esi
  80416028d6:	4c 89 f7             	mov    %r14,%rdi
  80416028d9:	41 ff d7             	call   *%r15
  80416028dc:	48 98                	cltq   
  80416028de:	49 01 c6             	add    %rax,%r14
                    if (form != DW_FORM_addr) high_pc += low_pc;
  80416028e1:	49 83 fd 01          	cmp    $0x1,%r13
  80416028e5:	0f 84 18 ff ff ff    	je     8041602803 <function_by_info+0x3cc>
  80416028eb:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80416028ef:	48 01 45 b8          	add    %rax,-0x48(%rbp)
  80416028f3:	e9 0b ff ff ff       	jmp    8041602803 <function_by_info+0x3cc>

            /* Load info and finish if address is inside of the function */
            if (p >= low_pc && p <= high_pc) {
  80416028f8:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80416028fc:	48 8b bd 78 ff ff ff 	mov    -0x88(%rbp),%rdi
  8041602903:	48 39 f8             	cmp    %rdi,%rax
  8041602906:	0f 87 6e fc ff ff    	ja     804160257a <function_by_info+0x143>
  804160290c:	48 39 7d b8          	cmp    %rdi,-0x48(%rbp)
  8041602910:	0f 82 64 fc ff ff    	jb     804160257a <function_by_info+0x143>
                *offset = low_pc;
  8041602916:	48 8b bd 70 ff ff ff 	mov    -0x90(%rbp),%rdi
  804160291d:	48 89 07             	mov    %rax,(%rdi)
                if (name_form == DW_FORM_strp) {
  8041602920:	48 83 7d a0 0e       	cmpq   $0xe,-0x60(%rbp)
  8041602925:	74 2c                	je     8041602953 <function_by_info+0x51c>
                    uintptr_t str_offset = 0;
                    entry += dwarf_read_abbrev_entry(fn_name_entry, name_form, &str_offset, sizeof(uintptr_t), address_size);
                    (void)entry;
                    if (buf) put_unaligned((const uint8_t *)addrs->str_begin + str_offset, buf);
                } else {
                    entry += dwarf_read_abbrev_entry(fn_name_entry, name_form, buf, sizeof(uint8_t *), address_size);
  8041602927:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160292d:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602932:	48 8b 55 88          	mov    -0x78(%rbp),%rdx
  8041602936:	8b 75 a0             	mov    -0x60(%rbp),%esi
  8041602939:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  804160293d:	48 b8 c2 0e 60 41 80 	movabs $0x8041600ec2,%rax
  8041602944:	00 00 00 
  8041602947:	ff d0                	call   *%rax
                    (void)entry;
                }
                return 0;
  8041602949:	b8 00 00 00 00       	mov    $0x0,%eax
  804160294e:	e9 42 01 00 00       	jmp    8041602a95 <function_by_info+0x65e>
                    uintptr_t str_offset = 0;
  8041602953:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  804160295a:	00 
                    entry += dwarf_read_abbrev_entry(fn_name_entry, name_form, &str_offset, sizeof(uintptr_t), address_size);
  804160295b:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602961:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602966:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  804160296a:	be 0e 00 00 00       	mov    $0xe,%esi
  804160296f:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  8041602973:	48 b8 c2 0e 60 41 80 	movabs $0x8041600ec2,%rax
  804160297a:	00 00 00 
  804160297d:	ff d0                	call   *%rax
                    if (buf) put_unaligned((const uint8_t *)addrs->str_begin + str_offset, buf);
  804160297f:	48 8b 7d 88          	mov    -0x78(%rbp),%rdi
  8041602983:	48 85 ff             	test   %rdi,%rdi
  8041602986:	74 c1                	je     8041602949 <function_by_info+0x512>
  8041602988:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  804160298c:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
  8041602990:	48 03 43 40          	add    0x40(%rbx),%rax
  8041602994:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  8041602998:	ba 08 00 00 00       	mov    $0x8,%edx
  804160299d:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  80416029a1:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416029a8:	00 00 00 
  80416029ab:	ff d0                	call   *%rax
  80416029ad:	eb 9a                	jmp    8041602949 <function_by_info+0x512>
    while (byte & 0x80) {
  80416029af:	45 84 c0             	test   %r8b,%r8b
  80416029b2:	79 12                	jns    80416029c6 <function_by_info+0x58f>
        byte = *addr++;
  80416029b4:	48 f7 d7             	not    %rdi
  80416029b7:	48 01 fe             	add    %rdi,%rsi
  80416029ba:	0f b6 0c 06          	movzbl (%rsi,%rax,1),%ecx
        count++;
  80416029be:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  80416029c2:	84 c9                	test   %cl,%cl
  80416029c4:	78 f4                	js     80416029ba <function_by_info+0x583>
            }
        } else {
            /* Skip if not a subprogram */
            do {
                curr_abbrev_entry += dwarf_read_uleb128(curr_abbrev_entry, &name);
                curr_abbrev_entry += dwarf_read_uleb128(curr_abbrev_entry, &form);
  80416029c6:	48 8d 1c 02          	lea    (%rdx,%rax,1),%rbx
                entry += dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);
  80416029ca:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416029d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416029d5:	ba 00 00 00 00       	mov    $0x0,%edx
  80416029da:	44 89 e6             	mov    %r12d,%esi
  80416029dd:	4c 89 f7             	mov    %r14,%rdi
  80416029e0:	41 ff d7             	call   *%r15
  80416029e3:	48 98                	cltq   
  80416029e5:	49 01 c6             	add    %rax,%r14
            } while (name || form);
  80416029e8:	4d 09 ec             	or     %r13,%r12
  80416029eb:	0f 84 89 fb ff ff    	je     804160257a <function_by_info+0x143>
        const uint8_t *curr_abbrev_entry = abbrev_entry;
  80416029f1:	48 89 da             	mov    %rbx,%rdx
    size_t shift = 0, count = 0;
  80416029f4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416029f9:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  80416029fe:	41 bd 00 00 00 00    	mov    $0x0,%r13d
        byte = *addr++;
  8041602a04:	48 83 c2 01          	add    $0x1,%rdx
  8041602a08:	0f b6 7a ff          	movzbl -0x1(%rdx),%edi
        result |= (byte & 0x7FULL) << shift;
  8041602a0c:	48 89 fe             	mov    %rdi,%rsi
  8041602a0f:	83 e6 7f             	and    $0x7f,%esi
  8041602a12:	48 d3 e6             	shl    %cl,%rsi
  8041602a15:	49 09 f5             	or     %rsi,%r13
        shift += 7;
  8041602a18:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041602a1c:	48 89 c6             	mov    %rax,%rsi
  8041602a1f:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  8041602a23:	40 84 ff             	test   %dil,%dil
  8041602a26:	79 06                	jns    8041602a2e <function_by_info+0x5f7>
  8041602a28:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041602a2c:	76 d6                	jbe    8041602a04 <function_by_info+0x5cd>
    while (byte & 0x80) {
  8041602a2e:	40 84 ff             	test   %dil,%dil
  8041602a31:	79 12                	jns    8041602a45 <function_by_info+0x60e>
        byte = *addr++;
  8041602a33:	48 f7 d6             	not    %rsi
  8041602a36:	48 01 f2             	add    %rsi,%rdx
  8041602a39:	0f b6 0c 02          	movzbl (%rdx,%rax,1),%ecx
        count++;
  8041602a3d:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  8041602a41:	84 c9                	test   %cl,%cl
  8041602a43:	78 f4                	js     8041602a39 <function_by_info+0x602>
                curr_abbrev_entry += dwarf_read_uleb128(curr_abbrev_entry, &name);
  8041602a45:	48 8d 14 03          	lea    (%rbx,%rax,1),%rdx
  8041602a49:	48 89 d6             	mov    %rdx,%rsi
    size_t shift = 0, count = 0;
  8041602a4c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602a51:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041602a56:	41 bc 00 00 00 00    	mov    $0x0,%r12d
        byte = *addr++;
  8041602a5c:	48 83 c6 01          	add    $0x1,%rsi
  8041602a60:	44 0f b6 46 ff       	movzbl -0x1(%rsi),%r8d
        result |= (byte & 0x7FULL) << shift;
  8041602a65:	4c 89 c7             	mov    %r8,%rdi
  8041602a68:	83 e7 7f             	and    $0x7f,%edi
  8041602a6b:	48 d3 e7             	shl    %cl,%rdi
  8041602a6e:	49 09 fc             	or     %rdi,%r12
        shift += 7;
  8041602a71:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041602a75:	48 89 c7             	mov    %rax,%rdi
  8041602a78:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  8041602a7c:	45 84 c0             	test   %r8b,%r8b
  8041602a7f:	0f 89 2a ff ff ff    	jns    80416029af <function_by_info+0x578>
  8041602a85:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041602a89:	76 d1                	jbe    8041602a5c <function_by_info+0x625>
  8041602a8b:	e9 1f ff ff ff       	jmp    80416029af <function_by_info+0x578>
        }
    }
    return -E_NO_ENT;
  8041602a90:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8041602a95:	48 83 c4 68          	add    $0x68,%rsp
  8041602a99:	5b                   	pop    %rbx
  8041602a9a:	41 5c                	pop    %r12
  8041602a9c:	41 5d                	pop    %r13
  8041602a9e:	41 5e                	pop    %r14
  8041602aa0:	41 5f                	pop    %r15
  8041602aa2:	5d                   	pop    %rbp
  8041602aa3:	c3                   	ret    
    uint64_t count = sizeof(uint32_t);
  8041602aa4:	ba 04 00 00 00       	mov    $0x4,%edx
    entry += count = dwarf_entry_len(entry, &len);
  8041602aa9:	49 01 d6             	add    %rdx,%r14
    const void *entry_end = entry + len;
  8041602aac:	4c 01 f0             	add    %r14,%rax
  8041602aaf:	48 89 45 80          	mov    %rax,-0x80(%rbp)
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041602ab3:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602ab8:	4c 89 f6             	mov    %r14,%rsi
  8041602abb:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602abf:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041602ac6:	00 00 00 
  8041602ac9:	ff d0                	call   *%rax
    entry += sizeof(Dwarf_Half);
  8041602acb:	49 8d 76 02          	lea    0x2(%r14),%rsi
    assert(version == 4 || version == 2);
  8041602acf:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041602ad3:	83 e8 02             	sub    $0x2,%eax
  8041602ad6:	66 a9 fd ff          	test   $0xfffd,%ax
  8041602ada:	0f 85 11 fa ff ff    	jne    80416024f1 <function_by_info+0xba>
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041602ae0:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602ae5:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602ae9:	49 bc 77 94 60 41 80 	movabs $0x8041609477,%r12
  8041602af0:	00 00 00 
  8041602af3:	41 ff d4             	call   *%r12
  8041602af6:	8b 5d c8             	mov    -0x38(%rbp),%ebx
    entry += sizeof(uint32_t);
  8041602af9:	49 8d 76 06          	lea    0x6(%r14),%rsi
    Dwarf_Small address_size = get_unaligned(entry, Dwarf_Small);
  8041602afd:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602b02:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602b06:	41 ff d4             	call   *%r12
    entry += sizeof(Dwarf_Small);
  8041602b09:	49 83 c6 07          	add    $0x7,%r14
    assert(address_size == sizeof(uintptr_t));
  8041602b0d:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602b11:	0f 85 0f fa ff ff    	jne    8041602526 <function_by_info+0xef>
    const uint8_t *abbrev_entry = addrs->abbrev_begin + abbrev_offset;
  8041602b17:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8041602b1b:	48 03 18             	add    (%rax),%rbx
  8041602b1e:	48 89 5d 90          	mov    %rbx,-0x70(%rbp)
                entry += dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);
  8041602b22:	49 bf c2 0e 60 41 80 	movabs $0x8041600ec2,%r15
  8041602b29:	00 00 00 
    while (entry < entry_end) {
  8041602b2c:	e9 49 fa ff ff       	jmp    804160257a <function_by_info+0x143>

0000008041602b31 <address_by_fname>:

int
address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname, uintptr_t *offset) {
  8041602b31:	f3 0f 1e fa          	endbr64 
  8041602b35:	55                   	push   %rbp
  8041602b36:	48 89 e5             	mov    %rsp,%rbp
  8041602b39:	41 57                	push   %r15
  8041602b3b:	41 56                	push   %r14
  8041602b3d:	41 55                	push   %r13
  8041602b3f:	41 54                	push   %r12
  8041602b41:	53                   	push   %rbx
  8041602b42:	48 83 ec 48          	sub    $0x48,%rsp
  8041602b46:	48 89 fb             	mov    %rdi,%rbx
  8041602b49:	48 89 7d b0          	mov    %rdi,-0x50(%rbp)
  8041602b4d:	48 89 f7             	mov    %rsi,%rdi
  8041602b50:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  8041602b54:	48 89 55 90          	mov    %rdx,-0x70(%rbp)
    const int flen = strlen(fname);
  8041602b58:	48 b8 ac 91 60 41 80 	movabs $0x80416091ac,%rax
  8041602b5f:	00 00 00 
  8041602b62:	ff d0                	call   *%rax
    if (!flen) return -E_INVAL;
  8041602b64:	85 c0                	test   %eax,%eax
  8041602b66:	0f 84 0e 06 00 00    	je     804160317a <address_by_fname+0x649>

    const uint8_t *pubnames_entry = addrs->pubnames_begin;
  8041602b6c:	4c 8b 73 50          	mov    0x50(%rbx),%r14
    uint32_t count = 0;
    uint64_t len = 0;
    Dwarf_Off cu_offset = 0, func_offset = 0;

    /* parse pubnames section */
    while (pubnames_entry < addrs->pubnames_end) {
  8041602b70:	4d 89 f7             	mov    %r14,%r15
  8041602b73:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602b77:	4c 3b 78 58          	cmp    0x58(%rax),%r15
  8041602b7b:	0f 83 f0 05 00 00    	jae    8041603171 <address_by_fname+0x640>
    uint64_t initial_len = get_unaligned(addr, uint32_t);
  8041602b81:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602b86:	4c 89 fe             	mov    %r15,%rsi
  8041602b89:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602b8d:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041602b94:	00 00 00 
  8041602b97:	ff d0                	call   *%rax
  8041602b99:	8b 45 c8             	mov    -0x38(%rbp),%eax
    if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041602b9c:	48 ba 10 00 00 00 ff 	movabs $0xffffffff00000010,%rdx
  8041602ba3:	ff ff ff 
  8041602ba6:	48 01 c2             	add    %rax,%rdx
  8041602ba9:	48 83 fa 0f          	cmp    $0xf,%rdx
  8041602bad:	0f 87 b1 06 00 00    	ja     8041603264 <address_by_fname+0x733>
        if (initial_len == DW_EXT_DWARF64) {
  8041602bb3:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8041602bb8:	48 39 d0             	cmp    %rdx,%rax
  8041602bbb:	74 27                	je     8041602be4 <address_by_fname+0xb3>
            cprintf("Unknown DWARF extension\n");
  8041602bbd:	48 bf 40 a4 60 41 80 	movabs $0x804160a440,%rdi
  8041602bc4:	00 00 00 
  8041602bc7:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602bcc:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  8041602bd3:	00 00 00 
  8041602bd6:	ff d2                	call   *%rdx
        count = dwarf_entry_len(pubnames_entry, &len);
        if (!count) return -E_BAD_DWARF;
  8041602bd8:	c7 45 bc fa ff ff ff 	movl   $0xfffffffa,-0x44(%rbp)
  8041602bdf:	e9 7b 05 00 00       	jmp    804160315f <address_by_fname+0x62e>
            *len = get_unaligned((uint64_t *)addr + sizeof(uint32_t), uint64_t);
  8041602be4:	49 8d 77 20          	lea    0x20(%r15),%rsi
  8041602be8:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602bed:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602bf1:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041602bf8:	00 00 00 
  8041602bfb:	ff d0                	call   *%rax
  8041602bfd:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
            count += sizeof(uint64_t);
  8041602c01:	bb 0c 00 00 00       	mov    $0xc,%ebx
  8041602c06:	e9 5e 06 00 00       	jmp    8041603269 <address_by_fname+0x738>
        pubnames_entry += count;

        const uint8_t *pubnames_entry_end = pubnames_entry + len;
        Dwarf_Half version = get_unaligned(pubnames_entry, Dwarf_Half);
        assert(version == 2);
  8041602c0b:	48 b9 69 a4 60 41 80 	movabs $0x804160a469,%rcx
  8041602c12:	00 00 00 
  8041602c15:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041602c1c:	00 00 00 
  8041602c1f:	be 01 02 00 00       	mov    $0x201,%esi
  8041602c24:	48 bf 8b a4 60 41 80 	movabs $0x804160a48b,%rdi
  8041602c2b:	00 00 00 
  8041602c2e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602c33:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041602c3a:	00 00 00 
  8041602c3d:	41 ff d0             	call   *%r8
            *len = get_unaligned((uint64_t *)addr + sizeof(uint32_t), uint64_t);
  8041602c40:	48 8d 73 26          	lea    0x26(%rbx),%rsi
  8041602c44:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602c49:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602c4d:	4c 89 f0             	mov    %r14,%rax
  8041602c50:	ff d0                	call   *%rax
            count += sizeof(uint64_t);
  8041602c52:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041602c57:	e9 b7 06 00 00       	jmp    8041603313 <address_by_fname+0x7e2>
            *len = get_unaligned((uint64_t *)addr + sizeof(uint32_t), uint64_t);
  8041602c5c:	49 8d 74 24 20       	lea    0x20(%r12),%rsi
  8041602c61:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602c66:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602c6a:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041602c71:	00 00 00 
  8041602c74:	ff d0                	call   *%rax
            count += sizeof(uint64_t);
  8041602c76:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041602c7b:	e9 08 05 00 00       	jmp    8041603188 <address_by_fname+0x657>
                const uint8_t *func_entry = entry + func_offset;
                entry += count = dwarf_entry_len(entry, &len);
                if (!count) return -E_BAD_DWARF;

                Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
                assert(version == 4 || version == 2);
  8041602c80:	48 b9 59 a4 60 41 80 	movabs $0x804160a459,%rcx
  8041602c87:	00 00 00 
  8041602c8a:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041602c91:	00 00 00 
  8041602c94:	be 17 02 00 00       	mov    $0x217,%esi
  8041602c99:	48 bf 8b a4 60 41 80 	movabs $0x804160a48b,%rdi
  8041602ca0:	00 00 00 
  8041602ca3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602ca8:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041602caf:	00 00 00 
  8041602cb2:	41 ff d0             	call   *%r8
                entry += sizeof(Dwarf_Half);
                Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
                entry += sizeof(uint32_t);
                const uint8_t *abbrev_entry = addrs->abbrev_begin + abbrev_offset;
                Dwarf_Small address_size = get_unaligned(entry, Dwarf_Small);
                assert(address_size == sizeof(uintptr_t));
  8041602cb5:	48 b9 c8 a5 60 41 80 	movabs $0x804160a5c8,%rcx
  8041602cbc:	00 00 00 
  8041602cbf:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041602cc6:	00 00 00 
  8041602cc9:	be 1d 02 00 00       	mov    $0x21d,%esi
  8041602cce:	48 bf 8b a4 60 41 80 	movabs $0x804160a48b,%rdi
  8041602cd5:	00 00 00 
  8041602cd8:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602cdd:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041602ce4:	00 00 00 
  8041602ce7:	41 ff d0             	call   *%r8
    while (byte & 0x80) {
  8041602cea:	45 84 e4             	test   %r12b,%r12b
  8041602ced:	79 12                	jns    8041602d01 <address_by_fname+0x1d0>
        byte = *addr++;
  8041602cef:	49 f7 d0             	not    %r8
  8041602cf2:	4c 01 c6             	add    %r8,%rsi
  8041602cf5:	0f b6 0c 06          	movzbl (%rsi,%rax,1),%ecx
        count++;
  8041602cf9:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  8041602cfd:	84 c9                	test   %cl,%cl
  8041602cff:	78 f4                	js     8041602cf5 <address_by_fname+0x1c4>
                    if (table_abbrev_code == abbrev_code) break;

                    /* skip attributes */
                    do {
                        abbrev_entry += dwarf_read_uleb128(abbrev_entry, &name);
                        abbrev_entry += dwarf_read_uleb128(abbrev_entry, &form);
  8041602d01:	48 01 d0             	add    %rdx,%rax
                    } while (name || form);
  8041602d04:	48 09 fb             	or     %rdi,%rbx
  8041602d07:	0f 84 9c 00 00 00    	je     8041602da9 <address_by_fname+0x278>
    uint64_t result = 0;
  8041602d0d:	48 89 c6             	mov    %rax,%rsi
    size_t shift = 0, count = 0;
  8041602d10:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602d15:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041602d1a:	bf 00 00 00 00       	mov    $0x0,%edi
        byte = *addr++;
  8041602d1f:	48 83 c6 01          	add    $0x1,%rsi
  8041602d23:	0f b6 5e ff          	movzbl -0x1(%rsi),%ebx
        result |= (byte & 0x7FULL) << shift;
  8041602d27:	49 89 d8             	mov    %rbx,%r8
  8041602d2a:	41 83 e0 7f          	and    $0x7f,%r8d
  8041602d2e:	49 d3 e0             	shl    %cl,%r8
  8041602d31:	4c 09 c7             	or     %r8,%rdi
        shift += 7;
  8041602d34:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041602d38:	49 89 d0             	mov    %rdx,%r8
  8041602d3b:	48 83 c2 01          	add    $0x1,%rdx
    } while (byte & 0x80 && shift < 64);
  8041602d3f:	84 db                	test   %bl,%bl
  8041602d41:	79 06                	jns    8041602d49 <address_by_fname+0x218>
  8041602d43:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041602d47:	76 d6                	jbe    8041602d1f <address_by_fname+0x1ee>
    while (byte & 0x80) {
  8041602d49:	84 db                	test   %bl,%bl
  8041602d4b:	79 12                	jns    8041602d5f <address_by_fname+0x22e>
        byte = *addr++;
  8041602d4d:	49 f7 d0             	not    %r8
  8041602d50:	4c 01 c6             	add    %r8,%rsi
  8041602d53:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
        count++;
  8041602d57:	48 83 c2 01          	add    $0x1,%rdx
    while (byte & 0x80) {
  8041602d5b:	84 c9                	test   %cl,%cl
  8041602d5d:	78 f4                	js     8041602d53 <address_by_fname+0x222>
                        abbrev_entry += dwarf_read_uleb128(abbrev_entry, &name);
  8041602d5f:	48 01 c2             	add    %rax,%rdx
  8041602d62:	48 89 d6             	mov    %rdx,%rsi
    size_t shift = 0, count = 0;
  8041602d65:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602d6a:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041602d6f:	bb 00 00 00 00       	mov    $0x0,%ebx
        byte = *addr++;
  8041602d74:	48 83 c6 01          	add    $0x1,%rsi
  8041602d78:	44 0f b6 66 ff       	movzbl -0x1(%rsi),%r12d
        result |= (byte & 0x7FULL) << shift;
  8041602d7d:	4d 89 e0             	mov    %r12,%r8
  8041602d80:	41 83 e0 7f          	and    $0x7f,%r8d
  8041602d84:	49 d3 e0             	shl    %cl,%r8
  8041602d87:	4c 09 c3             	or     %r8,%rbx
        shift += 7;
  8041602d8a:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041602d8e:	49 89 c0             	mov    %rax,%r8
  8041602d91:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  8041602d95:	45 84 e4             	test   %r12b,%r12b
  8041602d98:	0f 89 4c ff ff ff    	jns    8041602cea <address_by_fname+0x1b9>
  8041602d9e:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041602da2:	76 d0                	jbe    8041602d74 <address_by_fname+0x243>
  8041602da4:	e9 41 ff ff ff       	jmp    8041602cea <address_by_fname+0x1b9>
                while (abbrev_entry < addrs->abbrev_end) {
  8041602da9:	49 39 c3             	cmp    %rax,%r11
  8041602dac:	0f 86 b9 00 00 00    	jbe    8041602e6b <address_by_fname+0x33a>
    uint64_t result = 0;
  8041602db2:	48 89 c6             	mov    %rax,%rsi
    size_t shift = 0, count = 0;
  8041602db5:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602dba:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041602dbf:	bf 00 00 00 00       	mov    $0x0,%edi
        byte = *addr++;
  8041602dc4:	48 83 c6 01          	add    $0x1,%rsi
  8041602dc8:	44 0f b6 4e ff       	movzbl -0x1(%rsi),%r9d
        result |= (byte & 0x7FULL) << shift;
  8041602dcd:	4d 89 c8             	mov    %r9,%r8
  8041602dd0:	41 83 e0 7f          	and    $0x7f,%r8d
  8041602dd4:	49 d3 e0             	shl    %cl,%r8
  8041602dd7:	4c 09 c7             	or     %r8,%rdi
        shift += 7;
  8041602dda:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041602dde:	49 89 d0             	mov    %rdx,%r8
  8041602de1:	48 83 c2 01          	add    $0x1,%rdx
    } while (byte & 0x80 && shift < 64);
  8041602de5:	45 84 c9             	test   %r9b,%r9b
  8041602de8:	79 06                	jns    8041602df0 <address_by_fname+0x2bf>
  8041602dea:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041602dee:	76 d4                	jbe    8041602dc4 <address_by_fname+0x293>
    while (byte & 0x80) {
  8041602df0:	45 84 c9             	test   %r9b,%r9b
  8041602df3:	79 12                	jns    8041602e07 <address_by_fname+0x2d6>
        byte = *addr++;
  8041602df5:	49 f7 d0             	not    %r8
  8041602df8:	4c 01 c6             	add    %r8,%rsi
  8041602dfb:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
        count++;
  8041602dff:	48 83 c2 01          	add    $0x1,%rdx
    while (byte & 0x80) {
  8041602e03:	84 c9                	test   %cl,%cl
  8041602e05:	78 f4                	js     8041602dfb <address_by_fname+0x2ca>
                    abbrev_entry += dwarf_read_uleb128(abbrev_entry, &table_abbrev_code);
  8041602e07:	48 01 c2             	add    %rax,%rdx
  8041602e0a:	48 89 d6             	mov    %rdx,%rsi
    size_t shift = 0, count = 0;
  8041602e0d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602e12:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041602e17:	41 b9 00 00 00 00    	mov    $0x0,%r9d
        byte = *addr++;
  8041602e1d:	48 83 c6 01          	add    $0x1,%rsi
  8041602e21:	0f b6 5e ff          	movzbl -0x1(%rsi),%ebx
        result |= (byte & 0x7FULL) << shift;
  8041602e25:	49 89 d8             	mov    %rbx,%r8
  8041602e28:	41 83 e0 7f          	and    $0x7f,%r8d
  8041602e2c:	49 d3 e0             	shl    %cl,%r8
  8041602e2f:	4d 09 c1             	or     %r8,%r9
        shift += 7;
  8041602e32:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041602e36:	49 89 c0             	mov    %rax,%r8
  8041602e39:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  8041602e3d:	84 db                	test   %bl,%bl
  8041602e3f:	79 06                	jns    8041602e47 <address_by_fname+0x316>
  8041602e41:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041602e45:	76 d6                	jbe    8041602e1d <address_by_fname+0x2ec>
    while (byte & 0x80) {
  8041602e47:	84 db                	test   %bl,%bl
  8041602e49:	79 12                	jns    8041602e5d <address_by_fname+0x32c>
        byte = *addr++;
  8041602e4b:	49 f7 d0             	not    %r8
  8041602e4e:	4c 01 c6             	add    %r8,%rsi
  8041602e51:	0f b6 0c 06          	movzbl (%rsi,%rax,1),%ecx
        count++;
  8041602e55:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  8041602e59:	84 c9                	test   %cl,%cl
  8041602e5b:	78 f4                	js     8041602e51 <address_by_fname+0x320>
                    abbrev_entry += sizeof(Dwarf_Small);
  8041602e5d:	48 8d 44 02 01       	lea    0x1(%rdx,%rax,1),%rax
                    if (table_abbrev_code == abbrev_code) break;
  8041602e62:	49 39 fa             	cmp    %rdi,%r10
  8041602e65:	0f 85 a2 fe ff ff    	jne    8041602d0d <address_by_fname+0x1dc>
                }
                /* Find low_pc */
                if (tag == DW_TAG_subprogram) {
  8041602e6b:	48 89 c3             	mov    %rax,%rbx
  8041602e6e:	49 83 f9 2e          	cmp    $0x2e,%r9
  8041602e72:	0f 85 7a 01 00 00    	jne    8041602ff2 <address_by_fname+0x4c1>
                     * with a pair where both name and form equal zero.
                     * Address of a function is encoded in attribute with name DW_AT_low_pc.
                     * To find it, we need to scan both abbreviation table and attribute values.
                     * You can read unsigned LEB128 number using dwarf_read_uleb128 function.
                     * Attribute value can be obtained using dwarf_read_abbrev_entry function. */
                    uintptr_t low_pc = 0;
  8041602e78:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041602e7f:	00 
  8041602e80:	eb 55                	jmp    8041602ed7 <address_by_fname+0x3a6>
  8041602e82:	45 84 c0             	test   %r8b,%r8b
  8041602e85:	79 12                	jns    8041602e99 <address_by_fname+0x368>
        byte = *addr++;
  8041602e87:	48 f7 d7             	not    %rdi
  8041602e8a:	48 01 fe             	add    %rdi,%rsi
  8041602e8d:	0f b6 0c 06          	movzbl (%rsi,%rax,1),%ecx
        count++;
  8041602e91:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  8041602e95:	84 c9                	test   %cl,%cl
  8041602e97:	78 f4                	js     8041602e8d <address_by_fname+0x35c>
                    // LAB 3: Your code here:

                    do {
                        abbrev_entry += dwarf_read_uleb128(abbrev_entry, &name);
                        abbrev_entry += dwarf_read_uleb128(abbrev_entry, &form);
  8041602e99:	48 8d 1c 02          	lea    (%rdx,%rax,1),%rbx

                        if(name == DW_AT_low_pc){
  8041602e9d:	49 83 fc 11          	cmp    $0x11,%r12
  8041602ea1:	0f 84 cf 00 00 00    	je     8041602f76 <address_by_fname+0x445>
                            entry += dwarf_read_abbrev_entry(entry, form, &low_pc, sizeof(low_pc), address_size);                        
                            *offset = low_pc;
                            return 0;
                        }
                        else{
                            entry += dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);                        
  8041602ea7:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602ead:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602eb2:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602eb7:	44 89 ee             	mov    %r13d,%esi
  8041602eba:	4c 89 f7             	mov    %r14,%rdi
  8041602ebd:	48 b8 c2 0e 60 41 80 	movabs $0x8041600ec2,%rax
  8041602ec4:	00 00 00 
  8041602ec7:	ff d0                	call   *%rax
  8041602ec9:	48 98                	cltq   
  8041602ecb:	49 01 c6             	add    %rax,%r14
                        }
                    } while (name || form);
  8041602ece:	4d 09 e5             	or     %r12,%r13
  8041602ed1:	0f 84 ba 01 00 00    	je     8041603091 <address_by_fname+0x560>
    uint64_t result = 0;
  8041602ed7:	48 89 da             	mov    %rbx,%rdx
    size_t shift = 0, count = 0;
  8041602eda:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602edf:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041602ee4:	41 bc 00 00 00 00    	mov    $0x0,%r12d
        byte = *addr++;
  8041602eea:	48 83 c2 01          	add    $0x1,%rdx
  8041602eee:	0f b6 7a ff          	movzbl -0x1(%rdx),%edi
        result |= (byte & 0x7FULL) << shift;
  8041602ef2:	48 89 fe             	mov    %rdi,%rsi
  8041602ef5:	83 e6 7f             	and    $0x7f,%esi
  8041602ef8:	48 d3 e6             	shl    %cl,%rsi
  8041602efb:	49 09 f4             	or     %rsi,%r12
        shift += 7;
  8041602efe:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041602f02:	48 89 c6             	mov    %rax,%rsi
  8041602f05:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  8041602f09:	40 84 ff             	test   %dil,%dil
  8041602f0c:	79 06                	jns    8041602f14 <address_by_fname+0x3e3>
  8041602f0e:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041602f12:	76 d6                	jbe    8041602eea <address_by_fname+0x3b9>
    while (byte & 0x80) {
  8041602f14:	40 84 ff             	test   %dil,%dil
  8041602f17:	79 12                	jns    8041602f2b <address_by_fname+0x3fa>
        byte = *addr++;
  8041602f19:	48 f7 d6             	not    %rsi
  8041602f1c:	48 01 f2             	add    %rsi,%rdx
  8041602f1f:	0f b6 0c 02          	movzbl (%rdx,%rax,1),%ecx
        count++;
  8041602f23:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  8041602f27:	84 c9                	test   %cl,%cl
  8041602f29:	78 f4                	js     8041602f1f <address_by_fname+0x3ee>
                        abbrev_entry += dwarf_read_uleb128(abbrev_entry, &name);
  8041602f2b:	48 8d 14 03          	lea    (%rbx,%rax,1),%rdx
  8041602f2f:	48 89 d6             	mov    %rdx,%rsi
    size_t shift = 0, count = 0;
  8041602f32:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602f37:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041602f3c:	41 bd 00 00 00 00    	mov    $0x0,%r13d
        byte = *addr++;
  8041602f42:	48 83 c6 01          	add    $0x1,%rsi
  8041602f46:	44 0f b6 46 ff       	movzbl -0x1(%rsi),%r8d
        result |= (byte & 0x7FULL) << shift;
  8041602f4b:	4c 89 c7             	mov    %r8,%rdi
  8041602f4e:	83 e7 7f             	and    $0x7f,%edi
  8041602f51:	48 d3 e7             	shl    %cl,%rdi
  8041602f54:	49 09 fd             	or     %rdi,%r13
        shift += 7;
  8041602f57:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041602f5b:	48 89 c7             	mov    %rax,%rdi
  8041602f5e:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  8041602f62:	45 84 c0             	test   %r8b,%r8b
  8041602f65:	0f 89 17 ff ff ff    	jns    8041602e82 <address_by_fname+0x351>
  8041602f6b:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041602f6f:	76 d1                	jbe    8041602f42 <address_by_fname+0x411>
  8041602f71:	e9 0c ff ff ff       	jmp    8041602e82 <address_by_fname+0x351>
                            entry += dwarf_read_abbrev_entry(entry, form, &low_pc, sizeof(low_pc), address_size);                        
  8041602f76:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602f7c:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602f81:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041602f85:	44 89 ee             	mov    %r13d,%esi
  8041602f88:	4c 89 f7             	mov    %r14,%rdi
  8041602f8b:	48 b8 c2 0e 60 41 80 	movabs $0x8041600ec2,%rax
  8041602f92:	00 00 00 
  8041602f95:	ff d0                	call   *%rax
                            *offset = low_pc;
  8041602f97:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041602f9b:	48 8b 7d 90          	mov    -0x70(%rbp),%rdi
  8041602f9f:	48 89 07             	mov    %rax,(%rdi)
                            return 0;
  8041602fa2:	e9 b8 01 00 00       	jmp    804160315f <address_by_fname+0x62e>
    while (byte & 0x80) {
  8041602fa7:	45 84 c0             	test   %r8b,%r8b
  8041602faa:	79 12                	jns    8041602fbe <address_by_fname+0x48d>
        byte = *addr++;
  8041602fac:	48 f7 d7             	not    %rdi
  8041602faf:	48 01 fe             	add    %rdi,%rsi
  8041602fb2:	0f b6 0c 06          	movzbl (%rsi,%rax,1),%ecx
        count++;
  8041602fb6:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  8041602fba:	84 c9                	test   %cl,%cl
  8041602fbc:	78 f4                	js     8041602fb2 <address_by_fname+0x481>
                } else {
                    /* Skip if not a subprogram or label */
                    do {
                        abbrev_entry += dwarf_read_uleb128(abbrev_entry, &name);
                        abbrev_entry += dwarf_read_uleb128(abbrev_entry, &form);
  8041602fbe:	48 8d 1c 02          	lea    (%rdx,%rax,1),%rbx
                        entry += dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);
  8041602fc2:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602fc8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602fcd:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602fd2:	44 89 e6             	mov    %r12d,%esi
  8041602fd5:	4c 89 f7             	mov    %r14,%rdi
  8041602fd8:	48 b8 c2 0e 60 41 80 	movabs $0x8041600ec2,%rax
  8041602fdf:	00 00 00 
  8041602fe2:	ff d0                	call   *%rax
  8041602fe4:	48 98                	cltq   
  8041602fe6:	49 01 c6             	add    %rax,%r14
                    } while (name || form);
  8041602fe9:	4d 09 ec             	or     %r13,%r12
  8041602fec:	0f 84 9f 00 00 00    	je     8041603091 <address_by_fname+0x560>
    uint64_t result = 0;
  8041602ff2:	48 89 da             	mov    %rbx,%rdx
    size_t shift = 0, count = 0;
  8041602ff5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602ffa:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041602fff:	41 bd 00 00 00 00    	mov    $0x0,%r13d
        byte = *addr++;
  8041603005:	48 83 c2 01          	add    $0x1,%rdx
  8041603009:	0f b6 7a ff          	movzbl -0x1(%rdx),%edi
        result |= (byte & 0x7FULL) << shift;
  804160300d:	48 89 fe             	mov    %rdi,%rsi
  8041603010:	83 e6 7f             	and    $0x7f,%esi
  8041603013:	48 d3 e6             	shl    %cl,%rsi
  8041603016:	49 09 f5             	or     %rsi,%r13
        shift += 7;
  8041603019:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  804160301d:	48 89 c6             	mov    %rax,%rsi
  8041603020:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  8041603024:	40 84 ff             	test   %dil,%dil
  8041603027:	79 06                	jns    804160302f <address_by_fname+0x4fe>
  8041603029:	48 83 f9 3f          	cmp    $0x3f,%rcx
  804160302d:	76 d6                	jbe    8041603005 <address_by_fname+0x4d4>
    while (byte & 0x80) {
  804160302f:	40 84 ff             	test   %dil,%dil
  8041603032:	79 12                	jns    8041603046 <address_by_fname+0x515>
        byte = *addr++;
  8041603034:	48 f7 d6             	not    %rsi
  8041603037:	48 01 f2             	add    %rsi,%rdx
  804160303a:	0f b6 0c 02          	movzbl (%rdx,%rax,1),%ecx
        count++;
  804160303e:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  8041603042:	84 c9                	test   %cl,%cl
  8041603044:	78 f4                	js     804160303a <address_by_fname+0x509>
                        abbrev_entry += dwarf_read_uleb128(abbrev_entry, &name);
  8041603046:	48 8d 14 03          	lea    (%rbx,%rax,1),%rdx
  804160304a:	48 89 d6             	mov    %rdx,%rsi
    size_t shift = 0, count = 0;
  804160304d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603052:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041603057:	41 bc 00 00 00 00    	mov    $0x0,%r12d
        byte = *addr++;
  804160305d:	48 83 c6 01          	add    $0x1,%rsi
  8041603061:	44 0f b6 46 ff       	movzbl -0x1(%rsi),%r8d
        result |= (byte & 0x7FULL) << shift;
  8041603066:	4c 89 c7             	mov    %r8,%rdi
  8041603069:	83 e7 7f             	and    $0x7f,%edi
  804160306c:	48 d3 e7             	shl    %cl,%rdi
  804160306f:	49 09 fc             	or     %rdi,%r12
        shift += 7;
  8041603072:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041603076:	48 89 c7             	mov    %rax,%rdi
  8041603079:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  804160307d:	45 84 c0             	test   %r8b,%r8b
  8041603080:	0f 89 21 ff ff ff    	jns    8041602fa7 <address_by_fname+0x476>
  8041603086:	48 83 f9 3f          	cmp    $0x3f,%rcx
  804160308a:	76 d1                	jbe    804160305d <address_by_fname+0x52c>
  804160308c:	e9 16 ff ff ff       	jmp    8041602fa7 <address_by_fname+0x476>
                }
            }
            pubnames_entry += strlen((const char *)pubnames_entry) + 1;
  8041603091:	4c 89 ff             	mov    %r15,%rdi
  8041603094:	48 b8 ac 91 60 41 80 	movabs $0x80416091ac,%rax
  804160309b:	00 00 00 
  804160309e:	ff d0                	call   *%rax
  80416030a0:	4d 8d 7c 07 01       	lea    0x1(%r15,%rax,1),%r15
        while (pubnames_entry < pubnames_entry_end) {
  80416030a5:	4c 39 7d a8          	cmp    %r15,-0x58(%rbp)
  80416030a9:	0f 86 71 02 00 00    	jbe    8041603320 <address_by_fname+0x7ef>
            func_offset = get_unaligned(pubnames_entry, uint32_t);
  80416030af:	ba 04 00 00 00       	mov    $0x4,%edx
  80416030b4:	4c 89 fe             	mov    %r15,%rsi
  80416030b7:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416030bb:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416030c2:	00 00 00 
  80416030c5:	ff d0                	call   *%rax
  80416030c7:	44 8b 75 c8          	mov    -0x38(%rbp),%r14d
            pubnames_entry += sizeof(uint32_t);
  80416030cb:	49 83 c7 04          	add    $0x4,%r15
            if (!func_offset) break;
  80416030cf:	4d 85 f6             	test   %r14,%r14
  80416030d2:	0f 84 9b fa ff ff    	je     8041602b73 <address_by_fname+0x42>
            if (!strcmp(fname, (const char *)pubnames_entry)) {
  80416030d8:	4c 89 fe             	mov    %r15,%rsi
  80416030db:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  80416030df:	48 b8 a6 92 60 41 80 	movabs $0x80416092a6,%rax
  80416030e6:	00 00 00 
  80416030e9:	ff d0                	call   *%rax
  80416030eb:	89 45 bc             	mov    %eax,-0x44(%rbp)
  80416030ee:	85 c0                	test   %eax,%eax
  80416030f0:	75 9f                	jne    8041603091 <address_by_fname+0x560>
                const uint8_t *entry = addrs->info_begin + cu_offset;
  80416030f2:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80416030f6:	4c 8b 65 98          	mov    -0x68(%rbp),%r12
  80416030fa:	4c 03 60 20          	add    0x20(%rax),%r12
                const uint8_t *func_entry = entry + func_offset;
  80416030fe:	4d 01 e6             	add    %r12,%r14
    uint64_t initial_len = get_unaligned(addr, uint32_t);
  8041603101:	ba 04 00 00 00       	mov    $0x4,%edx
  8041603106:	4c 89 e6             	mov    %r12,%rsi
  8041603109:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160310d:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041603114:	00 00 00 
  8041603117:	ff d0                	call   *%rax
  8041603119:	8b 55 c8             	mov    -0x38(%rbp),%edx
    if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160311c:	48 b8 10 00 00 00 ff 	movabs $0xffffffff00000010,%rax
  8041603123:	ff ff ff 
  8041603126:	48 01 d0             	add    %rdx,%rax
  8041603129:	48 83 f8 0f          	cmp    $0xf,%rax
  804160312d:	77 54                	ja     8041603183 <address_by_fname+0x652>
        if (initial_len == DW_EXT_DWARF64) {
  804160312f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8041603134:	48 39 c2             	cmp    %rax,%rdx
  8041603137:	0f 84 1f fb ff ff    	je     8041602c5c <address_by_fname+0x12b>
            cprintf("Unknown DWARF extension\n");
  804160313d:	48 bf 40 a4 60 41 80 	movabs $0x804160a440,%rdi
  8041603144:	00 00 00 
  8041603147:	b8 00 00 00 00       	mov    $0x0,%eax
  804160314c:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  8041603153:	00 00 00 
  8041603156:	ff d2                	call   *%rdx
                if (!count) return -E_BAD_DWARF;
  8041603158:	c7 45 bc fa ff ff ff 	movl   $0xfffffffa,-0x44(%rbp)
        }
    }
    return -E_NO_ENT;
}
  804160315f:	8b 45 bc             	mov    -0x44(%rbp),%eax
  8041603162:	48 83 c4 48          	add    $0x48,%rsp
  8041603166:	5b                   	pop    %rbx
  8041603167:	41 5c                	pop    %r12
  8041603169:	41 5d                	pop    %r13
  804160316b:	41 5e                	pop    %r14
  804160316d:	41 5f                	pop    %r15
  804160316f:	5d                   	pop    %rbp
  8041603170:	c3                   	ret    
    return -E_NO_ENT;
  8041603171:	c7 45 bc f6 ff ff ff 	movl   $0xfffffff6,-0x44(%rbp)
  8041603178:	eb e5                	jmp    804160315f <address_by_fname+0x62e>
    if (!flen) return -E_INVAL;
  804160317a:	c7 45 bc fd ff ff ff 	movl   $0xfffffffd,-0x44(%rbp)
  8041603181:	eb dc                	jmp    804160315f <address_by_fname+0x62e>
    uint64_t count = sizeof(uint32_t);
  8041603183:	b8 04 00 00 00       	mov    $0x4,%eax
                entry += count = dwarf_entry_len(entry, &len);
  8041603188:	49 01 c4             	add    %rax,%r12
                Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  804160318b:	ba 02 00 00 00       	mov    $0x2,%edx
  8041603190:	4c 89 e6             	mov    %r12,%rsi
  8041603193:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603197:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  804160319e:	00 00 00 
  80416031a1:	ff d0                	call   *%rax
                assert(version == 4 || version == 2);
  80416031a3:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416031a7:	83 e8 02             	sub    $0x2,%eax
  80416031aa:	66 a9 fd ff          	test   $0xfffd,%ax
  80416031ae:	0f 85 cc fa ff ff    	jne    8041602c80 <address_by_fname+0x14f>
                entry += sizeof(Dwarf_Half);
  80416031b4:	49 8d 74 24 02       	lea    0x2(%r12),%rsi
                Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  80416031b9:	ba 04 00 00 00       	mov    $0x4,%edx
  80416031be:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416031c2:	49 bd 77 94 60 41 80 	movabs $0x8041609477,%r13
  80416031c9:	00 00 00 
  80416031cc:	41 ff d5             	call   *%r13
  80416031cf:	8b 5d c8             	mov    -0x38(%rbp),%ebx
                const uint8_t *abbrev_entry = addrs->abbrev_begin + abbrev_offset;
  80416031d2:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80416031d6:	48 03 18             	add    (%rax),%rbx
                entry += sizeof(uint32_t);
  80416031d9:	49 8d 74 24 06       	lea    0x6(%r12),%rsi
                Dwarf_Small address_size = get_unaligned(entry, Dwarf_Small);
  80416031de:	ba 01 00 00 00       	mov    $0x1,%edx
  80416031e3:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416031e7:	41 ff d5             	call   *%r13
                assert(address_size == sizeof(uintptr_t));
  80416031ea:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  80416031ee:	0f 85 c1 fa ff ff    	jne    8041602cb5 <address_by_fname+0x184>
  80416031f4:	4c 89 f2             	mov    %r14,%rdx
    size_t shift = 0, count = 0;
  80416031f7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416031fc:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041603201:	41 ba 00 00 00 00    	mov    $0x0,%r10d
        byte = *addr++;
  8041603207:	48 83 c2 01          	add    $0x1,%rdx
  804160320b:	0f b6 7a ff          	movzbl -0x1(%rdx),%edi
        result |= (byte & 0x7FULL) << shift;
  804160320f:	48 89 fe             	mov    %rdi,%rsi
  8041603212:	83 e6 7f             	and    $0x7f,%esi
  8041603215:	48 d3 e6             	shl    %cl,%rsi
  8041603218:	49 09 f2             	or     %rsi,%r10
        shift += 7;
  804160321b:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  804160321f:	48 89 c6             	mov    %rax,%rsi
  8041603222:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  8041603226:	40 84 ff             	test   %dil,%dil
  8041603229:	79 06                	jns    8041603231 <address_by_fname+0x700>
  804160322b:	48 83 f9 3f          	cmp    $0x3f,%rcx
  804160322f:	76 d6                	jbe    8041603207 <address_by_fname+0x6d6>
    while (byte & 0x80) {
  8041603231:	40 84 ff             	test   %dil,%dil
  8041603234:	79 12                	jns    8041603248 <address_by_fname+0x717>
        byte = *addr++;
  8041603236:	48 f7 d6             	not    %rsi
  8041603239:	48 01 f2             	add    %rsi,%rdx
  804160323c:	0f b6 0c 02          	movzbl (%rdx,%rax,1),%ecx
        count++;
  8041603240:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  8041603244:	84 c9                	test   %cl,%cl
  8041603246:	78 f4                	js     804160323c <address_by_fname+0x70b>
                entry += dwarf_read_uleb128(entry, &abbrev_code);
  8041603248:	49 01 c6             	add    %rax,%r14
                while (abbrev_entry < addrs->abbrev_end) {
  804160324b:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  804160324f:	4c 8b 58 08          	mov    0x8(%rax),%r11
  8041603253:	4c 39 db             	cmp    %r11,%rbx
  8041603256:	0f 83 96 fd ff ff    	jae    8041602ff2 <address_by_fname+0x4c1>
  804160325c:	48 89 d8             	mov    %rbx,%rax
  804160325f:	e9 4e fb ff ff       	jmp    8041602db2 <address_by_fname+0x281>
    uint64_t count = sizeof(uint32_t);
  8041603264:	bb 04 00 00 00       	mov    $0x4,%ebx
        pubnames_entry += count;
  8041603269:	4c 01 fb             	add    %r15,%rbx
        const uint8_t *pubnames_entry_end = pubnames_entry + len;
  804160326c:	48 01 d8             	add    %rbx,%rax
  804160326f:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
        Dwarf_Half version = get_unaligned(pubnames_entry, Dwarf_Half);
  8041603273:	ba 02 00 00 00       	mov    $0x2,%edx
  8041603278:	48 89 de             	mov    %rbx,%rsi
  804160327b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160327f:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041603286:	00 00 00 
  8041603289:	ff d0                	call   *%rax
        assert(version == 2);
  804160328b:	66 83 7d c8 02       	cmpw   $0x2,-0x38(%rbp)
  8041603290:	0f 85 75 f9 ff ff    	jne    8041602c0b <address_by_fname+0xda>
        pubnames_entry += sizeof(Dwarf_Half);
  8041603296:	48 8d 73 02          	lea    0x2(%rbx),%rsi
        cu_offset = get_unaligned(pubnames_entry, uint32_t);
  804160329a:	ba 04 00 00 00       	mov    $0x4,%edx
  804160329f:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416032a3:	49 be 77 94 60 41 80 	movabs $0x8041609477,%r14
  80416032aa:	00 00 00 
  80416032ad:	41 ff d6             	call   *%r14
  80416032b0:	8b 45 c8             	mov    -0x38(%rbp),%eax
  80416032b3:	48 89 45 98          	mov    %rax,-0x68(%rbp)
        pubnames_entry += sizeof(uint32_t);
  80416032b7:	4c 8d 7b 06          	lea    0x6(%rbx),%r15
    uint64_t initial_len = get_unaligned(addr, uint32_t);
  80416032bb:	ba 04 00 00 00       	mov    $0x4,%edx
  80416032c0:	4c 89 fe             	mov    %r15,%rsi
  80416032c3:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416032c7:	41 ff d6             	call   *%r14
  80416032ca:	8b 4d c8             	mov    -0x38(%rbp),%ecx
    if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416032cd:	48 ba 10 00 00 00 ff 	movabs $0xffffffff00000010,%rdx
  80416032d4:	ff ff ff 
  80416032d7:	48 01 ca             	add    %rcx,%rdx
    uint64_t count = sizeof(uint32_t);
  80416032da:	b8 04 00 00 00       	mov    $0x4,%eax
    if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416032df:	48 83 fa 0f          	cmp    $0xf,%rdx
  80416032e3:	77 2e                	ja     8041603313 <address_by_fname+0x7e2>
        if (initial_len == DW_EXT_DWARF64) {
  80416032e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80416032ea:	48 39 c1             	cmp    %rax,%rcx
  80416032ed:	0f 84 4d f9 ff ff    	je     8041602c40 <address_by_fname+0x10f>
            cprintf("Unknown DWARF extension\n");
  80416032f3:	48 bf 40 a4 60 41 80 	movabs $0x804160a440,%rdi
  80416032fa:	00 00 00 
  80416032fd:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603302:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  8041603309:	00 00 00 
  804160330c:	ff d2                	call   *%rdx
            count = 0;
  804160330e:	b8 00 00 00 00       	mov    $0x0,%eax
        pubnames_entry += count;
  8041603313:	49 01 c7             	add    %rax,%r15
        while (pubnames_entry < pubnames_entry_end) {
  8041603316:	4c 39 7d a8          	cmp    %r15,-0x58(%rbp)
  804160331a:	0f 87 8f fd ff ff    	ja     80416030af <address_by_fname+0x57e>
    while (pubnames_entry < addrs->pubnames_end) {
  8041603320:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041603324:	4c 3b 78 58          	cmp    0x58(%rax),%r15
  8041603328:	0f 82 53 f8 ff ff    	jb     8041602b81 <address_by_fname+0x50>
    return -E_NO_ENT;
  804160332e:	c7 45 bc f6 ff ff ff 	movl   $0xfffffff6,-0x44(%rbp)
  8041603335:	e9 25 fe ff ff       	jmp    804160315f <address_by_fname+0x62e>

000000804160333a <naive_address_by_fname>:

int
naive_address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname, uintptr_t *offset) {
  804160333a:	f3 0f 1e fa          	endbr64 
  804160333e:	55                   	push   %rbp
  804160333f:	48 89 e5             	mov    %rsp,%rbp
  8041603342:	41 57                	push   %r15
  8041603344:	41 56                	push   %r14
  8041603346:	41 55                	push   %r13
  8041603348:	41 54                	push   %r12
  804160334a:	53                   	push   %rbx
  804160334b:	48 83 ec 48          	sub    $0x48,%rsp
  804160334f:	48 89 fb             	mov    %rdi,%rbx
  8041603352:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
  8041603356:	48 89 f7             	mov    %rsi,%rdi
  8041603359:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  804160335d:	48 89 55 90          	mov    %rdx,-0x70(%rbp)
    const int flen = strlen(fname);
  8041603361:	48 b8 ac 91 60 41 80 	movabs $0x80416091ac,%rax
  8041603368:	00 00 00 
  804160336b:	ff d0                	call   *%rax
    if (!flen) return -E_INVAL;
  804160336d:	85 c0                	test   %eax,%eax
  804160336f:	0f 84 3c 06 00 00    	je     80416039b1 <naive_address_by_fname+0x677>

    for (const uint8_t *entry = addrs->info_begin; (const unsigned char *)entry < addrs->info_end;) {
  8041603375:	4c 8b 7b 20          	mov    0x20(%rbx),%r15
  8041603379:	4c 39 7b 28          	cmp    %r15,0x28(%rbx)
  804160337d:	0f 87 bc 05 00 00    	ja     804160393f <naive_address_by_fname+0x605>
                } while (name || form);
            }
        }
    }

    return -E_NO_ENT;
  8041603383:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8041603388:	e9 0e 06 00 00       	jmp    804160399b <naive_address_by_fname+0x661>
            *len = get_unaligned((uint64_t *)addr + sizeof(uint32_t), uint64_t);
  804160338d:	49 8d 77 20          	lea    0x20(%r15),%rsi
  8041603391:	ba 08 00 00 00       	mov    $0x8,%edx
  8041603396:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160339a:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416033a1:	00 00 00 
  80416033a4:	ff d0                	call   *%rax
  80416033a6:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
            count += sizeof(uint64_t);
  80416033aa:	bb 0c 00 00 00       	mov    $0xc,%ebx
  80416033af:	e9 09 06 00 00       	jmp    80416039bd <naive_address_by_fname+0x683>
        assert(version == 4 || version == 2);
  80416033b4:	48 b9 59 a4 60 41 80 	movabs $0x804160a459,%rcx
  80416033bb:	00 00 00 
  80416033be:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  80416033c5:	00 00 00 
  80416033c8:	be 6c 02 00 00       	mov    $0x26c,%esi
  80416033cd:	48 bf 8b a4 60 41 80 	movabs $0x804160a48b,%rdi
  80416033d4:	00 00 00 
  80416033d7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416033dc:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  80416033e3:	00 00 00 
  80416033e6:	41 ff d0             	call   *%r8
        assert(address_size == sizeof(uintptr_t));
  80416033e9:	48 b9 c8 a5 60 41 80 	movabs $0x804160a5c8,%rcx
  80416033f0:	00 00 00 
  80416033f3:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  80416033fa:	00 00 00 
  80416033fd:	be 71 02 00 00       	mov    $0x271,%esi
  8041603402:	48 bf 8b a4 60 41 80 	movabs $0x804160a48b,%rdi
  8041603409:	00 00 00 
  804160340c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603411:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041603418:	00 00 00 
  804160341b:	41 ff d0             	call   *%r8
    while (byte & 0x80) {
  804160341e:	40 84 ff             	test   %dil,%dil
  8041603421:	79 12                	jns    8041603435 <naive_address_by_fname+0xfb>
        byte = *addr++;
  8041603423:	48 f7 d6             	not    %rsi
  8041603426:	48 01 f2             	add    %rsi,%rdx
  8041603429:	0f b6 0c 02          	movzbl (%rdx,%rax,1),%ecx
        count++;
  804160342d:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  8041603431:	84 c9                	test   %cl,%cl
  8041603433:	78 f4                	js     8041603429 <naive_address_by_fname+0xef>
            entry += count;
  8041603435:	89 c0                	mov    %eax,%eax
  8041603437:	49 01 c7             	add    %rax,%r15
            if (!abbrev_code) continue;
  804160343a:	4d 85 d2             	test   %r10,%r10
  804160343d:	75 49                	jne    8041603488 <naive_address_by_fname+0x14e>
        while (entry < entry_end) {
  804160343f:	4c 3b 7d 98          	cmp    -0x68(%rbp),%r15
  8041603443:	0f 83 ec 04 00 00    	jae    8041603935 <naive_address_by_fname+0x5fb>
  8041603449:	4c 89 fa             	mov    %r15,%rdx
    size_t shift = 0, count = 0;
  804160344c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603451:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041603456:	41 ba 00 00 00 00    	mov    $0x0,%r10d
        byte = *addr++;
  804160345c:	48 83 c2 01          	add    $0x1,%rdx
  8041603460:	0f b6 7a ff          	movzbl -0x1(%rdx),%edi
        result |= (byte & 0x7FULL) << shift;
  8041603464:	48 89 fe             	mov    %rdi,%rsi
  8041603467:	83 e6 7f             	and    $0x7f,%esi
  804160346a:	48 d3 e6             	shl    %cl,%rsi
  804160346d:	49 09 f2             	or     %rsi,%r10
        shift += 7;
  8041603470:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041603474:	48 89 c6             	mov    %rax,%rsi
  8041603477:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  804160347b:	40 84 ff             	test   %dil,%dil
  804160347e:	79 9e                	jns    804160341e <naive_address_by_fname+0xe4>
  8041603480:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041603484:	76 d6                	jbe    804160345c <naive_address_by_fname+0x122>
  8041603486:	eb 96                	jmp    804160341e <naive_address_by_fname+0xe4>
            while ((const unsigned char *)curr_abbrev_entry < addrs->abbrev_end) {
  8041603488:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  804160348c:	4c 8b 58 08          	mov    0x8(%rax),%r11
  8041603490:	48 8b 5d a8          	mov    -0x58(%rbp),%rbx
  8041603494:	4c 39 db             	cmp    %r11,%rbx
  8041603497:	0f 83 a8 03 00 00    	jae    8041603845 <naive_address_by_fname+0x50b>
            const uint8_t *curr_abbrev_entry = abbrev_entry;
  804160349d:	48 89 d8             	mov    %rbx,%rax
  80416034a0:	e9 c8 00 00 00       	jmp    804160356d <naive_address_by_fname+0x233>
    while (byte & 0x80) {
  80416034a5:	45 84 ed             	test   %r13b,%r13b
  80416034a8:	79 12                	jns    80416034bc <naive_address_by_fname+0x182>
        byte = *addr++;
  80416034aa:	49 f7 d0             	not    %r8
  80416034ad:	4c 01 c6             	add    %r8,%rsi
  80416034b0:	0f b6 0c 06          	movzbl (%rsi,%rax,1),%ecx
        count++;
  80416034b4:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  80416034b8:	84 c9                	test   %cl,%cl
  80416034ba:	78 f4                	js     80416034b0 <naive_address_by_fname+0x176>
                    curr_abbrev_entry += dwarf_read_uleb128(curr_abbrev_entry, &form);
  80416034bc:	48 01 d0             	add    %rdx,%rax
                } while (name || form);
  80416034bf:	48 09 fb             	or     %rdi,%rbx
  80416034c2:	0f 84 9c 00 00 00    	je     8041603564 <naive_address_by_fname+0x22a>
    uint64_t result = 0;
  80416034c8:	48 89 c6             	mov    %rax,%rsi
    size_t shift = 0, count = 0;
  80416034cb:	ba 00 00 00 00       	mov    $0x0,%edx
  80416034d0:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  80416034d5:	bf 00 00 00 00       	mov    $0x0,%edi
        byte = *addr++;
  80416034da:	48 83 c6 01          	add    $0x1,%rsi
  80416034de:	0f b6 5e ff          	movzbl -0x1(%rsi),%ebx
        result |= (byte & 0x7FULL) << shift;
  80416034e2:	49 89 d8             	mov    %rbx,%r8
  80416034e5:	41 83 e0 7f          	and    $0x7f,%r8d
  80416034e9:	49 d3 e0             	shl    %cl,%r8
  80416034ec:	4c 09 c7             	or     %r8,%rdi
        shift += 7;
  80416034ef:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  80416034f3:	49 89 d0             	mov    %rdx,%r8
  80416034f6:	48 83 c2 01          	add    $0x1,%rdx
    } while (byte & 0x80 && shift < 64);
  80416034fa:	84 db                	test   %bl,%bl
  80416034fc:	79 06                	jns    8041603504 <naive_address_by_fname+0x1ca>
  80416034fe:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041603502:	76 d6                	jbe    80416034da <naive_address_by_fname+0x1a0>
    while (byte & 0x80) {
  8041603504:	84 db                	test   %bl,%bl
  8041603506:	79 12                	jns    804160351a <naive_address_by_fname+0x1e0>
        byte = *addr++;
  8041603508:	49 f7 d0             	not    %r8
  804160350b:	4c 01 c6             	add    %r8,%rsi
  804160350e:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
        count++;
  8041603512:	48 83 c2 01          	add    $0x1,%rdx
    while (byte & 0x80) {
  8041603516:	84 c9                	test   %cl,%cl
  8041603518:	78 f4                	js     804160350e <naive_address_by_fname+0x1d4>
                    curr_abbrev_entry += dwarf_read_uleb128(curr_abbrev_entry, &name);
  804160351a:	48 01 c2             	add    %rax,%rdx
  804160351d:	48 89 d6             	mov    %rdx,%rsi
    size_t shift = 0, count = 0;
  8041603520:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603525:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  804160352a:	bb 00 00 00 00       	mov    $0x0,%ebx
        byte = *addr++;
  804160352f:	48 83 c6 01          	add    $0x1,%rsi
  8041603533:	44 0f b6 6e ff       	movzbl -0x1(%rsi),%r13d
        result |= (byte & 0x7FULL) << shift;
  8041603538:	4d 89 e8             	mov    %r13,%r8
  804160353b:	41 83 e0 7f          	and    $0x7f,%r8d
  804160353f:	49 d3 e0             	shl    %cl,%r8
  8041603542:	4c 09 c3             	or     %r8,%rbx
        shift += 7;
  8041603545:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041603549:	49 89 c0             	mov    %rax,%r8
  804160354c:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  8041603550:	45 84 ed             	test   %r13b,%r13b
  8041603553:	0f 89 4c ff ff ff    	jns    80416034a5 <naive_address_by_fname+0x16b>
  8041603559:	48 83 f9 3f          	cmp    $0x3f,%rcx
  804160355d:	76 d0                	jbe    804160352f <naive_address_by_fname+0x1f5>
  804160355f:	e9 41 ff ff ff       	jmp    80416034a5 <naive_address_by_fname+0x16b>
            while ((const unsigned char *)curr_abbrev_entry < addrs->abbrev_end) {
  8041603564:	4c 39 d8             	cmp    %r11,%rax
  8041603567:	0f 83 c6 00 00 00    	jae    8041603633 <naive_address_by_fname+0x2f9>
            const uint8_t *curr_abbrev_entry = abbrev_entry;
  804160356d:	48 89 c6             	mov    %rax,%rsi
    size_t shift = 0, count = 0;
  8041603570:	ba 00 00 00 00       	mov    $0x0,%edx
  8041603575:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  804160357a:	bf 00 00 00 00       	mov    $0x0,%edi
        byte = *addr++;
  804160357f:	48 83 c6 01          	add    $0x1,%rsi
  8041603583:	44 0f b6 4e ff       	movzbl -0x1(%rsi),%r9d
        result |= (byte & 0x7FULL) << shift;
  8041603588:	4d 89 c8             	mov    %r9,%r8
  804160358b:	41 83 e0 7f          	and    $0x7f,%r8d
  804160358f:	49 d3 e0             	shl    %cl,%r8
  8041603592:	4c 09 c7             	or     %r8,%rdi
        shift += 7;
  8041603595:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041603599:	49 89 d0             	mov    %rdx,%r8
  804160359c:	48 83 c2 01          	add    $0x1,%rdx
    } while (byte & 0x80 && shift < 64);
  80416035a0:	45 84 c9             	test   %r9b,%r9b
  80416035a3:	79 06                	jns    80416035ab <naive_address_by_fname+0x271>
  80416035a5:	48 83 f9 3f          	cmp    $0x3f,%rcx
  80416035a9:	76 d4                	jbe    804160357f <naive_address_by_fname+0x245>
    while (byte & 0x80) {
  80416035ab:	45 84 c9             	test   %r9b,%r9b
  80416035ae:	79 12                	jns    80416035c2 <naive_address_by_fname+0x288>
        byte = *addr++;
  80416035b0:	49 f7 d0             	not    %r8
  80416035b3:	4c 01 c6             	add    %r8,%rsi
  80416035b6:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
        count++;
  80416035ba:	48 83 c2 01          	add    $0x1,%rdx
    while (byte & 0x80) {
  80416035be:	84 c9                	test   %cl,%cl
  80416035c0:	78 f4                	js     80416035b6 <naive_address_by_fname+0x27c>
                curr_abbrev_entry += dwarf_read_uleb128(curr_abbrev_entry, &table_abbrev_code);
  80416035c2:	48 01 c2             	add    %rax,%rdx
  80416035c5:	48 89 d6             	mov    %rdx,%rsi
    size_t shift = 0, count = 0;
  80416035c8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416035cd:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  80416035d2:	41 b9 00 00 00 00    	mov    $0x0,%r9d
        byte = *addr++;
  80416035d8:	48 83 c6 01          	add    $0x1,%rsi
  80416035dc:	0f b6 5e ff          	movzbl -0x1(%rsi),%ebx
        result |= (byte & 0x7FULL) << shift;
  80416035e0:	49 89 d8             	mov    %rbx,%r8
  80416035e3:	41 83 e0 7f          	and    $0x7f,%r8d
  80416035e7:	49 d3 e0             	shl    %cl,%r8
  80416035ea:	4d 09 c1             	or     %r8,%r9
        shift += 7;
  80416035ed:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  80416035f1:	49 89 c5             	mov    %rax,%r13
  80416035f4:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  80416035f8:	41 89 d8             	mov    %ebx,%r8d
  80416035fb:	41 c0 e8 07          	shr    $0x7,%r8b
  80416035ff:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041603603:	41 0f 96 c4          	setbe  %r12b
  8041603607:	45 20 e0             	and    %r12b,%r8b
  804160360a:	75 cc                	jne    80416035d8 <naive_address_by_fname+0x29e>
    while (byte & 0x80) {
  804160360c:	45 89 c4             	mov    %r8d,%r12d
  804160360f:	84 db                	test   %bl,%bl
  8041603611:	79 12                	jns    8041603625 <naive_address_by_fname+0x2eb>
        byte = *addr++;
  8041603613:	49 f7 d5             	not    %r13
  8041603616:	4c 01 ee             	add    %r13,%rsi
  8041603619:	0f b6 0c 06          	movzbl (%rsi,%rax,1),%ecx
        count++;
  804160361d:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  8041603621:	84 c9                	test   %cl,%cl
  8041603623:	78 f4                	js     8041603619 <naive_address_by_fname+0x2df>
                curr_abbrev_entry += sizeof(Dwarf_Small);
  8041603625:	48 8d 44 02 01       	lea    0x1(%rdx,%rax,1),%rax
                if (table_abbrev_code == abbrev_code) break;
  804160362a:	49 39 fa             	cmp    %rdi,%r10
  804160362d:	0f 85 95 fe ff ff    	jne    80416034c8 <naive_address_by_fname+0x18e>
            if (tag == DW_TAG_subprogram || tag == DW_TAG_label) {
  8041603633:	48 89 c3             	mov    %rax,%rbx
  8041603636:	49 83 f9 2e          	cmp    $0x2e,%r9
  804160363a:	0f 94 c2             	sete   %dl
  804160363d:	49 83 f9 0a          	cmp    $0xa,%r9
  8041603641:	0f 94 c0             	sete   %al
  8041603644:	08 c2                	or     %al,%dl
  8041603646:	88 55 b7             	mov    %dl,-0x49(%rbp)
  8041603649:	0f 84 47 02 00 00    	je     8041603896 <naive_address_by_fname+0x55c>
                uintptr_t low_pc = 0;
  804160364f:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041603656:	00 
                bool found = 0;
  8041603657:	e9 b3 00 00 00       	jmp    804160370f <naive_address_by_fname+0x3d5>
                        entry += dwarf_read_abbrev_entry(entry, form, &low_pc, sizeof(low_pc), address_size);
  804160365c:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041603662:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041603667:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  804160366b:	44 89 ee             	mov    %r13d,%esi
  804160366e:	4c 89 ff             	mov    %r15,%rdi
  8041603671:	48 b8 c2 0e 60 41 80 	movabs $0x8041600ec2,%rax
  8041603678:	00 00 00 
  804160367b:	ff d0                	call   *%rax
  804160367d:	48 98                	cltq   
  804160367f:	49 01 c7             	add    %rax,%r15
  8041603682:	e9 88 00 00 00       	jmp    804160370f <naive_address_by_fname+0x3d5>
                            uint64_t str_offset = 0;
  8041603687:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  804160368e:	00 
                            entry += dwarf_read_abbrev_entry(entry, form, &str_offset, sizeof(uint64_t), address_size);
  804160368f:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041603695:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160369a:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  804160369e:	be 0e 00 00 00       	mov    $0xe,%esi
  80416036a3:	4c 89 ff             	mov    %r15,%rdi
  80416036a6:	48 b8 c2 0e 60 41 80 	movabs $0x8041600ec2,%rax
  80416036ad:	00 00 00 
  80416036b0:	ff d0                	call   *%rax
  80416036b2:	48 98                	cltq   
  80416036b4:	49 01 c7             	add    %rax,%r15
                            if (!strcmp(fname, (const char *)addrs->str_begin + str_offset)) found = 1;
  80416036b7:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416036bb:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80416036bf:	48 03 70 40          	add    0x40(%rax),%rsi
  80416036c3:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  80416036c7:	48 b8 a6 92 60 41 80 	movabs $0x80416092a6,%rax
  80416036ce:	00 00 00 
  80416036d1:	ff d0                	call   *%rax
  80416036d3:	85 c0                	test   %eax,%eax
  80416036d5:	0f b6 45 b7          	movzbl -0x49(%rbp),%eax
  80416036d9:	44 0f 44 e0          	cmove  %eax,%r12d
  80416036dd:	eb 30                	jmp    804160370f <naive_address_by_fname+0x3d5>
                        entry += dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);
  80416036df:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416036e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416036ea:	ba 00 00 00 00       	mov    $0x0,%edx
  80416036ef:	44 89 ee             	mov    %r13d,%esi
  80416036f2:	4c 89 ff             	mov    %r15,%rdi
  80416036f5:	48 b8 c2 0e 60 41 80 	movabs $0x8041600ec2,%rax
  80416036fc:	00 00 00 
  80416036ff:	ff d0                	call   *%rax
  8041603701:	48 98                	cltq   
  8041603703:	49 01 c7             	add    %rax,%r15
                } while (name || form);
  8041603706:	4d 09 f5             	or     %r14,%r13
  8041603709:	0f 84 18 01 00 00    	je     8041603827 <naive_address_by_fname+0x4ed>
    uint64_t result = 0;
  804160370f:	48 89 da             	mov    %rbx,%rdx
    size_t shift = 0, count = 0;
  8041603712:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603717:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  804160371c:	41 be 00 00 00 00    	mov    $0x0,%r14d
        byte = *addr++;
  8041603722:	48 83 c2 01          	add    $0x1,%rdx
  8041603726:	0f b6 7a ff          	movzbl -0x1(%rdx),%edi
        result |= (byte & 0x7FULL) << shift;
  804160372a:	48 89 fe             	mov    %rdi,%rsi
  804160372d:	83 e6 7f             	and    $0x7f,%esi
  8041603730:	48 d3 e6             	shl    %cl,%rsi
  8041603733:	49 09 f6             	or     %rsi,%r14
        shift += 7;
  8041603736:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  804160373a:	48 89 c6             	mov    %rax,%rsi
  804160373d:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  8041603741:	40 84 ff             	test   %dil,%dil
  8041603744:	79 06                	jns    804160374c <naive_address_by_fname+0x412>
  8041603746:	48 83 f9 3f          	cmp    $0x3f,%rcx
  804160374a:	76 d6                	jbe    8041603722 <naive_address_by_fname+0x3e8>
    while (byte & 0x80) {
  804160374c:	40 84 ff             	test   %dil,%dil
  804160374f:	79 12                	jns    8041603763 <naive_address_by_fname+0x429>
        byte = *addr++;
  8041603751:	48 f7 d6             	not    %rsi
  8041603754:	48 01 f2             	add    %rsi,%rdx
  8041603757:	0f b6 0c 02          	movzbl (%rdx,%rax,1),%ecx
        count++;
  804160375b:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  804160375f:	84 c9                	test   %cl,%cl
  8041603761:	78 f4                	js     8041603757 <naive_address_by_fname+0x41d>
                    curr_abbrev_entry += dwarf_read_uleb128(curr_abbrev_entry, &name);
  8041603763:	48 8d 14 03          	lea    (%rbx,%rax,1),%rdx
  8041603767:	48 89 d6             	mov    %rdx,%rsi
    size_t shift = 0, count = 0;
  804160376a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160376f:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041603774:	41 bd 00 00 00 00    	mov    $0x0,%r13d
        byte = *addr++;
  804160377a:	48 83 c6 01          	add    $0x1,%rsi
  804160377e:	44 0f b6 46 ff       	movzbl -0x1(%rsi),%r8d
        result |= (byte & 0x7FULL) << shift;
  8041603783:	4c 89 c7             	mov    %r8,%rdi
  8041603786:	83 e7 7f             	and    $0x7f,%edi
  8041603789:	48 d3 e7             	shl    %cl,%rdi
  804160378c:	49 09 fd             	or     %rdi,%r13
        shift += 7;
  804160378f:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041603793:	48 89 c7             	mov    %rax,%rdi
  8041603796:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  804160379a:	45 84 c0             	test   %r8b,%r8b
  804160379d:	79 06                	jns    80416037a5 <naive_address_by_fname+0x46b>
  804160379f:	48 83 f9 3f          	cmp    $0x3f,%rcx
  80416037a3:	76 d5                	jbe    804160377a <naive_address_by_fname+0x440>
    while (byte & 0x80) {
  80416037a5:	45 84 c0             	test   %r8b,%r8b
  80416037a8:	79 12                	jns    80416037bc <naive_address_by_fname+0x482>
        byte = *addr++;
  80416037aa:	48 f7 d7             	not    %rdi
  80416037ad:	48 01 fe             	add    %rdi,%rsi
  80416037b0:	0f b6 0c 06          	movzbl (%rsi,%rax,1),%ecx
        count++;
  80416037b4:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  80416037b8:	84 c9                	test   %cl,%cl
  80416037ba:	78 f4                	js     80416037b0 <naive_address_by_fname+0x476>
                    curr_abbrev_entry += dwarf_read_uleb128(curr_abbrev_entry, &form);
  80416037bc:	48 8d 1c 02          	lea    (%rdx,%rax,1),%rbx
                    if (name == DW_AT_low_pc) {
  80416037c0:	49 83 fe 11          	cmp    $0x11,%r14
  80416037c4:	0f 84 92 fe ff ff    	je     804160365c <naive_address_by_fname+0x322>
                    } else if (name == DW_AT_name) {
  80416037ca:	49 83 fe 03          	cmp    $0x3,%r14
  80416037ce:	0f 85 0b ff ff ff    	jne    80416036df <naive_address_by_fname+0x3a5>
                        if (form == DW_FORM_strp) {
  80416037d4:	49 83 fd 0e          	cmp    $0xe,%r13
  80416037d8:	0f 84 a9 fe ff ff    	je     8041603687 <naive_address_by_fname+0x34d>
                            if (!strcmp(fname, (const char *)entry)) found = 1;
  80416037de:	4c 89 fe             	mov    %r15,%rsi
  80416037e1:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  80416037e5:	48 b8 a6 92 60 41 80 	movabs $0x80416092a6,%rax
  80416037ec:	00 00 00 
  80416037ef:	ff d0                	call   *%rax
  80416037f1:	85 c0                	test   %eax,%eax
  80416037f3:	0f b6 45 b7          	movzbl -0x49(%rbp),%eax
  80416037f7:	44 0f 44 e0          	cmove  %eax,%r12d
                            entry += dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);
  80416037fb:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041603801:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041603806:	ba 00 00 00 00       	mov    $0x0,%edx
  804160380b:	44 89 ee             	mov    %r13d,%esi
  804160380e:	4c 89 ff             	mov    %r15,%rdi
  8041603811:	48 b8 c2 0e 60 41 80 	movabs $0x8041600ec2,%rax
  8041603818:	00 00 00 
  804160381b:	ff d0                	call   *%rax
  804160381d:	48 98                	cltq   
  804160381f:	49 01 c7             	add    %rax,%r15
  8041603822:	e9 e8 fe ff ff       	jmp    804160370f <naive_address_by_fname+0x3d5>
                if (found) {
  8041603827:	45 84 e4             	test   %r12b,%r12b
  804160382a:	0f 84 0f fc ff ff    	je     804160343f <naive_address_by_fname+0x105>
                    *offset = low_pc;
  8041603830:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8041603834:	48 8b 7d 90          	mov    -0x70(%rbp),%rdi
  8041603838:	48 89 07             	mov    %rax,(%rdi)
                    return 0;
  804160383b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603840:	e9 56 01 00 00       	jmp    804160399b <naive_address_by_fname+0x661>
            const uint8_t *curr_abbrev_entry = abbrev_entry;
  8041603845:	48 8b 5d a8          	mov    -0x58(%rbp),%rbx
  8041603849:	eb 4b                	jmp    8041603896 <naive_address_by_fname+0x55c>
  804160384b:	45 84 c0             	test   %r8b,%r8b
  804160384e:	79 12                	jns    8041603862 <naive_address_by_fname+0x528>
        byte = *addr++;
  8041603850:	48 f7 d7             	not    %rdi
  8041603853:	48 01 fe             	add    %rdi,%rsi
  8041603856:	0f b6 0c 06          	movzbl (%rsi,%rax,1),%ecx
        count++;
  804160385a:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  804160385e:	84 c9                	test   %cl,%cl
  8041603860:	78 f4                	js     8041603856 <naive_address_by_fname+0x51c>
                    curr_abbrev_entry += dwarf_read_uleb128(curr_abbrev_entry, &form);
  8041603862:	48 8d 1c 02          	lea    (%rdx,%rax,1),%rbx
                    entry += dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);
  8041603866:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160386c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041603871:	ba 00 00 00 00       	mov    $0x0,%edx
  8041603876:	44 89 ee             	mov    %r13d,%esi
  8041603879:	4c 89 ff             	mov    %r15,%rdi
  804160387c:	48 b8 c2 0e 60 41 80 	movabs $0x8041600ec2,%rax
  8041603883:	00 00 00 
  8041603886:	ff d0                	call   *%rax
  8041603888:	48 98                	cltq   
  804160388a:	49 01 c7             	add    %rax,%r15
                } while (name || form);
  804160388d:	4d 09 e5             	or     %r12,%r13
  8041603890:	0f 84 a9 fb ff ff    	je     804160343f <naive_address_by_fname+0x105>
            const uint8_t *curr_abbrev_entry = abbrev_entry;
  8041603896:	48 89 da             	mov    %rbx,%rdx
    size_t shift = 0, count = 0;
  8041603899:	b8 00 00 00 00       	mov    $0x0,%eax
  804160389e:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  80416038a3:	41 bc 00 00 00 00    	mov    $0x0,%r12d
        byte = *addr++;
  80416038a9:	48 83 c2 01          	add    $0x1,%rdx
  80416038ad:	0f b6 7a ff          	movzbl -0x1(%rdx),%edi
        result |= (byte & 0x7FULL) << shift;
  80416038b1:	48 89 fe             	mov    %rdi,%rsi
  80416038b4:	83 e6 7f             	and    $0x7f,%esi
  80416038b7:	48 d3 e6             	shl    %cl,%rsi
  80416038ba:	49 09 f4             	or     %rsi,%r12
        shift += 7;
  80416038bd:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  80416038c1:	48 89 c6             	mov    %rax,%rsi
  80416038c4:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  80416038c8:	40 84 ff             	test   %dil,%dil
  80416038cb:	79 06                	jns    80416038d3 <naive_address_by_fname+0x599>
  80416038cd:	48 83 f9 3f          	cmp    $0x3f,%rcx
  80416038d1:	76 d6                	jbe    80416038a9 <naive_address_by_fname+0x56f>
    while (byte & 0x80) {
  80416038d3:	40 84 ff             	test   %dil,%dil
  80416038d6:	79 12                	jns    80416038ea <naive_address_by_fname+0x5b0>
        byte = *addr++;
  80416038d8:	48 f7 d6             	not    %rsi
  80416038db:	48 01 f2             	add    %rsi,%rdx
  80416038de:	0f b6 0c 02          	movzbl (%rdx,%rax,1),%ecx
        count++;
  80416038e2:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  80416038e6:	84 c9                	test   %cl,%cl
  80416038e8:	78 f4                	js     80416038de <naive_address_by_fname+0x5a4>
                    curr_abbrev_entry += dwarf_read_uleb128(curr_abbrev_entry, &name);
  80416038ea:	48 8d 14 03          	lea    (%rbx,%rax,1),%rdx
  80416038ee:	48 89 d6             	mov    %rdx,%rsi
    size_t shift = 0, count = 0;
  80416038f1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416038f6:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  80416038fb:	41 bd 00 00 00 00    	mov    $0x0,%r13d
        byte = *addr++;
  8041603901:	48 83 c6 01          	add    $0x1,%rsi
  8041603905:	44 0f b6 46 ff       	movzbl -0x1(%rsi),%r8d
        result |= (byte & 0x7FULL) << shift;
  804160390a:	4c 89 c7             	mov    %r8,%rdi
  804160390d:	83 e7 7f             	and    $0x7f,%edi
  8041603910:	48 d3 e7             	shl    %cl,%rdi
  8041603913:	49 09 fd             	or     %rdi,%r13
        shift += 7;
  8041603916:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  804160391a:	48 89 c7             	mov    %rax,%rdi
  804160391d:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  8041603921:	45 84 c0             	test   %r8b,%r8b
  8041603924:	0f 89 21 ff ff ff    	jns    804160384b <naive_address_by_fname+0x511>
  804160392a:	48 83 f9 3f          	cmp    $0x3f,%rcx
  804160392e:	76 d1                	jbe    8041603901 <naive_address_by_fname+0x5c7>
  8041603930:	e9 16 ff ff ff       	jmp    804160384b <naive_address_by_fname+0x511>
    for (const uint8_t *entry = addrs->info_begin; (const unsigned char *)entry < addrs->info_end;) {
  8041603935:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041603939:	4c 39 78 28          	cmp    %r15,0x28(%rax)
  804160393d:	76 6b                	jbe    80416039aa <naive_address_by_fname+0x670>
    uint64_t initial_len = get_unaligned(addr, uint32_t);
  804160393f:	ba 04 00 00 00       	mov    $0x4,%edx
  8041603944:	4c 89 fe             	mov    %r15,%rsi
  8041603947:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160394b:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041603952:	00 00 00 
  8041603955:	ff d0                	call   *%rax
  8041603957:	8b 45 c8             	mov    -0x38(%rbp),%eax
    if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160395a:	48 ba 10 00 00 00 ff 	movabs $0xffffffff00000010,%rdx
  8041603961:	ff ff ff 
  8041603964:	48 01 c2             	add    %rax,%rdx
  8041603967:	48 83 fa 0f          	cmp    $0xf,%rdx
  804160396b:	77 4b                	ja     80416039b8 <naive_address_by_fname+0x67e>
        if (initial_len == DW_EXT_DWARF64) {
  804160396d:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8041603972:	48 39 d0             	cmp    %rdx,%rax
  8041603975:	0f 84 12 fa ff ff    	je     804160338d <naive_address_by_fname+0x53>
            cprintf("Unknown DWARF extension\n");
  804160397b:	48 bf 40 a4 60 41 80 	movabs $0x804160a440,%rdi
  8041603982:	00 00 00 
  8041603985:	b8 00 00 00 00       	mov    $0x0,%eax
  804160398a:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  8041603991:	00 00 00 
  8041603994:	ff d2                	call   *%rdx
        if (!count) return -E_BAD_DWARF;
  8041603996:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
  804160399b:	48 83 c4 48          	add    $0x48,%rsp
  804160399f:	5b                   	pop    %rbx
  80416039a0:	41 5c                	pop    %r12
  80416039a2:	41 5d                	pop    %r13
  80416039a4:	41 5e                	pop    %r14
  80416039a6:	41 5f                	pop    %r15
  80416039a8:	5d                   	pop    %rbp
  80416039a9:	c3                   	ret    
    return -E_NO_ENT;
  80416039aa:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80416039af:	eb ea                	jmp    804160399b <naive_address_by_fname+0x661>
    if (!flen) return -E_INVAL;
  80416039b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80416039b6:	eb e3                	jmp    804160399b <naive_address_by_fname+0x661>
    uint64_t count = sizeof(uint32_t);
  80416039b8:	bb 04 00 00 00       	mov    $0x4,%ebx
        entry += count;
  80416039bd:	49 01 df             	add    %rbx,%r15
        const uint8_t *entry_end = entry + len;
  80416039c0:	4c 01 f8             	add    %r15,%rax
  80416039c3:	48 89 45 98          	mov    %rax,-0x68(%rbp)
        Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  80416039c7:	ba 02 00 00 00       	mov    $0x2,%edx
  80416039cc:	4c 89 fe             	mov    %r15,%rsi
  80416039cf:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416039d3:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416039da:	00 00 00 
  80416039dd:	ff d0                	call   *%rax
        entry += sizeof(Dwarf_Half);
  80416039df:	49 8d 77 02          	lea    0x2(%r15),%rsi
        assert(version == 4 || version == 2);
  80416039e3:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416039e7:	83 e8 02             	sub    $0x2,%eax
  80416039ea:	66 a9 fd ff          	test   $0xfffd,%ax
  80416039ee:	0f 85 c0 f9 ff ff    	jne    80416033b4 <naive_address_by_fname+0x7a>
        Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  80416039f4:	ba 04 00 00 00       	mov    $0x4,%edx
  80416039f9:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416039fd:	48 bb 77 94 60 41 80 	movabs $0x8041609477,%rbx
  8041603a04:	00 00 00 
  8041603a07:	ff d3                	call   *%rbx
  8041603a09:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
        /**/ entry += sizeof(uint32_t);
  8041603a0d:	49 8d 77 06          	lea    0x6(%r15),%rsi
        Dwarf_Small address_size = get_unaligned(entry, Dwarf_Small);
  8041603a11:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603a16:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603a1a:	ff d3                	call   *%rbx
        entry += sizeof(Dwarf_Small);
  8041603a1c:	49 83 c7 07          	add    $0x7,%r15
        assert(address_size == sizeof(uintptr_t));
  8041603a20:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041603a24:	0f 85 bf f9 ff ff    	jne    80416033e9 <naive_address_by_fname+0xaf>
        const uint8_t *abbrev_entry = addrs->abbrev_begin + abbrev_offset;
  8041603a2a:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041603a2e:	4c 03 20             	add    (%rax),%r12
  8041603a31:	4c 89 65 a8          	mov    %r12,-0x58(%rbp)
        while (entry < entry_end) {
  8041603a35:	e9 05 fa ff ff       	jmp    804160343f <naive_address_by_fname+0x105>

0000008041603a3a <line_for_address>:
 * contain an offset in .debug_line of entry associated with compilation unit,
 * in which we search address `p`. This offset can be obtained from .debug_info
 * section, using the `file_name_by_info` function. */
int
line_for_address(const struct Dwarf_Addrs *addrs, uintptr_t p,
                 Dwarf_Off line_offset, int *lineno_store) {
  8041603a3a:	f3 0f 1e fa          	endbr64 
  8041603a3e:	55                   	push   %rbp
  8041603a3f:	48 89 e5             	mov    %rsp,%rbp
  8041603a42:	41 57                	push   %r15
  8041603a44:	41 56                	push   %r14
  8041603a46:	41 55                	push   %r13
  8041603a48:	41 54                	push   %r12
  8041603a4a:	53                   	push   %rbx
  8041603a4b:	48 83 ec 48          	sub    $0x48,%rsp
  8041603a4f:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  8041603a53:	48 89 4d 90          	mov    %rcx,-0x70(%rbp)
    if (line_offset > addrs->line_end - addrs->line_begin)
  8041603a57:	4c 8b 67 30          	mov    0x30(%rdi),%r12
  8041603a5b:	48 8b 47 38          	mov    0x38(%rdi),%rax
  8041603a5f:	4c 29 e0             	sub    %r12,%rax
        return -E_INVAL;
    if (!lineno_store)
  8041603a62:	48 39 d0             	cmp    %rdx,%rax
  8041603a65:	0f 82 41 07 00 00    	jb     80416041ac <line_for_address+0x772>
  8041603a6b:	48 85 c9             	test   %rcx,%rcx
  8041603a6e:	0f 84 38 07 00 00    	je     80416041ac <line_for_address+0x772>
        return -E_INVAL;

    const void *curr_addr = addrs->line_begin + line_offset;
  8041603a74:	49 01 d4             	add    %rdx,%r12
    uint64_t initial_len = get_unaligned(addr, uint32_t);
  8041603a77:	ba 04 00 00 00       	mov    $0x4,%edx
  8041603a7c:	4c 89 e6             	mov    %r12,%rsi
  8041603a7f:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603a83:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041603a8a:	00 00 00 
  8041603a8d:	ff d0                	call   *%rax
  8041603a8f:	8b 55 c8             	mov    -0x38(%rbp),%edx
    if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041603a92:	48 b8 10 00 00 00 ff 	movabs $0xffffffff00000010,%rax
  8041603a99:	ff ff ff 
  8041603a9c:	48 01 d0             	add    %rdx,%rax
  8041603a9f:	48 83 f8 0f          	cmp    $0xf,%rax
  8041603aa3:	0f 87 d5 07 00 00    	ja     804160427e <line_for_address+0x844>
        if (initial_len == DW_EXT_DWARF64) {
  8041603aa9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8041603aae:	48 39 c2             	cmp    %rax,%rdx
  8041603ab1:	74 25                	je     8041603ad8 <line_for_address+0x9e>
            cprintf("Unknown DWARF extension\n");
  8041603ab3:	48 bf 40 a4 60 41 80 	movabs $0x804160a440,%rdi
  8041603aba:	00 00 00 
  8041603abd:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603ac2:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  8041603ac9:	00 00 00 
  8041603acc:	ff d2                	call   *%rdx
    uint64_t unit_length = 0;
    uint32_t count;

    curr_addr += count = dwarf_entry_len(curr_addr, &unit_length);
    if (!count)
        return -E_BAD_DWARF;
  8041603ace:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  8041603ad3:	e9 c5 06 00 00       	jmp    804160419d <line_for_address+0x763>
            *len = get_unaligned((uint64_t *)addr + sizeof(uint32_t), uint64_t);
  8041603ad8:	49 8d 74 24 20       	lea    0x20(%r12),%rsi
  8041603add:	ba 08 00 00 00       	mov    $0x8,%edx
  8041603ae2:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603ae6:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041603aed:	00 00 00 
  8041603af0:	ff d0                	call   *%rax
  8041603af2:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
            count += sizeof(uint64_t);
  8041603af6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041603afb:	e9 83 07 00 00       	jmp    8041604283 <line_for_address+0x849>

    const void *unit_end = curr_addr + unit_length;
    Dwarf_Half version = get_unaligned(curr_addr, Dwarf_Half);
    curr_addr += sizeof(Dwarf_Half);
    assert(version == 4 || version == 3 || version == 2);
  8041603b00:	48 b9 58 a6 60 41 80 	movabs $0x804160a658,%rcx
  8041603b07:	00 00 00 
  8041603b0a:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041603b11:	00 00 00 
  8041603b14:	be dd 00 00 00       	mov    $0xdd,%esi
  8041603b19:	48 bf 11 a6 60 41 80 	movabs $0x804160a611,%rdi
  8041603b20:	00 00 00 
  8041603b23:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b28:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041603b2f:	00 00 00 
  8041603b32:	41 ff d0             	call   *%r8
            *len = get_unaligned((uint64_t *)addr + sizeof(uint32_t), uint64_t);
  8041603b35:	49 8d 74 24 22       	lea    0x22(%r12),%rsi
  8041603b3a:	ba 08 00 00 00       	mov    $0x8,%edx
  8041603b3f:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603b43:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041603b4a:	00 00 00 
  8041603b4d:	ff d0                	call   *%rax
  8041603b4f:	48 8b 5d c8          	mov    -0x38(%rbp),%rbx
            count += sizeof(uint64_t);
  8041603b53:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041603b58:	e9 5b 06 00 00       	jmp    80416041b8 <line_for_address+0x77e>
        return -E_BAD_DWARF;

    const uint8_t *program_addr = curr_addr + header_length;
    Dwarf_Small minimum_instruction_length =
            get_unaligned(curr_addr, Dwarf_Small);
    assert(minimum_instruction_length == 1);
  8041603b5d:	48 b9 88 a6 60 41 80 	movabs $0x804160a688,%rcx
  8041603b64:	00 00 00 
  8041603b67:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041603b6e:	00 00 00 
  8041603b71:	be e7 00 00 00       	mov    $0xe7,%esi
  8041603b76:	48 bf 11 a6 60 41 80 	movabs $0x804160a611,%rdi
  8041603b7d:	00 00 00 
  8041603b80:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b85:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041603b8c:	00 00 00 
  8041603b8f:	41 ff d0             	call   *%r8
    curr_addr += sizeof(Dwarf_Small);

    Dwarf_Small maximum_operations_per_instruction;
    if (version == 4) {
        maximum_operations_per_instruction = get_unaligned(curr_addr, Dwarf_Small);
  8041603b92:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603b97:	4c 89 e6             	mov    %r12,%rsi
  8041603b9a:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603b9e:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041603ba5:	00 00 00 
  8041603ba8:	ff d0                	call   *%rax
        curr_addr += sizeof(Dwarf_Small);
  8041603baa:	4d 8d 65 02          	lea    0x2(%r13),%r12
    } else {
        maximum_operations_per_instruction = 1;
    }
    assert(maximum_operations_per_instruction == 1);
  8041603bae:	80 7d c8 01          	cmpb   $0x1,-0x38(%rbp)
  8041603bb2:	0f 84 37 06 00 00    	je     80416041ef <line_for_address+0x7b5>
  8041603bb8:	48 b9 a8 a6 60 41 80 	movabs $0x804160a6a8,%rcx
  8041603bbf:	00 00 00 
  8041603bc2:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041603bc9:	00 00 00 
  8041603bcc:	be f1 00 00 00       	mov    $0xf1,%esi
  8041603bd1:	48 bf 11 a6 60 41 80 	movabs $0x804160a611,%rdi
  8041603bd8:	00 00 00 
  8041603bdb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603be0:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041603be7:	00 00 00 
  8041603bea:	41 ff d0             	call   *%r8
  8041603bed:	48 89 f0             	mov    %rsi,%rax
    size_t shift = 0, count = 0;
  8041603bf0:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint64_t result = 0;
  8041603bf5:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  8041603bfb:	49 89 d8             	mov    %rbx,%r8
        byte = *addr++;
  8041603bfe:	48 83 c0 01          	add    $0x1,%rax
  8041603c02:	0f b6 78 ff          	movzbl -0x1(%rax),%edi
        result |= (byte & 0x7FULL) << shift;
  8041603c06:	48 89 fa             	mov    %rdi,%rdx
  8041603c09:	83 e2 7f             	and    $0x7f,%edx
  8041603c0c:	48 d3 e2             	shl    %cl,%rdx
  8041603c0f:	49 09 d4             	or     %rdx,%r12
        shift += 7;
  8041603c12:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041603c16:	4c 8d 48 ff          	lea    -0x1(%rax),%r9
  8041603c1a:	4c 89 ca             	mov    %r9,%rdx
  8041603c1d:	48 29 da             	sub    %rbx,%rdx
    } while (byte & 0x80 && shift < 64);
  8041603c20:	40 84 ff             	test   %dil,%dil
  8041603c23:	79 06                	jns    8041603c2b <line_for_address+0x1f1>
  8041603c25:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041603c29:	76 d3                	jbe    8041603bfe <line_for_address+0x1c4>
    while (byte & 0x80) {
  8041603c2b:	40 84 ff             	test   %dil,%dil
  8041603c2e:	79 12                	jns    8041603c42 <line_for_address+0x208>
        byte = *addr++;
  8041603c30:	4d 29 c8             	sub    %r9,%r8
  8041603c33:	4c 01 c0             	add    %r8,%rax
  8041603c36:	0f b6 0c 10          	movzbl (%rax,%rdx,1),%ecx
        count++;
  8041603c3a:	48 83 c2 01          	add    $0x1,%rdx
    while (byte & 0x80) {
  8041603c3e:	84 c9                	test   %cl,%cl
  8041603c40:	78 f4                	js     8041603c36 <line_for_address+0x1fc>
            program_addr += count;
  8041603c42:	89 d2                	mov    %edx,%edx
  8041603c44:	4c 8d 2c 16          	lea    (%rsi,%rdx,1),%r13
            const uint8_t *opcode_end = program_addr + length;
  8041603c48:	4d 01 ec             	add    %r13,%r12
            opcode = get_unaligned(program_addr, Dwarf_Small);
  8041603c4b:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603c50:	4c 89 ee             	mov    %r13,%rsi
  8041603c53:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603c57:	41 ff d7             	call   *%r15
  8041603c5a:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
            program_addr += sizeof(Dwarf_Small);
  8041603c5e:	49 8d 5d 01          	lea    0x1(%r13),%rbx
            switch (opcode) {
  8041603c62:	3c 03                	cmp    $0x3,%al
  8041603c64:	0f 84 ef 00 00 00    	je     8041603d59 <line_for_address+0x31f>
  8041603c6a:	77 65                	ja     8041603cd1 <line_for_address+0x297>
  8041603c6c:	3c 01                	cmp    $0x1,%al
  8041603c6e:	0f 84 af 00 00 00    	je     8041603d23 <line_for_address+0x2e9>
  8041603c74:	3c 02                	cmp    $0x2,%al
  8041603c76:	0f 85 bc 01 00 00    	jne    8041603e38 <line_for_address+0x3fe>
                state->address = get_unaligned(program_addr, uintptr_t);
  8041603c7c:	ba 08 00 00 00       	mov    $0x8,%edx
  8041603c81:	48 89 de             	mov    %rbx,%rsi
  8041603c84:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603c88:	41 ff d7             	call   *%r15
  8041603c8b:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
                program_addr += sizeof(uintptr_t);
  8041603c8f:	49 8d 5d 09          	lea    0x9(%r13),%rbx
            assert(program_addr == opcode_end);
  8041603c93:	49 39 dc             	cmp    %rbx,%r12
  8041603c96:	0f 84 7d 04 00 00    	je     8041604119 <line_for_address+0x6df>
  8041603c9c:	48 b9 37 a6 60 41 80 	movabs $0x804160a637,%rcx
  8041603ca3:	00 00 00 
  8041603ca6:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041603cad:	00 00 00 
  8041603cb0:	be 61 00 00 00       	mov    $0x61,%esi
  8041603cb5:	48 bf 11 a6 60 41 80 	movabs $0x804160a611,%rdi
  8041603cbc:	00 00 00 
  8041603cbf:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603cc4:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041603ccb:	00 00 00 
  8041603cce:	41 ff d0             	call   *%r8
            switch (opcode) {
  8041603cd1:	3c 04                	cmp    $0x4,%al
  8041603cd3:	0f 85 5f 01 00 00    	jne    8041603e38 <line_for_address+0x3fe>
  8041603cd9:	48 89 d8             	mov    %rbx,%rax
  8041603cdc:	b9 00 00 00 00       	mov    $0x0,%ecx
        byte = *addr++;
  8041603ce1:	48 83 c0 01          	add    $0x1,%rax
        shift += 7;
  8041603ce5:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041603ce9:	48 8d 78 ff          	lea    -0x1(%rax),%rdi
  8041603ced:	48 89 fa             	mov    %rdi,%rdx
  8041603cf0:	4c 29 ea             	sub    %r13,%rdx
    } while (byte & 0x80 && shift < 64);
  8041603cf3:	0f b6 70 ff          	movzbl -0x1(%rax),%esi
  8041603cf7:	40 84 f6             	test   %sil,%sil
  8041603cfa:	79 06                	jns    8041603d02 <line_for_address+0x2c8>
  8041603cfc:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041603d00:	76 df                	jbe    8041603ce1 <line_for_address+0x2a7>
    while (byte & 0x80) {
  8041603d02:	40 84 f6             	test   %sil,%sil
  8041603d05:	79 12                	jns    8041603d19 <line_for_address+0x2df>
        byte = *addr++;
  8041603d07:	49 29 fd             	sub    %rdi,%r13
  8041603d0a:	4c 01 e8             	add    %r13,%rax
  8041603d0d:	0f b6 0c 10          	movzbl (%rax,%rdx,1),%ecx
        count++;
  8041603d11:	48 83 c2 01          	add    $0x1,%rdx
    while (byte & 0x80) {
  8041603d15:	84 c9                	test   %cl,%cl
  8041603d17:	78 f4                	js     8041603d0d <line_for_address+0x2d3>
                program_addr += count;
  8041603d19:	89 d2                	mov    %edx,%edx
  8041603d1b:	48 01 d3             	add    %rdx,%rbx
            } break;
  8041603d1e:	e9 70 ff ff ff       	jmp    8041603c93 <line_for_address+0x259>
                if (last_state.address <= destination_addr &&
  8041603d23:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041603d27:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  8041603d2b:	48 39 f0             	cmp    %rsi,%rax
  8041603d2e:	0f 82 32 01 00 00    	jb     8041603e66 <line_for_address+0x42c>
  8041603d34:	4c 39 f0             	cmp    %r14,%rax
  8041603d37:	0f 82 3c 04 00 00    	jb     8041604179 <line_for_address+0x73f>
                last_state = *state;
  8041603d3d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041603d40:	89 45 9c             	mov    %eax,-0x64(%rbp)
  8041603d43:	4c 89 75 a8          	mov    %r14,-0x58(%rbp)
                *state = (struct Line_Number_State){
  8041603d47:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%rbp)
  8041603d4e:	41 be 00 00 00 00    	mov    $0x0,%r14d
  8041603d54:	e9 3a ff ff ff       	jmp    8041603c93 <line_for_address+0x259>
                while (*program_addr++)
  8041603d59:	48 83 c3 01          	add    $0x1,%rbx
  8041603d5d:	80 7b ff 00          	cmpb   $0x0,-0x1(%rbx)
  8041603d61:	75 f6                	jne    8041603d59 <line_for_address+0x31f>
  8041603d63:	48 89 da             	mov    %rbx,%rdx
    size_t shift = 0, count = 0;
  8041603d66:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d6b:	b9 00 00 00 00       	mov    $0x0,%ecx
        byte = *addr++;
  8041603d70:	48 83 c2 01          	add    $0x1,%rdx
        shift += 7;
  8041603d74:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041603d78:	48 89 c7             	mov    %rax,%rdi
  8041603d7b:	48 83 c0 01          	add    $0x1,%rax
    } while (byte & 0x80 && shift < 64);
  8041603d7f:	0f b6 72 ff          	movzbl -0x1(%rdx),%esi
  8041603d83:	40 84 f6             	test   %sil,%sil
  8041603d86:	79 06                	jns    8041603d8e <line_for_address+0x354>
  8041603d88:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041603d8c:	76 e2                	jbe    8041603d70 <line_for_address+0x336>
    while (byte & 0x80) {
  8041603d8e:	40 84 f6             	test   %sil,%sil
  8041603d91:	79 12                	jns    8041603da5 <line_for_address+0x36b>
        byte = *addr++;
  8041603d93:	48 f7 d7             	not    %rdi
  8041603d96:	48 01 fa             	add    %rdi,%rdx
  8041603d99:	0f b6 0c 02          	movzbl (%rdx,%rax,1),%ecx
        count++;
  8041603d9d:	48 83 c0 01          	add    $0x1,%rax
    while (byte & 0x80) {
  8041603da1:	84 c9                	test   %cl,%cl
  8041603da3:	78 f4                	js     8041603d99 <line_for_address+0x35f>
                program_addr += dwarf_read_uleb128(program_addr, &dir_index);
  8041603da5:	48 01 d8             	add    %rbx,%rax
  8041603da8:	48 89 c1             	mov    %rax,%rcx
    size_t shift = 0, count = 0;
  8041603dab:	ba 00 00 00 00       	mov    $0x0,%edx
  8041603db0:	be 00 00 00 00       	mov    $0x0,%esi
        byte = *addr++;
  8041603db5:	48 83 c1 01          	add    $0x1,%rcx
        shift += 7;
  8041603db9:	48 83 c6 07          	add    $0x7,%rsi
        count++;
  8041603dbd:	49 89 d0             	mov    %rdx,%r8
  8041603dc0:	48 83 c2 01          	add    $0x1,%rdx
    } while (byte & 0x80 && shift < 64);
  8041603dc4:	0f b6 79 ff          	movzbl -0x1(%rcx),%edi
  8041603dc8:	40 84 ff             	test   %dil,%dil
  8041603dcb:	79 06                	jns    8041603dd3 <line_for_address+0x399>
  8041603dcd:	48 83 fe 3f          	cmp    $0x3f,%rsi
  8041603dd1:	76 e2                	jbe    8041603db5 <line_for_address+0x37b>
    while (byte & 0x80) {
  8041603dd3:	40 84 ff             	test   %dil,%dil
  8041603dd6:	79 13                	jns    8041603deb <line_for_address+0x3b1>
        byte = *addr++;
  8041603dd8:	49 f7 d0             	not    %r8
  8041603ddb:	4c 01 c1             	add    %r8,%rcx
  8041603dde:	0f b6 34 11          	movzbl (%rcx,%rdx,1),%esi
        count++;
  8041603de2:	48 83 c2 01          	add    $0x1,%rdx
    while (byte & 0x80) {
  8041603de6:	40 84 f6             	test   %sil,%sil
  8041603de9:	78 f3                	js     8041603dde <line_for_address+0x3a4>
                program_addr += dwarf_read_uleb128(program_addr, &last_mod);
  8041603deb:	48 01 d0             	add    %rdx,%rax
  8041603dee:	48 89 c2             	mov    %rax,%rdx
    size_t shift = 0, count = 0;
  8041603df1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041603df6:	b9 00 00 00 00       	mov    $0x0,%ecx
        byte = *addr++;
  8041603dfb:	48 83 c2 01          	add    $0x1,%rdx
        shift += 7;
  8041603dff:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041603e03:	48 89 df             	mov    %rbx,%rdi
  8041603e06:	48 83 c3 01          	add    $0x1,%rbx
    } while (byte & 0x80 && shift < 64);
  8041603e0a:	0f b6 72 ff          	movzbl -0x1(%rdx),%esi
  8041603e0e:	40 84 f6             	test   %sil,%sil
  8041603e11:	79 06                	jns    8041603e19 <line_for_address+0x3df>
  8041603e13:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041603e17:	76 e2                	jbe    8041603dfb <line_for_address+0x3c1>
    while (byte & 0x80) {
  8041603e19:	40 84 f6             	test   %sil,%sil
  8041603e1c:	79 12                	jns    8041603e30 <line_for_address+0x3f6>
        byte = *addr++;
  8041603e1e:	48 f7 d7             	not    %rdi
  8041603e21:	48 01 fa             	add    %rdi,%rdx
  8041603e24:	0f b6 0c 1a          	movzbl (%rdx,%rbx,1),%ecx
        count++;
  8041603e28:	48 83 c3 01          	add    $0x1,%rbx
    while (byte & 0x80) {
  8041603e2c:	84 c9                	test   %cl,%cl
  8041603e2e:	78 f4                	js     8041603e24 <line_for_address+0x3ea>
                program_addr += dwarf_read_uleb128(program_addr, &length);
  8041603e30:	48 01 c3             	add    %rax,%rbx
            } break;
  8041603e33:	e9 5b fe ff ff       	jmp    8041603c93 <line_for_address+0x259>
            switch (opcode) {
  8041603e38:	0f b6 c8             	movzbl %al,%ecx
                panic("Unknown opcode: %x", opcode);
  8041603e3b:	48 ba 24 a6 60 41 80 	movabs $0x804160a624,%rdx
  8041603e42:	00 00 00 
  8041603e45:	be 5e 00 00 00       	mov    $0x5e,%esi
  8041603e4a:	48 bf 11 a6 60 41 80 	movabs $0x804160a611,%rdi
  8041603e51:	00 00 00 
  8041603e54:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603e59:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041603e60:	00 00 00 
  8041603e63:	41 ff d0             	call   *%r8
                last_state = *state;
  8041603e66:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041603e69:	89 45 9c             	mov    %eax,-0x64(%rbp)
  8041603e6c:	4c 89 75 a8          	mov    %r14,-0x58(%rbp)
                *state = (struct Line_Number_State){
  8041603e70:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%rbp)
  8041603e77:	41 be 00 00 00 00    	mov    $0x0,%r14d
  8041603e7d:	e9 11 fe ff ff       	jmp    8041603c93 <line_for_address+0x259>
                if (last_state.address <= destination_addr &&
  8041603e82:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041603e86:	48 8b 5d a8          	mov    -0x58(%rbp),%rbx
  8041603e8a:	48 39 d8             	cmp    %rbx,%rax
  8041603e8d:	0f 82 ce 02 00 00    	jb     8041604161 <line_for_address+0x727>
  8041603e93:	4c 39 f0             	cmp    %r14,%rax
  8041603e96:	0f 82 e5 02 00 00    	jb     8041604181 <line_for_address+0x747>
                last_state = *state;
  8041603e9c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041603e9f:	89 45 9c             	mov    %eax,-0x64(%rbp)
  8041603ea2:	4c 89 75 a8          	mov    %r14,-0x58(%rbp)
        program_addr += sizeof(Dwarf_Small);
  8041603ea6:	48 89 f3             	mov    %rsi,%rbx
  8041603ea9:	e9 6b 02 00 00       	jmp    8041604119 <line_for_address+0x6df>
            switch (opcode) {
  8041603eae:	48 89 f0             	mov    %rsi,%rax
  8041603eb1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041603eb6:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  8041603ebc:	49 89 d9             	mov    %rbx,%r9
        byte = *addr++;
  8041603ebf:	48 83 c0 01          	add    $0x1,%rax
  8041603ec3:	0f b6 78 ff          	movzbl -0x1(%rax),%edi
        result |= (byte & 0x7FULL) << shift;
  8041603ec7:	48 89 fa             	mov    %rdi,%rdx
  8041603eca:	83 e2 7f             	and    $0x7f,%edx
  8041603ecd:	48 d3 e2             	shl    %cl,%rdx
  8041603ed0:	49 09 d0             	or     %rdx,%r8
        shift += 7;
  8041603ed3:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041603ed7:	4c 8d 50 ff          	lea    -0x1(%rax),%r10
  8041603edb:	4c 89 d2             	mov    %r10,%rdx
  8041603ede:	48 29 da             	sub    %rbx,%rdx
    } while (byte & 0x80 && shift < 64);
  8041603ee1:	40 84 ff             	test   %dil,%dil
  8041603ee4:	79 06                	jns    8041603eec <line_for_address+0x4b2>
  8041603ee6:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041603eea:	76 d3                	jbe    8041603ebf <line_for_address+0x485>
    while (byte & 0x80) {
  8041603eec:	40 84 ff             	test   %dil,%dil
  8041603eef:	79 12                	jns    8041603f03 <line_for_address+0x4c9>
        byte = *addr++;
  8041603ef1:	4d 29 d1             	sub    %r10,%r9
  8041603ef4:	4c 01 c8             	add    %r9,%rax
  8041603ef7:	0f b6 0c 10          	movzbl (%rax,%rdx,1),%ecx
        count++;
  8041603efb:	48 83 c2 01          	add    $0x1,%rdx
    while (byte & 0x80) {
  8041603eff:	84 c9                	test   %cl,%cl
  8041603f01:	78 f4                	js     8041603ef7 <line_for_address+0x4bd>
                state->address += info->minimum_instruction_length *
  8041603f03:	4d 01 c6             	add    %r8,%r14
                program_addr += count;
  8041603f06:	89 d2                	mov    %edx,%edx
  8041603f08:	48 8d 1c 16          	lea    (%rsi,%rdx,1),%rbx
            } break;
  8041603f0c:	e9 08 02 00 00       	jmp    8041604119 <line_for_address+0x6df>
            switch (opcode) {
  8041603f11:	48 89 f0             	mov    %rsi,%rax
  8041603f14:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  8041603f1a:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041603f1f:	49 89 d9             	mov    %rbx,%r9
        byte = *addr++;
  8041603f22:	48 83 c0 01          	add    $0x1,%rax
  8041603f26:	0f b6 78 ff          	movzbl -0x1(%rax),%edi
        result |= (byte & 0x7FULL) << shift;
  8041603f2a:	48 89 fa             	mov    %rdi,%rdx
  8041603f2d:	83 e2 7f             	and    $0x7f,%edx
  8041603f30:	48 d3 e2             	shl    %cl,%rdx
  8041603f33:	49 09 d0             	or     %rdx,%r8
        shift += 7;
  8041603f36:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041603f3a:	4c 8d 50 ff          	lea    -0x1(%rax),%r10
  8041603f3e:	4c 89 d2             	mov    %r10,%rdx
  8041603f41:	48 29 da             	sub    %rbx,%rdx
    } while (byte & 0x80 && shift < 64);
  8041603f44:	40 84 ff             	test   %dil,%dil
  8041603f47:	79 06                	jns    8041603f4f <line_for_address+0x515>
  8041603f49:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041603f4d:	76 d3                	jbe    8041603f22 <line_for_address+0x4e8>
    while (byte & 0x80) {
  8041603f4f:	40 84 ff             	test   %dil,%dil
  8041603f52:	79 21                	jns    8041603f75 <line_for_address+0x53b>
        byte = *addr++;
  8041603f54:	4d 29 d1             	sub    %r10,%r9
  8041603f57:	4c 01 c8             	add    %r9,%rax
  8041603f5a:	0f b6 0c 10          	movzbl (%rax,%rdx,1),%ecx
        count++;
  8041603f5e:	48 83 c2 01          	add    $0x1,%rdx
    while (byte & 0x80) {
  8041603f62:	84 c9                	test   %cl,%cl
  8041603f64:	78 f4                	js     8041603f5a <line_for_address+0x520>
                state->line += (int)line_incr;
  8041603f66:	44 01 45 b8          	add    %r8d,-0x48(%rbp)
                program_addr += count;
  8041603f6a:	89 d2                	mov    %edx,%edx
  8041603f6c:	48 8d 1c 16          	lea    (%rsi,%rdx,1),%rbx
            } break;
  8041603f70:	e9 a4 01 00 00       	jmp    8041604119 <line_for_address+0x6df>
    if (shift < 8 * sizeof(result) && byte & 0x40)
  8041603f75:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041603f79:	77 eb                	ja     8041603f66 <line_for_address+0x52c>
  8041603f7b:	40 f6 c7 40          	test   $0x40,%dil
  8041603f7f:	74 e5                	je     8041603f66 <line_for_address+0x52c>
        result |= (-1U << shift);
  8041603f81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8041603f86:	d3 e0                	shl    %cl,%eax
  8041603f88:	49 09 c0             	or     %rax,%r8
  8041603f8b:	eb d9                	jmp    8041603f66 <line_for_address+0x52c>
            switch (opcode) {
  8041603f8d:	48 89 f0             	mov    %rsi,%rax
  8041603f90:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041603f95:	49 89 d9             	mov    %rbx,%r9
        byte = *addr++;
  8041603f98:	48 83 c0 01          	add    $0x1,%rax
        shift += 7;
  8041603f9c:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041603fa0:	4c 8d 40 ff          	lea    -0x1(%rax),%r8
  8041603fa4:	4c 89 c2             	mov    %r8,%rdx
  8041603fa7:	48 29 da             	sub    %rbx,%rdx
    } while (byte & 0x80 && shift < 64);
  8041603faa:	0f b6 78 ff          	movzbl -0x1(%rax),%edi
  8041603fae:	40 84 ff             	test   %dil,%dil
  8041603fb1:	79 06                	jns    8041603fb9 <line_for_address+0x57f>
  8041603fb3:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041603fb7:	76 df                	jbe    8041603f98 <line_for_address+0x55e>
    while (byte & 0x80) {
  8041603fb9:	40 84 ff             	test   %dil,%dil
  8041603fbc:	79 15                	jns    8041603fd3 <line_for_address+0x599>
        byte = *addr++;
  8041603fbe:	4c 89 c9             	mov    %r9,%rcx
  8041603fc1:	4c 29 c1             	sub    %r8,%rcx
  8041603fc4:	48 01 c8             	add    %rcx,%rax
  8041603fc7:	0f b6 0c 10          	movzbl (%rax,%rdx,1),%ecx
        count++;
  8041603fcb:	48 83 c2 01          	add    $0x1,%rdx
    while (byte & 0x80) {
  8041603fcf:	84 c9                	test   %cl,%cl
  8041603fd1:	78 f4                	js     8041603fc7 <line_for_address+0x58d>
                program_addr += count;
  8041603fd3:	89 d2                	mov    %edx,%edx
  8041603fd5:	48 8d 1c 16          	lea    (%rsi,%rdx,1),%rbx
            } break;
  8041603fd9:	e9 3b 01 00 00       	jmp    8041604119 <line_for_address+0x6df>
            switch (opcode) {
  8041603fde:	48 89 f0             	mov    %rsi,%rax
  8041603fe1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041603fe6:	49 89 d9             	mov    %rbx,%r9
        byte = *addr++;
  8041603fe9:	48 83 c0 01          	add    $0x1,%rax
        shift += 7;
  8041603fed:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041603ff1:	4c 8d 40 ff          	lea    -0x1(%rax),%r8
  8041603ff5:	4c 89 c2             	mov    %r8,%rdx
  8041603ff8:	48 29 da             	sub    %rbx,%rdx
    } while (byte & 0x80 && shift < 64);
  8041603ffb:	0f b6 78 ff          	movzbl -0x1(%rax),%edi
  8041603fff:	40 84 ff             	test   %dil,%dil
  8041604002:	79 06                	jns    804160400a <line_for_address+0x5d0>
  8041604004:	48 83 f9 3f          	cmp    $0x3f,%rcx
  8041604008:	76 df                	jbe    8041603fe9 <line_for_address+0x5af>
    while (byte & 0x80) {
  804160400a:	40 84 ff             	test   %dil,%dil
  804160400d:	79 15                	jns    8041604024 <line_for_address+0x5ea>
        byte = *addr++;
  804160400f:	4c 89 c9             	mov    %r9,%rcx
  8041604012:	4c 29 c1             	sub    %r8,%rcx
  8041604015:	48 01 c8             	add    %rcx,%rax
  8041604018:	0f b6 0c 10          	movzbl (%rax,%rdx,1),%ecx
        count++;
  804160401c:	48 83 c2 01          	add    $0x1,%rdx
    while (byte & 0x80) {
  8041604020:	84 c9                	test   %cl,%cl
  8041604022:	78 f4                	js     8041604018 <line_for_address+0x5de>
                program_addr += count;
  8041604024:	89 d2                	mov    %edx,%edx
  8041604026:	48 8d 1c 16          	lea    (%rsi,%rdx,1),%rbx
            } break;
  804160402a:	e9 ea 00 00 00       	jmp    8041604119 <line_for_address+0x6df>
                int op_advance = adjusted_opcode / info->line_range;
  804160402f:	0f b7 45 9a          	movzwl -0x66(%rbp),%eax
  8041604033:	f6 75 be             	divb   -0x42(%rbp)
                state->address += info->minimum_instruction_length *
  8041604036:	0f b6 c0             	movzbl %al,%eax
  8041604039:	49 01 c6             	add    %rax,%r14
        program_addr += sizeof(Dwarf_Small);
  804160403c:	48 89 f3             	mov    %rsi,%rbx
            } break;
  804160403f:	e9 d5 00 00 00       	jmp    8041604119 <line_for_address+0x6df>
                state->address += get_unaligned(program_addr, Dwarf_Half);
  8041604044:	ba 02 00 00 00       	mov    $0x2,%edx
  8041604049:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160404d:	41 ff d7             	call   *%r15
  8041604050:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041604054:	49 01 c6             	add    %rax,%r14
                program_addr += sizeof(Dwarf_Half);
  8041604057:	48 83 c3 03          	add    $0x3,%rbx
            } break;
  804160405b:	e9 b9 00 00 00       	jmp    8041604119 <line_for_address+0x6df>
            switch (opcode) {
  8041604060:	48 89 f0             	mov    %rsi,%rax
  8041604063:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041604068:	49 89 d9             	mov    %rbx,%r9
        byte = *addr++;
  804160406b:	48 83 c0 01          	add    $0x1,%rax
        shift += 7;
  804160406f:	48 83 c1 07          	add    $0x7,%rcx
        count++;
  8041604073:	4c 8d 40 ff          	lea    -0x1(%rax),%r8
  8041604077:	4c 89 c2             	mov    %r8,%rdx
  804160407a:	48 29 da             	sub    %rbx,%rdx
    } while (byte & 0x80 && shift < 64);
  804160407d:	0f b6 78 ff          	movzbl -0x1(%rax),%edi
  8041604081:	40 84 ff             	test   %dil,%dil
  8041604084:	79 06                	jns    804160408c <line_for_address+0x652>
  8041604086:	48 83 f9 3f          	cmp    $0x3f,%rcx
  804160408a:	76 df                	jbe    804160406b <line_for_address+0x631>
    while (byte & 0x80) {
  804160408c:	40 84 ff             	test   %dil,%dil
  804160408f:	79 15                	jns    80416040a6 <line_for_address+0x66c>
        byte = *addr++;
  8041604091:	4c 89 c9             	mov    %r9,%rcx
  8041604094:	4c 29 c1             	sub    %r8,%rcx
  8041604097:	48 01 c8             	add    %rcx,%rax
  804160409a:	0f b6 0c 10          	movzbl (%rax,%rdx,1),%ecx
        count++;
  804160409e:	48 83 c2 01          	add    $0x1,%rdx
    while (byte & 0x80) {
  80416040a2:	84 c9                	test   %cl,%cl
  80416040a4:	78 f4                	js     804160409a <line_for_address+0x660>
                program_addr += count;
  80416040a6:	89 d2                	mov    %edx,%edx
  80416040a8:	48 8d 1c 16          	lea    (%rsi,%rdx,1),%rbx
            } break;
  80416040ac:	eb 6b                	jmp    8041604119 <line_for_address+0x6df>
            switch (opcode) {
  80416040ae:	0f b6 c8             	movzbl %al,%ecx
                panic("Unknown opcode: %x", opcode);
  80416040b1:	48 ba 24 a6 60 41 80 	movabs $0x804160a624,%rdx
  80416040b8:	00 00 00 
  80416040bb:	be a5 00 00 00       	mov    $0xa5,%esi
  80416040c0:	48 bf 11 a6 60 41 80 	movabs $0x804160a611,%rdi
  80416040c7:	00 00 00 
  80416040ca:	b8 00 00 00 00       	mov    $0x0,%eax
  80416040cf:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  80416040d6:	00 00 00 
  80416040d9:	41 ff d0             	call   *%r8
            Dwarf_Small adjusted_opcode = opcode - info->opcode_base;
  80416040dc:	2a 45 bf             	sub    -0x41(%rbp),%al
            state->line += (info->line_base + (adjusted_opcode % info->line_range));
  80416040df:	0f b6 c0             	movzbl %al,%eax
  80416040e2:	f6 75 be             	divb   -0x42(%rbp)
  80416040e5:	0f b6 d4             	movzbl %ah,%edx
  80416040e8:	0f b6 d2             	movzbl %dl,%edx
  80416040eb:	0f be 4d bd          	movsbl -0x43(%rbp),%ecx
  80416040ef:	01 ca                	add    %ecx,%edx
  80416040f1:	01 55 b8             	add    %edx,-0x48(%rbp)
            state->address += info->minimum_instruction_length *
  80416040f4:	0f b6 c0             	movzbl %al,%eax
  80416040f7:	49 01 c6             	add    %rax,%r14
            if (last_state.address <= destination_addr && destination_addr < state->address) {
  80416040fa:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  80416040fe:	4c 39 f0             	cmp    %r14,%rax
  8041604101:	73 09                	jae    804160410c <line_for_address+0x6d2>
  8041604103:	48 8b 5d a8          	mov    -0x58(%rbp),%rbx
  8041604107:	48 39 d8             	cmp    %rbx,%rax
  804160410a:	73 7d                	jae    8041604189 <line_for_address+0x74f>
            last_state = *state;
  804160410c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160410f:	89 45 9c             	mov    %eax,-0x64(%rbp)
  8041604112:	4c 89 75 a8          	mov    %r14,-0x58(%rbp)
        program_addr += sizeof(Dwarf_Small);
  8041604116:	48 89 f3             	mov    %rsi,%rbx
    while (program_addr < end_addr) {
  8041604119:	48 39 5d b0          	cmp    %rbx,-0x50(%rbp)
  804160411d:	76 70                	jbe    804160418f <line_for_address+0x755>
        Dwarf_Small opcode = get_unaligned(program_addr, Dwarf_Small);
  804160411f:	ba 01 00 00 00       	mov    $0x1,%edx
  8041604124:	48 89 de             	mov    %rbx,%rsi
  8041604127:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160412b:	41 ff d7             	call   *%r15
  804160412e:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
        program_addr += sizeof(Dwarf_Small);
  8041604132:	48 8d 73 01          	lea    0x1(%rbx),%rsi
        if (opcode == 0) {
  8041604136:	84 c0                	test   %al,%al
  8041604138:	0f 84 af fa ff ff    	je     8041603bed <line_for_address+0x1b3>
        } else if (opcode < info->opcode_base) {
  804160413e:	38 45 bf             	cmp    %al,-0x41(%rbp)
  8041604141:	76 99                	jbe    80416040dc <line_for_address+0x6a2>
            switch (opcode) {
  8041604143:	3c 0c                	cmp    $0xc,%al
  8041604145:	0f 87 63 ff ff ff    	ja     80416040ae <line_for_address+0x674>
  804160414b:	0f b6 d0             	movzbl %al,%edx
  804160414e:	48 bf d0 a6 60 41 80 	movabs $0x804160a6d0,%rdi
  8041604155:	00 00 00 
  8041604158:	3e ff 24 d7          	notrack jmp *(%rdi,%rdx,8)
  804160415c:	48 89 f3             	mov    %rsi,%rbx
  804160415f:	eb b8                	jmp    8041604119 <line_for_address+0x6df>
                last_state = *state;
  8041604161:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041604164:	89 45 9c             	mov    %eax,-0x64(%rbp)
  8041604167:	4c 89 75 a8          	mov    %r14,-0x58(%rbp)
        program_addr += sizeof(Dwarf_Small);
  804160416b:	48 89 f3             	mov    %rsi,%rbx
  804160416e:	eb a9                	jmp    8041604119 <line_for_address+0x6df>
    struct Line_Number_State current_state = {
  8041604170:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%rbp)
  8041604177:	eb 16                	jmp    804160418f <line_for_address+0x755>
                    *state = last_state;
  8041604179:	8b 45 9c             	mov    -0x64(%rbp),%eax
  804160417c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160417f:	eb 0e                	jmp    804160418f <line_for_address+0x755>
                    *state = last_state;
  8041604181:	8b 45 9c             	mov    -0x64(%rbp),%eax
  8041604184:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041604187:	eb 06                	jmp    804160418f <line_for_address+0x755>
                *state = last_state;
  8041604189:	8b 45 9c             	mov    -0x64(%rbp),%eax
  804160418c:	89 45 b8             	mov    %eax,-0x48(%rbp)
            .standard_opcode_lengths = standard_opcode_lengths,
    };

    run_line_number_program(program_addr, unit_end, &info, &current_state, p);

    *lineno_store = current_state.line;
  804160418f:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8041604193:	8b 75 b8             	mov    -0x48(%rbp),%esi
  8041604196:	89 30                	mov    %esi,(%rax)

    return 0;
  8041604198:	b8 00 00 00 00       	mov    $0x0,%eax
}
  804160419d:	48 83 c4 48          	add    $0x48,%rsp
  80416041a1:	5b                   	pop    %rbx
  80416041a2:	41 5c                	pop    %r12
  80416041a4:	41 5d                	pop    %r13
  80416041a6:	41 5e                	pop    %r14
  80416041a8:	41 5f                	pop    %r15
  80416041aa:	5d                   	pop    %rbp
  80416041ab:	c3                   	ret    
        return -E_INVAL;
  80416041ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80416041b1:	eb ea                	jmp    804160419d <line_for_address+0x763>
    uint64_t count = sizeof(uint32_t);
  80416041b3:	b8 04 00 00 00       	mov    $0x4,%eax
    curr_addr += count = dwarf_entry_len(curr_addr, &header_length);
  80416041b8:	49 01 c5             	add    %rax,%r13
    const uint8_t *program_addr = curr_addr + header_length;
  80416041bb:	4c 01 eb             	add    %r13,%rbx
            get_unaligned(curr_addr, Dwarf_Small);
  80416041be:	ba 01 00 00 00       	mov    $0x1,%edx
  80416041c3:	4c 89 ee             	mov    %r13,%rsi
  80416041c6:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416041ca:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416041d1:	00 00 00 
  80416041d4:	ff d0                	call   *%rax
    assert(minimum_instruction_length == 1);
  80416041d6:	80 7d c8 01          	cmpb   $0x1,-0x38(%rbp)
  80416041da:	0f 85 7d f9 ff ff    	jne    8041603b5d <line_for_address+0x123>
    curr_addr += sizeof(Dwarf_Small);
  80416041e0:	4d 8d 65 01          	lea    0x1(%r13),%r12
    if (version == 4) {
  80416041e4:	66 41 83 fe 04       	cmp    $0x4,%r14w
  80416041e9:	0f 84 a3 f9 ff ff    	je     8041603b92 <line_for_address+0x158>
    curr_addr += sizeof(Dwarf_Small);
  80416041ef:	49 8d 74 24 01       	lea    0x1(%r12),%rsi
    int8_t line_base = get_unaligned(curr_addr, int8_t);
  80416041f4:	ba 01 00 00 00       	mov    $0x1,%edx
  80416041f9:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416041fd:	49 bd 77 94 60 41 80 	movabs $0x8041609477,%r13
  8041604204:	00 00 00 
  8041604207:	41 ff d5             	call   *%r13
  804160420a:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  804160420e:	88 45 bd             	mov    %al,-0x43(%rbp)
    curr_addr += sizeof(int8_t);
  8041604211:	49 8d 74 24 02       	lea    0x2(%r12),%rsi
    Dwarf_Small line_range = get_unaligned(curr_addr, Dwarf_Small);
  8041604216:	ba 01 00 00 00       	mov    $0x1,%edx
  804160421b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160421f:	41 ff d5             	call   *%r13
  8041604222:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  8041604226:	88 45 be             	mov    %al,-0x42(%rbp)
    curr_addr += sizeof(Dwarf_Small);
  8041604229:	49 8d 74 24 03       	lea    0x3(%r12),%rsi
    Dwarf_Small opcode_base = get_unaligned(curr_addr, Dwarf_Small);
  804160422e:	ba 01 00 00 00       	mov    $0x1,%edx
  8041604233:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041604237:	41 ff d5             	call   *%r13
  804160423a:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  804160423e:	88 45 bf             	mov    %al,-0x41(%rbp)
    curr_addr += sizeof(Dwarf_Small);
  8041604241:	49 8d 74 24 04       	lea    0x4(%r12),%rsi
    Dwarf_Small *standard_opcode_lengths = (Dwarf_Small *)get_unaligned(curr_addr, Dwarf_Small *);
  8041604246:	ba 08 00 00 00       	mov    $0x8,%edx
  804160424b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160424f:	41 ff d5             	call   *%r13
    while (program_addr < end_addr) {
  8041604252:	48 39 5d b0          	cmp    %rbx,-0x50(%rbp)
  8041604256:	0f 86 14 ff ff ff    	jbe    8041604170 <line_for_address+0x736>
    struct Line_Number_State current_state = {
  804160425c:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%rbp)
  8041604263:	41 be 00 00 00 00    	mov    $0x0,%r14d
        Dwarf_Small opcode = get_unaligned(program_addr, Dwarf_Small);
  8041604269:	4d 89 ef             	mov    %r13,%r15
                Dwarf_Small adjusted_opcode = opcode - info->opcode_base;
  804160426c:	0f b6 45 bf          	movzbl -0x41(%rbp),%eax
  8041604270:	f7 d0                	not    %eax
                int op_advance = adjusted_opcode / info->line_range;
  8041604272:	0f b6 c0             	movzbl %al,%eax
  8041604275:	66 89 45 9a          	mov    %ax,-0x66(%rbp)
  8041604279:	e9 a1 fe ff ff       	jmp    804160411f <line_for_address+0x6e5>
  804160427e:	b8 04 00 00 00       	mov    $0x4,%eax
    curr_addr += count = dwarf_entry_len(curr_addr, &unit_length);
  8041604283:	49 01 c4             	add    %rax,%r12
    const void *unit_end = curr_addr + unit_length;
  8041604286:	49 8d 04 14          	lea    (%r12,%rdx,1),%rax
  804160428a:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
    Dwarf_Half version = get_unaligned(curr_addr, Dwarf_Half);
  804160428e:	ba 02 00 00 00       	mov    $0x2,%edx
  8041604293:	4c 89 e6             	mov    %r12,%rsi
  8041604296:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160429a:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416042a1:	00 00 00 
  80416042a4:	ff d0                	call   *%rax
  80416042a6:	44 0f b7 75 c8       	movzwl -0x38(%rbp),%r14d
    curr_addr += sizeof(Dwarf_Half);
  80416042ab:	4d 8d 6c 24 02       	lea    0x2(%r12),%r13
    assert(version == 4 || version == 3 || version == 2);
  80416042b0:	41 8d 46 fe          	lea    -0x2(%r14),%eax
  80416042b4:	66 83 f8 02          	cmp    $0x2,%ax
  80416042b8:	0f 87 42 f8 ff ff    	ja     8041603b00 <line_for_address+0xc6>
    uint64_t initial_len = get_unaligned(addr, uint32_t);
  80416042be:	ba 04 00 00 00       	mov    $0x4,%edx
  80416042c3:	4c 89 ee             	mov    %r13,%rsi
  80416042c6:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416042ca:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416042d1:	00 00 00 
  80416042d4:	ff d0                	call   *%rax
  80416042d6:	8b 5d c8             	mov    -0x38(%rbp),%ebx
    if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416042d9:	48 b8 10 00 00 00 ff 	movabs $0xffffffff00000010,%rax
  80416042e0:	ff ff ff 
  80416042e3:	48 01 d8             	add    %rbx,%rax
  80416042e6:	48 83 f8 0f          	cmp    $0xf,%rax
  80416042ea:	0f 87 c3 fe ff ff    	ja     80416041b3 <line_for_address+0x779>
        if (initial_len == DW_EXT_DWARF64) {
  80416042f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80416042f5:	48 39 c3             	cmp    %rax,%rbx
  80416042f8:	0f 84 37 f8 ff ff    	je     8041603b35 <line_for_address+0xfb>
            cprintf("Unknown DWARF extension\n");
  80416042fe:	48 bf 40 a4 60 41 80 	movabs $0x804160a440,%rdi
  8041604305:	00 00 00 
  8041604308:	b8 00 00 00 00       	mov    $0x0,%eax
  804160430d:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  8041604314:	00 00 00 
  8041604317:	ff d2                	call   *%rdx
        return -E_BAD_DWARF;
  8041604319:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  804160431e:	e9 7a fe ff ff       	jmp    804160419d <line_for_address+0x763>

0000008041604323 <mon_help>:
#define NCOMMANDS (sizeof(commands) / sizeof(commands[0]))

/* Implementations of basic kernel monitor commands */

int
mon_help(int argc, char **argv, struct Trapframe *tf) {
  8041604323:	f3 0f 1e fa          	endbr64 
  8041604327:	55                   	push   %rbp
  8041604328:	48 89 e5             	mov    %rsp,%rbp
  804160432b:	41 56                	push   %r14
  804160432d:	41 55                	push   %r13
  804160432f:	41 54                	push   %r12
  8041604331:	53                   	push   %rbx
    for (size_t i = 0; i < NCOMMANDS; i++)
  8041604332:	48 bb 20 aa 60 41 80 	movabs $0x804160aa20,%rbx
  8041604339:	00 00 00 
  804160433c:	4c 8d b3 d8 00 00 00 	lea    0xd8(%rbx),%r14
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  8041604343:	49 bd 38 a7 60 41 80 	movabs $0x804160a738,%r13
  804160434a:	00 00 00 
  804160434d:	49 bc b7 6f 60 41 80 	movabs $0x8041606fb7,%r12
  8041604354:	00 00 00 
  8041604357:	48 8b 53 08          	mov    0x8(%rbx),%rdx
  804160435b:	48 8b 33             	mov    (%rbx),%rsi
  804160435e:	4c 89 ef             	mov    %r13,%rdi
  8041604361:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604366:	41 ff d4             	call   *%r12
    for (size_t i = 0; i < NCOMMANDS; i++)
  8041604369:	48 83 c3 18          	add    $0x18,%rbx
  804160436d:	4c 39 f3             	cmp    %r14,%rbx
  8041604370:	75 e5                	jne    8041604357 <mon_help+0x34>
    return 0;
}
  8041604372:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604377:	5b                   	pop    %rbx
  8041604378:	41 5c                	pop    %r12
  804160437a:	41 5d                	pop    %r13
  804160437c:	41 5e                	pop    %r14
  804160437e:	5d                   	pop    %rbp
  804160437f:	c3                   	ret    

0000008041604380 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf) {
  8041604380:	f3 0f 1e fa          	endbr64 
  8041604384:	55                   	push   %rbp
  8041604385:	48 89 e5             	mov    %rsp,%rbp
  8041604388:	41 55                	push   %r13
  804160438a:	41 54                	push   %r12
  804160438c:	53                   	push   %rbx
  804160438d:	48 83 ec 08          	sub    $0x8,%rsp
    extern char _head64[], entry[], etext[], edata[], end[];

    cprintf("Special kernel symbols:\n");
  8041604391:	48 bf 41 a7 60 41 80 	movabs $0x804160a741,%rdi
  8041604398:	00 00 00 
  804160439b:	b8 00 00 00 00       	mov    $0x0,%eax
  80416043a0:	49 bc b7 6f 60 41 80 	movabs $0x8041606fb7,%r12
  80416043a7:	00 00 00 
  80416043aa:	41 ff d4             	call   *%r12
    cprintf("  _head64 %16lx (virt)  %16lx (phys)\n", (unsigned long)_head64, (unsigned long)_head64);
  80416043ad:	48 be 00 00 50 01 00 	movabs $0x1500000,%rsi
  80416043b4:	00 00 00 
  80416043b7:	48 89 f2             	mov    %rsi,%rdx
  80416043ba:	48 bf 98 a8 60 41 80 	movabs $0x804160a898,%rdi
  80416043c1:	00 00 00 
  80416043c4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416043c9:	41 ff d4             	call   *%r12
    cprintf("  entry   %16lx (virt)  %16lx (phys)\n", (unsigned long)entry, (unsigned long)entry - KERN_BASE_ADDR);
  80416043cc:	49 bd 00 00 60 41 80 	movabs $0x8041600000,%r13
  80416043d3:	00 00 00 
  80416043d6:	48 ba 00 00 60 01 00 	movabs $0x1600000,%rdx
  80416043dd:	00 00 00 
  80416043e0:	4c 89 ee             	mov    %r13,%rsi
  80416043e3:	48 bf c0 a8 60 41 80 	movabs $0x804160a8c0,%rdi
  80416043ea:	00 00 00 
  80416043ed:	b8 00 00 00 00       	mov    $0x0,%eax
  80416043f2:	41 ff d4             	call   *%r12
    cprintf("  etext   %16lx (virt)  %16lx (phys)\n", (unsigned long)etext, (unsigned long)etext - KERN_BASE_ADDR);
  80416043f5:	48 ba 10 a1 60 01 00 	movabs $0x160a110,%rdx
  80416043fc:	00 00 00 
  80416043ff:	48 be 10 a1 60 41 80 	movabs $0x804160a110,%rsi
  8041604406:	00 00 00 
  8041604409:	48 bf e8 a8 60 41 80 	movabs $0x804160a8e8,%rdi
  8041604410:	00 00 00 
  8041604413:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604418:	41 ff d4             	call   *%r12
    cprintf("  edata   %16lx (virt)  %16lx (phys)\n", (unsigned long)edata, (unsigned long)edata - KERN_BASE_ADDR);
  804160441b:	48 ba 08 42 64 01 00 	movabs $0x1644208,%rdx
  8041604422:	00 00 00 
  8041604425:	48 be 08 42 64 41 80 	movabs $0x8041644208,%rsi
  804160442c:	00 00 00 
  804160442f:	48 bf 10 a9 60 41 80 	movabs $0x804160a910,%rdi
  8041604436:	00 00 00 
  8041604439:	b8 00 00 00 00       	mov    $0x0,%eax
  804160443e:	41 ff d4             	call   *%r12
    cprintf("  end     %16lx (virt)  %16lx (phys)\n", (unsigned long)end, (unsigned long)end - KERN_BASE_ADDR);
  8041604441:	48 bb 00 60 e4 41 80 	movabs $0x8041e46000,%rbx
  8041604448:	00 00 00 
  804160444b:	48 ba 00 60 e4 01 00 	movabs $0x1e46000,%rdx
  8041604452:	00 00 00 
  8041604455:	48 89 de             	mov    %rbx,%rsi
  8041604458:	48 bf 38 a9 60 41 80 	movabs $0x804160a938,%rdi
  804160445f:	00 00 00 
  8041604462:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604467:	41 ff d4             	call   *%r12
    cprintf("Kernel executable memory footprint: %luKB\n", (unsigned long)ROUNDUP(end - entry, 1024) / 1024);
  804160446a:	4c 29 eb             	sub    %r13,%rbx
  804160446d:	48 8d b3 ff 03 00 00 	lea    0x3ff(%rbx),%rsi
  8041604474:	48 c1 ee 0a          	shr    $0xa,%rsi
  8041604478:	48 bf 60 a9 60 41 80 	movabs $0x804160a960,%rdi
  804160447f:	00 00 00 
  8041604482:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604487:	41 ff d4             	call   *%r12
    return 0;
}
  804160448a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160448f:	48 83 c4 08          	add    $0x8,%rsp
  8041604493:	5b                   	pop    %rbx
  8041604494:	41 5c                	pop    %r12
  8041604496:	41 5d                	pop    %r13
  8041604498:	5d                   	pop    %rbp
  8041604499:	c3                   	ret    

000000804160449a <mon_echo>:

    return 0;
}

int
mon_echo(int argc, char **argv, struct Trapframe *tf) {
  804160449a:	f3 0f 1e fa          	endbr64 
  804160449e:	55                   	push   %rbp
  804160449f:	48 89 e5             	mov    %rsp,%rbp
  80416044a2:	41 57                	push   %r15
  80416044a4:	41 56                	push   %r14
  80416044a6:	41 55                	push   %r13
  80416044a8:	41 54                	push   %r12
  80416044aa:	53                   	push   %rbx
  80416044ab:	48 83 ec 18          	sub    $0x18,%rsp
  80416044af:	41 89 ff             	mov    %edi,%r15d
  80416044b2:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)

    for(int n_word = 1; n_word < argc - 1; n_word++){
  80416044b6:	83 ff 02             	cmp    $0x2,%edi
  80416044b9:	7e 37                	jle    80416044f2 <mon_echo+0x58>
  80416044bb:	48 8d 5e 08          	lea    0x8(%rsi),%rbx
  80416044bf:	8d 47 fd             	lea    -0x3(%rdi),%eax
  80416044c2:	4c 8d 74 c6 10       	lea    0x10(%rsi,%rax,8),%r14
        cprintf("%s ", argv[n_word]);
  80416044c7:	49 bd 5a a7 60 41 80 	movabs $0x804160a75a,%r13
  80416044ce:	00 00 00 
  80416044d1:	49 bc b7 6f 60 41 80 	movabs $0x8041606fb7,%r12
  80416044d8:	00 00 00 
  80416044db:	48 8b 33             	mov    (%rbx),%rsi
  80416044de:	4c 89 ef             	mov    %r13,%rdi
  80416044e1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416044e6:	41 ff d4             	call   *%r12
    for(int n_word = 1; n_word < argc - 1; n_word++){
  80416044e9:	48 83 c3 08          	add    $0x8,%rbx
  80416044ed:	4c 39 f3             	cmp    %r14,%rbx
  80416044f0:	75 e9                	jne    80416044db <mon_echo+0x41>
    }
    if(argc > 1){
  80416044f2:	41 83 ff 01          	cmp    $0x1,%r15d
  80416044f6:	7f 14                	jg     804160450c <mon_echo+0x72>
        cprintf("%s\n", argv[argc - 1]);
    }
    return 0;
}
  80416044f8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416044fd:	48 83 c4 18          	add    $0x18,%rsp
  8041604501:	5b                   	pop    %rbx
  8041604502:	41 5c                	pop    %r12
  8041604504:	41 5d                	pop    %r13
  8041604506:	41 5e                	pop    %r14
  8041604508:	41 5f                	pop    %r15
  804160450a:	5d                   	pop    %rbp
  804160450b:	c3                   	ret    
        cprintf("%s\n", argv[argc - 1]);
  804160450c:	4d 63 ff             	movslq %r15d,%r15
  804160450f:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041604513:	4a 8b 74 f8 f8       	mov    -0x8(%rax,%r15,8),%rsi
  8041604518:	48 bf 3d a7 60 41 80 	movabs $0x804160a73d,%rdi
  804160451f:	00 00 00 
  8041604522:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604527:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  804160452e:	00 00 00 
  8041604531:	ff d2                	call   *%rdx
  8041604533:	eb c3                	jmp    80416044f8 <mon_echo+0x5e>

0000008041604535 <mon_backtrace>:
mon_backtrace(int argc, char **argv, struct Trapframe *tf) {
  8041604535:	f3 0f 1e fa          	endbr64 
  8041604539:	55                   	push   %rbp
  804160453a:	48 89 e5             	mov    %rsp,%rbp
  804160453d:	41 57                	push   %r15
  804160453f:	41 56                	push   %r14
  8041604541:	41 55                	push   %r13
  8041604543:	41 54                	push   %r12
  8041604545:	53                   	push   %rbx
  8041604546:	48 81 ec 28 02 00 00 	sub    $0x228,%rsp
    cprintf("\a");
  804160454d:	48 bf 5e a7 60 41 80 	movabs $0x804160a75e,%rdi
  8041604554:	00 00 00 
  8041604557:	b8 00 00 00 00       	mov    $0x0,%eax
  804160455c:	48 bb b7 6f 60 41 80 	movabs $0x8041606fb7,%rbx
  8041604563:	00 00 00 
  8041604566:	ff d3                	call   *%rbx
    cprintf("Stack backtrace:\n");
  8041604568:	48 bf 60 a7 60 41 80 	movabs $0x804160a760,%rdi
  804160456f:	00 00 00 
  8041604572:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604577:	ff d3                	call   *%rbx
}

static inline uint64_t __attribute__((always_inline))
read_rbp(void) {
    uint64_t rbp;
    asm volatile("movq %%rbp,%0"
  8041604579:	48 89 e8             	mov    %rbp,%rax
    while(cur_rbp != 0){
  804160457c:	48 85 c0             	test   %rax,%rax
  804160457f:	74 78                	je     80416045f9 <mon_backtrace+0xc4>
  8041604581:	48 89 c3             	mov    %rax,%rbx
        debuginfo_rip(ret_addr, &debug_info);
  8041604584:	49 bf ee 85 60 41 80 	movabs $0x80416085ee,%r15
  804160458b:	00 00 00 
        cprintf("  rbp %016lx  rip %016lx\n", cur_rbp, ret_addr);
  804160458e:	49 be 72 a7 60 41 80 	movabs $0x804160a772,%r14
  8041604595:	00 00 00 
  8041604598:	49 bd b7 6f 60 41 80 	movabs $0x8041606fb7,%r13
  804160459f:	00 00 00 
        uint64_t ret_addr = *(uint64_t*)(cur_rbp + 8);
  80416045a2:	4c 8b 63 08          	mov    0x8(%rbx),%r12
        debuginfo_rip(ret_addr, &debug_info);
  80416045a6:	48 8d b5 b8 fd ff ff 	lea    -0x248(%rbp),%rsi
  80416045ad:	4c 89 e7             	mov    %r12,%rdi
  80416045b0:	41 ff d7             	call   *%r15
        cprintf("  rbp %016lx  rip %016lx\n", cur_rbp, ret_addr);
  80416045b3:	4c 89 e2             	mov    %r12,%rdx
  80416045b6:	48 89 de             	mov    %rbx,%rsi
  80416045b9:	4c 89 f7             	mov    %r14,%rdi
  80416045bc:	b8 00 00 00 00       	mov    $0x0,%eax
  80416045c1:	41 ff d5             	call   *%r13
        cprintf("    %s:%d: %s+%lu\n", 
  80416045c4:	4d 89 e0             	mov    %r12,%r8
  80416045c7:	4c 2b 45 c0          	sub    -0x40(%rbp),%r8
  80416045cb:	48 8d 8d bc fe ff ff 	lea    -0x144(%rbp),%rcx
  80416045d2:	8b 95 b8 fe ff ff    	mov    -0x148(%rbp),%edx
  80416045d8:	48 8d b5 b8 fd ff ff 	lea    -0x248(%rbp),%rsi
  80416045df:	48 bf 8c a7 60 41 80 	movabs $0x804160a78c,%rdi
  80416045e6:	00 00 00 
  80416045e9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416045ee:	41 ff d5             	call   *%r13
        cur_rbp = *(uint64_t*)(cur_rbp);
  80416045f1:	48 8b 1b             	mov    (%rbx),%rbx
    while(cur_rbp != 0){
  80416045f4:	48 85 db             	test   %rbx,%rbx
  80416045f7:	75 a9                	jne    80416045a2 <mon_backtrace+0x6d>
}
  80416045f9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416045fe:	48 81 c4 28 02 00 00 	add    $0x228,%rsp
  8041604605:	5b                   	pop    %rbx
  8041604606:	41 5c                	pop    %r12
  8041604608:	41 5d                	pop    %r13
  804160460a:	41 5e                	pop    %r14
  804160460c:	41 5f                	pop    %r15
  804160460e:	5d                   	pop    %rbp
  804160460f:	c3                   	ret    

0000008041604610 <mon_dumpcmos>:
static const int N_REGS = 128;
static const int N_BYTES_IN_LINE = 16;
static const int N_LINES = N_REGS /  N_BYTES_IN_LINE;

int
mon_dumpcmos(int argc, char **argv, struct Trapframe *tf) {
  8041604610:	f3 0f 1e fa          	endbr64 
  8041604614:	55                   	push   %rbp
  8041604615:	48 89 e5             	mov    %rsp,%rbp
  8041604618:	41 57                	push   %r15
  804160461a:	41 56                	push   %r14
  804160461c:	41 55                	push   %r13
  804160461e:	41 54                	push   %r12
  8041604620:	53                   	push   %rbx
  8041604621:	48 83 ec 18          	sub    $0x18,%rsp
  8041604625:	41 bc 10 00 00 00    	mov    $0x10,%r12d
  804160462b:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%rbp)
    // LAB 4: Your code here

    for(int n_line = 0; n_line < N_LINES; n_line++){
        
        // TODO: fix
        cprintf("%x: ", n_line * N_BYTES_IN_LINE);
  8041604632:	49 bd b7 6f 60 41 80 	movabs $0x8041606fb7,%r13
  8041604639:	00 00 00 
        for(int n_byte = 0; n_byte < N_BYTES_IN_LINE; n_byte++){
            uint8_t val = cmos_read8(n_line * N_BYTES_IN_LINE + n_byte);
  804160463c:	49 bf 1c 6c 60 41 80 	movabs $0x8041606c1c,%r15
  8041604643:	00 00 00 

            cprintf("%x ", val);
  8041604646:	49 be a4 a7 60 41 80 	movabs $0x804160a7a4,%r14
  804160464d:	00 00 00 
        cprintf("%x: ", n_line * N_BYTES_IN_LINE);
  8041604650:	8b 5d cc             	mov    -0x34(%rbp),%ebx
  8041604653:	89 de                	mov    %ebx,%esi
  8041604655:	48 bf 9f a7 60 41 80 	movabs $0x804160a79f,%rdi
  804160465c:	00 00 00 
  804160465f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604664:	41 ff d5             	call   *%r13
            uint8_t val = cmos_read8(n_line * N_BYTES_IN_LINE + n_byte);
  8041604667:	0f b6 fb             	movzbl %bl,%edi
  804160466a:	41 ff d7             	call   *%r15
            cprintf("%x ", val);
  804160466d:	0f b6 f0             	movzbl %al,%esi
  8041604670:	4c 89 f7             	mov    %r14,%rdi
  8041604673:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604678:	41 ff d5             	call   *%r13
        for(int n_byte = 0; n_byte < N_BYTES_IN_LINE; n_byte++){
  804160467b:	83 c3 01             	add    $0x1,%ebx
  804160467e:	44 38 e3             	cmp    %r12b,%bl
  8041604681:	75 e4                	jne    8041604667 <mon_dumpcmos+0x57>
        }
        cprintf("\n");
  8041604683:	48 bf f0 a1 60 41 80 	movabs $0x804160a1f0,%rdi
  804160468a:	00 00 00 
  804160468d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604692:	41 ff d5             	call   *%r13
    for(int n_line = 0; n_line < N_LINES; n_line++){
  8041604695:	83 45 cc 10          	addl   $0x10,-0x34(%rbp)
  8041604699:	41 83 c4 10          	add    $0x10,%r12d
  804160469d:	41 80 fc 90          	cmp    $0x90,%r12b
  80416046a1:	75 ad                	jne    8041604650 <mon_dumpcmos+0x40>
    }

    return 0;
}
  80416046a3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416046a8:	48 83 c4 18          	add    $0x18,%rsp
  80416046ac:	5b                   	pop    %rbx
  80416046ad:	41 5c                	pop    %r12
  80416046af:	41 5d                	pop    %r13
  80416046b1:	41 5e                	pop    %r14
  80416046b3:	41 5f                	pop    %r15
  80416046b5:	5d                   	pop    %rbp
  80416046b6:	c3                   	ret    

00000080416046b7 <mon_start>:

/* Implement timer_start (mon_start), timer_stop (mon_stop), timer_freq (mon_frequency) commands. */
// LAB 5: Your code here:

int mon_start(int argc, char **argv, struct Trapframe *tf){
  80416046b7:	f3 0f 1e fa          	endbr64 
  80416046bb:	55                   	push   %rbp
  80416046bc:	48 89 e5             	mov    %rsp,%rbp
    if(argc < 2){
  80416046bf:	83 ff 01             	cmp    $0x1,%edi
  80416046c2:	7e 17                	jle    80416046db <mon_start+0x24>
        cprintf("timer name required\n");
        return 0;
    }

    timer_start(argv[1]);
  80416046c4:	48 8b 7e 08          	mov    0x8(%rsi),%rdi
  80416046c8:	48 b8 9b 98 60 41 80 	movabs $0x804160989b,%rax
  80416046cf:	00 00 00 
  80416046d2:	ff d0                	call   *%rax
    return 0;
}
  80416046d4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416046d9:	5d                   	pop    %rbp
  80416046da:	c3                   	ret    
        cprintf("timer name required\n");
  80416046db:	48 bf a8 a7 60 41 80 	movabs $0x804160a7a8,%rdi
  80416046e2:	00 00 00 
  80416046e5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416046ea:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  80416046f1:	00 00 00 
  80416046f4:	ff d2                	call   *%rdx
        return 0;
  80416046f6:	eb dc                	jmp    80416046d4 <mon_start+0x1d>

00000080416046f8 <mon_stop>:

int mon_stop(int argc, char **argv, struct Trapframe *tf){
  80416046f8:	f3 0f 1e fa          	endbr64 
  80416046fc:	55                   	push   %rbp
  80416046fd:	48 89 e5             	mov    %rsp,%rbp
    timer_stop();
  8041604700:	48 b8 3c 99 60 41 80 	movabs $0x804160993c,%rax
  8041604707:	00 00 00 
  804160470a:	ff d0                	call   *%rax
    return 0;
}
  804160470c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604711:	5d                   	pop    %rbp
  8041604712:	c3                   	ret    

0000008041604713 <mon_frequency>:

int mon_frequency(int argc, char **argv, struct Trapframe *tf){
  8041604713:	f3 0f 1e fa          	endbr64 
  8041604717:	55                   	push   %rbp
  8041604718:	48 89 e5             	mov    %rsp,%rbp
    if(argc < 2){
  804160471b:	83 ff 01             	cmp    $0x1,%edi
  804160471e:	7e 17                	jle    8041604737 <mon_frequency+0x24>
        cprintf("timer name required\n");
        return 0;
    }

    timer_cpu_frequency(argv[1]);
  8041604720:	48 8b 7e 08          	mov    0x8(%rsi),%rdi
  8041604724:	48 b8 c0 99 60 41 80 	movabs $0x80416099c0,%rax
  804160472b:	00 00 00 
  804160472e:	ff d0                	call   *%rax
    return 0;
}
  8041604730:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604735:	5d                   	pop    %rbp
  8041604736:	c3                   	ret    
        cprintf("timer name required\n");
  8041604737:	48 bf a8 a7 60 41 80 	movabs $0x804160a7a8,%rdi
  804160473e:	00 00 00 
  8041604741:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604746:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  804160474d:	00 00 00 
  8041604750:	ff d2                	call   *%rdx
        return 0;
  8041604752:	eb dc                	jmp    8041604730 <mon_frequency+0x1d>

0000008041604754 <mon_memory>:
/* Implement memory (mon_memory) command.
 * This command should call dump_memory_lists()
 */
// LAB 6: Your code here
int mon_memory(int argc, char **argv, struct Trapframe *tf){
  8041604754:	f3 0f 1e fa          	endbr64 
  8041604758:	55                   	push   %rbp
  8041604759:	48 89 e5             	mov    %rsp,%rbp
    dump_memory_lists();
  804160475c:	48 b8 85 5c 60 41 80 	movabs $0x8041605c85,%rax
  8041604763:	00 00 00 
  8041604766:	ff d0                	call   *%rax
    return 0;
}
  8041604768:	b8 00 00 00 00       	mov    $0x0,%eax
  804160476d:	5d                   	pop    %rbp
  804160476e:	c3                   	ret    

000000804160476f <monitor>:
    cprintf("Unknown command '%s'\n", argv[0]);
    return 0;
}

void
monitor(struct Trapframe *tf) {
  804160476f:	f3 0f 1e fa          	endbr64 
  8041604773:	55                   	push   %rbp
  8041604774:	48 89 e5             	mov    %rsp,%rbp
  8041604777:	41 57                	push   %r15
  8041604779:	41 56                	push   %r14
  804160477b:	41 55                	push   %r13
  804160477d:	41 54                	push   %r12
  804160477f:	53                   	push   %rbx
  8041604780:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
  8041604787:	49 89 ff             	mov    %rdi,%r15
  804160478a:	48 89 bd 48 ff ff ff 	mov    %rdi,-0xb8(%rbp)

    cprintf("Welcome to the JOS kernel monitor!\n");
  8041604791:	48 bf 90 a9 60 41 80 	movabs $0x804160a990,%rdi
  8041604798:	00 00 00 
  804160479b:	b8 00 00 00 00       	mov    $0x0,%eax
  80416047a0:	48 bb b7 6f 60 41 80 	movabs $0x8041606fb7,%rbx
  80416047a7:	00 00 00 
  80416047aa:	ff d3                	call   *%rbx
    cprintf("Type 'help' for a list of commands.\n");
  80416047ac:	48 bf b8 a9 60 41 80 	movabs $0x804160a9b8,%rdi
  80416047b3:	00 00 00 
  80416047b6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416047bb:	ff d3                	call   *%rbx

    if (tf) print_trapframe(tf);
  80416047bd:	4d 85 ff             	test   %r15,%r15
  80416047c0:	74 0f                	je     80416047d1 <monitor+0x62>
  80416047c2:	4c 89 ff             	mov    %r15,%rdi
  80416047c5:	48 b8 8c 73 60 41 80 	movabs $0x804160738c,%rax
  80416047cc:	00 00 00 
  80416047cf:	ff d0                	call   *%rax
        while (*buf && strchr(WHITESPACE, *buf)) *buf++ = 0;
  80416047d1:	49 bd c1 a7 60 41 80 	movabs $0x804160a7c1,%r13
  80416047d8:	00 00 00 
  80416047db:	e9 f7 00 00 00       	jmp    80416048d7 <monitor+0x168>
  80416047e0:	40 0f be f6          	movsbl %sil,%esi
  80416047e4:	4c 89 ef             	mov    %r13,%rdi
  80416047e7:	41 ff d4             	call   *%r12
  80416047ea:	48 85 c0             	test   %rax,%rax
  80416047ed:	74 0c                	je     80416047fb <monitor+0x8c>
  80416047ef:	c6 03 00             	movb   $0x0,(%rbx)
  80416047f2:	45 89 f7             	mov    %r14d,%r15d
  80416047f5:	48 8d 5b 01          	lea    0x1(%rbx),%rbx
  80416047f9:	eb 41                	jmp    804160483c <monitor+0xcd>
        if (!*buf) break;
  80416047fb:	80 3b 00             	cmpb   $0x0,(%rbx)
  80416047fe:	74 47                	je     8041604847 <monitor+0xd8>
        if (argc == MAXARGS - 1) {
  8041604800:	41 83 fe 0f          	cmp    $0xf,%r14d
  8041604804:	0f 84 b2 00 00 00    	je     80416048bc <monitor+0x14d>
        argv[argc++] = buf;
  804160480a:	45 8d 7e 01          	lea    0x1(%r14),%r15d
  804160480e:	4d 63 f6             	movslq %r14d,%r14
  8041604811:	4a 89 9c f5 50 ff ff 	mov    %rbx,-0xb0(%rbp,%r14,8)
  8041604818:	ff 
        while (*buf && !strchr(WHITESPACE, *buf)) buf++;
  8041604819:	0f b6 33             	movzbl (%rbx),%esi
  804160481c:	40 84 f6             	test   %sil,%sil
  804160481f:	74 1b                	je     804160483c <monitor+0xcd>
  8041604821:	40 0f be f6          	movsbl %sil,%esi
  8041604825:	4c 89 ef             	mov    %r13,%rdi
  8041604828:	41 ff d4             	call   *%r12
  804160482b:	48 85 c0             	test   %rax,%rax
  804160482e:	75 0c                	jne    804160483c <monitor+0xcd>
  8041604830:	48 83 c3 01          	add    $0x1,%rbx
  8041604834:	0f b6 33             	movzbl (%rbx),%esi
  8041604837:	40 84 f6             	test   %sil,%sil
  804160483a:	75 e5                	jne    8041604821 <monitor+0xb2>
        while (*buf && strchr(WHITESPACE, *buf)) *buf++ = 0;
  804160483c:	45 89 fe             	mov    %r15d,%r14d
  804160483f:	0f b6 33             	movzbl (%rbx),%esi
  8041604842:	40 84 f6             	test   %sil,%sil
  8041604845:	75 99                	jne    80416047e0 <monitor+0x71>
    argv[argc] = NULL;
  8041604847:	49 63 c6             	movslq %r14d,%rax
  804160484a:	48 c7 84 c5 50 ff ff 	movq   $0x0,-0xb0(%rbp,%rax,8)
  8041604851:	ff 00 00 00 00 
    if (!argc) return 0;
  8041604856:	45 85 f6             	test   %r14d,%r14d
  8041604859:	74 7c                	je     80416048d7 <monitor+0x168>
  804160485b:	48 bb 20 aa 60 41 80 	movabs $0x804160aa20,%rbx
  8041604862:	00 00 00 
    for (size_t i = 0; i < NCOMMANDS; i++) {
  8041604865:	41 bc 00 00 00 00    	mov    $0x0,%r12d
        if (strcmp(argv[0], commands[i].name) == 0)
  804160486b:	49 bf a6 92 60 41 80 	movabs $0x80416092a6,%r15
  8041604872:	00 00 00 
  8041604875:	48 8b 33             	mov    (%rbx),%rsi
  8041604878:	48 8b bd 50 ff ff ff 	mov    -0xb0(%rbp),%rdi
  804160487f:	41 ff d7             	call   *%r15
  8041604882:	85 c0                	test   %eax,%eax
  8041604884:	0f 84 8b 00 00 00    	je     8041604915 <monitor+0x1a6>
    for (size_t i = 0; i < NCOMMANDS; i++) {
  804160488a:	49 83 c4 01          	add    $0x1,%r12
  804160488e:	48 83 c3 18          	add    $0x18,%rbx
  8041604892:	49 83 fc 09          	cmp    $0x9,%r12
  8041604896:	75 dd                	jne    8041604875 <monitor+0x106>
    cprintf("Unknown command '%s'\n", argv[0]);
  8041604898:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  804160489f:	48 bf e3 a7 60 41 80 	movabs $0x804160a7e3,%rdi
  80416048a6:	00 00 00 
  80416048a9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416048ae:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  80416048b5:	00 00 00 
  80416048b8:	ff d2                	call   *%rdx
    return 0;
  80416048ba:	eb 1b                	jmp    80416048d7 <monitor+0x168>
            cprintf("Too many arguments (max %d)\n", MAXARGS);
  80416048bc:	be 10 00 00 00       	mov    $0x10,%esi
  80416048c1:	48 bf c6 a7 60 41 80 	movabs $0x804160a7c6,%rdi
  80416048c8:	00 00 00 
  80416048cb:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  80416048d2:	00 00 00 
  80416048d5:	ff d2                	call   *%rdx

    char *buf;
    do buf = readline("K> ");
  80416048d7:	48 bf bd a7 60 41 80 	movabs $0x804160a7bd,%rdi
  80416048de:	00 00 00 
  80416048e1:	48 b8 8f 90 60 41 80 	movabs $0x804160908f,%rax
  80416048e8:	00 00 00 
  80416048eb:	ff d0                	call   *%rax
  80416048ed:	48 89 c3             	mov    %rax,%rbx
    while (!buf || runcmd(buf, tf) >= 0);
  80416048f0:	48 85 c0             	test   %rax,%rax
  80416048f3:	74 e2                	je     80416048d7 <monitor+0x168>
    argv[0] = NULL;
  80416048f5:	48 c7 85 50 ff ff ff 	movq   $0x0,-0xb0(%rbp)
  80416048fc:	00 00 00 00 
    int argc = 0;
  8041604900:	41 be 00 00 00 00    	mov    $0x0,%r14d
        while (*buf && strchr(WHITESPACE, *buf)) *buf++ = 0;
  8041604906:	49 bc 0f 93 60 41 80 	movabs $0x804160930f,%r12
  804160490d:	00 00 00 
  8041604910:	e9 2a ff ff ff       	jmp    804160483f <monitor+0xd0>
            return commands[i].func(argc, argv, tf);
  8041604915:	4b 8d 0c 64          	lea    (%r12,%r12,2),%rcx
  8041604919:	48 8b 95 48 ff ff ff 	mov    -0xb8(%rbp),%rdx
  8041604920:	48 8d b5 50 ff ff ff 	lea    -0xb0(%rbp),%rsi
  8041604927:	44 89 f7             	mov    %r14d,%edi
  804160492a:	48 b8 20 aa 60 41 80 	movabs $0x804160aa20,%rax
  8041604931:	00 00 00 
  8041604934:	ff 54 c8 10          	call   *0x10(%rax,%rcx,8)
    while (!buf || runcmd(buf, tf) >= 0);
  8041604938:	85 c0                	test   %eax,%eax
  804160493a:	79 9b                	jns    80416048d7 <monitor+0x168>
}
  804160493c:	48 81 c4 98 00 00 00 	add    $0x98,%rsp
  8041604943:	5b                   	pop    %rbx
  8041604944:	41 5c                	pop    %r12
  8041604946:	41 5d                	pop    %r13
  8041604948:	41 5e                	pop    %r14
  804160494a:	41 5f                	pop    %r15
  804160494c:	5d                   	pop    %rbp
  804160494d:	c3                   	ret    

000000804160494e <page_ref>:

    return node;
}

static void
page_ref(struct Page *node) {
  804160494e:	f3 0f 1e fa          	endbr64 
    if (!node) return;
  8041604952:	48 85 ff             	test   %rdi,%rdi
  8041604955:	74 4f                	je     80416049a6 <page_ref+0x58>
page_ref(struct Page *node) {
  8041604957:	55                   	push   %rbp
  8041604958:	48 89 e5             	mov    %rsp,%rbp
  804160495b:	41 54                	push   %r12
  804160495d:	53                   	push   %rbx
  804160495e:	48 89 fb             	mov    %rdi,%rbx
    if (!node->refc++) {
  8041604961:	8b 47 30             	mov    0x30(%rdi),%eax
  8041604964:	8d 50 01             	lea    0x1(%rax),%edx
  8041604967:	89 57 30             	mov    %edx,0x30(%rdi)
  804160496a:	85 c0                	test   %eax,%eax
  804160496c:	74 05                	je     8041604973 <page_ref+0x25>
        list_del((struct List *)node);
        list_init((struct List *)node);
        page_ref(node->left);
        page_ref(node->right);
    }
}
  804160496e:	5b                   	pop    %rbx
  804160496f:	41 5c                	pop    %r12
  8041604971:	5d                   	pop    %rbp
  8041604972:	c3                   	ret    
    list->next->prev = list->prev;
  8041604973:	48 8b 57 08          	mov    0x8(%rdi),%rdx
  8041604977:	48 8b 07             	mov    (%rdi),%rax
  804160497a:	48 89 02             	mov    %rax,(%rdx)
    list->prev->next = list->next;
  804160497d:	48 8b 57 08          	mov    0x8(%rdi),%rdx
  8041604981:	48 89 50 08          	mov    %rdx,0x8(%rax)
    list->next = list->prev = list;
  8041604985:	48 89 3f             	mov    %rdi,(%rdi)
  8041604988:	48 89 7f 08          	mov    %rdi,0x8(%rdi)
        page_ref(node->left);
  804160498c:	48 8b 7f 10          	mov    0x10(%rdi),%rdi
  8041604990:	49 bc 4e 49 60 41 80 	movabs $0x804160494e,%r12
  8041604997:	00 00 00 
  804160499a:	41 ff d4             	call   *%r12
        page_ref(node->right);
  804160499d:	48 8b 7b 18          	mov    0x18(%rbx),%rdi
  80416049a1:	41 ff d4             	call   *%r12
  80416049a4:	eb c8                	jmp    804160496e <page_ref+0x20>
  80416049a6:	c3                   	ret    

00000080416049a7 <free_desc_rec>:
free_desc_rec(struct Page *p) {
  80416049a7:	f3 0f 1e fa          	endbr64 
    while (p) {
  80416049ab:	48 85 ff             	test   %rdi,%rdi
  80416049ae:	0f 84 bc 00 00 00    	je     8041604a70 <free_desc_rec+0xc9>
free_desc_rec(struct Page *p) {
  80416049b4:	55                   	push   %rbp
  80416049b5:	48 89 e5             	mov    %rsp,%rbp
  80416049b8:	41 56                	push   %r14
  80416049ba:	41 55                	push   %r13
  80416049bc:	41 54                	push   %r12
  80416049be:	53                   	push   %rbx
  80416049bf:	48 89 fb             	mov    %rdi,%rbx
        free_desc_rec(p->right);
  80416049c2:	49 be a7 49 60 41 80 	movabs $0x80416049a7,%r14
  80416049c9:	00 00 00 
    new->next = list->next;
  80416049cc:	49 bc a0 40 e0 41 80 	movabs $0x8041e040a0,%r12
  80416049d3:	00 00 00 
    free_desc_count++;
  80416049d6:	49 bd 98 40 e0 41 80 	movabs $0x8041e04098,%r13
  80416049dd:	00 00 00 
  80416049e0:	eb 03                	jmp    80416049e5 <free_desc_rec+0x3e>
        p = tmp;
  80416049e2:	48 89 d3             	mov    %rdx,%rbx
        assert(!p->refc);
  80416049e5:	83 7b 30 00          	cmpl   $0x0,0x30(%rbx)
  80416049e9:	75 50                	jne    8041604a3b <free_desc_rec+0x94>
        free_desc_rec(p->right);
  80416049eb:	48 8b 7b 18          	mov    0x18(%rbx),%rdi
  80416049ef:	41 ff d6             	call   *%r14
        struct Page *tmp = p->left;
  80416049f2:	48 8b 53 10          	mov    0x10(%rbx),%rdx
    list->next->prev = list->prev;
  80416049f6:	48 8b 4b 08          	mov    0x8(%rbx),%rcx
  80416049fa:	48 8b 03             	mov    (%rbx),%rax
  80416049fd:	48 89 01             	mov    %rax,(%rcx)
    list->prev->next = list->next;
  8041604a00:	48 8b 4b 08          	mov    0x8(%rbx),%rcx
  8041604a04:	48 89 48 08          	mov    %rcx,0x8(%rax)
    list->next = list->prev = list;
  8041604a08:	48 89 1b             	mov    %rbx,(%rbx)
  8041604a0b:	48 89 5b 08          	mov    %rbx,0x8(%rbx)
    new->next = list->next;
  8041604a0f:	49 8b 44 24 08       	mov    0x8(%r12),%rax
  8041604a14:	48 89 43 08          	mov    %rax,0x8(%rbx)
    new->prev = list;
  8041604a18:	4c 89 23             	mov    %r12,(%rbx)
    list->next->prev = new;
  8041604a1b:	49 8b 44 24 08       	mov    0x8(%r12),%rax
  8041604a20:	48 89 18             	mov    %rbx,(%rax)
    list->next = new;
  8041604a23:	49 89 5c 24 08       	mov    %rbx,0x8(%r12)
    free_desc_count++;
  8041604a28:	49 83 45 00 01       	addq   $0x1,0x0(%r13)
    while (p) {
  8041604a2d:	48 85 d2             	test   %rdx,%rdx
  8041604a30:	75 b0                	jne    80416049e2 <free_desc_rec+0x3b>
}
  8041604a32:	5b                   	pop    %rbx
  8041604a33:	41 5c                	pop    %r12
  8041604a35:	41 5d                	pop    %r13
  8041604a37:	41 5e                	pop    %r14
  8041604a39:	5d                   	pop    %rbp
  8041604a3a:	c3                   	ret    
        assert(!p->refc);
  8041604a3b:	48 b9 f8 aa 60 41 80 	movabs $0x804160aaf8,%rcx
  8041604a42:	00 00 00 
  8041604a45:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041604a4c:	00 00 00 
  8041604a4f:	be 97 00 00 00       	mov    $0x97,%esi
  8041604a54:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041604a5b:	00 00 00 
  8041604a5e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604a63:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041604a6a:	00 00 00 
  8041604a6d:	41 ff d0             	call   *%r8
  8041604a70:	c3                   	ret    

0000008041604a71 <check_physical_tree>:
            base & PTE_PS ? 'S' : '-',
            step);
}

static void
check_physical_tree(struct Page *page) {
  8041604a71:	f3 0f 1e fa          	endbr64 
  8041604a75:	55                   	push   %rbp
  8041604a76:	48 89 e5             	mov    %rsp,%rbp
  8041604a79:	41 54                	push   %r12
  8041604a7b:	53                   	push   %rbx
    assert_physical(page);
  8041604a7c:	44 8b 57 28          	mov    0x28(%rdi),%r10d
  8041604a80:	44 89 d0             	mov    %r10d,%eax
  8041604a83:	25 00 00 f0 00       	and    $0xf00000,%eax
  8041604a88:	3d ff ff 2f 00       	cmp    $0x2fffff,%eax
  8041604a8d:	0f 86 99 00 00 00    	jbe    8041604b2c <check_physical_tree+0xbb>
  8041604a93:	48 89 fb             	mov    %rdi,%rbx
/* Number of PML4 entries taken by userspace */
#define NUSERPML4 1

inline static physaddr_t __attribute__((always_inline))
page2pa(struct Page *page) {
    return page->addr << CLASS_BASE;
  8041604a96:	48 b8 ff ff ff ff ff 	movabs $0xfffffffffffff,%rax
  8041604a9d:	ff 0f 00 
  8041604aa0:	49 89 c1             	mov    %rax,%r9
  8041604aa3:	4c 23 4f 38          	and    0x38(%rdi),%r9
  8041604aa7:	4d 89 c8             	mov    %r9,%r8
  8041604aaa:	49 c1 e0 0c          	shl    $0xc,%r8
  8041604aae:	49 21 c0             	and    %rax,%r8
    assert(page->class >= 0);
    assert(!(page2pa(page) & CLASS_MASK(page->class)));
  8041604ab1:	0f b7 47 34          	movzwl 0x34(%rdi),%eax
  8041604ab5:	89 c2                	mov    %eax,%edx
  8041604ab7:	66 81 e2 ff 0f       	and    $0xfff,%dx
  8041604abc:	25 ff 0f 00 00       	and    $0xfff,%eax
  8041604ac1:	8d 48 0c             	lea    0xc(%rax),%ecx
  8041604ac4:	48 c7 c6 ff ff ff ff 	mov    $0xffffffffffffffff,%rsi
  8041604acb:	48 d3 e6             	shl    %cl,%rsi
  8041604ace:	48 f7 d6             	not    %rsi
  8041604ad1:	4c 85 c6             	test   %r8,%rsi
  8041604ad4:	0f 85 87 00 00 00    	jne    8041604b61 <check_physical_tree+0xf0>
    if (page->state == ALLOCATABLE_NODE || page->state == RESERVED_NODE) {
  8041604ada:	44 89 d1             	mov    %r10d,%ecx
  8041604add:	81 e1 ff ff ef ff    	and    $0xffefffff,%ecx
  8041604ae3:	81 f9 00 00 40 00    	cmp    $0x400000,%ecx
  8041604ae9:	0f 85 11 01 00 00    	jne    8041604c00 <check_physical_tree+0x18f>
        if (page->left) assert(page->left->state == page->state);
  8041604aef:	48 8b 7f 10          	mov    0x10(%rdi),%rdi
  8041604af3:	48 85 ff             	test   %rdi,%rdi
  8041604af6:	0f 84 8e 05 00 00    	je     804160508a <check_physical_tree+0x619>
  8041604afc:	44 3b 57 28          	cmp    0x28(%rdi),%r10d
  8041604b00:	0f 85 90 00 00 00    	jne    8041604b96 <check_physical_tree+0x125>
        if (page->right) assert(page->right->state == page->state);
  8041604b06:	4c 8b 63 18          	mov    0x18(%rbx),%r12
  8041604b0a:	4d 85 e4             	test   %r12,%r12
  8041604b0d:	0f 84 f6 00 00 00    	je     8041604c09 <check_physical_tree+0x198>
  8041604b13:	45 3b 54 24 28       	cmp    0x28(%r12),%r10d
  8041604b18:	0f 85 ad 00 00 00    	jne    8041604bcb <check_physical_tree+0x15a>
    }
    if (page->left) {
  8041604b1e:	48 85 ff             	test   %rdi,%rdi
  8041604b21:	0f 85 e2 00 00 00    	jne    8041604c09 <check_physical_tree+0x198>
  8041604b27:	e9 1c 01 00 00       	jmp    8041604c48 <check_physical_tree+0x1d7>
    assert_physical(page);
  8041604b2c:	48 b9 58 ac 60 41 80 	movabs $0x804160ac58,%rcx
  8041604b33:	00 00 00 
  8041604b36:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041604b3d:	00 00 00 
  8041604b40:	be 87 01 00 00       	mov    $0x187,%esi
  8041604b45:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041604b4c:	00 00 00 
  8041604b4f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604b54:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041604b5b:	00 00 00 
  8041604b5e:	41 ff d0             	call   *%r8
    assert(!(page2pa(page) & CLASS_MASK(page->class)));
  8041604b61:	48 b9 90 ac 60 41 80 	movabs $0x804160ac90,%rcx
  8041604b68:	00 00 00 
  8041604b6b:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041604b72:	00 00 00 
  8041604b75:	be 89 01 00 00       	mov    $0x189,%esi
  8041604b7a:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041604b81:	00 00 00 
  8041604b84:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604b89:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041604b90:	00 00 00 
  8041604b93:	41 ff d0             	call   *%r8
        if (page->left) assert(page->left->state == page->state);
  8041604b96:	48 b9 c0 ac 60 41 80 	movabs $0x804160acc0,%rcx
  8041604b9d:	00 00 00 
  8041604ba0:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041604ba7:	00 00 00 
  8041604baa:	be 8b 01 00 00       	mov    $0x18b,%esi
  8041604baf:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041604bb6:	00 00 00 
  8041604bb9:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604bbe:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041604bc5:	00 00 00 
  8041604bc8:	41 ff d0             	call   *%r8
        if (page->right) assert(page->right->state == page->state);
  8041604bcb:	48 b9 e8 ac 60 41 80 	movabs $0x804160ace8,%rcx
  8041604bd2:	00 00 00 
  8041604bd5:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041604bdc:	00 00 00 
  8041604bdf:	be 8c 01 00 00       	mov    $0x18c,%esi
  8041604be4:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041604beb:	00 00 00 
  8041604bee:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604bf3:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041604bfa:	00 00 00 
  8041604bfd:	41 ff d0             	call   *%r8
    if (page->left) {
  8041604c00:	48 8b 7f 10          	mov    0x10(%rdi),%rdi
  8041604c04:	48 85 ff             	test   %rdi,%rdi
  8041604c07:	74 36                	je     8041604c3f <check_physical_tree+0x1ce>
        assert(page->left->class + 1 == page->class);
  8041604c09:	0f b7 4f 34          	movzwl 0x34(%rdi),%ecx
  8041604c0d:	81 e1 ff 0f 00 00    	and    $0xfff,%ecx
  8041604c13:	83 c1 01             	add    $0x1,%ecx
  8041604c16:	39 c8                	cmp    %ecx,%eax
  8041604c18:	0f 85 32 01 00 00    	jne    8041604d50 <check_physical_tree+0x2df>
  8041604c1e:	48 be ff ff ff ff ff 	movabs $0xfffffffffffff,%rsi
  8041604c25:	ff 0f 00 
  8041604c28:	48 89 f1             	mov    %rsi,%rcx
  8041604c2b:	48 23 4f 38          	and    0x38(%rdi),%rcx
  8041604c2f:	48 c1 e1 0c          	shl    $0xc,%rcx
  8041604c33:	48 21 f1             	and    %rsi,%rcx
        assert(page2pa(page) == page2pa(page->left));
  8041604c36:	49 39 c8             	cmp    %rcx,%r8
  8041604c39:	0f 85 46 01 00 00    	jne    8041604d85 <check_physical_tree+0x314>
    }
    if (page->right) {
  8041604c3f:	4c 8b 63 18          	mov    0x18(%rbx),%r12
  8041604c43:	4d 85 e4             	test   %r12,%r12
  8041604c46:	74 3d                	je     8041604c85 <check_physical_tree+0x214>
        assert(page->right->class + 1 == page->class);
  8041604c48:	41 0f b7 4c 24 34    	movzwl 0x34(%r12),%ecx
  8041604c4e:	81 e1 ff 0f 00 00    	and    $0xfff,%ecx
  8041604c54:	83 c1 01             	add    $0x1,%ecx
  8041604c57:	39 c8                	cmp    %ecx,%eax
  8041604c59:	0f 85 5b 01 00 00    	jne    8041604dba <check_physical_tree+0x349>
        assert(page->addr + (1ULL << (page->class - 1)) == page->right->addr);
  8041604c5f:	8d 48 ff             	lea    -0x1(%rax),%ecx
  8041604c62:	be 01 00 00 00       	mov    $0x1,%esi
  8041604c67:	48 d3 e6             	shl    %cl,%rsi
  8041604c6a:	4c 01 ce             	add    %r9,%rsi
  8041604c6d:	48 b9 ff ff ff ff ff 	movabs $0xfffffffffffff,%rcx
  8041604c74:	ff 0f 00 
  8041604c77:	49 23 4c 24 38       	and    0x38(%r12),%rcx
  8041604c7c:	48 39 ce             	cmp    %rcx,%rsi
  8041604c7f:	0f 85 6a 01 00 00    	jne    8041604def <check_physical_tree+0x37e>
    }
    if (page->parent) {
  8041604c85:	48 8b 73 20          	mov    0x20(%rbx),%rsi
  8041604c89:	48 85 f6             	test   %rsi,%rsi
  8041604c8c:	0f 84 fc 01 00 00    	je     8041604e8e <check_physical_tree+0x41d>
        assert(page->parent->class - 1 == page->class);
  8041604c92:	0f b7 4e 34          	movzwl 0x34(%rsi),%ecx
  8041604c96:	81 e1 ff 0f 00 00    	and    $0xfff,%ecx
  8041604c9c:	83 e9 01             	sub    $0x1,%ecx
  8041604c9f:	39 c8                	cmp    %ecx,%eax
  8041604ca1:	0f 85 7d 01 00 00    	jne    8041604e24 <check_physical_tree+0x3b3>
        assert((page->parent->left == page) ^ (page->parent->right == page));
  8041604ca7:	48 39 5e 10          	cmp    %rbx,0x10(%rsi)
  8041604cab:	0f 95 c1             	setne  %cl
  8041604cae:	48 39 5e 18          	cmp    %rbx,0x18(%rsi)
  8041604cb2:	0f 94 c0             	sete   %al
  8041604cb5:	38 c1                	cmp    %al,%cl
  8041604cb7:	0f 85 9c 01 00 00    	jne    8041604e59 <check_physical_tree+0x3e8>
    } else {
        assert(page->class == MAX_CLASS);
        assert(page == &root);
    }
    if (!page->refc) {
  8041604cbd:	83 7b 30 00          	cmpl   $0x0,0x30(%rbx)
  8041604cc1:	0f 85 87 02 00 00    	jne    8041604f4e <check_physical_tree+0x4dd>
        assert(page->head.next && page->head.prev);
  8041604cc7:	48 8b 43 08          	mov    0x8(%rbx),%rax
  8041604ccb:	48 85 c0             	test   %rax,%rax
  8041604cce:	0f 84 45 02 00 00    	je     8041604f19 <check_physical_tree+0x4a8>
  8041604cd4:	48 83 3b 00          	cmpq   $0x0,(%rbx)
  8041604cd8:	0f 84 3b 02 00 00    	je     8041604f19 <check_physical_tree+0x4a8>
        if (!list_empty((struct List *)page)) {
  8041604cde:	48 39 d8             	cmp    %rbx,%rax
  8041604ce1:	0f 84 90 02 00 00    	je     8041604f77 <check_physical_tree+0x506>
            for (struct List *n = page->head.next;
                 n != &free_classes[page->class]; n = n->next) {
  8041604ce7:	0f b7 d2             	movzwl %dx,%edx
  8041604cea:	48 c1 e2 04          	shl    $0x4,%rdx
  8041604cee:	48 b9 c0 40 e0 41 80 	movabs $0x8041e040c0,%rcx
  8041604cf5:	00 00 00 
  8041604cf8:	48 01 ca             	add    %rcx,%rdx
  8041604cfb:	48 39 d0             	cmp    %rdx,%rax
  8041604cfe:	0f 84 73 02 00 00    	je     8041604f77 <check_physical_tree+0x506>
                assert(n != &page->head);
  8041604d04:	48 39 d8             	cmp    %rbx,%rax
  8041604d07:	74 12                	je     8041604d1b <check_physical_tree+0x2aa>
                 n != &free_classes[page->class]; n = n->next) {
  8041604d09:	48 8b 40 08          	mov    0x8(%rax),%rax
  8041604d0d:	48 39 c2             	cmp    %rax,%rdx
  8041604d10:	0f 84 61 02 00 00    	je     8041604f77 <check_physical_tree+0x506>
                assert(n != &page->head);
  8041604d16:	48 39 c3             	cmp    %rax,%rbx
  8041604d19:	75 ee                	jne    8041604d09 <check_physical_tree+0x298>
  8041604d1b:	48 b9 34 ab 60 41 80 	movabs $0x804160ab34,%rcx
  8041604d22:	00 00 00 
  8041604d25:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041604d2c:	00 00 00 
  8041604d2f:	be a2 01 00 00       	mov    $0x1a2,%esi
  8041604d34:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041604d3b:	00 00 00 
  8041604d3e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604d43:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041604d4a:	00 00 00 
  8041604d4d:	41 ff d0             	call   *%r8
        assert(page->left->class + 1 == page->class);
  8041604d50:	48 b9 10 ad 60 41 80 	movabs $0x804160ad10,%rcx
  8041604d57:	00 00 00 
  8041604d5a:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041604d61:	00 00 00 
  8041604d64:	be 8f 01 00 00       	mov    $0x18f,%esi
  8041604d69:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041604d70:	00 00 00 
  8041604d73:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604d78:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041604d7f:	00 00 00 
  8041604d82:	41 ff d0             	call   *%r8
        assert(page2pa(page) == page2pa(page->left));
  8041604d85:	48 b9 38 ad 60 41 80 	movabs $0x804160ad38,%rcx
  8041604d8c:	00 00 00 
  8041604d8f:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041604d96:	00 00 00 
  8041604d99:	be 90 01 00 00       	mov    $0x190,%esi
  8041604d9e:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041604da5:	00 00 00 
  8041604da8:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604dad:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041604db4:	00 00 00 
  8041604db7:	41 ff d0             	call   *%r8
        assert(page->right->class + 1 == page->class);
  8041604dba:	48 b9 60 ad 60 41 80 	movabs $0x804160ad60,%rcx
  8041604dc1:	00 00 00 
  8041604dc4:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041604dcb:	00 00 00 
  8041604dce:	be 93 01 00 00       	mov    $0x193,%esi
  8041604dd3:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041604dda:	00 00 00 
  8041604ddd:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604de2:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041604de9:	00 00 00 
  8041604dec:	41 ff d0             	call   *%r8
        assert(page->addr + (1ULL << (page->class - 1)) == page->right->addr);
  8041604def:	48 b9 88 ad 60 41 80 	movabs $0x804160ad88,%rcx
  8041604df6:	00 00 00 
  8041604df9:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041604e00:	00 00 00 
  8041604e03:	be 94 01 00 00       	mov    $0x194,%esi
  8041604e08:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041604e0f:	00 00 00 
  8041604e12:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604e17:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041604e1e:	00 00 00 
  8041604e21:	41 ff d0             	call   *%r8
        assert(page->parent->class - 1 == page->class);
  8041604e24:	48 b9 c8 ad 60 41 80 	movabs $0x804160adc8,%rcx
  8041604e2b:	00 00 00 
  8041604e2e:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041604e35:	00 00 00 
  8041604e38:	be 97 01 00 00       	mov    $0x197,%esi
  8041604e3d:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041604e44:	00 00 00 
  8041604e47:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604e4c:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041604e53:	00 00 00 
  8041604e56:	41 ff d0             	call   *%r8
        assert((page->parent->left == page) ^ (page->parent->right == page));
  8041604e59:	48 b9 f0 ad 60 41 80 	movabs $0x804160adf0,%rcx
  8041604e60:	00 00 00 
  8041604e63:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041604e6a:	00 00 00 
  8041604e6d:	be 98 01 00 00       	mov    $0x198,%esi
  8041604e72:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041604e79:	00 00 00 
  8041604e7c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604e81:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041604e88:	00 00 00 
  8041604e8b:	41 ff d0             	call   *%r8
        assert(page->class == MAX_CLASS);
  8041604e8e:	0f b7 43 34          	movzwl 0x34(%rbx),%eax
  8041604e92:	66 25 ff 0f          	and    $0xfff,%ax
  8041604e96:	66 83 f8 30          	cmp    $0x30,%ax
  8041604e9a:	75 48                	jne    8041604ee4 <check_physical_tree+0x473>
        assert(page == &root);
  8041604e9c:	48 b8 00 00 e0 41 80 	movabs $0x8041e00000,%rax
  8041604ea3:	00 00 00 
  8041604ea6:	48 39 c3             	cmp    %rax,%rbx
  8041604ea9:	0f 84 0e fe ff ff    	je     8041604cbd <check_physical_tree+0x24c>
  8041604eaf:	48 b9 26 ab 60 41 80 	movabs $0x804160ab26,%rcx
  8041604eb6:	00 00 00 
  8041604eb9:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041604ec0:	00 00 00 
  8041604ec3:	be 9b 01 00 00       	mov    $0x19b,%esi
  8041604ec8:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041604ecf:	00 00 00 
  8041604ed2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604ed7:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041604ede:	00 00 00 
  8041604ee1:	41 ff d0             	call   *%r8
        assert(page->class == MAX_CLASS);
  8041604ee4:	48 b9 0d ab 60 41 80 	movabs $0x804160ab0d,%rcx
  8041604eeb:	00 00 00 
  8041604eee:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041604ef5:	00 00 00 
  8041604ef8:	be 9a 01 00 00       	mov    $0x19a,%esi
  8041604efd:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041604f04:	00 00 00 
  8041604f07:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604f0c:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041604f13:	00 00 00 
  8041604f16:	41 ff d0             	call   *%r8
        assert(page->head.next && page->head.prev);
  8041604f19:	48 b9 30 ae 60 41 80 	movabs $0x804160ae30,%rcx
  8041604f20:	00 00 00 
  8041604f23:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041604f2a:	00 00 00 
  8041604f2d:	be 9e 01 00 00       	mov    $0x19e,%esi
  8041604f32:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041604f39:	00 00 00 
  8041604f3c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604f41:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041604f48:	00 00 00 
  8041604f4b:	41 ff d0             	call   *%r8
            }
        }
    } else {
        for (struct List *n = (struct List *)page->head.next;
  8041604f4e:	48 8b 43 08          	mov    0x8(%rbx),%rax
             (struct List *)page != n; n = n->next) {
  8041604f52:	48 39 c3             	cmp    %rax,%rbx
  8041604f55:	74 20                	je     8041604f77 <check_physical_tree+0x506>
            struct Page *v = (struct Page *)n;
            assert_virtual(v);
  8041604f57:	8b 50 28             	mov    0x28(%rax),%edx
  8041604f5a:	81 e2 00 00 f0 00    	and    $0xf00000,%edx
  8041604f60:	81 fa ff ff 2f 00    	cmp    $0x2fffff,%edx
  8041604f66:	77 4e                	ja     8041604fb6 <check_physical_tree+0x545>
            assert(v->phy == page);
  8041604f68:	48 39 58 30          	cmp    %rbx,0x30(%rax)
  8041604f6c:	75 7d                	jne    8041604feb <check_physical_tree+0x57a>
             (struct List *)page != n; n = n->next) {
  8041604f6e:	48 8b 40 08          	mov    0x8(%rax),%rax
  8041604f72:	48 39 c3             	cmp    %rax,%rbx
  8041604f75:	75 e0                	jne    8041604f57 <check_physical_tree+0x4e6>
        }
    }
    if (page->left) {
  8041604f77:	48 85 ff             	test   %rdi,%rdi
  8041604f7a:	74 16                	je     8041604f92 <check_physical_tree+0x521>
        assert(page->left->parent == page);
  8041604f7c:	48 39 5f 20          	cmp    %rbx,0x20(%rdi)
  8041604f80:	0f 85 9a 00 00 00    	jne    8041605020 <check_physical_tree+0x5af>
        check_physical_tree(page->left);
  8041604f86:	48 b8 71 4a 60 41 80 	movabs $0x8041604a71,%rax
  8041604f8d:	00 00 00 
  8041604f90:	ff d0                	call   *%rax
    }
    if (page->right) {
  8041604f92:	4d 85 e4             	test   %r12,%r12
  8041604f95:	74 1a                	je     8041604fb1 <check_physical_tree+0x540>
        assert(page->right->parent == page);
  8041604f97:	49 39 5c 24 20       	cmp    %rbx,0x20(%r12)
  8041604f9c:	0f 85 b3 00 00 00    	jne    8041605055 <check_physical_tree+0x5e4>
        check_physical_tree(page->right);
  8041604fa2:	4c 89 e7             	mov    %r12,%rdi
  8041604fa5:	48 b8 71 4a 60 41 80 	movabs $0x8041604a71,%rax
  8041604fac:	00 00 00 
  8041604faf:	ff d0                	call   *%rax
    }
}
  8041604fb1:	5b                   	pop    %rbx
  8041604fb2:	41 5c                	pop    %r12
  8041604fb4:	5d                   	pop    %rbp
  8041604fb5:	c3                   	ret    
            assert_virtual(v);
  8041604fb6:	48 b9 58 ae 60 41 80 	movabs $0x804160ae58,%rcx
  8041604fbd:	00 00 00 
  8041604fc0:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041604fc7:	00 00 00 
  8041604fca:	be a9 01 00 00       	mov    $0x1a9,%esi
  8041604fcf:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041604fd6:	00 00 00 
  8041604fd9:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604fde:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041604fe5:	00 00 00 
  8041604fe8:	41 ff d0             	call   *%r8
            assert(v->phy == page);
  8041604feb:	48 b9 45 ab 60 41 80 	movabs $0x804160ab45,%rcx
  8041604ff2:	00 00 00 
  8041604ff5:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041604ffc:	00 00 00 
  8041604fff:	be aa 01 00 00       	mov    $0x1aa,%esi
  8041605004:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  804160500b:	00 00 00 
  804160500e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605013:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  804160501a:	00 00 00 
  804160501d:	41 ff d0             	call   *%r8
        assert(page->left->parent == page);
  8041605020:	48 b9 54 ab 60 41 80 	movabs $0x804160ab54,%rcx
  8041605027:	00 00 00 
  804160502a:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041605031:	00 00 00 
  8041605034:	be ae 01 00 00       	mov    $0x1ae,%esi
  8041605039:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041605040:	00 00 00 
  8041605043:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605048:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  804160504f:	00 00 00 
  8041605052:	41 ff d0             	call   *%r8
        assert(page->right->parent == page);
  8041605055:	48 b9 6f ab 60 41 80 	movabs $0x804160ab6f,%rcx
  804160505c:	00 00 00 
  804160505f:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041605066:	00 00 00 
  8041605069:	be b2 01 00 00       	mov    $0x1b2,%esi
  804160506e:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041605075:	00 00 00 
  8041605078:	b8 00 00 00 00       	mov    $0x0,%eax
  804160507d:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041605084:	00 00 00 
  8041605087:	41 ff d0             	call   *%r8
        if (page->right) assert(page->right->state == page->state);
  804160508a:	4c 8b 63 18          	mov    0x18(%rbx),%r12
  804160508e:	4d 85 e4             	test   %r12,%r12
  8041605091:	0f 85 7c fa ff ff    	jne    8041604b13 <check_physical_tree+0xa2>
    if (page->left) {
  8041605097:	4c 89 e7             	mov    %r12,%rdi
  804160509a:	e9 e6 fb ff ff       	jmp    8041604c85 <check_physical_tree+0x214>

000000804160509f <ensure_free_desc>:
ensure_free_desc(size_t count) {
  804160509f:	f3 0f 1e fa          	endbr64 
  80416050a3:	55                   	push   %rbp
  80416050a4:	48 89 e5             	mov    %rsp,%rbp
  80416050a7:	41 55                	push   %r13
  80416050a9:	41 54                	push   %r12
  80416050ab:	53                   	push   %rbx
  80416050ac:	48 83 ec 08          	sub    $0x8,%rsp
    if (free_desc_count < count) {
  80416050b0:	48 b8 98 40 e0 41 80 	movabs $0x8041e04098,%rax
  80416050b7:	00 00 00 
  80416050ba:	4c 8b 08             	mov    (%rax),%r9
  80416050bd:	49 39 f9             	cmp    %rdi,%r9
  80416050c0:	72 1f                	jb     80416050e1 <ensure_free_desc+0x42>
    return list->next == list;
  80416050c2:	48 b8 a0 40 e0 41 80 	movabs $0x8041e040a0,%rax
  80416050c9:	00 00 00 
    assert(!list_empty(&free_descriptors));
  80416050cc:	48 39 40 08          	cmp    %rax,0x8(%rax)
  80416050d0:	0f 84 65 04 00 00    	je     804160553b <ensure_free_desc+0x49c>
}
  80416050d6:	48 83 c4 08          	add    $0x8,%rsp
  80416050da:	5b                   	pop    %rbx
  80416050db:	41 5c                	pop    %r12
  80416050dd:	41 5d                	pop    %r13
  80416050df:	5d                   	pop    %rbp
  80416050e0:	c3                   	ret    
  80416050e1:	48 89 fb             	mov    %rdi,%rbx
  80416050e4:	48 b8 d0 40 e0 41 80 	movabs $0x8041e040d0,%rax
  80416050eb:	00 00 00 
  80416050ee:	4c 8d 80 f0 02 00 00 	lea    0x2f0(%rax),%r8
  80416050f5:	48 b9 ff ff ff ff ff 	movabs $0xfffffffffffff,%rcx
  80416050fc:	ff 0f 00 
    if (flags & ALLOC_POOL) flags |= ALLOC_BOOTMEM;

    /* Find page that is not smaller than requested
     * (Pool memory should also be within BOOT_MEM_SIZE) */
    for (int pclass = class; pclass < MAX_CLASS; pclass++, li = NULL) {
        for (li = free_classes[pclass].next; li != &free_classes[pclass]; li = li->next) {
  80416050ff:	48 89 c6             	mov    %rax,%rsi
  8041605102:	48 8b 78 08          	mov    0x8(%rax),%rdi
  8041605106:	48 39 c7             	cmp    %rax,%rdi
  8041605109:	74 30                	je     804160513b <ensure_free_desc+0x9c>
            peer = (struct Page *)li;
            assert(peer->state == ALLOCATABLE_NODE);
  804160510b:	81 7f 28 00 00 40 00 	cmpl   $0x400000,0x28(%rdi)
  8041605112:	75 5a                	jne    804160516e <ensure_free_desc+0xcf>
  8041605114:	48 89 ca             	mov    %rcx,%rdx
  8041605117:	48 23 57 38          	and    0x38(%rdi),%rdx
  804160511b:	48 c1 e2 0c          	shl    $0xc,%rdx
  804160511f:	48 21 ca             	and    %rcx,%rdx
            assert_physical(peer);
            if (!(flags & ALLOC_BOOTMEM) || page2pa(peer) + CLASS_SIZE(class) < BOOT_MEM_SIZE) goto found;
  8041605122:	48 81 c2 00 20 00 00 	add    $0x2000,%rdx
  8041605129:	48 81 fa ff ff ff 3f 	cmp    $0x3fffffff,%rdx
  8041605130:	76 71                	jbe    80416051a3 <ensure_free_desc+0x104>
        for (li = free_classes[pclass].next; li != &free_classes[pclass]; li = li->next) {
  8041605132:	48 8b 7f 08          	mov    0x8(%rdi),%rdi
  8041605136:	48 39 fe             	cmp    %rdi,%rsi
  8041605139:	75 d0                	jne    804160510b <ensure_free_desc+0x6c>
    for (int pclass = class; pclass < MAX_CLASS; pclass++, li = NULL) {
  804160513b:	48 83 c0 10          	add    $0x10,%rax
  804160513f:	4c 39 c0             	cmp    %r8,%rax
  8041605142:	75 bb                	jne    80416050ff <ensure_free_desc+0x60>
        if (!res) panic("Out of memory\n");
  8041605144:	48 ba c0 ab 60 41 80 	movabs $0x804160abc0,%rdx
  804160514b:	00 00 00 
  804160514e:	be 71 00 00 00       	mov    $0x71,%esi
  8041605153:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  804160515a:	00 00 00 
  804160515d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605162:	48 b9 e3 03 60 41 80 	movabs $0x80416003e3,%rcx
  8041605169:	00 00 00 
  804160516c:	ff d1                	call   *%rcx
            assert(peer->state == ALLOCATABLE_NODE);
  804160516e:	48 b9 88 ae 60 41 80 	movabs $0x804160ae88,%rcx
  8041605175:	00 00 00 
  8041605178:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  804160517f:	00 00 00 
  8041605182:	be 0f 02 00 00       	mov    $0x20f,%esi
  8041605187:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  804160518e:	00 00 00 
  8041605191:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605196:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  804160519d:	00 00 00 
  80416051a0:	41 ff d0             	call   *%r8
    list->next->prev = list->prev;
  80416051a3:	48 8b 57 08          	mov    0x8(%rdi),%rdx
  80416051a7:	48 8b 07             	mov    (%rdi),%rax
  80416051aa:	48 89 02             	mov    %rax,(%rdx)
    list->prev->next = list->next;
  80416051ad:	48 8b 57 08          	mov    0x8(%rdi),%rdx
  80416051b1:	48 89 50 08          	mov    %rdx,0x8(%rax)
    list->next = list->prev = list;
  80416051b5:	48 89 3f             	mov    %rdi,(%rdi)
  80416051b8:	48 89 7f 08          	mov    %rdi,0x8(%rdi)
    list_del(li);

    size_t ndesc = 0;
    static bool allocating_pool;
    if (flags & ALLOC_POOL) {
        assert(!allocating_pool);
  80416051bc:	48 b8 80 40 e0 41 80 	movabs $0x8041e04080,%rax
  80416051c3:	00 00 00 
  80416051c6:	80 38 00             	cmpb   $0x0,(%rax)
  80416051c9:	0f 85 0e 02 00 00    	jne    80416053dd <ensure_free_desc+0x33e>
        allocating_pool = 1;
  80416051cf:	48 b8 80 40 e0 41 80 	movabs $0x8041e04080,%rax
  80416051d6:	00 00 00 
  80416051d9:	c6 00 01             	movb   $0x1,(%rax)
  80416051dc:	48 b8 ff ff ff ff ff 	movabs $0xfffffffffffff,%rax
  80416051e3:	ff 0f 00 
  80416051e6:	48 89 c1             	mov    %rax,%rcx
  80416051e9:	48 23 4f 38          	and    0x38(%rdi),%rcx
  80416051ed:	48 c1 e1 0c          	shl    $0xc,%rcx
  80416051f1:	48 21 c1             	and    %rax,%rcx
    if (pa > max_memory_map_addr)
  80416051f4:	48 a1 68 00 e0 41 80 	movabs 0x8041e00068,%rax
  80416051fb:	00 00 00 
  80416051fe:	48 39 c1             	cmp    %rax,%rcx
  8041605201:	0f 87 0b 02 00 00    	ja     8041605412 <ensure_free_desc+0x373>
    return (void *)(pa + KERN_BASE_ADDR);
  8041605207:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  804160520e:	00 00 00 
  8041605211:	48 01 c8             	add    %rcx,%rax

        struct PagePool *newpool = KADDR(page2pa(peer));
        ndesc = POOL_ENTRIES_FOR_SIZE(CLASS_SIZE(class));
        for (size_t i = 0; i < ndesc; i++)
  8041605214:	48 ba 10 00 00 40 80 	movabs $0x8040000010,%rdx
  804160521b:	00 00 00 
  804160521e:	48 01 ca             	add    %rcx,%rdx
  8041605221:	48 be d0 1f 00 40 80 	movabs $0x8040001fd0,%rsi
  8041605228:	00 00 00 
  804160522b:	48 01 f1             	add    %rsi,%rcx
    new->next = list->next;
  804160522e:	48 be a0 40 e0 41 80 	movabs $0x8041e040a0,%rsi
  8041605235:	00 00 00 
  8041605238:	4c 8b 46 08          	mov    0x8(%rsi),%r8
  804160523c:	4c 89 42 08          	mov    %r8,0x8(%rdx)
    new->prev = list;
  8041605240:	48 89 32             	mov    %rsi,(%rdx)
    list->next->prev = new;
  8041605243:	49 89 10             	mov    %rdx,(%r8)
    list->next = new;
  8041605246:	48 89 56 08          	mov    %rdx,0x8(%rsi)
        for (size_t i = 0; i < ndesc; i++)
  804160524a:	48 83 c2 40          	add    $0x40,%rdx
  804160524e:	48 39 d1             	cmp    %rdx,%rcx
  8041605251:	75 e5                	jne    8041605238 <ensure_free_desc+0x199>
            list_append(&free_descriptors, (struct List *)&newpool->data[i]);
        newpool->next = first_pool;
  8041605253:	48 ba b0 40 e0 41 80 	movabs $0x8041e040b0,%rdx
  804160525a:	00 00 00 
  804160525d:	48 8b 0a             	mov    (%rdx),%rcx
  8041605260:	48 89 48 08          	mov    %rcx,0x8(%rax)
        first_pool = newpool;
  8041605264:	48 89 02             	mov    %rax,(%rdx)
        free_desc_count += ndesc;
  8041605267:	49 8d 41 7f          	lea    0x7f(%r9),%rax
  804160526b:	48 a3 98 40 e0 41 80 	movabs %rax,0x8041e04098
  8041605272:	00 00 00 
    return page->addr << CLASS_BASE;
  8041605275:	48 b8 ff ff ff ff ff 	movabs $0xfffffffffffff,%rax
  804160527c:	ff 0f 00 
  804160527f:	48 89 c6             	mov    %rax,%rsi
  8041605282:	48 23 77 38          	and    0x38(%rdi),%rsi
  8041605286:	48 c1 e6 0c          	shl    $0xc,%rsi
  804160528a:	48 21 c6             	and    %rax,%rsi
        if (trace_memory_more) cprintf("Allocated pool of size %zu at [%08lX, %08lX]\n",
                                       ndesc, page2pa(peer), page2pa(peer) + (long)CLASS_MASK(class));
    }

    struct Page *new = page_lookup(peer, page2pa(peer), class, PARTIAL_NODE, 1);
  804160528d:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  8041605293:	b9 00 00 30 00       	mov    $0x300000,%ecx
  8041605298:	ba 01 00 00 00       	mov    $0x1,%edx
  804160529d:	48 b8 fc 56 60 41 80 	movabs $0x80416056fc,%rax
  80416052a4:	00 00 00 
  80416052a7:	ff d0                	call   *%rax
  80416052a9:	49 89 c4             	mov    %rax,%r12
    assert(!new->refc);
  80416052ac:	83 78 30 00          	cmpl   $0x0,0x30(%rax)
  80416052b0:	0f 85 8a 01 00 00    	jne    8041605440 <ensure_free_desc+0x3a1>
  80416052b6:	48 b8 ff ff ff ff ff 	movabs $0xfffffffffffff,%rax
  80416052bd:	ff 0f 00 
  80416052c0:	48 89 c1             	mov    %rax,%rcx
  80416052c3:	49 23 4c 24 38       	and    0x38(%r12),%rcx
  80416052c8:	48 c1 e1 0c          	shl    $0xc,%rcx
  80416052cc:	48 21 c1             	and    %rax,%rcx
    if (pa > max_memory_map_addr)
  80416052cf:	48 a1 68 00 e0 41 80 	movabs 0x8041e00068,%rax
  80416052d6:	00 00 00 
  80416052d9:	48 39 c1             	cmp    %rax,%rcx
  80416052dc:	0f 87 93 01 00 00    	ja     8041605475 <ensure_free_desc+0x3d6>

    if (flags & ALLOC_POOL) {
        assert(KADDR(page2pa(new)) == first_pool);
  80416052e2:	48 b8 b0 40 e0 41 80 	movabs $0x8041e040b0,%rax
  80416052e9:	00 00 00 
  80416052ec:	4c 8b 28             	mov    (%rax),%r13
    return (void *)(pa + KERN_BASE_ADDR);
  80416052ef:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  80416052f6:	00 00 00 
  80416052f9:	48 01 c1             	add    %rax,%rcx
  80416052fc:	49 39 cd             	cmp    %rcx,%r13
  80416052ff:	0f 85 9e 01 00 00    	jne    80416054a3 <ensure_free_desc+0x404>
        page_ref(new);
  8041605305:	4c 89 e7             	mov    %r12,%rdi
  8041605308:	48 b8 4e 49 60 41 80 	movabs $0x804160494e,%rax
  804160530f:	00 00 00 
  8041605312:	ff d0                	call   *%rax
        first_pool->peer = new;
  8041605314:	4d 89 65 00          	mov    %r12,0x0(%r13)
        allocating_pool = 0;
  8041605318:	48 b8 80 40 e0 41 80 	movabs $0x8041e04080,%rax
  804160531f:	00 00 00 
  8041605322:	c6 00 00             	movb   $0x0,(%rax)
    return page->addr << CLASS_BASE;
  8041605325:	48 ba ff ff ff ff ff 	movabs $0xfffffffffffff,%rdx
  804160532c:	ff 0f 00 
  804160532f:	48 89 d0             	mov    %rdx,%rax
  8041605332:	49 23 44 24 38       	and    0x38(%r12),%rax
  8041605337:	48 c1 e0 0c          	shl    $0xc,%rax
  804160533b:	48 21 d0             	and    %rdx,%rax
    if ((uint64_t)kva < KERN_BASE_ADDR)
  804160533e:	48 ba 00 60 e4 41 80 	movabs $0x8041e46000,%rdx
  8041605345:	00 00 00 
  8041605348:	48 b9 ff ff ff 3f 80 	movabs $0x803fffffff,%rcx
  804160534f:	00 00 00 
  8041605352:	48 39 ca             	cmp    %rcx,%rdx
  8041605355:	0f 86 7d 01 00 00    	jbe    80416054d8 <ensure_free_desc+0x439>
    return (physaddr_t)kva - KERN_BASE_ADDR;
  804160535b:	48 b9 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rcx
  8041605362:	ff ff ff 
  8041605365:	48 01 ca             	add    %rcx,%rdx
    } else {
        if (trace_memory_more) cprintf("Allocated page at [%08lX, %08lX] class=%d\n",
                                       page2pa(new), page2pa(new) + (long)CLASS_MASK(new->class), new->class);
    }

    assert(page2pa(new) >= PADDR(end) || page2pa(new) + CLASS_MASK(new->class) < IOPHYSMEM);
  8041605368:	48 39 d0             	cmp    %rdx,%rax
  804160536b:	73 28                	jae    8041605395 <ensure_free_desc+0x2f6>
  804160536d:	41 0f b7 4c 24 34    	movzwl 0x34(%r12),%ecx
  8041605373:	81 e1 ff 0f 00 00    	and    $0xfff,%ecx
  8041605379:	83 c1 0c             	add    $0xc,%ecx
  804160537c:	ba 01 00 00 00       	mov    $0x1,%edx
  8041605381:	48 d3 e2             	shl    %cl,%rdx
  8041605384:	48 8d 44 10 ff       	lea    -0x1(%rax,%rdx,1),%rax
  8041605389:	48 3d ff ff 09 00    	cmp    $0x9ffff,%rax
  804160538f:	0f 87 71 01 00 00    	ja     8041605506 <ensure_free_desc+0x467>
    assert(free_desc_count >= count);
  8041605395:	48 b8 98 40 e0 41 80 	movabs $0x8041e04098,%rax
  804160539c:	00 00 00 
  804160539f:	48 39 18             	cmp    %rbx,(%rax)
  80416053a2:	0f 83 1a fd ff ff    	jae    80416050c2 <ensure_free_desc+0x23>
  80416053a8:	48 b9 a7 ab 60 41 80 	movabs $0x804160aba7,%rcx
  80416053af:	00 00 00 
  80416053b2:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  80416053b9:	00 00 00 
  80416053bc:	be 74 00 00 00       	mov    $0x74,%esi
  80416053c1:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  80416053c8:	00 00 00 
  80416053cb:	b8 00 00 00 00       	mov    $0x0,%eax
  80416053d0:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  80416053d7:	00 00 00 
  80416053da:	41 ff d0             	call   *%r8
        assert(!allocating_pool);
  80416053dd:	48 b9 8b ab 60 41 80 	movabs $0x804160ab8b,%rcx
  80416053e4:	00 00 00 
  80416053e7:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  80416053ee:	00 00 00 
  80416053f1:	be 1c 02 00 00       	mov    $0x21c,%esi
  80416053f6:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  80416053fd:	00 00 00 
  8041605400:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605405:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  804160540c:	00 00 00 
  804160540f:	41 ff d0             	call   *%r8
        _panic(file, line, "KADDR called with invalid pa %p with max_memory_map_addr=%p", (void *)pa, (void *)max_memory_map_addr);
  8041605412:	49 89 c0             	mov    %rax,%r8
  8041605415:	48 ba a8 ae 60 41 80 	movabs $0x804160aea8,%rdx
  804160541c:	00 00 00 
  804160541f:	be 1f 02 00 00       	mov    $0x21f,%esi
  8041605424:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  804160542b:	00 00 00 
  804160542e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605433:	49 b9 e3 03 60 41 80 	movabs $0x80416003e3,%r9
  804160543a:	00 00 00 
  804160543d:	41 ff d1             	call   *%r9
    assert(!new->refc);
  8041605440:	48 b9 9c ab 60 41 80 	movabs $0x804160ab9c,%rcx
  8041605447:	00 00 00 
  804160544a:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041605451:	00 00 00 
  8041605454:	be 2b 02 00 00       	mov    $0x22b,%esi
  8041605459:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041605460:	00 00 00 
  8041605463:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605468:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  804160546f:	00 00 00 
  8041605472:	41 ff d0             	call   *%r8
  8041605475:	49 89 c0             	mov    %rax,%r8
  8041605478:	48 ba a8 ae 60 41 80 	movabs $0x804160aea8,%rdx
  804160547f:	00 00 00 
  8041605482:	be 2e 02 00 00       	mov    $0x22e,%esi
  8041605487:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  804160548e:	00 00 00 
  8041605491:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605496:	49 b9 e3 03 60 41 80 	movabs $0x80416003e3,%r9
  804160549d:	00 00 00 
  80416054a0:	41 ff d1             	call   *%r9
        assert(KADDR(page2pa(new)) == first_pool);
  80416054a3:	48 b9 e8 ae 60 41 80 	movabs $0x804160aee8,%rcx
  80416054aa:	00 00 00 
  80416054ad:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  80416054b4:	00 00 00 
  80416054b7:	be 2e 02 00 00       	mov    $0x22e,%esi
  80416054bc:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  80416054c3:	00 00 00 
  80416054c6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416054cb:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  80416054d2:	00 00 00 
  80416054d5:	41 ff d0             	call   *%r8
        _panic(file, line, "PADDR called with invalid kva %p", kva);
  80416054d8:	48 89 d1             	mov    %rdx,%rcx
  80416054db:	48 ba 10 af 60 41 80 	movabs $0x804160af10,%rdx
  80416054e2:	00 00 00 
  80416054e5:	be 37 02 00 00       	mov    $0x237,%esi
  80416054ea:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  80416054f1:	00 00 00 
  80416054f4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416054f9:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041605500:	00 00 00 
  8041605503:	41 ff d0             	call   *%r8
    assert(page2pa(new) >= PADDR(end) || page2pa(new) + CLASS_MASK(new->class) < IOPHYSMEM);
  8041605506:	48 b9 38 af 60 41 80 	movabs $0x804160af38,%rcx
  804160550d:	00 00 00 
  8041605510:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041605517:	00 00 00 
  804160551a:	be 37 02 00 00       	mov    $0x237,%esi
  804160551f:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041605526:	00 00 00 
  8041605529:	b8 00 00 00 00       	mov    $0x0,%eax
  804160552e:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041605535:	00 00 00 
  8041605538:	41 ff d0             	call   *%r8
    assert(!list_empty(&free_descriptors));
  804160553b:	48 b9 88 af 60 41 80 	movabs $0x804160af88,%rcx
  8041605542:	00 00 00 
  8041605545:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  804160554c:	00 00 00 
  804160554f:	be 75 00 00 00       	mov    $0x75,%esi
  8041605554:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  804160555b:	00 00 00 
  804160555e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605563:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  804160556a:	00 00 00 
  804160556d:	41 ff d0             	call   *%r8

0000008041605570 <alloc_child>:
alloc_child(struct Page *parent, bool right) {
  8041605570:	f3 0f 1e fa          	endbr64 
  8041605574:	55                   	push   %rbp
  8041605575:	48 89 e5             	mov    %rsp,%rbp
  8041605578:	41 56                	push   %r14
  804160557a:	41 55                	push   %r13
  804160557c:	41 54                	push   %r12
  804160557e:	53                   	push   %rbx
    assert_physical(parent);
  804160557f:	44 8b 77 28          	mov    0x28(%rdi),%r14d
  8041605583:	44 89 f0             	mov    %r14d,%eax
  8041605586:	25 00 00 f0 00       	and    $0xf00000,%eax
  804160558b:	3d ff ff 2f 00       	cmp    $0x2fffff,%eax
  8041605590:	0f 86 fd 00 00 00    	jbe    8041605693 <alloc_child+0x123>
  8041605596:	49 89 fc             	mov    %rdi,%r12
  8041605599:	41 89 f5             	mov    %esi,%r13d
    ensure_free_desc(1);
  804160559c:	bf 01 00 00 00       	mov    $0x1,%edi
  80416055a1:	48 b8 9f 50 60 41 80 	movabs $0x804160509f,%rax
  80416055a8:	00 00 00 
  80416055ab:	ff d0                	call   *%rax
    struct Page *new = (struct Page *)list_del(free_descriptors.next);
  80416055ad:	48 b8 a8 40 e0 41 80 	movabs $0x8041e040a8,%rax
  80416055b4:	00 00 00 
  80416055b7:	48 8b 18             	mov    (%rax),%rbx
    list->next->prev = list->prev;
  80416055ba:	48 8b 53 08          	mov    0x8(%rbx),%rdx
  80416055be:	48 8b 03             	mov    (%rbx),%rax
  80416055c1:	48 89 02             	mov    %rax,(%rdx)
    list->prev->next = list->next;
  80416055c4:	48 8b 53 08          	mov    0x8(%rbx),%rdx
  80416055c8:	48 89 50 08          	mov    %rdx,0x8(%rax)
    list->next = list->prev = list;
  80416055cc:	48 89 1b             	mov    %rbx,(%rbx)
  80416055cf:	48 89 5b 08          	mov    %rbx,0x8(%rbx)
    memset(new, 0, sizeof *new);
  80416055d3:	ba 40 00 00 00       	mov    $0x40,%edx
  80416055d8:	be 00 00 00 00       	mov    $0x0,%esi
  80416055dd:	48 89 df             	mov    %rbx,%rdi
  80416055e0:	48 b8 5e 93 60 41 80 	movabs $0x804160935e,%rax
  80416055e7:	00 00 00 
  80416055ea:	ff d0                	call   *%rax
    list->next = list->prev = list;
  80416055ec:	48 89 1b             	mov    %rbx,(%rbx)
  80416055ef:	48 89 5b 08          	mov    %rbx,0x8(%rbx)
    new->state = state;
  80416055f3:	44 89 73 28          	mov    %r14d,0x28(%rbx)
    free_desc_count--;
  80416055f7:	48 b8 98 40 e0 41 80 	movabs $0x8041e04098,%rax
  80416055fe:	00 00 00 
  8041605601:	48 83 28 01          	subq   $0x1,(%rax)
    new->parent = parent;
  8041605605:	4c 89 63 20          	mov    %r12,0x20(%rbx)
    if(parent->refc == 0) {
  8041605609:	41 83 7c 24 30 00    	cmpl   $0x0,0x30(%r12)
  804160560f:	0f 95 c0             	setne  %al
  8041605612:	0f b6 c0             	movzbl %al,%eax
  8041605615:	89 43 30             	mov    %eax,0x30(%rbx)
    new->class = parent->class - 1;
  8041605618:	41 0f b7 44 24 34    	movzwl 0x34(%r12),%eax
  804160561e:	8d 88 ff 0f 00 00    	lea    0xfff(%rax),%ecx
  8041605624:	66 81 e1 ff 0f       	and    $0xfff,%cx
  8041605629:	0f b7 43 34          	movzwl 0x34(%rbx),%eax
  804160562d:	66 25 00 f0          	and    $0xf000,%ax
  8041605631:	09 c8                	or     %ecx,%eax
  8041605633:	66 89 43 34          	mov    %ax,0x34(%rbx)
    if(right) {
  8041605637:	45 84 ed             	test   %r13b,%r13b
  804160563a:	0f 84 88 00 00 00    	je     80416056c8 <alloc_child+0x158>
        new->addr = parent->addr + (CLASS_SIZE(new->class) >> CLASS_BASE);
  8041605640:	83 c1 0c             	add    $0xc,%ecx
  8041605643:	b8 01 00 00 00       	mov    $0x1,%eax
  8041605648:	48 d3 e0             	shl    %cl,%rax
  804160564b:	48 c1 e8 0c          	shr    $0xc,%rax
  804160564f:	48 ba ff ff ff ff ff 	movabs $0xfffffffffffff,%rdx
  8041605656:	ff 0f 00 
  8041605659:	49 23 54 24 38       	and    0x38(%r12),%rdx
  804160565e:	48 01 d0             	add    %rdx,%rax
  8041605661:	89 43 38             	mov    %eax,0x38(%rbx)
  8041605664:	48 89 c2             	mov    %rax,%rdx
  8041605667:	48 c1 ea 20          	shr    $0x20,%rdx
  804160566b:	66 89 53 3c          	mov    %dx,0x3c(%rbx)
  804160566f:	48 c1 e8 30          	shr    $0x30,%rax
  8041605673:	83 e0 0f             	and    $0xf,%eax
  8041605676:	0f b6 53 3e          	movzbl 0x3e(%rbx),%edx
  804160567a:	83 e2 f0             	and    $0xfffffff0,%edx
  804160567d:	09 d0                	or     %edx,%eax
  804160567f:	88 43 3e             	mov    %al,0x3e(%rbx)
        parent->right = new;
  8041605682:	49 89 5c 24 18       	mov    %rbx,0x18(%r12)
}
  8041605687:	48 89 d8             	mov    %rbx,%rax
  804160568a:	5b                   	pop    %rbx
  804160568b:	41 5c                	pop    %r12
  804160568d:	41 5d                	pop    %r13
  804160568f:	41 5e                	pop    %r14
  8041605691:	5d                   	pop    %rbp
  8041605692:	c3                   	ret    
    assert_physical(parent);
  8041605693:	48 b9 a8 af 60 41 80 	movabs $0x804160afa8,%rcx
  804160569a:	00 00 00 
  804160569d:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  80416056a4:	00 00 00 
  80416056a7:	be b3 00 00 00       	mov    $0xb3,%esi
  80416056ac:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  80416056b3:	00 00 00 
  80416056b6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416056bb:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  80416056c2:	00 00 00 
  80416056c5:	41 ff d0             	call   *%r8
        new->addr = parent->addr;
  80416056c8:	48 b8 ff ff ff ff ff 	movabs $0xfffffffffffff,%rax
  80416056cf:	ff 0f 00 
  80416056d2:	49 23 44 24 38       	and    0x38(%r12),%rax
  80416056d7:	89 43 38             	mov    %eax,0x38(%rbx)
  80416056da:	48 89 c2             	mov    %rax,%rdx
  80416056dd:	48 c1 ea 20          	shr    $0x20,%rdx
  80416056e1:	66 89 53 3c          	mov    %dx,0x3c(%rbx)
  80416056e5:	48 c1 e8 30          	shr    $0x30,%rax
  80416056e9:	0f b6 53 3e          	movzbl 0x3e(%rbx),%edx
  80416056ed:	83 e2 f0             	and    $0xfffffff0,%edx
  80416056f0:	09 d0                	or     %edx,%eax
  80416056f2:	88 43 3e             	mov    %al,0x3e(%rbx)
        parent->left = new;
  80416056f5:	49 89 5c 24 10       	mov    %rbx,0x10(%r12)
    return new;
  80416056fa:	eb 8b                	jmp    8041605687 <alloc_child+0x117>

00000080416056fc <page_lookup>:
page_lookup(struct Page *hint, uintptr_t addr, int class, enum PageState type, bool alloc) {
  80416056fc:	f3 0f 1e fa          	endbr64 
  8041605700:	55                   	push   %rbp
  8041605701:	48 89 e5             	mov    %rsp,%rbp
  8041605704:	41 57                	push   %r15
  8041605706:	41 56                	push   %r14
  8041605708:	41 55                	push   %r13
  804160570a:	41 54                	push   %r12
  804160570c:	53                   	push   %rbx
  804160570d:	48 83 ec 28          	sub    $0x28,%rsp
  8041605711:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
  8041605715:	89 4d c4             	mov    %ecx,-0x3c(%rbp)
  8041605718:	44 89 45 bc          	mov    %r8d,-0x44(%rbp)
    assert(class >= 0);
  804160571c:	85 d2                	test   %edx,%edx
  804160571e:	78 43                	js     8041605763 <page_lookup+0x67>
  8041605720:	48 89 fb             	mov    %rdi,%rbx
  8041605723:	41 89 d5             	mov    %edx,%r13d
  8041605726:	45 89 c7             	mov    %r8d,%r15d
    if (hint) assert_physical(hint);
  8041605729:	48 85 ff             	test   %rdi,%rdi
  804160572c:	0f 84 a0 03 00 00    	je     8041605ad2 <page_lookup+0x3d6>
  8041605732:	8b 47 28             	mov    0x28(%rdi),%eax
  8041605735:	25 00 00 f0 00       	and    $0xf00000,%eax
  804160573a:	3d ff ff 2f 00       	cmp    $0x2fffff,%eax
  804160573f:	76 57                	jbe    8041605798 <page_lookup+0x9c>
    assert(!(addr & CLASS_MASK(class)));
  8041605741:	41 8d 4d 0c          	lea    0xc(%r13),%ecx
  8041605745:	48 c7 c0 ff ff ff ff 	mov    $0xffffffffffffffff,%rax
  804160574c:	48 d3 e0             	shl    %cl,%rax
  804160574f:	48 f7 d0             	not    %rax
  8041605752:	48 85 45 c8          	test   %rax,-0x38(%rbp)
  8041605756:	75 75                	jne    80416057cd <page_lookup+0xd1>
        bool right = addr & CLASS_SIZE(node->class - 1);
  8041605758:	41 be 01 00 00 00    	mov    $0x1,%r14d
  804160575e:	e9 47 02 00 00       	jmp    80416059aa <page_lookup+0x2ae>
    assert(class >= 0);
  8041605763:	48 b9 cf ab 60 41 80 	movabs $0x804160abcf,%rcx
  804160576a:	00 00 00 
  804160576d:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041605774:	00 00 00 
  8041605777:	be d2 00 00 00       	mov    $0xd2,%esi
  804160577c:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041605783:	00 00 00 
  8041605786:	b8 00 00 00 00       	mov    $0x0,%eax
  804160578b:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041605792:	00 00 00 
  8041605795:	41 ff d0             	call   *%r8
    if (hint) assert_physical(hint);
  8041605798:	48 b9 e0 af 60 41 80 	movabs $0x804160afe0,%rcx
  804160579f:	00 00 00 
  80416057a2:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  80416057a9:	00 00 00 
  80416057ac:	be d3 00 00 00       	mov    $0xd3,%esi
  80416057b1:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  80416057b8:	00 00 00 
  80416057bb:	b8 00 00 00 00       	mov    $0x0,%eax
  80416057c0:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  80416057c7:	00 00 00 
  80416057ca:	41 ff d0             	call   *%r8
    assert(!(addr & CLASS_MASK(class)));
  80416057cd:	48 b9 da ab 60 41 80 	movabs $0x804160abda,%rcx
  80416057d4:	00 00 00 
  80416057d7:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  80416057de:	00 00 00 
  80416057e1:	be d6 00 00 00       	mov    $0xd6,%esi
  80416057e6:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  80416057ed:	00 00 00 
  80416057f0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416057f5:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  80416057fc:	00 00 00 
  80416057ff:	41 ff d0             	call   *%r8
            ensure_free_desc((node->class - class + 1) * 2);
  8041605802:	44 29 e8             	sub    %r13d,%eax
  8041605805:	8d 7c 00 02          	lea    0x2(%rax,%rax,1),%edi
  8041605809:	48 63 ff             	movslq %edi,%rdi
  804160580c:	48 b8 9f 50 60 41 80 	movabs $0x804160509f,%rax
  8041605813:	00 00 00 
  8041605816:	ff d0                	call   *%rax
            bool was_free = node->state == ALLOCATABLE_NODE && PAGE_IS_FREE(node);
  8041605818:	81 7b 28 00 00 40 00 	cmpl   $0x400000,0x28(%rbx)
  804160581f:	74 51                	je     8041605872 <page_lookup+0x176>
            if (!node->left) alloc_child(node, 0);
  8041605821:	48 83 7b 10 00       	cmpq   $0x0,0x10(%rbx)
  8041605826:	74 62                	je     804160588a <page_lookup+0x18e>
            if (!node->right) alloc_child(node, 1);
  8041605828:	48 83 7b 18 00       	cmpq   $0x0,0x18(%rbx)
  804160582d:	0f 84 e1 00 00 00    	je     8041605914 <page_lookup+0x218>
            if (type != PARTIAL_NODE && node->state != type)
  8041605833:	8b 45 c4             	mov    -0x3c(%rbp),%eax
  8041605836:	3d 00 00 30 00       	cmp    $0x300000,%eax
  804160583b:	74 0c                	je     8041605849 <page_lookup+0x14d>
  804160583d:	39 43 28             	cmp    %eax,0x28(%rbx)
  8041605840:	74 07                	je     8041605849 <page_lookup+0x14d>
                node->state = PARTIAL_NODE;
  8041605842:	c7 43 28 00 00 30 00 	movl   $0x300000,0x28(%rbx)
        assert((node->left && node->right) || !alloc);
  8041605849:	48 8b 43 10          	mov    0x10(%rbx),%rax
  804160584d:	48 85 c0             	test   %rax,%rax
  8041605850:	0f 84 16 01 00 00    	je     804160596c <page_lookup+0x270>
  8041605856:	48 83 7b 18 00       	cmpq   $0x0,0x18(%rbx)
  804160585b:	0f 84 0b 01 00 00    	je     804160596c <page_lookup+0x270>
        node = right ? node->right : node->left;
  8041605861:	4d 85 e4             	test   %r12,%r12
  8041605864:	0f 85 37 01 00 00    	jne    80416059a1 <page_lookup+0x2a5>
  804160586a:	48 89 c3             	mov    %rax,%rbx
  804160586d:	e9 38 01 00 00       	jmp    80416059aa <page_lookup+0x2ae>
            bool was_free = node->state == ALLOCATABLE_NODE && PAGE_IS_FREE(node);
  8041605872:	83 7b 30 00          	cmpl   $0x0,0x30(%rbx)
  8041605876:	75 a9                	jne    8041605821 <page_lookup+0x125>
  8041605878:	48 83 7b 10 00       	cmpq   $0x0,0x10(%rbx)
  804160587d:	75 a9                	jne    8041605828 <page_lookup+0x12c>
  804160587f:	48 83 7b 18 00       	cmpq   $0x0,0x18(%rbx)
  8041605884:	0f 94 45 c3          	sete   -0x3d(%rbp)
  8041605888:	eb 04                	jmp    804160588e <page_lookup+0x192>
  804160588a:	c6 45 c3 00          	movb   $0x0,-0x3d(%rbp)
            if (!node->left) alloc_child(node, 0);
  804160588e:	be 00 00 00 00       	mov    $0x0,%esi
  8041605893:	48 89 df             	mov    %rbx,%rdi
  8041605896:	48 b8 70 55 60 41 80 	movabs $0x8041605570,%rax
  804160589d:	00 00 00 
  80416058a0:	ff d0                	call   *%rax
            if (!node->right) alloc_child(node, 1);
  80416058a2:	48 83 7b 18 00       	cmpq   $0x0,0x18(%rbx)
  80416058a7:	74 6f                	je     8041605918 <page_lookup+0x21c>
            if (was_free) {
  80416058a9:	80 7d c3 00          	cmpb   $0x0,-0x3d(%rbp)
  80416058ad:	74 84                	je     8041605833 <page_lookup+0x137>
                struct Page *other = !right ? node->right : node->left;
  80416058af:	4d 85 e4             	test   %r12,%r12
  80416058b2:	75 7d                	jne    8041605931 <page_lookup+0x235>
  80416058b4:	48 8b 53 18          	mov    0x18(%rbx),%rdx
                assert(other->state == ALLOCATABLE_NODE);
  80416058b8:	81 7a 28 00 00 40 00 	cmpl   $0x400000,0x28(%rdx)
  80416058bf:	75 76                	jne    8041605937 <page_lookup+0x23b>
    list->next->prev = list->prev;
  80416058c1:	48 8b 4b 08          	mov    0x8(%rbx),%rcx
  80416058c5:	48 8b 03             	mov    (%rbx),%rax
  80416058c8:	48 89 01             	mov    %rax,(%rcx)
    list->prev->next = list->next;
  80416058cb:	48 8b 4b 08          	mov    0x8(%rbx),%rcx
  80416058cf:	48 89 48 08          	mov    %rcx,0x8(%rax)
    list->next = list->prev = list;
  80416058d3:	48 89 1b             	mov    %rbx,(%rbx)
  80416058d6:	48 89 5b 08          	mov    %rbx,0x8(%rbx)
                list_append(&free_classes[node->class - 1], (struct List *)other);
  80416058da:	0f b7 43 34          	movzwl 0x34(%rbx),%eax
  80416058de:	25 ff 0f 00 00       	and    $0xfff,%eax
  80416058e3:	83 e8 01             	sub    $0x1,%eax
    new->next = list->next;
  80416058e6:	48 98                	cltq   
  80416058e8:	48 c1 e0 04          	shl    $0x4,%rax
  80416058ec:	48 be c0 40 e0 41 80 	movabs $0x8041e040c0,%rsi
  80416058f3:	00 00 00 
  80416058f6:	48 01 f0             	add    %rsi,%rax
  80416058f9:	48 8b 48 08          	mov    0x8(%rax),%rcx
  80416058fd:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
                list_append(&free_classes[node->class - 1], (struct List *)other);
  8041605901:	48 89 02             	mov    %rax,(%rdx)
    list->next->prev = new;
  8041605904:	48 8b 48 08          	mov    0x8(%rax),%rcx
  8041605908:	48 89 11             	mov    %rdx,(%rcx)
    list->next = new;
  804160590b:	48 89 50 08          	mov    %rdx,0x8(%rax)
}
  804160590f:	e9 1f ff ff ff       	jmp    8041605833 <page_lookup+0x137>
            if (!node->right) alloc_child(node, 1);
  8041605914:	c6 45 c3 00          	movb   $0x0,-0x3d(%rbp)
  8041605918:	be 01 00 00 00       	mov    $0x1,%esi
  804160591d:	48 89 df             	mov    %rbx,%rdi
  8041605920:	48 b8 70 55 60 41 80 	movabs $0x8041605570,%rax
  8041605927:	00 00 00 
  804160592a:	ff d0                	call   *%rax
  804160592c:	e9 78 ff ff ff       	jmp    80416058a9 <page_lookup+0x1ad>
                struct Page *other = !right ? node->right : node->left;
  8041605931:	48 8b 53 10          	mov    0x10(%rbx),%rdx
  8041605935:	eb 81                	jmp    80416058b8 <page_lookup+0x1bc>
                assert(other->state == ALLOCATABLE_NODE);
  8041605937:	48 b9 18 b0 60 41 80 	movabs $0x804160b018,%rcx
  804160593e:	00 00 00 
  8041605941:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041605948:	00 00 00 
  804160594b:	be e6 00 00 00       	mov    $0xe6,%esi
  8041605950:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041605957:	00 00 00 
  804160595a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160595f:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041605966:	00 00 00 
  8041605969:	41 ff d0             	call   *%r8
        assert((node->left && node->right) || !alloc);
  804160596c:	48 b9 40 b0 60 41 80 	movabs $0x804160b040,%rcx
  8041605973:	00 00 00 
  8041605976:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  804160597d:	00 00 00 
  8041605980:	be ef 00 00 00       	mov    $0xef,%esi
  8041605985:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  804160598c:	00 00 00 
  804160598f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605994:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  804160599b:	00 00 00 
  804160599e:	41 ff d0             	call   *%r8
        node = right ? node->right : node->left;
  80416059a1:	48 8b 5b 18          	mov    0x18(%rbx),%rbx
    while (node && node->class > class) {
  80416059a5:	48 85 db             	test   %rbx,%rbx
  80416059a8:	74 46                	je     80416059f0 <page_lookup+0x2f4>
  80416059aa:	0f b7 43 34          	movzwl 0x34(%rbx),%eax
  80416059ae:	25 ff 0f 00 00       	and    $0xfff,%eax
  80416059b3:	44 39 e8             	cmp    %r13d,%eax
  80416059b6:	0f 8e 25 01 00 00    	jle    8041605ae1 <page_lookup+0x3e5>
        bool right = addr & CLASS_SIZE(node->class - 1);
  80416059bc:	8d 48 0b             	lea    0xb(%rax),%ecx
  80416059bf:	4d 89 f4             	mov    %r14,%r12
  80416059c2:	49 d3 e4             	shl    %cl,%r12
  80416059c5:	4c 23 65 c8          	and    -0x38(%rbp),%r12
        if (alloc) {
  80416059c9:	45 84 ff             	test   %r15b,%r15b
  80416059cc:	0f 85 30 fe ff ff    	jne    8041605802 <page_lookup+0x106>
        assert((node->left && node->right) || !alloc);
  80416059d2:	48 8b 43 10          	mov    0x10(%rbx),%rax
  80416059d6:	48 85 c0             	test   %rax,%rax
  80416059d9:	74 0b                	je     80416059e6 <page_lookup+0x2ea>
  80416059db:	48 83 7b 18 00       	cmpq   $0x0,0x18(%rbx)
  80416059e0:	0f 85 7b fe ff ff    	jne    8041605861 <page_lookup+0x165>
        node = right ? node->right : node->left;
  80416059e6:	4d 85 e4             	test   %r12,%r12
  80416059e9:	75 b6                	jne    80416059a1 <page_lookup+0x2a5>
  80416059eb:	48 89 c3             	mov    %rax,%rbx
  80416059ee:	eb b5                	jmp    80416059a5 <page_lookup+0x2a9>
    if (alloc) assert(node);
  80416059f0:	80 7d bc 00          	cmpb   $0x0,-0x44(%rbp)
  80416059f4:	0f 84 99 01 00 00    	je     8041605b93 <page_lookup+0x497>
  80416059fa:	48 b9 f6 ab 60 41 80 	movabs $0x804160abf6,%rcx
  8041605a01:	00 00 00 
  8041605a04:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041605a0b:	00 00 00 
  8041605a0e:	be f4 00 00 00       	mov    $0xf4,%esi
  8041605a13:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041605a1a:	00 00 00 
  8041605a1d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605a22:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041605a29:	00 00 00 
  8041605a2c:	41 ff d0             	call   *%r8
        assert(!node->refc);
  8041605a2f:	48 b9 fb ab 60 41 80 	movabs $0x804160abfb,%rcx
  8041605a36:	00 00 00 
  8041605a39:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041605a40:	00 00 00 
  8041605a43:	be f7 00 00 00       	mov    $0xf7,%esi
  8041605a48:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041605a4f:	00 00 00 
  8041605a52:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605a57:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041605a5e:	00 00 00 
  8041605a61:	41 ff d0             	call   *%r8
        if (node->state == ALLOCATABLE_NODE) list_append(&free_classes[node->class], (struct List *)node);
  8041605a64:	0f b7 43 34          	movzwl 0x34(%rbx),%eax
    new->next = list->next;
  8041605a68:	48 b9 c0 40 e0 41 80 	movabs $0x8041e040c0,%rcx
  8041605a6f:	00 00 00 
  8041605a72:	48 89 c2             	mov    %rax,%rdx
  8041605a75:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  8041605a7b:	48 c1 e2 04          	shl    $0x4,%rdx
  8041605a7f:	48 01 ca             	add    %rcx,%rdx
  8041605a82:	48 8b 72 08          	mov    0x8(%rdx),%rsi
  8041605a86:	48 89 73 08          	mov    %rsi,0x8(%rbx)
        if (node->state == ALLOCATABLE_NODE) list_append(&free_classes[node->class], (struct List *)node);
  8041605a8a:	48 89 13             	mov    %rdx,(%rbx)
    list->next->prev = new;
  8041605a8d:	48 8b 42 08          	mov    0x8(%rdx),%rax
  8041605a91:	48 89 18             	mov    %rbx,(%rax)
    list->next = new;
  8041605a94:	48 89 5a 08          	mov    %rbx,0x8(%rdx)
}
  8041605a98:	e9 b8 00 00 00       	jmp    8041605b55 <page_lookup+0x459>
    if (node) assert(!(page2pa(node) & CLASS_MASK(node->class)));
  8041605a9d:	48 b9 68 b0 60 41 80 	movabs $0x804160b068,%rcx
  8041605aa4:	00 00 00 
  8041605aa7:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041605aae:	00 00 00 
  8041605ab1:	be 06 01 00 00       	mov    $0x106,%esi
  8041605ab6:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041605abd:	00 00 00 
  8041605ac0:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605ac5:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041605acc:	00 00 00 
  8041605acf:	41 ff d0             	call   *%r8
    struct Page *node = hint ? hint : &root;
  8041605ad2:	48 bb 00 00 e0 41 80 	movabs $0x8041e00000,%rbx
  8041605ad9:	00 00 00 
  8041605adc:	e9 60 fc ff ff       	jmp    8041605741 <page_lookup+0x45>
    if (alloc && type != PARTIAL_NODE) /* Attach new memory */ {
  8041605ae1:	81 7d c4 00 00 30 00 	cmpl   $0x300000,-0x3c(%rbp)
  8041605ae8:	74 6b                	je     8041605b55 <page_lookup+0x459>
  8041605aea:	80 7d bc 00          	cmpb   $0x0,-0x44(%rbp)
  8041605aee:	74 65                	je     8041605b55 <page_lookup+0x459>
        assert(!node->refc);
  8041605af0:	83 7b 30 00          	cmpl   $0x0,0x30(%rbx)
  8041605af4:	0f 85 35 ff ff ff    	jne    8041605a2f <page_lookup+0x333>
        free_desc_rec(node->left);
  8041605afa:	48 8b 7b 10          	mov    0x10(%rbx),%rdi
  8041605afe:	49 bc a7 49 60 41 80 	movabs $0x80416049a7,%r12
  8041605b05:	00 00 00 
  8041605b08:	41 ff d4             	call   *%r12
        free_desc_rec(node->right);
  8041605b0b:	48 8b 7b 18          	mov    0x18(%rbx),%rdi
  8041605b0f:	41 ff d4             	call   *%r12
        node->left = node->right = NULL;
  8041605b12:	48 c7 43 18 00 00 00 	movq   $0x0,0x18(%rbx)
  8041605b19:	00 
  8041605b1a:	48 c7 43 10 00 00 00 	movq   $0x0,0x10(%rbx)
  8041605b21:	00 
    list->next->prev = list->prev;
  8041605b22:	48 8b 53 08          	mov    0x8(%rbx),%rdx
  8041605b26:	48 8b 03             	mov    (%rbx),%rax
  8041605b29:	48 89 02             	mov    %rax,(%rdx)
    list->prev->next = list->next;
  8041605b2c:	48 8b 53 08          	mov    0x8(%rbx),%rdx
  8041605b30:	48 89 50 08          	mov    %rdx,0x8(%rax)
    list->next = list->prev = list;
  8041605b34:	48 89 1b             	mov    %rbx,(%rbx)
  8041605b37:	48 89 5b 08          	mov    %rbx,0x8(%rbx)
        if (type != PARTIAL_NODE && node->state != RESERVED_NODE) node->state = type;
  8041605b3b:	81 7b 28 00 00 50 00 	cmpl   $0x500000,0x28(%rbx)
  8041605b42:	74 11                	je     8041605b55 <page_lookup+0x459>
  8041605b44:	8b 45 c4             	mov    -0x3c(%rbp),%eax
  8041605b47:	89 43 28             	mov    %eax,0x28(%rbx)
        if (node->state == ALLOCATABLE_NODE) list_append(&free_classes[node->class], (struct List *)node);
  8041605b4a:	3d 00 00 40 00       	cmp    $0x400000,%eax
  8041605b4f:	0f 84 0f ff ff ff    	je     8041605a64 <page_lookup+0x368>
    if (node) assert(!(page2pa(node) & CLASS_MASK(node->class)));
  8041605b55:	0f b7 4b 34          	movzwl 0x34(%rbx),%ecx
  8041605b59:	81 e1 ff 0f 00 00    	and    $0xfff,%ecx
  8041605b5f:	83 c1 0c             	add    $0xc,%ecx
  8041605b62:	48 c7 c0 ff ff ff ff 	mov    $0xffffffffffffffff,%rax
  8041605b69:	48 d3 e0             	shl    %cl,%rax
  8041605b6c:	48 f7 d0             	not    %rax
  8041605b6f:	48 89 c2             	mov    %rax,%rdx
    return page->addr << CLASS_BASE;
  8041605b72:	48 b9 ff ff ff ff ff 	movabs $0xfffffffffffff,%rcx
  8041605b79:	ff 0f 00 
  8041605b7c:	48 89 c8             	mov    %rcx,%rax
  8041605b7f:	48 23 43 38          	and    0x38(%rbx),%rax
  8041605b83:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605b87:	48 21 c8             	and    %rcx,%rax
  8041605b8a:	48 85 c2             	test   %rax,%rdx
  8041605b8d:	0f 85 0a ff ff ff    	jne    8041605a9d <page_lookup+0x3a1>
}
  8041605b93:	48 89 d8             	mov    %rbx,%rax
  8041605b96:	48 83 c4 28          	add    $0x28,%rsp
  8041605b9a:	5b                   	pop    %rbx
  8041605b9b:	41 5c                	pop    %r12
  8041605b9d:	41 5d                	pop    %r13
  8041605b9f:	41 5e                	pop    %r14
  8041605ba1:	41 5f                	pop    %r15
  8041605ba3:	5d                   	pop    %rbp
  8041605ba4:	c3                   	ret    

0000008041605ba5 <attach_region>:
attach_region(uintptr_t start, uintptr_t end, enum PageState type) {
  8041605ba5:	f3 0f 1e fa          	endbr64 
  8041605ba9:	55                   	push   %rbp
  8041605baa:	48 89 e5             	mov    %rsp,%rbp
  8041605bad:	41 57                	push   %r15
  8041605baf:	41 56                	push   %r14
  8041605bb1:	41 55                	push   %r13
  8041605bb3:	41 54                	push   %r12
  8041605bb5:	53                   	push   %rbx
  8041605bb6:	48 83 ec 18          	sub    $0x18,%rsp
  8041605bba:	89 55 cc             	mov    %edx,-0x34(%rbp)
    start = ROUNDDOWN(start, CLASS_SIZE(0));
  8041605bbd:	48 81 e7 00 f0 ff ff 	and    $0xfffffffffffff000,%rdi
  8041605bc4:	49 89 fc             	mov    %rdi,%r12
    end = ROUNDUP(end, CLASS_SIZE(0));
  8041605bc7:	4c 8d b6 ff 0f 00 00 	lea    0xfff(%rsi),%r14
  8041605bce:	49 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%r14
        while (class <= MAX_CLASS && (CLASS_MASK(class) & start) == 0)
  8041605bd5:	49 c7 c5 ff ff ff ff 	mov    $0xffffffffffffffff,%r13
        while(class && ((CLASS_MASK(class) & start) != 0 || (start + CLASS_SIZE(class) > end)))
  8041605bdc:	41 bf 01 00 00 00    	mov    $0x1,%r15d
    while (start < end){
  8041605be2:	49 39 fe             	cmp    %rdi,%r14
  8041605be5:	77 63                	ja     8041605c4a <attach_region+0xa5>
}
  8041605be7:	48 83 c4 18          	add    $0x18,%rsp
  8041605beb:	5b                   	pop    %rbx
  8041605bec:	41 5c                	pop    %r12
  8041605bee:	41 5d                	pop    %r13
  8041605bf0:	41 5e                	pop    %r14
  8041605bf2:	41 5f                	pop    %r15
  8041605bf4:	5d                   	pop    %rbp
  8041605bf5:	c3                   	ret    
        while(class && ((CLASS_MASK(class) & start) != 0 || (start + CLASS_SIZE(class) > end)))
  8041605bf6:	83 eb 01             	sub    $0x1,%ebx
  8041605bf9:	74 1f                	je     8041605c1a <attach_region+0x75>
  8041605bfb:	8d 4b 0c             	lea    0xc(%rbx),%ecx
  8041605bfe:	4c 89 e8             	mov    %r13,%rax
  8041605c01:	48 d3 e0             	shl    %cl,%rax
  8041605c04:	48 f7 d0             	not    %rax
  8041605c07:	4c 85 e0             	test   %r12,%rax
  8041605c0a:	75 ea                	jne    8041605bf6 <attach_region+0x51>
  8041605c0c:	4c 89 f8             	mov    %r15,%rax
  8041605c0f:	48 d3 e0             	shl    %cl,%rax
  8041605c12:	4c 01 e0             	add    %r12,%rax
  8041605c15:	4c 39 f0             	cmp    %r14,%rax
  8041605c18:	77 dc                	ja     8041605bf6 <attach_region+0x51>
        page_lookup(NULL, start, class, type, 1);
  8041605c1a:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  8041605c20:	8b 4d cc             	mov    -0x34(%rbp),%ecx
  8041605c23:	89 da                	mov    %ebx,%edx
  8041605c25:	4c 89 e6             	mov    %r12,%rsi
  8041605c28:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605c2d:	48 b8 fc 56 60 41 80 	movabs $0x80416056fc,%rax
  8041605c34:	00 00 00 
  8041605c37:	ff d0                	call   *%rax
        start += CLASS_SIZE(class);
  8041605c39:	8d 4b 0c             	lea    0xc(%rbx),%ecx
  8041605c3c:	4c 89 f8             	mov    %r15,%rax
  8041605c3f:	48 d3 e0             	shl    %cl,%rax
  8041605c42:	49 01 c4             	add    %rax,%r12
    while (start < end){
  8041605c45:	4d 39 e6             	cmp    %r12,%r14
  8041605c48:	76 9d                	jbe    8041605be7 <attach_region+0x42>
            class++;
  8041605c4a:	bb 01 00 00 00       	mov    $0x1,%ebx
        while (class <= MAX_CLASS && (CLASS_MASK(class) & start) == 0)
  8041605c4f:	41 f7 c4 ff 0f 00 00 	test   $0xfff,%r12d
  8041605c56:	75 21                	jne    8041605c79 <attach_region+0xd4>
  8041605c58:	8d 4b 0c             	lea    0xc(%rbx),%ecx
  8041605c5b:	4c 89 e8             	mov    %r13,%rax
  8041605c5e:	48 d3 e0             	shl    %cl,%rax
  8041605c61:	48 f7 d0             	not    %rax
  8041605c64:	4c 85 e0             	test   %r12,%rax
  8041605c67:	75 0a                	jne    8041605c73 <attach_region+0xce>
            class++;
  8041605c69:	83 c3 01             	add    $0x1,%ebx
        while (class <= MAX_CLASS && (CLASS_MASK(class) & start) == 0)
  8041605c6c:	83 fb 31             	cmp    $0x31,%ebx
  8041605c6f:	75 e7                	jne    8041605c58 <attach_region+0xb3>
  8041605c71:	eb 88                	jmp    8041605bfb <attach_region+0x56>
        while(class && ((CLASS_MASK(class) & start) != 0 || (start + CLASS_SIZE(class) > end)))
  8041605c73:	85 db                	test   %ebx,%ebx
  8041605c75:	75 84                	jne    8041605bfb <attach_region+0x56>
  8041605c77:	eb a1                	jmp    8041605c1a <attach_region+0x75>
        while (class <= MAX_CLASS && (CLASS_MASK(class) & start) == 0)
  8041605c79:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041605c7e:	eb 9a                	jmp    8041605c1a <attach_region+0x75>

0000008041605c80 <dump_virtual_tree>:
dump_virtual_tree(struct Page *node, int class) {
  8041605c80:	f3 0f 1e fa          	endbr64 
}
  8041605c84:	c3                   	ret    

0000008041605c85 <dump_memory_lists>:
dump_memory_lists(void) {
  8041605c85:	f3 0f 1e fa          	endbr64 
  8041605c89:	55                   	push   %rbp
  8041605c8a:	48 89 e5             	mov    %rsp,%rbp
  8041605c8d:	41 57                	push   %r15
  8041605c8f:	41 56                	push   %r14
  8041605c91:	41 55                	push   %r13
  8041605c93:	41 54                	push   %r12
  8041605c95:	53                   	push   %rbx
  8041605c96:	48 83 ec 18          	sub    $0x18,%rsp
    for (int class = 0; class < MAX_CLASS; ++class) {
  8041605c9a:	48 b8 c0 40 e0 41 80 	movabs $0x8041e040c0,%rax
  8041605ca1:	00 00 00 
  8041605ca4:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041605ca8:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%rbp)
        cprintf("Class[%d] size(%0llx) {", class, CLASS_SIZE(class));
  8041605caf:	49 bd b7 6f 60 41 80 	movabs $0x8041606fb7,%r13
  8041605cb6:	00 00 00 
  8041605cb9:	8b 75 cc             	mov    -0x34(%rbp),%esi
  8041605cbc:	8d 4e 0c             	lea    0xc(%rsi),%ecx
  8041605cbf:	ba 01 00 00 00       	mov    $0x1,%edx
  8041605cc4:	48 d3 e2             	shl    %cl,%rdx
  8041605cc7:	48 bf 07 ac 60 41 80 	movabs $0x804160ac07,%rdi
  8041605cce:	00 00 00 
  8041605cd1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605cd6:	41 ff d5             	call   *%r13
        for (struct List *cur_node = list->next; cur_node != list; cur_node = cur_node->next, ++i) {
  8041605cd9:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8041605cdd:	49 89 c6             	mov    %rax,%r14
  8041605ce0:	4c 8b 60 08          	mov    0x8(%rax),%r12
  8041605ce4:	49 39 c4             	cmp    %rax,%r12
  8041605ce7:	0f 84 aa 00 00 00    	je     8041605d97 <dump_memory_lists+0x112>
        int i = 0;
  8041605ced:	bb 00 00 00 00       	mov    $0x0,%ebx
            cprintf("0x%08zx ", (uintptr_t) page->addr << CLASS_BASE);
  8041605cf2:	49 bf ff ff ff ff ff 	movabs $0xfffffffffffff,%r15
  8041605cf9:	ff 0f 00 
  8041605cfc:	eb 2b                	jmp    8041605d29 <dump_memory_lists+0xa4>
  8041605cfe:	4c 89 fe             	mov    %r15,%rsi
  8041605d01:	49 23 74 24 38       	and    0x38(%r12),%rsi
  8041605d06:	48 c1 e6 0c          	shl    $0xc,%rsi
  8041605d0a:	48 bf 25 ac 60 41 80 	movabs $0x804160ac25,%rdi
  8041605d11:	00 00 00 
  8041605d14:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605d19:	41 ff d5             	call   *%r13
        for (struct List *cur_node = list->next; cur_node != list; cur_node = cur_node->next, ++i) {
  8041605d1c:	4d 8b 64 24 08       	mov    0x8(%r12),%r12
  8041605d21:	83 c3 01             	add    $0x1,%ebx
  8041605d24:	4d 39 f4             	cmp    %r14,%r12
  8041605d27:	74 32                	je     8041605d5b <dump_memory_lists+0xd6>
            if (i % SKIP == 0) {
  8041605d29:	48 63 c3             	movslq %ebx,%rax
  8041605d2c:	48 69 c0 67 66 66 66 	imul   $0x66666667,%rax,%rax
  8041605d33:	48 c1 f8 22          	sar    $0x22,%rax
  8041605d37:	89 da                	mov    %ebx,%edx
  8041605d39:	c1 fa 1f             	sar    $0x1f,%edx
  8041605d3c:	29 d0                	sub    %edx,%eax
  8041605d3e:	8d 04 80             	lea    (%rax,%rax,4),%eax
  8041605d41:	01 c0                	add    %eax,%eax
  8041605d43:	39 c3                	cmp    %eax,%ebx
  8041605d45:	75 b7                	jne    8041605cfe <dump_memory_lists+0x79>
                cprintf("\n    ");
  8041605d47:	48 bf 1f ac 60 41 80 	movabs $0x804160ac1f,%rdi
  8041605d4e:	00 00 00 
  8041605d51:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605d56:	41 ff d5             	call   *%r13
  8041605d59:	eb a3                	jmp    8041605cfe <dump_memory_lists+0x79>
        cprintf("\n}\n");
  8041605d5b:	48 bf 2e ac 60 41 80 	movabs $0x804160ac2e,%rdi
  8041605d62:	00 00 00 
  8041605d65:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605d6a:	41 ff d5             	call   *%r13
        if (i == 0) {
  8041605d6d:	85 db                	test   %ebx,%ebx
  8041605d6f:	75 0f                	jne    8041605d80 <dump_memory_lists+0xfb>
}
  8041605d71:	48 83 c4 18          	add    $0x18,%rsp
  8041605d75:	5b                   	pop    %rbx
  8041605d76:	41 5c                	pop    %r12
  8041605d78:	41 5d                	pop    %r13
  8041605d7a:	41 5e                	pop    %r14
  8041605d7c:	41 5f                	pop    %r15
  8041605d7e:	5d                   	pop    %rbp
  8041605d7f:	c3                   	ret    
    for (int class = 0; class < MAX_CLASS; ++class) {
  8041605d80:	83 45 cc 01          	addl   $0x1,-0x34(%rbp)
  8041605d84:	8b 45 cc             	mov    -0x34(%rbp),%eax
  8041605d87:	48 83 45 c0 10       	addq   $0x10,-0x40(%rbp)
  8041605d8c:	83 f8 30             	cmp    $0x30,%eax
  8041605d8f:	0f 85 24 ff ff ff    	jne    8041605cb9 <dump_memory_lists+0x34>
  8041605d95:	eb da                	jmp    8041605d71 <dump_memory_lists+0xec>
        cprintf("\n}\n");
  8041605d97:	48 bf 2e ac 60 41 80 	movabs $0x804160ac2e,%rdi
  8041605d9e:	00 00 00 
  8041605da1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605da6:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  8041605dad:	00 00 00 
  8041605db0:	ff d2                	call   *%rdx
        if (i == 0) {
  8041605db2:	eb bd                	jmp    8041605d71 <dump_memory_lists+0xec>

0000008041605db4 <dump_page_table>:
dump_page_table(pte_t *pml4) {
  8041605db4:	f3 0f 1e fa          	endbr64 
  8041605db8:	55                   	push   %rbp
  8041605db9:	48 89 e5             	mov    %rsp,%rbp
    cprintf("Page table:\n");
  8041605dbc:	48 bf 32 ac 60 41 80 	movabs $0x804160ac32,%rdi
  8041605dc3:	00 00 00 
  8041605dc6:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605dcb:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  8041605dd2:	00 00 00 
  8041605dd5:	ff d2                	call   *%rdx
}
  8041605dd7:	5d                   	pop    %rbp
  8041605dd8:	c3                   	ret    

0000008041605dd9 <init_memory>:
    root.class = MAX_CLASS;
    root.state = PARTIAL_NODE;
}

void
init_memory(void) {
  8041605dd9:	f3 0f 1e fa          	endbr64 
  8041605ddd:	55                   	push   %rbp
  8041605dde:	48 89 e5             	mov    %rsp,%rbp
  8041605de1:	41 57                	push   %r15
  8041605de3:	41 56                	push   %r14
  8041605de5:	41 55                	push   %r13
  8041605de7:	41 54                	push   %r12
  8041605de9:	53                   	push   %rbx
  8041605dea:	48 83 ec 08          	sub    $0x8,%rsp
    for (size_t i = 0; i < MAX_CLASS; i++)
  8041605dee:	48 b8 c0 40 e0 41 80 	movabs $0x8041e040c0,%rax
  8041605df5:	00 00 00 
  8041605df8:	48 8d 90 00 03 00 00 	lea    0x300(%rax),%rdx
    list->next = list->prev = list;
  8041605dff:	48 89 00             	mov    %rax,(%rax)
  8041605e02:	48 89 40 08          	mov    %rax,0x8(%rax)
    for (size_t i = 0; i < MAX_CLASS; i++)
  8041605e06:	48 83 c0 10          	add    $0x10,%rax
  8041605e0a:	48 39 d0             	cmp    %rdx,%rax
  8041605e0d:	75 f0                	jne    8041605dff <init_memory+0x26>
    list->next = list->prev = list;
  8041605e0f:	48 b8 a0 40 e0 41 80 	movabs $0x8041e040a0,%rax
  8041605e16:	00 00 00 
  8041605e19:	48 89 00             	mov    %rax,(%rax)
  8041605e1c:	48 89 40 08          	mov    %rax,0x8(%rax)
    free_desc_count = INIT_DESCR;
  8041605e20:	48 b8 98 40 e0 41 80 	movabs $0x8041e04098,%rax
  8041605e27:	00 00 00 
  8041605e2a:	48 c7 00 00 01 00 00 	movq   $0x100,(%rax)
    for (size_t i = 0; i < INIT_DESCR; i++)
  8041605e31:	48 b8 80 00 e0 41 80 	movabs $0x8041e00080,%rax
  8041605e38:	00 00 00 
  8041605e3b:	48 8d b0 00 40 00 00 	lea    0x4000(%rax),%rsi
    new->next = list->next;
  8041605e42:	48 ba a0 40 e0 41 80 	movabs $0x8041e040a0,%rdx
  8041605e49:	00 00 00 
  8041605e4c:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  8041605e50:	48 89 48 08          	mov    %rcx,0x8(%rax)
    new->prev = list;
  8041605e54:	48 89 10             	mov    %rdx,(%rax)
    list->next->prev = new;
  8041605e57:	48 89 01             	mov    %rax,(%rcx)
    list->next = new;
  8041605e5a:	48 89 42 08          	mov    %rax,0x8(%rdx)
    for (size_t i = 0; i < INIT_DESCR; i++)
  8041605e5e:	48 83 c0 40          	add    $0x40,%rax
  8041605e62:	48 39 f0             	cmp    %rsi,%rax
  8041605e65:	75 e5                	jne    8041605e4c <init_memory+0x73>
    list->next = list->prev = list;
  8041605e67:	48 b8 00 00 e0 41 80 	movabs $0x8041e00000,%rax
  8041605e6e:	00 00 00 
  8041605e71:	48 89 00             	mov    %rax,(%rax)
  8041605e74:	48 89 40 08          	mov    %rax,0x8(%rax)
    root.class = MAX_CLASS;
  8041605e78:	0f b7 50 34          	movzwl 0x34(%rax),%edx
  8041605e7c:	66 81 e2 00 f0       	and    $0xf000,%dx
  8041605e81:	83 ca 30             	or     $0x30,%edx
  8041605e84:	66 89 50 34          	mov    %dx,0x34(%rax)
    root.state = PARTIAL_NODE;
  8041605e88:	c7 40 28 00 00 30 00 	movl   $0x300000,0x28(%rax)

    init_allocator();
    if (trace_init) cprintf("Memory allocator is initiallized\n");
  8041605e8f:	48 bf 98 b0 60 41 80 	movabs $0x804160b098,%rdi
  8041605e96:	00 00 00 
  8041605e99:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605e9e:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  8041605ea5:	00 00 00 
  8041605ea8:	ff d2                	call   *%rdx
    attach_region((uintptr_t) 0, (uintptr_t) PAGE_SIZE, RESERVED_NODE);
  8041605eaa:	ba 00 00 50 00       	mov    $0x500000,%edx
  8041605eaf:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605eb4:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605eb9:	48 b8 a5 5b 60 41 80 	movabs $0x8041605ba5,%rax
  8041605ec0:	00 00 00 
  8041605ec3:	ff d0                	call   *%rax
    if ((uint64_t)kva < KERN_BASE_ADDR)
  8041605ec5:	48 b8 00 60 e4 41 80 	movabs $0x8041e46000,%rax
  8041605ecc:	00 00 00 
  8041605ecf:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  8041605ed6:	00 00 00 
  8041605ed9:	48 39 d0             	cmp    %rdx,%rax
  8041605edc:	76 77                	jbe    8041605f55 <init_memory+0x17c>
    return (physaddr_t)kva - KERN_BASE_ADDR;
  8041605ede:	48 ba 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rdx
  8041605ee5:	ff ff ff 
  8041605ee8:	48 8d 34 10          	lea    (%rax,%rdx,1),%rsi
    attach_region((uintptr_t) IOPHYSMEM, PADDR(end), RESERVED_NODE);
  8041605eec:	ba 00 00 50 00       	mov    $0x500000,%edx
  8041605ef1:	bf 00 00 0a 00       	mov    $0xa0000,%edi
  8041605ef6:	48 b8 a5 5b 60 41 80 	movabs $0x8041605ba5,%rax
  8041605efd:	00 00 00 
  8041605f00:	ff d0                	call   *%rax
    if (uefi_lp && uefi_lp->MemoryMap) {
  8041605f02:	48 a1 00 d0 62 41 80 	movabs 0x804162d000,%rax
  8041605f09:	00 00 00 
  8041605f0c:	48 85 c0             	test   %rax,%rax
  8041605f0f:	0f 84 ef 00 00 00    	je     8041606004 <init_memory+0x22b>
  8041605f15:	48 8b 50 28          	mov    0x28(%rax),%rdx
  8041605f19:	48 85 d2             	test   %rdx,%rdx
  8041605f1c:	0f 84 e2 00 00 00    	je     8041606004 <init_memory+0x22b>
        EFI_MEMORY_DESCRIPTOR *start = (void *)uefi_lp->MemoryMap;
  8041605f22:	48 89 d3             	mov    %rdx,%rbx
        EFI_MEMORY_DESCRIPTOR *end = (void *)(uefi_lp->MemoryMap + uefi_lp->MemoryMapSize);
  8041605f25:	49 89 d5             	mov    %rdx,%r13
  8041605f28:	4c 03 68 38          	add    0x38(%rax),%r13
        while (start < end) {
  8041605f2c:	4c 39 ea             	cmp    %r13,%rdx
  8041605f2f:	0f 83 b0 00 00 00    	jae    8041605fe5 <init_memory+0x20c>
            max_memory_map_addr = MAX(start->NumberOfPages * EFI_PAGE_SIZE + start->PhysicalStart, max_memory_map_addr);
  8041605f35:	49 bc 68 00 e0 41 80 	movabs $0x8041e00068,%r12
  8041605f3c:	00 00 00 
            attach_region(start->PhysicalStart, start->NumberOfPages * EFI_PAGE_SIZE + start->PhysicalStart, type);
  8041605f3f:	49 bf a5 5b 60 41 80 	movabs $0x8041605ba5,%r15
  8041605f46:	00 00 00 
            start = (void *)((uint8_t *)start + uefi_lp->MemoryMapDescriptorSize);
  8041605f49:	49 be 00 d0 62 41 80 	movabs $0x804162d000,%r14
  8041605f50:	00 00 00 
  8041605f53:	eb 64                	jmp    8041605fb9 <init_memory+0x1e0>
        _panic(file, line, "PADDR called with invalid kva %p", kva);
  8041605f55:	48 89 c1             	mov    %rax,%rcx
  8041605f58:	48 ba 10 af 60 41 80 	movabs $0x804160af10,%rdx
  8041605f5f:	00 00 00 
  8041605f62:	be 58 02 00 00       	mov    $0x258,%esi
  8041605f67:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041605f6e:	00 00 00 
  8041605f71:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605f76:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041605f7d:	00 00 00 
  8041605f80:	41 ff d0             	call   *%r8
            switch (start->Type) {
  8041605f83:	ba 00 00 50 00       	mov    $0x500000,%edx
  8041605f88:	85 c0                	test   %eax,%eax
  8041605f8a:	75 3e                	jne    8041605fca <init_memory+0x1f1>
            max_memory_map_addr = MAX(start->NumberOfPages * EFI_PAGE_SIZE + start->PhysicalStart, max_memory_map_addr);
  8041605f8c:	48 8b 7b 08          	mov    0x8(%rbx),%rdi
  8041605f90:	48 8b 73 18          	mov    0x18(%rbx),%rsi
  8041605f94:	48 c1 e6 0c          	shl    $0xc,%rsi
  8041605f98:	48 01 fe             	add    %rdi,%rsi
  8041605f9b:	49 8b 04 24          	mov    (%r12),%rax
  8041605f9f:	48 39 f0             	cmp    %rsi,%rax
  8041605fa2:	48 0f 42 c6          	cmovb  %rsi,%rax
  8041605fa6:	49 89 04 24          	mov    %rax,(%r12)
            attach_region(start->PhysicalStart, start->NumberOfPages * EFI_PAGE_SIZE + start->PhysicalStart, type);
  8041605faa:	41 ff d7             	call   *%r15
            start = (void *)((uint8_t *)start + uefi_lp->MemoryMapDescriptorSize);
  8041605fad:	49 8b 06             	mov    (%r14),%rax
  8041605fb0:	48 03 58 20          	add    0x20(%rax),%rbx
        while (start < end) {
  8041605fb4:	49 39 dd             	cmp    %rbx,%r13
  8041605fb7:	76 2c                	jbe    8041605fe5 <init_memory+0x20c>
            switch (start->Type) {
  8041605fb9:	8b 03                	mov    (%rbx),%eax
  8041605fbb:	83 f8 04             	cmp    $0x4,%eax
  8041605fbe:	76 c3                	jbe    8041605f83 <init_memory+0x1aa>
  8041605fc0:	ba 00 00 50 00       	mov    $0x500000,%edx
  8041605fc5:	83 f8 07             	cmp    $0x7,%eax
  8041605fc8:	75 c2                	jne    8041605f8c <init_memory+0x1b3>
                type = start->Attribute & EFI_MEMORY_WB ? ALLOCATABLE_NODE : RESERVED_NODE;
  8041605fca:	48 8b 43 20          	mov    0x20(%rbx),%rax
  8041605fce:	83 e0 08             	and    $0x8,%eax
  8041605fd1:	48 83 f8 01          	cmp    $0x1,%rax
  8041605fd5:	19 d2                	sbb    %edx,%edx
  8041605fd7:	81 e2 00 00 10 00    	and    $0x100000,%edx
  8041605fdd:	81 c2 00 00 40 00    	add    $0x400000,%edx
  8041605fe3:	eb a7                	jmp    8041605f8c <init_memory+0x1b3>
        basemem = MIN(max_memory_map_addr, IOPHYSMEM);
  8041605fe5:	48 a1 68 00 e0 41 80 	movabs 0x8041e00068,%rax
  8041605fec:	00 00 00 
  8041605fef:	41 bc 00 00 0a 00    	mov    $0xa0000,%r12d
  8041605ff5:	4c 39 e0             	cmp    %r12,%rax
  8041605ff8:	4c 0f 46 e0          	cmovbe %rax,%r12
        extmem = max_memory_map_addr - basemem;
  8041605ffc:	4c 29 e0             	sub    %r12,%rax
  8041605fff:	48 89 c3             	mov    %rax,%rbx
    if (uefi_lp && uefi_lp->MemoryMap) {
  8041606002:	eb 6a                	jmp    804160606e <init_memory+0x295>
        basemem = cmos_read16(CMOS_BASELO) * KB;
  8041606004:	bf 15 00 00 00       	mov    $0x15,%edi
  8041606009:	49 bd b2 6c 60 41 80 	movabs $0x8041606cb2,%r13
  8041606010:	00 00 00 
  8041606013:	41 ff d5             	call   *%r13
  8041606016:	44 0f b7 e0          	movzwl %ax,%r12d
  804160601a:	49 c1 e4 0a          	shl    $0xa,%r12
        extmem = cmos_read16(CMOS_EXTLO) * KB;
  804160601e:	bf 17 00 00 00       	mov    $0x17,%edi
  8041606023:	41 ff d5             	call   *%r13
  8041606026:	89 c3                	mov    %eax,%ebx
        size_t pextmem = (size_t)cmos_read16(CMOS_PEXTLO) * KB * 64;
  8041606028:	bf 34 00 00 00       	mov    $0x34,%edi
  804160602d:	41 ff d5             	call   *%r13
  8041606030:	0f b7 c0             	movzwl %ax,%eax
        if (pextmem) extmem = (16 * MB + pextmem - MB);
  8041606033:	48 c1 e0 10          	shl    $0x10,%rax
  8041606037:	0f 84 a3 01 00 00    	je     80416061e0 <init_memory+0x407>
  804160603d:	48 8d 98 00 00 f0 00 	lea    0xf00000(%rax),%rbx
        max_memory_map_addr = extmem ? EXTPHYSMEM + extmem : basemem;
  8041606044:	48 8d b3 00 00 10 00 	lea    0x100000(%rbx),%rsi
  804160604b:	48 89 f0             	mov    %rsi,%rax
  804160604e:	48 a3 68 00 e0 41 80 	movabs %rax,0x8041e00068
  8041606055:	00 00 00 
        attach_region(0, max_memory_map_addr, ALLOCATABLE_NODE);
  8041606058:	ba 00 00 40 00       	mov    $0x400000,%edx
  804160605d:	bf 00 00 00 00       	mov    $0x0,%edi
  8041606062:	48 b8 a5 5b 60 41 80 	movabs $0x8041605ba5,%rax
  8041606069:	00 00 00 
  804160606c:	ff d0                	call   *%rax
                (size_t)((basemem + extmem) / MB), (size_t)(basemem / KB), (size_t)(extmem / KB));
  804160606e:	48 89 d9             	mov    %rbx,%rcx
  8041606071:	48 c1 e9 0a          	shr    $0xa,%rcx
  8041606075:	4c 89 e2             	mov    %r12,%rdx
  8041606078:	48 c1 ea 0a          	shr    $0xa,%rdx
  804160607c:	4a 8d 34 23          	lea    (%rbx,%r12,1),%rsi
  8041606080:	48 c1 ee 14          	shr    $0x14,%rsi
        cprintf("Physical memory: %zuM available, base = %zuK, extended = %zuK\n",
  8041606084:	48 bf c0 b0 60 41 80 	movabs $0x804160b0c0,%rdi
  804160608b:	00 00 00 
  804160608e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606093:	49 b8 b7 6f 60 41 80 	movabs $0x8041606fb7,%r8
  804160609a:	00 00 00 
  804160609d:	41 ff d0             	call   *%r8
    check_physical_tree(&root);
  80416060a0:	48 bf 00 00 e0 41 80 	movabs $0x8041e00000,%rdi
  80416060a7:	00 00 00 
  80416060aa:	48 b8 71 4a 60 41 80 	movabs $0x8041604a71,%rax
  80416060b1:	00 00 00 
  80416060b4:	ff d0                	call   *%rax
    if ((uint64_t)kva < KERN_BASE_ADDR)
  80416060b6:	48 b8 00 00 a0 41 80 	movabs $0x8041a00000,%rax
  80416060bd:	00 00 00 
  80416060c0:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  80416060c7:	00 00 00 
  80416060ca:	48 39 d0             	cmp    %rdx,%rax
  80416060cd:	0f 86 22 01 00 00    	jbe    80416061f5 <init_memory+0x41c>
    return (physaddr_t)kva - KERN_BASE_ADDR;
  80416060d3:	48 ba 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rdx
  80416060da:	ff ff ff 
  80416060dd:	48 8d 34 10          	lea    (%rax,%rdx,1),%rsi
    one_page = page_lookup(NULL, PADDR(one_page_raw), MAX_ALLOCATION_CLASS, PARTIAL_NODE, 1);
  80416060e1:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  80416060e7:	b9 00 00 30 00       	mov    $0x300000,%ecx
  80416060ec:	ba 09 00 00 00       	mov    $0x9,%edx
  80416060f1:	bf 00 00 00 00       	mov    $0x0,%edi
  80416060f6:	48 b8 fc 56 60 41 80 	movabs $0x80416056fc,%rax
  80416060fd:	00 00 00 
  8041606100:	ff d0                	call   *%rax
  8041606102:	48 a3 88 40 e0 41 80 	movabs %rax,0x8041e04088
  8041606109:	00 00 00 
    page_ref(one_page);
  804160610c:	48 89 c7             	mov    %rax,%rdi
  804160610f:	48 b8 4e 49 60 41 80 	movabs $0x804160494e,%rax
  8041606116:	00 00 00 
  8041606119:	ff d0                	call   *%rax
    if ((uint64_t)kva < KERN_BASE_ADDR)
  804160611b:	48 b8 00 00 c0 41 80 	movabs $0x8041c00000,%rax
  8041606122:	00 00 00 
  8041606125:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  804160612c:	00 00 00 
  804160612f:	48 39 d0             	cmp    %rdx,%rax
  8041606132:	0f 86 eb 00 00 00    	jbe    8041606223 <init_memory+0x44a>
    return (physaddr_t)kva - KERN_BASE_ADDR;
  8041606138:	48 ba 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rdx
  804160613f:	ff ff ff 
  8041606142:	48 8d 34 10          	lea    (%rax,%rdx,1),%rsi
    zero_page = page_lookup(NULL, PADDR(zero_page_raw), MAX_ALLOCATION_CLASS, PARTIAL_NODE, 1);
  8041606146:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  804160614c:	b9 00 00 30 00       	mov    $0x300000,%ecx
  8041606151:	ba 09 00 00 00       	mov    $0x9,%edx
  8041606156:	bf 00 00 00 00       	mov    $0x0,%edi
  804160615b:	48 b8 fc 56 60 41 80 	movabs $0x80416056fc,%rax
  8041606162:	00 00 00 
  8041606165:	ff d0                	call   *%rax
  8041606167:	48 89 c3             	mov    %rax,%rbx
  804160616a:	48 a3 90 40 e0 41 80 	movabs %rax,0x8041e04090
  8041606171:	00 00 00 
    page_ref(zero_page);
  8041606174:	48 89 c7             	mov    %rax,%rdi
  8041606177:	48 b8 4e 49 60 41 80 	movabs $0x804160494e,%rax
  804160617e:	00 00 00 
  8041606181:	ff d0                	call   *%rax
    assert(zero_page && one_page);
  8041606183:	48 85 db             	test   %rbx,%rbx
  8041606186:	0f 84 c5 00 00 00    	je     8041606251 <init_memory+0x478>
  804160618c:	48 b8 88 40 e0 41 80 	movabs $0x8041e04088,%rax
  8041606193:	00 00 00 
  8041606196:	48 83 38 00          	cmpq   $0x0,(%rax)
  804160619a:	0f 84 b1 00 00 00    	je     8041606251 <init_memory+0x478>

    detect_memory();
    check_physical_tree(&root);
  80416061a0:	48 bf 00 00 e0 41 80 	movabs $0x8041e00000,%rdi
  80416061a7:	00 00 00 
  80416061aa:	48 b8 71 4a 60 41 80 	movabs $0x8041604a71,%rax
  80416061b1:	00 00 00 
  80416061b4:	ff d0                	call   *%rax
    if (trace_init) cprintf("Physical memory tree is correct\n");
  80416061b6:	48 bf 00 b1 60 41 80 	movabs $0x804160b100,%rdi
  80416061bd:	00 00 00 
  80416061c0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416061c5:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  80416061cc:	00 00 00 
  80416061cf:	ff d2                	call   *%rdx
}
  80416061d1:	48 83 c4 08          	add    $0x8,%rsp
  80416061d5:	5b                   	pop    %rbx
  80416061d6:	41 5c                	pop    %r12
  80416061d8:	41 5d                	pop    %r13
  80416061da:	41 5e                	pop    %r14
  80416061dc:	41 5f                	pop    %r15
  80416061de:	5d                   	pop    %rbp
  80416061df:	c3                   	ret    
        extmem = cmos_read16(CMOS_EXTLO) * KB;
  80416061e0:	0f b7 db             	movzwl %bx,%ebx
        max_memory_map_addr = extmem ? EXTPHYSMEM + extmem : basemem;
  80416061e3:	48 c1 e3 0a          	shl    $0xa,%rbx
  80416061e7:	0f 85 57 fe ff ff    	jne    8041606044 <init_memory+0x26b>
  80416061ed:	4c 89 e6             	mov    %r12,%rsi
  80416061f0:	e9 56 fe ff ff       	jmp    804160604b <init_memory+0x272>
        _panic(file, line, "PADDR called with invalid kva %p", kva);
  80416061f5:	48 89 c1             	mov    %rax,%rcx
  80416061f8:	48 ba 10 af 60 41 80 	movabs $0x804160af10,%rdx
  80416061ff:	00 00 00 
  8041606202:	be 8c 02 00 00       	mov    $0x28c,%esi
  8041606207:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  804160620e:	00 00 00 
  8041606211:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606216:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  804160621d:	00 00 00 
  8041606220:	41 ff d0             	call   *%r8
  8041606223:	48 89 c1             	mov    %rax,%rcx
  8041606226:	48 ba 10 af 60 41 80 	movabs $0x804160af10,%rdx
  804160622d:	00 00 00 
  8041606230:	be 8f 02 00 00       	mov    $0x28f,%esi
  8041606235:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  804160623c:	00 00 00 
  804160623f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606244:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  804160624b:	00 00 00 
  804160624e:	41 ff d0             	call   *%r8
    assert(zero_page && one_page);
  8041606251:	48 b9 3f ac 60 41 80 	movabs $0x804160ac3f,%rcx
  8041606258:	00 00 00 
  804160625b:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041606262:	00 00 00 
  8041606265:	be 92 02 00 00       	mov    $0x292,%esi
  804160626a:	48 bf 01 ab 60 41 80 	movabs $0x804160ab01,%rdi
  8041606271:	00 00 00 
  8041606274:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606279:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041606280:	00 00 00 
  8041606283:	41 ff d0             	call   *%r8

0000008041606286 <envid2env>:
 * RETURNS
 *     0 on success, -E_BAD_ENV on error.
 *   On success, sets *env_store to the environment.
 *   On error, sets *env_store to NULL. */
int
envid2env(envid_t envid, struct Env **env_store, bool need_check_perm) {
  8041606286:	f3 0f 1e fa          	endbr64 
    struct Env *env;

    /* If envid is zero, return the current environment. */
    if (!envid) {
  804160628a:	85 ff                	test   %edi,%edi
  804160628c:	74 6b                	je     80416062f9 <envid2env+0x73>
    /* Look up the Env structure via the index part of the envid,
     * then check the env_id field in that struct Env
     * to ensure that the envid is not stale
     * (i.e., does not refer to a _previous_ environment
     * that used the same slot in the envs[] array). */
    env = &envs[ENVX(envid)];
  804160628e:	89 f9                	mov    %edi,%ecx
  8041606290:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
  8041606296:	48 c1 e1 08          	shl    $0x8,%rcx
  804160629a:	48 a1 20 d7 62 41 80 	movabs 0x804162d720,%rax
  80416062a1:	00 00 00 
  80416062a4:	48 01 c1             	add    %rax,%rcx
    if (env->env_status == ENV_FREE || env->env_id != envid) {
  80416062a7:	83 b9 d4 00 00 00 00 	cmpl   $0x0,0xd4(%rcx)
  80416062ae:	74 5c                	je     804160630c <envid2env+0x86>
  80416062b0:	39 b9 c8 00 00 00    	cmp    %edi,0xc8(%rcx)
  80416062b6:	75 60                	jne    8041606318 <envid2env+0x92>
        *env_store = NULL;
        return -E_BAD_ENV;
    }

    *env_store = env;
    return 0;
  80416062b8:	b8 00 00 00 00       	mov    $0x0,%eax
    if (need_check_perm && env != curenv && env->env_parent_id != curenv->env_id) {
  80416062bd:	84 d2                	test   %dl,%dl
  80416062bf:	74 47                	je     8041606308 <envid2env+0x82>
  80416062c1:	48 b8 c0 43 e4 41 80 	movabs $0x8041e443c0,%rax
  80416062c8:	00 00 00 
  80416062cb:	48 8b 10             	mov    (%rax),%rdx
    return 0;
  80416062ce:	b8 00 00 00 00       	mov    $0x0,%eax
    if (need_check_perm && env != curenv && env->env_parent_id != curenv->env_id) {
  80416062d3:	48 39 ca             	cmp    %rcx,%rdx
  80416062d6:	74 30                	je     8041606308 <envid2env+0x82>
  80416062d8:	8b 81 cc 00 00 00    	mov    0xcc(%rcx),%eax
  80416062de:	3b 82 c8 00 00 00    	cmp    0xc8(%rdx),%eax
  80416062e4:	bf 00 00 00 00       	mov    $0x0,%edi
  80416062e9:	48 0f 45 cf          	cmovne %rdi,%rcx
  80416062ed:	0f 94 c0             	sete   %al
  80416062f0:	0f b6 c0             	movzbl %al,%eax
  80416062f3:	8d 44 00 fe          	lea    -0x2(%rax,%rax,1),%eax
  80416062f7:	eb 0f                	jmp    8041606308 <envid2env+0x82>
        *env_store = curenv;
  80416062f9:	48 b8 c0 43 e4 41 80 	movabs $0x8041e443c0,%rax
  8041606300:	00 00 00 
  8041606303:	48 8b 08             	mov    (%rax),%rcx
        return 0;
  8041606306:	89 f8                	mov    %edi,%eax
        *env_store = curenv;
  8041606308:	48 89 0e             	mov    %rcx,(%rsi)
}
  804160630b:	c3                   	ret    
  804160630c:	b9 00 00 00 00       	mov    $0x0,%ecx
        return -E_BAD_ENV;
  8041606311:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  8041606316:	eb f0                	jmp    8041606308 <envid2env+0x82>
  8041606318:	b9 00 00 00 00       	mov    $0x0,%ecx
  804160631d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  8041606322:	eb e4                	jmp    8041606308 <envid2env+0x82>

0000008041606324 <env_init>:
 * Make sure the environments are in the free list in the same order
 * they are in the envs array (i.e., so that the first call to
 * env_alloc() returns envs[0]).
 */
void
env_init(void) {
  8041606324:	f3 0f 1e fa          	endbr64 
    /* Set up envs array */

    // LAB 3: Your code here

    for(int n_env = 0; n_env < NENV; n_env++){
        envs[n_env].env_link        = envs + n_env + 1;
  8041606328:	48 a1 20 d7 62 41 80 	movabs 0x804162d720,%rax
  804160632f:	00 00 00 
  8041606332:	48 8d 90 00 01 00 00 	lea    0x100(%rax),%rdx
    for(int n_env = 0; n_env < NENV; n_env++){
  8041606339:	b9 00 00 00 00       	mov    $0x0,%ecx
        envs[n_env].env_link        = envs + n_env + 1;
  804160633e:	48 89 52 c0          	mov    %rdx,-0x40(%rdx)
        envs[n_env].env_id          = n_env;
  8041606342:	89 4a c8             	mov    %ecx,-0x38(%rdx)
        //envs[n_env].env_parent_id   = n_env + 1;
        envs[n_env].env_type        = ENV_TYPE_KERNEL;
  8041606345:	c7 42 d0 01 00 00 00 	movl   $0x1,-0x30(%rdx)
        envs[n_env].env_status      = ENV_FREE;
  804160634c:	c7 42 d4 00 00 00 00 	movl   $0x0,-0x2c(%rdx)
        envs[n_env].env_runs        = 0;
  8041606353:	c7 42 d8 00 00 00 00 	movl   $0x0,-0x28(%rdx)
        envs[n_env].binary          = NULL;
  804160635a:	48 c7 42 e0 00 00 00 	movq   $0x0,-0x20(%rdx)
  8041606361:	00 
    for(int n_env = 0; n_env < NENV; n_env++){
  8041606362:	83 c1 01             	add    $0x1,%ecx
  8041606365:	48 81 c2 00 01 00 00 	add    $0x100,%rdx
  804160636c:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  8041606372:	75 ca                	jne    804160633e <env_init+0x1a>
    }

    envs[NENV - 1].env_link = NULL;
  8041606374:	48 c7 80 c0 ff 03 00 	movq   $0x0,0x3ffc0(%rax)
  804160637b:	00 00 00 00 
    env_free_list = envs;
  804160637f:	48 a3 c8 43 e4 41 80 	movabs %rax,0x8041e443c8
  8041606386:	00 00 00 
    
    curenv = NULL;
  8041606389:	48 b8 c0 43 e4 41 80 	movabs $0x8041e443c0,%rax
  8041606390:	00 00 00 
  8041606393:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

    return;
}
  804160639a:	c3                   	ret    

000000804160639b <env_alloc>:
 * Errors
 *    -E_NO_FREE_ENV if all NENVS environments are allocated
 *    -E_NO_MEM on memory exhaustion
 */
int
env_alloc(struct Env **newenv_store, envid_t parent_id, enum EnvType type) {
  804160639b:	f3 0f 1e fa          	endbr64 
  804160639f:	55                   	push   %rbp
  80416063a0:	48 89 e5             	mov    %rsp,%rbp
  80416063a3:	41 55                	push   %r13
  80416063a5:	41 54                	push   %r12
  80416063a7:	53                   	push   %rbx
  80416063a8:	48 83 ec 08          	sub    $0x8,%rsp

    struct Env *env;
    if (!(env = env_free_list))
  80416063ac:	48 b8 c8 43 e4 41 80 	movabs $0x8041e443c8,%rax
  80416063b3:	00 00 00 
  80416063b6:	48 8b 18             	mov    (%rax),%rbx
  80416063b9:	48 85 db             	test   %rbx,%rbx
  80416063bc:	0f 84 30 01 00 00    	je     80416064f2 <env_alloc+0x157>
  80416063c2:	49 89 fc             	mov    %rdi,%r12
        return -E_NO_FREE_ENV;

    /* Generate an env_id for this environment */
    int32_t generation = (env->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
  80416063c5:	8b 83 c8 00 00 00    	mov    0xc8(%rbx),%eax
  80416063cb:	05 00 10 00 00       	add    $0x1000,%eax
    /* Don't create a negative env_id */
    if (generation <= 0) generation = 1 << ENVGENSHIFT;
  80416063d0:	25 00 fc ff ff       	and    $0xfffffc00,%eax
  80416063d5:	ba 00 10 00 00       	mov    $0x1000,%edx
  80416063da:	0f 4e c2             	cmovle %edx,%eax
    env->env_id = generation | (env - envs);
  80416063dd:	49 bd 20 d7 62 41 80 	movabs $0x804162d720,%r13
  80416063e4:	00 00 00 
  80416063e7:	48 89 da             	mov    %rbx,%rdx
  80416063ea:	49 2b 55 00          	sub    0x0(%r13),%rdx
  80416063ee:	48 c1 fa 08          	sar    $0x8,%rdx
  80416063f2:	09 d0                	or     %edx,%eax
  80416063f4:	89 83 c8 00 00 00    	mov    %eax,0xc8(%rbx)

    /* Set the basic status variables */
    env->env_parent_id = parent_id;
  80416063fa:	89 b3 cc 00 00 00    	mov    %esi,0xcc(%rbx)
#ifdef CONFIG_KSPACE
    env->env_type = ENV_TYPE_KERNEL;
  8041606400:	c7 83 d0 00 00 00 01 	movl   $0x1,0xd0(%rbx)
  8041606407:	00 00 00 
#else
    env->env_type = type;
#endif
    env->env_status = ENV_RUNNABLE;
  804160640a:	c7 83 d4 00 00 00 02 	movl   $0x2,0xd4(%rbx)
  8041606411:	00 00 00 
    env->env_runs = 0;
  8041606414:	c7 83 d8 00 00 00 00 	movl   $0x0,0xd8(%rbx)
  804160641b:	00 00 00 

    /* Clear out all the saved register st  ate,
     * to prevent the register values
     * of a prior environment inhabiting this Env structure
     * from "leaking" into our new environment */
    memset(&env->env_tf, 0, sizeof(env->env_tf));
  804160641e:	ba c0 00 00 00       	mov    $0xc0,%edx
  8041606423:	be 00 00 00 00       	mov    $0x0,%esi
  8041606428:	48 89 df             	mov    %rbx,%rdi
  804160642b:	48 b8 5e 93 60 41 80 	movabs $0x804160935e,%rax
  8041606432:	00 00 00 
  8041606435:	ff d0                	call   *%rax
     * we switch privilege levels, the hardware does various
     * checks involving the RPL and the Descriptor Privilege Level
     * (DPL) stored in the descriptors themselves */

#ifdef CONFIG_KSPACE
    env->env_tf.tf_ds = GD_KD;
  8041606437:	66 c7 83 80 00 00 00 	movw   $0x10,0x80(%rbx)
  804160643e:	10 00 
    env->env_tf.tf_es = GD_KD;
  8041606440:	66 c7 43 78 10 00    	movw   $0x10,0x78(%rbx)
    env->env_tf.tf_ss = GD_KD;
  8041606446:	66 c7 83 b8 00 00 00 	movw   $0x10,0xb8(%rbx)
  804160644d:	10 00 
    env->env_tf.tf_cs = GD_KT;
  804160644f:	66 c7 83 a0 00 00 00 	movw   $0x8,0xa0(%rbx)
  8041606456:	08 00 

    // LAB 3: Your code here:
    static uintptr_t stack_top = 0x2000000;

    unsigned long long env_stack_offset = ((env - envs) + 1) * PAGE_SIZE * 2;
  8041606458:	48 89 d8             	mov    %rbx,%rax
  804160645b:	49 2b 45 00          	sub    0x0(%r13),%rax
  804160645f:	48 c1 f8 08          	sar    $0x8,%rax
  8041606463:	48 83 c0 01          	add    $0x1,%rax
  8041606467:	48 c1 e0 0d          	shl    $0xd,%rax

    if(!((stack_top - env_stack_offset) > (UTEXT + PAGE_SIZE * 2) && (stack_top - env_stack_offset) < 0x2000000)){
  804160646b:	b9 00 00 00 02       	mov    $0x2000000,%ecx
  8041606470:	48 29 c1             	sub    %rax,%rcx
  8041606473:	ba ff df 7f 01       	mov    $0x17fdfff,%edx
  8041606478:	48 29 c2             	sub    %rax,%rdx
  804160647b:	48 81 fa fe df 7f 01 	cmp    $0x17fdffe,%rdx
  8041606482:	77 37                	ja     80416064bb <env_alloc+0x120>
        panic("attempt to initiate memory [%llx - %llx] for proccess %p", stack_top - env_stack_offset, stack_top - env_stack_offset - 2 * PAGE_SIZE, env);
    }

    env->env_tf.tf_rsp = stack_top - env_stack_offset;
  8041606484:	48 89 8b b0 00 00 00 	mov    %rcx,0xb0(%rbx)
    env->env_tf.tf_cs = GD_UT | 3;
    env->env_tf.tf_rsp = USER_STACK_TOP;
#endif

    /* For now init trapframe with IF set */
    env->env_tf.tf_rflags = FL_IF;
  804160648b:	48 c7 83 a8 00 00 00 	movq   $0x200,0xa8(%rbx)
  8041606492:	00 02 00 00 

    /* Commit the allocation */
    env_free_list = env->env_link;
  8041606496:	48 8b 83 c0 00 00 00 	mov    0xc0(%rbx),%rax
  804160649d:	48 a3 c8 43 e4 41 80 	movabs %rax,0x8041e443c8
  80416064a4:	00 00 00 
    *newenv_store = env;
  80416064a7:	49 89 1c 24          	mov    %rbx,(%r12)

    if (trace_envs) cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, env->env_id);
    return 0;
  80416064ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80416064b0:	48 83 c4 08          	add    $0x8,%rsp
  80416064b4:	5b                   	pop    %rbx
  80416064b5:	41 5c                	pop    %r12
  80416064b7:	41 5d                	pop    %r13
  80416064b9:	5d                   	pop    %rbp
  80416064ba:	c3                   	ret    
        panic("attempt to initiate memory [%llx - %llx] for proccess %p", stack_top - env_stack_offset, stack_top - env_stack_offset - 2 * PAGE_SIZE, env);
  80416064bb:	49 89 d9             	mov    %rbx,%r9
  80416064be:	41 b8 00 e0 ff 01    	mov    $0x1ffe000,%r8d
  80416064c4:	49 29 c0             	sub    %rax,%r8
  80416064c7:	48 ba 28 b1 60 41 80 	movabs $0x804160b128,%rdx
  80416064ce:	00 00 00 
  80416064d1:	be b6 00 00 00       	mov    $0xb6,%esi
  80416064d6:	48 bf 61 b1 60 41 80 	movabs $0x804160b161,%rdi
  80416064dd:	00 00 00 
  80416064e0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416064e5:	49 ba e3 03 60 41 80 	movabs $0x80416003e3,%r10
  80416064ec:	00 00 00 
  80416064ef:	41 ff d2             	call   *%r10
        return -E_NO_FREE_ENV;
  80416064f2:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
  80416064f7:	eb b7                	jmp    80416064b0 <env_alloc+0x115>

00000080416064f9 <env_create>:
 * This function is ONLY called during kernel initialization,
 * before running the first user-mode environment.
 * The new env's parent ID is set to 0.
 */
void
env_create(uint8_t *binary, size_t size, enum EnvType type) {
  80416064f9:	f3 0f 1e fa          	endbr64 
  80416064fd:	55                   	push   %rbp
  80416064fe:	48 89 e5             	mov    %rsp,%rbp
  8041606501:	41 57                	push   %r15
  8041606503:	41 56                	push   %r14
  8041606505:	41 55                	push   %r13
  8041606507:	41 54                	push   %r12
  8041606509:	53                   	push   %rbx
  804160650a:	48 83 ec 58          	sub    $0x58,%rsp
  804160650e:	49 89 ff             	mov    %rdi,%r15
  8041606511:	49 89 f5             	mov    %rsi,%r13
  8041606514:	89 55 bc             	mov    %edx,-0x44(%rbp)
    // LAB 3: Your code here

    struct Env* new_env = NULL;
  8041606517:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  804160651e:	00 

    int alloc_res = env_alloc(&new_env, 0, type);
  804160651f:	be 00 00 00 00       	mov    $0x0,%esi
  8041606524:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041606528:	48 b8 9b 63 60 41 80 	movabs $0x804160639b,%rax
  804160652f:	00 00 00 
  8041606532:	ff d0                	call   *%rax
    
    if(alloc_res == -E_NO_FREE_ENV || alloc_res == -E_NO_MEM){
  8041606534:	8d 50 05             	lea    0x5(%rax),%edx
  8041606537:	83 fa 01             	cmp    $0x1,%edx
  804160653a:	0f 86 4b 01 00 00    	jbe    804160668b <env_create+0x192>
        panic("env_create: %i\n", alloc_res);
    }

    int binary_load_res = load_icode(new_env, binary, size);
  8041606540:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041606544:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
    if(elf_header->e_magic != ELF_MAGIC)                  return -E_INVALID_EXE;
  8041606548:	41 81 3f 7f 45 4c 46 	cmpl   $0x464c457f,(%r15)
  804160654f:	0f 85 8e 04 00 00    	jne    80416069e3 <env_create+0x4ea>
    if(elf_header->e_type == ET_NONE)                     return -E_INVALID_EXE;
  8041606555:	66 41 83 7f 10 00    	cmpw   $0x0,0x10(%r15)
  804160655b:	0f 84 82 04 00 00    	je     80416069e3 <env_create+0x4ea>
    if(elf_header->e_ehsize > size)                       return -E_INVALID_EXE;
  8041606561:	41 0f b7 47 34       	movzwl 0x34(%r15),%eax
  8041606566:	49 39 c5             	cmp    %rax,%r13
  8041606569:	0f 82 74 04 00 00    	jb     80416069e3 <env_create+0x4ea>
    if(elf_header->e_phentsize != sizeof(struct Proghdr)) return -E_INVALID_EXE;
  804160656f:	66 41 83 7f 36 38    	cmpw   $0x38,0x36(%r15)
  8041606575:	0f 85 68 04 00 00    	jne    80416069e3 <env_create+0x4ea>
    if(elf_header->e_shentsize != sizeof(struct Secthdr)) return -E_INVALID_EXE;
  804160657b:	66 41 83 7f 3a 40    	cmpw   $0x40,0x3a(%r15)
  8041606581:	0f 85 5c 04 00 00    	jne    80416069e3 <env_create+0x4ea>
    if(__builtin_umulll_overflow(sizeof(struct Proghdr), elf_header->e_phnum, &program_headers_size)) return -E_INVALID_EXE;
  8041606587:	41 0f b7 57 38       	movzwl 0x38(%r15),%edx
    if(__builtin_umulll_overflow(sizeof(struct Secthdr), elf_header->e_shnum, &section_headers_size)) return -E_INVALID_EXE;
  804160658c:	41 0f b7 7f 3c       	movzwl 0x3c(%r15),%edi
    if(__builtin_umulll_overflow(sizeof(struct Proghdr), elf_header->e_phnum, &program_headers_size)) return -E_INVALID_EXE;
  8041606591:	0f b7 ca             	movzwl %dx,%ecx
  8041606594:	48 8d 04 cd 00 00 00 	lea    0x0(,%rcx,8),%rax
  804160659b:	00 
  804160659c:	48 29 c8             	sub    %rcx,%rax
  804160659f:	48 c1 e0 03          	shl    $0x3,%rax
    if(__builtin_umulll_overflow(sizeof(struct Secthdr), elf_header->e_shnum, &section_headers_size)) return -E_INVALID_EXE;
  80416065a3:	0f b7 cf             	movzwl %di,%ecx
  80416065a6:	48 c1 e1 06          	shl    $0x6,%rcx
    if(section_headers_size > size) return -E_INVALID_EXE;
  80416065aa:	48 39 c8             	cmp    %rcx,%rax
  80416065ad:	48 0f 42 c1          	cmovb  %rcx,%rax
  80416065b1:	49 39 c5             	cmp    %rax,%r13
  80416065b4:	0f 82 29 04 00 00    	jb     80416069e3 <env_create+0x4ea>
    if(elf_header->e_phoff == 0 || elf_header->e_phoff > size) return -E_INVALID_EXE;
  80416065ba:	49 8b 5f 20          	mov    0x20(%r15),%rbx
  80416065be:	48 8d 43 ff          	lea    -0x1(%rbx),%rax
  80416065c2:	49 39 c5             	cmp    %rax,%r13
  80416065c5:	0f 86 18 04 00 00    	jbe    80416069e3 <env_create+0x4ea>
    if(elf_header->e_shoff == 0 || elf_header->e_shoff > size) return -E_INVALID_EXE;
  80416065cb:	4d 8b 67 28          	mov    0x28(%r15),%r12
  80416065cf:	49 8d 44 24 ff       	lea    -0x1(%r12),%rax
  80416065d4:	49 39 c5             	cmp    %rax,%r13
  80416065d7:	0f 86 06 04 00 00    	jbe    80416069e3 <env_create+0x4ea>
    const struct Proghdr* prog_headers = (const struct Proghdr*)(binary + elf_header->e_phoff);
  80416065dd:	4c 01 fb             	add    %r15,%rbx
    const struct Secthdr* sect_headers = (const struct Secthdr*)(binary + elf_header->e_shoff);
  80416065e0:	4d 01 fc             	add    %r15,%r12
    for(int n_header = 0; n_header < elf_header->e_phnum; n_header++){
  80416065e3:	0f b7 f2             	movzwl %dx,%esi
  80416065e6:	85 f6                	test   %esi,%esi
  80416065e8:	0f 8e ca 00 00 00    	jle    80416066b8 <env_create+0x1bf>
  80416065ee:	48 8d 43 08          	lea    0x8(%rbx),%rax
  80416065f2:	8d 4e ff             	lea    -0x1(%rsi),%ecx
  80416065f5:	48 8d 14 cd 00 00 00 	lea    0x0(,%rcx,8),%rdx
  80416065fc:	00 
  80416065fd:	48 29 ca             	sub    %rcx,%rdx
  8041606600:	4c 8d 44 d3 40       	lea    0x40(%rbx,%rdx,8),%r8
        struct Proghdr prog_header = prog_headers[n_header];
  8041606605:	48 8b 10             	mov    (%rax),%rdx
  8041606608:	48 8b 48 18          	mov    0x18(%rax),%rcx
        if(prog_header.p_filesz > prog_header.p_memsz) return -E_INVALID_EXE;
  804160660c:	48 3b 48 20          	cmp    0x20(%rax),%rcx
  8041606610:	0f 87 cd 03 00 00    	ja     80416069e3 <env_create+0x4ea>
        if(__builtin_uaddll_overflow(prog_header.p_offset, prog_header.p_filesz, &prog_header_limit_offset)) return -E_INVALID_EXE;
  8041606616:	48 01 ca             	add    %rcx,%rdx
  8041606619:	0f 92 c1             	setb   %cl
  804160661c:	0f b6 c9             	movzbl %cl,%ecx
        if(prog_header_limit_offset > size) return -E_INVALID_EXE;
  804160661f:	49 39 d5             	cmp    %rdx,%r13
  8041606622:	0f 82 bb 03 00 00    	jb     80416069e3 <env_create+0x4ea>
  8041606628:	48 85 c9             	test   %rcx,%rcx
  804160662b:	0f 85 b2 03 00 00    	jne    80416069e3 <env_create+0x4ea>
    for(int n_header = 0; n_header < elf_header->e_phnum; n_header++){
  8041606631:	48 83 c0 38          	add    $0x38,%rax
  8041606635:	4c 39 c0             	cmp    %r8,%rax
  8041606638:	75 cb                	jne    8041606605 <env_create+0x10c>
    for(int n_header = 0 ; n_header < elf_header->e_shnum; n_header++){
  804160663a:	0f b7 ff             	movzwl %di,%edi
  804160663d:	85 ff                	test   %edi,%edi
  804160663f:	7e 3e                	jle    804160667f <env_create+0x186>
  8041606641:	49 8d 44 24 18       	lea    0x18(%r12),%rax
  8041606646:	b9 00 00 00 00       	mov    $0x0,%ecx
        if(__builtin_uaddll_overflow(section_header.sh_offset, section_header.sh_size, &sect_header_limit_offset)) return -E_INVALID_EXE;
  804160664b:	48 8b 50 08          	mov    0x8(%rax),%rdx
  804160664f:	48 03 10             	add    (%rax),%rdx
  8041606652:	41 0f 92 c0          	setb   %r8b
  8041606656:	45 0f b6 c0          	movzbl %r8b,%r8d
        if(sect_header_limit_offset > size) return -E_INVALID_EXE;
  804160665a:	49 39 d5             	cmp    %rdx,%r13
  804160665d:	0f 82 80 03 00 00    	jb     80416069e3 <env_create+0x4ea>
  8041606663:	4d 85 c0             	test   %r8,%r8
  8041606666:	0f 85 77 03 00 00    	jne    80416069e3 <env_create+0x4ea>
    for(int n_header = 0 ; n_header < elf_header->e_shnum; n_header++){
  804160666c:	83 c1 01             	add    $0x1,%ecx
  804160666f:	48 83 c0 40          	add    $0x40,%rax
  8041606673:	39 f9                	cmp    %edi,%ecx
  8041606675:	7c d4                	jl     804160664b <env_create+0x152>
    for(int n_header = 0; n_header < elf_header->e_phnum; n_header++){
  8041606677:	85 f6                	test   %esi,%esi
  8041606679:	0f 8e ad 00 00 00    	jle    804160672c <env_create+0x233>
    for(int n_header = 0 ; n_header < elf_header->e_shnum; n_header++){
  804160667f:	41 bd 00 00 00 00    	mov    $0x0,%r13d
            memset((uint8_t*)prog_header.p_va + prog_header.p_filesz, 0, prog_header.p_memsz - prog_header.p_filesz);
  8041606685:	4c 89 65 a0          	mov    %r12,-0x60(%rbp)
  8041606689:	eb 48                	jmp    80416066d3 <env_create+0x1da>
        panic("env_create: %i\n", alloc_res);
  804160668b:	89 c1                	mov    %eax,%ecx
  804160668d:	48 ba 6c b1 60 41 80 	movabs $0x804160b16c,%rdx
  8041606694:	00 00 00 
  8041606697:	be be 01 00 00       	mov    $0x1be,%esi
  804160669c:	48 bf 61 b1 60 41 80 	movabs $0x804160b161,%rdi
  80416066a3:	00 00 00 
  80416066a6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416066ab:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  80416066b2:	00 00 00 
  80416066b5:	41 ff d0             	call   *%r8
    for(int n_header = 0 ; n_header < elf_header->e_shnum; n_header++){
  80416066b8:	0f b7 ff             	movzwl %di,%edi
  80416066bb:	85 ff                	test   %edi,%edi
  80416066bd:	7f 82                	jg     8041606641 <env_create+0x148>
  80416066bf:	eb 6b                	jmp    804160672c <env_create+0x233>
    for(int n_header = 0; n_header < elf_header->e_phnum; n_header++){
  80416066c1:	41 83 c5 01          	add    $0x1,%r13d
  80416066c5:	48 83 c3 38          	add    $0x38,%rbx
  80416066c9:	41 0f b7 47 38       	movzwl 0x38(%r15),%eax
  80416066ce:	41 39 c5             	cmp    %eax,%r13d
  80416066d1:	7d 55                	jge    8041606728 <env_create+0x22f>
        struct Proghdr prog_header = prog_headers[n_header];
  80416066d3:	4c 8b 63 20          	mov    0x20(%rbx),%r12
        if(prog_header.p_type != ELF_PROG_LOAD || prog_header.p_filesz == 0) continue;
  80416066d7:	83 3b 01             	cmpl   $0x1,(%rbx)
  80416066da:	75 e5                	jne    80416066c1 <env_create+0x1c8>
  80416066dc:	4d 85 e4             	test   %r12,%r12
  80416066df:	74 e0                	je     80416066c1 <env_create+0x1c8>
        struct Proghdr prog_header = prog_headers[n_header];
  80416066e1:	48 8b 7b 10          	mov    0x10(%rbx),%rdi
  80416066e5:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  80416066e9:	4c 8b 73 28          	mov    0x28(%rbx),%r14
        memcpy((void*)prog_header.p_va, binary + prog_header.p_offset, prog_header.p_filesz);
  80416066ed:	4c 89 fe             	mov    %r15,%rsi
  80416066f0:	48 03 73 08          	add    0x8(%rbx),%rsi
  80416066f4:	4c 89 e2             	mov    %r12,%rdx
  80416066f7:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416066fe:	00 00 00 
  8041606701:	ff d0                	call   *%rax
        if(prog_header.p_memsz > prog_header.p_filesz){
  8041606703:	4d 39 f4             	cmp    %r14,%r12
  8041606706:	73 b9                	jae    80416066c1 <env_create+0x1c8>
            memset((uint8_t*)prog_header.p_va + prog_header.p_filesz, 0, prog_header.p_memsz - prog_header.p_filesz);
  8041606708:	4c 89 f2             	mov    %r14,%rdx
  804160670b:	4c 29 e2             	sub    %r12,%rdx
  804160670e:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  8041606712:	4c 01 e7             	add    %r12,%rdi
  8041606715:	be 00 00 00 00       	mov    $0x0,%esi
  804160671a:	48 b8 5e 93 60 41 80 	movabs $0x804160935e,%rax
  8041606721:	00 00 00 
  8041606724:	ff d0                	call   *%rax
  8041606726:	eb 99                	jmp    80416066c1 <env_create+0x1c8>
  8041606728:	4c 8b 65 a0          	mov    -0x60(%rbp),%r12
    for(int n_header = 0 ; n_header < elf_header->e_shnum; n_header++){
  804160672c:	66 41 83 7f 3c 00    	cmpw   $0x0,0x3c(%r15)
  8041606732:	74 43                	je     8041606777 <env_create+0x27e>
  8041606734:	49 83 c4 04          	add    $0x4,%r12
  8041606738:	bb 00 00 00 00       	mov    $0x0,%ebx
        memcpy((void*)section_header.sh_addr, binary + section_header.sh_offset, section_header.sh_size);
  804160673d:	49 bd 77 94 60 41 80 	movabs $0x8041609477,%r13
  8041606744:	00 00 00 
  8041606747:	eb 10                	jmp    8041606759 <env_create+0x260>
    for(int n_header = 0 ; n_header < elf_header->e_shnum; n_header++){
  8041606749:	83 c3 01             	add    $0x1,%ebx
  804160674c:	49 83 c4 40          	add    $0x40,%r12
  8041606750:	41 0f b7 47 3c       	movzwl 0x3c(%r15),%eax
  8041606755:	39 c3                	cmp    %eax,%ebx
  8041606757:	7d 1e                	jge    8041606777 <env_create+0x27e>
        if(section_header.sh_type == ELF_SHT_NULL) continue;
  8041606759:	41 83 3c 24 00       	cmpl   $0x0,(%r12)
  804160675e:	74 e9                	je     8041606749 <env_create+0x250>
        memcpy((void*)section_header.sh_addr, binary + section_header.sh_offset, section_header.sh_size);
  8041606760:	49 8b 54 24 1c       	mov    0x1c(%r12),%rdx
  8041606765:	4c 89 fe             	mov    %r15,%rsi
  8041606768:	49 03 74 24 14       	add    0x14(%r12),%rsi
  804160676d:	49 8b 7c 24 0c       	mov    0xc(%r12),%rdi
  8041606772:	41 ff d5             	call   *%r13
  8041606775:	eb d2                	jmp    8041606749 <env_create+0x250>
    env->binary        = binary;
  8041606777:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  804160677b:	4c 89 be e0 00 00 00 	mov    %r15,0xe0(%rsi)
    env->env_tf.tf_rip = elf_header->e_entry;
  8041606782:	49 8b 47 18          	mov    0x18(%r15),%rax
  8041606786:	48 89 86 98 00 00 00 	mov    %rax,0x98(%rsi)
    const struct Secthdr* sections_pos = (struct Secthdr*)(binary + header->e_shoff);
  804160678d:	4c 89 fe             	mov    %r15,%rsi
  8041606790:	49 03 77 28          	add    0x28(%r15),%rsi
  8041606794:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
    unsigned int n_sections = header->e_shnum;
  8041606798:	41 0f b7 57 3c       	movzwl 0x3c(%r15),%edx
  804160679d:	0f b7 c2             	movzwl %dx,%eax
  80416067a0:	89 45 98             	mov    %eax,-0x68(%rbp)
    const struct Secthdr* p_shstrtab_header = sections_pos + header->e_shstrndx;
  80416067a3:	41 0f b7 47 3e       	movzwl 0x3e(%r15),%eax
    const char* p_shstrtab = (const char*)(binary + p_shstrtab_header->sh_offset);
  80416067a8:	48 c1 e0 06          	shl    $0x6,%rax
  80416067ac:	4c 89 fb             	mov    %r15,%rbx
  80416067af:	48 03 5c 06 18       	add    0x18(%rsi,%rax,1),%rbx
  80416067b4:	48 89 5d b0          	mov    %rbx,-0x50(%rbp)
    for (int section_index = 0; section_index < header->e_shnum; section_index++) {
  80416067b8:	66 85 d2             	test   %dx,%dx
  80416067bb:	74 43                	je     8041606800 <env_create+0x307>
  80416067bd:	49 89 f6             	mov    %rsi,%r14
  80416067c0:	48 89 f3             	mov    %rsi,%rbx
  80416067c3:	41 bc 00 00 00 00    	mov    $0x0,%r12d
        if(strcmp(p_shstrtab + section_header->sh_name, ".bss") == 0) {
  80416067c9:	49 bd a6 92 60 41 80 	movabs $0x80416092a6,%r13
  80416067d0:	00 00 00 
        const struct Secthdr* section_header = sections_pos + section_index;
  80416067d3:	48 89 5d a8          	mov    %rbx,-0x58(%rbp)
        if(strcmp(p_shstrtab + section_header->sh_name, ".bss") == 0) {
  80416067d7:	8b 3b                	mov    (%rbx),%edi
  80416067d9:	48 03 7d b0          	add    -0x50(%rbp),%rdi
  80416067dd:	48 be 7c b1 60 41 80 	movabs $0x804160b17c,%rsi
  80416067e4:	00 00 00 
  80416067e7:	41 ff d5             	call   *%r13
  80416067ea:	85 c0                	test   %eax,%eax
  80416067ec:	74 2e                	je     804160681c <env_create+0x323>
    for (int section_index = 0; section_index < header->e_shnum; section_index++) {
  80416067ee:	41 83 c4 01          	add    $0x1,%r12d
  80416067f2:	48 83 c3 40          	add    $0x40,%rbx
  80416067f6:	41 0f b7 47 3c       	movzwl 0x3c(%r15),%eax
  80416067fb:	41 39 c4             	cmp    %eax,%r12d
  80416067fe:	7c d3                	jl     80416067d3 <env_create+0x2da>
    if(binary_load_res == -E_INVALID_EXE){
        panic("env_create: %i\n", binary_load_res);
    }

    new_env->env_type = type;
  8041606800:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041606804:	8b 75 bc             	mov    -0x44(%rbp),%esi
  8041606807:	89 b0 d0 00 00 00    	mov    %esi,0xd0(%rax)
    return;
}
  804160680d:	48 83 c4 58          	add    $0x58,%rsp
  8041606811:	5b                   	pop    %rbx
  8041606812:	41 5c                	pop    %r12
  8041606814:	41 5d                	pop    %r13
  8041606816:	41 5e                	pop    %r14
  8041606818:	41 5f                	pop    %r15
  804160681a:	5d                   	pop    %rbp
  804160681b:	c3                   	ret    
            bss_init = section_header->sh_addr;
  804160681c:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  8041606820:	48 8b 46 10          	mov    0x10(%rsi),%rax
  8041606824:	48 89 45 88          	mov    %rax,-0x78(%rbp)
            bss_end = bss_init + section_header->sh_size;
  8041606828:	48 89 f3             	mov    %rsi,%rbx
  804160682b:	48 89 c6             	mov    %rax,%rsi
  804160682e:	48 03 73 20          	add    0x20(%rbx),%rsi
  8041606832:	48 89 75 90          	mov    %rsi,-0x70(%rbp)
    if (bss_init == bss_end) return -1;
  8041606836:	48 39 f0             	cmp    %rsi,%rax
  8041606839:	74 c5                	je     8041606800 <env_create+0x307>
    for(unsigned int n_section = 0; n_section < n_sections; n_section++){
  804160683b:	8b 45 98             	mov    -0x68(%rbp),%eax
  804160683e:	8d 40 ff             	lea    -0x1(%rax),%eax
  8041606841:	48 c1 e0 06          	shl    $0x6,%rax
  8041606845:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  8041606849:	4c 8d 64 06 40       	lea    0x40(%rsi,%rax,1),%r12
    unsigned int n_symbs = 0;
  804160684e:	c7 45 a0 00 00 00 00 	movl   $0x0,-0x60(%rbp)
    struct Elf64_Sym* p_symtab = 0;
  8041606855:	48 c7 45 98 00 00 00 	movq   $0x0,-0x68(%rbp)
  804160685c:	00 
    const char*       p_strtab = 0;
  804160685d:	48 c7 45 a8 00 00 00 	movq   $0x0,-0x58(%rbp)
  8041606864:	00 
            if(!strcmp(sect_name, ".symtab")){
  8041606865:	49 bd a6 92 60 41 80 	movabs $0x80416092a6,%r13
  804160686c:	00 00 00 
  804160686f:	eb 2c                	jmp    804160689d <env_create+0x3a4>
            const char* sect_name = p_shstrtab + cur_sect->sh_name;
  8041606871:	41 8b 3e             	mov    (%r14),%edi
  8041606874:	48 03 7d b0          	add    -0x50(%rbp),%rdi
            if(!strcmp(sect_name, ".strtab")){
  8041606878:	48 be 81 b1 60 41 80 	movabs $0x804160b181,%rsi
  804160687f:	00 00 00 
  8041606882:	41 ff d5             	call   *%r13
  8041606885:	85 c0                	test   %eax,%eax
  8041606887:	75 0b                	jne    8041606894 <env_create+0x39b>
                p_strtab = (const char*)(binary + cur_sect->sh_offset);
  8041606889:	4c 89 f8             	mov    %r15,%rax
  804160688c:	49 03 46 18          	add    0x18(%r14),%rax
  8041606890:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
    for(unsigned int n_section = 0; n_section < n_sections; n_section++){
  8041606894:	49 83 c6 40          	add    $0x40,%r14
  8041606898:	4d 39 e6             	cmp    %r12,%r14
  804160689b:	74 4b                	je     80416068e8 <env_create+0x3ef>
        if(cur_sect->sh_type == ELF_SHT_STRTAB){
  804160689d:	41 8b 46 04          	mov    0x4(%r14),%eax
  80416068a1:	83 f8 03             	cmp    $0x3,%eax
  80416068a4:	74 cb                	je     8041606871 <env_create+0x378>
        else if(cur_sect->sh_type == ELF_SHT_SYMTAB){
  80416068a6:	83 f8 02             	cmp    $0x2,%eax
  80416068a9:	75 e9                	jne    8041606894 <env_create+0x39b>
            const char* sect_name = p_shstrtab + cur_sect->sh_name;
  80416068ab:	41 8b 3e             	mov    (%r14),%edi
  80416068ae:	48 03 7d b0          	add    -0x50(%rbp),%rdi
            if(!strcmp(sect_name, ".symtab")){
  80416068b2:	48 be 89 b1 60 41 80 	movabs $0x804160b189,%rsi
  80416068b9:	00 00 00 
  80416068bc:	41 ff d5             	call   *%r13
  80416068bf:	85 c0                	test   %eax,%eax
  80416068c1:	75 d1                	jne    8041606894 <env_create+0x39b>
                p_symtab = (struct Elf64_Sym*)(binary + cur_sect->sh_offset);
  80416068c3:	4c 89 f8             	mov    %r15,%rax
  80416068c6:	49 03 46 18          	add    0x18(%r14),%rax
  80416068ca:	48 89 45 98          	mov    %rax,-0x68(%rbp)
                n_symbs = cur_sect->sh_size / sizeof(struct Elf64_Sym);
  80416068ce:	49 8b 56 20          	mov    0x20(%r14),%rdx
  80416068d2:	48 b8 ab aa aa aa aa 	movabs $0xaaaaaaaaaaaaaaab,%rax
  80416068d9:	aa aa aa 
  80416068dc:	48 f7 e2             	mul    %rdx
  80416068df:	48 c1 ea 04          	shr    $0x4,%rdx
  80416068e3:	89 55 a0             	mov    %edx,-0x60(%rbp)
  80416068e6:	eb ac                	jmp    8041606894 <env_create+0x39b>
    if (p_strtab == NULL) return -1;
  80416068e8:	48 83 7d a8 00       	cmpq   $0x0,-0x58(%rbp)
  80416068ed:	0f 84 0d ff ff ff    	je     8041606800 <env_create+0x307>
    for(unsigned int n_sym = 0; n_sym < n_symbs; n_sym++){
  80416068f3:	8b 45 a0             	mov    -0x60(%rbp),%eax
  80416068f6:	85 c0                	test   %eax,%eax
  80416068f8:	0f 84 02 ff ff ff    	je     8041606800 <env_create+0x307>
  80416068fe:	48 8b 75 98          	mov    -0x68(%rbp),%rsi
  8041606902:	48 89 f3             	mov    %rsi,%rbx
  8041606905:	8d 40 ff             	lea    -0x1(%rax),%eax
  8041606908:	48 8d 04 40          	lea    (%rax,%rax,2),%rax
  804160690c:	4c 8d 6c c6 18       	lea    0x18(%rsi,%rax,8),%r13
                if(strcmp(non_dwarf_kern_functions[n_non_dwarf_func].name, symb_name) == 0){
  8041606911:	49 be a6 92 60 41 80 	movabs $0x80416092a6,%r14
  8041606918:	00 00 00 
                    *((uintptr_t*)cur_sym->st_value) = non_dwarf_kern_functions[n_non_dwarf_func].addr;
  804160691b:	49 bf 00 b2 60 41 80 	movabs $0x804160b200,%r15
  8041606922:	00 00 00 
  8041606925:	eb 2c                	jmp    8041606953 <env_create+0x45a>
            for(unsigned int n_non_dwarf_func = 0; n_non_dwarf_func < N_NON_DWARF_KERN_FUNCTIONS; n_non_dwarf_func++){
  8041606927:	b8 01 00 00 00       	mov    $0x1,%eax
  804160692c:	eb 05                	jmp    8041606933 <env_create+0x43a>
  804160692e:	b8 00 00 00 00       	mov    $0x0,%eax
                    *((uintptr_t*)cur_sym->st_value) = non_dwarf_kern_functions[n_non_dwarf_func].addr;
  8041606933:	49 8b 54 24 08       	mov    0x8(%r12),%rdx
  8041606938:	89 c0                	mov    %eax,%eax
  804160693a:	48 c1 e0 04          	shl    $0x4,%rax
  804160693e:	49 8b 44 07 08       	mov    0x8(%r15,%rax,1),%rax
  8041606943:	48 89 02             	mov    %rax,(%rdx)
    for(unsigned int n_sym = 0; n_sym < n_symbs; n_sym++){
  8041606946:	48 83 c3 18          	add    $0x18,%rbx
  804160694a:	4c 39 eb             	cmp    %r13,%rbx
  804160694d:	0f 84 ad fe ff ff    	je     8041606800 <env_create+0x307>
        if(ELF_ST_TYPE(cur_sym->st_info) == STT_OBJECT && ELF_ST_BIND(cur_sym->st_info) == STB_GLOBAL){
  8041606953:	49 89 dc             	mov    %rbx,%r12
  8041606956:	0f b6 43 04          	movzbl 0x4(%rbx),%eax
  804160695a:	89 c2                	mov    %eax,%edx
  804160695c:	83 e2 0f             	and    $0xf,%edx
  804160695f:	80 fa 01             	cmp    $0x1,%dl
  8041606962:	75 e2                	jne    8041606946 <env_create+0x44d>
  8041606964:	c0 e8 04             	shr    $0x4,%al
  8041606967:	3c 01                	cmp    $0x1,%al
  8041606969:	75 db                	jne    8041606946 <env_create+0x44d>
            if (cur_sym->st_value < bss_init || cur_sym->st_value >= bss_end) {
  804160696b:	48 8b 43 08          	mov    0x8(%rbx),%rax
  804160696f:	48 39 45 90          	cmp    %rax,-0x70(%rbp)
  8041606973:	76 d1                	jbe    8041606946 <env_create+0x44d>
  8041606975:	48 39 45 88          	cmp    %rax,-0x78(%rbp)
  8041606979:	77 cb                	ja     8041606946 <env_create+0x44d>
            const char* symb_name = p_strtab + cur_sym->st_name;
  804160697b:	8b 03                	mov    (%rbx),%eax
  804160697d:	48 03 45 a8          	add    -0x58(%rbp),%rax
                if(strcmp(non_dwarf_kern_functions[n_non_dwarf_func].name, symb_name) == 0){
  8041606981:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  8041606985:	48 89 c6             	mov    %rax,%rsi
  8041606988:	48 bf 91 b1 60 41 80 	movabs $0x804160b191,%rdi
  804160698f:	00 00 00 
  8041606992:	41 ff d6             	call   *%r14
  8041606995:	85 c0                	test   %eax,%eax
  8041606997:	74 95                	je     804160692e <env_create+0x435>
  8041606999:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  804160699d:	48 bf 9b b1 60 41 80 	movabs $0x804160b19b,%rdi
  80416069a4:	00 00 00 
  80416069a7:	41 ff d6             	call   *%r14
  80416069aa:	85 c0                	test   %eax,%eax
  80416069ac:	0f 84 75 ff ff ff    	je     8041606927 <env_create+0x42e>
            if((offset = find_function(symb_name)) != 0){
  80416069b2:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
  80416069b6:	48 b8 ec 87 60 41 80 	movabs $0x80416087ec,%rax
  80416069bd:	00 00 00 
  80416069c0:	ff d0                	call   *%rax
  80416069c2:	48 85 c0             	test   %rax,%rax
  80416069c5:	74 0c                	je     80416069d3 <env_create+0x4da>
                *((uintptr_t*)cur_sym->st_value) = offset;
  80416069c7:	48 8b 53 08          	mov    0x8(%rbx),%rdx
  80416069cb:	48 89 02             	mov    %rax,(%rdx)
  80416069ce:	e9 73 ff ff ff       	jmp    8041606946 <env_create+0x44d>
                *((uintptr_t*)cur_sym->st_value) = 0;
  80416069d3:	48 8b 43 08          	mov    0x8(%rbx),%rax
  80416069d7:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  80416069de:	e9 63 ff ff ff       	jmp    8041606946 <env_create+0x44d>
        panic("env_create: %i\n", binary_load_res);
  80416069e3:	b9 f8 ff ff ff       	mov    $0xfffffff8,%ecx
  80416069e8:	48 ba 6c b1 60 41 80 	movabs $0x804160b16c,%rdx
  80416069ef:	00 00 00 
  80416069f2:	be c3 01 00 00       	mov    $0x1c3,%esi
  80416069f7:	48 bf 61 b1 60 41 80 	movabs $0x804160b161,%rdi
  80416069fe:	00 00 00 
  8041606a01:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606a06:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041606a0d:	00 00 00 
  8041606a10:	41 ff d0             	call   *%r8

0000008041606a13 <env_free>:

/* Frees env and all memory it uses */
void
env_free(struct Env *env) {
  8041606a13:	f3 0f 1e fa          	endbr64 

    /* Note the environment's demise. */
    if (trace_envs) cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, env->env_id);

    /* Return the environment to the free list */
    env->env_status = ENV_FREE;
  8041606a17:	c7 87 d4 00 00 00 00 	movl   $0x0,0xd4(%rdi)
  8041606a1e:	00 00 00 
    env->env_link = env_free_list;
  8041606a21:	48 b8 c8 43 e4 41 80 	movabs $0x8041e443c8,%rax
  8041606a28:	00 00 00 
  8041606a2b:	48 8b 10             	mov    (%rax),%rdx
  8041606a2e:	48 89 97 c0 00 00 00 	mov    %rdx,0xc0(%rdi)
    env_free_list = env;
  8041606a35:	48 89 38             	mov    %rdi,(%rax)
}
  8041606a38:	c3                   	ret    

0000008041606a39 <env_destroy>:
 *
 * If env was the current one, then runs a new environment
 * (and does not return to the caller)
 */
void
env_destroy(struct Env *env) {
  8041606a39:	f3 0f 1e fa          	endbr64 
  8041606a3d:	55                   	push   %rbp
  8041606a3e:	48 89 e5             	mov    %rsp,%rbp
     * ENV_DYING. A zombie environment will be freed the next time
     * it traps to the kernel. */

    // LAB 3: Your code here

    env_free(env);
  8041606a41:	48 b8 13 6a 60 41 80 	movabs $0x8041606a13,%rax
  8041606a48:	00 00 00 
  8041606a4b:	ff d0                	call   *%rax

    sched_yield();
  8041606a4d:	48 b8 2d 84 60 41 80 	movabs $0x804160842d,%rax
  8041606a54:	00 00 00 
  8041606a57:	ff d0                	call   *%rax

0000008041606a59 <csys_exit>:
}

#ifdef CONFIG_KSPACE
void
csys_exit(void) {
  8041606a59:	f3 0f 1e fa          	endbr64 
  8041606a5d:	55                   	push   %rbp
  8041606a5e:	48 89 e5             	mov    %rsp,%rbp
    if (!curenv) panic("curenv = NULL");
  8041606a61:	48 b8 c0 43 e4 41 80 	movabs $0x8041e443c0,%rax
  8041606a68:	00 00 00 
  8041606a6b:	48 8b 38             	mov    (%rax),%rdi
  8041606a6e:	48 85 ff             	test   %rdi,%rdi
  8041606a71:	74 0c                	je     8041606a7f <csys_exit+0x26>
    env_destroy(curenv);
  8041606a73:	48 b8 39 6a 60 41 80 	movabs $0x8041606a39,%rax
  8041606a7a:	00 00 00 
  8041606a7d:	ff d0                	call   *%rax
    if (!curenv) panic("curenv = NULL");
  8041606a7f:	48 ba a4 b1 60 41 80 	movabs $0x804160b1a4,%rdx
  8041606a86:	00 00 00 
  8041606a89:	be ec 01 00 00       	mov    $0x1ec,%esi
  8041606a8e:	48 bf 61 b1 60 41 80 	movabs $0x804160b161,%rdi
  8041606a95:	00 00 00 
  8041606a98:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606a9d:	48 b9 e3 03 60 41 80 	movabs $0x80416003e3,%rcx
  8041606aa4:	00 00 00 
  8041606aa7:	ff d1                	call   *%rcx

0000008041606aa9 <csys_yield>:
}

void
csys_yield(struct Trapframe *tf) {
  8041606aa9:	f3 0f 1e fa          	endbr64 
  8041606aad:	55                   	push   %rbp
  8041606aae:	48 89 e5             	mov    %rsp,%rbp
  8041606ab1:	48 89 fe             	mov    %rdi,%rsi
    memcpy(&curenv->env_tf, tf, sizeof(struct Trapframe));
  8041606ab4:	ba c0 00 00 00       	mov    $0xc0,%edx
  8041606ab9:	48 b8 c0 43 e4 41 80 	movabs $0x8041e443c0,%rax
  8041606ac0:	00 00 00 
  8041606ac3:	48 8b 38             	mov    (%rax),%rdi
  8041606ac6:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041606acd:	00 00 00 
  8041606ad0:	ff d0                	call   *%rax
    sched_yield();
  8041606ad2:	48 b8 2d 84 60 41 80 	movabs $0x804160842d,%rax
  8041606ad9:	00 00 00 
  8041606adc:	ff d0                	call   *%rax

0000008041606ade <env_pop_tf>:
 *
 * This function does not return.
 */

_Noreturn void
env_pop_tf(struct Trapframe *tf) {
  8041606ade:	f3 0f 1e fa          	endbr64 
  8041606ae2:	55                   	push   %rbp
  8041606ae3:	48 89 e5             	mov    %rsp,%rbp
    asm volatile(
  8041606ae6:	48 89 fc             	mov    %rdi,%rsp
  8041606ae9:	4c 8b 3c 24          	mov    (%rsp),%r15
  8041606aed:	4c 8b 74 24 08       	mov    0x8(%rsp),%r14
  8041606af2:	4c 8b 6c 24 10       	mov    0x10(%rsp),%r13
  8041606af7:	4c 8b 64 24 18       	mov    0x18(%rsp),%r12
  8041606afc:	4c 8b 5c 24 20       	mov    0x20(%rsp),%r11
  8041606b01:	4c 8b 54 24 28       	mov    0x28(%rsp),%r10
  8041606b06:	4c 8b 4c 24 30       	mov    0x30(%rsp),%r9
  8041606b0b:	4c 8b 44 24 38       	mov    0x38(%rsp),%r8
  8041606b10:	48 8b 74 24 40       	mov    0x40(%rsp),%rsi
  8041606b15:	48 8b 7c 24 48       	mov    0x48(%rsp),%rdi
  8041606b1a:	48 8b 6c 24 50       	mov    0x50(%rsp),%rbp
  8041606b1f:	48 8b 54 24 58       	mov    0x58(%rsp),%rdx
  8041606b24:	48 8b 4c 24 60       	mov    0x60(%rsp),%rcx
  8041606b29:	48 8b 5c 24 68       	mov    0x68(%rsp),%rbx
  8041606b2e:	48 8b 44 24 70       	mov    0x70(%rsp),%rax
  8041606b33:	8e 44 24 78          	mov    0x78(%rsp),%es
  8041606b37:	8e 9c 24 80 00 00 00 	mov    0x80(%rsp),%ds
  8041606b3e:	48 81 c4 98 00 00 00 	add    $0x98,%rsp
  8041606b45:	48 cf                	iretq  
            "addq $152,%%rsp\n" /* skip tf_trapno and tf_errcode */
            "iretq" ::"g"(tf)
            : "memory");

    /* Mostly to placate the compiler */
    panic("Reached unrecheble\n");
  8041606b47:	48 ba b2 b1 60 41 80 	movabs $0x804160b1b2,%rdx
  8041606b4e:	00 00 00 
  8041606b51:	be 17 02 00 00       	mov    $0x217,%esi
  8041606b56:	48 bf 61 b1 60 41 80 	movabs $0x804160b161,%rdi
  8041606b5d:	00 00 00 
  8041606b60:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606b65:	48 b9 e3 03 60 41 80 	movabs $0x80416003e3,%rcx
  8041606b6c:	00 00 00 
  8041606b6f:	ff d1                	call   *%rcx

0000008041606b71 <env_run>:
 *    env->env_tf.  Go back through the code you wrote above
 *    and make sure you have set the relevant parts of
 *    env->env_tf to sensible values.
 */
_Noreturn void
env_run(struct Env *env) {
  8041606b71:	f3 0f 1e fa          	endbr64 
  8041606b75:	55                   	push   %rbp
  8041606b76:	48 89 e5             	mov    %rsp,%rbp
    assert(env);
  8041606b79:	48 85 ff             	test   %rdi,%rdi
  8041606b7c:	74 42                	je     8041606bc0 <env_run+0x4f>
        cprintf("[%08X] env started: %s\n", env->env_id, state[env->env_status]);
    }

    // LAB 3: Your code here

    if(curenv != NULL){
  8041606b7e:	48 a1 c0 43 e4 41 80 	movabs 0x8041e443c0,%rax
  8041606b85:	00 00 00 
  8041606b88:	48 85 c0             	test   %rax,%rax
  8041606b8b:	74 09                	je     8041606b96 <env_run+0x25>
        if(curenv->env_status == ENV_RUNNING){
  8041606b8d:	83 b8 d4 00 00 00 03 	cmpl   $0x3,0xd4(%rax)
  8041606b94:	74 5f                	je     8041606bf5 <env_run+0x84>
            curenv->env_status = ENV_RUNNABLE;
        }
        // TODO: env_dying handling
    }
    
    curenv = env;
  8041606b96:	48 89 f8             	mov    %rdi,%rax
  8041606b99:	48 a3 c0 43 e4 41 80 	movabs %rax,0x8041e443c0
  8041606ba0:	00 00 00 
    curenv->env_status = ENV_RUNNING;
  8041606ba3:	c7 87 d4 00 00 00 03 	movl   $0x3,0xd4(%rdi)
  8041606baa:	00 00 00 
    curenv->env_runs++;
  8041606bad:	83 87 d8 00 00 00 01 	addl   $0x1,0xd8(%rdi)
    
    env_pop_tf(&(curenv->env_tf));
  8041606bb4:	48 b8 de 6a 60 41 80 	movabs $0x8041606ade,%rax
  8041606bbb:	00 00 00 
  8041606bbe:	ff d0                	call   *%rax
    assert(env);
  8041606bc0:	48 b9 7c b4 60 41 80 	movabs $0x804160b47c,%rcx
  8041606bc7:	00 00 00 
  8041606bca:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041606bd1:	00 00 00 
  8041606bd4:	be 31 02 00 00       	mov    $0x231,%esi
  8041606bd9:	48 bf 61 b1 60 41 80 	movabs $0x804160b161,%rdi
  8041606be0:	00 00 00 
  8041606be3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606be8:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041606bef:	00 00 00 
  8041606bf2:	41 ff d0             	call   *%r8
            curenv->env_status = ENV_RUNNABLE;
  8041606bf5:	c7 80 d4 00 00 00 02 	movl   $0x2,0xd4(%rax)
  8041606bfc:	00 00 00 
  8041606bff:	eb 95                	jmp    8041606b96 <env_run+0x25>

0000008041606c01 <rtc_timer_pic_interrupt>:
cmos_read16(uint8_t reg) {
    return cmos_read8(reg) | (cmos_read8(reg + 1) << 8);
}

static void
rtc_timer_pic_interrupt(void) {
  8041606c01:	f3 0f 1e fa          	endbr64 
  8041606c05:	55                   	push   %rbp
  8041606c06:	48 89 e5             	mov    %rsp,%rbp
    // LAB 4: Your code here
    // Enable PIC interrupts.
    pic_irq_unmask(IRQ_CLOCK);
  8041606c09:	bf 08 00 00 00       	mov    $0x8,%edi
  8041606c0e:	48 b8 e7 6e 60 41 80 	movabs $0x8041606ee7,%rax
  8041606c15:	00 00 00 
  8041606c18:	ff d0                	call   *%rax
}
  8041606c1a:	5d                   	pop    %rbp
  8041606c1b:	c3                   	ret    

0000008041606c1c <cmos_read8>:
cmos_read8(uint8_t reg) {
  8041606c1c:	f3 0f 1e fa          	endbr64 
    asm volatile("inb %w1,%0"
  8041606c20:	b9 70 00 00 00       	mov    $0x70,%ecx
  8041606c25:	89 ca                	mov    %ecx,%edx
  8041606c27:	ec                   	in     (%dx),%al
    outb(CMOS_CMD, inb(CMOS_CMD) & ~CMOS_NMI_LOCK);
}

static inline void __attribute__((always_inline))
nmi_disable(void) {
    outb(CMOS_CMD, inb(CMOS_CMD) | CMOS_NMI_LOCK);
  8041606c28:	83 c8 80             	or     $0xffffff80,%eax
    asm volatile("outb %0,%w1" ::"a"(data), "d"(port));
  8041606c2b:	ee                   	out    %al,(%dx)
  8041606c2c:	89 f8                	mov    %edi,%eax
  8041606c2e:	ee                   	out    %al,(%dx)
    asm volatile("inb %w1,%0"
  8041606c2f:	ba 71 00 00 00       	mov    $0x71,%edx
  8041606c34:	ec                   	in     (%dx),%al
  8041606c35:	89 c6                	mov    %eax,%esi
  8041606c37:	89 ca                	mov    %ecx,%edx
  8041606c39:	ec                   	in     (%dx),%al
    asm volatile("outb %0,%w1" ::"a"(data), "d"(port));
  8041606c3a:	83 e0 7f             	and    $0x7f,%eax
  8041606c3d:	ee                   	out    %al,(%dx)
}
  8041606c3e:	89 f0                	mov    %esi,%eax
  8041606c40:	c3                   	ret    

0000008041606c41 <cmos_write8>:
cmos_write8(uint8_t reg, uint8_t value) {
  8041606c41:	f3 0f 1e fa          	endbr64 
    asm volatile("inb %w1,%0"
  8041606c45:	b9 70 00 00 00       	mov    $0x70,%ecx
  8041606c4a:	89 ca                	mov    %ecx,%edx
  8041606c4c:	ec                   	in     (%dx),%al
    outb(CMOS_CMD, inb(CMOS_CMD) | CMOS_NMI_LOCK);
  8041606c4d:	83 c8 80             	or     $0xffffff80,%eax
    asm volatile("outb %0,%w1" ::"a"(data), "d"(port));
  8041606c50:	ee                   	out    %al,(%dx)
  8041606c51:	89 f8                	mov    %edi,%eax
  8041606c53:	ee                   	out    %al,(%dx)
  8041606c54:	ba 71 00 00 00       	mov    $0x71,%edx
  8041606c59:	89 f0                	mov    %esi,%eax
  8041606c5b:	ee                   	out    %al,(%dx)
    asm volatile("inb %w1,%0"
  8041606c5c:	89 ca                	mov    %ecx,%edx
  8041606c5e:	ec                   	in     (%dx),%al
    asm volatile("outb %0,%w1" ::"a"(data), "d"(port));
  8041606c5f:	83 e0 7f             	and    $0x7f,%eax
  8041606c62:	ee                   	out    %al,(%dx)
}
  8041606c63:	c3                   	ret    

0000008041606c64 <rtc_timer_init>:
        .enable_interrupts = rtc_timer_pic_interrupt,
        .handle_interrupts = rtc_timer_pic_handle,
};

void
rtc_timer_init(void) {
  8041606c64:	f3 0f 1e fa          	endbr64 
  8041606c68:	55                   	push   %rbp
  8041606c69:	48 89 e5             	mov    %rsp,%rbp
  8041606c6c:	41 54                	push   %r12
  8041606c6e:	53                   	push   %rbx
    // LAB 4: Your code here
    // (use cmos_read8/cmos_write8)

    cmos_write8(RTC_AREG, (cmos_read8(RTC_AREG) & 0xF0) | 0x0F);
  8041606c6f:	bf 0a 00 00 00       	mov    $0xa,%edi
  8041606c74:	49 bc 1c 6c 60 41 80 	movabs $0x8041606c1c,%r12
  8041606c7b:	00 00 00 
  8041606c7e:	41 ff d4             	call   *%r12
  8041606c81:	83 c8 0f             	or     $0xf,%eax
  8041606c84:	0f b6 f0             	movzbl %al,%esi
  8041606c87:	bf 0a 00 00 00       	mov    $0xa,%edi
  8041606c8c:	48 bb 41 6c 60 41 80 	movabs $0x8041606c41,%rbx
  8041606c93:	00 00 00 
  8041606c96:	ff d3                	call   *%rbx
    cmos_write8(RTC_BREG, cmos_read8(RTC_BREG) | RTC_PIE);
  8041606c98:	bf 0b 00 00 00       	mov    $0xb,%edi
  8041606c9d:	41 ff d4             	call   *%r12
  8041606ca0:	83 c8 40             	or     $0x40,%eax
  8041606ca3:	0f b6 f0             	movzbl %al,%esi
  8041606ca6:	bf 0b 00 00 00       	mov    $0xb,%edi
  8041606cab:	ff d3                	call   *%rbx
}
  8041606cad:	5b                   	pop    %rbx
  8041606cae:	41 5c                	pop    %r12
  8041606cb0:	5d                   	pop    %rbp
  8041606cb1:	c3                   	ret    

0000008041606cb2 <cmos_read16>:
cmos_read16(uint8_t reg) {
  8041606cb2:	f3 0f 1e fa          	endbr64 
  8041606cb6:	55                   	push   %rbp
  8041606cb7:	48 89 e5             	mov    %rsp,%rbp
  8041606cba:	41 55                	push   %r13
  8041606cbc:	41 54                	push   %r12
  8041606cbe:	53                   	push   %rbx
  8041606cbf:	48 83 ec 08          	sub    $0x8,%rsp
  8041606cc3:	89 fb                	mov    %edi,%ebx
    return cmos_read8(reg) | (cmos_read8(reg + 1) << 8);
  8041606cc5:	40 0f b6 ff          	movzbl %dil,%edi
  8041606cc9:	49 bd 1c 6c 60 41 80 	movabs $0x8041606c1c,%r13
  8041606cd0:	00 00 00 
  8041606cd3:	41 ff d5             	call   *%r13
  8041606cd6:	41 89 c4             	mov    %eax,%r12d
  8041606cd9:	8d 7b 01             	lea    0x1(%rbx),%edi
  8041606cdc:	40 0f b6 ff          	movzbl %dil,%edi
  8041606ce0:	41 ff d5             	call   *%r13
  8041606ce3:	c1 e0 08             	shl    $0x8,%eax
  8041606ce6:	45 0f b6 e4          	movzbl %r12b,%r12d
  8041606cea:	44 09 e0             	or     %r12d,%eax
}
  8041606ced:	48 83 c4 08          	add    $0x8,%rsp
  8041606cf1:	5b                   	pop    %rbx
  8041606cf2:	41 5c                	pop    %r12
  8041606cf4:	41 5d                	pop    %r13
  8041606cf6:	5d                   	pop    %rbp
  8041606cf7:	c3                   	ret    

0000008041606cf8 <rtc_check_status>:

uint8_t
rtc_check_status(void) {
  8041606cf8:	f3 0f 1e fa          	endbr64 
  8041606cfc:	55                   	push   %rbp
  8041606cfd:	48 89 e5             	mov    %rsp,%rbp
    // LAB 4: Your code here
    // (use cmos_read8)

    return cmos_read8(RTC_CREG);
  8041606d00:	bf 0c 00 00 00       	mov    $0xc,%edi
  8041606d05:	48 b8 1c 6c 60 41 80 	movabs $0x8041606c1c,%rax
  8041606d0c:	00 00 00 
  8041606d0f:	ff d0                	call   *%rax
}
  8041606d11:	5d                   	pop    %rbp
  8041606d12:	c3                   	ret    

0000008041606d13 <rtc_timer_pic_handle>:
rtc_timer_pic_handle(void) {
  8041606d13:	f3 0f 1e fa          	endbr64 
  8041606d17:	55                   	push   %rbp
  8041606d18:	48 89 e5             	mov    %rsp,%rbp
    rtc_check_status();
  8041606d1b:	48 b8 f8 6c 60 41 80 	movabs $0x8041606cf8,%rax
  8041606d22:	00 00 00 
  8041606d25:	ff d0                	call   *%rax
    pic_send_eoi(IRQ_CLOCK);
  8041606d27:	bf 08 00 00 00       	mov    $0x8,%edi
  8041606d2c:	48 b8 39 6f 60 41 80 	movabs $0x8041606f39,%rax
  8041606d33:	00 00 00 
  8041606d36:	ff d0                	call   *%rax
}
  8041606d38:	5d                   	pop    %rbp
  8041606d39:	c3                   	ret    

0000008041606d3a <print_irq_mask>:
    outb(IO_PIC1_DATA, (uint8_t)mask);
    outb(IO_PIC2_DATA, (uint8_t)(mask >> 8));
}

static void
print_irq_mask(uint16_t mask) {
  8041606d3a:	f3 0f 1e fa          	endbr64 
  8041606d3e:	55                   	push   %rbp
  8041606d3f:	48 89 e5             	mov    %rsp,%rbp
  8041606d42:	41 56                	push   %r14
  8041606d44:	41 55                	push   %r13
  8041606d46:	41 54                	push   %r12
  8041606d48:	53                   	push   %rbx
  8041606d49:	41 89 fc             	mov    %edi,%r12d
    cprintf("enabled interrupts:");
  8041606d4c:	48 bf 24 b2 60 41 80 	movabs $0x804160b224,%rdi
  8041606d53:	00 00 00 
  8041606d56:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606d5b:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  8041606d62:	00 00 00 
  8041606d65:	ff d2                	call   *%rdx
    for (int i = 0; i < 16; i++) {
  8041606d67:	bb 00 00 00 00       	mov    $0x0,%ebx
        if (~mask & (1 << i))
  8041606d6c:	45 0f b7 e4          	movzwl %r12w,%r12d
  8041606d70:	41 f7 d4             	not    %r12d
            cprintf(" %d", i);
  8041606d73:	49 be 3f bc 60 41 80 	movabs $0x804160bc3f,%r14
  8041606d7a:	00 00 00 
  8041606d7d:	49 bd b7 6f 60 41 80 	movabs $0x8041606fb7,%r13
  8041606d84:	00 00 00 
  8041606d87:	eb 08                	jmp    8041606d91 <print_irq_mask+0x57>
    for (int i = 0; i < 16; i++) {
  8041606d89:	83 c3 01             	add    $0x1,%ebx
  8041606d8c:	83 fb 10             	cmp    $0x10,%ebx
  8041606d8f:	74 15                	je     8041606da6 <print_irq_mask+0x6c>
        if (~mask & (1 << i))
  8041606d91:	41 0f a3 dc          	bt     %ebx,%r12d
  8041606d95:	73 f2                	jae    8041606d89 <print_irq_mask+0x4f>
            cprintf(" %d", i);
  8041606d97:	89 de                	mov    %ebx,%esi
  8041606d99:	4c 89 f7             	mov    %r14,%rdi
  8041606d9c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606da1:	41 ff d5             	call   *%r13
  8041606da4:	eb e3                	jmp    8041606d89 <print_irq_mask+0x4f>
    }
    cprintf("\n");
  8041606da6:	48 bf f0 a1 60 41 80 	movabs $0x804160a1f0,%rdi
  8041606dad:	00 00 00 
  8041606db0:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606db5:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  8041606dbc:	00 00 00 
  8041606dbf:	ff d2                	call   *%rdx
}
  8041606dc1:	5b                   	pop    %rbx
  8041606dc2:	41 5c                	pop    %r12
  8041606dc4:	41 5d                	pop    %r13
  8041606dc6:	41 5e                	pop    %r14
  8041606dc8:	5d                   	pop    %rbp
  8041606dc9:	c3                   	ret    

0000008041606dca <pic_init>:


/* Initialize the 8259A interrupt controllers. */
void
pic_init(void) {
  8041606dca:	f3 0f 1e fa          	endbr64 
  8041606dce:	55                   	push   %rbp
  8041606dcf:	48 89 e5             	mov    %rsp,%rbp
  8041606dd2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8041606dd7:	be 21 00 00 00       	mov    $0x21,%esi
  8041606ddc:	89 f2                	mov    %esi,%edx
  8041606dde:	ee                   	out    %al,(%dx)
  8041606ddf:	b9 a1 00 00 00       	mov    $0xa1,%ecx
  8041606de4:	89 ca                	mov    %ecx,%edx
  8041606de6:	ee                   	out    %al,(%dx)
  8041606de7:	41 b9 11 00 00 00    	mov    $0x11,%r9d
  8041606ded:	bf 20 00 00 00       	mov    $0x20,%edi
  8041606df2:	44 89 c8             	mov    %r9d,%eax
  8041606df5:	89 fa                	mov    %edi,%edx
  8041606df7:	ee                   	out    %al,(%dx)
  8041606df8:	b8 20 00 00 00       	mov    $0x20,%eax
  8041606dfd:	89 f2                	mov    %esi,%edx
  8041606dff:	ee                   	out    %al,(%dx)
  8041606e00:	b8 04 00 00 00       	mov    $0x4,%eax
  8041606e05:	ee                   	out    %al,(%dx)
  8041606e06:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  8041606e0c:	44 89 c0             	mov    %r8d,%eax
  8041606e0f:	ee                   	out    %al,(%dx)
  8041606e10:	be a0 00 00 00       	mov    $0xa0,%esi
  8041606e15:	44 89 c8             	mov    %r9d,%eax
  8041606e18:	89 f2                	mov    %esi,%edx
  8041606e1a:	ee                   	out    %al,(%dx)
  8041606e1b:	b8 28 00 00 00       	mov    $0x28,%eax
  8041606e20:	89 ca                	mov    %ecx,%edx
  8041606e22:	ee                   	out    %al,(%dx)
  8041606e23:	b8 02 00 00 00       	mov    $0x2,%eax
  8041606e28:	ee                   	out    %al,(%dx)
  8041606e29:	44 89 c0             	mov    %r8d,%eax
  8041606e2c:	ee                   	out    %al,(%dx)
  8041606e2d:	41 b8 68 00 00 00    	mov    $0x68,%r8d
  8041606e33:	44 89 c0             	mov    %r8d,%eax
  8041606e36:	89 fa                	mov    %edi,%edx
  8041606e38:	ee                   	out    %al,(%dx)
  8041606e39:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8041606e3e:	89 c8                	mov    %ecx,%eax
  8041606e40:	ee                   	out    %al,(%dx)
  8041606e41:	44 89 c0             	mov    %r8d,%eax
  8041606e44:	89 f2                	mov    %esi,%edx
  8041606e46:	ee                   	out    %al,(%dx)
  8041606e47:	89 c8                	mov    %ecx,%eax
  8041606e49:	ee                   	out    %al,(%dx)

    /* OCW3 */
    outb(IO_PIC2_CMND, OCW3 | OCW3_SET);
    outb(IO_PIC2_CMND, OCW3 | OCW3_IRR);

    pic_initilalized = 1;
  8041606e4a:	48 b8 d0 43 e4 41 80 	movabs $0x8041e443d0,%rax
  8041606e51:	00 00 00 
  8041606e54:	c6 00 01             	movb   $0x1,(%rax)

    if (irq_mask_8259A != 0xFFFF)
  8041606e57:	48 b8 68 d7 62 41 80 	movabs $0x804162d768,%rax
  8041606e5e:	00 00 00 
  8041606e61:	66 8b 38             	mov    (%rax),%di
  8041606e64:	66 83 ff ff          	cmp    $0xffff,%di
  8041606e68:	75 11                	jne    8041606e7b <pic_init+0xb1>
        set_irq_mask(irq_mask_8259A);
    print_irq_mask(irq_mask_8259A);
  8041606e6a:	0f b7 ff             	movzwl %di,%edi
  8041606e6d:	48 b8 3a 6d 60 41 80 	movabs $0x8041606d3a,%rax
  8041606e74:	00 00 00 
  8041606e77:	ff d0                	call   *%rax
}
  8041606e79:	5d                   	pop    %rbp
  8041606e7a:	c3                   	ret    
  8041606e7b:	ba 21 00 00 00       	mov    $0x21,%edx
  8041606e80:	89 f8                	mov    %edi,%eax
  8041606e82:	ee                   	out    %al,(%dx)
    outb(IO_PIC2_DATA, (uint8_t)(mask >> 8));
  8041606e83:	89 f8                	mov    %edi,%eax
  8041606e85:	66 c1 e8 08          	shr    $0x8,%ax
  8041606e89:	ba a1 00 00 00       	mov    $0xa1,%edx
  8041606e8e:	ee                   	out    %al,(%dx)
}
  8041606e8f:	eb d9                	jmp    8041606e6a <pic_init+0xa0>

0000008041606e91 <pic_irq_mask>:

void
pic_irq_mask(uint8_t irq) {
  8041606e91:	f3 0f 1e fa          	endbr64 
  8041606e95:	89 f9                	mov    %edi,%ecx
    irq_mask_8259A |= (1 << irq);
  8041606e97:	48 b8 68 d7 62 41 80 	movabs $0x804162d768,%rax
  8041606e9e:	00 00 00 
  8041606ea1:	bf 01 00 00 00       	mov    $0x1,%edi
  8041606ea6:	d3 e7                	shl    %cl,%edi
  8041606ea8:	66 0b 38             	or     (%rax),%di
  8041606eab:	66 89 38             	mov    %di,(%rax)
    if (pic_initilalized) {
  8041606eae:	48 b8 d0 43 e4 41 80 	movabs $0x8041e443d0,%rax
  8041606eb5:	00 00 00 
  8041606eb8:	80 38 00             	cmpb   $0x0,(%rax)
  8041606ebb:	75 01                	jne    8041606ebe <pic_irq_mask+0x2d>
  8041606ebd:	c3                   	ret    
pic_irq_mask(uint8_t irq) {
  8041606ebe:	55                   	push   %rbp
  8041606ebf:	48 89 e5             	mov    %rsp,%rbp
  8041606ec2:	ba 21 00 00 00       	mov    $0x21,%edx
  8041606ec7:	89 f8                	mov    %edi,%eax
  8041606ec9:	ee                   	out    %al,(%dx)
    outb(IO_PIC2_DATA, (uint8_t)(mask >> 8));
  8041606eca:	89 f8                	mov    %edi,%eax
  8041606ecc:	66 c1 e8 08          	shr    $0x8,%ax
  8041606ed0:	ba a1 00 00 00       	mov    $0xa1,%edx
  8041606ed5:	ee                   	out    %al,(%dx)
        set_irq_mask(irq_mask_8259A);
  8041606ed6:	0f b7 ff             	movzwl %di,%edi
        print_irq_mask(irq_mask_8259A);
  8041606ed9:	48 b8 3a 6d 60 41 80 	movabs $0x8041606d3a,%rax
  8041606ee0:	00 00 00 
  8041606ee3:	ff d0                	call   *%rax
    }
}
  8041606ee5:	5d                   	pop    %rbp
  8041606ee6:	c3                   	ret    

0000008041606ee7 <pic_irq_unmask>:

void
pic_irq_unmask(uint8_t irq) {
  8041606ee7:	f3 0f 1e fa          	endbr64 
  8041606eeb:	89 fa                	mov    %edi,%edx
    irq_mask_8259A &= ~(1 << irq);
  8041606eed:	48 b8 68 d7 62 41 80 	movabs $0x804162d768,%rax
  8041606ef4:	00 00 00 
  8041606ef7:	0f b7 38             	movzwl (%rax),%edi
  8041606efa:	0f b3 d7             	btr    %edx,%edi
  8041606efd:	66 89 38             	mov    %di,(%rax)
    if (pic_initilalized) {
  8041606f00:	48 b8 d0 43 e4 41 80 	movabs $0x8041e443d0,%rax
  8041606f07:	00 00 00 
  8041606f0a:	80 38 00             	cmpb   $0x0,(%rax)
  8041606f0d:	75 01                	jne    8041606f10 <pic_irq_unmask+0x29>
  8041606f0f:	c3                   	ret    
pic_irq_unmask(uint8_t irq) {
  8041606f10:	55                   	push   %rbp
  8041606f11:	48 89 e5             	mov    %rsp,%rbp
  8041606f14:	ba 21 00 00 00       	mov    $0x21,%edx
  8041606f19:	89 f8                	mov    %edi,%eax
  8041606f1b:	ee                   	out    %al,(%dx)
    outb(IO_PIC2_DATA, (uint8_t)(mask >> 8));
  8041606f1c:	89 f8                	mov    %edi,%eax
  8041606f1e:	66 c1 e8 08          	shr    $0x8,%ax
  8041606f22:	ba a1 00 00 00       	mov    $0xa1,%edx
  8041606f27:	ee                   	out    %al,(%dx)
        set_irq_mask(irq_mask_8259A);
  8041606f28:	0f b7 ff             	movzwl %di,%edi
        print_irq_mask(irq_mask_8259A);
  8041606f2b:	48 b8 3a 6d 60 41 80 	movabs $0x8041606d3a,%rax
  8041606f32:	00 00 00 
  8041606f35:	ff d0                	call   *%rax
    }
}
  8041606f37:	5d                   	pop    %rbp
  8041606f38:	c3                   	ret    

0000008041606f39 <pic_send_eoi>:

void
pic_send_eoi(uint8_t irq) {
  8041606f39:	f3 0f 1e fa          	endbr64 
    if (irq > 7) outb(IO_PIC2_CMND, PIC_EOI);
  8041606f3d:	40 80 ff 07          	cmp    $0x7,%dil
  8041606f41:	76 0b                	jbe    8041606f4e <pic_send_eoi+0x15>
  8041606f43:	b8 20 00 00 00       	mov    $0x20,%eax
  8041606f48:	ba a0 00 00 00       	mov    $0xa0,%edx
  8041606f4d:	ee                   	out    %al,(%dx)
  8041606f4e:	b8 20 00 00 00       	mov    $0x20,%eax
  8041606f53:	ba 20 00 00 00       	mov    $0x20,%edx
  8041606f58:	ee                   	out    %al,(%dx)
    outb(IO_PIC1_CMND, PIC_EOI);
}
  8041606f59:	c3                   	ret    

0000008041606f5a <putch>:
#include <inc/types.h>
#include <inc/stdio.h>
#include <inc/stdarg.h>

static void
putch(int ch, int *cnt) {
  8041606f5a:	f3 0f 1e fa          	endbr64 
  8041606f5e:	55                   	push   %rbp
  8041606f5f:	48 89 e5             	mov    %rsp,%rbp
  8041606f62:	53                   	push   %rbx
  8041606f63:	48 83 ec 08          	sub    $0x8,%rsp
  8041606f67:	48 89 f3             	mov    %rsi,%rbx
    cputchar(ch);
  8041606f6a:	48 b8 f8 0d 60 41 80 	movabs $0x8041600df8,%rax
  8041606f71:	00 00 00 
  8041606f74:	ff d0                	call   *%rax
    (*cnt)++;
  8041606f76:	83 03 01             	addl   $0x1,(%rbx)
}
  8041606f79:	48 8b 5d f8          	mov    -0x8(%rbp),%rbx
  8041606f7d:	c9                   	leave  
  8041606f7e:	c3                   	ret    

0000008041606f7f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8041606f7f:	f3 0f 1e fa          	endbr64 
  8041606f83:	55                   	push   %rbp
  8041606f84:	48 89 e5             	mov    %rsp,%rbp
  8041606f87:	48 83 ec 10          	sub    $0x10,%rsp
  8041606f8b:	48 89 fa             	mov    %rdi,%rdx
  8041606f8e:	48 89 f1             	mov    %rsi,%rcx
    int count = 0;
  8041606f91:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)

    vprintfmt((void *)putch, &count, fmt, ap);
  8041606f98:	48 8d 75 fc          	lea    -0x4(%rbp),%rsi
  8041606f9c:	48 bf 5a 6f 60 41 80 	movabs $0x8041606f5a,%rdi
  8041606fa3:	00 00 00 
  8041606fa6:	48 b8 5d 8a 60 41 80 	movabs $0x8041608a5d,%rax
  8041606fad:	00 00 00 
  8041606fb0:	ff d0                	call   *%rax

    return count;
}
  8041606fb2:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8041606fb5:	c9                   	leave  
  8041606fb6:	c3                   	ret    

0000008041606fb7 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8041606fb7:	f3 0f 1e fa          	endbr64 
  8041606fbb:	55                   	push   %rbp
  8041606fbc:	48 89 e5             	mov    %rsp,%rbp
  8041606fbf:	48 83 ec 50          	sub    $0x50,%rsp
  8041606fc3:	48 89 75 d8          	mov    %rsi,-0x28(%rbp)
  8041606fc7:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
  8041606fcb:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  8041606fcf:	4c 89 45 f0          	mov    %r8,-0x10(%rbp)
  8041606fd3:	4c 89 4d f8          	mov    %r9,-0x8(%rbp)
    va_list ap;
    va_start(ap, fmt);
  8041606fd7:	c7 45 b8 08 00 00 00 	movl   $0x8,-0x48(%rbp)
  8041606fde:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8041606fe2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041606fe6:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  8041606fea:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    int res = vcprintf(fmt, ap);
  8041606fee:	48 8d 75 b8          	lea    -0x48(%rbp),%rsi
  8041606ff2:	48 b8 7f 6f 60 41 80 	movabs $0x8041606f7f,%rax
  8041606ff9:	00 00 00 
  8041606ffc:	ff d0                	call   *%rax
    va_end(ap);

    return res;
}
  8041606ffe:	c9                   	leave  
  8041606fff:	c3                   	ret    

0000008041607000 <trap_init_percpu>:
    trap_init_percpu();
}

/* Initialize and load the per-CPU TSS and IDT */
void
trap_init_percpu(void) {
  8041607000:	f3 0f 1e fa          	endbr64 
    asm volatile("lgdt (%0)" ::"r"(p));
  8041607004:	48 b8 80 d7 62 41 80 	movabs $0x804162d780,%rax
  804160700b:	00 00 00 
  804160700e:	0f 01 10             	lgdt   (%rax)
    /* The kernel never uses GS or FS,
     * so we leave those set to the user data segment
     *
     * For good measure, clear the local descriptor table (LDT),
     * since we don't use it */
    asm volatile(
  8041607011:	b8 10 00 00 00       	mov    $0x10,%eax
  8041607016:	ba 33 00 00 00       	mov    $0x33,%edx
  804160701b:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041607020:	8e ea                	mov    %edx,%gs
  8041607022:	8e e2                	mov    %edx,%fs
  8041607024:	8e c0                	mov    %eax,%es
  8041607026:	8e d8                	mov    %eax,%ds
  8041607028:	8e d0                	mov    %eax,%ss
  804160702a:	31 c0                	xor    %eax,%eax
  804160702c:	0f 00 d0             	lldt   %ax
  804160702f:	51                   	push   %rcx
  8041607030:	48 b8 3d 70 60 41 80 	movabs $0x804160703d,%rax
  8041607037:	00 00 00 
  804160703a:	50                   	push   %rax
  804160703b:	48 cb                	lretq  
            "d"(GD_UD | 3), "c"(GD_KT)
            : "cc", "memory");

    /* Setup a TSS so that we get the right stack
     * when we trap to the kernel. */
    ts.ts_rsp0 = KERN_STACK_TOP;
  804160703d:	48 ba 00 54 e4 41 80 	movabs $0x8041e45400,%rdx
  8041607044:	00 00 00 
  8041607047:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  804160704e:	00 00 00 
  8041607051:	48 89 42 04          	mov    %rax,0x4(%rdx)
    ts.ts_ist1 = KERN_PF_STACK_TOP;
  8041607055:	48 8d 80 00 80 fe ff 	lea    -0x18000(%rax),%rax
  804160705c:	48 89 42 24          	mov    %rax,0x24(%rdx)

    /* Initialize the TSS slot of the gdt. */
    *(volatile struct Segdesc64 *)(&gdt[(GD_TSS0 >> 3)]) = SEG64_TSS(STS_T64A, ((uint64_t)&ts), sizeof(struct Taskstate), 0);
  8041607060:	be 00 00 00 00       	mov    $0x0,%esi
  8041607065:	bf 00 00 00 00       	mov    $0x0,%edi
  804160706a:	48 89 f0             	mov    %rsi,%rax
  804160706d:	66 b8 00 00          	mov    $0x0,%ax
  8041607071:	48 83 c8 68          	or     $0x68,%rax
  8041607075:	0f b7 ca             	movzwl %dx,%ecx
  8041607078:	48 c1 e1 10          	shl    $0x10,%rcx
  804160707c:	49 b8 ff ff 00 00 ff 	movabs $0xffffffff0000ffff,%r8
  8041607083:	ff ff ff 
  8041607086:	4c 21 c0             	and    %r8,%rax
  8041607089:	48 09 c8             	or     %rcx,%rax
  804160708c:	49 89 d0             	mov    %rdx,%r8
  804160708f:	49 c1 e8 10          	shr    $0x10,%r8
  8041607093:	45 0f b6 c0          	movzbl %r8b,%r8d
  8041607097:	49 c1 e0 20          	shl    $0x20,%r8
  804160709b:	48 b9 ff ff ff ff 00 	movabs $0xffffff00ffffffff,%rcx
  80416070a2:	ff ff ff 
  80416070a5:	48 21 c8             	and    %rcx,%rax
  80416070a8:	4c 09 c0             	or     %r8,%rax
  80416070ab:	49 b8 ff ff ff ff ff 	movabs $0xfffff0ffffffffff,%r8
  80416070b2:	f0 ff ff 
  80416070b5:	4c 21 c0             	and    %r8,%rax
  80416070b8:	49 b8 00 00 00 00 00 	movabs $0x90000000000,%r8
  80416070bf:	09 00 00 
  80416070c2:	4c 09 c0             	or     %r8,%rax
  80416070c5:	48 0f ba f0 2c       	btr    $0x2c,%rax
  80416070ca:	49 b8 ff ff ff ff ff 	movabs $0xffff9fffffffffff,%r8
  80416070d1:	9f ff ff 
  80416070d4:	4c 21 c0             	and    %r8,%rax
  80416070d7:	48 0f ba e8 2f       	bts    $0x2f,%rax
  80416070dc:	49 b8 ff ff ff ff ff 	movabs $0xfff0ffffffffffff,%r8
  80416070e3:	ff f0 ff 
  80416070e6:	4c 21 c0             	and    %r8,%rax
  80416070e9:	48 0f ba f0 34       	btr    $0x34,%rax
  80416070ee:	49 b8 ff ff ff ff ff 	movabs $0xff9fffffffffffff,%r8
  80416070f5:	ff 9f ff 
  80416070f8:	4c 21 c0             	and    %r8,%rax
  80416070fb:	48 0f ba f0 37       	btr    $0x37,%rax
  8041607100:	49 89 d0             	mov    %rdx,%r8
  8041607103:	49 c1 e8 18          	shr    $0x18,%r8
  8041607107:	49 c1 e0 38          	shl    $0x38,%r8
  804160710b:	49 b9 ff ff ff ff ff 	movabs $0xffffffffffffff,%r9
  8041607112:	ff ff 00 
  8041607115:	4c 21 c8             	and    %r9,%rax
  8041607118:	4c 09 c0             	or     %r8,%rax
  804160711b:	48 89 c6             	mov    %rax,%rsi
  804160711e:	48 89 d0             	mov    %rdx,%rax
  8041607121:	48 c1 e8 20          	shr    $0x20,%rax
  8041607125:	48 89 fa             	mov    %rdi,%rdx
  8041607128:	49 b8 00 00 00 00 ff 	movabs $0xffffffff00000000,%r8
  804160712f:	ff ff ff 
  8041607132:	4c 21 c2             	and    %r8,%rdx
  8041607135:	48 09 c2             	or     %rax,%rdx
  8041607138:	48 21 ca             	and    %rcx,%rdx
  804160713b:	48 b8 ff ff ff ff ff 	movabs $0xffff00ffffffffff,%rax
  8041607142:	00 ff ff 
  8041607145:	48 21 c2             	and    %rax,%rdx
  8041607148:	89 d7                	mov    %edx,%edi
  804160714a:	48 b8 a0 d7 62 41 80 	movabs $0x804162d7a0,%rax
  8041607151:	00 00 00 
  8041607154:	48 89 70 38          	mov    %rsi,0x38(%rax)
  8041607158:	48 89 78 40          	mov    %rdi,0x40(%rax)
    asm volatile("ltr %0" ::"r"(sel));
  804160715c:	b8 38 00 00 00       	mov    $0x38,%eax
  8041607161:	0f 00 d8             	ltr    %ax
    asm volatile("lidt (%0)" ::"r"(p));
  8041607164:	48 b8 e8 d7 62 41 80 	movabs $0x804162d7e8,%rax
  804160716b:	00 00 00 
  804160716e:	0f 01 18             	lidt   (%rax)
     * bottom three bits are special; we leave them 0) */
    ltr(GD_TSS0);

    /* Load the IDT */
    lidt(&idt_pd);
}
  8041607171:	c3                   	ret    

0000008041607172 <trap_init>:
trap_init(void) {
  8041607172:	f3 0f 1e fa          	endbr64 
  8041607176:	55                   	push   %rbp
  8041607177:	48 89 e5             	mov    %rsp,%rbp
    idt[IRQ_OFFSET + IRQ_TIMER] = GATE(0, GD_KT, timer_thdlr, 0);
  804160717a:	48 b8 e0 43 e4 41 80 	movabs $0x8041e443e0,%rax
  8041607181:	00 00 00 
  8041607184:	48 ba b1 77 60 41 80 	movabs $0x80416077b1,%rdx
  804160718b:	00 00 00 
  804160718e:	66 89 90 00 02 00 00 	mov    %dx,0x200(%rax)
  8041607195:	66 c7 80 02 02 00 00 	movw   $0x8,0x202(%rax)
  804160719c:	08 00 
  804160719e:	c6 80 04 02 00 00 00 	movb   $0x0,0x204(%rax)
  80416071a5:	c6 80 05 02 00 00 8e 	movb   $0x8e,0x205(%rax)
  80416071ac:	48 89 d1             	mov    %rdx,%rcx
  80416071af:	48 c1 e9 10          	shr    $0x10,%rcx
  80416071b3:	66 89 88 06 02 00 00 	mov    %cx,0x206(%rax)
  80416071ba:	48 c1 ea 20          	shr    $0x20,%rdx
  80416071be:	89 90 08 02 00 00    	mov    %edx,0x208(%rax)
  80416071c4:	c7 80 0c 02 00 00 00 	movl   $0x0,0x20c(%rax)
  80416071cb:	00 00 00 
    idt[IRQ_OFFSET + IRQ_CLOCK] = GATE(0, GD_KT, clock_thdlr, 0);
  80416071ce:	48 ba 99 77 60 41 80 	movabs $0x8041607799,%rdx
  80416071d5:	00 00 00 
  80416071d8:	66 89 90 80 02 00 00 	mov    %dx,0x280(%rax)
  80416071df:	66 c7 80 82 02 00 00 	movw   $0x8,0x282(%rax)
  80416071e6:	08 00 
  80416071e8:	c6 80 84 02 00 00 00 	movb   $0x0,0x284(%rax)
  80416071ef:	c6 80 85 02 00 00 8e 	movb   $0x8e,0x285(%rax)
  80416071f6:	48 89 d1             	mov    %rdx,%rcx
  80416071f9:	48 c1 e9 10          	shr    $0x10,%rcx
  80416071fd:	66 89 88 86 02 00 00 	mov    %cx,0x286(%rax)
  8041607204:	48 c1 ea 20          	shr    $0x20,%rdx
  8041607208:	89 90 88 02 00 00    	mov    %edx,0x288(%rax)
  804160720e:	c7 80 8c 02 00 00 00 	movl   $0x0,0x28c(%rax)
  8041607215:	00 00 00 
    trap_init_percpu();
  8041607218:	48 b8 00 70 60 41 80 	movabs $0x8041607000,%rax
  804160721f:	00 00 00 
  8041607222:	ff d0                	call   *%rax
}
  8041607224:	5d                   	pop    %rbp
  8041607225:	c3                   	ret    

0000008041607226 <print_regs>:
    cprintf("  rsp  0x%08lx\n", (unsigned long)tf->tf_rsp);
    cprintf("  ss   0x----%04x\n", tf->tf_ss);
}

void
print_regs(struct PushRegs *regs) {
  8041607226:	f3 0f 1e fa          	endbr64 
  804160722a:	55                   	push   %rbp
  804160722b:	48 89 e5             	mov    %rsp,%rbp
  804160722e:	41 54                	push   %r12
  8041607230:	53                   	push   %rbx
  8041607231:	48 89 fb             	mov    %rdi,%rbx
    cprintf("  r15  0x%08lx\n", (unsigned long)regs->reg_r15);
  8041607234:	48 8b 37             	mov    (%rdi),%rsi
  8041607237:	48 bf 38 b2 60 41 80 	movabs $0x804160b238,%rdi
  804160723e:	00 00 00 
  8041607241:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607246:	49 bc b7 6f 60 41 80 	movabs $0x8041606fb7,%r12
  804160724d:	00 00 00 
  8041607250:	41 ff d4             	call   *%r12
    cprintf("  r14  0x%08lx\n", (unsigned long)regs->reg_r14);
  8041607253:	48 8b 73 08          	mov    0x8(%rbx),%rsi
  8041607257:	48 bf 48 b2 60 41 80 	movabs $0x804160b248,%rdi
  804160725e:	00 00 00 
  8041607261:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607266:	41 ff d4             	call   *%r12
    cprintf("  r13  0x%08lx\n", (unsigned long)regs->reg_r13);
  8041607269:	48 8b 73 10          	mov    0x10(%rbx),%rsi
  804160726d:	48 bf 58 b2 60 41 80 	movabs $0x804160b258,%rdi
  8041607274:	00 00 00 
  8041607277:	b8 00 00 00 00       	mov    $0x0,%eax
  804160727c:	41 ff d4             	call   *%r12
    cprintf("  r12  0x%08lx\n", (unsigned long)regs->reg_r12);
  804160727f:	48 8b 73 18          	mov    0x18(%rbx),%rsi
  8041607283:	48 bf 68 b2 60 41 80 	movabs $0x804160b268,%rdi
  804160728a:	00 00 00 
  804160728d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607292:	41 ff d4             	call   *%r12
    cprintf("  r11  0x%08lx\n", (unsigned long)regs->reg_r11);
  8041607295:	48 8b 73 20          	mov    0x20(%rbx),%rsi
  8041607299:	48 bf 78 b2 60 41 80 	movabs $0x804160b278,%rdi
  80416072a0:	00 00 00 
  80416072a3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416072a8:	41 ff d4             	call   *%r12
    cprintf("  r10  0x%08lx\n", (unsigned long)regs->reg_r10);
  80416072ab:	48 8b 73 28          	mov    0x28(%rbx),%rsi
  80416072af:	48 bf 88 b2 60 41 80 	movabs $0x804160b288,%rdi
  80416072b6:	00 00 00 
  80416072b9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416072be:	41 ff d4             	call   *%r12
    cprintf("  r9   0x%08lx\n", (unsigned long)regs->reg_r9);
  80416072c1:	48 8b 73 30          	mov    0x30(%rbx),%rsi
  80416072c5:	48 bf 98 b2 60 41 80 	movabs $0x804160b298,%rdi
  80416072cc:	00 00 00 
  80416072cf:	b8 00 00 00 00       	mov    $0x0,%eax
  80416072d4:	41 ff d4             	call   *%r12
    cprintf("  r8   0x%08lx\n", (unsigned long)regs->reg_r8);
  80416072d7:	48 8b 73 38          	mov    0x38(%rbx),%rsi
  80416072db:	48 bf a8 b2 60 41 80 	movabs $0x804160b2a8,%rdi
  80416072e2:	00 00 00 
  80416072e5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416072ea:	41 ff d4             	call   *%r12
    cprintf("  rdi  0x%08lx\n", (unsigned long)regs->reg_rdi);
  80416072ed:	48 8b 73 48          	mov    0x48(%rbx),%rsi
  80416072f1:	48 bf b8 b2 60 41 80 	movabs $0x804160b2b8,%rdi
  80416072f8:	00 00 00 
  80416072fb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607300:	41 ff d4             	call   *%r12
    cprintf("  rsi  0x%08lx\n", (unsigned long)regs->reg_rsi);
  8041607303:	48 8b 73 40          	mov    0x40(%rbx),%rsi
  8041607307:	48 bf c8 b2 60 41 80 	movabs $0x804160b2c8,%rdi
  804160730e:	00 00 00 
  8041607311:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607316:	41 ff d4             	call   *%r12
    cprintf("  rbp  0x%08lx\n", (unsigned long)regs->reg_rbp);
  8041607319:	48 8b 73 50          	mov    0x50(%rbx),%rsi
  804160731d:	48 bf d8 b2 60 41 80 	movabs $0x804160b2d8,%rdi
  8041607324:	00 00 00 
  8041607327:	b8 00 00 00 00       	mov    $0x0,%eax
  804160732c:	41 ff d4             	call   *%r12
    cprintf("  rbx  0x%08lx\n", (unsigned long)regs->reg_rbx);
  804160732f:	48 8b 73 68          	mov    0x68(%rbx),%rsi
  8041607333:	48 bf e8 b2 60 41 80 	movabs $0x804160b2e8,%rdi
  804160733a:	00 00 00 
  804160733d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607342:	41 ff d4             	call   *%r12
    cprintf("  rdx  0x%08lx\n", (unsigned long)regs->reg_rdx);
  8041607345:	48 8b 73 58          	mov    0x58(%rbx),%rsi
  8041607349:	48 bf f8 b2 60 41 80 	movabs $0x804160b2f8,%rdi
  8041607350:	00 00 00 
  8041607353:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607358:	41 ff d4             	call   *%r12
    cprintf("  rcx  0x%08lx\n", (unsigned long)regs->reg_rcx);
  804160735b:	48 8b 73 60          	mov    0x60(%rbx),%rsi
  804160735f:	48 bf 08 b3 60 41 80 	movabs $0x804160b308,%rdi
  8041607366:	00 00 00 
  8041607369:	b8 00 00 00 00       	mov    $0x0,%eax
  804160736e:	41 ff d4             	call   *%r12
    cprintf("  rax  0x%08lx\n", (unsigned long)regs->reg_rax);
  8041607371:	48 8b 73 70          	mov    0x70(%rbx),%rsi
  8041607375:	48 bf 18 b3 60 41 80 	movabs $0x804160b318,%rdi
  804160737c:	00 00 00 
  804160737f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607384:	41 ff d4             	call   *%r12
}
  8041607387:	5b                   	pop    %rbx
  8041607388:	41 5c                	pop    %r12
  804160738a:	5d                   	pop    %rbp
  804160738b:	c3                   	ret    

000000804160738c <print_trapframe>:
print_trapframe(struct Trapframe *tf) {
  804160738c:	f3 0f 1e fa          	endbr64 
  8041607390:	55                   	push   %rbp
  8041607391:	48 89 e5             	mov    %rsp,%rbp
  8041607394:	41 54                	push   %r12
  8041607396:	53                   	push   %rbx
  8041607397:	48 89 fb             	mov    %rdi,%rbx
    cprintf("TRAP frame at %p\n", tf);
  804160739a:	48 89 fe             	mov    %rdi,%rsi
  804160739d:	48 bf 85 b3 60 41 80 	movabs $0x804160b385,%rdi
  80416073a4:	00 00 00 
  80416073a7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416073ac:	49 bc b7 6f 60 41 80 	movabs $0x8041606fb7,%r12
  80416073b3:	00 00 00 
  80416073b6:	41 ff d4             	call   *%r12
    print_regs(&tf->tf_regs);
  80416073b9:	48 89 df             	mov    %rbx,%rdi
  80416073bc:	48 b8 26 72 60 41 80 	movabs $0x8041607226,%rax
  80416073c3:	00 00 00 
  80416073c6:	ff d0                	call   *%rax
    cprintf("  es   0x----%04x\n", tf->tf_es);
  80416073c8:	0f b7 73 78          	movzwl 0x78(%rbx),%esi
  80416073cc:	48 bf 97 b3 60 41 80 	movabs $0x804160b397,%rdi
  80416073d3:	00 00 00 
  80416073d6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416073db:	41 ff d4             	call   *%r12
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  80416073de:	0f b7 b3 80 00 00 00 	movzwl 0x80(%rbx),%esi
  80416073e5:	48 bf aa b3 60 41 80 	movabs $0x804160b3aa,%rdi
  80416073ec:	00 00 00 
  80416073ef:	b8 00 00 00 00       	mov    $0x0,%eax
  80416073f4:	41 ff d4             	call   *%r12
    cprintf("  trap 0x%08lx %s\n", (unsigned long)tf->tf_trapno, trapname(tf->tf_trapno));
  80416073f7:	48 8b b3 88 00 00 00 	mov    0x88(%rbx),%rsi
    if (trapno < sizeof(excnames) / sizeof(excnames[0])) return excnames[trapno];
  80416073fe:	83 fe 13             	cmp    $0x13,%esi
  8041607401:	0f 86 96 01 00 00    	jbe    804160759d <print_trapframe+0x211>
    if (trapno == T_SYSCALL) return "System call";
  8041607407:	48 ba 28 b3 60 41 80 	movabs $0x804160b328,%rdx
  804160740e:	00 00 00 
  8041607411:	83 fe 30             	cmp    $0x30,%esi
  8041607414:	74 1e                	je     8041607434 <print_trapframe+0xa8>
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) return "Hardware Interrupt";
  8041607416:	8d 46 e0             	lea    -0x20(%rsi),%eax
  8041607419:	83 f8 0f             	cmp    $0xf,%eax
  804160741c:	48 ba 34 b3 60 41 80 	movabs $0x804160b334,%rdx
  8041607423:	00 00 00 
  8041607426:	48 b8 43 b3 60 41 80 	movabs $0x804160b343,%rax
  804160742d:	00 00 00 
  8041607430:	48 0f 46 d0          	cmovbe %rax,%rdx
    cprintf("  trap 0x%08lx %s\n", (unsigned long)tf->tf_trapno, trapname(tf->tf_trapno));
  8041607434:	48 bf bd b3 60 41 80 	movabs $0x804160b3bd,%rdi
  804160743b:	00 00 00 
  804160743e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607443:	48 b9 b7 6f 60 41 80 	movabs $0x8041606fb7,%rcx
  804160744a:	00 00 00 
  804160744d:	ff d1                	call   *%rcx
    if (tf == last_tf && tf->tf_trapno == T_PGFLT)
  804160744f:	48 b8 e0 53 e4 41 80 	movabs $0x8041e453e0,%rax
  8041607456:	00 00 00 
  8041607459:	48 39 18             	cmp    %rbx,(%rax)
  804160745c:	0f 84 51 01 00 00    	je     80416075b3 <print_trapframe+0x227>
    cprintf("  err  0x%08lx", (unsigned long)tf->tf_err);
  8041607462:	48 8b b3 90 00 00 00 	mov    0x90(%rbx),%rsi
  8041607469:	48 bf e0 b3 60 41 80 	movabs $0x804160b3e0,%rdi
  8041607470:	00 00 00 
  8041607473:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607478:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  804160747f:	00 00 00 
  8041607482:	ff d2                	call   *%rdx
    if (tf->tf_trapno == T_PGFLT) {
  8041607484:	48 83 bb 88 00 00 00 	cmpq   $0xe,0x88(%rbx)
  804160748b:	0e 
  804160748c:	0f 85 52 01 00 00    	jne    80416075e4 <print_trapframe+0x258>
                tf->tf_err & FEC_P ? "protection" : "not-present");
  8041607492:	48 8b 83 90 00 00 00 	mov    0x90(%rbx),%rax
        cprintf(" [%s, %s, %s]\n",
  8041607499:	a8 01                	test   $0x1,%al
  804160749b:	48 b9 56 b3 60 41 80 	movabs $0x804160b356,%rcx
  80416074a2:	00 00 00 
  80416074a5:	48 ba 61 b3 60 41 80 	movabs $0x804160b361,%rdx
  80416074ac:	00 00 00 
  80416074af:	48 0f 44 ca          	cmove  %rdx,%rcx
  80416074b3:	48 ba 72 b3 60 41 80 	movabs $0x804160b372,%rdx
  80416074ba:	00 00 00 
  80416074bd:	a8 02                	test   $0x2,%al
  80416074bf:	75 1a                	jne    80416074db <print_trapframe+0x14f>
                tf->tf_err & FEC_W ? "write" : tf->tf_err & FEC_I ? "execute" :
  80416074c1:	a8 10                	test   $0x10,%al
  80416074c3:	48 ba 78 b3 60 41 80 	movabs $0x804160b378,%rdx
  80416074ca:	00 00 00 
  80416074cd:	48 be 6d b3 60 41 80 	movabs $0x804160b36d,%rsi
  80416074d4:	00 00 00 
  80416074d7:	48 0f 44 d6          	cmove  %rsi,%rdx
        cprintf(" [%s, %s, %s]\n",
  80416074db:	a8 04                	test   $0x4,%al
  80416074dd:	48 be 80 b3 60 41 80 	movabs $0x804160b380,%rsi
  80416074e4:	00 00 00 
  80416074e7:	48 b8 92 b4 60 41 80 	movabs $0x804160b492,%rax
  80416074ee:	00 00 00 
  80416074f1:	48 0f 44 f0          	cmove  %rax,%rsi
  80416074f5:	48 bf ef b3 60 41 80 	movabs $0x804160b3ef,%rdi
  80416074fc:	00 00 00 
  80416074ff:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607504:	49 b8 b7 6f 60 41 80 	movabs $0x8041606fb7,%r8
  804160750b:	00 00 00 
  804160750e:	41 ff d0             	call   *%r8
    cprintf("  rip  0x%08lx\n", (unsigned long)tf->tf_rip);
  8041607511:	48 8b b3 98 00 00 00 	mov    0x98(%rbx),%rsi
  8041607518:	48 bf fe b3 60 41 80 	movabs $0x804160b3fe,%rdi
  804160751f:	00 00 00 
  8041607522:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607527:	49 bc b7 6f 60 41 80 	movabs $0x8041606fb7,%r12
  804160752e:	00 00 00 
  8041607531:	41 ff d4             	call   *%r12
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  8041607534:	0f b7 b3 a0 00 00 00 	movzwl 0xa0(%rbx),%esi
  804160753b:	48 bf 0e b4 60 41 80 	movabs $0x804160b40e,%rdi
  8041607542:	00 00 00 
  8041607545:	b8 00 00 00 00       	mov    $0x0,%eax
  804160754a:	41 ff d4             	call   *%r12
    cprintf("  flag 0x%08lx\n", (unsigned long)tf->tf_rflags);
  804160754d:	48 8b b3 a8 00 00 00 	mov    0xa8(%rbx),%rsi
  8041607554:	48 bf 21 b4 60 41 80 	movabs $0x804160b421,%rdi
  804160755b:	00 00 00 
  804160755e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607563:	41 ff d4             	call   *%r12
    cprintf("  rsp  0x%08lx\n", (unsigned long)tf->tf_rsp);
  8041607566:	48 8b b3 b0 00 00 00 	mov    0xb0(%rbx),%rsi
  804160756d:	48 bf 31 b4 60 41 80 	movabs $0x804160b431,%rdi
  8041607574:	00 00 00 
  8041607577:	b8 00 00 00 00       	mov    $0x0,%eax
  804160757c:	41 ff d4             	call   *%r12
    cprintf("  ss   0x----%04x\n", tf->tf_ss);
  804160757f:	0f b7 b3 b8 00 00 00 	movzwl 0xb8(%rbx),%esi
  8041607586:	48 bf 41 b4 60 41 80 	movabs $0x804160b441,%rdi
  804160758d:	00 00 00 
  8041607590:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607595:	41 ff d4             	call   *%r12
}
  8041607598:	5b                   	pop    %rbx
  8041607599:	41 5c                	pop    %r12
  804160759b:	5d                   	pop    %rbp
  804160759c:	c3                   	ret    
    if (trapno < sizeof(excnames) / sizeof(excnames[0])) return excnames[trapno];
  804160759d:	48 63 c6             	movslq %esi,%rax
  80416075a0:	48 ba e0 b5 60 41 80 	movabs $0x804160b5e0,%rdx
  80416075a7:	00 00 00 
  80416075aa:	48 8b 14 c2          	mov    (%rdx,%rax,8),%rdx
  80416075ae:	e9 81 fe ff ff       	jmp    8041607434 <print_trapframe+0xa8>
    if (tf == last_tf && tf->tf_trapno == T_PGFLT)
  80416075b3:	48 83 bb 88 00 00 00 	cmpq   $0xe,0x88(%rbx)
  80416075ba:	0e 
  80416075bb:	0f 85 a1 fe ff ff    	jne    8041607462 <print_trapframe+0xd6>
    asm volatile("movq %%cr2,%0"
  80416075c1:	0f 20 d6             	mov    %cr2,%rsi
        cprintf("  cr2  0x%08lx\n", (unsigned long)rcr2());
  80416075c4:	48 bf d0 b3 60 41 80 	movabs $0x804160b3d0,%rdi
  80416075cb:	00 00 00 
  80416075ce:	b8 00 00 00 00       	mov    $0x0,%eax
  80416075d3:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  80416075da:	00 00 00 
  80416075dd:	ff d2                	call   *%rdx
  80416075df:	e9 7e fe ff ff       	jmp    8041607462 <print_trapframe+0xd6>
        cprintf("\n");
  80416075e4:	48 bf f0 a1 60 41 80 	movabs $0x804160a1f0,%rdi
  80416075eb:	00 00 00 
  80416075ee:	b8 00 00 00 00       	mov    $0x0,%eax
  80416075f3:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  80416075fa:	00 00 00 
  80416075fd:	ff d2                	call   *%rdx
  80416075ff:	e9 0d ff ff ff       	jmp    8041607511 <print_trapframe+0x185>

0000008041607604 <trap>:
        env_destroy(curenv);
    }
}

_Noreturn void
trap(struct Trapframe *tf) {
  8041607604:	f3 0f 1e fa          	endbr64 
  8041607608:	55                   	push   %rbp
  8041607609:	48 89 e5             	mov    %rsp,%rbp
  804160760c:	53                   	push   %rbx
  804160760d:	48 83 ec 08          	sub    $0x8,%rsp
  8041607611:	48 89 fe             	mov    %rdi,%rsi

    /* The environment may have set DF and some versions
     * of GCC rely on DF being clear */
    asm volatile("cld" ::
  8041607614:	fc                   	cld    
                         : "cc");

    /* Halt the CPU if some other CPU has called panic() */
    extern char *panicstr;
    if (panicstr) asm volatile("hlt");
  8041607615:	48 b8 00 00 80 41 80 	movabs $0x8041800000,%rax
  804160761c:	00 00 00 
  804160761f:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041607623:	74 01                	je     8041607626 <trap+0x22>
  8041607625:	f4                   	hlt    
    asm volatile("pushfq; popq %0"
  8041607626:	9c                   	pushf  
  8041607627:	58                   	pop    %rax

    /* Check that interrupts are disabled.  If this assertion
     * fails, DO NOT be tempted to fix it by inserting a "cli" in
     * the interrupt path */
    assert(!(read_rflags() & FL_IF));
  8041607628:	f6 c4 02             	test   $0x2,%ah
  804160762b:	0f 85 8d 00 00 00    	jne    80416076be <trap+0xba>

    if (trace_traps) cprintf("Incoming TRAP[%ld] frame at %p\n", tf->tf_trapno, tf);
    if (trace_traps_more) print_trapframe(tf);

    assert(curenv);
  8041607631:	48 a1 c0 43 e4 41 80 	movabs 0x8041e443c0,%rax
  8041607638:	00 00 00 
  804160763b:	48 85 c0             	test   %rax,%rax
  804160763e:	0f 84 af 00 00 00    	je     80416076f3 <trap+0xef>

    /* Copy trap frame (which is currently on the stack)
     * into 'curenv->env_tf', so that running the environment
     * will restart at the trap point */
    curenv->env_tf = *tf;
  8041607644:	b9 30 00 00 00       	mov    $0x30,%ecx
  8041607649:	48 89 c7             	mov    %rax,%rdi
  804160764c:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
    /* The trapframe on the stack should be ignored from here on */
    tf = &curenv->env_tf;
  804160764e:	48 b8 c0 43 e4 41 80 	movabs $0x8041e443c0,%rax
  8041607655:	00 00 00 
  8041607658:	48 8b 18             	mov    (%rax),%rbx

    /* Record that tf is the last real trapframe so
     * print_trapframe can print some additional information */
    last_tf = tf;
  804160765b:	48 89 d8             	mov    %rbx,%rax
  804160765e:	48 a3 e0 53 e4 41 80 	movabs %rax,0x8041e453e0
  8041607665:	00 00 00 
    switch (tf->tf_trapno) {
  8041607668:	48 8b 83 88 00 00 00 	mov    0x88(%rbx),%rax
  804160766f:	48 83 f8 27          	cmp    $0x27,%rax
  8041607673:	0f 84 14 01 00 00    	je     804160778d <trap+0x189>
  8041607679:	48 83 e0 f7          	and    $0xfffffffffffffff7,%rax
  804160767d:	48 83 f8 20          	cmp    $0x20,%rax
  8041607681:	0f 84 9c 00 00 00    	je     8041607723 <trap+0x11f>
        print_trapframe(tf);
  8041607687:	48 89 df             	mov    %rbx,%rdi
  804160768a:	48 b8 8c 73 60 41 80 	movabs $0x804160738c,%rax
  8041607691:	00 00 00 
  8041607694:	ff d0                	call   *%rax
        if (!(tf->tf_cs & 3))
  8041607696:	f6 83 a0 00 00 00 03 	testb  $0x3,0xa0(%rbx)
  804160769d:	0f 84 b1 00 00 00    	je     8041607754 <trap+0x150>
        env_destroy(curenv);
  80416076a3:	48 b8 c0 43 e4 41 80 	movabs $0x8041e443c0,%rax
  80416076aa:	00 00 00 
  80416076ad:	48 8b 38             	mov    (%rax),%rdi
  80416076b0:	48 b8 39 6a 60 41 80 	movabs $0x8041606a39,%rax
  80416076b7:	00 00 00 
  80416076ba:	ff d0                	call   *%rax
  80416076bc:	eb 72                	jmp    8041607730 <trap+0x12c>
    assert(!(read_rflags() & FL_IF));
  80416076be:	48 b9 54 b4 60 41 80 	movabs $0x804160b454,%rcx
  80416076c5:	00 00 00 
  80416076c8:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  80416076cf:	00 00 00 
  80416076d2:	be 09 01 00 00       	mov    $0x109,%esi
  80416076d7:	48 bf 6d b4 60 41 80 	movabs $0x804160b46d,%rdi
  80416076de:	00 00 00 
  80416076e1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416076e6:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  80416076ed:	00 00 00 
  80416076f0:	41 ff d0             	call   *%r8
    assert(curenv);
  80416076f3:	48 b9 79 b4 60 41 80 	movabs $0x804160b479,%rcx
  80416076fa:	00 00 00 
  80416076fd:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041607704:	00 00 00 
  8041607707:	be 0e 01 00 00       	mov    $0x10e,%esi
  804160770c:	48 bf 6d b4 60 41 80 	movabs $0x804160b46d,%rdi
  8041607713:	00 00 00 
  8041607716:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  804160771d:	00 00 00 
  8041607720:	41 ff d0             	call   *%r8
        timer_for_schedule->handle_interrupts();
  8041607723:	48 a1 80 54 e4 41 80 	movabs 0x8041e45480,%rax
  804160772a:	00 00 00 
  804160772d:	ff 50 20             	call   *0x20(%rax)
*/

    /* If we made it to this point, then no other environment was
     * scheduled, so we should return to the current environment
     * if doing so makes sense */
    if (curenv && curenv->env_status == ENV_RUNNING){
  8041607730:	48 a1 c0 43 e4 41 80 	movabs 0x8041e443c0,%rax
  8041607737:	00 00 00 
  804160773a:	48 85 c0             	test   %rax,%rax
  804160773d:	74 09                	je     8041607748 <trap+0x144>
  804160773f:	83 b8 d4 00 00 00 03 	cmpl   $0x3,0xd4(%rax)
  8041607746:	74 36                	je     804160777e <trap+0x17a>
        env_run(curenv);
    }
    else{
        sched_yield();
  8041607748:	48 b8 2d 84 60 41 80 	movabs $0x804160842d,%rax
  804160774f:	00 00 00 
  8041607752:	ff d0                	call   *%rax
            panic("Unhandled trap in kernel");
  8041607754:	48 ba 80 b4 60 41 80 	movabs $0x804160b480,%rdx
  804160775b:	00 00 00 
  804160775e:	be f5 00 00 00       	mov    $0xf5,%esi
  8041607763:	48 bf 6d b4 60 41 80 	movabs $0x804160b46d,%rdi
  804160776a:	00 00 00 
  804160776d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607772:	48 b9 e3 03 60 41 80 	movabs $0x80416003e3,%rcx
  8041607779:	00 00 00 
  804160777c:	ff d1                	call   *%rcx
        env_run(curenv);
  804160777e:	48 89 c7             	mov    %rax,%rdi
  8041607781:	48 b8 71 6b 60 41 80 	movabs $0x8041606b71,%rax
  8041607788:	00 00 00 
  804160778b:	ff d0                	call   *%rax
    if (curenv && curenv->env_status == ENV_RUNNING){
  804160778d:	48 a1 c0 43 e4 41 80 	movabs 0x8041e443c0,%rax
  8041607794:	00 00 00 
  8041607797:	eb a6                	jmp    804160773f <trap+0x13b>

0000008041607799 <clock_thdlr>:
#ifdef CONFIG_KSPACE

.globl clock_thdlr
.type clock_thdlr, @function
clock_thdlr:
    cli
  8041607799:	fa                   	cli    
    call save_trapframe_trap
  804160779a:	e8 78 88 ff ff       	call   8041600017 <save_trapframe_trap>
    # Set trap code for trapframe
    movl $(IRQ_OFFSET + IRQ_CLOCK), 136(%rsp)
  804160779f:	c7 84 24 88 00 00 00 	movl   $0x28,0x88(%rsp)
  80416077a6:	28 00 00 00 
    call trap
  80416077aa:	e8 55 fe ff ff       	call   8041607604 <trap>
    jmp .
  80416077af:	eb fe                	jmp    80416077af <clock_thdlr+0x16>

00000080416077b1 <timer_thdlr>:

.globl timer_thdlr
.type timer_thdlr, @function
timer_thdlr:
    # cli?
    call save_trapframe_trap
  80416077b1:	e8 61 88 ff ff       	call   8041600017 <save_trapframe_trap>
    # Set trap code for trapframe
    movl $(IRQ_OFFSET + IRQ_TIMER), 136(%rsp)
  80416077b6:	c7 84 24 88 00 00 00 	movl   $0x20,0x88(%rsp)
  80416077bd:	20 00 00 00 
    call trap
  80416077c1:	e8 3e fe ff ff       	call   8041607604 <trap>
    jmp .
  80416077c6:	eb fe                	jmp    80416077c6 <timer_thdlr+0x15>

00000080416077c8 <hpet_enable_interrupts_tim0>:
 *
 * HINT To be able to use HPET as PIT replacement consult
 *      LegacyReplacement functionality in HPET spec.
 * HINT Don't forget to unmask interrupt in PIC */
void
hpet_enable_interrupts_tim0(void) {
  80416077c8:	f3 0f 1e fa          	endbr64 
  80416077cc:	55                   	push   %rbp
  80416077cd:	48 89 e5             	mov    %rsp,%rbp
    // LAB 5: Your code here
    pic_irq_unmask(IRQ_TIMER);
  80416077d0:	bf 00 00 00 00       	mov    $0x0,%edi
  80416077d5:	48 b8 e7 6e 60 41 80 	movabs $0x8041606ee7,%rax
  80416077dc:	00 00 00 
  80416077df:	ff d0                	call   *%rax

    hpetReg->GEN_CONF |= HPET_ENABLE_CNF;
  80416077e1:	48 b8 78 55 e4 41 80 	movabs $0x8041e45578,%rax
  80416077e8:	00 00 00 
  80416077eb:	48 8b 08             	mov    (%rax),%rcx
  80416077ee:	48 8b 41 10          	mov    0x10(%rcx),%rax
  80416077f2:	48 83 c8 01          	or     $0x1,%rax
  80416077f6:	48 89 41 10          	mov    %rax,0x10(%rcx)
    hpetReg->GEN_CONF |= HPET_LEG_RT_CNF;
  80416077fa:	48 8b 41 10          	mov    0x10(%rcx),%rax
  80416077fe:	48 83 c8 02          	or     $0x2,%rax
  8041607802:	48 89 41 10          	mov    %rax,0x10(%rcx)
    hpetReg->TIM0_CONF |= HPET_TN_TYPE_CNF;
  8041607806:	48 8b 81 00 01 00 00 	mov    0x100(%rcx),%rax
  804160780d:	48 83 c8 08          	or     $0x8,%rax
  8041607811:	48 89 81 00 01 00 00 	mov    %rax,0x100(%rcx)
    hpetReg->TIM0_CONF |= HPET_TN_INT_ENB_CNF;
  8041607818:	48 8b 81 00 01 00 00 	mov    0x100(%rcx),%rax
  804160781f:	48 83 c8 04          	or     $0x4,%rax
  8041607823:	48 89 81 00 01 00 00 	mov    %rax,0x100(%rcx)

    hpetReg->GEN_CONF &= ~HPET_ENABLE_CNF;
  804160782a:	48 8b 41 10          	mov    0x10(%rcx),%rax
  804160782e:	48 83 e0 fe          	and    $0xfffffffffffffffe,%rax
  8041607832:	48 89 41 10          	mov    %rax,0x10(%rcx)
    hpetReg->MAIN_CNT = 0;
  8041607836:	48 c7 81 f0 00 00 00 	movq   $0x0,0xf0(%rcx)
  804160783d:	00 00 00 00 
    hpetReg->TIM0_CONF |= HPET_TN_VAL_SET_CNF;
  8041607841:	48 8b 81 00 01 00 00 	mov    0x100(%rcx),%rax
  8041607848:	48 83 c8 40          	or     $0x40,%rax
  804160784c:	48 89 81 00 01 00 00 	mov    %rax,0x100(%rcx)
    hpetReg->TIM0_COMP = (hpetFemto / (hpetReg->GCAP_ID >> 32));
  8041607853:	48 8b 31             	mov    (%rcx),%rsi
  8041607856:	48 c1 ee 20          	shr    $0x20,%rsi
  804160785a:	48 a1 70 55 e4 41 80 	movabs 0x8041e45570,%rax
  8041607861:	00 00 00 
  8041607864:	ba 00 00 00 00       	mov    $0x0,%edx
  8041607869:	48 f7 f6             	div    %rsi
  804160786c:	48 89 81 08 01 00 00 	mov    %rax,0x108(%rcx)
    hpetReg->GEN_CONF |= HPET_ENABLE_CNF;
  8041607873:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8041607877:	48 83 c8 01          	or     $0x1,%rax
  804160787b:	48 89 41 10          	mov    %rax,0x10(%rcx)

    return;
}
  804160787f:	5d                   	pop    %rbp
  8041607880:	c3                   	ret    

0000008041607881 <hpet_enable_interrupts_tim1>:

void
hpet_enable_interrupts_tim1(void) {
  8041607881:	f3 0f 1e fa          	endbr64 
  8041607885:	55                   	push   %rbp
  8041607886:	48 89 e5             	mov    %rsp,%rbp
    // LAB 5: Your code here

    hpetReg->GEN_CONF |= HPET_ENABLE_CNF;
  8041607889:	48 b8 78 55 e4 41 80 	movabs $0x8041e45578,%rax
  8041607890:	00 00 00 
  8041607893:	48 8b 08             	mov    (%rax),%rcx
  8041607896:	48 8b 41 10          	mov    0x10(%rcx),%rax
  804160789a:	48 83 c8 01          	or     $0x1,%rax
  804160789e:	48 89 41 10          	mov    %rax,0x10(%rcx)
    hpetReg->GEN_CONF |= HPET_LEG_RT_CNF;
  80416078a2:	48 8b 41 10          	mov    0x10(%rcx),%rax
  80416078a6:	48 83 c8 02          	or     $0x2,%rax
  80416078aa:	48 89 41 10          	mov    %rax,0x10(%rcx)
    hpetReg->TIM1_CONF |= HPET_TN_TYPE_CNF;
  80416078ae:	48 8b 81 20 01 00 00 	mov    0x120(%rcx),%rax
  80416078b5:	48 83 c8 08          	or     $0x8,%rax
  80416078b9:	48 89 81 20 01 00 00 	mov    %rax,0x120(%rcx)
    hpetReg->TIM1_CONF |= HPET_TN_INT_ENB_CNF;
  80416078c0:	48 8b 81 20 01 00 00 	mov    0x120(%rcx),%rax
  80416078c7:	48 83 c8 04          	or     $0x4,%rax
  80416078cb:	48 89 81 20 01 00 00 	mov    %rax,0x120(%rcx)

    hpetReg->GEN_CONF &= ~HPET_ENABLE_CNF;
  80416078d2:	48 8b 41 10          	mov    0x10(%rcx),%rax
  80416078d6:	48 83 e0 fe          	and    $0xfffffffffffffffe,%rax
  80416078da:	48 89 41 10          	mov    %rax,0x10(%rcx)
    hpetReg->MAIN_CNT = 0;
  80416078de:	48 c7 81 f0 00 00 00 	movq   $0x0,0xf0(%rcx)
  80416078e5:	00 00 00 00 
    hpetReg->TIM1_CONF |= HPET_TN_VAL_SET_CNF;
  80416078e9:	48 8b 81 20 01 00 00 	mov    0x120(%rcx),%rax
  80416078f0:	48 83 c8 40          	or     $0x40,%rax
  80416078f4:	48 89 81 20 01 00 00 	mov    %rax,0x120(%rcx)
    hpetReg->TIM1_COMP = 3 * (hpetFemto / (hpetReg->GCAP_ID >> 32)) / 2;
  80416078fb:	48 8b 31             	mov    (%rcx),%rsi
  80416078fe:	48 c1 ee 20          	shr    $0x20,%rsi
  8041607902:	48 a1 70 55 e4 41 80 	movabs 0x8041e45570,%rax
  8041607909:	00 00 00 
  804160790c:	ba 00 00 00 00       	mov    $0x0,%edx
  8041607911:	48 f7 f6             	div    %rsi
  8041607914:	48 8d 04 40          	lea    (%rax,%rax,2),%rax
  8041607918:	48 d1 e8             	shr    %rax
  804160791b:	48 89 81 28 01 00 00 	mov    %rax,0x128(%rcx)
    hpetReg->GEN_CONF |= HPET_ENABLE_CNF;
  8041607922:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8041607926:	48 83 c8 01          	or     $0x1,%rax
  804160792a:	48 89 41 10          	mov    %rax,0x10(%rcx)

    pic_irq_unmask(IRQ_CLOCK);
  804160792e:	bf 08 00 00 00       	mov    $0x8,%edi
  8041607933:	48 b8 e7 6e 60 41 80 	movabs $0x8041606ee7,%rax
  804160793a:	00 00 00 
  804160793d:	ff d0                	call   *%rax
}
  804160793f:	5d                   	pop    %rbp
  8041607940:	c3                   	ret    

0000008041607941 <hpet_handle_interrupts_tim0>:

void
hpet_handle_interrupts_tim0(void) {
  8041607941:	f3 0f 1e fa          	endbr64 
  8041607945:	55                   	push   %rbp
  8041607946:	48 89 e5             	mov    %rsp,%rbp

    pic_send_eoi(IRQ_TIMER);
  8041607949:	bf 00 00 00 00       	mov    $0x0,%edi
  804160794e:	48 b8 39 6f 60 41 80 	movabs $0x8041606f39,%rax
  8041607955:	00 00 00 
  8041607958:	ff d0                	call   *%rax
    sched_yield();
  804160795a:	48 b8 2d 84 60 41 80 	movabs $0x804160842d,%rax
  8041607961:	00 00 00 
  8041607964:	ff d0                	call   *%rax

0000008041607966 <hpet_handle_interrupts_tim1>:
}

void
hpet_handle_interrupts_tim1(void) {
  8041607966:	f3 0f 1e fa          	endbr64 
  804160796a:	55                   	push   %rbp
  804160796b:	48 89 e5             	mov    %rsp,%rbp

    pic_send_eoi(IRQ_CLOCK);
  804160796e:	bf 08 00 00 00       	mov    $0x8,%edi
  8041607973:	48 b8 39 6f 60 41 80 	movabs $0x8041606f39,%rax
  804160797a:	00 00 00 
  804160797d:	ff d0                	call   *%rax
    sched_yield();
  804160797f:	48 b8 2d 84 60 41 80 	movabs $0x804160842d,%rax
  8041607986:	00 00 00 
  8041607989:	ff d0                	call   *%rax

000000804160798b <hpet_cpu_frequency>:

/* Calculate CPU frequency in Hz with the help with HPET timer.
 * HINT Use hpet_get_main_cnt function and do not forget about
 * about pause instruction. */
uint64_t
hpet_cpu_frequency(void) {
  804160798b:	f3 0f 1e fa          	endbr64 
    return hpetReg->MAIN_CNT;
  804160798f:	48 a1 78 55 e4 41 80 	movabs 0x8041e45578,%rax
  8041607996:	00 00 00 
  8041607999:	48 8b b8 f0 00 00 00 	mov    0xf0(%rax),%rdi
    asm volatile("rdtsc"
  80416079a0:	0f 31                	rdtsc  
    return (uint64_t)lo | ((uint64_t)hi << 32);
  80416079a2:	48 c1 e2 20          	shl    $0x20,%rdx
  80416079a6:	89 c0                	mov    %eax,%eax
  80416079a8:	48 89 d1             	mov    %rdx,%rcx
  80416079ab:	48 09 c1             	or     %rax,%rcx
  80416079ae:	b8 10 27 00 00       	mov    $0x2710,%eax

    uint64_t hpet_cnt_init = hpet_get_main_cnt();
    uint64_t tsc_init = read_tsc();
    
    for(int i = 0; i < 10000; i++)
        asm volatile("pause");
  80416079b3:	f3 90                	pause  
    for(int i = 0; i < 10000; i++)
  80416079b5:	83 e8 01             	sub    $0x1,%eax
  80416079b8:	75 f9                	jne    80416079b3 <hpet_cpu_frequency+0x28>
    asm volatile("rdtsc"
  80416079ba:	0f 31                	rdtsc  
  80416079bc:	41 89 c0             	mov    %eax,%r8d
    return hpetReg->MAIN_CNT;
  80416079bf:	48 a1 78 55 e4 41 80 	movabs 0x8041e45578,%rax
  80416079c6:	00 00 00 
  80416079c9:	48 8b b0 f0 00 00 00 	mov    0xf0(%rax),%rsi
    return (uint64_t)lo | ((uint64_t)hi << 32);
  80416079d0:	48 89 d0             	mov    %rdx,%rax
  80416079d3:	48 c1 e0 20          	shl    $0x20,%rax
  80416079d7:	45 89 c0             	mov    %r8d,%r8d
  80416079da:	4c 09 c0             	or     %r8,%rax

    uint64_t tsc_offset = read_tsc() - tsc_init;
  80416079dd:	48 29 c8             	sub    %rcx,%rax
    uint64_t hpet_cnt_offset = hpet_get_main_cnt() - hpet_cnt_init;

    cpu_freq = tsc_offset * hpetFreq / (hpet_cnt_offset);
  80416079e0:	48 ba 68 55 e4 41 80 	movabs $0x8041e45568,%rdx
  80416079e7:	00 00 00 
  80416079ea:	48 0f af 02          	imul   (%rdx),%rax
    uint64_t hpet_cnt_offset = hpet_get_main_cnt() - hpet_cnt_init;
  80416079ee:	48 29 fe             	sub    %rdi,%rsi
    cpu_freq = tsc_offset * hpetFreq / (hpet_cnt_offset);
  80416079f1:	ba 00 00 00 00       	mov    $0x0,%edx
  80416079f6:	48 f7 f6             	div    %rsi
    // LAB 5: Your code here
    
    return cpu_freq;
}
  80416079f9:	c3                   	ret    

00000080416079fa <mmio_map_region>:
mmio_map_region(physaddr_t pa, size_t size) {
  80416079fa:	f3 0f 1e fa          	endbr64 
  80416079fe:	55                   	push   %rbp
  80416079ff:	48 89 e5             	mov    %rsp,%rbp
  8041607a02:	53                   	push   %rbx
  8041607a03:	48 83 ec 08          	sub    $0x8,%rsp
  8041607a07:	48 89 fb             	mov    %rdi,%rbx
    size += pa & (base_2mb - 1);
  8041607a0a:	48 89 f8             	mov    %rdi,%rax
  8041607a0d:	25 ff ff 1f 00       	and    $0x1fffff,%eax
    size += (base_2mb - 1);
  8041607a12:	48 8d 94 30 ff ff 1f 	lea    0x1fffff(%rax,%rsi,1),%rdx
  8041607a19:	00 
    pa &= ~(base_2mb - 1);
  8041607a1a:	48 81 e7 00 00 e0 ff 	and    $0xffffffffffe00000,%rdi
    size &= ~(base_2mb - 1);
  8041607a21:	48 81 e2 00 00 e0 ff 	and    $0xffffffffffe00000,%rdx
    map_addr_early_boot(pa, pa, size);
  8041607a28:	48 89 fe             	mov    %rdi,%rsi
  8041607a2b:	48 b8 ab 02 60 41 80 	movabs $0x80416002ab,%rax
  8041607a32:	00 00 00 
  8041607a35:	ff d0                	call   *%rax
}
  8041607a37:	48 89 d8             	mov    %rbx,%rax
  8041607a3a:	48 8b 5d f8          	mov    -0x8(%rbp),%rbx
  8041607a3e:	c9                   	leave  
  8041607a3f:	c3                   	ret    

0000008041607a40 <mmio_remap_last_region>:
mmio_remap_last_region(physaddr_t pa, void *addr, size_t oldsz, size_t newsz) {
  8041607a40:	f3 0f 1e fa          	endbr64 
  8041607a44:	55                   	push   %rbp
  8041607a45:	48 89 e5             	mov    %rsp,%rbp
  8041607a48:	48 89 ce             	mov    %rcx,%rsi
    return mmio_map_region(pa, newsz);
  8041607a4b:	48 b8 fa 79 60 41 80 	movabs $0x80416079fa,%rax
  8041607a52:	00 00 00 
  8041607a55:	ff d0                	call   *%rax
}
  8041607a57:	5d                   	pop    %rbp
  8041607a58:	c3                   	ret    

0000008041607a59 <validate_sdt_checksum>:
int validate_sdt_checksum(ACPISDTHeader* sdt_ptr){
  8041607a59:	f3 0f 1e fa          	endbr64 
    for(uint8_t* p_byte = (uint8_t*)sdt_ptr; p_byte < (uint8_t*)(sdt_ptr + sdt_ptr->Length); p_byte++){
  8041607a5d:	8b 47 04             	mov    0x4(%rdi),%eax
  8041607a60:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  8041607a64:	48 8d 04 87          	lea    (%rdi,%rax,4),%rax
  8041607a68:	48 39 c7             	cmp    %rax,%rdi
  8041607a6b:	73 09                	jae    8041607a76 <validate_sdt_checksum+0x1d>
  8041607a6d:	48 83 c7 01          	add    $0x1,%rdi
  8041607a71:	48 39 c7             	cmp    %rax,%rdi
  8041607a74:	75 f7                	jne    8041607a6d <validate_sdt_checksum+0x14>
}
  8041607a76:	b8 01 00 00 00       	mov    $0x1,%eax
  8041607a7b:	c3                   	ret    

0000008041607a7c <acpi_find_table>:
acpi_find_table(const char *sign) {
  8041607a7c:	f3 0f 1e fa          	endbr64 
  8041607a80:	55                   	push   %rbp
  8041607a81:	48 89 e5             	mov    %rsp,%rbp
  8041607a84:	41 57                	push   %r15
  8041607a86:	41 56                	push   %r14
  8041607a88:	41 55                	push   %r13
  8041607a8a:	41 54                	push   %r12
  8041607a8c:	53                   	push   %rbx
  8041607a8d:	48 83 ec 08          	sub    $0x8,%rsp
    RSDP* rsdp_ptr = (RSDP*)uefi_lp->ACPIRoot;
  8041607a91:	48 a1 00 d0 62 41 80 	movabs 0x804162d000,%rax
  8041607a98:	00 00 00 
  8041607a9b:	48 8b 40 10          	mov    0x10(%rax),%rax
    if(*(int64_t*)rsdp_ptr->Signature != ACPI_RSDP_SIGNATURE){
  8041607a9f:	48 ba 52 53 44 20 50 	movabs $0x2052545020445352,%rdx
  8041607aa6:	54 52 20 
  8041607aa9:	48 39 10             	cmp    %rdx,(%rax)
  8041607aac:	0f 85 93 00 00 00    	jne    8041607b45 <acpi_find_table+0xc9>
  8041607ab2:	49 89 fd             	mov    %rdi,%r13
    assert((uint64_t)rsdp_ptr->RsdtAddress != (uint64_t)rsdp_ptr->XsdtAddress && "xsdt and rsdt adresses differ");
  8041607ab5:	44 8b 60 10          	mov    0x10(%rax),%r12d
  8041607ab9:	4c 3b 60 18          	cmp    0x18(%rax),%r12
  8041607abd:	0f 84 ac 00 00 00    	je     8041607b6f <acpi_find_table+0xf3>
    if(*(int32_t*)rsdt_ptr->h.Signature != ACPI_RSDT_SIGNATURE){
  8041607ac3:	41 81 3c 24 52 53 44 	cmpl   $0x54445352,(%r12)
  8041607aca:	54 
  8041607acb:	0f 85 d3 00 00 00    	jne    8041607ba4 <acpi_find_table+0x128>
    if(!(validate_sdt_checksum((ACPISDTHeader*)rsdt_ptr))){
  8041607ad1:	4c 89 e7             	mov    %r12,%rdi
  8041607ad4:	48 b8 59 7a 60 41 80 	movabs $0x8041607a59,%rax
  8041607adb:	00 00 00 
  8041607ade:	ff d0                	call   *%rax
  8041607ae0:	85 c0                	test   %eax,%eax
  8041607ae2:	0f 84 e6 00 00 00    	je     8041607bce <acpi_find_table+0x152>
    int n_tables = RSDT_N_TABLES(rsdt_ptr);
  8041607ae8:	41 8b 44 24 04       	mov    0x4(%r12),%eax
  8041607aed:	8d 50 f7             	lea    -0x9(%rax),%edx
    for(int n_table = 0; n_table < n_tables; n_table++){
  8041607af0:	85 d2                	test   %edx,%edx
  8041607af2:	0f 8e fb 00 00 00    	jle    8041607bf3 <acpi_find_table+0x177>
  8041607af8:	49 8d 5c 24 24       	lea    0x24(%r12),%rbx
  8041607afd:	8d 40 f6             	lea    -0xa(%rax),%eax
  8041607b00:	4d 8d 7c 84 28       	lea    0x28(%r12,%rax,4),%r15
        if(strncmp(table_header->Signature, sign, 4) == 0){
  8041607b05:	49 be cd 92 60 41 80 	movabs $0x80416092cd,%r14
  8041607b0c:	00 00 00 
        ACPISDTHeader* table_header = (ACPISDTHeader*)(uintptr_t)(rsdt_ptr->PointerToOtherSDT[n_table]);
  8041607b0f:	44 8b 23             	mov    (%rbx),%r12d
        if(strncmp(table_header->Signature, sign, 4) == 0){
  8041607b12:	ba 04 00 00 00       	mov    $0x4,%edx
  8041607b17:	4c 89 ee             	mov    %r13,%rsi
  8041607b1a:	4c 89 e7             	mov    %r12,%rdi
  8041607b1d:	41 ff d6             	call   *%r14
  8041607b20:	85 c0                	test   %eax,%eax
  8041607b22:	74 0f                	je     8041607b33 <acpi_find_table+0xb7>
    for(int n_table = 0; n_table < n_tables; n_table++){
  8041607b24:	48 83 c3 04          	add    $0x4,%rbx
  8041607b28:	4c 39 fb             	cmp    %r15,%rbx
  8041607b2b:	75 e2                	jne    8041607b0f <acpi_find_table+0x93>
    return NULL;
  8041607b2d:	41 bc 00 00 00 00    	mov    $0x0,%r12d
}
  8041607b33:	4c 89 e0             	mov    %r12,%rax
  8041607b36:	48 83 c4 08          	add    $0x8,%rsp
  8041607b3a:	5b                   	pop    %rbx
  8041607b3b:	41 5c                	pop    %r12
  8041607b3d:	41 5d                	pop    %r13
  8041607b3f:	41 5e                	pop    %r14
  8041607b41:	41 5f                	pop    %r15
  8041607b43:	5d                   	pop    %rbp
  8041607b44:	c3                   	ret    
        panic("acpi_find_table: signature of rsdp is invalid\n");
  8041607b45:	48 ba 80 b6 60 41 80 	movabs $0x804160b680,%rdx
  8041607b4c:	00 00 00 
  8041607b4f:	be 76 00 00 00       	mov    $0x76,%esi
  8041607b54:	48 bf d3 b8 60 41 80 	movabs $0x804160b8d3,%rdi
  8041607b5b:	00 00 00 
  8041607b5e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607b63:	48 b9 e3 03 60 41 80 	movabs $0x80416003e3,%rcx
  8041607b6a:	00 00 00 
  8041607b6d:	ff d1                	call   *%rcx
    assert((uint64_t)rsdp_ptr->RsdtAddress != (uint64_t)rsdp_ptr->XsdtAddress && "xsdt and rsdt adresses differ");
  8041607b6f:	48 b9 b0 b6 60 41 80 	movabs $0x804160b6b0,%rcx
  8041607b76:	00 00 00 
  8041607b79:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041607b80:	00 00 00 
  8041607b83:	be 82 00 00 00       	mov    $0x82,%esi
  8041607b88:	48 bf d3 b8 60 41 80 	movabs $0x804160b8d3,%rdi
  8041607b8f:	00 00 00 
  8041607b92:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607b97:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041607b9e:	00 00 00 
  8041607ba1:	41 ff d0             	call   *%r8
        panic("acpi_find_table: signature of rsdt is invalid\n"); 
  8041607ba4:	48 ba 18 b7 60 41 80 	movabs $0x804160b718,%rdx
  8041607bab:	00 00 00 
  8041607bae:	be 8a 00 00 00       	mov    $0x8a,%esi
  8041607bb3:	48 bf d3 b8 60 41 80 	movabs $0x804160b8d3,%rdi
  8041607bba:	00 00 00 
  8041607bbd:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607bc2:	48 b9 e3 03 60 41 80 	movabs $0x80416003e3,%rcx
  8041607bc9:	00 00 00 
  8041607bcc:	ff d1                	call   *%rcx
        panic("acpi_find_table: checksum of rsdt is invalid\n");
  8041607bce:	48 ba 48 b7 60 41 80 	movabs $0x804160b748,%rdx
  8041607bd5:	00 00 00 
  8041607bd8:	be 8e 00 00 00       	mov    $0x8e,%esi
  8041607bdd:	48 bf d3 b8 60 41 80 	movabs $0x804160b8d3,%rdi
  8041607be4:	00 00 00 
  8041607be7:	48 b9 e3 03 60 41 80 	movabs $0x80416003e3,%rcx
  8041607bee:	00 00 00 
  8041607bf1:	ff d1                	call   *%rcx
    return NULL;
  8041607bf3:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  8041607bf9:	e9 35 ff ff ff       	jmp    8041607b33 <acpi_find_table+0xb7>

0000008041607bfe <get_fadt>:
get_fadt(void) {
  8041607bfe:	f3 0f 1e fa          	endbr64 
  8041607c02:	55                   	push   %rbp
  8041607c03:	48 89 e5             	mov    %rsp,%rbp
  8041607c06:	53                   	push   %rbx
  8041607c07:	48 83 ec 08          	sub    $0x8,%rsp
    kfadt = acpi_find_table("FACP");
  8041607c0b:	48 bf e0 b8 60 41 80 	movabs $0x804160b8e0,%rdi
  8041607c12:	00 00 00 
  8041607c15:	48 b8 7c 7a 60 41 80 	movabs $0x8041607a7c,%rax
  8041607c1c:	00 00 00 
  8041607c1f:	ff d0                	call   *%rax
    if(kfadt == NULL){
  8041607c21:	48 85 c0             	test   %rax,%rax
  8041607c24:	74 1f                	je     8041607c45 <get_fadt+0x47>
  8041607c26:	48 89 c3             	mov    %rax,%rbx
    if(!validate_sdt_checksum((ACPISDTHeader*)kfadt)){
  8041607c29:	48 89 c7             	mov    %rax,%rdi
  8041607c2c:	48 b8 59 7a 60 41 80 	movabs $0x8041607a59,%rax
  8041607c33:	00 00 00 
  8041607c36:	ff d0                	call   *%rax
  8041607c38:	85 c0                	test   %eax,%eax
  8041607c3a:	74 33                	je     8041607c6f <get_fadt+0x71>
}
  8041607c3c:	48 89 d8             	mov    %rbx,%rax
  8041607c3f:	48 8b 5d f8          	mov    -0x8(%rbp),%rbx
  8041607c43:	c9                   	leave  
  8041607c44:	c3                   	ret    
        panic("get_fadt: unable to get FADT table");
  8041607c45:	48 ba 78 b7 60 41 80 	movabs $0x804160b778,%rdx
  8041607c4c:	00 00 00 
  8041607c4f:	be a9 00 00 00       	mov    $0xa9,%esi
  8041607c54:	48 bf d3 b8 60 41 80 	movabs $0x804160b8d3,%rdi
  8041607c5b:	00 00 00 
  8041607c5e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607c63:	48 b9 e3 03 60 41 80 	movabs $0x80416003e3,%rcx
  8041607c6a:	00 00 00 
  8041607c6d:	ff d1                	call   *%rcx
        panic("get_fadt: signature FADT table is invalid");
  8041607c6f:	48 ba a0 b7 60 41 80 	movabs $0x804160b7a0,%rdx
  8041607c76:	00 00 00 
  8041607c79:	be ad 00 00 00       	mov    $0xad,%esi
  8041607c7e:	48 bf d3 b8 60 41 80 	movabs $0x804160b8d3,%rdi
  8041607c85:	00 00 00 
  8041607c88:	48 b9 e3 03 60 41 80 	movabs $0x80416003e3,%rcx
  8041607c8f:	00 00 00 
  8041607c92:	ff d1                	call   *%rcx

0000008041607c94 <acpi_enable>:
acpi_enable(void) {
  8041607c94:	f3 0f 1e fa          	endbr64 
  8041607c98:	55                   	push   %rbp
  8041607c99:	48 89 e5             	mov    %rsp,%rbp
    FADT *fadt = get_fadt();
  8041607c9c:	48 b8 fe 7b 60 41 80 	movabs $0x8041607bfe,%rax
  8041607ca3:	00 00 00 
  8041607ca6:	ff d0                	call   *%rax
  8041607ca8:	48 89 c1             	mov    %rax,%rcx
    asm volatile("outb %0,%w1" ::"a"(data), "d"(port));
  8041607cab:	0f b6 40 34          	movzbl 0x34(%rax),%eax
  8041607caf:	8b 51 30             	mov    0x30(%rcx),%edx
  8041607cb2:	ee                   	out    %al,(%dx)
    while ((inw(fadt->PM1aControlBlock) & 1) == 0) /* nothing */
  8041607cb3:	8b 51 40             	mov    0x40(%rcx),%edx
    asm volatile("inw %w1,%0"
  8041607cb6:	66 ed                	in     (%dx),%ax
  8041607cb8:	a8 01                	test   $0x1,%al
  8041607cba:	74 fa                	je     8041607cb6 <acpi_enable+0x22>
}
  8041607cbc:	5d                   	pop    %rbp
  8041607cbd:	c3                   	ret    

0000008041607cbe <get_hpet>:
get_hpet(void) {
  8041607cbe:	f3 0f 1e fa          	endbr64 
  8041607cc2:	55                   	push   %rbp
  8041607cc3:	48 89 e5             	mov    %rsp,%rbp
  8041607cc6:	53                   	push   %rbx
  8041607cc7:	48 83 ec 08          	sub    $0x8,%rsp
    khpet = acpi_find_table("HPET");
  8041607ccb:	48 bf e5 b8 60 41 80 	movabs $0x804160b8e5,%rdi
  8041607cd2:	00 00 00 
  8041607cd5:	48 b8 7c 7a 60 41 80 	movabs $0x8041607a7c,%rax
  8041607cdc:	00 00 00 
  8041607cdf:	ff d0                	call   *%rax
    if(khpet == NULL){
  8041607ce1:	48 85 c0             	test   %rax,%rax
  8041607ce4:	74 39                	je     8041607d1f <get_hpet+0x61>
  8041607ce6:	48 89 c3             	mov    %rax,%rbx
    if(!validate_sdt_checksum((ACPISDTHeader*)khpet)){
  8041607ce9:	48 89 c7             	mov    %rax,%rdi
  8041607cec:	48 b8 59 7a 60 41 80 	movabs $0x8041607a59,%rax
  8041607cf3:	00 00 00 
  8041607cf6:	ff d0                	call   *%rax
  8041607cf8:	85 c0                	test   %eax,%eax
  8041607cfa:	74 4d                	je     8041607d49 <get_hpet+0x8b>
    if(khpet->hardware_rev_id == 0){
  8041607cfc:	80 7b 24 00          	cmpb   $0x0,0x24(%rbx)
  8041607d00:	74 6c                	je     8041607d6e <get_hpet+0xb0>
    if(khpet->counter_size != 1){
  8041607d02:	0f b6 43 25          	movzbl 0x25(%rbx),%eax
  8041607d06:	a8 20                	test   $0x20,%al
  8041607d08:	0f 84 8a 00 00 00    	je     8041607d98 <get_hpet+0xda>
    if(khpet->legacy_replacement != 1){
  8041607d0e:	84 c0                	test   %al,%al
  8041607d10:	0f 89 ac 00 00 00    	jns    8041607dc2 <get_hpet+0x104>
}
  8041607d16:	48 89 d8             	mov    %rbx,%rax
  8041607d19:	48 8b 5d f8          	mov    -0x8(%rbp),%rbx
  8041607d1d:	c9                   	leave  
  8041607d1e:	c3                   	ret    
        panic("get_hpet: unable to get HPET table");
  8041607d1f:	48 ba d0 b7 60 41 80 	movabs $0x804160b7d0,%rdx
  8041607d26:	00 00 00 
  8041607d29:	be bc 00 00 00       	mov    $0xbc,%esi
  8041607d2e:	48 bf d3 b8 60 41 80 	movabs $0x804160b8d3,%rdi
  8041607d35:	00 00 00 
  8041607d38:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607d3d:	48 b9 e3 03 60 41 80 	movabs $0x80416003e3,%rcx
  8041607d44:	00 00 00 
  8041607d47:	ff d1                	call   *%rcx
        panic("get_hpet: signature HPET table is invalid");
  8041607d49:	48 ba f8 b7 60 41 80 	movabs $0x804160b7f8,%rdx
  8041607d50:	00 00 00 
  8041607d53:	be c0 00 00 00       	mov    $0xc0,%esi
  8041607d58:	48 bf d3 b8 60 41 80 	movabs $0x804160b8d3,%rdi
  8041607d5f:	00 00 00 
  8041607d62:	48 b9 e3 03 60 41 80 	movabs $0x80416003e3,%rcx
  8041607d69:	00 00 00 
  8041607d6c:	ff d1                	call   *%rcx
        panic("get_hpet: hardware_rev_id is 0");
  8041607d6e:	48 ba 28 b8 60 41 80 	movabs $0x804160b828,%rdx
  8041607d75:	00 00 00 
  8041607d78:	be c4 00 00 00       	mov    $0xc4,%esi
  8041607d7d:	48 bf d3 b8 60 41 80 	movabs $0x804160b8d3,%rdi
  8041607d84:	00 00 00 
  8041607d87:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607d8c:	48 b9 e3 03 60 41 80 	movabs $0x80416003e3,%rcx
  8041607d93:	00 00 00 
  8041607d96:	ff d1                	call   *%rcx
        panic("get_hpet: hpet is not enable to run in 64 mode");
  8041607d98:	48 ba 48 b8 60 41 80 	movabs $0x804160b848,%rdx
  8041607d9f:	00 00 00 
  8041607da2:	be c8 00 00 00       	mov    $0xc8,%esi
  8041607da7:	48 bf d3 b8 60 41 80 	movabs $0x804160b8d3,%rdi
  8041607dae:	00 00 00 
  8041607db1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607db6:	48 b9 e3 03 60 41 80 	movabs $0x80416003e3,%rcx
  8041607dbd:	00 00 00 
  8041607dc0:	ff d1                	call   *%rcx
        panic("get_hpet: hpet doesn't support legacy replacement");
  8041607dc2:	48 ba 78 b8 60 41 80 	movabs $0x804160b878,%rdx
  8041607dc9:	00 00 00 
  8041607dcc:	be cc 00 00 00       	mov    $0xcc,%esi
  8041607dd1:	48 bf d3 b8 60 41 80 	movabs $0x804160b8d3,%rdi
  8041607dd8:	00 00 00 
  8041607ddb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607de0:	48 b9 e3 03 60 41 80 	movabs $0x80416003e3,%rcx
  8041607de7:	00 00 00 
  8041607dea:	ff d1                	call   *%rcx

0000008041607dec <hpet_register>:
hpet_register(void) {
  8041607dec:	f3 0f 1e fa          	endbr64 
  8041607df0:	55                   	push   %rbp
  8041607df1:	48 89 e5             	mov    %rsp,%rbp
    HPET *hpet_timer = get_hpet();
  8041607df4:	48 b8 be 7c 60 41 80 	movabs $0x8041607cbe,%rax
  8041607dfb:	00 00 00 
  8041607dfe:	ff d0                	call   *%rax
    if (!hpet_timer->address.address) panic("hpet is unavailable\n");
  8041607e00:	48 8b 78 2c          	mov    0x2c(%rax),%rdi
  8041607e04:	48 85 ff             	test   %rdi,%rdi
  8041607e07:	74 13                	je     8041607e1c <hpet_register+0x30>
    return mmio_map_region(paddr, sizeof(HPETRegister));
  8041607e09:	be 00 04 00 00       	mov    $0x400,%esi
  8041607e0e:	48 b8 fa 79 60 41 80 	movabs $0x80416079fa,%rax
  8041607e15:	00 00 00 
  8041607e18:	ff d0                	call   *%rax
}
  8041607e1a:	5d                   	pop    %rbp
  8041607e1b:	c3                   	ret    
    if (!hpet_timer->address.address) panic("hpet is unavailable\n");
  8041607e1c:	48 ba ea b8 60 41 80 	movabs $0x804160b8ea,%rdx
  8041607e23:	00 00 00 
  8041607e26:	be d9 00 00 00       	mov    $0xd9,%esi
  8041607e2b:	48 bf d3 b8 60 41 80 	movabs $0x804160b8d3,%rdi
  8041607e32:	00 00 00 
  8041607e35:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607e3a:	48 b9 e3 03 60 41 80 	movabs $0x80416003e3,%rcx
  8041607e41:	00 00 00 
  8041607e44:	ff d1                	call   *%rcx

0000008041607e46 <hpet_init>:
hpet_init() {
  8041607e46:	f3 0f 1e fa          	endbr64 
    if (hpetReg == NULL) {
  8041607e4a:	48 b8 78 55 e4 41 80 	movabs $0x8041e45578,%rax
  8041607e51:	00 00 00 
  8041607e54:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041607e58:	74 01                	je     8041607e5b <hpet_init+0x15>
  8041607e5a:	c3                   	ret    
hpet_init() {
  8041607e5b:	55                   	push   %rbp
  8041607e5c:	48 89 e5             	mov    %rsp,%rbp
    asm volatile("inb %w1,%0"
  8041607e5f:	ba 70 00 00 00       	mov    $0x70,%edx
  8041607e64:	ec                   	in     (%dx),%al
    outb(CMOS_CMD, inb(CMOS_CMD) | CMOS_NMI_LOCK);
  8041607e65:	83 c8 80             	or     $0xffffff80,%eax
    asm volatile("outb %0,%w1" ::"a"(data), "d"(port));
  8041607e68:	ee                   	out    %al,(%dx)
        hpetReg = hpet_register();
  8041607e69:	48 b8 ec 7d 60 41 80 	movabs $0x8041607dec,%rax
  8041607e70:	00 00 00 
  8041607e73:	ff d0                	call   *%rax
  8041607e75:	48 89 c1             	mov    %rax,%rcx
  8041607e78:	48 a3 78 55 e4 41 80 	movabs %rax,0x8041e45578
  8041607e7f:	00 00 00 
        uint64_t cap = hpetReg->GCAP_ID;
  8041607e82:	48 8b 10             	mov    (%rax),%rdx
        hpetFemto = (uintptr_t)(cap >> 32);
  8041607e85:	48 89 d6             	mov    %rdx,%rsi
  8041607e88:	48 c1 ee 20          	shr    $0x20,%rsi
  8041607e8c:	48 89 f0             	mov    %rsi,%rax
  8041607e8f:	48 a3 70 55 e4 41 80 	movabs %rax,0x8041e45570
  8041607e96:	00 00 00 
        if (!(cap & HPET_LEG_RT_CAP)) panic("HPET has no LegacyReplacement mode");
  8041607e99:	f6 c6 80             	test   $0x80,%dh
  8041607e9c:	74 34                	je     8041607ed2 <hpet_init+0x8c>
        hpetFreq = (1 * Peta) / hpetFemto;
  8041607e9e:	48 b8 00 80 c6 a4 7e 	movabs $0x38d7ea4c68000,%rax
  8041607ea5:	8d 03 00 
  8041607ea8:	ba 00 00 00 00       	mov    $0x0,%edx
  8041607ead:	48 f7 f6             	div    %rsi
  8041607eb0:	48 a3 68 55 e4 41 80 	movabs %rax,0x8041e45568
  8041607eb7:	00 00 00 
        hpetReg->GEN_CONF |= HPET_ENABLE_CNF;
  8041607eba:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8041607ebe:	48 83 c8 01          	or     $0x1,%rax
  8041607ec2:	48 89 41 10          	mov    %rax,0x10(%rcx)
    asm volatile("inb %w1,%0"
  8041607ec6:	ba 70 00 00 00       	mov    $0x70,%edx
  8041607ecb:	ec                   	in     (%dx),%al
    asm volatile("outb %0,%w1" ::"a"(data), "d"(port));
  8041607ecc:	83 e0 7f             	and    $0x7f,%eax
  8041607ecf:	ee                   	out    %al,(%dx)
}
  8041607ed0:	5d                   	pop    %rbp
  8041607ed1:	c3                   	ret    
        if (!(cap & HPET_LEG_RT_CAP)) panic("HPET has no LegacyReplacement mode");
  8041607ed2:	48 ba b0 b8 60 41 80 	movabs $0x804160b8b0,%rdx
  8041607ed9:	00 00 00 
  8041607edc:	be 10 01 00 00       	mov    $0x110,%esi
  8041607ee1:	48 bf d3 b8 60 41 80 	movabs $0x804160b8d3,%rdi
  8041607ee8:	00 00 00 
  8041607eeb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607ef0:	48 b9 e3 03 60 41 80 	movabs $0x80416003e3,%rcx
  8041607ef7:	00 00 00 
  8041607efa:	ff d1                	call   *%rcx

0000008041607efc <hpet_print_struct>:
hpet_print_struct(void) {
  8041607efc:	f3 0f 1e fa          	endbr64 
  8041607f00:	55                   	push   %rbp
  8041607f01:	48 89 e5             	mov    %rsp,%rbp
  8041607f04:	41 54                	push   %r12
  8041607f06:	53                   	push   %rbx
    HPET *hpet = get_hpet();
  8041607f07:	48 b8 be 7c 60 41 80 	movabs $0x8041607cbe,%rax
  8041607f0e:	00 00 00 
  8041607f11:	ff d0                	call   *%rax
    assert(hpet != NULL);
  8041607f13:	48 85 c0             	test   %rax,%rax
  8041607f16:	0f 84 da 01 00 00    	je     80416080f6 <hpet_print_struct+0x1fa>
  8041607f1c:	48 89 c3             	mov    %rax,%rbx
    cprintf("signature = %s\n", (hpet->h).Signature);
  8041607f1f:	48 89 c6             	mov    %rax,%rsi
  8041607f22:	48 bf 0c b9 60 41 80 	movabs $0x804160b90c,%rdi
  8041607f29:	00 00 00 
  8041607f2c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607f31:	49 bc b7 6f 60 41 80 	movabs $0x8041606fb7,%r12
  8041607f38:	00 00 00 
  8041607f3b:	41 ff d4             	call   *%r12
    cprintf("length = %08x\n", (hpet->h).Length);
  8041607f3e:	8b 73 04             	mov    0x4(%rbx),%esi
  8041607f41:	48 bf 1c b9 60 41 80 	movabs $0x804160b91c,%rdi
  8041607f48:	00 00 00 
  8041607f4b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607f50:	41 ff d4             	call   *%r12
    cprintf("revision = %08x\n", (hpet->h).Revision);
  8041607f53:	0f b6 73 08          	movzbl 0x8(%rbx),%esi
  8041607f57:	48 bf 40 b9 60 41 80 	movabs $0x804160b940,%rdi
  8041607f5e:	00 00 00 
  8041607f61:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607f66:	41 ff d4             	call   *%r12
    cprintf("checksum = %08x\n", (hpet->h).Checksum);
  8041607f69:	0f b6 73 09          	movzbl 0x9(%rbx),%esi
  8041607f6d:	48 bf 2b b9 60 41 80 	movabs $0x804160b92b,%rdi
  8041607f74:	00 00 00 
  8041607f77:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607f7c:	41 ff d4             	call   *%r12
    cprintf("oem_revision = %08x\n", (hpet->h).OEMRevision);
  8041607f7f:	8b 73 18             	mov    0x18(%rbx),%esi
  8041607f82:	48 bf 3c b9 60 41 80 	movabs $0x804160b93c,%rdi
  8041607f89:	00 00 00 
  8041607f8c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607f91:	41 ff d4             	call   *%r12
    cprintf("creator_id = %08x\n", (hpet->h).CreatorID);
  8041607f94:	8b 73 1c             	mov    0x1c(%rbx),%esi
  8041607f97:	48 bf 51 b9 60 41 80 	movabs $0x804160b951,%rdi
  8041607f9e:	00 00 00 
  8041607fa1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607fa6:	41 ff d4             	call   *%r12
    cprintf("creator_revision = %08x\n", (hpet->h).CreatorRevision);
  8041607fa9:	8b 73 20             	mov    0x20(%rbx),%esi
  8041607fac:	48 bf 64 b9 60 41 80 	movabs $0x804160b964,%rdi
  8041607fb3:	00 00 00 
  8041607fb6:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607fbb:	41 ff d4             	call   *%r12
    cprintf("hardware_rev_id = %08x\n", hpet->hardware_rev_id);
  8041607fbe:	0f b6 73 24          	movzbl 0x24(%rbx),%esi
  8041607fc2:	48 bf 7d b9 60 41 80 	movabs $0x804160b97d,%rdi
  8041607fc9:	00 00 00 
  8041607fcc:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607fd1:	41 ff d4             	call   *%r12
    cprintf("comparator_count = %08x\n", hpet->comparator_count);
  8041607fd4:	0f b6 73 25          	movzbl 0x25(%rbx),%esi
  8041607fd8:	83 e6 1f             	and    $0x1f,%esi
  8041607fdb:	48 bf 95 b9 60 41 80 	movabs $0x804160b995,%rdi
  8041607fe2:	00 00 00 
  8041607fe5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607fea:	41 ff d4             	call   *%r12
    cprintf("counter_size = %08x\n", hpet->counter_size);
  8041607fed:	0f b6 73 25          	movzbl 0x25(%rbx),%esi
  8041607ff1:	40 c0 ee 05          	shr    $0x5,%sil
  8041607ff5:	83 e6 01             	and    $0x1,%esi
  8041607ff8:	48 bf ae b9 60 41 80 	movabs $0x804160b9ae,%rdi
  8041607fff:	00 00 00 
  8041608002:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608007:	41 ff d4             	call   *%r12
    cprintf("reserved = %08x\n", hpet->reserved);
  804160800a:	0f b6 73 25          	movzbl 0x25(%rbx),%esi
  804160800e:	40 c0 ee 06          	shr    $0x6,%sil
  8041608012:	83 e6 01             	and    $0x1,%esi
  8041608015:	48 bf c3 b9 60 41 80 	movabs $0x804160b9c3,%rdi
  804160801c:	00 00 00 
  804160801f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608024:	41 ff d4             	call   *%r12
    cprintf("legacy_replacement = %08x\n", hpet->legacy_replacement);
  8041608027:	0f b6 73 25          	movzbl 0x25(%rbx),%esi
  804160802b:	40 c0 ee 07          	shr    $0x7,%sil
  804160802f:	40 0f b6 f6          	movzbl %sil,%esi
  8041608033:	48 bf d4 b9 60 41 80 	movabs $0x804160b9d4,%rdi
  804160803a:	00 00 00 
  804160803d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608042:	41 ff d4             	call   *%r12
    cprintf("pci_vendor_id = %08x\n", hpet->pci_vendor_id);
  8041608045:	0f b7 73 26          	movzwl 0x26(%rbx),%esi
  8041608049:	48 bf ef b9 60 41 80 	movabs $0x804160b9ef,%rdi
  8041608050:	00 00 00 
  8041608053:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608058:	41 ff d4             	call   *%r12
    cprintf("hpet_number = %08x\n", hpet->hpet_number);
  804160805b:	0f b6 73 34          	movzbl 0x34(%rbx),%esi
  804160805f:	48 bf 05 ba 60 41 80 	movabs $0x804160ba05,%rdi
  8041608066:	00 00 00 
  8041608069:	b8 00 00 00 00       	mov    $0x0,%eax
  804160806e:	41 ff d4             	call   *%r12
    cprintf("minimum_tick = %08x\n", hpet->minimum_tick);
  8041608071:	0f b7 73 35          	movzwl 0x35(%rbx),%esi
  8041608075:	48 bf 19 ba 60 41 80 	movabs $0x804160ba19,%rdi
  804160807c:	00 00 00 
  804160807f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608084:	41 ff d4             	call   *%r12
    cprintf("address_structure:\n");
  8041608087:	48 bf 2e ba 60 41 80 	movabs $0x804160ba2e,%rdi
  804160808e:	00 00 00 
  8041608091:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608096:	41 ff d4             	call   *%r12
    cprintf("address_space_id = %08x\n", (hpet->address).address_space_id);
  8041608099:	0f b6 73 28          	movzbl 0x28(%rbx),%esi
  804160809d:	48 bf 42 ba 60 41 80 	movabs $0x804160ba42,%rdi
  80416080a4:	00 00 00 
  80416080a7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416080ac:	41 ff d4             	call   *%r12
    cprintf("register_bit_width = %08x\n", (hpet->address).register_bit_width);
  80416080af:	0f b6 73 29          	movzbl 0x29(%rbx),%esi
  80416080b3:	48 bf 5b ba 60 41 80 	movabs $0x804160ba5b,%rdi
  80416080ba:	00 00 00 
  80416080bd:	b8 00 00 00 00       	mov    $0x0,%eax
  80416080c2:	41 ff d4             	call   *%r12
    cprintf("register_bit_offset = %08x\n", (hpet->address).register_bit_offset);
  80416080c5:	0f b6 73 2a          	movzbl 0x2a(%rbx),%esi
  80416080c9:	48 bf 76 ba 60 41 80 	movabs $0x804160ba76,%rdi
  80416080d0:	00 00 00 
  80416080d3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416080d8:	41 ff d4             	call   *%r12
    cprintf("address = %08lx\n", (unsigned long)(hpet->address).address);
  80416080db:	48 8b 73 2c          	mov    0x2c(%rbx),%rsi
  80416080df:	48 bf 92 ba 60 41 80 	movabs $0x804160ba92,%rdi
  80416080e6:	00 00 00 
  80416080e9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416080ee:	41 ff d4             	call   *%r12
}
  80416080f1:	5b                   	pop    %rbx
  80416080f2:	41 5c                	pop    %r12
  80416080f4:	5d                   	pop    %rbp
  80416080f5:	c3                   	ret    
    assert(hpet != NULL);
  80416080f6:	48 b9 ff b8 60 41 80 	movabs $0x804160b8ff,%rcx
  80416080fd:	00 00 00 
  8041608100:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041608107:	00 00 00 
  804160810a:	be e3 00 00 00       	mov    $0xe3,%esi
  804160810f:	48 bf d3 b8 60 41 80 	movabs $0x804160b8d3,%rdi
  8041608116:	00 00 00 
  8041608119:	b8 00 00 00 00       	mov    $0x0,%eax
  804160811e:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041608125:	00 00 00 
  8041608128:	41 ff d0             	call   *%r8

000000804160812b <hpet_freq>:
uint64_t hpet_freq(){
  804160812b:	f3 0f 1e fa          	endbr64 
}
  804160812f:	48 a1 68 55 e4 41 80 	movabs 0x8041e45568,%rax
  8041608136:	00 00 00 
  8041608139:	c3                   	ret    

000000804160813a <hpet_print_reg>:
hpet_print_reg(void) {
  804160813a:	f3 0f 1e fa          	endbr64 
  804160813e:	55                   	push   %rbp
  804160813f:	48 89 e5             	mov    %rsp,%rbp
  8041608142:	41 54                	push   %r12
  8041608144:	53                   	push   %rbx
    cprintf("GCAP_ID = %016lx\n", (unsigned long)hpetReg->GCAP_ID);
  8041608145:	49 bc 78 55 e4 41 80 	movabs $0x8041e45578,%r12
  804160814c:	00 00 00 
  804160814f:	49 8b 04 24          	mov    (%r12),%rax
  8041608153:	48 8b 30             	mov    (%rax),%rsi
  8041608156:	48 bf a3 ba 60 41 80 	movabs $0x804160baa3,%rdi
  804160815d:	00 00 00 
  8041608160:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608165:	48 bb b7 6f 60 41 80 	movabs $0x8041606fb7,%rbx
  804160816c:	00 00 00 
  804160816f:	ff d3                	call   *%rbx
    cprintf("GEN_CONF = %016lx\n", (unsigned long)hpetReg->GEN_CONF);
  8041608171:	49 8b 04 24          	mov    (%r12),%rax
  8041608175:	48 8b 70 10          	mov    0x10(%rax),%rsi
  8041608179:	48 bf b5 ba 60 41 80 	movabs $0x804160bab5,%rdi
  8041608180:	00 00 00 
  8041608183:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608188:	ff d3                	call   *%rbx
    cprintf("GINTR_STA = %016lx\n", (unsigned long)hpetReg->GINTR_STA);
  804160818a:	49 8b 04 24          	mov    (%r12),%rax
  804160818e:	48 8b 70 20          	mov    0x20(%rax),%rsi
  8041608192:	48 bf c8 ba 60 41 80 	movabs $0x804160bac8,%rdi
  8041608199:	00 00 00 
  804160819c:	b8 00 00 00 00       	mov    $0x0,%eax
  80416081a1:	ff d3                	call   *%rbx
    cprintf("MAIN_CNT = %016lx\n", (unsigned long)hpetReg->MAIN_CNT);
  80416081a3:	49 8b 04 24          	mov    (%r12),%rax
  80416081a7:	48 8b b0 f0 00 00 00 	mov    0xf0(%rax),%rsi
  80416081ae:	48 bf dc ba 60 41 80 	movabs $0x804160badc,%rdi
  80416081b5:	00 00 00 
  80416081b8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416081bd:	ff d3                	call   *%rbx
    cprintf("TIM0_CONF = %016lx\n", (unsigned long)hpetReg->TIM0_CONF);
  80416081bf:	49 8b 04 24          	mov    (%r12),%rax
  80416081c3:	48 8b b0 00 01 00 00 	mov    0x100(%rax),%rsi
  80416081ca:	48 bf ef ba 60 41 80 	movabs $0x804160baef,%rdi
  80416081d1:	00 00 00 
  80416081d4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416081d9:	ff d3                	call   *%rbx
    cprintf("TIM0_COMP = %016lx\n", (unsigned long)hpetReg->TIM0_COMP);
  80416081db:	49 8b 04 24          	mov    (%r12),%rax
  80416081df:	48 8b b0 08 01 00 00 	mov    0x108(%rax),%rsi
  80416081e6:	48 bf 03 bb 60 41 80 	movabs $0x804160bb03,%rdi
  80416081ed:	00 00 00 
  80416081f0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416081f5:	ff d3                	call   *%rbx
    cprintf("TIM0_FSB = %016lx\n", (unsigned long)hpetReg->TIM0_FSB);
  80416081f7:	49 8b 04 24          	mov    (%r12),%rax
  80416081fb:	48 8b b0 10 01 00 00 	mov    0x110(%rax),%rsi
  8041608202:	48 bf 17 bb 60 41 80 	movabs $0x804160bb17,%rdi
  8041608209:	00 00 00 
  804160820c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608211:	ff d3                	call   *%rbx
    cprintf("TIM1_CONF = %016lx\n", (unsigned long)hpetReg->TIM1_CONF);
  8041608213:	49 8b 04 24          	mov    (%r12),%rax
  8041608217:	48 8b b0 20 01 00 00 	mov    0x120(%rax),%rsi
  804160821e:	48 bf 2a bb 60 41 80 	movabs $0x804160bb2a,%rdi
  8041608225:	00 00 00 
  8041608228:	b8 00 00 00 00       	mov    $0x0,%eax
  804160822d:	ff d3                	call   *%rbx
    cprintf("TIM1_COMP = %016lx\n", (unsigned long)hpetReg->TIM1_COMP);
  804160822f:	49 8b 04 24          	mov    (%r12),%rax
  8041608233:	48 8b b0 28 01 00 00 	mov    0x128(%rax),%rsi
  804160823a:	48 bf 3e bb 60 41 80 	movabs $0x804160bb3e,%rdi
  8041608241:	00 00 00 
  8041608244:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608249:	ff d3                	call   *%rbx
    cprintf("TIM1_FSB = %016lx\n", (unsigned long)hpetReg->TIM1_FSB);
  804160824b:	49 8b 04 24          	mov    (%r12),%rax
  804160824f:	48 8b b0 30 01 00 00 	mov    0x130(%rax),%rsi
  8041608256:	48 bf 52 bb 60 41 80 	movabs $0x804160bb52,%rdi
  804160825d:	00 00 00 
  8041608260:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608265:	ff d3                	call   *%rbx
    cprintf("TIM2_CONF = %016lx\n", (unsigned long)hpetReg->TIM2_CONF);
  8041608267:	49 8b 04 24          	mov    (%r12),%rax
  804160826b:	48 8b b0 40 01 00 00 	mov    0x140(%rax),%rsi
  8041608272:	48 bf 65 bb 60 41 80 	movabs $0x804160bb65,%rdi
  8041608279:	00 00 00 
  804160827c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608281:	ff d3                	call   *%rbx
    cprintf("TIM2_COMP = %016lx\n", (unsigned long)hpetReg->TIM2_COMP);
  8041608283:	49 8b 04 24          	mov    (%r12),%rax
  8041608287:	48 8b b0 48 01 00 00 	mov    0x148(%rax),%rsi
  804160828e:	48 bf 79 bb 60 41 80 	movabs $0x804160bb79,%rdi
  8041608295:	00 00 00 
  8041608298:	b8 00 00 00 00       	mov    $0x0,%eax
  804160829d:	ff d3                	call   *%rbx
    cprintf("TIM2_FSB = %016lx\n", (unsigned long)hpetReg->TIM2_FSB);
  804160829f:	49 8b 04 24          	mov    (%r12),%rax
  80416082a3:	48 8b b0 50 01 00 00 	mov    0x150(%rax),%rsi
  80416082aa:	48 bf 8d bb 60 41 80 	movabs $0x804160bb8d,%rdi
  80416082b1:	00 00 00 
  80416082b4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416082b9:	ff d3                	call   *%rbx
}
  80416082bb:	5b                   	pop    %rbx
  80416082bc:	41 5c                	pop    %r12
  80416082be:	5d                   	pop    %rbp
  80416082bf:	c3                   	ret    

00000080416082c0 <hpet_get_main_cnt>:
hpet_get_main_cnt(void) {
  80416082c0:	f3 0f 1e fa          	endbr64 
    return hpetReg->MAIN_CNT;
  80416082c4:	48 a1 78 55 e4 41 80 	movabs 0x8041e45578,%rax
  80416082cb:	00 00 00 
  80416082ce:	48 8b 80 f0 00 00 00 	mov    0xf0(%rax),%rax
}
  80416082d5:	c3                   	ret    

00000080416082d6 <pmtimer_get_timeval>:

uint32_t
pmtimer_get_timeval(void) {
  80416082d6:	f3 0f 1e fa          	endbr64 
  80416082da:	55                   	push   %rbp
  80416082db:	48 89 e5             	mov    %rsp,%rbp
    FADT *fadt = get_fadt();
  80416082de:	48 b8 fe 7b 60 41 80 	movabs $0x8041607bfe,%rax
  80416082e5:	00 00 00 
  80416082e8:	ff d0                	call   *%rax
    asm volatile("inl %w1,%0"
  80416082ea:	8b 50 4c             	mov    0x4c(%rax),%edx
  80416082ed:	ed                   	in     (%dx),%eax
    return inl(fadt->PMTimerBlock);
}
  80416082ee:	5d                   	pop    %rbp
  80416082ef:	c3                   	ret    

00000080416082f0 <pmtimer_cpu_frequency>:

/* Calculate CPU frequency in Hz with the help with ACPI PowerManagement timer.
 * HINT Use pmtimer_get_timeval function and do not forget that ACPI PM timer
 *      can be 24-bit or 32-bit. */
uint64_t
pmtimer_cpu_frequency(void) {
  80416082f0:	f3 0f 1e fa          	endbr64 
  80416082f4:	55                   	push   %rbp
  80416082f5:	48 89 e5             	mov    %rsp,%rbp
  80416082f8:	41 54                	push   %r12
  80416082fa:	53                   	push   %rbx

    // LAB 5: Your code here

    //! 32 bit error?

    uint64_t pm_init_val = pmtimer_get_timeval();
  80416082fb:	48 b8 d6 82 60 41 80 	movabs $0x80416082d6,%rax
  8041608302:	00 00 00 
  8041608305:	ff d0                	call   *%rax
  8041608307:	41 89 c4             	mov    %eax,%r12d
    asm volatile("rdtsc"
  804160830a:	0f 31                	rdtsc  
    return (uint64_t)lo | ((uint64_t)hi << 32);
  804160830c:	48 c1 e2 20          	shl    $0x20,%rdx
  8041608310:	89 c0                	mov    %eax,%eax
  8041608312:	48 89 d1             	mov    %rdx,%rcx
  8041608315:	48 09 c1             	or     %rax,%rcx
  8041608318:	b8 10 27 00 00       	mov    $0x2710,%eax
    uint64_t tsc_init = read_tsc();
    
    for(int i = 0; i < 10000; i++)
        asm volatile("pause");
  804160831d:	f3 90                	pause  
    for(int i = 0; i < 10000; i++)
  804160831f:	83 e8 01             	sub    $0x1,%eax
  8041608322:	75 f9                	jne    804160831d <pmtimer_cpu_frequency+0x2d>
    asm volatile("rdtsc"
  8041608324:	0f 31                	rdtsc  
    return (uint64_t)lo | ((uint64_t)hi << 32);
  8041608326:	48 c1 e2 20          	shl    $0x20,%rdx
  804160832a:	89 c0                	mov    %eax,%eax
  804160832c:	48 09 c2             	or     %rax,%rdx

    uint64_t tsc_offset = read_tsc() - tsc_init;
  804160832f:	48 89 d3             	mov    %rdx,%rbx
  8041608332:	48 29 cb             	sub    %rcx,%rbx
    uint64_t pm_cur_val = pmtimer_get_timeval();
  8041608335:	48 b8 d6 82 60 41 80 	movabs $0x80416082d6,%rax
  804160833c:	00 00 00 
  804160833f:	ff d0                	call   *%rax
  8041608341:	89 c0                	mov    %eax,%eax
    uint64_t pm_offset = 0;

    if(pm_cur_val >= pm_init_val){
  8041608343:	49 39 c4             	cmp    %rax,%r12
  8041608346:	77 1a                	ja     8041608362 <pmtimer_cpu_frequency+0x72>
        // no overflow
        pm_offset = pm_cur_val - pm_init_val;
  8041608348:	4c 29 e0             	sub    %r12,%rax
  804160834b:	48 89 c1             	mov    %rax,%rcx
    else{
        // overflow 32-bit case
        pm_offset = UINT32_MAX - pm_init_val + pm_cur_val;
    }

    cpu_freq = tsc_offset * PM_FREQ / (pm_offset);
  804160834e:	48 69 c3 99 9e 36 00 	imul   $0x369e99,%rbx,%rax
  8041608355:	ba 00 00 00 00       	mov    $0x0,%edx
  804160835a:	48 f7 f1             	div    %rcx

    return cpu_freq;
}
  804160835d:	5b                   	pop    %rbx
  804160835e:	41 5c                	pop    %r12
  8041608360:	5d                   	pop    %rbp
  8041608361:	c3                   	ret    
    else if(pm_init_val - pm_cur_val <= 0x00FFFFFF){
  8041608362:	4c 89 e2             	mov    %r12,%rdx
  8041608365:	48 29 c2             	sub    %rax,%rdx
  8041608368:	48 81 fa ff ff ff 00 	cmp    $0xffffff,%rdx
  804160836f:	77 0c                	ja     804160837d <pmtimer_cpu_frequency+0x8d>
        pm_offset = 0x00FFFFFF - pm_init_val + pm_cur_val;
  8041608371:	4c 29 e0             	sub    %r12,%rax
  8041608374:	48 8d 88 ff ff ff 00 	lea    0xffffff(%rax),%rcx
  804160837b:	eb d1                	jmp    804160834e <pmtimer_cpu_frequency+0x5e>
        pm_offset = UINT32_MAX - pm_init_val + pm_cur_val;
  804160837d:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8041608382:	4c 29 e2             	sub    %r12,%rdx
  8041608385:	48 8d 0c 02          	lea    (%rdx,%rax,1),%rcx
  8041608389:	eb c3                	jmp    804160834e <pmtimer_cpu_frequency+0x5e>

000000804160838b <sched_halt>:
}

/* Halt this CPU when there is nothing to do. Wait until the
 * timer interrupt wakes it up. This function never returns */
_Noreturn void
sched_halt(void) {
  804160838b:	f3 0f 1e fa          	endbr64 

    /* For debugging and testing purposes, if there are no runnable
     * environments in the system, then drop into the kernel monitor */
    int i;
    for (i = 0; i < NENV; i++)
  804160838f:	48 a1 20 d7 62 41 80 	movabs 0x804162d720,%rax
  8041608396:	00 00 00 
  8041608399:	48 8d 90 d4 00 00 00 	lea    0xd4(%rax),%rdx
  80416083a0:	b9 00 00 00 00       	mov    $0x0,%ecx
        if (envs[i].env_status == ENV_RUNNABLE ||
  80416083a5:	8b 02                	mov    (%rdx),%eax
  80416083a7:	83 e8 02             	sub    $0x2,%eax
  80416083aa:	83 f8 01             	cmp    $0x1,%eax
  80416083ad:	76 49                	jbe    80416083f8 <sched_halt+0x6d>
    for (i = 0; i < NENV; i++)
  80416083af:	83 c1 01             	add    $0x1,%ecx
  80416083b2:	48 81 c2 00 01 00 00 	add    $0x100,%rdx
  80416083b9:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  80416083bf:	75 e4                	jne    80416083a5 <sched_halt+0x1a>
sched_halt(void) {
  80416083c1:	55                   	push   %rbp
  80416083c2:	48 89 e5             	mov    %rsp,%rbp
  80416083c5:	53                   	push   %rbx
  80416083c6:	48 83 ec 08          	sub    $0x8,%rsp
            envs[i].env_status == ENV_RUNNING) break;
    if (i == NENV) {
        cprintf("No runnable environments in the system!\n");
  80416083ca:	48 bf b0 bb 60 41 80 	movabs $0x804160bbb0,%rdi
  80416083d1:	00 00 00 
  80416083d4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416083d9:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  80416083e0:	00 00 00 
  80416083e3:	ff d2                	call   *%rdx
        for (;;) monitor(NULL);
  80416083e5:	48 bb 6f 47 60 41 80 	movabs $0x804160476f,%rbx
  80416083ec:	00 00 00 
  80416083ef:	bf 00 00 00 00       	mov    $0x0,%edi
  80416083f4:	ff d3                	call   *%rbx
  80416083f6:	eb f7                	jmp    80416083ef <sched_halt+0x64>
    if (i == NENV) {
  80416083f8:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  80416083fe:	74 c1                	je     80416083c1 <sched_halt+0x36>
    }

    /* Mark that no environment is running on CPU */
    curenv = NULL;
  8041608400:	48 b8 c0 43 e4 41 80 	movabs $0x8041e443c0,%rax
  8041608407:	00 00 00 
  804160840a:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

    /* Reset stack pointer, enable interrupts and then halt */
    asm volatile(
  8041608411:	48 a1 84 55 e4 41 80 	movabs 0x8041e45584,%rax
  8041608418:	00 00 00 
  804160841b:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
  8041608422:	48 89 c4             	mov    %rax,%rsp
  8041608425:	6a 00                	push   $0x0
  8041608427:	6a 00                	push   $0x0
  8041608429:	fb                   	sti    
  804160842a:	f4                   	hlt    
            "pushq $0\n"
            "sti\n"
            "hlt\n" ::"a"(cpu_ts.ts_rsp0));

    /* Unreachable */
    for (;;)
  804160842b:	eb fe                	jmp    804160842b <sched_halt+0xa0>

000000804160842d <sched_yield>:
sched_yield(void) {
  804160842d:	f3 0f 1e fa          	endbr64 
  8041608431:	55                   	push   %rbp
  8041608432:	48 89 e5             	mov    %rsp,%rbp
    if(curenv != NULL){
  8041608435:	48 b8 c0 43 e4 41 80 	movabs $0x8041e443c0,%rax
  804160843c:	00 00 00 
  804160843f:	48 8b 10             	mov    (%rax),%rdx
  8041608442:	48 85 d2             	test   %rdx,%rdx
  8041608445:	74 6c                	je     80416084b3 <sched_yield+0x86>
        active_env_ind = (size_t)(curenv - envs);
  8041608447:	48 a1 20 d7 62 41 80 	movabs 0x804162d720,%rax
  804160844e:	00 00 00 
  8041608451:	48 29 c2             	sub    %rax,%rdx
  8041608454:	48 89 d1             	mov    %rdx,%rcx
  8041608457:	48 c1 f9 08          	sar    $0x8,%rcx
  804160845b:	48 89 ce             	mov    %rcx,%rsi
    for(size_t n_env = active_env_ind + 1; n_env < NENV; n_env++){
  804160845e:	48 8d 79 01          	lea    0x1(%rcx),%rdi
  8041608462:	48 81 ff ff 03 00 00 	cmp    $0x3ff,%rdi
  8041608469:	77 1e                	ja     8041608489 <sched_yield+0x5c>
        if(envs[n_env].env_status == ENV_RUNNABLE){
  804160846b:	48 89 fa             	mov    %rdi,%rdx
  804160846e:	48 c1 e2 08          	shl    $0x8,%rdx
  8041608472:	83 bc 10 d4 00 00 00 	cmpl   $0x2,0xd4(%rax,%rdx,1)
  8041608479:	02 
  804160847a:	74 14                	je     8041608490 <sched_yield+0x63>
    for(size_t n_env = active_env_ind + 1; n_env < NENV; n_env++){
  804160847c:	48 83 c7 01          	add    $0x1,%rdi
  8041608480:	48 81 ff 00 04 00 00 	cmp    $0x400,%rdi
  8041608487:	75 e2                	jne    804160846b <sched_yield+0x3e>
        for(size_t n_env = 0; n_env < active_env_ind; n_env++){
  8041608489:	48 85 c9             	test   %rcx,%rcx
  804160848c:	75 2a                	jne    80416084b8 <sched_yield+0x8b>
  804160848e:	eb 6b                	jmp    80416084fb <sched_yield+0xce>
    if(new_active_env_ind == invalid_active_env_id){
  8041608490:	48 83 ff ff          	cmp    $0xffffffffffffffff,%rdi
  8041608494:	74 f3                	je     8041608489 <sched_yield+0x5c>
        env_run(&envs[new_active_env_ind]);
  8041608496:	48 c1 e7 08          	shl    $0x8,%rdi
  804160849a:	48 a1 20 d7 62 41 80 	movabs 0x804162d720,%rax
  80416084a1:	00 00 00 
  80416084a4:	48 01 c7             	add    %rax,%rdi
  80416084a7:	48 b8 71 6b 60 41 80 	movabs $0x8041606b71,%rax
  80416084ae:	00 00 00 
  80416084b1:	ff d0                	call   *%rax
    size_t active_env_ind = NENV;
  80416084b3:	be 00 04 00 00       	mov    $0x400,%esi
            if(envs[n_env].env_status == ENV_RUNNABLE){
  80416084b8:	48 a1 20 d7 62 41 80 	movabs 0x804162d720,%rax
  80416084bf:	00 00 00 
        for(size_t n_env = 0; n_env < active_env_ind; n_env++){
  80416084c2:	bf 00 00 00 00       	mov    $0x0,%edi
            if(envs[n_env].env_status == ENV_RUNNABLE){
  80416084c7:	48 89 fa             	mov    %rdi,%rdx
  80416084ca:	48 c1 e2 08          	shl    $0x8,%rdx
  80416084ce:	83 bc 10 d4 00 00 00 	cmpl   $0x2,0xd4(%rax,%rdx,1)
  80416084d5:	02 
  80416084d6:	74 14                	je     80416084ec <sched_yield+0xbf>
        for(size_t n_env = 0; n_env < active_env_ind; n_env++){
  80416084d8:	48 83 c7 01          	add    $0x1,%rdi
  80416084dc:	48 39 fe             	cmp    %rdi,%rsi
  80416084df:	75 e6                	jne    80416084c7 <sched_yield+0x9a>
        if(active_env_ind < NENV && envs[active_env_ind].env_status == ENV_RUNNING ){
  80416084e1:	48 81 fe ff 03 00 00 	cmp    $0x3ff,%rsi
  80416084e8:	77 3e                	ja     8041608528 <sched_yield+0xfb>
  80416084ea:	eb 0f                	jmp    80416084fb <sched_yield+0xce>
  80416084ec:	48 81 fe ff 03 00 00 	cmp    $0x3ff,%rsi
  80416084f3:	77 29                	ja     804160851e <sched_yield+0xf1>
  80416084f5:	48 83 ff ff          	cmp    $0xffffffffffffffff,%rdi
  80416084f9:	75 23                	jne    804160851e <sched_yield+0xf1>
  80416084fb:	48 89 f2             	mov    %rsi,%rdx
  80416084fe:	48 c1 e2 08          	shl    $0x8,%rdx
  8041608502:	48 a1 20 d7 62 41 80 	movabs 0x804162d720,%rax
  8041608509:	00 00 00 
  804160850c:	83 bc 10 d4 00 00 00 	cmpl   $0x3,0xd4(%rax,%rdx,1)
  8041608513:	03 
  8041608514:	75 12                	jne    8041608528 <sched_yield+0xfb>
  8041608516:	48 89 f7             	mov    %rsi,%rdi
  8041608519:	e9 78 ff ff ff       	jmp    8041608496 <sched_yield+0x69>
    if(new_active_env_ind != invalid_active_env_id){
  804160851e:	48 83 ff ff          	cmp    $0xffffffffffffffff,%rdi
  8041608522:	0f 85 6e ff ff ff    	jne    8041608496 <sched_yield+0x69>
    cprintf("Halt\n");
  8041608528:	48 bf d9 bb 60 41 80 	movabs $0x804160bbd9,%rdi
  804160852f:	00 00 00 
  8041608532:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608537:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  804160853e:	00 00 00 
  8041608541:	ff d2                	call   *%rdx
    sched_halt();
  8041608543:	48 b8 8b 83 60 41 80 	movabs $0x804160838b,%rax
  804160854a:	00 00 00 
  804160854d:	ff d0                	call   *%rax

000000804160854f <load_kernel_dwarf_info>:
#include <kern/pmap.h>
#include <kern/env.h>
#include <inc/uefi.h>

void
load_kernel_dwarf_info(struct Dwarf_Addrs *addrs) {
  804160854f:	f3 0f 1e fa          	endbr64 
    addrs->aranges_begin = (uint8_t *)(uefi_lp->DebugArangesStart);
  8041608553:	48 b9 00 d0 62 41 80 	movabs $0x804162d000,%rcx
  804160855a:	00 00 00 
  804160855d:	48 8b 11             	mov    (%rcx),%rdx
  8041608560:	48 8b 72 58          	mov    0x58(%rdx),%rsi
  8041608564:	48 89 77 10          	mov    %rsi,0x10(%rdi)
    addrs->aranges_end = (uint8_t *)(uefi_lp->DebugArangesEnd);
  8041608568:	48 8b 72 60          	mov    0x60(%rdx),%rsi
  804160856c:	48 89 77 18          	mov    %rsi,0x18(%rdi)
    addrs->abbrev_begin = (uint8_t *)(uefi_lp->DebugAbbrevStart);
  8041608570:	48 8b 52 68          	mov    0x68(%rdx),%rdx
  8041608574:	48 89 17             	mov    %rdx,(%rdi)
    addrs->abbrev_end = (uint8_t *)(uefi_lp->DebugAbbrevEnd);
  8041608577:	48 8b 11             	mov    (%rcx),%rdx
  804160857a:	48 8b 4a 70          	mov    0x70(%rdx),%rcx
  804160857e:	48 89 4f 08          	mov    %rcx,0x8(%rdi)
    addrs->info_begin = (uint8_t *)(uefi_lp->DebugInfoStart);
  8041608582:	48 8b 4a 78          	mov    0x78(%rdx),%rcx
  8041608586:	48 89 4f 20          	mov    %rcx,0x20(%rdi)
    addrs->info_end = (uint8_t *)(uefi_lp->DebugInfoEnd);
  804160858a:	48 8b 8a 80 00 00 00 	mov    0x80(%rdx),%rcx
  8041608591:	48 89 4f 28          	mov    %rcx,0x28(%rdi)
    addrs->line_begin = (uint8_t *)(uefi_lp->DebugLineStart);
  8041608595:	48 8b 8a 88 00 00 00 	mov    0x88(%rdx),%rcx
  804160859c:	48 89 4f 30          	mov    %rcx,0x30(%rdi)
    addrs->line_end = (uint8_t *)(uefi_lp->DebugLineEnd);
  80416085a0:	48 8b 8a 90 00 00 00 	mov    0x90(%rdx),%rcx
  80416085a7:	48 89 4f 38          	mov    %rcx,0x38(%rdi)
    addrs->str_begin = (uint8_t *)(uefi_lp->DebugStrStart);
  80416085ab:	48 8b 8a 98 00 00 00 	mov    0x98(%rdx),%rcx
  80416085b2:	48 89 4f 40          	mov    %rcx,0x40(%rdi)
    addrs->str_end = (uint8_t *)(uefi_lp->DebugStrEnd);
  80416085b6:	48 8b 8a a0 00 00 00 	mov    0xa0(%rdx),%rcx
  80416085bd:	48 89 4f 48          	mov    %rcx,0x48(%rdi)
    addrs->pubnames_begin = (uint8_t *)(uefi_lp->DebugPubnamesStart);
  80416085c1:	48 8b 8a a8 00 00 00 	mov    0xa8(%rdx),%rcx
  80416085c8:	48 89 4f 50          	mov    %rcx,0x50(%rdi)
    addrs->pubnames_end = (uint8_t *)(uefi_lp->DebugPubnamesEnd);
  80416085cc:	48 8b 8a b0 00 00 00 	mov    0xb0(%rdx),%rcx
  80416085d3:	48 89 4f 58          	mov    %rcx,0x58(%rdi)
    addrs->pubtypes_begin = (uint8_t *)(uefi_lp->DebugPubtypesStart);
  80416085d7:	48 8b 8a b8 00 00 00 	mov    0xb8(%rdx),%rcx
  80416085de:	48 89 4f 60          	mov    %rcx,0x60(%rdi)
    addrs->pubtypes_end = (uint8_t *)(uefi_lp->DebugPubtypesEnd);
  80416085e2:	48 8b 92 c0 00 00 00 	mov    0xc0(%rdx),%rdx
  80416085e9:	48 89 57 68          	mov    %rdx,0x68(%rdi)
}
  80416085ed:	c3                   	ret    

00000080416085ee <debuginfo_rip>:
 * instruction address, 'addr'.  Returns 0 if information was found, and
 * negative if not.  But even if it returns negative it has stored some
 * information into '*info'
 */
int
debuginfo_rip(uintptr_t addr, struct Ripdebuginfo *info) {
  80416085ee:	f3 0f 1e fa          	endbr64 
  80416085f2:	55                   	push   %rbp
  80416085f3:	48 89 e5             	mov    %rsp,%rbp
  80416085f6:	41 57                	push   %r15
  80416085f8:	41 56                	push   %r14
  80416085fa:	41 55                	push   %r13
  80416085fc:	41 54                	push   %r12
  80416085fe:	53                   	push   %rbx
  80416085ff:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
    if (!addr) return 0;
  8041608606:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  804160860c:	48 85 ff             	test   %rdi,%rdi
  804160860f:	75 15                	jne    8041608626 <debuginfo_rip+0x38>
    if (res < 0) goto error;
    strncpy(info->rip_fn_name, tmp_buf, sizeof(info->rip_fn_name));

error:
    return res;
}
  8041608611:	44 89 e8             	mov    %r13d,%eax
  8041608614:	48 81 c4 98 00 00 00 	add    $0x98,%rsp
  804160861b:	5b                   	pop    %rbx
  804160861c:	41 5c                	pop    %r12
  804160861e:	41 5d                	pop    %r13
  8041608620:	41 5e                	pop    %r14
  8041608622:	41 5f                	pop    %r15
  8041608624:	5d                   	pop    %rbp
  8041608625:	c3                   	ret    
  8041608626:	49 89 fc             	mov    %rdi,%r12
  8041608629:	48 89 f3             	mov    %rsi,%rbx
    strcpy(info->rip_file, UNKNOWN);
  804160862c:	49 bf df bb 60 41 80 	movabs $0x804160bbdf,%r15
  8041608633:	00 00 00 
  8041608636:	4c 89 fe             	mov    %r15,%rsi
  8041608639:	48 89 df             	mov    %rbx,%rdi
  804160863c:	49 bd f2 91 60 41 80 	movabs $0x80416091f2,%r13
  8041608643:	00 00 00 
  8041608646:	41 ff d5             	call   *%r13
    strcpy(info->rip_fn_name, UNKNOWN);
  8041608649:	4c 8d b3 04 01 00 00 	lea    0x104(%rbx),%r14
  8041608650:	4c 89 fe             	mov    %r15,%rsi
  8041608653:	4c 89 f7             	mov    %r14,%rdi
  8041608656:	41 ff d5             	call   *%r13
    info->rip_fn_namelen = sizeof UNKNOWN - 1;
  8041608659:	c7 83 04 02 00 00 09 	movl   $0x9,0x204(%rbx)
  8041608660:	00 00 00 
    info->rip_line = 0;
  8041608663:	c7 83 00 01 00 00 00 	movl   $0x0,0x100(%rbx)
  804160866a:	00 00 00 
    info->rip_fn_addr = addr;
  804160866d:	4c 89 a3 08 02 00 00 	mov    %r12,0x208(%rbx)
    info->rip_fn_narg = 0;
  8041608674:	c7 83 10 02 00 00 00 	movl   $0x0,0x210(%rbx)
  804160867b:	00 00 00 
    assert(addr >= MAX_USER_READABLE);
  804160867e:	48 b8 ff ff df 1f 80 	movabs $0x801fdfffff,%rax
  8041608685:	00 00 00 
  8041608688:	49 39 c4             	cmp    %rax,%r12
  804160868b:	0f 86 26 01 00 00    	jbe    80416087b7 <debuginfo_rip+0x1c9>
    load_kernel_dwarf_info(&addrs);
  8041608691:	48 8d bd 60 ff ff ff 	lea    -0xa0(%rbp),%rdi
  8041608698:	48 b8 4f 85 60 41 80 	movabs $0x804160854f,%rax
  804160869f:	00 00 00 
  80416086a2:	ff d0                	call   *%rax
    Dwarf_Off offset = 0, line_offset = 0;
  80416086a4:	48 c7 85 58 ff ff ff 	movq   $0x0,-0xa8(%rbp)
  80416086ab:	00 00 00 00 
  80416086af:	48 c7 85 50 ff ff ff 	movq   $0x0,-0xb0(%rbp)
  80416086b6:	00 00 00 00 
    int res = info_by_address(&addrs, addr, &offset);
  80416086ba:	48 8d 95 58 ff ff ff 	lea    -0xa8(%rbp),%rdx
  80416086c1:	4c 89 e6             	mov    %r12,%rsi
  80416086c4:	48 8d bd 60 ff ff ff 	lea    -0xa0(%rbp),%rdi
  80416086cb:	48 b8 66 19 60 41 80 	movabs $0x8041601966,%rax
  80416086d2:	00 00 00 
  80416086d5:	ff d0                	call   *%rax
  80416086d7:	41 89 c5             	mov    %eax,%r13d
    if (res < 0) goto error;
  80416086da:	85 c0                	test   %eax,%eax
  80416086dc:	0f 88 2f ff ff ff    	js     8041608611 <debuginfo_rip+0x23>
    char *tmp_buf = NULL;
  80416086e2:	48 c7 85 48 ff ff ff 	movq   $0x0,-0xb8(%rbp)
  80416086e9:	00 00 00 00 
    res = file_name_by_info(&addrs, offset, &tmp_buf, &line_offset);
  80416086ed:	48 8d 8d 50 ff ff ff 	lea    -0xb0(%rbp),%rcx
  80416086f4:	48 8d 95 48 ff ff ff 	lea    -0xb8(%rbp),%rdx
  80416086fb:	48 8b b5 58 ff ff ff 	mov    -0xa8(%rbp),%rsi
  8041608702:	48 8d bd 60 ff ff ff 	lea    -0xa0(%rbp),%rdi
  8041608709:	48 b8 19 1f 60 41 80 	movabs $0x8041601f19,%rax
  8041608710:	00 00 00 
  8041608713:	ff d0                	call   *%rax
  8041608715:	41 89 c5             	mov    %eax,%r13d
    if (res < 0) goto error;
  8041608718:	85 c0                	test   %eax,%eax
  804160871a:	0f 88 f1 fe ff ff    	js     8041608611 <debuginfo_rip+0x23>
    strncpy(info->rip_file, tmp_buf, sizeof(info->rip_file));
  8041608720:	ba 00 01 00 00       	mov    $0x100,%edx
  8041608725:	48 8b b5 48 ff ff ff 	mov    -0xb8(%rbp),%rsi
  804160872c:	48 89 df             	mov    %rbx,%rdi
  804160872f:	48 b8 46 92 60 41 80 	movabs $0x8041609246,%rax
  8041608736:	00 00 00 
  8041608739:	ff d0                	call   *%rax
    line_for_address(&addrs, addr - 5, line_offset, &(info->rip_line));
  804160873b:	48 8d 8b 00 01 00 00 	lea    0x100(%rbx),%rcx
  8041608742:	49 8d 74 24 fb       	lea    -0x5(%r12),%rsi
  8041608747:	48 8b 95 50 ff ff ff 	mov    -0xb0(%rbp),%rdx
  804160874e:	48 8d bd 60 ff ff ff 	lea    -0xa0(%rbp),%rdi
  8041608755:	48 b8 3a 3a 60 41 80 	movabs $0x8041603a3a,%rax
  804160875c:	00 00 00 
  804160875f:	ff d0                	call   *%rax
    res = function_by_info(&addrs, addr, offset, &tmp_buf, &(info->rip_fn_addr));
  8041608761:	4c 8d 83 08 02 00 00 	lea    0x208(%rbx),%r8
  8041608768:	48 8d 8d 48 ff ff ff 	lea    -0xb8(%rbp),%rcx
  804160876f:	48 8b 95 58 ff ff ff 	mov    -0xa8(%rbp),%rdx
  8041608776:	4c 89 e6             	mov    %r12,%rsi
  8041608779:	48 8d bd 60 ff ff ff 	lea    -0xa0(%rbp),%rdi
  8041608780:	48 b8 37 24 60 41 80 	movabs $0x8041602437,%rax
  8041608787:	00 00 00 
  804160878a:	ff d0                	call   *%rax
  804160878c:	41 89 c5             	mov    %eax,%r13d
    if (res < 0) goto error;
  804160878f:	85 c0                	test   %eax,%eax
  8041608791:	0f 88 7a fe ff ff    	js     8041608611 <debuginfo_rip+0x23>
    strncpy(info->rip_fn_name, tmp_buf, sizeof(info->rip_fn_name));
  8041608797:	ba 00 01 00 00       	mov    $0x100,%edx
  804160879c:	48 8b b5 48 ff ff ff 	mov    -0xb8(%rbp),%rsi
  80416087a3:	4c 89 f7             	mov    %r14,%rdi
  80416087a6:	48 b8 46 92 60 41 80 	movabs $0x8041609246,%rax
  80416087ad:	00 00 00 
  80416087b0:	ff d0                	call   *%rax
  80416087b2:	e9 5a fe ff ff       	jmp    8041608611 <debuginfo_rip+0x23>
    assert(addr >= MAX_USER_READABLE);
  80416087b7:	48 b9 e9 bb 60 41 80 	movabs $0x804160bbe9,%rcx
  80416087be:	00 00 00 
  80416087c1:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  80416087c8:	00 00 00 
  80416087cb:	be 35 00 00 00       	mov    $0x35,%esi
  80416087d0:	48 bf 03 bc 60 41 80 	movabs $0x804160bc03,%rdi
  80416087d7:	00 00 00 
  80416087da:	b8 00 00 00 00       	mov    $0x0,%eax
  80416087df:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  80416087e6:	00 00 00 
  80416087e9:	41 ff d0             	call   *%r8

00000080416087ec <find_function>:

uintptr_t
find_function(const char *const fname) {
  80416087ec:	f3 0f 1e fa          	endbr64 
  80416087f0:	55                   	push   %rbp
  80416087f1:	48 89 e5             	mov    %rsp,%rbp
  80416087f4:	53                   	push   %rbx
  80416087f5:	48 81 ec 88 00 00 00 	sub    $0x88,%rsp
  80416087fc:	48 89 fb             	mov    %rdi,%rbx
     * in assembly. */

    // LAB 3: Your code here:

    struct Dwarf_Addrs dwarf_data;
    load_kernel_dwarf_info(&dwarf_data);
  80416087ff:	48 8d 7d 80          	lea    -0x80(%rbp),%rdi
  8041608803:	48 b8 4f 85 60 41 80 	movabs $0x804160854f,%rax
  804160880a:	00 00 00 
  804160880d:	ff d0                	call   *%rax

    uintptr_t offset = 0;
  804160880f:	48 c7 85 78 ff ff ff 	movq   $0x0,-0x88(%rbp)
  8041608816:	00 00 00 00 
    if (address_by_fname(&dwarf_data, fname, &offset) == 0) return offset;
  804160881a:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  8041608821:	48 89 de             	mov    %rbx,%rsi
  8041608824:	48 8d 7d 80          	lea    -0x80(%rbp),%rdi
  8041608828:	48 b8 31 2b 60 41 80 	movabs $0x8041602b31,%rax
  804160882f:	00 00 00 
  8041608832:	ff d0                	call   *%rax
  8041608834:	85 c0                	test   %eax,%eax
  8041608836:	75 0d                	jne    8041608845 <find_function+0x59>
  8041608838:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
    if( naive_address_by_fname(&dwarf_data, fname, &offset) == 0) return offset;

    return 0;
}
  804160883f:	48 8b 5d f8          	mov    -0x8(%rbp),%rbx
  8041608843:	c9                   	leave  
  8041608844:	c3                   	ret    
    if( naive_address_by_fname(&dwarf_data, fname, &offset) == 0) return offset;
  8041608845:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  804160884c:	48 89 de             	mov    %rbx,%rsi
  804160884f:	48 8d 7d 80          	lea    -0x80(%rbp),%rdi
  8041608853:	48 b8 3a 33 60 41 80 	movabs $0x804160333a,%rax
  804160885a:	00 00 00 
  804160885d:	ff d0                	call   *%rax
  804160885f:	85 c0                	test   %eax,%eax
  8041608861:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608866:	48 0f 44 85 78 ff ff 	cmove  -0x88(%rbp),%rax
  804160886d:	ff 
  804160886e:	eb cf                	jmp    804160883f <find_function+0x53>

0000008041608870 <print_num>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
print_num(void (*putch)(int, void *), void *put_arg,
          uintmax_t num, unsigned base, int width, char padc, bool capital) {
  8041608870:	f3 0f 1e fa          	endbr64 
  8041608874:	55                   	push   %rbp
  8041608875:	48 89 e5             	mov    %rsp,%rbp
  8041608878:	41 57                	push   %r15
  804160887a:	41 56                	push   %r14
  804160887c:	41 55                	push   %r13
  804160887e:	41 54                	push   %r12
  8041608880:	53                   	push   %rbx
  8041608881:	48 83 ec 18          	sub    $0x18,%rsp
  8041608885:	49 89 fc             	mov    %rdi,%r12
  8041608888:	49 89 f5             	mov    %rsi,%r13
  804160888b:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  804160888f:	8b 45 10             	mov    0x10(%rbp),%eax
  8041608892:	89 45 c4             	mov    %eax,-0x3c(%rbp)
    /* First recursively print all preceding (more significant) digits */
    if (num >= base) {
  8041608895:	41 89 cf             	mov    %ecx,%r15d
  8041608898:	49 39 d7             	cmp    %rdx,%r15
  804160889b:	76 5b                	jbe    80416088f8 <print_num+0x88>
        print_num(putch, put_arg, num / base, base, width - 1, padc, capital);
    } else {
        /* Print any needed pad characters before first digit */
        while (--width > 0) {
  804160889d:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
            putch(padc, put_arg);
  80416088a1:	45 0f be f1          	movsbl %r9b,%r14d
        while (--width > 0) {
  80416088a5:	85 db                	test   %ebx,%ebx
  80416088a7:	7e 0e                	jle    80416088b7 <print_num+0x47>
            putch(padc, put_arg);
  80416088a9:	4c 89 ee             	mov    %r13,%rsi
  80416088ac:	44 89 f7             	mov    %r14d,%edi
  80416088af:	41 ff d4             	call   *%r12
        while (--width > 0) {
  80416088b2:	83 eb 01             	sub    $0x1,%ebx
  80416088b5:	75 f2                	jne    80416088a9 <print_num+0x39>
        }
    }

    const char *dig = capital ? "0123456789ABCDEF" : "0123456789abcdef";
  80416088b7:	80 7d c4 00          	cmpb   $0x0,-0x3c(%rbp)
  80416088bb:	48 b9 11 bc 60 41 80 	movabs $0x804160bc11,%rcx
  80416088c2:	00 00 00 
  80416088c5:	48 b8 22 bc 60 41 80 	movabs $0x804160bc22,%rax
  80416088cc:	00 00 00 
  80416088cf:	48 0f 44 c8          	cmove  %rax,%rcx

    /* Then print this (the least significant) digit */
    putch(dig[num % base], put_arg);
  80416088d3:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80416088d7:	ba 00 00 00 00       	mov    $0x0,%edx
  80416088dc:	49 f7 f7             	div    %r15
  80416088df:	0f be 3c 11          	movsbl (%rcx,%rdx,1),%edi
  80416088e3:	4c 89 ee             	mov    %r13,%rsi
  80416088e6:	41 ff d4             	call   *%r12
}
  80416088e9:	48 8d 65 d8          	lea    -0x28(%rbp),%rsp
  80416088ed:	5b                   	pop    %rbx
  80416088ee:	41 5c                	pop    %r12
  80416088f0:	41 5d                	pop    %r13
  80416088f2:	41 5e                	pop    %r14
  80416088f4:	41 5f                	pop    %r15
  80416088f6:	5d                   	pop    %rbp
  80416088f7:	c3                   	ret    
        print_num(putch, put_arg, num / base, base, width - 1, padc, capital);
  80416088f8:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80416088fc:	ba 00 00 00 00       	mov    $0x0,%edx
  8041608901:	49 f7 f7             	div    %r15
  8041608904:	48 83 ec 08          	sub    $0x8,%rsp
  8041608908:	0f b6 55 c4          	movzbl -0x3c(%rbp),%edx
  804160890c:	52                   	push   %rdx
  804160890d:	45 0f be c9          	movsbl %r9b,%r9d
  8041608911:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8041608915:	48 89 c2             	mov    %rax,%rdx
  8041608918:	48 b8 70 88 60 41 80 	movabs $0x8041608870,%rax
  804160891f:	00 00 00 
  8041608922:	ff d0                	call   *%rax
  8041608924:	48 83 c4 10          	add    $0x10,%rsp
  8041608928:	eb 8d                	jmp    80416088b7 <print_num+0x47>

000000804160892a <get_unsigned>:

/* Get an unsigned int of various possible sizes from a varargs list,
 * depending on the lflag parameter. */
static uintmax_t
get_unsigned(va_list *ap, int lflag, bool zflag, int hflag) {
  804160892a:	f3 0f 1e fa          	endbr64 
    if (zflag) return va_arg(*ap, size_t);
  804160892e:	84 d2                	test   %dl,%dl
  8041608930:	75 2f                	jne    8041608961 <get_unsigned+0x37>

    switch (hflag) {
  8041608932:	83 e9 01             	sub    $0x1,%ecx
  8041608935:	83 f9 01             	cmp    $0x1,%ecx
  8041608938:	76 4b                	jbe    8041608985 <get_unsigned+0x5b>
    case 1:
    case 2:
        return va_arg(*ap, unsigned int);
    }

    switch (lflag) {
  804160893a:	85 f6                	test   %esi,%esi
  804160893c:	74 6a                	je     80416089a8 <get_unsigned+0x7e>
  804160893e:	83 fe 01             	cmp    $0x1,%esi
  8041608941:	0f 84 84 00 00 00    	je     80416089cb <get_unsigned+0xa1>
    case 0:
        return va_arg(*ap, unsigned int);
    case 1:
        return va_arg(*ap, unsigned long);
    default:
        return va_arg(*ap, unsigned long long);
  8041608947:	8b 17                	mov    (%rdi),%edx
  8041608949:	83 fa 2f             	cmp    $0x2f,%edx
  804160894c:	0f 87 9d 00 00 00    	ja     80416089ef <get_unsigned+0xc5>
  8041608952:	89 d1                	mov    %edx,%ecx
  8041608954:	48 03 4f 10          	add    0x10(%rdi),%rcx
  8041608958:	83 c2 08             	add    $0x8,%edx
  804160895b:	89 17                	mov    %edx,(%rdi)
  804160895d:	48 8b 01             	mov    (%rcx),%rax
    }
}
  8041608960:	c3                   	ret    
    if (zflag) return va_arg(*ap, size_t);
  8041608961:	8b 17                	mov    (%rdi),%edx
  8041608963:	83 fa 2f             	cmp    $0x2f,%edx
  8041608966:	77 0f                	ja     8041608977 <get_unsigned+0x4d>
  8041608968:	89 d1                	mov    %edx,%ecx
  804160896a:	48 03 4f 10          	add    0x10(%rdi),%rcx
  804160896e:	83 c2 08             	add    $0x8,%edx
  8041608971:	89 17                	mov    %edx,(%rdi)
  8041608973:	48 8b 01             	mov    (%rcx),%rax
  8041608976:	c3                   	ret    
  8041608977:	48 8b 4f 08          	mov    0x8(%rdi),%rcx
  804160897b:	48 8d 51 08          	lea    0x8(%rcx),%rdx
  804160897f:	48 89 57 08          	mov    %rdx,0x8(%rdi)
  8041608983:	eb ee                	jmp    8041608973 <get_unsigned+0x49>
        return va_arg(*ap, unsigned int);
  8041608985:	8b 17                	mov    (%rdi),%edx
  8041608987:	83 fa 2f             	cmp    $0x2f,%edx
  804160898a:	77 0e                	ja     804160899a <get_unsigned+0x70>
  804160898c:	89 d1                	mov    %edx,%ecx
  804160898e:	48 03 4f 10          	add    0x10(%rdi),%rcx
  8041608992:	83 c2 08             	add    $0x8,%edx
  8041608995:	89 17                	mov    %edx,(%rdi)
  8041608997:	8b 01                	mov    (%rcx),%eax
  8041608999:	c3                   	ret    
  804160899a:	48 8b 4f 08          	mov    0x8(%rdi),%rcx
  804160899e:	48 8d 51 08          	lea    0x8(%rcx),%rdx
  80416089a2:	48 89 57 08          	mov    %rdx,0x8(%rdi)
  80416089a6:	eb ef                	jmp    8041608997 <get_unsigned+0x6d>
        return va_arg(*ap, unsigned int);
  80416089a8:	8b 17                	mov    (%rdi),%edx
  80416089aa:	83 fa 2f             	cmp    $0x2f,%edx
  80416089ad:	77 0e                	ja     80416089bd <get_unsigned+0x93>
  80416089af:	89 d1                	mov    %edx,%ecx
  80416089b1:	48 03 4f 10          	add    0x10(%rdi),%rcx
  80416089b5:	83 c2 08             	add    $0x8,%edx
  80416089b8:	89 17                	mov    %edx,(%rdi)
  80416089ba:	8b 01                	mov    (%rcx),%eax
  80416089bc:	c3                   	ret    
  80416089bd:	48 8b 4f 08          	mov    0x8(%rdi),%rcx
  80416089c1:	48 8d 51 08          	lea    0x8(%rcx),%rdx
  80416089c5:	48 89 57 08          	mov    %rdx,0x8(%rdi)
  80416089c9:	eb ef                	jmp    80416089ba <get_unsigned+0x90>
        return va_arg(*ap, unsigned long);
  80416089cb:	8b 17                	mov    (%rdi),%edx
  80416089cd:	83 fa 2f             	cmp    $0x2f,%edx
  80416089d0:	77 0f                	ja     80416089e1 <get_unsigned+0xb7>
  80416089d2:	89 d1                	mov    %edx,%ecx
  80416089d4:	48 03 4f 10          	add    0x10(%rdi),%rcx
  80416089d8:	83 c2 08             	add    $0x8,%edx
  80416089db:	89 17                	mov    %edx,(%rdi)
  80416089dd:	48 8b 01             	mov    (%rcx),%rax
  80416089e0:	c3                   	ret    
  80416089e1:	48 8b 4f 08          	mov    0x8(%rdi),%rcx
  80416089e5:	48 8d 51 08          	lea    0x8(%rcx),%rdx
  80416089e9:	48 89 57 08          	mov    %rdx,0x8(%rdi)
  80416089ed:	eb ee                	jmp    80416089dd <get_unsigned+0xb3>
        return va_arg(*ap, unsigned long long);
  80416089ef:	48 8b 4f 08          	mov    0x8(%rdi),%rcx
  80416089f3:	48 8d 51 08          	lea    0x8(%rcx),%rdx
  80416089f7:	48 89 57 08          	mov    %rdx,0x8(%rdi)
  80416089fb:	e9 5d ff ff ff       	jmp    804160895d <get_unsigned+0x33>

0000008041608a00 <sprintputch>:
    char *end;
    int count;
};

static void
sprintputch(int ch, struct sprintbuf *state) {
  8041608a00:	f3 0f 1e fa          	endbr64 
    state->count++;
  8041608a04:	83 46 10 01          	addl   $0x1,0x10(%rsi)
    if (state->start < state->end) {
  8041608a08:	48 8b 06             	mov    (%rsi),%rax
  8041608a0b:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  8041608a0f:	73 0a                	jae    8041608a1b <sprintputch+0x1b>
        *state->start++ = ch;
  8041608a11:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8041608a15:	48 89 16             	mov    %rdx,(%rsi)
  8041608a18:	40 88 38             	mov    %dil,(%rax)
    }
}
  8041608a1b:	c3                   	ret    

0000008041608a1c <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  8041608a1c:	f3 0f 1e fa          	endbr64 
  8041608a20:	55                   	push   %rbp
  8041608a21:	48 89 e5             	mov    %rsp,%rbp
  8041608a24:	48 83 ec 50          	sub    $0x50,%rsp
  8041608a28:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  8041608a2c:	4c 89 45 f0          	mov    %r8,-0x10(%rbp)
  8041608a30:	4c 89 4d f8          	mov    %r9,-0x8(%rbp)
    va_start(ap, fmt);
  8041608a34:	c7 45 b8 18 00 00 00 	movl   $0x18,-0x48(%rbp)
  8041608a3b:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8041608a3f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041608a43:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  8041608a47:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    vprintfmt(putch, putdat, fmt, ap);
  8041608a4b:	48 8d 4d b8          	lea    -0x48(%rbp),%rcx
  8041608a4f:	48 b8 5d 8a 60 41 80 	movabs $0x8041608a5d,%rax
  8041608a56:	00 00 00 
  8041608a59:	ff d0                	call   *%rax
}
  8041608a5b:	c9                   	leave  
  8041608a5c:	c3                   	ret    

0000008041608a5d <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *put_arg, const char *fmt, va_list ap) {
  8041608a5d:	f3 0f 1e fa          	endbr64 
  8041608a61:	55                   	push   %rbp
  8041608a62:	48 89 e5             	mov    %rsp,%rbp
  8041608a65:	41 57                	push   %r15
  8041608a67:	41 56                	push   %r14
  8041608a69:	41 55                	push   %r13
  8041608a6b:	41 54                	push   %r12
  8041608a6d:	53                   	push   %rbx
  8041608a6e:	48 83 ec 48          	sub    $0x48,%rsp
  8041608a72:	49 89 fc             	mov    %rdi,%r12
  8041608a75:	49 89 f6             	mov    %rsi,%r14
  8041608a78:	49 89 d7             	mov    %rdx,%r15
    va_copy(aq, ap);
  8041608a7b:	48 8b 01             	mov    (%rcx),%rax
  8041608a7e:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  8041608a82:	48 8b 41 08          	mov    0x8(%rcx),%rax
  8041608a86:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041608a8a:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8041608a8e:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
        while ((ch = *ufmt++) != '%') {
  8041608a92:	49 8d 5f 01          	lea    0x1(%r15),%rbx
  8041608a96:	41 0f b6 3f          	movzbl (%r15),%edi
  8041608a9a:	40 80 ff 25          	cmp    $0x25,%dil
  8041608a9e:	74 18                	je     8041608ab8 <vprintfmt+0x5b>
            if (!ch) return;
  8041608aa0:	40 84 ff             	test   %dil,%dil
  8041608aa3:	0f 84 3f 05 00 00    	je     8041608fe8 <vprintfmt+0x58b>
            putch(ch, put_arg);
  8041608aa9:	40 0f b6 ff          	movzbl %dil,%edi
  8041608aad:	4c 89 f6             	mov    %r14,%rsi
  8041608ab0:	41 ff d4             	call   *%r12
        while ((ch = *ufmt++) != '%') {
  8041608ab3:	49 89 df             	mov    %rbx,%r15
  8041608ab6:	eb da                	jmp    8041608a92 <vprintfmt+0x35>
            precision = va_arg(aq, int);
  8041608ab8:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
        bool altflag = 0, zflag = 0;
  8041608abc:	ba 00 00 00 00       	mov    $0x0,%edx
  8041608ac1:	c6 45 98 00          	movb   $0x0,-0x68(%rbp)
        unsigned lflag = 0, hflag = 0, base = 10;
  8041608ac5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041608aca:	be 00 00 00 00       	mov    $0x0,%esi
        int width = -1, precision = -1;
  8041608acf:	41 bd ff ff ff ff    	mov    $0xffffffff,%r13d
  8041608ad5:	c7 45 ac ff ff ff ff 	movl   $0xffffffff,-0x54(%rbp)
        char padc = ' ';
  8041608adc:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
        switch (ch = *ufmt++) {
  8041608ae0:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  8041608ae6:	4c 8d 7b 01          	lea    0x1(%rbx),%r15
  8041608aea:	44 0f b6 0b          	movzbl (%rbx),%r9d
  8041608aee:	41 8d 41 dd          	lea    -0x23(%r9),%eax
  8041608af2:	3c 57                	cmp    $0x57,%al
  8041608af4:	0f 87 d3 04 00 00    	ja     8041608fcd <vprintfmt+0x570>
  8041608afa:	0f b6 c0             	movzbl %al,%eax
  8041608afd:	49 ba 00 bd 60 41 80 	movabs $0x804160bd00,%r10
  8041608b04:	00 00 00 
  8041608b07:	3e 41 ff 24 c2       	notrack jmp *(%r10,%rax,8)
  8041608b0c:	4c 89 fb             	mov    %r15,%rbx
            altflag = 1;
  8041608b0f:	44 88 45 98          	mov    %r8b,-0x68(%rbp)
  8041608b13:	eb d1                	jmp    8041608ae6 <vprintfmt+0x89>
        switch (ch = *ufmt++) {
  8041608b15:	4c 89 fb             	mov    %r15,%rbx
  8041608b18:	44 89 c2             	mov    %r8d,%edx
  8041608b1b:	eb c9                	jmp    8041608ae6 <vprintfmt+0x89>
            padc = ch;
  8041608b1d:	44 88 4d a0          	mov    %r9b,-0x60(%rbp)
        switch (ch = *ufmt++) {
  8041608b21:	4c 89 fb             	mov    %r15,%rbx
            goto reswitch;
  8041608b24:	eb c0                	jmp    8041608ae6 <vprintfmt+0x89>
            precision = va_arg(aq, int);
  8041608b26:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041608b29:	83 f8 2f             	cmp    $0x2f,%eax
  8041608b2c:	77 24                	ja     8041608b52 <vprintfmt+0xf5>
  8041608b2e:	41 89 c1             	mov    %eax,%r9d
  8041608b31:	49 01 f9             	add    %rdi,%r9
  8041608b34:	83 c0 08             	add    $0x8,%eax
  8041608b37:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041608b3a:	45 8b 29             	mov    (%r9),%r13d
        switch (ch = *ufmt++) {
  8041608b3d:	4c 89 fb             	mov    %r15,%rbx
            if (width < 0) {
  8041608b40:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8041608b44:	79 a0                	jns    8041608ae6 <vprintfmt+0x89>
                width = precision;
  8041608b46:	44 89 6d ac          	mov    %r13d,-0x54(%rbp)
                precision = -1;
  8041608b4a:	41 bd ff ff ff ff    	mov    $0xffffffff,%r13d
  8041608b50:	eb 94                	jmp    8041608ae6 <vprintfmt+0x89>
            precision = va_arg(aq, int);
  8041608b52:	4c 8b 4d c0          	mov    -0x40(%rbp),%r9
  8041608b56:	49 8d 41 08          	lea    0x8(%r9),%rax
  8041608b5a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041608b5e:	eb da                	jmp    8041608b3a <vprintfmt+0xdd>
        switch (ch = *ufmt++) {
  8041608b60:	45 0f b6 c9          	movzbl %r9b,%r9d
                precision = precision * 10 + ch - '0';
  8041608b64:	45 8d 69 d0          	lea    -0x30(%r9),%r13d
                if ((ch = *ufmt) - '0' > 9) break;
  8041608b68:	0f b6 43 01          	movzbl 0x1(%rbx),%eax
  8041608b6c:	3c 39                	cmp    $0x39,%al
  8041608b6e:	77 1e                	ja     8041608b8e <vprintfmt+0x131>
            for (precision = 0;; ++ufmt) {
  8041608b70:	49 83 c7 01          	add    $0x1,%r15
                precision = precision * 10 + ch - '0';
  8041608b74:	47 8d 4c ad 00       	lea    0x0(%r13,%r13,4),%r9d
  8041608b79:	0f b6 c0             	movzbl %al,%eax
  8041608b7c:	46 8d 6c 48 d0       	lea    -0x30(%rax,%r9,2),%r13d
                if ((ch = *ufmt) - '0' > 9) break;
  8041608b81:	41 0f b6 07          	movzbl (%r15),%eax
  8041608b85:	3c 39                	cmp    $0x39,%al
  8041608b87:	76 e7                	jbe    8041608b70 <vprintfmt+0x113>
            for (precision = 0;; ++ufmt) {
  8041608b89:	4c 89 fb             	mov    %r15,%rbx
        process_precision:
  8041608b8c:	eb b2                	jmp    8041608b40 <vprintfmt+0xe3>
        switch (ch = *ufmt++) {
  8041608b8e:	4c 89 fb             	mov    %r15,%rbx
  8041608b91:	eb ad                	jmp    8041608b40 <vprintfmt+0xe3>
            width = MAX(0, width);
  8041608b93:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  8041608b96:	85 db                	test   %ebx,%ebx
  8041608b98:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608b9d:	0f 49 c3             	cmovns %ebx,%eax
  8041608ba0:	89 45 ac             	mov    %eax,-0x54(%rbp)
        switch (ch = *ufmt++) {
  8041608ba3:	4c 89 fb             	mov    %r15,%rbx
            goto reswitch;
  8041608ba6:	e9 3b ff ff ff       	jmp    8041608ae6 <vprintfmt+0x89>
            lflag++;
  8041608bab:	83 c6 01             	add    $0x1,%esi
        switch (ch = *ufmt++) {
  8041608bae:	4c 89 fb             	mov    %r15,%rbx
            goto reswitch;
  8041608bb1:	e9 30 ff ff ff       	jmp    8041608ae6 <vprintfmt+0x89>
            hflag++;
  8041608bb6:	83 c1 01             	add    $0x1,%ecx
        switch (ch = *ufmt++) {
  8041608bb9:	4c 89 fb             	mov    %r15,%rbx
            goto reswitch;
  8041608bbc:	e9 25 ff ff ff       	jmp    8041608ae6 <vprintfmt+0x89>
            putch(va_arg(aq, int), put_arg);
  8041608bc1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041608bc4:	83 f8 2f             	cmp    $0x2f,%eax
  8041608bc7:	77 18                	ja     8041608be1 <vprintfmt+0x184>
  8041608bc9:	89 c2                	mov    %eax,%edx
  8041608bcb:	48 01 fa             	add    %rdi,%rdx
  8041608bce:	83 c0 08             	add    $0x8,%eax
  8041608bd1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041608bd4:	4c 89 f6             	mov    %r14,%rsi
  8041608bd7:	8b 3a                	mov    (%rdx),%edi
  8041608bd9:	41 ff d4             	call   *%r12
            break;
  8041608bdc:	e9 b1 fe ff ff       	jmp    8041608a92 <vprintfmt+0x35>
            putch(va_arg(aq, int), put_arg);
  8041608be1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041608be5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041608be9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041608bed:	eb e5                	jmp    8041608bd4 <vprintfmt+0x177>
            int err = va_arg(aq, int);
  8041608bef:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041608bf2:	83 f8 2f             	cmp    $0x2f,%eax
  8041608bf5:	77 59                	ja     8041608c50 <vprintfmt+0x1f3>
  8041608bf7:	89 c2                	mov    %eax,%edx
  8041608bf9:	48 01 fa             	add    %rdi,%rdx
  8041608bfc:	83 c0 08             	add    $0x8,%eax
  8041608bff:	89 45 b8             	mov    %eax,-0x48(%rbp)
            if (err < 0) err = -err;
  8041608c02:	8b 02                	mov    (%rdx),%eax
  8041608c04:	89 c1                	mov    %eax,%ecx
  8041608c06:	f7 d9                	neg    %ecx
  8041608c08:	0f 48 c8             	cmovs  %eax,%ecx
            if (err >= MAXERROR || !(strerr = error_string[err])) {
  8041608c0b:	83 f9 0a             	cmp    $0xa,%ecx
  8041608c0e:	7f 4e                	jg     8041608c5e <vprintfmt+0x201>
  8041608c10:	48 63 c1             	movslq %ecx,%rax
  8041608c13:	48 ba c0 bf 60 41 80 	movabs $0x804160bfc0,%rdx
  8041608c1a:	00 00 00 
  8041608c1d:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8041608c21:	48 85 c0             	test   %rax,%rax
  8041608c24:	74 38                	je     8041608c5e <vprintfmt+0x201>
                printfmt(putch, put_arg, "%s", strerr);
  8041608c26:	48 89 c1             	mov    %rax,%rcx
  8041608c29:	48 ba 88 a4 60 41 80 	movabs $0x804160a488,%rdx
  8041608c30:	00 00 00 
  8041608c33:	4c 89 f6             	mov    %r14,%rsi
  8041608c36:	4c 89 e7             	mov    %r12,%rdi
  8041608c39:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608c3e:	49 b8 1c 8a 60 41 80 	movabs $0x8041608a1c,%r8
  8041608c45:	00 00 00 
  8041608c48:	41 ff d0             	call   *%r8
  8041608c4b:	e9 42 fe ff ff       	jmp    8041608a92 <vprintfmt+0x35>
            int err = va_arg(aq, int);
  8041608c50:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041608c54:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041608c58:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041608c5c:	eb a4                	jmp    8041608c02 <vprintfmt+0x1a5>
                printfmt(putch, put_arg, "error %d", err);
  8041608c5e:	48 ba 3a bc 60 41 80 	movabs $0x804160bc3a,%rdx
  8041608c65:	00 00 00 
  8041608c68:	4c 89 f6             	mov    %r14,%rsi
  8041608c6b:	4c 89 e7             	mov    %r12,%rdi
  8041608c6e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608c73:	49 b8 1c 8a 60 41 80 	movabs $0x8041608a1c,%r8
  8041608c7a:	00 00 00 
  8041608c7d:	41 ff d0             	call   *%r8
  8041608c80:	e9 0d fe ff ff       	jmp    8041608a92 <vprintfmt+0x35>
            const char *ptr = va_arg(aq, char *);
  8041608c85:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041608c88:	83 f8 2f             	cmp    $0x2f,%eax
  8041608c8b:	77 55                	ja     8041608ce2 <vprintfmt+0x285>
  8041608c8d:	89 c2                	mov    %eax,%edx
  8041608c8f:	48 01 fa             	add    %rdi,%rdx
  8041608c92:	83 c0 08             	add    $0x8,%eax
  8041608c95:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041608c98:	48 8b 0a             	mov    (%rdx),%rcx
            if (!ptr) ptr = "(null)";
  8041608c9b:	48 85 c9             	test   %rcx,%rcx
  8041608c9e:	48 b8 33 bc 60 41 80 	movabs $0x804160bc33,%rax
  8041608ca5:	00 00 00 
  8041608ca8:	48 0f 45 c1          	cmovne %rcx,%rax
  8041608cac:	48 89 45 90          	mov    %rax,-0x70(%rbp)
            if (width > 0 && padc != '-') {
  8041608cb0:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8041608cb4:	7e 06                	jle    8041608cbc <vprintfmt+0x25f>
  8041608cb6:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8041608cba:	75 34                	jne    8041608cf0 <vprintfmt+0x293>
            for (; (ch = *ptr++) && (precision < 0 || --precision >= 0); width--) {
  8041608cbc:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8041608cc0:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8041608cc4:	0f b6 00             	movzbl (%rax),%eax
  8041608cc7:	84 c0                	test   %al,%al
  8041608cc9:	0f 84 b2 00 00 00    	je     8041608d81 <vprintfmt+0x324>
  8041608ccf:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8041608cd3:	44 0f b6 75 98       	movzbl -0x68(%rbp),%r14d
  8041608cd8:	4c 89 7d 98          	mov    %r15,-0x68(%rbp)
  8041608cdc:	44 8b 7d ac          	mov    -0x54(%rbp),%r15d
  8041608ce0:	eb 74                	jmp    8041608d56 <vprintfmt+0x2f9>
            const char *ptr = va_arg(aq, char *);
  8041608ce2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041608ce6:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041608cea:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041608cee:	eb a8                	jmp    8041608c98 <vprintfmt+0x23b>
                width -= strnlen(ptr, precision);
  8041608cf0:	49 63 f5             	movslq %r13d,%rsi
  8041608cf3:	48 8b 7d 90          	mov    -0x70(%rbp),%rdi
  8041608cf7:	48 b8 cb 91 60 41 80 	movabs $0x80416091cb,%rax
  8041608cfe:	00 00 00 
  8041608d01:	ff d0                	call   *%rax
  8041608d03:	48 89 c2             	mov    %rax,%rdx
  8041608d06:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8041608d09:	29 d0                	sub    %edx,%eax
                while (width-- > 0) putch(padc, put_arg);
  8041608d0b:	8d 50 ff             	lea    -0x1(%rax),%edx
  8041608d0e:	89 55 ac             	mov    %edx,-0x54(%rbp)
  8041608d11:	85 c0                	test   %eax,%eax
  8041608d13:	7e a7                	jle    8041608cbc <vprintfmt+0x25f>
  8041608d15:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  8041608d19:	44 89 6d a0          	mov    %r13d,-0x60(%rbp)
  8041608d1d:	41 89 d5             	mov    %edx,%r13d
  8041608d20:	4c 89 f6             	mov    %r14,%rsi
  8041608d23:	89 df                	mov    %ebx,%edi
  8041608d25:	41 ff d4             	call   *%r12
  8041608d28:	41 83 ed 01          	sub    $0x1,%r13d
  8041608d2c:	41 83 fd ff          	cmp    $0xffffffff,%r13d
  8041608d30:	75 ee                	jne    8041608d20 <vprintfmt+0x2c3>
  8041608d32:	44 89 6d ac          	mov    %r13d,-0x54(%rbp)
  8041608d36:	44 8b 6d a0          	mov    -0x60(%rbp),%r13d
  8041608d3a:	eb 80                	jmp    8041608cbc <vprintfmt+0x25f>
                putch(altflag && (ch < ' ' || ch > '~') ? '?' : ch, put_arg);
  8041608d3c:	0f b6 f8             	movzbl %al,%edi
  8041608d3f:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  8041608d43:	41 ff d4             	call   *%r12
            for (; (ch = *ptr++) && (precision < 0 || --precision >= 0); width--) {
  8041608d46:	41 83 ef 01          	sub    $0x1,%r15d
  8041608d4a:	48 83 c3 01          	add    $0x1,%rbx
  8041608d4e:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  8041608d52:	84 c0                	test   %al,%al
  8041608d54:	74 1f                	je     8041608d75 <vprintfmt+0x318>
  8041608d56:	45 85 ed             	test   %r13d,%r13d
  8041608d59:	78 06                	js     8041608d61 <vprintfmt+0x304>
  8041608d5b:	41 83 ed 01          	sub    $0x1,%r13d
  8041608d5f:	78 46                	js     8041608da7 <vprintfmt+0x34a>
                putch(altflag && (ch < ' ' || ch > '~') ? '?' : ch, put_arg);
  8041608d61:	45 84 f6             	test   %r14b,%r14b
  8041608d64:	74 d6                	je     8041608d3c <vprintfmt+0x2df>
  8041608d66:	8d 50 e0             	lea    -0x20(%rax),%edx
  8041608d69:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8041608d6e:	80 fa 5e             	cmp    $0x5e,%dl
  8041608d71:	77 cc                	ja     8041608d3f <vprintfmt+0x2e2>
  8041608d73:	eb c7                	jmp    8041608d3c <vprintfmt+0x2df>
  8041608d75:	44 89 7d ac          	mov    %r15d,-0x54(%rbp)
  8041608d79:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8041608d7d:	4c 8b 7d 98          	mov    -0x68(%rbp),%r15
            while (width-- > 0) putch(' ', put_arg);
  8041608d81:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8041608d84:	8d 58 ff             	lea    -0x1(%rax),%ebx
  8041608d87:	85 c0                	test   %eax,%eax
  8041608d89:	0f 8e 03 fd ff ff    	jle    8041608a92 <vprintfmt+0x35>
  8041608d8f:	4c 89 f6             	mov    %r14,%rsi
  8041608d92:	bf 20 00 00 00       	mov    $0x20,%edi
  8041608d97:	41 ff d4             	call   *%r12
  8041608d9a:	83 eb 01             	sub    $0x1,%ebx
  8041608d9d:	83 fb ff             	cmp    $0xffffffff,%ebx
  8041608da0:	75 ed                	jne    8041608d8f <vprintfmt+0x332>
  8041608da2:	e9 eb fc ff ff       	jmp    8041608a92 <vprintfmt+0x35>
  8041608da7:	44 89 7d ac          	mov    %r15d,-0x54(%rbp)
  8041608dab:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8041608daf:	4c 8b 7d 98          	mov    -0x68(%rbp),%r15
  8041608db3:	eb cc                	jmp    8041608d81 <vprintfmt+0x324>
    if (zflag) return va_arg(*ap, size_t);
  8041608db5:	45 89 cd             	mov    %r9d,%r13d
  8041608db8:	84 d2                	test   %dl,%dl
  8041608dba:	75 35                	jne    8041608df1 <vprintfmt+0x394>
    switch (hflag) {
  8041608dbc:	83 e9 01             	sub    $0x1,%ecx
  8041608dbf:	83 f9 01             	cmp    $0x1,%ecx
  8041608dc2:	76 67                	jbe    8041608e2b <vprintfmt+0x3ce>
    switch (lflag) {
  8041608dc4:	85 f6                	test   %esi,%esi
  8041608dc6:	0f 84 85 00 00 00    	je     8041608e51 <vprintfmt+0x3f4>
  8041608dcc:	83 fe 01             	cmp    $0x1,%esi
  8041608dcf:	0f 84 a2 00 00 00    	je     8041608e77 <vprintfmt+0x41a>
        return va_arg(*ap, long long);
  8041608dd5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041608dd8:	83 f8 2f             	cmp    $0x2f,%eax
  8041608ddb:	0f 87 bf 00 00 00    	ja     8041608ea0 <vprintfmt+0x443>
  8041608de1:	89 c2                	mov    %eax,%edx
  8041608de3:	48 01 d7             	add    %rdx,%rdi
  8041608de6:	83 c0 08             	add    $0x8,%eax
  8041608de9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041608dec:	48 8b 1f             	mov    (%rdi),%rbx
  8041608def:	eb 16                	jmp    8041608e07 <vprintfmt+0x3aa>
    if (zflag) return va_arg(*ap, size_t);
  8041608df1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041608df4:	83 f8 2f             	cmp    $0x2f,%eax
  8041608df7:	77 24                	ja     8041608e1d <vprintfmt+0x3c0>
  8041608df9:	89 c2                	mov    %eax,%edx
  8041608dfb:	48 01 fa             	add    %rdi,%rdx
  8041608dfe:	83 c0 08             	add    $0x8,%eax
  8041608e01:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041608e04:	48 8b 1a             	mov    (%rdx),%rbx
            if (i < 0) {
  8041608e07:	48 85 db             	test   %rbx,%rbx
  8041608e0a:	0f 88 a1 00 00 00    	js     8041608eb1 <vprintfmt+0x454>
            num = i;
  8041608e10:	48 89 da             	mov    %rbx,%rdx
        unsigned lflag = 0, hflag = 0, base = 10;
  8041608e13:	b9 0a 00 00 00       	mov    $0xa,%ecx
            goto number;
  8041608e18:	e9 1c 01 00 00       	jmp    8041608f39 <vprintfmt+0x4dc>
    if (zflag) return va_arg(*ap, size_t);
  8041608e1d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041608e21:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041608e25:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041608e29:	eb d9                	jmp    8041608e04 <vprintfmt+0x3a7>
        return va_arg(*ap, int);
  8041608e2b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041608e2e:	83 f8 2f             	cmp    $0x2f,%eax
  8041608e31:	77 10                	ja     8041608e43 <vprintfmt+0x3e6>
  8041608e33:	89 c2                	mov    %eax,%edx
  8041608e35:	48 01 fa             	add    %rdi,%rdx
  8041608e38:	83 c0 08             	add    $0x8,%eax
  8041608e3b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041608e3e:	48 63 1a             	movslq (%rdx),%rbx
  8041608e41:	eb c4                	jmp    8041608e07 <vprintfmt+0x3aa>
  8041608e43:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041608e47:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041608e4b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041608e4f:	eb ed                	jmp    8041608e3e <vprintfmt+0x3e1>
        return va_arg(*ap, int);
  8041608e51:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041608e54:	83 fa 2f             	cmp    $0x2f,%edx
  8041608e57:	77 10                	ja     8041608e69 <vprintfmt+0x40c>
  8041608e59:	89 d0                	mov    %edx,%eax
  8041608e5b:	48 01 f8             	add    %rdi,%rax
  8041608e5e:	83 c2 08             	add    $0x8,%edx
  8041608e61:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041608e64:	48 63 18             	movslq (%rax),%rbx
  8041608e67:	eb 9e                	jmp    8041608e07 <vprintfmt+0x3aa>
  8041608e69:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8041608e6d:	48 8d 50 08          	lea    0x8(%rax),%rdx
  8041608e71:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  8041608e75:	eb ed                	jmp    8041608e64 <vprintfmt+0x407>
        return va_arg(*ap, long);
  8041608e77:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041608e7a:	83 fa 2f             	cmp    $0x2f,%edx
  8041608e7d:	77 13                	ja     8041608e92 <vprintfmt+0x435>
  8041608e7f:	89 d0                	mov    %edx,%eax
  8041608e81:	48 01 f8             	add    %rdi,%rax
  8041608e84:	83 c2 08             	add    $0x8,%edx
  8041608e87:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041608e8a:	48 8b 18             	mov    (%rax),%rbx
  8041608e8d:	e9 75 ff ff ff       	jmp    8041608e07 <vprintfmt+0x3aa>
  8041608e92:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8041608e96:	48 8d 50 08          	lea    0x8(%rax),%rdx
  8041608e9a:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  8041608e9e:	eb ea                	jmp    8041608e8a <vprintfmt+0x42d>
        return va_arg(*ap, long long);
  8041608ea0:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
  8041608ea4:	48 8d 47 08          	lea    0x8(%rdi),%rax
  8041608ea8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041608eac:	e9 3b ff ff ff       	jmp    8041608dec <vprintfmt+0x38f>
                putch('-', put_arg);
  8041608eb1:	4c 89 f6             	mov    %r14,%rsi
  8041608eb4:	bf 2d 00 00 00       	mov    $0x2d,%edi
  8041608eb9:	41 ff d4             	call   *%r12
                i = -i;
  8041608ebc:	48 f7 db             	neg    %rbx
  8041608ebf:	e9 4c ff ff ff       	jmp    8041608e10 <vprintfmt+0x3b3>
            num = get_unsigned(&aq, lflag, zflag, hflag);
  8041608ec4:	45 89 cd             	mov    %r9d,%r13d
  8041608ec7:	0f b6 d2             	movzbl %dl,%edx
  8041608eca:	48 8d 7d b8          	lea    -0x48(%rbp),%rdi
  8041608ece:	48 b8 2a 89 60 41 80 	movabs $0x804160892a,%rax
  8041608ed5:	00 00 00 
  8041608ed8:	ff d0                	call   *%rax
  8041608eda:	48 89 c2             	mov    %rax,%rdx
        unsigned lflag = 0, hflag = 0, base = 10;
  8041608edd:	b9 0a 00 00 00       	mov    $0xa,%ecx
            goto number;
  8041608ee2:	eb 55                	jmp    8041608f39 <vprintfmt+0x4dc>
            num = get_unsigned(&aq, lflag, zflag, hflag);
  8041608ee4:	45 89 cd             	mov    %r9d,%r13d
  8041608ee7:	0f b6 d2             	movzbl %dl,%edx
  8041608eea:	48 8d 7d b8          	lea    -0x48(%rbp),%rdi
  8041608eee:	48 b8 2a 89 60 41 80 	movabs $0x804160892a,%rax
  8041608ef5:	00 00 00 
  8041608ef8:	ff d0                	call   *%rax
  8041608efa:	48 89 c2             	mov    %rax,%rdx
            base = 8;
  8041608efd:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  8041608f02:	eb 35                	jmp    8041608f39 <vprintfmt+0x4dc>
            putch('0', put_arg);
  8041608f04:	45 89 cd             	mov    %r9d,%r13d
  8041608f07:	4c 89 f6             	mov    %r14,%rsi
  8041608f0a:	bf 30 00 00 00       	mov    $0x30,%edi
  8041608f0f:	41 ff d4             	call   *%r12
            putch('x', put_arg);
  8041608f12:	4c 89 f6             	mov    %r14,%rsi
  8041608f15:	bf 78 00 00 00       	mov    $0x78,%edi
  8041608f1a:	41 ff d4             	call   *%r12
            num = (uintptr_t)va_arg(aq, void *);
  8041608f1d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041608f20:	83 f8 2f             	cmp    $0x2f,%eax
  8041608f23:	77 47                	ja     8041608f6c <vprintfmt+0x50f>
  8041608f25:	89 c2                	mov    %eax,%edx
  8041608f27:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041608f2b:	83 c0 08             	add    $0x8,%eax
  8041608f2e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041608f31:	48 8b 12             	mov    (%rdx),%rdx
            base = 16;
  8041608f34:	b9 10 00 00 00       	mov    $0x10,%ecx
            print_num(putch, put_arg, num, base, width, padc, ch == 'X');
  8041608f39:	48 83 ec 08          	sub    $0x8,%rsp
  8041608f3d:	41 80 fd 58          	cmp    $0x58,%r13b
  8041608f41:	0f 94 c0             	sete   %al
  8041608f44:	0f b6 c0             	movzbl %al,%eax
  8041608f47:	50                   	push   %rax
  8041608f48:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  8041608f4d:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  8041608f51:	4c 89 f6             	mov    %r14,%rsi
  8041608f54:	4c 89 e7             	mov    %r12,%rdi
  8041608f57:	48 b8 70 88 60 41 80 	movabs $0x8041608870,%rax
  8041608f5e:	00 00 00 
  8041608f61:	ff d0                	call   *%rax
            break;
  8041608f63:	48 83 c4 10          	add    $0x10,%rsp
  8041608f67:	e9 26 fb ff ff       	jmp    8041608a92 <vprintfmt+0x35>
            num = (uintptr_t)va_arg(aq, void *);
  8041608f6c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041608f70:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041608f74:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041608f78:	eb b7                	jmp    8041608f31 <vprintfmt+0x4d4>
            num = get_unsigned(&aq, lflag, zflag, hflag);
  8041608f7a:	45 89 cd             	mov    %r9d,%r13d
  8041608f7d:	0f b6 d2             	movzbl %dl,%edx
  8041608f80:	48 8d 7d b8          	lea    -0x48(%rbp),%rdi
  8041608f84:	48 b8 2a 89 60 41 80 	movabs $0x804160892a,%rax
  8041608f8b:	00 00 00 
  8041608f8e:	ff d0                	call   *%rax
  8041608f90:	48 89 c2             	mov    %rax,%rdx
            base = 16;
  8041608f93:	b9 10 00 00 00       	mov    $0x10,%ecx
  8041608f98:	eb 9f                	jmp    8041608f39 <vprintfmt+0x4dc>
            num = get_unsigned(&aq, lflag, zflag, hflag);
  8041608f9a:	45 89 cd             	mov    %r9d,%r13d
  8041608f9d:	0f b6 d2             	movzbl %dl,%edx
  8041608fa0:	48 8d 7d b8          	lea    -0x48(%rbp),%rdi
  8041608fa4:	48 b8 2a 89 60 41 80 	movabs $0x804160892a,%rax
  8041608fab:	00 00 00 
  8041608fae:	ff d0                	call   *%rax
  8041608fb0:	48 89 c2             	mov    %rax,%rdx
            base = 2;
  8041608fb3:	b9 02 00 00 00       	mov    $0x2,%ecx
            goto number;
  8041608fb8:	e9 7c ff ff ff       	jmp    8041608f39 <vprintfmt+0x4dc>
            putch(ch, put_arg);
  8041608fbd:	4c 89 f6             	mov    %r14,%rsi
  8041608fc0:	bf 25 00 00 00       	mov    $0x25,%edi
  8041608fc5:	41 ff d4             	call   *%r12
            break;
  8041608fc8:	e9 c5 fa ff ff       	jmp    8041608a92 <vprintfmt+0x35>
            putch('%', put_arg);
  8041608fcd:	4c 89 f6             	mov    %r14,%rsi
  8041608fd0:	bf 25 00 00 00       	mov    $0x25,%edi
  8041608fd5:	41 ff d4             	call   *%r12
            while ((--ufmt)[-1] != '%') /* nothing */
  8041608fd8:	49 83 ef 01          	sub    $0x1,%r15
  8041608fdc:	41 80 7f ff 25       	cmpb   $0x25,-0x1(%r15)
  8041608fe1:	75 f5                	jne    8041608fd8 <vprintfmt+0x57b>
  8041608fe3:	e9 aa fa ff ff       	jmp    8041608a92 <vprintfmt+0x35>
}
  8041608fe8:	48 8d 65 d8          	lea    -0x28(%rbp),%rsp
  8041608fec:	5b                   	pop    %rbx
  8041608fed:	41 5c                	pop    %r12
  8041608fef:	41 5d                	pop    %r13
  8041608ff1:	41 5e                	pop    %r14
  8041608ff3:	41 5f                	pop    %r15
  8041608ff5:	5d                   	pop    %rbp
  8041608ff6:	c3                   	ret    

0000008041608ff7 <vsnprintf>:

int
vsnprintf(char *buf, size_t n, const char *fmt, va_list ap) {
  8041608ff7:	f3 0f 1e fa          	endbr64 
  8041608ffb:	55                   	push   %rbp
  8041608ffc:	48 89 e5             	mov    %rsp,%rbp
  8041608fff:	48 83 ec 20          	sub    $0x20,%rsp
    struct sprintbuf state = {buf, buf + n - 1, 0};
  8041609003:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8041609007:	48 8d 44 37 ff       	lea    -0x1(%rdi,%rsi,1),%rax
  804160900c:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  8041609010:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)

    if (!buf || n < 1) return -E_INVAL;
  8041609017:	48 85 ff             	test   %rdi,%rdi
  804160901a:	74 2b                	je     8041609047 <vsnprintf+0x50>
  804160901c:	48 85 f6             	test   %rsi,%rsi
  804160901f:	74 26                	je     8041609047 <vsnprintf+0x50>

    /* Print the string to the buffer */
    vprintfmt((void *)sprintputch, &state, fmt, ap);
  8041609021:	48 8d 75 e8          	lea    -0x18(%rbp),%rsi
  8041609025:	48 bf 00 8a 60 41 80 	movabs $0x8041608a00,%rdi
  804160902c:	00 00 00 
  804160902f:	48 b8 5d 8a 60 41 80 	movabs $0x8041608a5d,%rax
  8041609036:	00 00 00 
  8041609039:	ff d0                	call   *%rax

    /* Null terminate the buffer */
    *state.start = '\0';
  804160903b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  804160903f:	c6 00 00             	movb   $0x0,(%rax)

    return state.count;
  8041609042:	8b 45 f8             	mov    -0x8(%rbp),%eax
}
  8041609045:	c9                   	leave  
  8041609046:	c3                   	ret    
    if (!buf || n < 1) return -E_INVAL;
  8041609047:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160904c:	eb f7                	jmp    8041609045 <vsnprintf+0x4e>

000000804160904e <snprintf>:

int
snprintf(char *buf, size_t n, const char *fmt, ...) {
  804160904e:	f3 0f 1e fa          	endbr64 
  8041609052:	55                   	push   %rbp
  8041609053:	48 89 e5             	mov    %rsp,%rbp
  8041609056:	48 83 ec 50          	sub    $0x50,%rsp
  804160905a:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  804160905e:	4c 89 45 f0          	mov    %r8,-0x10(%rbp)
  8041609062:	4c 89 4d f8          	mov    %r9,-0x8(%rbp)
    va_list ap;

    va_start(ap, fmt);
  8041609066:	c7 45 b8 18 00 00 00 	movl   $0x18,-0x48(%rbp)
  804160906d:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8041609071:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041609075:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  8041609079:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    int rc = vsnprintf(buf, n, fmt, ap);
  804160907d:	48 8d 4d b8          	lea    -0x48(%rbp),%rcx
  8041609081:	48 b8 f7 8f 60 41 80 	movabs $0x8041608ff7,%rax
  8041609088:	00 00 00 
  804160908b:	ff d0                	call   *%rax
    va_end(ap);

    return rc;
}
  804160908d:	c9                   	leave  
  804160908e:	c3                   	ret    

000000804160908f <readline>:
#define BUFLEN 1024

static char buf[BUFLEN];

char *
readline(const char *prompt) {
  804160908f:	f3 0f 1e fa          	endbr64 
  8041609093:	55                   	push   %rbp
  8041609094:	48 89 e5             	mov    %rsp,%rbp
  8041609097:	41 57                	push   %r15
  8041609099:	41 56                	push   %r14
  804160909b:	41 55                	push   %r13
  804160909d:	41 54                	push   %r12
  804160909f:	53                   	push   %rbx
  80416090a0:	48 83 ec 08          	sub    $0x8,%rsp
    if (prompt) {
  80416090a4:	48 85 ff             	test   %rdi,%rdi
  80416090a7:	74 1e                	je     80416090c7 <readline+0x38>
        cprintf("%s", prompt);
  80416090a9:	48 89 fe             	mov    %rdi,%rsi
  80416090ac:	48 bf 88 a4 60 41 80 	movabs $0x804160a488,%rdi
  80416090b3:	00 00 00 
  80416090b6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416090bb:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  80416090c2:	00 00 00 
  80416090c5:	ff d2                	call   *%rdx
    }

    bool echo = iscons(0);
  80416090c7:	bf 00 00 00 00       	mov    $0x0,%edi
  80416090cc:	48 b8 b8 0e 60 41 80 	movabs $0x8041600eb8,%rax
  80416090d3:	00 00 00 
  80416090d6:	ff d0                	call   *%rax
  80416090d8:	41 89 c6             	mov    %eax,%r14d

    for (size_t i = 0;;) {
  80416090db:	41 bc 00 00 00 00    	mov    $0x0,%r12d
        int c = getchar();
  80416090e1:	49 bd 95 0e 60 41 80 	movabs $0x8041600e95,%r13
  80416090e8:	00 00 00 
        if (c < 0) {
            return NULL;
        } else if ((c == '\b' || c == '\x7F')) {
            if (i) {
                if (echo) {
                    cputchar('\b');
  80416090eb:	49 bf f8 0d 60 41 80 	movabs $0x8041600df8,%r15
  80416090f2:	00 00 00 
  80416090f5:	eb 0e                	jmp    8041609105 <readline+0x76>
            if (i) {
  80416090f7:	4d 85 e4             	test   %r12,%r12
  80416090fa:	74 09                	je     8041609105 <readline+0x76>
                if (echo) {
  80416090fc:	45 85 f6             	test   %r14d,%r14d
  80416090ff:	75 43                	jne    8041609144 <readline+0xb5>
                    cputchar(' ');
                    cputchar('\b');
                }
                i--;
  8041609101:	49 83 ec 01          	sub    $0x1,%r12
        int c = getchar();
  8041609105:	41 ff d5             	call   *%r13
  8041609108:	89 c3                	mov    %eax,%ebx
        if (c < 0) {
  804160910a:	85 c0                	test   %eax,%eax
  804160910c:	0f 88 86 00 00 00    	js     8041609198 <readline+0x109>
        } else if ((c == '\b' || c == '\x7F')) {
  8041609112:	83 f8 08             	cmp    $0x8,%eax
  8041609115:	74 e0                	je     80416090f7 <readline+0x68>
  8041609117:	83 f8 7f             	cmp    $0x7f,%eax
  804160911a:	74 db                	je     80416090f7 <readline+0x68>
            }
        } else if (c >= ' ') {
  804160911c:	83 f8 1f             	cmp    $0x1f,%eax
  804160911f:	7e 44                	jle    8041609165 <readline+0xd6>
            if (i < BUFLEN - 1) {
  8041609121:	49 81 fc fe 03 00 00 	cmp    $0x3fe,%r12
  8041609128:	77 db                	ja     8041609105 <readline+0x76>
                if (echo) {
  804160912a:	45 85 f6             	test   %r14d,%r14d
  804160912d:	75 2f                	jne    804160915e <readline+0xcf>
                    cputchar(c);
                }
                buf[i++] = (char)c;
  804160912f:	48 b8 00 56 e4 41 80 	movabs $0x8041e45600,%rax
  8041609136:	00 00 00 
  8041609139:	42 88 1c 20          	mov    %bl,(%rax,%r12,1)
  804160913d:	4d 8d 64 24 01       	lea    0x1(%r12),%r12
  8041609142:	eb c1                	jmp    8041609105 <readline+0x76>
                    cputchar('\b');
  8041609144:	bf 08 00 00 00       	mov    $0x8,%edi
  8041609149:	41 ff d7             	call   *%r15
                    cputchar(' ');
  804160914c:	bf 20 00 00 00       	mov    $0x20,%edi
  8041609151:	41 ff d7             	call   *%r15
                    cputchar('\b');
  8041609154:	bf 08 00 00 00       	mov    $0x8,%edi
  8041609159:	41 ff d7             	call   *%r15
  804160915c:	eb a3                	jmp    8041609101 <readline+0x72>
                    cputchar(c);
  804160915e:	89 c7                	mov    %eax,%edi
  8041609160:	41 ff d7             	call   *%r15
  8041609163:	eb ca                	jmp    804160912f <readline+0xa0>
            }
        } else if (c == '\n' || c == '\r') {
  8041609165:	83 f8 0a             	cmp    $0xa,%eax
  8041609168:	74 05                	je     804160916f <readline+0xe0>
  804160916a:	83 f8 0d             	cmp    $0xd,%eax
  804160916d:	75 96                	jne    8041609105 <readline+0x76>
            if (echo) {
  804160916f:	45 85 f6             	test   %r14d,%r14d
  8041609172:	75 11                	jne    8041609185 <readline+0xf6>
                cputchar('\n');
            }
            buf[i] = 0;
  8041609174:	48 b8 00 56 e4 41 80 	movabs $0x8041e45600,%rax
  804160917b:	00 00 00 
  804160917e:	42 c6 04 20 00       	movb   $0x0,(%rax,%r12,1)
            return buf;
  8041609183:	eb 18                	jmp    804160919d <readline+0x10e>
                cputchar('\n');
  8041609185:	bf 0a 00 00 00       	mov    $0xa,%edi
  804160918a:	48 b8 f8 0d 60 41 80 	movabs $0x8041600df8,%rax
  8041609191:	00 00 00 
  8041609194:	ff d0                	call   *%rax
  8041609196:	eb dc                	jmp    8041609174 <readline+0xe5>
            return NULL;
  8041609198:	b8 00 00 00 00       	mov    $0x0,%eax
        }
    }
}
  804160919d:	48 83 c4 08          	add    $0x8,%rsp
  80416091a1:	5b                   	pop    %rbx
  80416091a2:	41 5c                	pop    %r12
  80416091a4:	41 5d                	pop    %r13
  80416091a6:	41 5e                	pop    %r14
  80416091a8:	41 5f                	pop    %r15
  80416091aa:	5d                   	pop    %rbp
  80416091ab:	c3                   	ret    

00000080416091ac <strlen>:
 * Primespipe runs 3x faster this way */

#define ASM 1

size_t
strlen(const char *s) {
  80416091ac:	f3 0f 1e fa          	endbr64 
    size_t n = 0;
    while (*s++) n++;
  80416091b0:	80 3f 00             	cmpb   $0x0,(%rdi)
  80416091b3:	74 10                	je     80416091c5 <strlen+0x19>
    size_t n = 0;
  80416091b5:	b8 00 00 00 00       	mov    $0x0,%eax
    while (*s++) n++;
  80416091ba:	48 83 c0 01          	add    $0x1,%rax
  80416091be:	80 3c 07 00          	cmpb   $0x0,(%rdi,%rax,1)
  80416091c2:	75 f6                	jne    80416091ba <strlen+0xe>
  80416091c4:	c3                   	ret    
    size_t n = 0;
  80416091c5:	b8 00 00 00 00       	mov    $0x0,%eax
    return n;
}
  80416091ca:	c3                   	ret    

00000080416091cb <strnlen>:

size_t
strnlen(const char *s, size_t size) {
  80416091cb:	f3 0f 1e fa          	endbr64 
  80416091cf:	48 89 f0             	mov    %rsi,%rax
    size_t n = 0;
  80416091d2:	ba 00 00 00 00       	mov    $0x0,%edx
    while (n < size && *s++) n++;
  80416091d7:	48 85 f6             	test   %rsi,%rsi
  80416091da:	74 11                	je     80416091ed <strnlen+0x22>
  80416091dc:	80 3c 17 00          	cmpb   $0x0,(%rdi,%rdx,1)
  80416091e0:	74 0c                	je     80416091ee <strnlen+0x23>
  80416091e2:	48 83 c2 01          	add    $0x1,%rdx
  80416091e6:	48 39 d0             	cmp    %rdx,%rax
  80416091e9:	75 f1                	jne    80416091dc <strnlen+0x11>
  80416091eb:	eb 04                	jmp    80416091f1 <strnlen+0x26>
  80416091ed:	c3                   	ret    
  80416091ee:	48 89 d0             	mov    %rdx,%rax
    return n;
}
  80416091f1:	c3                   	ret    

00000080416091f2 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  80416091f2:	f3 0f 1e fa          	endbr64 
  80416091f6:	48 89 f8             	mov    %rdi,%rax
    char *res = dst;
    while ((*dst++ = *src++)) /* nothing */
  80416091f9:	ba 00 00 00 00       	mov    $0x0,%edx
  80416091fe:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  8041609202:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  8041609205:	48 83 c2 01          	add    $0x1,%rdx
  8041609209:	84 c9                	test   %cl,%cl
  804160920b:	75 f1                	jne    80416091fe <strcpy+0xc>
        ;
    return res;
}
  804160920d:	c3                   	ret    

000000804160920e <strcat>:

char *
strcat(char *dst, const char *src) {
  804160920e:	f3 0f 1e fa          	endbr64 
  8041609212:	55                   	push   %rbp
  8041609213:	48 89 e5             	mov    %rsp,%rbp
  8041609216:	41 54                	push   %r12
  8041609218:	53                   	push   %rbx
  8041609219:	48 89 fb             	mov    %rdi,%rbx
  804160921c:	49 89 f4             	mov    %rsi,%r12
    size_t len = strlen(dst);
  804160921f:	48 b8 ac 91 60 41 80 	movabs $0x80416091ac,%rax
  8041609226:	00 00 00 
  8041609229:	ff d0                	call   *%rax
    strcpy(dst + len, src);
  804160922b:	48 8d 3c 03          	lea    (%rbx,%rax,1),%rdi
  804160922f:	4c 89 e6             	mov    %r12,%rsi
  8041609232:	48 b8 f2 91 60 41 80 	movabs $0x80416091f2,%rax
  8041609239:	00 00 00 
  804160923c:	ff d0                	call   *%rax
    return dst;
}
  804160923e:	48 89 d8             	mov    %rbx,%rax
  8041609241:	5b                   	pop    %rbx
  8041609242:	41 5c                	pop    %r12
  8041609244:	5d                   	pop    %rbp
  8041609245:	c3                   	ret    

0000008041609246 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8041609246:	f3 0f 1e fa          	endbr64 
  804160924a:	48 89 f8             	mov    %rdi,%rax
    char *ret = dst;
    while (size-- > 0) {
  804160924d:	48 85 d2             	test   %rdx,%rdx
  8041609250:	74 1f                	je     8041609271 <strncpy+0x2b>
  8041609252:	48 01 fa             	add    %rdi,%rdx
  8041609255:	48 89 f9             	mov    %rdi,%rcx
        *dst++ = *src;
  8041609258:	48 83 c1 01          	add    $0x1,%rcx
  804160925c:	44 0f b6 06          	movzbl (%rsi),%r8d
  8041609260:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
        /* If strlen(src) < size, null-pad
         * 'dst' out to 'size' chars */
        if (*src) src++;
  8041609264:	41 80 f8 01          	cmp    $0x1,%r8b
  8041609268:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
    while (size-- > 0) {
  804160926c:	48 39 ca             	cmp    %rcx,%rdx
  804160926f:	75 e7                	jne    8041609258 <strncpy+0x12>
    }
    return ret;
}
  8041609271:	c3                   	ret    

0000008041609272 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size) {
  8041609272:	f3 0f 1e fa          	endbr64 
    char *dst_in = dst;
    if (size) {
  8041609276:	48 89 f8             	mov    %rdi,%rax
  8041609279:	48 85 d2             	test   %rdx,%rdx
  804160927c:	74 24                	je     80416092a2 <strlcpy+0x30>
        while (--size > 0 && *src)
  804160927e:	48 83 ea 01          	sub    $0x1,%rdx
  8041609282:	74 1b                	je     804160929f <strlcpy+0x2d>
  8041609284:	48 8d 0c 17          	lea    (%rdi,%rdx,1),%rcx
  8041609288:	0f b6 16             	movzbl (%rsi),%edx
  804160928b:	84 d2                	test   %dl,%dl
  804160928d:	74 10                	je     804160929f <strlcpy+0x2d>
            *dst++ = *src++;
  804160928f:	48 83 c6 01          	add    $0x1,%rsi
  8041609293:	48 83 c0 01          	add    $0x1,%rax
  8041609297:	88 50 ff             	mov    %dl,-0x1(%rax)
        while (--size > 0 && *src)
  804160929a:	48 39 c8             	cmp    %rcx,%rax
  804160929d:	75 e9                	jne    8041609288 <strlcpy+0x16>
        *dst = '\0';
  804160929f:	c6 00 00             	movb   $0x0,(%rax)
    }
    return dst - dst_in;
  80416092a2:	48 29 f8             	sub    %rdi,%rax
}
  80416092a5:	c3                   	ret    

00000080416092a6 <strcmp>:
    }
    return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  80416092a6:	f3 0f 1e fa          	endbr64 
    while (*p && *p == *q) p++, q++;
  80416092aa:	0f b6 07             	movzbl (%rdi),%eax
  80416092ad:	84 c0                	test   %al,%al
  80416092af:	74 13                	je     80416092c4 <strcmp+0x1e>
  80416092b1:	38 06                	cmp    %al,(%rsi)
  80416092b3:	75 0f                	jne    80416092c4 <strcmp+0x1e>
  80416092b5:	48 83 c7 01          	add    $0x1,%rdi
  80416092b9:	48 83 c6 01          	add    $0x1,%rsi
  80416092bd:	0f b6 07             	movzbl (%rdi),%eax
  80416092c0:	84 c0                	test   %al,%al
  80416092c2:	75 ed                	jne    80416092b1 <strcmp+0xb>
    return (int)((unsigned char)*p - (unsigned char)*q);
  80416092c4:	0f b6 c0             	movzbl %al,%eax
  80416092c7:	0f b6 16             	movzbl (%rsi),%edx
  80416092ca:	29 d0                	sub    %edx,%eax
}
  80416092cc:	c3                   	ret    

00000080416092cd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  80416092cd:	f3 0f 1e fa          	endbr64 
    while (n && *p && *p == *q) n--, p++, q++;
  80416092d1:	48 85 d2             	test   %rdx,%rdx
  80416092d4:	74 1f                	je     80416092f5 <strncmp+0x28>
  80416092d6:	0f b6 07             	movzbl (%rdi),%eax
  80416092d9:	84 c0                	test   %al,%al
  80416092db:	74 1e                	je     80416092fb <strncmp+0x2e>
  80416092dd:	3a 06                	cmp    (%rsi),%al
  80416092df:	75 1a                	jne    80416092fb <strncmp+0x2e>
  80416092e1:	48 83 c7 01          	add    $0x1,%rdi
  80416092e5:	48 83 c6 01          	add    $0x1,%rsi
  80416092e9:	48 83 ea 01          	sub    $0x1,%rdx
  80416092ed:	75 e7                	jne    80416092d6 <strncmp+0x9>

    if (!n) return 0;
  80416092ef:	b8 00 00 00 00       	mov    $0x0,%eax
  80416092f4:	c3                   	ret    
  80416092f5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416092fa:	c3                   	ret    
  80416092fb:	48 85 d2             	test   %rdx,%rdx
  80416092fe:	74 09                	je     8041609309 <strncmp+0x3c>

    return (int)((unsigned char)*p - (unsigned char)*q);
  8041609300:	0f b6 07             	movzbl (%rdi),%eax
  8041609303:	0f b6 16             	movzbl (%rsi),%edx
  8041609306:	29 d0                	sub    %edx,%eax
  8041609308:	c3                   	ret    
    if (!n) return 0;
  8041609309:	b8 00 00 00 00       	mov    $0x0,%eax
}
  804160930e:	c3                   	ret    

000000804160930f <strchr>:

/* Return a pointer to the first occurrence of 'c' in 's',
 *  * or a null pointer if the string has no 'c' */
char *
strchr(const char *str, int c) {
  804160930f:	f3 0f 1e fa          	endbr64 
    for (; *str; str++) {
  8041609313:	0f b6 17             	movzbl (%rdi),%edx
  8041609316:	84 d2                	test   %dl,%dl
  8041609318:	74 18                	je     8041609332 <strchr+0x23>
        if (*str == c) {
  804160931a:	0f be d2             	movsbl %dl,%edx
  804160931d:	39 f2                	cmp    %esi,%edx
  804160931f:	74 17                	je     8041609338 <strchr+0x29>
    for (; *str; str++) {
  8041609321:	48 83 c7 01          	add    $0x1,%rdi
  8041609325:	0f b6 17             	movzbl (%rdi),%edx
  8041609328:	84 d2                	test   %dl,%dl
  804160932a:	75 ee                	jne    804160931a <strchr+0xb>
            return (char *)str;
        }
    }
    return NULL;
  804160932c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609331:	c3                   	ret    
  8041609332:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609337:	c3                   	ret    
  8041609338:	48 89 f8             	mov    %rdi,%rax
}
  804160933b:	c3                   	ret    

000000804160933c <strfind>:

/* Return a pointer to the first occurrence of 'c' in 's',
 *  * or a pointer to the string-ending null character if the string has no 'c' */
char *
strfind(const char *str, int ch) {
  804160933c:	f3 0f 1e fa          	endbr64 
  8041609340:	48 89 f8             	mov    %rdi,%rax
    for (; *str && *str != ch; str++) /* nothing */
  8041609343:	0f b6 17             	movzbl (%rdi),%edx
  8041609346:	84 d2                	test   %dl,%dl
  8041609348:	74 13                	je     804160935d <strfind+0x21>
  804160934a:	0f be d2             	movsbl %dl,%edx
  804160934d:	39 f2                	cmp    %esi,%edx
  804160934f:	74 0b                	je     804160935c <strfind+0x20>
  8041609351:	48 83 c0 01          	add    $0x1,%rax
  8041609355:	0f b6 10             	movzbl (%rax),%edx
  8041609358:	84 d2                	test   %dl,%dl
  804160935a:	75 ee                	jne    804160934a <strfind+0xe>
        ;
    return (char *)str;
}
  804160935c:	c3                   	ret    
  804160935d:	c3                   	ret    

000000804160935e <memset>:


#if ASM
void *
memset(void *v, int c, size_t n) {
  804160935e:	f3 0f 1e fa          	endbr64 
  8041609362:	49 89 f8             	mov    %rdi,%r8
    uint8_t *ptr = v;
    ssize_t ni = n;

    if (__builtin_expect((ni -= ((8 - ((uintptr_t)v & 7))) & 7) < 0, 0)) {
  8041609365:	48 89 f8             	mov    %rdi,%rax
  8041609368:	48 f7 d8             	neg    %rax
  804160936b:	83 e0 07             	and    $0x7,%eax
  804160936e:	49 89 d1             	mov    %rdx,%r9
  8041609371:	49 29 c1             	sub    %rax,%r9
  8041609374:	78 32                	js     80416093a8 <memset+0x4a>
        while (n-- > 0) *ptr++ = c;
        return v;
    }

    uint64_t k = 0x101010101010101ULL * (c & 0xFFU);
  8041609376:	40 0f b6 c6          	movzbl %sil,%eax
  804160937a:	48 ba 01 01 01 01 01 	movabs $0x101010101010101,%rdx
  8041609381:	01 01 01 
  8041609384:	48 0f af c2          	imul   %rdx,%rax

    if (__builtin_expect((uintptr_t)ptr & 7, 0)) {
  8041609388:	40 f6 c7 07          	test   $0x7,%dil
  804160938c:	75 34                	jne    80416093c2 <memset+0x64>
        if ((uintptr_t)ptr & 1) *ptr = k, ptr += 1;
        if ((uintptr_t)ptr & 2) *(uint16_t *)ptr = k, ptr += 2;
        if ((uintptr_t)ptr & 4) *(uint32_t *)ptr = k, ptr += 4;
    }

    if (__builtin_expect(ni >> 3, 1)) {
  804160938e:	4c 89 c9             	mov    %r9,%rcx
  8041609391:	48 c1 f9 03          	sar    $0x3,%rcx
  8041609395:	74 08                	je     804160939f <memset+0x41>
        asm volatile("cld; rep stosq\n" ::"D"(ptr), "a"(k), "c"(ni >> 3)
  8041609397:	fc                   	cld    
  8041609398:	f3 48 ab             	rep stos %rax,%es:(%rdi)
                     : "cc", "memory");
        ni &= 7;
  804160939b:	41 83 e1 07          	and    $0x7,%r9d
    }

    if (__builtin_expect(ni, 0)) {
  804160939f:	4d 85 c9             	test   %r9,%r9
  80416093a2:	75 45                	jne    80416093e9 <memset+0x8b>
        if (ni & 2) *(uint16_t *)ptr = k, ptr += 2;
        if (ni & 1) *ptr = k;
    }

    return v;
}
  80416093a4:	4c 89 c0             	mov    %r8,%rax
  80416093a7:	c3                   	ret    
        while (n-- > 0) *ptr++ = c;
  80416093a8:	48 85 d2             	test   %rdx,%rdx
  80416093ab:	74 f7                	je     80416093a4 <memset+0x46>
  80416093ad:	48 01 fa             	add    %rdi,%rdx
    uint8_t *ptr = v;
  80416093b0:	48 89 f8             	mov    %rdi,%rax
        while (n-- > 0) *ptr++ = c;
  80416093b3:	48 83 c0 01          	add    $0x1,%rax
  80416093b7:	40 88 70 ff          	mov    %sil,-0x1(%rax)
  80416093bb:	48 39 c2             	cmp    %rax,%rdx
  80416093be:	75 f3                	jne    80416093b3 <memset+0x55>
  80416093c0:	eb e2                	jmp    80416093a4 <memset+0x46>
        if ((uintptr_t)ptr & 1) *ptr = k, ptr += 1;
  80416093c2:	40 f6 c7 01          	test   $0x1,%dil
  80416093c6:	74 06                	je     80416093ce <memset+0x70>
  80416093c8:	88 07                	mov    %al,(%rdi)
  80416093ca:	48 8d 7f 01          	lea    0x1(%rdi),%rdi
        if ((uintptr_t)ptr & 2) *(uint16_t *)ptr = k, ptr += 2;
  80416093ce:	40 f6 c7 02          	test   $0x2,%dil
  80416093d2:	74 07                	je     80416093db <memset+0x7d>
  80416093d4:	66 89 07             	mov    %ax,(%rdi)
  80416093d7:	48 83 c7 02          	add    $0x2,%rdi
        if ((uintptr_t)ptr & 4) *(uint32_t *)ptr = k, ptr += 4;
  80416093db:	40 f6 c7 04          	test   $0x4,%dil
  80416093df:	74 ad                	je     804160938e <memset+0x30>
  80416093e1:	89 07                	mov    %eax,(%rdi)
  80416093e3:	48 83 c7 04          	add    $0x4,%rdi
  80416093e7:	eb a5                	jmp    804160938e <memset+0x30>
        if (ni & 4) *(uint32_t *)ptr = k, ptr += 4;
  80416093e9:	41 f6 c1 04          	test   $0x4,%r9b
  80416093ed:	74 06                	je     80416093f5 <memset+0x97>
  80416093ef:	89 07                	mov    %eax,(%rdi)
  80416093f1:	48 83 c7 04          	add    $0x4,%rdi
        if (ni & 2) *(uint16_t *)ptr = k, ptr += 2;
  80416093f5:	41 f6 c1 02          	test   $0x2,%r9b
  80416093f9:	74 07                	je     8041609402 <memset+0xa4>
  80416093fb:	66 89 07             	mov    %ax,(%rdi)
  80416093fe:	48 83 c7 02          	add    $0x2,%rdi
        if (ni & 1) *ptr = k;
  8041609402:	41 f6 c1 01          	test   $0x1,%r9b
  8041609406:	74 9c                	je     80416093a4 <memset+0x46>
  8041609408:	88 07                	mov    %al,(%rdi)
  804160940a:	eb 98                	jmp    80416093a4 <memset+0x46>

000000804160940c <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  804160940c:	f3 0f 1e fa          	endbr64 
  8041609410:	48 89 f8             	mov    %rdi,%rax
  8041609413:	48 89 d1             	mov    %rdx,%rcx
    const char *s = src;
    char *d = dst;

    if (s < d && s + n > d) {
  8041609416:	48 39 fe             	cmp    %rdi,%rsi
  8041609419:	73 3b                	jae    8041609456 <memmove+0x4a>
  804160941b:	48 8d 14 16          	lea    (%rsi,%rdx,1),%rdx
  804160941f:	48 39 fa             	cmp    %rdi,%rdx
  8041609422:	76 32                	jbe    8041609456 <memmove+0x4a>
        s += n;
        d += n;
  8041609424:	48 8d 3c 0f          	lea    (%rdi,%rcx,1),%rdi
        if (!(((intptr_t)s & 7) | ((intptr_t)d & 7) | (n & 7))) {
  8041609428:	48 89 d6             	mov    %rdx,%rsi
  804160942b:	48 09 fe             	or     %rdi,%rsi
  804160942e:	48 09 ce             	or     %rcx,%rsi
  8041609431:	40 f6 c6 07          	test   $0x7,%sil
  8041609435:	75 12                	jne    8041609449 <memmove+0x3d>
            asm volatile("std; rep movsq\n" ::"D"(d - 8), "S"(s - 8), "c"(n / 8)
  8041609437:	48 83 ef 08          	sub    $0x8,%rdi
  804160943b:	48 8d 72 f8          	lea    -0x8(%rdx),%rsi
  804160943f:	48 c1 e9 03          	shr    $0x3,%rcx
  8041609443:	fd                   	std    
  8041609444:	f3 48 a5             	rep movsq %ds:(%rsi),%es:(%rdi)
        } else {
            asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
                         : "cc", "memory");
        }
        /* Some versions of GCC rely on DF being clear */
        asm volatile("cld" ::
  8041609447:	fc                   	cld    
  8041609448:	c3                   	ret    
            asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  8041609449:	48 83 ef 01          	sub    $0x1,%rdi
  804160944d:	48 8d 72 ff          	lea    -0x1(%rdx),%rsi
  8041609451:	fd                   	std    
  8041609452:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
  8041609454:	eb f1                	jmp    8041609447 <memmove+0x3b>
                             : "cc");
    } else {
        if (!(((intptr_t)s & 7) | ((intptr_t)d & 7) | (n & 7))) {
  8041609456:	48 89 f2             	mov    %rsi,%rdx
  8041609459:	48 09 c2             	or     %rax,%rdx
  804160945c:	48 09 ca             	or     %rcx,%rdx
  804160945f:	f6 c2 07             	test   $0x7,%dl
  8041609462:	75 0c                	jne    8041609470 <memmove+0x64>
            asm volatile("cld; rep movsq\n" ::"D"(d), "S"(s), "c"(n / 8)
  8041609464:	48 c1 e9 03          	shr    $0x3,%rcx
  8041609468:	48 89 c7             	mov    %rax,%rdi
  804160946b:	fc                   	cld    
  804160946c:	f3 48 a5             	rep movsq %ds:(%rsi),%es:(%rdi)
  804160946f:	c3                   	ret    
                         : "cc", "memory");
        } else {
            asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  8041609470:	48 89 c7             	mov    %rax,%rdi
  8041609473:	fc                   	cld    
  8041609474:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                         : "cc", "memory");
        }
    }
    return dst;
}
  8041609476:	c3                   	ret    

0000008041609477 <memcpy>:
    return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  8041609477:	f3 0f 1e fa          	endbr64 
  804160947b:	55                   	push   %rbp
  804160947c:	48 89 e5             	mov    %rsp,%rbp
    return memmove(dst, src, n);
  804160947f:	48 b8 0c 94 60 41 80 	movabs $0x804160940c,%rax
  8041609486:	00 00 00 
  8041609489:	ff d0                	call   *%rax
}
  804160948b:	5d                   	pop    %rbp
  804160948c:	c3                   	ret    

000000804160948d <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  804160948d:	f3 0f 1e fa          	endbr64 
  8041609491:	55                   	push   %rbp
  8041609492:	48 89 e5             	mov    %rsp,%rbp
  8041609495:	41 57                	push   %r15
  8041609497:	41 56                	push   %r14
  8041609499:	41 55                	push   %r13
  804160949b:	41 54                	push   %r12
  804160949d:	53                   	push   %rbx
  804160949e:	48 83 ec 08          	sub    $0x8,%rsp
  80416094a2:	49 89 fe             	mov    %rdi,%r14
  80416094a5:	49 89 f7             	mov    %rsi,%r15
  80416094a8:	48 89 d3             	mov    %rdx,%rbx
    const size_t srclen = strlen(src);
  80416094ab:	48 89 f7             	mov    %rsi,%rdi
  80416094ae:	48 b8 ac 91 60 41 80 	movabs $0x80416091ac,%rax
  80416094b5:	00 00 00 
  80416094b8:	ff d0                	call   *%rax
  80416094ba:	49 89 c4             	mov    %rax,%r12
    const size_t dstlen = strnlen(dst, maxlen);
  80416094bd:	48 89 de             	mov    %rbx,%rsi
  80416094c0:	4c 89 f7             	mov    %r14,%rdi
  80416094c3:	48 b8 cb 91 60 41 80 	movabs $0x80416091cb,%rax
  80416094ca:	00 00 00 
  80416094cd:	ff d0                	call   *%rax
  80416094cf:	49 89 c5             	mov    %rax,%r13
    if (dstlen == maxlen) return maxlen + srclen;
  80416094d2:	48 39 c3             	cmp    %rax,%rbx
  80416094d5:	74 36                	je     804160950d <strlcat+0x80>
    if (srclen < maxlen - dstlen) {
  80416094d7:	48 89 d8             	mov    %rbx,%rax
  80416094da:	4c 29 e8             	sub    %r13,%rax
  80416094dd:	4c 39 e0             	cmp    %r12,%rax
  80416094e0:	76 31                	jbe    8041609513 <strlcat+0x86>
        memcpy(dst + dstlen, src, srclen + 1);
  80416094e2:	49 8d 54 24 01       	lea    0x1(%r12),%rdx
  80416094e7:	4b 8d 3c 2e          	lea    (%r14,%r13,1),%rdi
  80416094eb:	4c 89 fe             	mov    %r15,%rsi
  80416094ee:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  80416094f5:	00 00 00 
  80416094f8:	ff d0                	call   *%rax
    return dstlen + srclen;
  80416094fa:	4b 8d 04 2c          	lea    (%r12,%r13,1),%rax
}
  80416094fe:	48 83 c4 08          	add    $0x8,%rsp
  8041609502:	5b                   	pop    %rbx
  8041609503:	41 5c                	pop    %r12
  8041609505:	41 5d                	pop    %r13
  8041609507:	41 5e                	pop    %r14
  8041609509:	41 5f                	pop    %r15
  804160950b:	5d                   	pop    %rbp
  804160950c:	c3                   	ret    
    if (dstlen == maxlen) return maxlen + srclen;
  804160950d:	49 8d 04 04          	lea    (%r12,%rax,1),%rax
  8041609511:	eb eb                	jmp    80416094fe <strlcat+0x71>
        memcpy(dst + dstlen, src, maxlen - 1);
  8041609513:	48 83 eb 01          	sub    $0x1,%rbx
  8041609517:	4b 8d 3c 2e          	lea    (%r14,%r13,1),%rdi
  804160951b:	48 89 da             	mov    %rbx,%rdx
  804160951e:	4c 89 fe             	mov    %r15,%rsi
  8041609521:	48 b8 77 94 60 41 80 	movabs $0x8041609477,%rax
  8041609528:	00 00 00 
  804160952b:	ff d0                	call   *%rax
        dst[dstlen + maxlen - 1] = '\0';
  804160952d:	49 01 de             	add    %rbx,%r14
  8041609530:	43 c6 04 2e 00       	movb   $0x0,(%r14,%r13,1)
  8041609535:	eb c3                	jmp    80416094fa <strlcat+0x6d>

0000008041609537 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n) {
  8041609537:	f3 0f 1e fa          	endbr64 
    const uint8_t *s1 = (const uint8_t *)v1;
    const uint8_t *s2 = (const uint8_t *)v2;

    while (n-- > 0) {
  804160953b:	48 85 d2             	test   %rdx,%rdx
  804160953e:	74 2d                	je     804160956d <memcmp+0x36>
  8041609540:	b8 00 00 00 00       	mov    $0x0,%eax
        if (*s1 != *s2) {
  8041609545:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  8041609549:	44 0f b6 04 06       	movzbl (%rsi,%rax,1),%r8d
  804160954e:	44 38 c1             	cmp    %r8b,%cl
  8041609551:	75 0f                	jne    8041609562 <memcmp+0x2b>
    while (n-- > 0) {
  8041609553:	48 83 c0 01          	add    $0x1,%rax
  8041609557:	48 39 c2             	cmp    %rax,%rdx
  804160955a:	75 e9                	jne    8041609545 <memcmp+0xe>
            return (int)*s1 - (int)*s2;
        }
        s1++, s2++;
    }

    return 0;
  804160955c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609561:	c3                   	ret    
            return (int)*s1 - (int)*s2;
  8041609562:	0f b6 c1             	movzbl %cl,%eax
  8041609565:	45 0f b6 c0          	movzbl %r8b,%r8d
  8041609569:	44 29 c0             	sub    %r8d,%eax
  804160956c:	c3                   	ret    
    return 0;
  804160956d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041609572:	c3                   	ret    

0000008041609573 <memfind>:

void *
memfind(const void *src, int c, size_t n) {
  8041609573:	f3 0f 1e fa          	endbr64 
    const void *end = (const char *)src + n;
  8041609577:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
    for (; src < end; src++) {
  804160957b:	48 39 c7             	cmp    %rax,%rdi
  804160957e:	73 0f                	jae    804160958f <memfind+0x1c>
        if (*(const unsigned char *)src == (unsigned char)c) break;
  8041609580:	40 38 37             	cmp    %sil,(%rdi)
  8041609583:	74 0e                	je     8041609593 <memfind+0x20>
    for (; src < end; src++) {
  8041609585:	48 83 c7 01          	add    $0x1,%rdi
  8041609589:	48 39 f8             	cmp    %rdi,%rax
  804160958c:	75 f2                	jne    8041609580 <memfind+0xd>
  804160958e:	c3                   	ret    
  804160958f:	48 89 f8             	mov    %rdi,%rax
  8041609592:	c3                   	ret    
  8041609593:	48 89 f8             	mov    %rdi,%rax
    }
    return (void *)src;
}
  8041609596:	c3                   	ret    

0000008041609597 <strtol>:

long
strtol(const char *s, char **endptr, int base) {
  8041609597:	f3 0f 1e fa          	endbr64 
  804160959b:	49 89 f2             	mov    %rsi,%r10
    /* Gobble initial whitespace */
    while (*s == ' ' || *s == '\t') s++;
  804160959e:	44 0f b6 07          	movzbl (%rdi),%r8d
  80416095a2:	41 80 f8 20          	cmp    $0x20,%r8b
  80416095a6:	74 06                	je     80416095ae <strtol+0x17>
  80416095a8:	41 80 f8 09          	cmp    $0x9,%r8b
  80416095ac:	75 14                	jne    80416095c2 <strtol+0x2b>
  80416095ae:	48 83 c7 01          	add    $0x1,%rdi
  80416095b2:	44 0f b6 07          	movzbl (%rdi),%r8d
  80416095b6:	41 80 f8 20          	cmp    $0x20,%r8b
  80416095ba:	74 f2                	je     80416095ae <strtol+0x17>
  80416095bc:	41 80 f8 09          	cmp    $0x9,%r8b
  80416095c0:	74 ec                	je     80416095ae <strtol+0x17>

    bool neg = *s == '-';

    /* Plus/minus sign */
    if (*s == '+' || *s == '-') s++;
  80416095c2:	41 8d 40 d5          	lea    -0x2b(%r8),%eax
  80416095c6:	83 e0 fd             	and    $0xfffffffd,%eax
  80416095c9:	3c 01                	cmp    $0x1,%al
  80416095cb:	48 83 d7 00          	adc    $0x0,%rdi

    /* Hex or octal base prefix */
    if ((!base || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  80416095cf:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  80416095d5:	75 0f                	jne    80416095e6 <strtol+0x4f>
  80416095d7:	80 3f 30             	cmpb   $0x30,(%rdi)
  80416095da:	74 14                	je     80416095f0 <strtol+0x59>
        s += 2;
    } else if (!base && s[0] == '0') {
        base = 8;
        s++;
    } else if (!base) {
        base = 10;
  80416095dc:	85 d2                	test   %edx,%edx
  80416095de:	b8 0a 00 00 00       	mov    $0xa,%eax
  80416095e3:	0f 44 d0             	cmove  %eax,%edx
    }

    /* Digits */
    long val = 0;
  80416095e6:	b8 00 00 00 00       	mov    $0x0,%eax
            break;

        if (dig >= base) break;

        /* We don't properly detect overflow! */
        val = val * base + dig;
  80416095eb:	4c 63 ca             	movslq %edx,%r9
  80416095ee:	eb 34                	jmp    8041609624 <strtol+0x8d>
    if ((!base || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  80416095f0:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  80416095f4:	74 0f                	je     8041609605 <strtol+0x6e>
    } else if (!base && s[0] == '0') {
  80416095f6:	85 d2                	test   %edx,%edx
  80416095f8:	75 ec                	jne    80416095e6 <strtol+0x4f>
        s++;
  80416095fa:	48 83 c7 01          	add    $0x1,%rdi
        base = 8;
  80416095fe:	ba 08 00 00 00       	mov    $0x8,%edx
        s++;
  8041609603:	eb e1                	jmp    80416095e6 <strtol+0x4f>
        s += 2;
  8041609605:	48 83 c7 02          	add    $0x2,%rdi
        base = 16;
  8041609609:	ba 10 00 00 00       	mov    $0x10,%edx
        s += 2;
  804160960e:	eb d6                	jmp    80416095e6 <strtol+0x4f>
            dig -= '0';
  8041609610:	83 e9 30             	sub    $0x30,%ecx
        if (dig >= base) break;
  8041609613:	0f b6 f1             	movzbl %cl,%esi
  8041609616:	39 d6                	cmp    %edx,%esi
  8041609618:	7d 21                	jge    804160963b <strtol+0xa4>
        val = val * base + dig;
  804160961a:	49 0f af c1          	imul   %r9,%rax
  804160961e:	0f b6 c9             	movzbl %cl,%ecx
  8041609621:	48 01 c8             	add    %rcx,%rax
        uint8_t dig = *s++;
  8041609624:	48 83 c7 01          	add    $0x1,%rdi
  8041609628:	0f b6 4f ff          	movzbl -0x1(%rdi),%ecx
        if (dig - '0' < 10)
  804160962c:	80 f9 39             	cmp    $0x39,%cl
  804160962f:	76 df                	jbe    8041609610 <strtol+0x79>
        else if (dig - 'a' < 27)
  8041609631:	80 f9 7b             	cmp    $0x7b,%cl
  8041609634:	77 05                	ja     804160963b <strtol+0xa4>
            dig -= 'a' - 10;
  8041609636:	83 e9 57             	sub    $0x57,%ecx
  8041609639:	eb d8                	jmp    8041609613 <strtol+0x7c>
    }

    if (endptr) *endptr = (char *)s;
  804160963b:	4d 85 d2             	test   %r10,%r10
  804160963e:	74 03                	je     8041609643 <strtol+0xac>
  8041609640:	49 89 3a             	mov    %rdi,(%r10)

    return (neg ? -val : val);
  8041609643:	48 89 c2             	mov    %rax,%rdx
  8041609646:	48 f7 da             	neg    %rdx
  8041609649:	41 80 f8 2d          	cmp    $0x2d,%r8b
  804160964d:	48 0f 44 c2          	cmove  %rdx,%rax
}
  8041609651:	c3                   	ret    

0000008041609652 <tsc_calibrate>:

    return delta;
}

uint64_t
tsc_calibrate(void) {
  8041609652:	f3 0f 1e fa          	endbr64 
  8041609656:	55                   	push   %rbp
  8041609657:	48 89 e5             	mov    %rsp,%rbp
  804160965a:	41 57                	push   %r15
  804160965c:	41 56                	push   %r14
  804160965e:	41 55                	push   %r13
  8041609660:	41 54                	push   %r12
  8041609662:	53                   	push   %rbx
  8041609663:	48 83 ec 18          	sub    $0x18,%rsp
    static uint64_t cpu_freq;

    if (!cpu_freq) {
  8041609667:	48 a1 00 5a e4 41 80 	movabs 0x8041e45a00,%rax
  804160966e:	00 00 00 
  8041609671:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041609675:	48 85 c0             	test   %rax,%rax
  8041609678:	0f 85 83 01 00 00    	jne    8041609801 <tsc_calibrate+0x1af>
        int i = TIMES;
        while (--i > 0) {
  804160967e:	41 be 63 00 00 00    	mov    $0x63,%r14d
    asm volatile("inb %w1,%0"
  8041609684:	41 bd 61 00 00 00    	mov    $0x61,%r13d
    asm volatile("outb %0,%w1" ::"a"(data), "d"(port));
  804160968a:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8041609690:	be 42 00 00 00       	mov    $0x42,%esi
  8041609695:	eb 30                	jmp    80416096c7 <tsc_calibrate+0x75>
    uint64_t tsc = 0;
  8041609697:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
    while (count++ < 50000) {
  804160969b:	bf 01 00 00 00       	mov    $0x1,%edi
  80416096a0:	eb 70                	jmp    8041609712 <tsc_calibrate+0xc0>
    uint64_t tsc = 0;
  80416096a2:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
    while (count++ < 50000) {
  80416096a6:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  80416096ac:	e9 bf 00 00 00       	jmp    8041609770 <tsc_calibrate+0x11e>
        for (i = 1; i <= MAX_QUICK_PIT_ITERATIONS; i++) {
  80416096b1:	83 c3 01             	add    $0x1,%ebx
  80416096b4:	41 83 e9 01          	sub    $0x1,%r9d
  80416096b8:	83 fb 75             	cmp    $0x75,%ebx
  80416096bb:	75 79                	jne    8041609736 <tsc_calibrate+0xe4>
        while (--i > 0) {
  80416096bd:	41 83 ee 01          	sub    $0x1,%r14d
  80416096c1:	0f 84 5a 01 00 00    	je     8041609821 <tsc_calibrate+0x1cf>
    asm volatile("inb %w1,%0"
  80416096c7:	44 89 ea             	mov    %r13d,%edx
  80416096ca:	ec                   	in     (%dx),%al
    outb(0x61, (inb(0x61) & ~0x02) | 0x01);
  80416096cb:	83 e0 fc             	and    $0xfffffffc,%eax
  80416096ce:	83 c8 01             	or     $0x1,%eax
    asm volatile("outb %0,%w1" ::"a"(data), "d"(port));
  80416096d1:	ee                   	out    %al,(%dx)
  80416096d2:	b8 b0 ff ff ff       	mov    $0xffffffb0,%eax
  80416096d7:	ba 43 00 00 00       	mov    $0x43,%edx
  80416096dc:	ee                   	out    %al,(%dx)
  80416096dd:	44 89 e0             	mov    %r12d,%eax
  80416096e0:	89 f2                	mov    %esi,%edx
  80416096e2:	ee                   	out    %al,(%dx)
  80416096e3:	ee                   	out    %al,(%dx)
    asm volatile("inb %w1,%0"
  80416096e4:	ec                   	in     (%dx),%al
  80416096e5:	ec                   	in     (%dx),%al
  80416096e6:	ec                   	in     (%dx),%al
  80416096e7:	ec                   	in     (%dx),%al
        if (!pit_verify_msb(val)) break;
  80416096e8:	3c ff                	cmp    $0xff,%al
  80416096ea:	75 ab                	jne    8041609697 <tsc_calibrate+0x45>
    while (count++ < 50000) {
  80416096ec:	bf 01 00 00 00       	mov    $0x1,%edi
    asm volatile("rdtsc"
  80416096f1:	0f 31                	rdtsc  
    return (uint64_t)lo | ((uint64_t)hi << 32);
  80416096f3:	48 c1 e2 20          	shl    $0x20,%rdx
  80416096f7:	89 c0                	mov    %eax,%eax
  80416096f9:	48 89 d1             	mov    %rdx,%rcx
  80416096fc:	48 09 c1             	or     %rax,%rcx
  80416096ff:	83 c7 01             	add    $0x1,%edi
  8041609702:	81 ff 51 c3 00 00    	cmp    $0xc351,%edi
  8041609708:	74 08                	je     8041609712 <tsc_calibrate+0xc0>
    asm volatile("inb %w1,%0"
  804160970a:	89 f2                	mov    %esi,%edx
  804160970c:	ec                   	in     (%dx),%al
  804160970d:	ec                   	in     (%dx),%al
        if (!pit_verify_msb(val)) break;
  804160970e:	3c ff                	cmp    $0xff,%al
  8041609710:	74 df                	je     80416096f1 <tsc_calibrate+0x9f>
    asm volatile("rdtsc"
  8041609712:	0f 31                	rdtsc  
    if (pit_expect_msb(0xFF, &tsc, &d1)) {
  8041609714:	83 ff 06             	cmp    $0x6,%edi
  8041609717:	7e a4                	jle    80416096bd <tsc_calibrate+0x6b>
    return (uint64_t)lo | ((uint64_t)hi << 32);
  8041609719:	48 c1 e2 20          	shl    $0x20,%rdx
  804160971d:	89 c0                	mov    %eax,%eax
  804160971f:	48 09 c2             	or     %rax,%rdx
  8041609722:	49 89 d3             	mov    %rdx,%r11
    *deltap = read_tsc() - tsc;
  8041609725:	49 89 d7             	mov    %rdx,%r15
  8041609728:	49 29 cf             	sub    %rcx,%r15
  804160972b:	41 b9 fe ff ff ff    	mov    $0xfffffffe,%r9d
        for (i = 1; i <= MAX_QUICK_PIT_ITERATIONS; i++) {
  8041609731:	bb 01 00 00 00       	mov    $0x1,%ebx
            if (!pit_expect_msb(0xFF - i, &delta, &d2)) break;
  8041609736:	88 5d cf             	mov    %bl,-0x31(%rbp)
    asm volatile("inb %w1,%0"
  8041609739:	89 f2                	mov    %esi,%edx
  804160973b:	ec                   	in     (%dx),%al
  804160973c:	ec                   	in     (%dx),%al
        if (!pit_verify_msb(val)) break;
  804160973d:	41 38 c1             	cmp    %al,%r9b
  8041609740:	0f 85 5c ff ff ff    	jne    80416096a2 <tsc_calibrate+0x50>
    while (count++ < 50000) {
  8041609746:	41 b8 01 00 00 00    	mov    $0x1,%r8d
    asm volatile("rdtsc"
  804160974c:	0f 31                	rdtsc  
    return (uint64_t)lo | ((uint64_t)hi << 32);
  804160974e:	48 c1 e2 20          	shl    $0x20,%rdx
  8041609752:	89 c0                	mov    %eax,%eax
  8041609754:	48 89 d7             	mov    %rdx,%rdi
  8041609757:	48 09 c7             	or     %rax,%rdi
  804160975a:	41 83 c0 01          	add    $0x1,%r8d
  804160975e:	41 81 f8 51 c3 00 00 	cmp    $0xc351,%r8d
  8041609765:	74 09                	je     8041609770 <tsc_calibrate+0x11e>
    asm volatile("inb %w1,%0"
  8041609767:	89 f2                	mov    %esi,%edx
  8041609769:	ec                   	in     (%dx),%al
  804160976a:	ec                   	in     (%dx),%al
        if (!pit_verify_msb(val)) break;
  804160976b:	44 38 c8             	cmp    %r9b,%al
  804160976e:	74 dc                	je     804160974c <tsc_calibrate+0xfa>
    asm volatile("rdtsc"
  8041609770:	0f 31                	rdtsc  
    return (uint64_t)lo | ((uint64_t)hi << 32);
  8041609772:	48 c1 e2 20          	shl    $0x20,%rdx
  8041609776:	89 c0                	mov    %eax,%eax
  8041609778:	48 09 c2             	or     %rax,%rdx
    *deltap = read_tsc() - tsc;
  804160977b:	48 29 fa             	sub    %rdi,%rdx
  804160977e:	49 89 d2             	mov    %rdx,%r10
            if (!pit_expect_msb(0xFF - i, &delta, &d2)) break;
  8041609781:	41 83 f8 06          	cmp    $0x6,%r8d
  8041609785:	0f 8e 32 ff ff ff    	jle    80416096bd <tsc_calibrate+0x6b>
            delta -= tsc;
  804160978b:	48 29 cf             	sub    %rcx,%rdi
  804160978e:	48 89 fa             	mov    %rdi,%rdx
            if (d1 + d2 >= delta >> 11) continue;
  8041609791:	4b 8d 3c 17          	lea    (%r15,%r10,1),%rdi
  8041609795:	48 89 d0             	mov    %rdx,%rax
  8041609798:	48 c1 e8 0b          	shr    $0xb,%rax
  804160979c:	48 39 c7             	cmp    %rax,%rdi
  804160979f:	0f 83 0c ff ff ff    	jae    80416096b1 <tsc_calibrate+0x5f>
    asm volatile("inb %w1,%0"
  80416097a5:	48 89 d7             	mov    %rdx,%rdi
  80416097a8:	89 f2                	mov    %esi,%edx
  80416097aa:	ec                   	in     (%dx),%al
  80416097ab:	ec                   	in     (%dx),%al
            if (!pit_verify_msb(0xFE - i)) break;
  80416097ac:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
  80416097b1:	2a 55 cf             	sub    -0x31(%rbp),%dl
  80416097b4:	38 c2                	cmp    %al,%dl
  80416097b6:	0f 85 01 ff ff ff    	jne    80416096bd <tsc_calibrate+0x6b>
    delta += (long)(d2 - d1) / 2;
  80416097bc:	4c 29 d9             	sub    %r11,%rcx
  80416097bf:	4a 8d 04 11          	lea    (%rcx,%r10,1),%rax
  80416097c3:	48 89 c2             	mov    %rax,%rdx
  80416097c6:	48 c1 ea 3f          	shr    $0x3f,%rdx
  80416097ca:	48 01 d0             	add    %rdx,%rax
  80416097cd:	48 d1 f8             	sar    %rax
  80416097d0:	48 01 c7             	add    %rax,%rdi
    delta *= PIT_TICK_RATE;
  80416097d3:	48 69 ff de 34 12 00 	imul   $0x1234de,%rdi,%rdi
    delta /= i * 256 * 1000;
  80416097da:	69 cb 00 e8 03 00    	imul   $0x3e800,%ebx,%ecx
  80416097e0:	48 63 c9             	movslq %ecx,%rcx
  80416097e3:	48 89 f8             	mov    %rdi,%rax
  80416097e6:	ba 00 00 00 00       	mov    $0x0,%edx
  80416097eb:	48 f7 f1             	div    %rcx
            if ((cpu_freq = quick_pit_calibrate())) break;
  80416097ee:	48 39 cf             	cmp    %rcx,%rdi
  80416097f1:	0f 82 c6 fe ff ff    	jb     80416096bd <tsc_calibrate+0x6b>
  80416097f7:	48 a3 00 5a e4 41 80 	movabs %rax,0x8041e45a00
  80416097fe:	00 00 00 
            cpu_freq = DEFAULT_FREQ;
            cprintf("Can't calibrate pit timer. Using default frequency\n");
        }
    }

    return cpu_freq * 1000;
  8041609801:	48 a1 00 5a e4 41 80 	movabs 0x8041e45a00,%rax
  8041609808:	00 00 00 
  804160980b:	48 69 c0 e8 03 00 00 	imul   $0x3e8,%rax,%rax
}
  8041609812:	48 83 c4 18          	add    $0x18,%rsp
  8041609816:	5b                   	pop    %rbx
  8041609817:	41 5c                	pop    %r12
  8041609819:	41 5d                	pop    %r13
  804160981b:	41 5e                	pop    %r14
  804160981d:	41 5f                	pop    %r15
  804160981f:	5d                   	pop    %rbp
  8041609820:	c3                   	ret    
            cpu_freq = DEFAULT_FREQ;
  8041609821:	48 b8 00 5a e4 41 80 	movabs $0x8041e45a00,%rax
  8041609828:	00 00 00 
  804160982b:	48 c7 00 a0 25 26 00 	movq   $0x2625a0,(%rax)
            cprintf("Can't calibrate pit timer. Using default frequency\n");
  8041609832:	48 bf 18 c0 60 41 80 	movabs $0x804160c018,%rdi
  8041609839:	00 00 00 
  804160983c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609841:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  8041609848:	00 00 00 
  804160984b:	ff d2                	call   *%rdx
  804160984d:	eb b2                	jmp    8041609801 <tsc_calibrate+0x1af>

000000804160984f <print_time>:

void
print_time(unsigned seconds) {
  804160984f:	f3 0f 1e fa          	endbr64 
  8041609853:	55                   	push   %rbp
  8041609854:	48 89 e5             	mov    %rsp,%rbp
  8041609857:	89 fe                	mov    %edi,%esi
    cprintf("%u\n", seconds);
  8041609859:	48 bf 4c c0 60 41 80 	movabs $0x804160c04c,%rdi
  8041609860:	00 00 00 
  8041609863:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609868:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  804160986f:	00 00 00 
  8041609872:	ff d2                	call   *%rdx
}
  8041609874:	5d                   	pop    %rbp
  8041609875:	c3                   	ret    

0000008041609876 <print_timer_error>:

void
print_timer_error(void) {
  8041609876:	f3 0f 1e fa          	endbr64 
  804160987a:	55                   	push   %rbp
  804160987b:	48 89 e5             	mov    %rsp,%rbp
    cprintf("Timer Error\n");
  804160987e:	48 bf 50 c0 60 41 80 	movabs $0x804160c050,%rdi
  8041609885:	00 00 00 
  8041609888:	b8 00 00 00 00       	mov    $0x0,%eax
  804160988d:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  8041609894:	00 00 00 
  8041609897:	ff d2                	call   *%rdx
}
  8041609899:	5d                   	pop    %rbp
  804160989a:	c3                   	ret    

000000804160989b <timer_start>:
static int timer_id = -1;
static uint64_t timer = 0;
static uint64_t freq = 0;

void
timer_start(const char *name) {
  804160989b:	f3 0f 1e fa          	endbr64 
  804160989f:	55                   	push   %rbp
  80416098a0:	48 89 e5             	mov    %rsp,%rbp
  80416098a3:	41 57                	push   %r15
  80416098a5:	41 56                	push   %r14
  80416098a7:	41 55                	push   %r13
  80416098a9:	41 54                	push   %r12
  80416098ab:	53                   	push   %rbx
  80416098ac:	48 83 ec 08          	sub    $0x8,%rsp
  80416098b0:	49 89 fd             	mov    %rdi,%r13
    (void)timer_started;
    (void)timer_id;
    (void)timer;
    (void)freq;

    for(int i = 0; i < MAX_TIMERS; i++){
  80416098b3:	49 bc a0 54 e4 41 80 	movabs $0x8041e454a0,%r12
  80416098ba:	00 00 00 
  80416098bd:	bb 00 00 00 00       	mov    $0x0,%ebx
        if(strcmp(timertab[i].timer_name, name) == 0){
  80416098c2:	49 be a6 92 60 41 80 	movabs $0x80416092a6,%r14
  80416098c9:	00 00 00 
            freq = timertab[i].get_cpu_freq();
  80416098cc:	49 bf 08 5a e4 41 80 	movabs $0x8041e45a08,%r15
  80416098d3:	00 00 00 
  80416098d6:	eb 0c                	jmp    80416098e4 <timer_start+0x49>
    for(int i = 0; i < MAX_TIMERS; i++){
  80416098d8:	83 c3 01             	add    $0x1,%ebx
  80416098db:	49 83 c4 28          	add    $0x28,%r12
  80416098df:	83 fb 05             	cmp    $0x5,%ebx
  80416098e2:	74 49                	je     804160992d <timer_start+0x92>
        if(strcmp(timertab[i].timer_name, name) == 0){
  80416098e4:	4c 89 ee             	mov    %r13,%rsi
  80416098e7:	49 8b 3c 24          	mov    (%r12),%rdi
  80416098eb:	41 ff d6             	call   *%r14
  80416098ee:	85 c0                	test   %eax,%eax
  80416098f0:	75 e6                	jne    80416098d8 <timer_start+0x3d>
            freq = timertab[i].get_cpu_freq();
  80416098f2:	41 ff 54 24 10       	call   *0x10(%r12)
  80416098f7:	49 89 07             	mov    %rax,(%r15)
    asm volatile("rdtsc"
  80416098fa:	0f 31                	rdtsc  
    return (uint64_t)lo | ((uint64_t)hi << 32);
  80416098fc:	48 c1 e2 20          	shl    $0x20,%rdx
  8041609900:	89 c0                	mov    %eax,%eax
  8041609902:	48 09 c2             	or     %rax,%rdx
  8041609905:	48 b8 10 5a e4 41 80 	movabs $0x8041e45a10,%rax
  804160990c:	00 00 00 
  804160990f:	48 89 10             	mov    %rdx,(%rax)
            timer = read_tsc();
            timer_id = i;
  8041609912:	48 b8 c0 d8 62 41 80 	movabs $0x804162d8c0,%rax
  8041609919:	00 00 00 
  804160991c:	89 18                	mov    %ebx,(%rax)
            timer_started = 1;
  804160991e:	48 b8 18 5a e4 41 80 	movabs $0x8041e45a18,%rax
  8041609925:	00 00 00 
  8041609928:	c6 00 01             	movb   $0x1,(%rax)
  804160992b:	eb ab                	jmp    80416098d8 <timer_start+0x3d>
        }
    }
    
    return;
}
  804160992d:	48 83 c4 08          	add    $0x8,%rsp
  8041609931:	5b                   	pop    %rbx
  8041609932:	41 5c                	pop    %r12
  8041609934:	41 5d                	pop    %r13
  8041609936:	41 5e                	pop    %r14
  8041609938:	41 5f                	pop    %r15
  804160993a:	5d                   	pop    %rbp
  804160993b:	c3                   	ret    

000000804160993c <timer_stop>:

void
timer_stop(void) {
  804160993c:	f3 0f 1e fa          	endbr64 
  8041609940:	55                   	push   %rbp
  8041609941:	48 89 e5             	mov    %rsp,%rbp
    asm volatile("rdtsc"
  8041609944:	0f 31                	rdtsc  
  8041609946:	89 c1                	mov    %eax,%ecx

    uint64_t timer_div = read_tsc() - timer;
  8041609948:	48 a1 10 5a e4 41 80 	movabs 0x8041e45a10,%rax
  804160994f:	00 00 00 
    if(!timer_started || timer_id == -1){
  8041609952:	48 be 18 5a e4 41 80 	movabs $0x8041e45a18,%rsi
  8041609959:	00 00 00 
  804160995c:	80 3e 00             	cmpb   $0x0,(%rsi)
  804160995f:	74 51                	je     80416099b2 <timer_stop+0x76>
  8041609961:	48 be c0 d8 62 41 80 	movabs $0x804162d8c0,%rsi
  8041609968:	00 00 00 
  804160996b:	83 3e ff             	cmpl   $0xffffffff,(%rsi)
  804160996e:	74 42                	je     80416099b2 <timer_stop+0x76>
    return (uint64_t)lo | ((uint64_t)hi << 32);
  8041609970:	48 89 d7             	mov    %rdx,%rdi
  8041609973:	48 c1 e7 20          	shl    $0x20,%rdi
  8041609977:	89 c9                	mov    %ecx,%ecx
  8041609979:	48 09 cf             	or     %rcx,%rdi
    uint64_t timer_div = read_tsc() - timer;
  804160997c:	48 29 c7             	sub    %rax,%rdi
        print_timer_error();
        return;
    }

    print_time(timer_div / freq);
  804160997f:	48 b9 08 5a e4 41 80 	movabs $0x8041e45a08,%rcx
  8041609986:	00 00 00 
  8041609989:	48 89 f8             	mov    %rdi,%rax
  804160998c:	ba 00 00 00 00       	mov    $0x0,%edx
  8041609991:	48 f7 31             	divq   (%rcx)
  8041609994:	48 89 c7             	mov    %rax,%rdi
  8041609997:	48 b8 4f 98 60 41 80 	movabs $0x804160984f,%rax
  804160999e:	00 00 00 
  80416099a1:	ff d0                	call   *%rax

    timer_started = 0;
  80416099a3:	48 b8 18 5a e4 41 80 	movabs $0x8041e45a18,%rax
  80416099aa:	00 00 00 
  80416099ad:	c6 00 00             	movb   $0x0,(%rax)
    return;
}
  80416099b0:	5d                   	pop    %rbp
  80416099b1:	c3                   	ret    
        print_timer_error();
  80416099b2:	48 b8 76 98 60 41 80 	movabs $0x8041609876,%rax
  80416099b9:	00 00 00 
  80416099bc:	ff d0                	call   *%rax
        return;
  80416099be:	eb f0                	jmp    80416099b0 <timer_stop+0x74>

00000080416099c0 <timer_cpu_frequency>:

void
timer_cpu_frequency(const char *name) {
  80416099c0:	f3 0f 1e fa          	endbr64 
  80416099c4:	55                   	push   %rbp
  80416099c5:	48 89 e5             	mov    %rsp,%rbp
  80416099c8:	41 57                	push   %r15
  80416099ca:	41 56                	push   %r14
  80416099cc:	41 55                	push   %r13
  80416099ce:	41 54                	push   %r12
  80416099d0:	53                   	push   %rbx
  80416099d1:	48 83 ec 08          	sub    $0x8,%rsp
  80416099d5:	49 89 fc             	mov    %rdi,%r12

    for(int i = 0; i < MAX_TIMERS; i++){
  80416099d8:	48 bb a0 54 e4 41 80 	movabs $0x8041e454a0,%rbx
  80416099df:	00 00 00 
  80416099e2:	4c 8d b3 c8 00 00 00 	lea    0xc8(%rbx),%r14
        if(strcmp(timertab[i].timer_name, name) == 0){
  80416099e9:	49 bd a6 92 60 41 80 	movabs $0x80416092a6,%r13
  80416099f0:	00 00 00 
            cprintf("%lu\n", timertab[i].get_cpu_freq());
  80416099f3:	49 bf b7 6f 60 41 80 	movabs $0x8041606fb7,%r15
  80416099fa:	00 00 00 
  80416099fd:	eb 09                	jmp    8041609a08 <timer_cpu_frequency+0x48>
    for(int i = 0; i < MAX_TIMERS; i++){
  80416099ff:	48 83 c3 28          	add    $0x28,%rbx
  8041609a03:	4c 39 f3             	cmp    %r14,%rbx
  8041609a06:	74 27                	je     8041609a2f <timer_cpu_frequency+0x6f>
        if(strcmp(timertab[i].timer_name, name) == 0){
  8041609a08:	4c 89 e6             	mov    %r12,%rsi
  8041609a0b:	48 8b 3b             	mov    (%rbx),%rdi
  8041609a0e:	41 ff d5             	call   *%r13
  8041609a11:	85 c0                	test   %eax,%eax
  8041609a13:	75 ea                	jne    80416099ff <timer_cpu_frequency+0x3f>
            cprintf("%lu\n", timertab[i].get_cpu_freq());
  8041609a15:	ff 53 10             	call   *0x10(%rbx)
  8041609a18:	48 89 c6             	mov    %rax,%rsi
  8041609a1b:	48 bf 9a a7 60 41 80 	movabs $0x804160a79a,%rdi
  8041609a22:	00 00 00 
  8041609a25:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609a2a:	41 ff d7             	call   *%r15
  8041609a2d:	eb d0                	jmp    80416099ff <timer_cpu_frequency+0x3f>
        }
    }

    return;
}
  8041609a2f:	48 83 c4 08          	add    $0x8,%rsp
  8041609a33:	5b                   	pop    %rbx
  8041609a34:	41 5c                	pop    %r12
  8041609a36:	41 5d                	pop    %r13
  8041609a38:	41 5e                	pop    %r14
  8041609a3a:	41 5f                	pop    %r15
  8041609a3c:	5d                   	pop    %rbp
  8041609a3d:	c3                   	ret    

0000008041609a3e <efi_call_in_32bit_mode>:

extern void _efi_call_in_32bit_mode_asm(uint32_t func, efi_registers *efi_reg, void *stack_contents, size_t stack_contents_size);

/* stack_contents_size is 16-byte multiple */
int
efi_call_in_32bit_mode(uint32_t func, efi_registers *efi_reg, void *stack_contents, size_t stack_contents_size, uint32_t *efi_status) {
  8041609a3e:	f3 0f 1e fa          	endbr64 
  8041609a42:	55                   	push   %rbp
  8041609a43:	48 89 e5             	mov    %rsp,%rbp
  8041609a46:	41 54                	push   %r12
  8041609a48:	53                   	push   %rbx
  8041609a49:	48 89 f3             	mov    %rsi,%rbx

    if (!func || !efi_reg || !stack_contents || (stack_contents_size & 15)) return -E_INVAL;
  8041609a4c:	85 ff                	test   %edi,%edi
  8041609a4e:	0f 94 c0             	sete   %al
  8041609a51:	48 85 f6             	test   %rsi,%rsi
  8041609a54:	40 0f 94 c6          	sete   %sil
  8041609a58:	40 08 f0             	or     %sil,%al
  8041609a5b:	75 44                	jne    8041609aa1 <efi_call_in_32bit_mode+0x63>
  8041609a5d:	4d 89 c4             	mov    %r8,%r12
  8041609a60:	48 85 d2             	test   %rdx,%rdx
  8041609a63:	74 3c                	je     8041609aa1 <efi_call_in_32bit_mode+0x63>
  8041609a65:	f6 c1 0f             	test   $0xf,%cl
  8041609a68:	75 3e                	jne    8041609aa8 <efi_call_in_32bit_mode+0x6a>

    /* We need to set up kernel data segments for 32 bit mode
     * before calling asm. */
    asm volatile("movw %%ax,%%es\n\t"
  8041609a6a:	b8 20 00 00 00       	mov    $0x20,%eax
  8041609a6f:	8e c0                	mov    %eax,%es
  8041609a71:	8e d8                	mov    %eax,%ds
  8041609a73:	8e d0                	mov    %eax,%ss
                 "movw %%ax,%%ds\n\t"
                 "movw %%ax,%%ss" ::"a"(GD_KD32));

    _efi_call_in_32bit_mode_asm(func, efi_reg, stack_contents, stack_contents_size);
  8041609a75:	48 89 de             	mov    %rbx,%rsi
  8041609a78:	48 b8 b0 9a 60 41 80 	movabs $0x8041609ab0,%rax
  8041609a7f:	00 00 00 
  8041609a82:	ff d0                	call   *%rax

    /* Restore 64 bit kernel data segments */
    asm volatile("movw %%ax,%%es\n\t"
  8041609a84:	b8 10 00 00 00       	mov    $0x10,%eax
  8041609a89:	8e c0                	mov    %eax,%es
  8041609a8b:	8e d8                	mov    %eax,%ds
  8041609a8d:	8e d0                	mov    %eax,%ss
                 "movw %%ax,%%ds\n\t"
                 "movw %%ax,%%ss" ::"a"(GD_KD));

    *efi_status = (uint32_t)efi_reg->rax;
  8041609a8f:	48 8b 43 20          	mov    0x20(%rbx),%rax
  8041609a93:	41 89 04 24          	mov    %eax,(%r12)

    return 0;
  8041609a97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041609a9c:	5b                   	pop    %rbx
  8041609a9d:	41 5c                	pop    %r12
  8041609a9f:	5d                   	pop    %rbp
  8041609aa0:	c3                   	ret    
    if (!func || !efi_reg || !stack_contents || (stack_contents_size & 15)) return -E_INVAL;
  8041609aa1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8041609aa6:	eb f4                	jmp    8041609a9c <efi_call_in_32bit_mode+0x5e>
  8041609aa8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8041609aad:	eb ed                	jmp    8041609a9c <efi_call_in_32bit_mode+0x5e>
  8041609aaf:	90                   	nop

0000008041609ab0 <_efi_call_in_32bit_mode_asm>:
.align 2

.globl _efi_call_in_32bit_mode_asm
.type _efi_call_in_32bit_mode_asm, @function;
_efi_call_in_32bit_mode_asm:
    pushq %rbp
  8041609ab0:	55                   	push   %rbp
    movq %rsp, %rbp
  8041609ab1:	48 89 e5             	mov    %rsp,%rbp
    # Save non-volatile registers
    push %rbx
  8041609ab4:	53                   	push   %rbx
    push %r12
  8041609ab5:	41 54                	push   %r12
    push %r13
  8041609ab7:	41 55                	push   %r13
    push %r14
  8041609ab9:	41 56                	push   %r14
    push %r15
  8041609abb:	41 57                	push   %r15

    # save parameters that we will need later
    push %rsi
  8041609abd:	56                   	push   %rsi
    push %rcx
  8041609abe:	51                   	push   %rcx
    # Save %rbp and align to 16-byte boundary
    # efi_reg in %rsi
    # stack_contents into %rdx
    # s_c_s into %rcx
    # s_c_s into %rcx
    push %rbp
  8041609abf:	55                   	push   %rbp

    # Make room for stack contents
    sub %rcx, %rsp
  8041609ac0:	48 29 cc             	sub    %rcx,%rsp

    COPY_STACK(%rdx, %rcx, %r8)
  8041609ac3:	49 c7 c0 00 00 00 00 	mov    $0x0,%r8

0000008041609aca <copyloop>:
  8041609aca:	4a 8b 04 02          	mov    (%rdx,%r8,1),%rax
  8041609ace:	4a 89 04 04          	mov    %rax,(%rsp,%r8,1)
  8041609ad2:	49 83 c0 08          	add    $0x8,%r8
  8041609ad6:	49 39 c8             	cmp    %rcx,%r8
  8041609ad9:	75 ef                	jne    8041609aca <copyloop>

    # Here in long-mode, with high kernel addresses,
    # but with the kernel double-mapped in the bottom 4GB.
    # We now switch to compat mode and call into EFI.
    ENTER_COMPAT_MODE()
  8041609adb:	e8 00 00 00 00       	call   8041609ae0 <copyloop+0x16>
  8041609ae0:	48 81 04 24 11 00 00 	addq   $0x11,(%rsp)
  8041609ae7:	00 
  8041609ae8:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%rsp)
  8041609aef:	00 
  8041609af0:	cb                   	lret   

    # call EFI runtime
    call *%edi
  8041609af1:	ff d7                	call   *%rdi

    ENTER_64BIT_MODE()
  8041609af3:	6a 08                	push   $0x8
  8041609af5:	e8 00 00 00 00       	call   8041609afa <copyloop+0x30>
  8041609afa:	81 04 24 08 00 00 00 	addl   $0x8,(%rsp)
  8041609b01:	cb                   	lret   

    # load efi_reg into %esi
    mov -48(%rbp), %rsi
  8041609b02:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
    /* save RAX back */
    mov %rax, 32(%rsi)
  8041609b06:	48 89 46 20          	mov    %rax,0x20(%rsi)

    # load s_c_s into %rcx
    mov -56(%rbp), %rcx
  8041609b0a:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
    # discard stack contents
    add %rcx, %rsp
  8041609b0e:	48 01 cc             	add    %rcx,%rsp
    # restore full 64-bit frame pointer
    # which the 32-bit EFI will have truncated
    # our full %rsp will be restored by EMARF
    pop %rbp
  8041609b11:	5d                   	pop    %rbp

    pop %rcx
  8041609b12:	59                   	pop    %rcx
    pop %rsi
  8041609b13:	5e                   	pop    %rsi
    pop %r15
  8041609b14:	41 5f                	pop    %r15
    pop %r14
  8041609b16:	41 5e                	pop    %r14
    pop %r13
  8041609b18:	41 5d                	pop    %r13
    pop %r12
  8041609b1a:	41 5c                	pop    %r12
    pop %rbx
  8041609b1c:	5b                   	pop    %rbx

    leave
  8041609b1d:	c9                   	leave  
    ret
  8041609b1e:	c3                   	ret    

0000008041609b1f <__spin_initlock>:
    return lock->locked;
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name) {
  8041609b1f:	f3 0f 1e fa          	endbr64 
    lk->locked = 0;
  8041609b23:	c7 07 00 00 00 00    	movl   $0x0,(%rdi)
#if trace_spinlock
    lk->name = name;
#endif
}
  8041609b29:	c3                   	ret    

0000008041609b2a <spin_lock>:
/* Acquire the lock.
 * Loops (spins) until the lock is acquired.
 * Holding a lock for a long time may cause
 * other CPUs to waste time spinning to acquire it. */
void
spin_lock(struct spinlock *lk) {
  8041609b2a:	f3 0f 1e fa          	endbr64 
    uint32_t result = __atomic_exchange_n(addr, newval, __ATOMIC_ACQ_REL);
  8041609b2e:	ba 01 00 00 00       	mov    $0x1,%edx
#endif

    /* The xchg is atomic.
     * It also serializes, so that reads after acquire are not
     * reordered before it. */
    while (xchg(&lk->locked, 1)) asm volatile("pause");
  8041609b33:	eb 02                	jmp    8041609b37 <spin_lock+0xd>
  8041609b35:	f3 90                	pause  
  8041609b37:	89 d0                	mov    %edx,%eax
  8041609b39:	87 07                	xchg   %eax,(%rdi)
  8041609b3b:	85 c0                	test   %eax,%eax
  8041609b3d:	75 f6                	jne    8041609b35 <spin_lock+0xb>

        /* Record info about lock acquisition for debugging. */
#if trace_spinlock
    get_caller_pcs(lk->pcs);
#endif
}
  8041609b3f:	c3                   	ret    

0000008041609b40 <spin_unlock>:

/* Release the lock. */
void
spin_unlock(struct spinlock *lk) {
  8041609b40:	f3 0f 1e fa          	endbr64 
  8041609b44:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609b49:	87 07                	xchg   %eax,(%rdi)
     * Paper says that Intel 64 and IA-32 will not move a load
     * after a store. So lock->locked = 0 would work here.
     * The xchg being asm volatile ensures gcc emits it after
     * the above assignments (and after the critical section). */
    xchg(&lk->locked, 0);
}
  8041609b4b:	c3                   	ret    

0000008041609b4c <drv_e1000_read_eeprom_word>:
    }
    return result;
}

static uint16_t
drv_e1000_read_eeprom_word(struct e1000_data* e1000_data, uint8_t offset) {
  8041609b4c:	f3 0f 1e fa          	endbr64 
  8041609b50:	48 89 f9             	mov    %rdi,%rcx
    // e1000.pdf::96
    // e1000.pdf::248

    drv_e1000_cmd_send(e1000_data, EEPROM_REG_OFFSET, 1 | (((uint32_t)(offset)) << 8));
  8041609b53:	40 0f b6 c6          	movzbl %sil,%eax
  8041609b57:	c1 e0 08             	shl    $0x8,%eax
  8041609b5a:	83 c8 01             	or     $0x1,%eax
  8041609b5d:	89 c6                	mov    %eax,%esi
    if (e1000_data->reg_access_type == E1000_REG_ACCESS_TYPE_IO_PORTS) {
  8041609b5f:	83 7f 04 00          	cmpl   $0x0,0x4(%rdi)
  8041609b63:	74 19                	je     8041609b7e <drv_e1000_read_eeprom_word+0x32>
    asm volatile("outl %0,%w1" ::"a"(data), "d"(port));
  8041609b65:	8b 57 10             	mov    0x10(%rdi),%edx
  8041609b68:	b8 14 00 00 00       	mov    $0x14,%eax
  8041609b6d:	ef                   	out    %eax,(%dx)
  8041609b6e:	8b 57 14             	mov    0x14(%rdi),%edx
  8041609b71:	89 f0                	mov    %esi,%eax
  8041609b73:	ef                   	out    %eax,(%dx)
    if (e1000_data->reg_access_type == E1000_REG_ACCESS_TYPE_IO_PORTS) {
  8041609b74:	8b 71 04             	mov    0x4(%rcx),%esi
    asm volatile("outw %0,%w1" ::"a"(data), "d"(port));
  8041609b77:	bf 14 00 00 00       	mov    $0x14,%edi
  8041609b7c:	eb 18                	jmp    8041609b96 <drv_e1000_read_eeprom_word+0x4a>
        mmio_write32(e1000_data->mmio_base_address + address, value);
  8041609b7e:	48 8b 47 08          	mov    0x8(%rdi),%rax
    *value_ptr = value;
  8041609b82:	89 70 14             	mov    %esi,0x14(%rax)
}
  8041609b85:	eb ed                	jmp    8041609b74 <drv_e1000_read_eeprom_word+0x28>
  8041609b87:	8b 51 10             	mov    0x10(%rcx),%edx
  8041609b8a:	89 f8                	mov    %edi,%eax
  8041609b8c:	66 ef                	out    %ax,(%dx)
    asm volatile("inl %w1,%0"
  8041609b8e:	8b 51 14             	mov    0x14(%rcx),%edx
  8041609b91:	ed                   	in     (%dx),%eax

    uint32_t reg_val = 0;

    while(!(reg_val = drv_e1000_cmd_recv_result(e1000_data, EEPROM_REG_OFFSET) & (1 << 4))){
  8041609b92:	a8 10                	test   $0x10,%al
  8041609b94:	75 0d                	jne    8041609ba3 <drv_e1000_read_eeprom_word+0x57>
    if (e1000_data->reg_access_type == E1000_REG_ACCESS_TYPE_IO_PORTS) {
  8041609b96:	85 f6                	test   %esi,%esi
  8041609b98:	75 ed                	jne    8041609b87 <drv_e1000_read_eeprom_word+0x3b>
        result = mmio_read32(e1000_data->mmio_base_address + address);
  8041609b9a:	48 8b 41 08          	mov    0x8(%rcx),%rax
    uint32_t value = *value_ptr;
  8041609b9e:	8b 40 14             	mov    0x14(%rax),%eax
    return value;
  8041609ba1:	eb ef                	jmp    8041609b92 <drv_e1000_read_eeprom_word+0x46>
        ; // waiting why reading completes
    }
    
    return (reg_val >> 16) & 0xFFFF;
}
  8041609ba3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609ba8:	c3                   	ret    

0000008041609ba9 <pci_device_read_word>:
pci_device_read_word(uint8_t bus, uint8_t slot, uint8_t func, uint8_t offset) {
  8041609ba9:	f3 0f 1e fa          	endbr64 
    config_address |= ((uint32_t)  bus) << 16;
  8041609bad:	40 0f b6 ff          	movzbl %dil,%edi
  8041609bb1:	c1 e7 10             	shl    $0x10,%edi
    config_address |= offset;
  8041609bb4:	89 c8                	mov    %ecx,%eax
  8041609bb6:	25 fc 00 00 00       	and    $0xfc,%eax
  8041609bbb:	09 c7                	or     %eax,%edi
    config_address |= ((uint32_t) slot) << 11;
  8041609bbd:	40 0f b6 f6          	movzbl %sil,%esi
  8041609bc1:	c1 e6 0b             	shl    $0xb,%esi
    config_address |= offset;
  8041609bc4:	09 f7                	or     %esi,%edi
    config_address |= ((uint32_t) func) <<  8;
  8041609bc6:	0f b6 d2             	movzbl %dl,%edx
  8041609bc9:	c1 e2 08             	shl    $0x8,%edx
    config_address |= offset;
  8041609bcc:	09 d7                	or     %edx,%edi
  8041609bce:	89 f8                	mov    %edi,%eax
  8041609bd0:	0d 00 00 00 80       	or     $0x80000000,%eax
    asm volatile("outl %0,%w1" ::"a"(data), "d"(port));
  8041609bd5:	ba f8 0c 00 00       	mov    $0xcf8,%edx
  8041609bda:	ef                   	out    %eax,(%dx)
    asm volatile("inl %w1,%0"
  8041609bdb:	ba fc 0c 00 00       	mov    $0xcfc,%edx
  8041609be0:	ed                   	in     (%dx),%eax
        return (uint16_t) result;
  8041609be1:	89 c2                	mov    %eax,%edx
  8041609be3:	c1 ea 10             	shr    $0x10,%edx
  8041609be6:	f6 c1 03             	test   $0x3,%cl
  8041609be9:	0f 45 c2             	cmovne %edx,%eax
}
  8041609bec:	c3                   	ret    

0000008041609bed <print_mac>:

    return true;
}

//! mac should be valid
void print_mac(struct e1000_data* e1000_data){
  8041609bed:	f3 0f 1e fa          	endbr64 
  8041609bf1:	55                   	push   %rbp
  8041609bf2:	48 89 e5             	mov    %rsp,%rbp
  8041609bf5:	41 56                	push   %r14
  8041609bf7:	41 55                	push   %r13
  8041609bf9:	41 54                	push   %r12
  8041609bfb:	53                   	push   %rbx
  8041609bfc:	49 89 fc             	mov    %rdi,%r12

    cprintf("mac: ");
  8041609bff:	48 bf 61 c0 60 41 80 	movabs $0x804160c061,%rdi
  8041609c06:	00 00 00 
  8041609c09:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609c0e:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  8041609c15:	00 00 00 
  8041609c18:	ff d2                	call   *%rdx
  8041609c1a:	bb 00 00 00 00       	mov    $0x0,%ebx
    for(int n_b = 0; n_b < 5; n_b++){
        cprintf("%x::", (uint8_t)(((e1000_data->mac_addr) >> (8 * n_b)) & 0xFF));
  8041609c1f:	49 be 67 c0 60 41 80 	movabs $0x804160c067,%r14
  8041609c26:	00 00 00 
  8041609c29:	49 bd b7 6f 60 41 80 	movabs $0x8041606fb7,%r13
  8041609c30:	00 00 00 
  8041609c33:	49 8b 74 24 18       	mov    0x18(%r12),%rsi
  8041609c38:	89 d9                	mov    %ebx,%ecx
  8041609c3a:	48 d3 ee             	shr    %cl,%rsi
  8041609c3d:	40 0f b6 f6          	movzbl %sil,%esi
  8041609c41:	4c 89 f7             	mov    %r14,%rdi
  8041609c44:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609c49:	41 ff d5             	call   *%r13
    for(int n_b = 0; n_b < 5; n_b++){
  8041609c4c:	83 c3 08             	add    $0x8,%ebx
  8041609c4f:	83 fb 28             	cmp    $0x28,%ebx
  8041609c52:	75 df                	jne    8041609c33 <print_mac+0x46>
    }
    cprintf("%x\n", (uint8_t)(((e1000_data->mac_addr) >> (8 * 5)) & 0xFF));
  8041609c54:	41 0f b6 74 24 1d    	movzbl 0x1d(%r12),%esi
  8041609c5a:	48 bf 6c c0 60 41 80 	movabs $0x804160c06c,%rdi
  8041609c61:	00 00 00 
  8041609c64:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609c69:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  8041609c70:	00 00 00 
  8041609c73:	ff d2                	call   *%rdx

    return;
}
  8041609c75:	5b                   	pop    %rbx
  8041609c76:	41 5c                	pop    %r12
  8041609c78:	41 5d                	pop    %r13
  8041609c7a:	41 5e                	pop    %r14
  8041609c7c:	5d                   	pop    %rbp
  8041609c7d:	c3                   	ret    

0000008041609c7e <net_init>:

    return 0;
}

void
net_init() {
  8041609c7e:	f3 0f 1e fa          	endbr64 
  8041609c82:	55                   	push   %rbp
  8041609c83:	48 89 e5             	mov    %rsp,%rbp
  8041609c86:	41 57                	push   %r15
  8041609c88:	41 56                	push   %r14
  8041609c8a:	41 55                	push   %r13
  8041609c8c:	41 54                	push   %r12
  8041609c8e:	53                   	push   %rbx
  8041609c8f:	48 83 ec 48          	sub    $0x48,%rsp
    struct e1000_data e1000_data = {};
  8041609c93:	48 c7 45 b0 00 00 00 	movq   $0x0,-0x50(%rbp)
  8041609c9a:	00 
  8041609c9b:	48 c7 45 b8 00 00 00 	movq   $0x0,-0x48(%rbp)
  8041609ca2:	00 
  8041609ca3:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041609caa:	00 
  8041609cab:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041609cb2:	00 
  8041609cb3:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    return pci_device_read_word(bus, slot, function, PCI_CONFIG_SPACE_VENDOR_ID_OFFSET);
  8041609cb9:	49 be a9 9b 60 41 80 	movabs $0x8041609ba9,%r14
  8041609cc0:	00 00 00 
net_init() {
  8041609cc3:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  8041609cc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041609cce:	eb 0c                	jmp    8041609cdc <net_init+0x5e>
            for (uint8_t cur_function = 0; cur_function < 8; ++cur_function) {
  8041609cd0:	83 c3 01             	add    $0x1,%ebx
  8041609cd3:	83 fb 08             	cmp    $0x8,%ebx
  8041609cd6:	0f 84 ed 01 00 00    	je     8041609ec9 <net_init+0x24b>
  8041609cdc:	88 5d a8             	mov    %bl,-0x58(%rbp)
                uint16_t dev_vendor_id = pci_read_vendor_id(cur_bus, cur_slot, cur_function);
  8041609cdf:	44 88 6d a7          	mov    %r13b,-0x59(%rbp)
  8041609ce3:	45 89 e7             	mov    %r12d,%r15d
    return pci_device_read_word(bus, slot, function, PCI_CONFIG_SPACE_VENDOR_ID_OFFSET);
  8041609ce6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041609ceb:	89 da                	mov    %ebx,%edx
  8041609ced:	44 89 ee             	mov    %r13d,%esi
  8041609cf0:	44 89 e7             	mov    %r12d,%edi
  8041609cf3:	41 ff d6             	call   *%r14
                if (dev_vendor_id != target_vendor_id) {
  8041609cf6:	66 3d 86 80          	cmp    $0x8086,%ax
  8041609cfa:	75 d4                	jne    8041609cd0 <net_init+0x52>
    return pci_device_read_word(bus, slot, function, PCI_CONFIG_SPACE_DEVICE_ID_OFFSET);
  8041609cfc:	b9 02 00 00 00       	mov    $0x2,%ecx
  8041609d01:	89 da                	mov    %ebx,%edx
  8041609d03:	44 89 ee             	mov    %r13d,%esi
  8041609d06:	44 89 e7             	mov    %r12d,%edi
  8041609d09:	41 ff d6             	call   *%r14
                if (dev_device_id != target_device_id) {
  8041609d0c:	66 3d 0e 10          	cmp    $0x100e,%ax
  8041609d10:	75 be                	jne    8041609cd0 <net_init+0x52>
            cprintf("Found e1000 of id %02" PRIx16 ":%02" PRIx16 " at pci %02" PRIu8 ":%02" PRIu8 ".%" PRIu8 ".\n", NET_E1000_VENDOR_ID, NET_E1000_DEVICE_IDS[i], bus, slot, function);
  8041609d12:	0f b6 c3             	movzbl %bl,%eax
  8041609d15:	41 0f b6 cd          	movzbl %r13b,%ecx
  8041609d19:	45 0f b6 f4          	movzbl %r12b,%r14d
  8041609d1d:	89 45 a0             	mov    %eax,-0x60(%rbp)
  8041609d20:	41 89 c1             	mov    %eax,%r9d
  8041609d23:	89 4d 9c             	mov    %ecx,-0x64(%rbp)
  8041609d26:	41 89 c8             	mov    %ecx,%r8d
  8041609d29:	44 89 f1             	mov    %r14d,%ecx
  8041609d2c:	ba 0e 10 00 00       	mov    $0x100e,%edx
  8041609d31:	be 86 80 00 00       	mov    $0x8086,%esi
  8041609d36:	48 bf e8 c0 60 41 80 	movabs $0x804160c0e8,%rdi
  8041609d3d:	00 00 00 
  8041609d40:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609d45:	49 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%r10
  8041609d4c:	00 00 00 
  8041609d4f:	41 ff d2             	call   *%r10
    uint16_t result = pci_device_read_word(bus, slot, func, dword_offset);
  8041609d52:	b9 0e 00 00 00       	mov    $0xe,%ecx
  8041609d57:	8b 55 a0             	mov    -0x60(%rbp),%edx
  8041609d5a:	8b 75 9c             	mov    -0x64(%rbp),%esi
  8041609d5d:	44 89 f7             	mov    %r14d,%edi
  8041609d60:	48 b8 a9 9b 60 41 80 	movabs $0x8041609ba9,%rax
  8041609d67:	00 00 00 
  8041609d6a:	ff d0                	call   *%rax
    if (header_type != PCI_DEVICE_HEADER_TYPE) {
  8041609d6c:	83 e0 7f             	and    $0x7f,%eax
  8041609d6f:	0f 85 78 01 00 00    	jne    8041609eed <net_init+0x26f>
    e1000_data->bus = bus;
  8041609d75:	44 88 7d b0          	mov    %r15b,-0x50(%rbp)
    e1000_data->slot = slot;
  8041609d79:	0f b6 45 a7          	movzbl -0x59(%rbp),%eax
  8041609d7d:	88 45 b1             	mov    %al,-0x4f(%rbp)
    e1000_data->function = function;
  8041609d80:	0f b6 45 a8          	movzbl -0x58(%rbp),%eax
  8041609d84:	88 45 b2             	mov    %al,-0x4e(%rbp)
    bar0 |= pci_device_read_word(bus, slot, function, PCI_CONFIG_SPACE_BAR1_OFFSET);
  8041609d87:	b9 14 00 00 00       	mov    $0x14,%ecx
  8041609d8c:	8b 55 a0             	mov    -0x60(%rbp),%edx
  8041609d8f:	8b 75 9c             	mov    -0x64(%rbp),%esi
  8041609d92:	44 89 f7             	mov    %r14d,%edi
  8041609d95:	49 bf a9 9b 60 41 80 	movabs $0x8041609ba9,%r15
  8041609d9c:	00 00 00 
  8041609d9f:	41 ff d7             	call   *%r15
  8041609da2:	0f b7 c0             	movzwl %ax,%eax
    bar0 <<= 32;
  8041609da5:	48 c1 e0 20          	shl    $0x20,%rax
  8041609da9:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
    bar0 |= pci_device_read_word(bus, slot, function, PCI_CONFIG_SPACE_BAR0_OFFSET);
  8041609dad:	b9 10 00 00 00       	mov    $0x10,%ecx
  8041609db2:	8b 55 a0             	mov    -0x60(%rbp),%edx
  8041609db5:	8b 75 9c             	mov    -0x64(%rbp),%esi
  8041609db8:	44 89 f7             	mov    %r14d,%edi
  8041609dbb:	41 ff d7             	call   *%r15
  8041609dbe:	0f b7 c0             	movzwl %ax,%eax
  8041609dc1:	4c 8b 75 a8          	mov    -0x58(%rbp),%r14
  8041609dc5:	49 09 c6             	or     %rax,%r14
    if (register_access_is_ports) {
  8041609dc8:	4c 89 f0             	mov    %r14,%rax
  8041609dcb:	48 83 f0 01          	xor    $0x1,%rax
  8041609dcf:	83 e0 01             	and    $0x1,%eax
  8041609dd2:	89 45 b4             	mov    %eax,-0x4c(%rbp)
    if (!address_space_size_is_64bit) {
  8041609dd5:	41 f6 c6 02          	test   $0x2,%r14b
  8041609dd9:	0f 84 2e 01 00 00    	je     8041609f0d <net_init+0x28f>
    bar0 &= ~((uint64_t) 0x2);
  8041609ddf:	4c 89 f0             	mov    %r14,%rax
  8041609de2:	48 83 e0 fc          	and    $0xfffffffffffffffc,%rax
    e1000_data->mmio_base_address = mmio_base_address;
  8041609de6:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    config_address |= ((uint32_t)  bus) << 16;
  8041609dea:	41 0f b6 c4          	movzbl %r12b,%eax
  8041609dee:	c1 e0 10             	shl    $0x10,%eax
    config_address |= ((uint32_t) func) <<  8;
  8041609df1:	0f b6 db             	movzbl %bl,%ebx
  8041609df4:	c1 e3 08             	shl    $0x8,%ebx
    config_address |= offset;
  8041609df7:	09 d8                	or     %ebx,%eax
    config_address |= ((uint32_t) slot) << 11;
  8041609df9:	45 0f b6 ed          	movzbl %r13b,%r13d
  8041609dfd:	41 c1 e5 0b          	shl    $0xb,%r13d
    config_address |= offset;
  8041609e01:	44 09 e8             	or     %r13d,%eax
  8041609e04:	0d 20 00 00 80       	or     $0x80000020,%eax
    asm volatile("outl %0,%w1" ::"a"(data), "d"(port));
  8041609e09:	ba f8 0c 00 00       	mov    $0xcf8,%edx
  8041609e0e:	ef                   	out    %eax,(%dx)
    asm volatile("inl %w1,%0"
  8041609e0f:	ba fc 0c 00 00       	mov    $0xcfc,%edx
  8041609e14:	ed                   	in     (%dx),%eax
    uint32_t ioport_for_addr  = bar4 & ~((uint32_t) 0x7); // Unset the lowest 3 bits, although 2 of them are zeros by the docs.
  8041609e15:	83 e0 f8             	and    $0xfffffff8,%eax
    e1000_data->ioport_for_addr = ioport_for_addr;
  8041609e18:	89 45 c0             	mov    %eax,-0x40(%rbp)
    uint32_t ioport_for_data = ioport_for_addr + 4;
  8041609e1b:	83 c0 04             	add    $0x4,%eax
  8041609e1e:	89 45 c4             	mov    %eax,-0x3c(%rbp)
    tmp = drv_e1000_read_eeprom_word(e1000_data, 0);
  8041609e21:	be 00 00 00 00       	mov    $0x0,%esi
  8041609e26:	48 8d 7d b0          	lea    -0x50(%rbp),%rdi
  8041609e2a:	48 bb 4c 9b 60 41 80 	movabs $0x8041609b4c,%rbx
  8041609e31:	00 00 00 
  8041609e34:	ff d3                	call   *%rbx
    e1000_data->mac_addr |= (tmp >> 8) & 0xFF;
  8041609e36:	89 c2                	mov    %eax,%edx
  8041609e38:	66 c1 ea 08          	shr    $0x8,%dx
  8041609e3c:	0f b7 d2             	movzwl %dx,%edx
  8041609e3f:	48 0b 55 c8          	or     -0x38(%rbp),%rdx
    e1000_data->mac_addr |= (tmp & 0xFF) << 8;
  8041609e43:	48 c1 e0 08          	shl    $0x8,%rax
  8041609e47:	25 00 ff 00 00       	and    $0xff00,%eax
  8041609e4c:	48 09 d0             	or     %rdx,%rax
  8041609e4f:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    tmp = drv_e1000_read_eeprom_word(e1000_data, 1);
  8041609e53:	be 01 00 00 00       	mov    $0x1,%esi
  8041609e58:	48 8d 7d b0          	lea    -0x50(%rbp),%rdi
  8041609e5c:	ff d3                	call   *%rbx
  8041609e5e:	0f b7 c0             	movzwl %ax,%eax
    e1000_data->mac_addr |= ((tmp >> 8) & 0xFF) << 16;
  8041609e61:	48 89 c2             	mov    %rax,%rdx
  8041609e64:	48 c1 ea 08          	shr    $0x8,%rdx
  8041609e68:	48 c1 e2 10          	shl    $0x10,%rdx
    e1000_data->mac_addr |= (tmp & 0xFF) << 24;
  8041609e6c:	48 c1 e0 18          	shl    $0x18,%rax
  8041609e70:	89 c0                	mov    %eax,%eax
  8041609e72:	48 09 d0             	or     %rdx,%rax
  8041609e75:	48 09 45 c8          	or     %rax,-0x38(%rbp)
    tmp = drv_e1000_read_eeprom_word(e1000_data, 2);
  8041609e79:	be 02 00 00 00       	mov    $0x2,%esi
  8041609e7e:	48 8d 7d b0          	lea    -0x50(%rbp),%rdi
  8041609e82:	ff d3                	call   *%rbx
  8041609e84:	0f b7 c0             	movzwl %ax,%eax
    e1000_data->mac_addr |= ((tmp >> 8) & 0xFF) << 32;
  8041609e87:	48 89 c2             	mov    %rax,%rdx
  8041609e8a:	48 c1 ea 08          	shr    $0x8,%rdx
  8041609e8e:	48 c1 e2 20          	shl    $0x20,%rdx
    e1000_data->mac_addr |= (tmp & 0xFF) << 36;
  8041609e92:	48 c1 e0 24          	shl    $0x24,%rax
  8041609e96:	48 b9 00 00 00 00 f0 	movabs $0xff000000000,%rcx
  8041609e9d:	0f 00 00 
  8041609ea0:	48 21 c8             	and    %rcx,%rax
  8041609ea3:	48 09 d0             	or     %rdx,%rax
  8041609ea6:	48 09 45 c8          	or     %rax,-0x38(%rbp)
    print_mac(&e1000_data);
  8041609eaa:	48 8d 7d b0          	lea    -0x50(%rbp),%rdi
  8041609eae:	48 b8 ed 9b 60 41 80 	movabs $0x8041609bed,%rax
  8041609eb5:	00 00 00 
  8041609eb8:	ff d0                	call   *%rax
    drv_e1000_init();
}
  8041609eba:	48 83 c4 48          	add    $0x48,%rsp
  8041609ebe:	5b                   	pop    %rbx
  8041609ebf:	41 5c                	pop    %r12
  8041609ec1:	41 5d                	pop    %r13
  8041609ec3:	41 5e                	pop    %r14
  8041609ec5:	41 5f                	pop    %r15
  8041609ec7:	5d                   	pop    %rbp
  8041609ec8:	c3                   	ret    
        for (uint16_t cur_slot = 0; cur_slot < UINT8_MAX; ++cur_slot) {
  8041609ec9:	41 83 c5 01          	add    $0x1,%r13d
  8041609ecd:	41 81 fd ff 00 00 00 	cmp    $0xff,%r13d
  8041609ed4:	0f 85 ef fd ff ff    	jne    8041609cc9 <net_init+0x4b>
    for (uint16_t cur_bus = 0; cur_bus < UINT8_MAX; ++cur_bus) {
  8041609eda:	41 83 c4 01          	add    $0x1,%r12d
  8041609ede:	41 81 fc ff 00 00 00 	cmp    $0xff,%r12d
  8041609ee5:	0f 85 d8 fd ff ff    	jne    8041609cc3 <net_init+0x45>
  8041609eeb:	eb cd                	jmp    8041609eba <net_init+0x23c>
        cprintf("The E1000 header type is invalid (not a device header, has header type %" PRIx8 ".\n", header_type);
  8041609eed:	0f b6 f0             	movzbl %al,%esi
  8041609ef0:	48 bf 70 c0 60 41 80 	movabs $0x804160c070,%rdi
  8041609ef7:	00 00 00 
  8041609efa:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609eff:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  8041609f06:	00 00 00 
  8041609f09:	ff d2                	call   *%rdx
        return false;
  8041609f0b:	eb ad                	jmp    8041609eba <net_init+0x23c>
        cprintf("E1000 requests 32-bit addressing.\n");
  8041609f0d:	48 bf c0 c0 60 41 80 	movabs $0x804160c0c0,%rdi
  8041609f14:	00 00 00 
  8041609f17:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609f1c:	48 ba b7 6f 60 41 80 	movabs $0x8041606fb7,%rdx
  8041609f23:	00 00 00 
  8041609f26:	ff d2                	call   *%rdx
        bar0 &= ~((uint32_t) 0); // Unset the higher 32 bits.
  8041609f28:	4c 89 f0             	mov    %r14,%rax
  8041609f2b:	83 e0 fc             	and    $0xfffffffc,%eax
  8041609f2e:	e9 b3 fe ff ff       	jmp    8041609de6 <net_init+0x168>

0000008041609f33 <test_alloc>:
    asm volatile("sti");
}

/* malloc: general-purpose storage allocator */
void *
test_alloc(uint8_t nbytes) {
  8041609f33:	f3 0f 1e fa          	endbr64 
  8041609f37:	55                   	push   %rbp
  8041609f38:	48 89 e5             	mov    %rsp,%rbp

extern struct spinlock kernel_lock;

static inline void
lock_kernel(void) {
    spin_lock(&kernel_lock);
  8041609f3b:	48 bf 1c 5a e4 41 80 	movabs $0x8041e45a1c,%rdi
  8041609f42:	00 00 00 
  8041609f45:	48 b8 2a 9b 60 41 80 	movabs $0x8041609b2a,%rax
  8041609f4c:	00 00 00 
  8041609f4f:	ff d0                	call   *%rax
    
    size_t nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;

    lock_kernel();

    assert(0);
  8041609f51:	48 b9 d8 ab 60 41 80 	movabs $0x804160abd8,%rcx
  8041609f58:	00 00 00 
  8041609f5b:	48 ba 76 a4 60 41 80 	movabs $0x804160a476,%rdx
  8041609f62:	00 00 00 
  8041609f65:	be 25 00 00 00       	mov    $0x25,%esi
  8041609f6a:	48 bf 1a c1 60 41 80 	movabs $0x804160c11a,%rdi
  8041609f71:	00 00 00 
  8041609f74:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609f79:	49 b8 e3 03 60 41 80 	movabs $0x80416003e3,%r8
  8041609f80:	00 00 00 
  8041609f83:	41 ff d0             	call   *%r8

0000008041609f86 <test_free>:
    }
}

/* free: put block ap in free list */
void
test_free(void *ap) {
  8041609f86:	f3 0f 1e fa          	endbr64 
  8041609f8a:	55                   	push   %rbp
  8041609f8b:	48 89 e5             	mov    %rsp,%rbp
  8041609f8e:	41 54                	push   %r12
  8041609f90:	53                   	push   %rbx
  8041609f91:	49 89 fc             	mov    %rdi,%r12

    /* point to block header */
    Header *bp = (Header *)ap - 1;
  8041609f94:	48 8d 5f e0          	lea    -0x20(%rdi),%rbx
  8041609f98:	48 bf 1c 5a e4 41 80 	movabs $0x8041e45a1c,%rdi
  8041609f9f:	00 00 00 
  8041609fa2:	48 b8 2a 9b 60 41 80 	movabs $0x8041609b2a,%rax
  8041609fa9:	00 00 00 
  8041609fac:	ff d0                	call   *%rax
    // LAB 5: Your code here

    lock_kernel();

    /* freed block at start or end of arena */
    Header *p = freep;
  8041609fae:	48 a1 20 5a e4 41 80 	movabs 0x8041e45a20,%rax
  8041609fb5:	00 00 00 
    for (; !(bp > p && bp < p->next); p = p->next)
  8041609fb8:	eb 10                	jmp    8041609fca <test_free+0x44>
        if (p >= p->next && (bp > p || bp < p->next)) break;
  8041609fba:	48 8b 10             	mov    (%rax),%rdx
  8041609fbd:	48 39 c2             	cmp    %rax,%rdx
  8041609fc0:	77 05                	ja     8041609fc7 <test_free+0x41>
  8041609fc2:	48 39 da             	cmp    %rbx,%rdx
  8041609fc5:	77 15                	ja     8041609fdc <test_free+0x56>
test_free(void *ap) {
  8041609fc7:	48 89 d0             	mov    %rdx,%rax
    for (; !(bp > p && bp < p->next); p = p->next)
  8041609fca:	48 39 d8             	cmp    %rbx,%rax
  8041609fcd:	73 eb                	jae    8041609fba <test_free+0x34>
  8041609fcf:	48 8b 10             	mov    (%rax),%rdx
  8041609fd2:	48 39 da             	cmp    %rbx,%rdx
  8041609fd5:	77 05                	ja     8041609fdc <test_free+0x56>
        if (p >= p->next && (bp > p || bp < p->next)) break;
  8041609fd7:	48 39 c2             	cmp    %rax,%rdx
  8041609fda:	77 eb                	ja     8041609fc7 <test_free+0x41>

    if (bp + bp->size == p->next && p + p->size == bp) /* join to both */ {
  8041609fdc:	49 8b 4c 24 f0       	mov    -0x10(%r12),%rcx
  8041609fe1:	48 8b 30             	mov    (%rax),%rsi
  8041609fe4:	48 89 ca             	mov    %rcx,%rdx
  8041609fe7:	48 c1 e2 05          	shl    $0x5,%rdx
  8041609feb:	48 01 da             	add    %rbx,%rdx
  8041609fee:	48 39 d6             	cmp    %rdx,%rsi
  8041609ff1:	74 4d                	je     804160a040 <test_free+0xba>
        bp->size += p->next->size;
        bp->next = p->next->next;
        bp->prev = p->next->prev;
        p->next->next->prev = bp;
        p->next = bp;
    } else if (p + p->size == bp) /* join to lower nbr */ {
  8041609ff3:	48 8b 78 10          	mov    0x10(%rax),%rdi
  8041609ff7:	48 89 fa             	mov    %rdi,%rdx
  8041609ffa:	48 c1 e2 05          	shl    $0x5,%rdx
  8041609ffe:	48 01 c2             	add    %rax,%rdx
  804160a001:	48 39 d3             	cmp    %rdx,%rbx
  804160a004:	0f 84 98 00 00 00    	je     804160a0a2 <test_free+0x11c>
        p->size += bp->size;
    } else {
        bp->next = p->next;
  804160a00a:	49 89 74 24 e0       	mov    %rsi,-0x20(%r12)
        bp->prev = p;
  804160a00f:	49 89 44 24 e8       	mov    %rax,-0x18(%r12)
        p->next->prev = bp;
  804160a014:	48 8b 10             	mov    (%rax),%rdx
  804160a017:	48 89 5a 08          	mov    %rbx,0x8(%rdx)
        p->next = bp;
  804160a01b:	48 89 18             	mov    %rbx,(%rax)
    }
    freep = p;
  804160a01e:	48 ba 20 5a e4 41 80 	movabs $0x8041e45a20,%rdx
  804160a025:	00 00 00 
  804160a028:	48 89 02             	mov    %rax,(%rdx)
    asm volatile("cli");
  804160a02b:	fa                   	cli    
    Header *prevp = freep, *p = prevp->next;
  804160a02c:	48 8b 32             	mov    (%rdx),%rsi
  804160a02f:	48 8b 06             	mov    (%rsi),%rax
    for (; p != freep; p = p->next) {
  804160a032:	48 39 c6             	cmp    %rax,%rsi
  804160a035:	0f 84 87 00 00 00    	je     804160a0c2 <test_free+0x13c>
    Header *prevp = freep, *p = prevp->next;
  804160a03b:	48 89 f1             	mov    %rsi,%rcx
  804160a03e:	eb 71                	jmp    804160a0b1 <test_free+0x12b>
    if (bp + bp->size == p->next && p + p->size == bp) /* join to both */ {
  804160a040:	48 8b 78 10          	mov    0x10(%rax),%rdi
  804160a044:	48 89 fa             	mov    %rdi,%rdx
  804160a047:	48 c1 e2 05          	shl    $0x5,%rdx
  804160a04b:	48 01 c2             	add    %rax,%rdx
  804160a04e:	48 39 d3             	cmp    %rdx,%rbx
  804160a051:	74 2f                	je     804160a082 <test_free+0xfc>
        bp->size += p->next->size;
  804160a053:	48 03 4e 10          	add    0x10(%rsi),%rcx
  804160a057:	49 89 4c 24 f0       	mov    %rcx,-0x10(%r12)
        bp->next = p->next->next;
  804160a05c:	48 8b 10             	mov    (%rax),%rdx
  804160a05f:	48 8b 12             	mov    (%rdx),%rdx
  804160a062:	49 89 54 24 e0       	mov    %rdx,-0x20(%r12)
        bp->prev = p->next->prev;
  804160a067:	48 8b 10             	mov    (%rax),%rdx
  804160a06a:	48 8b 52 08          	mov    0x8(%rdx),%rdx
  804160a06e:	49 89 54 24 e8       	mov    %rdx,-0x18(%r12)
        p->next->next->prev = bp;
  804160a073:	48 8b 10             	mov    (%rax),%rdx
  804160a076:	48 8b 12             	mov    (%rdx),%rdx
  804160a079:	48 89 5a 08          	mov    %rbx,0x8(%rdx)
        p->next = bp;
  804160a07d:	48 89 18             	mov    %rbx,(%rax)
  804160a080:	eb 9c                	jmp    804160a01e <test_free+0x98>
        p->size += bp->size + p->next->size;
  804160a082:	48 01 f9             	add    %rdi,%rcx
  804160a085:	48 03 4e 10          	add    0x10(%rsi),%rcx
  804160a089:	48 89 48 10          	mov    %rcx,0x10(%rax)
        p->next->next->prev = p;
  804160a08d:	48 8b 16             	mov    (%rsi),%rdx
  804160a090:	48 89 42 08          	mov    %rax,0x8(%rdx)
        p->next = p->next->next;
  804160a094:	48 8b 10             	mov    (%rax),%rdx
  804160a097:	48 8b 12             	mov    (%rdx),%rdx
  804160a09a:	48 89 10             	mov    %rdx,(%rax)
  804160a09d:	e9 7c ff ff ff       	jmp    804160a01e <test_free+0x98>
        p->size += bp->size;
  804160a0a2:	48 01 f9             	add    %rdi,%rcx
  804160a0a5:	48 89 48 10          	mov    %rcx,0x10(%rax)
  804160a0a9:	e9 70 ff ff ff       	jmp    804160a01e <test_free+0x98>
    for (; p != freep; p = p->next) {
  804160a0ae:	48 89 d0             	mov    %rdx,%rax
        if (prevp != p->prev) panic("Corrupted list.\n");
  804160a0b1:	48 39 48 08          	cmp    %rcx,0x8(%rax)
  804160a0b5:	75 29                	jne    804160a0e0 <test_free+0x15a>
    for (; p != freep; p = p->next) {
  804160a0b7:	48 8b 10             	mov    (%rax),%rdx
  804160a0ba:	48 89 c1             	mov    %rax,%rcx
  804160a0bd:	48 39 d6             	cmp    %rdx,%rsi
  804160a0c0:	75 ec                	jne    804160a0ae <test_free+0x128>
    asm volatile("sti");
  804160a0c2:	fb                   	sti    
}

static inline void
unlock_kernel(void) {
    spin_unlock(&kernel_lock);
  804160a0c3:	48 bf 1c 5a e4 41 80 	movabs $0x8041e45a1c,%rdi
  804160a0ca:	00 00 00 
  804160a0cd:	48 b8 40 9b 60 41 80 	movabs $0x8041609b40,%rax
  804160a0d4:	00 00 00 
  804160a0d7:	ff d0                	call   *%rax

    /* Normally we wouldn't need to do this, but QEMU only runs
     * one CPU at a time and has a long time-slice.  Without the
     * pause, this CPU is likely to reacquire the lock before
     * another CPU has even been given a chance to acquire it. */
    asm volatile("pause");
  804160a0d9:	f3 90                	pause  

    check_list();
    unlock_kernel();

    return;
}
  804160a0db:	5b                   	pop    %rbx
  804160a0dc:	41 5c                	pop    %r12
  804160a0de:	5d                   	pop    %rbp
  804160a0df:	c3                   	ret    
        if (prevp != p->prev) panic("Corrupted list.\n");
  804160a0e0:	48 ba 27 c1 60 41 80 	movabs $0x804160c127,%rdx
  804160a0e7:	00 00 00 
  804160a0ea:	be 14 00 00 00       	mov    $0x14,%esi
  804160a0ef:	48 bf 1a c1 60 41 80 	movabs $0x804160c11a,%rdi
  804160a0f6:	00 00 00 
  804160a0f9:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a0fe:	48 b9 e3 03 60 41 80 	movabs $0x80416003e3,%rcx
  804160a105:	00 00 00 
  804160a108:	ff d1                	call   *%rcx
  804160a10a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

000000804160a110 <__rodata_start>:
  804160a110:	49 6e                	rex.WB outsb %ds:(%rsi),(%dx)
  804160a112:	69 74 69 61 6c 69 7a 	imul   $0x657a696c,0x61(%rcx,%rbp,2),%esi
  804160a119:	65 
  804160a11a:	64 20 74 69 6d       	and    %dh,%fs:0x6d(%rcx,%rbp,2)
  804160a11f:	65 72 20             	gs jb  804160a142 <__rodata_start+0x32>
  804160a122:	25 73 0a 00 6b       	and    $0x6b000a73,%eax
  804160a127:	65 72 6e             	gs jb  804160a198 <__rodata_start+0x88>
  804160a12a:	65 6c                	gs insb (%dx),%es:(%rdi)
  804160a12c:	20 70 61             	and    %dh,0x61(%rax)
  804160a12f:	6e                   	outsb  %ds:(%rsi),(%dx)
  804160a130:	69 63 20 61 74 20 25 	imul   $0x25207461,0x20(%rbx),%esp
  804160a137:	73 3a                	jae    804160a173 <__rodata_start+0x63>
  804160a139:	25 64 3a 20 00       	and    $0x203a64,%eax
  804160a13e:	6b 65 72 6e          	imul   $0x6e,0x72(%rbp),%esp
  804160a142:	2f                   	(bad)  
  804160a143:	69 6e 69 74 2e 63 00 	imul   $0x632e74,0x69(%rsi),%ebp
  804160a14a:	54                   	push   %rsp
  804160a14b:	69 6d 65 72 20 25 73 	imul   $0x73252072,0x65(%rbp),%ebp
  804160a152:	20 64 6f 65          	and    %ah,0x65(%rdi,%rbp,2)
  804160a156:	73 20                	jae    804160a178 <__rodata_start+0x68>
  804160a158:	6e                   	outsb  %ds:(%rsi),(%dx)
  804160a159:	6f                   	outsl  %ds:(%rsi),(%dx)
  804160a15a:	74 20                	je     804160a17c <__rodata_start+0x6c>
  804160a15c:	65 78 69             	gs js  804160a1c8 <__rodata_start+0xb8>
  804160a15f:	73 74                	jae    804160a1d5 <__rodata_start+0xc5>
  804160a161:	0a 00                	or     (%rax),%al
  804160a163:	36 38 32             	ss cmp %dh,(%rdx)
  804160a166:	38 20                	cmp    %ah,(%rax)
  804160a168:	64 65 63 69 6d       	fs movsxd %gs:0x6d(%rcx),%ebp
  804160a16d:	61                   	(bad)  
  804160a16e:	6c                   	insb   (%dx),%es:(%rdi)
  804160a16f:	20 69 73             	and    %ch,0x73(%rcx)
  804160a172:	20 25 6f 20 6f 63    	and    %ah,0x636f206f(%rip)        # 80a4cfc1e7 <__bss_end+0x62eb61e7>
  804160a178:	74 61                	je     804160a1db <__rodata_start+0xcb>
  804160a17a:	6c                   	insb   (%dx),%es:(%rdi)
  804160a17b:	21 0a                	and    %ecx,(%rdx)
  804160a17d:	00 45 4e             	add    %al,0x4e(%rbp)
  804160a180:	44 3a 20             	cmp    (%rax),%r12b
  804160a183:	25 70 0a 00 46       	and    $0x46000a70,%eax
  804160a188:	72 61                	jb     804160a1eb <__rodata_start+0xdb>
  804160a18a:	6d                   	insl   (%dx),%es:(%rdi)
  804160a18b:	65 62 75 66 66 65    	(bad)
  804160a191:	72 20                	jb     804160a1b3 <__rodata_start+0xa3>
  804160a193:	69 6e 69 74 69 61 6c 	imul   $0x6c616974,0x69(%rsi),%ebp
  804160a19a:	69 73 65 64 0a 00 68 	imul   $0x68000a64,0x65(%rbx),%esi
  804160a1a1:	70 65                	jo     804160a208 <__rodata_start+0xf8>
  804160a1a3:	74 30                	je     804160a1d5 <__rodata_start+0xc5>
  804160a1a5:	00 6b 65             	add    %ch,0x65(%rbx)
  804160a1a8:	72 6e                	jb     804160a218 <__rodata_start+0x108>
  804160a1aa:	65 6c                	gs insb (%dx),%es:(%rdi)
  804160a1ac:	20 77 61             	and    %dh,0x61(%rdi)
  804160a1af:	72 6e                	jb     804160a21f <__rodata_start+0x10f>
  804160a1b1:	69 6e 67 20 61 74 20 	imul   $0x20746120,0x67(%rsi),%ebp
  804160a1b8:	25 73 3a 25 64       	and    $0x64253a73,%eax
  804160a1bd:	3a 20                	cmp    (%rax),%ah
  804160a1bf:	00 54 69 6d          	add    %dl,0x6d(%rcx,%rbp,2)
  804160a1c3:	65 72 20             	gs jb  804160a1e6 <__rodata_start+0xd6>
  804160a1c6:	25 73 20 64 6f       	and    $0x6f642073,%eax
  804160a1cb:	65 73 20             	gs jae 804160a1ee <__rodata_start+0xde>
  804160a1ce:	6e                   	outsb  %ds:(%rsi),(%dx)
  804160a1cf:	6f                   	outsl  %ds:(%rsi),(%dx)
  804160a1d0:	74 20                	je     804160a1f2 <__rodata_start+0xe2>
  804160a1d2:	73 75                	jae    804160a249 <togglecode+0x9>
  804160a1d4:	70 70                	jo     804160a246 <togglecode+0x6>
  804160a1d6:	6f                   	outsl  %ds:(%rsi),(%dx)
  804160a1d7:	72 74                	jb     804160a24d <togglecode+0xd>
  804160a1d9:	20 69 6e             	and    %ch,0x6e(%rcx)
  804160a1dc:	74 65                	je     804160a243 <togglecode+0x3>
  804160a1de:	72 72                	jb     804160a252 <togglecode+0x12>
  804160a1e0:	75 70                	jne    804160a252 <togglecode+0x12>
  804160a1e2:	74 73                	je     804160a257 <togglecode+0x17>
  804160a1e4:	0a 00                	or     (%rax),%al
  804160a1e6:	52                   	push   %rdx
  804160a1e7:	65 62                	gs (bad) 
  804160a1e9:	6f                   	outsl  %ds:(%rsi),(%dx)
  804160a1ea:	6f                   	outsl  %ds:(%rsi),(%dx)
  804160a1eb:	74 69                	je     804160a256 <togglecode+0x16>
  804160a1ed:	6e                   	outsb  %ds:(%rsi),(%dx)
  804160a1ee:	67 21 0a             	and    %ecx,(%edx)
  804160a1f1:	00 53 65             	add    %dl,0x65(%rbx)
  804160a1f4:	72 69                	jb     804160a25f <togglecode+0x1f>
  804160a1f6:	61                   	(bad)  
  804160a1f7:	6c                   	insb   (%dx),%es:(%rdi)
  804160a1f8:	20 70 6f             	and    %dh,0x6f(%rax)
  804160a1fb:	72 74                	jb     804160a271 <togglecode+0x31>
  804160a1fd:	20 64 6f 65          	and    %ah,0x65(%rdi,%rbp,2)
  804160a201:	73 20                	jae    804160a223 <charcode+0x3>
  804160a203:	6e                   	outsb  %ds:(%rsi),(%dx)
  804160a204:	6f                   	outsl  %ds:(%rsi),(%dx)
  804160a205:	74 20                	je     804160a227 <charcode+0x7>
  804160a207:	65 78 69             	gs js  804160a273 <togglecode+0x33>
  804160a20a:	73 74                	jae    804160a280 <togglecode+0x40>
  804160a20c:	21 0a                	and    %ecx,(%rdx)
  804160a20e:	00 66 2e             	add    %ah,0x2e(%rsi)
  804160a211:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
  804160a218:	00 
  804160a219:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

000000804160a220 <charcode>:
  804160a220:	20 d2 62 41 80 00 00 00 20 d1 62 41 80 00 00 00      .bA.... .bA....
  804160a230:	20 d0 62 41 80 00 00 00 20 d0 62 41 80 00 00 00      .bA.... .bA....

000000804160a240 <togglecode>:
	...
  804160a278:	00 00 08 00 00 00 00 00 00 00 00 00 00 10 20 00     .............. .
	...

000000804160a340 <shiftcode>:
	...
  804160a35c:	00 02 00 00 00 00 00 00 00 00 00 00 00 00 01 00     ................
	...
  804160a374:	00 00 01 00 04 00 00 00 00 00 00 00 00 00 00 00     ................
	...
  804160a3dc:	00 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00     ................
	...
  804160a3f8:	04 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00     ................
	...
  804160a440:	55 6e 6b 6e 6f 77 6e 20 44 57 41 52 46 20 65 78     Unknown DWARF ex
  804160a450:	74 65 6e 73 69 6f 6e 0a 00 76 65 72 73 69 6f 6e     tension..version
  804160a460:	20 3d 3d 20 34 20 7c 7c 20 76 65 72 73 69 6f 6e      == 4 || version
  804160a470:	20 3d 3d 20 32 00 61 73 73 65 72 74 69 6f 6e 20      == 2.assertion 
  804160a480:	66 61 69 6c 65 64 3a 20 25 73 00 6b 65 72 6e 2f     failed: %s.kern/
  804160a490:	64 77 61 72 66 2e 63 00 61 62 62 72 65 76 5f 63     dwarf.c.abbrev_c
  804160a4a0:	6f 64 65 00 74 61 67 20 3d 3d 20 44 57 5f 54 41     ode.tag == DW_TA
  804160a4b0:	47 5f 63 6f 6d 70 69 6c 65 5f 75 6e 69 74 00 90     G_compile_unit..
  804160a4c0:	3f 19 60 41 80 00 00 00 fb 0e 60 41 80 00 00 00     ?.`A......`A....
  804160a4d0:	3f 19 60 41 80 00 00 00 52 0f 60 41 80 00 00 00     ?.`A....R.`A....
  804160a4e0:	ad 0f 60 41 80 00 00 00 01 10 60 41 80 00 00 00     ..`A......`A....
  804160a4f0:	56 10 60 41 80 00 00 00 ab 10 60 41 80 00 00 00     V.`A......`A....
  804160a500:	00 11 60 41 80 00 00 00 3c 11 60 41 80 00 00 00     ..`A....<.`A....
  804160a510:	cd 11 60 41 80 00 00 00 22 12 60 41 80 00 00 00     ..`A....".`A....
  804160a520:	5f 12 60 41 80 00 00 00 9f 12 60 41 80 00 00 00     _.`A......`A....
  804160a530:	46 13 60 41 80 00 00 00 04 14 60 41 80 00 00 00     F.`A......`A....
  804160a540:	93 14 60 41 80 00 00 00 51 15 60 41 80 00 00 00     ..`A....Q.`A....
  804160a550:	8e 15 60 41 80 00 00 00 e3 15 60 41 80 00 00 00     ..`A......`A....
  804160a560:	38 16 60 41 80 00 00 00 8d 16 60 41 80 00 00 00     8.`A......`A....
  804160a570:	1c 17 60 41 80 00 00 00 9d 17 60 41 80 00 00 00     ..`A......`A....
  804160a580:	5b 18 60 41 80 00 00 00 e1 18 60 41 80 00 00 00     [.`A......`A....
  804160a590:	3f 19 60 41 80 00 00 00 3f 19 60 41 80 00 00 00     ?.`A....?.`A....
  804160a5a0:	3f 19 60 41 80 00 00 00 3f 19 60 41 80 00 00 00     ?.`A....?.`A....
  804160a5b0:	3f 19 60 41 80 00 00 00 3f 19 60 41 80 00 00 00     ?.`A....?.`A....
  804160a5c0:	f0 18 60 41 80 00 00 00 61 64 64 72 65 73 73 5f     ..`A....address_
  804160a5d0:	73 69 7a 65 20 3d 3d 20 73 69 7a 65 6f 66 28 75     size == sizeof(u
  804160a5e0:	69 6e 74 70 74 72 5f 74 29 00 00 00 00 00 00 00     intptr_t).......
  804160a5f0:	74 61 62 6c 65 5f 61 62 62 72 65 76 5f 63 6f 64     table_abbrev_cod
  804160a600:	65 20 3d 3d 20 61 62 62 72 65 76 5f 63 6f 64 65     e == abbrev_code
  804160a610:	00 6b 65 72 6e 2f 64 77 61 72 66 5f 6c 69 6e 65     .kern/dwarf_line
  804160a620:	73 2e 63 00 55 6e 6b 6e 6f 77 6e 20 6f 70 63 6f     s.c.Unknown opco
  804160a630:	64 65 3a 20 25 78 00 70 72 6f 67 72 61 6d 5f 61     de: %x.program_a
  804160a640:	64 64 72 20 3d 3d 20 6f 70 63 6f 64 65 5f 65 6e     ddr == opcode_en
  804160a650:	64 00 66 0f 1f 44 00 00 76 65 72 73 69 6f 6e 20     d.f..D..version 
  804160a660:	3d 3d 20 34 20 7c 7c 20 76 65 72 73 69 6f 6e 20     == 4 || version 
  804160a670:	3d 3d 20 33 20 7c 7c 20 76 65 72 73 69 6f 6e 20     == 3 || version 
  804160a680:	3d 3d 20 32 00 00 00 00 6d 69 6e 69 6d 75 6d 5f     == 2....minimum_
  804160a690:	69 6e 73 74 72 75 63 74 69 6f 6e 5f 6c 65 6e 67     instruction_leng
  804160a6a0:	74 68 20 3d 3d 20 31 00 6d 61 78 69 6d 75 6d 5f     th == 1.maximum_
  804160a6b0:	6f 70 65 72 61 74 69 6f 6e 73 5f 70 65 72 5f 69     operations_per_i
  804160a6c0:	6e 73 74 72 75 63 74 69 6f 6e 20 3d 3d 20 31 00     nstruction == 1.
  804160a6d0:	ae 40 60 41 80 00 00 00 82 3e 60 41 80 00 00 00     .@`A.....>`A....
  804160a6e0:	ae 3e 60 41 80 00 00 00 11 3f 60 41 80 00 00 00     .>`A.....?`A....
  804160a6f0:	8d 3f 60 41 80 00 00 00 de 3f 60 41 80 00 00 00     .?`A.....?`A....
  804160a700:	5c 41 60 41 80 00 00 00 5c 41 60 41 80 00 00 00     \A`A....\A`A....
  804160a710:	2f 40 60 41 80 00 00 00 44 40 60 41 80 00 00 00     /@`A....D@`A....
  804160a720:	5c 41 60 41 80 00 00 00 5c 41 60 41 80 00 00 00     \A`A....\A`A....
  804160a730:	60 40 60 41 80 00 00 00 25 73 20 2d 20 25 73 0a     `@`A....%s - %s.
  804160a740:	00 53 70 65 63 69 61 6c 20 6b 65 72 6e 65 6c 20     .Special kernel 
  804160a750:	73 79 6d 62 6f 6c 73 3a 0a 00 25 73 20 00 07 00     symbols:..%s ...
  804160a760:	53 74 61 63 6b 20 62 61 63 6b 74 72 61 63 65 3a     Stack backtrace:
  804160a770:	0a 00 20 20 72 62 70 20 25 30 31 36 6c 78 20 20     ..  rbp %016lx  
  804160a780:	72 69 70 20 25 30 31 36 6c 78 0a 00 20 20 20 20     rip %016lx..    
  804160a790:	25 73 3a 25 64 3a 20 25 73 2b 25 6c 75 0a 00 25     %s:%d: %s+%lu..%
  804160a7a0:	78 3a 20 00 25 78 20 00 74 69 6d 65 72 20 6e 61     x: .%x .timer na
  804160a7b0:	6d 65 20 72 65 71 75 69 72 65 64 0a 00 4b 3e 20     me required..K> 
  804160a7c0:	00 09 0d 0a 20 00 54 6f 6f 20 6d 61 6e 79 20 61     .... .Too many a
  804160a7d0:	72 67 75 6d 65 6e 74 73 20 28 6d 61 78 20 25 64     rguments (max %d
  804160a7e0:	29 0a 00 55 6e 6b 6e 6f 77 6e 20 63 6f 6d 6d 61     )..Unknown comma
  804160a7f0:	6e 64 20 27 25 73 27 0a 00 68 65 6c 70 00 44 69     nd '%s'..help.Di
  804160a800:	73 70 6c 61 79 20 74 68 69 73 20 6c 69 73 74 20     splay this list 
  804160a810:	6f 66 20 63 6f 6d 6d 61 6e 64 73 00 6b 65 72 6e     of commands.kern
  804160a820:	69 6e 66 6f 00 50 72 69 6e 74 20 73 74 61 63 6b     info.Print stack
  804160a830:	20 62 61 63 6b 74 72 61 63 65 00 64 75 6d 70 63      backtrace.dumpc
  804160a840:	6d 6f 73 00 50 72 69 6e 74 20 43 4d 4f 53 20 63     mos.Print CMOS c
  804160a850:	6f 6e 74 65 6e 74 73 00 65 63 68 6f 00 73 68 6f     ontents.echo.sho
  804160a860:	77 73 20 74 65 78 74 00 74 69 6d 65 72 5f 73 74     ws text.timer_st
  804160a870:	61 72 74 00 74 69 6d 65 72 5f 73 74 6f 70 00 74     art.timer_stop.t
  804160a880:	69 6d 65 72 5f 66 72 65 71 00 64 75 6d 70 5f 6d     imer_freq.dump_m
  804160a890:	65 6d 6f 72 79 00 66 90 20 20 5f 68 65 61 64 36     emory.f.  _head6
  804160a8a0:	34 20 25 31 36 6c 78 20 28 76 69 72 74 29 20 20     4 %16lx (virt)  
  804160a8b0:	25 31 36 6c 78 20 28 70 68 79 73 29 0a 00 00 00     %16lx (phys)....
  804160a8c0:	20 20 65 6e 74 72 79 20 20 20 25 31 36 6c 78 20       entry   %16lx 
  804160a8d0:	28 76 69 72 74 29 20 20 25 31 36 6c 78 20 28 70     (virt)  %16lx (p
  804160a8e0:	68 79 73 29 0a 00 00 00 20 20 65 74 65 78 74 20     hys)....  etext 
  804160a8f0:	20 20 25 31 36 6c 78 20 28 76 69 72 74 29 20 20       %16lx (virt)  
  804160a900:	25 31 36 6c 78 20 28 70 68 79 73 29 0a 00 00 00     %16lx (phys)....
  804160a910:	20 20 65 64 61 74 61 20 20 20 25 31 36 6c 78 20       edata   %16lx 
  804160a920:	28 76 69 72 74 29 20 20 25 31 36 6c 78 20 28 70     (virt)  %16lx (p
  804160a930:	68 79 73 29 0a 00 00 00 20 20 65 6e 64 20 20 20     hys)....  end   
  804160a940:	20 20 25 31 36 6c 78 20 28 76 69 72 74 29 20 20       %16lx (virt)  
  804160a950:	25 31 36 6c 78 20 28 70 68 79 73 29 0a 00 00 00     %16lx (phys)....
  804160a960:	4b 65 72 6e 65 6c 20 65 78 65 63 75 74 61 62 6c     Kernel executabl
  804160a970:	65 20 6d 65 6d 6f 72 79 20 66 6f 6f 74 70 72 69     e memory footpri
  804160a980:	6e 74 3a 20 25 6c 75 4b 42 0a 00 00 00 00 00 00     nt: %luKB.......
  804160a990:	57 65 6c 63 6f 6d 65 20 74 6f 20 74 68 65 20 4a     Welcome to the J
  804160a9a0:	4f 53 20 6b 65 72 6e 65 6c 20 6d 6f 6e 69 74 6f     OS kernel monito
  804160a9b0:	72 21 0a 00 00 00 00 00 54 79 70 65 20 27 68 65     r!......Type 'he
  804160a9c0:	6c 70 27 20 66 6f 72 20 61 20 6c 69 73 74 20 6f     lp' for a list o
  804160a9d0:	66 20 63 6f 6d 6d 61 6e 64 73 2e 0a 00 00 00 00     f commands......
  804160a9e0:	44 69 73 70 6c 61 79 20 69 6e 66 6f 72 6d 61 74     Display informat
  804160a9f0:	69 6f 6e 20 61 62 6f 75 74 20 74 68 65 20 6b 65     ion about the ke
  804160aa00:	72 6e 65 6c 00 66 2e 0f 1f 84 00 00 00 00 00 66     rnel.f.........f
  804160aa10:	2e 0f 1f 84 00 00 00 00 00 0f 1f 80 00 00 00 00     ................

000000804160aa20 <commands>:
  804160aa20:	f9 a7 60 41 80 00 00 00 fe a7 60 41 80 00 00 00     ..`A......`A....
  804160aa30:	23 43 60 41 80 00 00 00 1c a8 60 41 80 00 00 00     #C`A......`A....
  804160aa40:	e0 a9 60 41 80 00 00 00 80 43 60 41 80 00 00 00     ..`A.....C`A....
  804160aa50:	31 a8 60 41 80 00 00 00 25 a8 60 41 80 00 00 00     1.`A....%.`A....
  804160aa60:	35 45 60 41 80 00 00 00 3b a8 60 41 80 00 00 00     5E`A....;.`A....
  804160aa70:	44 a8 60 41 80 00 00 00 10 46 60 41 80 00 00 00     D.`A.....F`A....
  804160aa80:	58 a8 60 41 80 00 00 00 5d a8 60 41 80 00 00 00     X.`A....].`A....
  804160aa90:	9a 44 60 41 80 00 00 00 68 a8 60 41 80 00 00 00     .D`A....h.`A....
  804160aaa0:	5f a7 60 41 80 00 00 00 b7 46 60 41 80 00 00 00     _.`A.....F`A....
  804160aab0:	74 a8 60 41 80 00 00 00 5f a7 60 41 80 00 00 00     t.`A...._.`A....
  804160aac0:	f8 46 60 41 80 00 00 00 7f a8 60 41 80 00 00 00     .F`A......`A....
  804160aad0:	5f a7 60 41 80 00 00 00 13 47 60 41 80 00 00 00     _.`A.....G`A....
  804160aae0:	8a a8 60 41 80 00 00 00 5f a7 60 41 80 00 00 00     ..`A...._.`A....
  804160aaf0:	54 47 60 41 80 00 00 00 21 70 2d 3e 72 65 66 63     TG`A....!p->refc
  804160ab00:	00 6b 65 72 6e 2f 70 6d 61 70 2e 63 00 70 61 67     .kern/pmap.c.pag
  804160ab10:	65 2d 3e 63 6c 61 73 73 20 3d 3d 20 4d 41 58 5f     e->class == MAX_
  804160ab20:	43 4c 41 53 53 00 70 61 67 65 20 3d 3d 20 26 72     CLASS.page == &r
  804160ab30:	6f 6f 74 00 6e 20 21 3d 20 26 70 61 67 65 2d 3e     oot.n != &page->
  804160ab40:	68 65 61 64 00 76 2d 3e 70 68 79 20 3d 3d 20 70     head.v->phy == p
  804160ab50:	61 67 65 00 70 61 67 65 2d 3e 6c 65 66 74 2d 3e     age.page->left->
  804160ab60:	70 61 72 65 6e 74 20 3d 3d 20 70 61 67 65 00 70     parent == page.p
  804160ab70:	61 67 65 2d 3e 72 69 67 68 74 2d 3e 70 61 72 65     age->right->pare
  804160ab80:	6e 74 20 3d 3d 20 70 61 67 65 00 21 61 6c 6c 6f     nt == page.!allo
  804160ab90:	63 61 74 69 6e 67 5f 70 6f 6f 6c 00 21 6e 65 77     cating_pool.!new
  804160aba0:	2d 3e 72 65 66 63 00 66 72 65 65 5f 64 65 73 63     ->refc.free_desc
  804160abb0:	5f 63 6f 75 6e 74 20 3e 3d 20 63 6f 75 6e 74 00     _count >= count.
  804160abc0:	4f 75 74 20 6f 66 20 6d 65 6d 6f 72 79 0a 00 63     Out of memory..c
  804160abd0:	6c 61 73 73 20 3e 3d 20 30 00 21 28 61 64 64 72     lass >= 0.!(addr
  804160abe0:	20 26 20 43 4c 41 53 53 5f 4d 41 53 4b 28 63 6c      & CLASS_MASK(cl
  804160abf0:	61 73 73 29 29 00 6e 6f 64 65 00 21 6e 6f 64 65     ass)).node.!node
  804160ac00:	2d 3e 72 65 66 63 00 43 6c 61 73 73 5b 25 64 5d     ->refc.Class[%d]
  804160ac10:	20 73 69 7a 65 28 25 30 6c 6c 78 29 20 7b 00 0a      size(%0llx) {..
  804160ac20:	20 20 20 20 00 30 78 25 30 38 7a 78 20 00 0a 7d         .0x%08zx ..}
  804160ac30:	0a 00 50 61 67 65 20 74 61 62 6c 65 3a 0a 00 7a     ..Page table:..z
  804160ac40:	65 72 6f 5f 70 61 67 65 20 26 26 20 6f 6e 65 5f     ero_page && one_
  804160ac50:	70 61 67 65 00 0f 1f 00 28 28 70 61 67 65 29 2d     page....((page)-
  804160ac60:	3e 73 74 61 74 65 20 26 20 4e 4f 44 45 5f 54 59     >state & NODE_TY
  804160ac70:	50 45 5f 4d 41 53 4b 29 20 3e 3d 20 50 41 52 54     PE_MASK) >= PART
  804160ac80:	49 41 4c 5f 4e 4f 44 45 00 00 00 00 00 00 00 00     IAL_NODE........
  804160ac90:	21 28 70 61 67 65 32 70 61 28 70 61 67 65 29 20     !(page2pa(page) 
  804160aca0:	26 20 43 4c 41 53 53 5f 4d 41 53 4b 28 70 61 67     & CLASS_MASK(pag
  804160acb0:	65 2d 3e 63 6c 61 73 73 29 29 00 00 00 00 00 00     e->class))......
  804160acc0:	70 61 67 65 2d 3e 6c 65 66 74 2d 3e 73 74 61 74     page->left->stat
  804160acd0:	65 20 3d 3d 20 70 61 67 65 2d 3e 73 74 61 74 65     e == page->state
	...
  804160ace8:	70 61 67 65 2d 3e 72 69 67 68 74 2d 3e 73 74 61     page->right->sta
  804160acf8:	74 65 20 3d 3d 20 70 61 67 65 2d 3e 73 74 61 74     te == page->stat
  804160ad08:	65 00 00 00 00 00 00 00 70 61 67 65 2d 3e 6c 65     e.......page->le
  804160ad18:	66 74 2d 3e 63 6c 61 73 73 20 2b 20 31 20 3d 3d     ft->class + 1 ==
  804160ad28:	20 70 61 67 65 2d 3e 63 6c 61 73 73 00 00 00 00      page->class....
  804160ad38:	70 61 67 65 32 70 61 28 70 61 67 65 29 20 3d 3d     page2pa(page) ==
  804160ad48:	20 70 61 67 65 32 70 61 28 70 61 67 65 2d 3e 6c      page2pa(page->l
  804160ad58:	65 66 74 29 00 00 00 00 70 61 67 65 2d 3e 72 69     eft)....page->ri
  804160ad68:	67 68 74 2d 3e 63 6c 61 73 73 20 2b 20 31 20 3d     ght->class + 1 =
  804160ad78:	3d 20 70 61 67 65 2d 3e 63 6c 61 73 73 00 00 00     = page->class...
  804160ad88:	70 61 67 65 2d 3e 61 64 64 72 20 2b 20 28 31 55     page->addr + (1U
  804160ad98:	4c 4c 20 3c 3c 20 28 70 61 67 65 2d 3e 63 6c 61     LL << (page->cla
  804160ada8:	73 73 20 2d 20 31 29 29 20 3d 3d 20 70 61 67 65     ss - 1)) == page
  804160adb8:	2d 3e 72 69 67 68 74 2d 3e 61 64 64 72 00 00 00     ->right->addr...
  804160adc8:	70 61 67 65 2d 3e 70 61 72 65 6e 74 2d 3e 63 6c     page->parent->cl
  804160add8:	61 73 73 20 2d 20 31 20 3d 3d 20 70 61 67 65 2d     ass - 1 == page-
  804160ade8:	3e 63 6c 61 73 73 00 00 28 70 61 67 65 2d 3e 70     >class..(page->p
  804160adf8:	61 72 65 6e 74 2d 3e 6c 65 66 74 20 3d 3d 20 70     arent->left == p
  804160ae08:	61 67 65 29 20 5e 20 28 70 61 67 65 2d 3e 70 61     age) ^ (page->pa
  804160ae18:	72 65 6e 74 2d 3e 72 69 67 68 74 20 3d 3d 20 70     rent->right == p
  804160ae28:	61 67 65 29 00 00 00 00 70 61 67 65 2d 3e 68 65     age)....page->he
  804160ae38:	61 64 2e 6e 65 78 74 20 26 26 20 70 61 67 65 2d     ad.next && page-
  804160ae48:	3e 68 65 61 64 2e 70 72 65 76 00 00 00 00 00 00     >head.prev......
  804160ae58:	28 28 76 29 2d 3e 73 74 61 74 65 20 26 20 4e 4f     ((v)->state & NO
  804160ae68:	44 45 5f 54 59 50 45 5f 4d 41 53 4b 29 20 3c 20     DE_TYPE_MASK) < 
  804160ae78:	50 41 52 54 49 41 4c 5f 4e 4f 44 45 00 00 00 00     PARTIAL_NODE....
  804160ae88:	70 65 65 72 2d 3e 73 74 61 74 65 20 3d 3d 20 41     peer->state == A
  804160ae98:	4c 4c 4f 43 41 54 41 42 4c 45 5f 4e 4f 44 45 00     LLOCATABLE_NODE.
  804160aea8:	4b 41 44 44 52 20 63 61 6c 6c 65 64 20 77 69 74     KADDR called wit
  804160aeb8:	68 20 69 6e 76 61 6c 69 64 20 70 61 20 25 70 20     h invalid pa %p 
  804160aec8:	77 69 74 68 20 6d 61 78 5f 6d 65 6d 6f 72 79 5f     with max_memory_
  804160aed8:	6d 61 70 5f 61 64 64 72 3d 25 70 00 00 00 00 00     map_addr=%p.....
  804160aee8:	4b 41 44 44 52 28 70 61 67 65 32 70 61 28 6e 65     KADDR(page2pa(ne
  804160aef8:	77 29 29 20 3d 3d 20 66 69 72 73 74 5f 70 6f 6f     w)) == first_poo
  804160af08:	6c 00 00 00 00 00 00 00 50 41 44 44 52 20 63 61     l.......PADDR ca
  804160af18:	6c 6c 65 64 20 77 69 74 68 20 69 6e 76 61 6c 69     lled with invali
  804160af28:	64 20 6b 76 61 20 25 70 00 00 00 00 00 00 00 00     d kva %p........
  804160af38:	70 61 67 65 32 70 61 28 6e 65 77 29 20 3e 3d 20     page2pa(new) >= 
  804160af48:	50 41 44 44 52 28 65 6e 64 29 20 7c 7c 20 70 61     PADDR(end) || pa
  804160af58:	67 65 32 70 61 28 6e 65 77 29 20 2b 20 43 4c 41     ge2pa(new) + CLA
  804160af68:	53 53 5f 4d 41 53 4b 28 6e 65 77 2d 3e 63 6c 61     SS_MASK(new->cla
  804160af78:	73 73 29 20 3c 20 49 4f 50 48 59 53 4d 45 4d 00     ss) < IOPHYSMEM.
  804160af88:	21 6c 69 73 74 5f 65 6d 70 74 79 28 26 66 72 65     !list_empty(&fre
  804160af98:	65 5f 64 65 73 63 72 69 70 74 6f 72 73 29 00 00     e_descriptors)..
  804160afa8:	28 28 70 61 72 65 6e 74 29 2d 3e 73 74 61 74 65     ((parent)->state
  804160afb8:	20 26 20 4e 4f 44 45 5f 54 59 50 45 5f 4d 41 53      & NODE_TYPE_MAS
  804160afc8:	4b 29 20 3e 3d 20 50 41 52 54 49 41 4c 5f 4e 4f     K) >= PARTIAL_NO
  804160afd8:	44 45 00 00 00 00 00 00 28 28 68 69 6e 74 29 2d     DE......((hint)-
  804160afe8:	3e 73 74 61 74 65 20 26 20 4e 4f 44 45 5f 54 59     >state & NODE_TY
  804160aff8:	50 45 5f 4d 41 53 4b 29 20 3e 3d 20 50 41 52 54     PE_MASK) >= PART
  804160b008:	49 41 4c 5f 4e 4f 44 45 00 00 00 00 00 00 00 00     IAL_NODE........
  804160b018:	6f 74 68 65 72 2d 3e 73 74 61 74 65 20 3d 3d 20     other->state == 
  804160b028:	41 4c 4c 4f 43 41 54 41 42 4c 45 5f 4e 4f 44 45     ALLOCATABLE_NODE
	...
  804160b040:	28 6e 6f 64 65 2d 3e 6c 65 66 74 20 26 26 20 6e     (node->left && n
  804160b050:	6f 64 65 2d 3e 72 69 67 68 74 29 20 7c 7c 20 21     ode->right) || !
  804160b060:	61 6c 6c 6f 63 00 00 00 21 28 70 61 67 65 32 70     alloc...!(page2p
  804160b070:	61 28 6e 6f 64 65 29 20 26 20 43 4c 41 53 53 5f     a(node) & CLASS_
  804160b080:	4d 41 53 4b 28 6e 6f 64 65 2d 3e 63 6c 61 73 73     MASK(node->class
  804160b090:	29 29 00 00 00 00 00 00 4d 65 6d 6f 72 79 20 61     ))......Memory a
  804160b0a0:	6c 6c 6f 63 61 74 6f 72 20 69 73 20 69 6e 69 74     llocator is init
  804160b0b0:	69 61 6c 6c 69 7a 65 64 0a 00 00 00 00 00 00 00     iallized........
  804160b0c0:	50 68 79 73 69 63 61 6c 20 6d 65 6d 6f 72 79 3a     Physical memory:
  804160b0d0:	20 25 7a 75 4d 20 61 76 61 69 6c 61 62 6c 65 2c      %zuM available,
  804160b0e0:	20 62 61 73 65 20 3d 20 25 7a 75 4b 2c 20 65 78      base = %zuK, ex
  804160b0f0:	74 65 6e 64 65 64 20 3d 20 25 7a 75 4b 0a 00 00     tended = %zuK...
  804160b100:	50 68 79 73 69 63 61 6c 20 6d 65 6d 6f 72 79 20     Physical memory 
  804160b110:	74 72 65 65 20 69 73 20 63 6f 72 72 65 63 74 0a     tree is correct.
  804160b120:	00 0f 1f 80 00 00 00 00 61 74 74 65 6d 70 74 20     ........attempt 
  804160b130:	74 6f 20 69 6e 69 74 69 61 74 65 20 6d 65 6d 6f     to initiate memo
  804160b140:	72 79 20 5b 25 6c 6c 78 20 2d 20 25 6c 6c 78 5d     ry [%llx - %llx]
  804160b150:	20 66 6f 72 20 70 72 6f 63 63 65 73 73 20 25 70      for proccess %p
  804160b160:	00 6b 65 72 6e 2f 65 6e 76 2e 63 00 65 6e 76 5f     .kern/env.c.env_
  804160b170:	63 72 65 61 74 65 3a 20 25 69 0a 00 2e 62 73 73     create: %i...bss
  804160b180:	00 2e 73 74 72 74 61 62 00 2e 73 79 6d 74 61 62     ..strtab..symtab
  804160b190:	00 73 79 73 5f 79 69 65 6c 64 00 73 79 73 5f 65     .sys_yield.sys_e
  804160b1a0:	78 69 74 00 63 75 72 65 6e 76 20 3d 20 4e 55 4c     xit.curenv = NUL
  804160b1b0:	4c 00 52 65 61 63 68 65 64 20 75 6e 72 65 63 68     L.Reached unrech
  804160b1c0:	65 62 6c 65 0a 00 66 2e 0f 1f 84 00 00 00 00 00     eble..f.........
  804160b1d0:	66 2e 0f 1f 84 00 00 00 00 00 66 0f 1f 44 00 00     f.........f..D..

000000804160b1e0 <N_NON_DWARF_KERN_FUNCTIONS>:
  804160b1e0:	02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00     ................
	...

000000804160b200 <non_dwarf_kern_functions>:
  804160b200:	91 b1 60 41 80 00 00 00 df 00 60 41 80 00 00 00     ..`A......`A....
  804160b210:	9b b1 60 41 80 00 00 00 ec 00 60 41 80 00 00 00     ..`A......`A....
  804160b220:	72 74 63 00 65 6e 61 62 6c 65 64 20 69 6e 74 65     rtc.enabled inte
  804160b230:	72 72 75 70 74 73 3a 00 20 20 72 31 35 20 20 30     rrupts:.  r15  0
  804160b240:	78 25 30 38 6c 78 0a 00 20 20 72 31 34 20 20 30     x%08lx..  r14  0
  804160b250:	78 25 30 38 6c 78 0a 00 20 20 72 31 33 20 20 30     x%08lx..  r13  0
  804160b260:	78 25 30 38 6c 78 0a 00 20 20 72 31 32 20 20 30     x%08lx..  r12  0
  804160b270:	78 25 30 38 6c 78 0a 00 20 20 72 31 31 20 20 30     x%08lx..  r11  0
  804160b280:	78 25 30 38 6c 78 0a 00 20 20 72 31 30 20 20 30     x%08lx..  r10  0
  804160b290:	78 25 30 38 6c 78 0a 00 20 20 72 39 20 20 20 30     x%08lx..  r9   0
  804160b2a0:	78 25 30 38 6c 78 0a 00 20 20 72 38 20 20 20 30     x%08lx..  r8   0
  804160b2b0:	78 25 30 38 6c 78 0a 00 20 20 72 64 69 20 20 30     x%08lx..  rdi  0
  804160b2c0:	78 25 30 38 6c 78 0a 00 20 20 72 73 69 20 20 30     x%08lx..  rsi  0
  804160b2d0:	78 25 30 38 6c 78 0a 00 20 20 72 62 70 20 20 30     x%08lx..  rbp  0
  804160b2e0:	78 25 30 38 6c 78 0a 00 20 20 72 62 78 20 20 30     x%08lx..  rbx  0
  804160b2f0:	78 25 30 38 6c 78 0a 00 20 20 72 64 78 20 20 30     x%08lx..  rdx  0
  804160b300:	78 25 30 38 6c 78 0a 00 20 20 72 63 78 20 20 30     x%08lx..  rcx  0
  804160b310:	78 25 30 38 6c 78 0a 00 20 20 72 61 78 20 20 30     x%08lx..  rax  0
  804160b320:	78 25 30 38 6c 78 0a 00 53 79 73 74 65 6d 20 63     x%08lx..System c
  804160b330:	61 6c 6c 00 28 75 6e 6b 6e 6f 77 6e 20 74 72 61     all.(unknown tra
  804160b340:	70 29 00 48 61 72 64 77 61 72 65 20 49 6e 74 65     p).Hardware Inte
  804160b350:	72 72 75 70 74 00 70 72 6f 74 65 63 74 69 6f 6e     rrupt.protection
  804160b360:	00 6e 6f 74 2d 70 72 65 73 65 6e 74 00 72 65 61     .not-present.rea
  804160b370:	64 00 77 72 69 74 65 00 65 78 65 63 75 74 65 00     d.write.execute.
  804160b380:	75 73 65 72 00 54 52 41 50 20 66 72 61 6d 65 20     user.TRAP frame 
  804160b390:	61 74 20 25 70 0a 00 20 20 65 73 20 20 20 30 78     at %p..  es   0x
  804160b3a0:	2d 2d 2d 2d 25 30 34 78 0a 00 20 20 64 73 20 20     ----%04x..  ds  
  804160b3b0:	20 30 78 2d 2d 2d 2d 25 30 34 78 0a 00 20 20 74      0x----%04x..  t
  804160b3c0:	72 61 70 20 30 78 25 30 38 6c 78 20 25 73 0a 00     rap 0x%08lx %s..
  804160b3d0:	20 20 63 72 32 20 20 30 78 25 30 38 6c 78 0a 00       cr2  0x%08lx..
  804160b3e0:	20 20 65 72 72 20 20 30 78 25 30 38 6c 78 00 20       err  0x%08lx. 
  804160b3f0:	5b 25 73 2c 20 25 73 2c 20 25 73 5d 0a 00 20 20     [%s, %s, %s]..  
  804160b400:	72 69 70 20 20 30 78 25 30 38 6c 78 0a 00 20 20     rip  0x%08lx..  
  804160b410:	63 73 20 20 20 30 78 2d 2d 2d 2d 25 30 34 78 0a     cs   0x----%04x.
  804160b420:	00 20 20 66 6c 61 67 20 30 78 25 30 38 6c 78 0a     .  flag 0x%08lx.
  804160b430:	00 20 20 72 73 70 20 20 30 78 25 30 38 6c 78 0a     .  rsp  0x%08lx.
  804160b440:	00 20 20 73 73 20 20 20 30 78 2d 2d 2d 2d 25 30     .  ss   0x----%0
  804160b450:	34 78 0a 00 21 28 72 65 61 64 5f 72 66 6c 61 67     4x..!(read_rflag
  804160b460:	73 28 29 20 26 20 46 4c 5f 49 46 29 00 6b 65 72     s() & FL_IF).ker
  804160b470:	6e 2f 74 72 61 70 2e 63 00 63 75 72 65 6e 76 00     n/trap.c.curenv.
  804160b480:	55 6e 68 61 6e 64 6c 65 64 20 74 72 61 70 20 69     Unhandled trap i
  804160b490:	6e 20 6b 65 72 6e 65 6c 00 44 69 76 69 64 65 20     n kernel.Divide 
  804160b4a0:	65 72 72 6f 72 00 44 65 62 75 67 00 4e 6f 6e 2d     error.Debug.Non-
  804160b4b0:	4d 61 73 6b 61 62 6c 65 20 49 6e 74 65 72 72 75     Maskable Interru
  804160b4c0:	70 74 00 42 72 65 61 6b 70 6f 69 6e 74 00 4f 76     pt.Breakpoint.Ov
  804160b4d0:	65 72 66 6c 6f 77 00 42 4f 55 4e 44 20 52 61 6e     erflow.BOUND Ran
  804160b4e0:	67 65 20 45 78 63 65 65 64 65 64 00 49 6e 76 61     ge Exceeded.Inva
  804160b4f0:	6c 69 64 20 4f 70 63 6f 64 65 00 44 65 76 69 63     lid Opcode.Devic
  804160b500:	65 20 4e 6f 74 20 41 76 61 69 6c 61 62 6c 65 00     e Not Available.
  804160b510:	44 6f 75 62 6c 65 20 46 61 75 6c 74 00 43 6f 70     Double Fault.Cop
  804160b520:	72 6f 63 65 73 73 6f 72 20 53 65 67 6d 65 6e 74     rocessor Segment
  804160b530:	20 4f 76 65 72 72 75 6e 00 49 6e 76 61 6c 69 64      Overrun.Invalid
  804160b540:	20 54 53 53 00 53 65 67 6d 65 6e 74 20 4e 6f 74      TSS.Segment Not
  804160b550:	20 50 72 65 73 65 6e 74 00 53 74 61 63 6b 20 46      Present.Stack F
  804160b560:	61 75 6c 74 00 47 65 6e 65 72 61 6c 20 50 72 6f     ault.General Pro
  804160b570:	74 65 63 74 69 6f 6e 00 50 61 67 65 20 46 61 75     tection.Page Fau
  804160b580:	6c 74 00 78 38 37 20 46 50 55 20 46 6c 6f 61 74     lt.x87 FPU Float
  804160b590:	69 6e 67 2d 50 6f 69 6e 74 20 45 72 72 6f 72 00     ing-Point Error.
  804160b5a0:	41 6c 69 67 6e 6d 65 6e 74 20 43 68 65 63 6b 00     Alignment Check.
  804160b5b0:	4d 61 63 68 69 6e 65 2d 43 68 65 63 6b 00 53 49     Machine-Check.SI
  804160b5c0:	4d 44 20 46 6c 6f 61 74 69 6e 67 2d 50 6f 69 6e     MD Floating-Poin
  804160b5d0:	74 20 45 78 63 65 70 74 69 6f 6e 00 0f 1f 40 00     t Exception...@.

000000804160b5e0 <excnames.0>:
  804160b5e0:	99 b4 60 41 80 00 00 00 a6 b4 60 41 80 00 00 00     ..`A......`A....
  804160b5f0:	ac b4 60 41 80 00 00 00 c3 b4 60 41 80 00 00 00     ..`A......`A....
  804160b600:	ce b4 60 41 80 00 00 00 d7 b4 60 41 80 00 00 00     ..`A......`A....
  804160b610:	ec b4 60 41 80 00 00 00 fb b4 60 41 80 00 00 00     ..`A......`A....
  804160b620:	10 b5 60 41 80 00 00 00 1d b5 60 41 80 00 00 00     ..`A......`A....
  804160b630:	39 b5 60 41 80 00 00 00 45 b5 60 41 80 00 00 00     9.`A....E.`A....
  804160b640:	59 b5 60 41 80 00 00 00 65 b5 60 41 80 00 00 00     Y.`A....e.`A....
  804160b650:	78 b5 60 41 80 00 00 00 34 b3 60 41 80 00 00 00     x.`A....4.`A....
  804160b660:	83 b5 60 41 80 00 00 00 a0 b5 60 41 80 00 00 00     ..`A......`A....
  804160b670:	b0 b5 60 41 80 00 00 00 be b5 60 41 80 00 00 00     ..`A......`A....
  804160b680:	61 63 70 69 5f 66 69 6e 64 5f 74 61 62 6c 65 3a     acpi_find_table:
  804160b690:	20 73 69 67 6e 61 74 75 72 65 20 6f 66 20 72 73      signature of rs
  804160b6a0:	64 70 20 69 73 20 69 6e 76 61 6c 69 64 0a 00 00     dp is invalid...
  804160b6b0:	28 75 69 6e 74 36 34 5f 74 29 72 73 64 70 5f 70     (uint64_t)rsdp_p
  804160b6c0:	74 72 2d 3e 52 73 64 74 41 64 64 72 65 73 73 20     tr->RsdtAddress 
  804160b6d0:	21 3d 20 28 75 69 6e 74 36 34 5f 74 29 72 73 64     != (uint64_t)rsd
  804160b6e0:	70 5f 70 74 72 2d 3e 58 73 64 74 41 64 64 72 65     p_ptr->XsdtAddre
  804160b6f0:	73 73 20 26 26 20 22 78 73 64 74 20 61 6e 64 20     ss && "xsdt and 
  804160b700:	72 73 64 74 20 61 64 72 65 73 73 65 73 20 64 69     rsdt adresses di
  804160b710:	66 66 65 72 22 00 00 00 61 63 70 69 5f 66 69 6e     ffer"...acpi_fin
  804160b720:	64 5f 74 61 62 6c 65 3a 20 73 69 67 6e 61 74 75     d_table: signatu
  804160b730:	72 65 20 6f 66 20 72 73 64 74 20 69 73 20 69 6e     re of rsdt is in
  804160b740:	76 61 6c 69 64 0a 00 00 61 63 70 69 5f 66 69 6e     valid...acpi_fin
  804160b750:	64 5f 74 61 62 6c 65 3a 20 63 68 65 63 6b 73 75     d_table: checksu
  804160b760:	6d 20 6f 66 20 72 73 64 74 20 69 73 20 69 6e 76     m of rsdt is inv
  804160b770:	61 6c 69 64 0a 00 00 00 67 65 74 5f 66 61 64 74     alid....get_fadt
  804160b780:	3a 20 75 6e 61 62 6c 65 20 74 6f 20 67 65 74 20     : unable to get 
  804160b790:	46 41 44 54 20 74 61 62 6c 65 00 00 00 00 00 00     FADT table......
  804160b7a0:	67 65 74 5f 66 61 64 74 3a 20 73 69 67 6e 61 74     get_fadt: signat
  804160b7b0:	75 72 65 20 46 41 44 54 20 74 61 62 6c 65 20 69     ure FADT table i
  804160b7c0:	73 20 69 6e 76 61 6c 69 64 00 00 00 00 00 00 00     s invalid.......
  804160b7d0:	67 65 74 5f 68 70 65 74 3a 20 75 6e 61 62 6c 65     get_hpet: unable
  804160b7e0:	20 74 6f 20 67 65 74 20 48 50 45 54 20 74 61 62      to get HPET tab
  804160b7f0:	6c 65 00 00 00 00 00 00 67 65 74 5f 68 70 65 74     le......get_hpet
  804160b800:	3a 20 73 69 67 6e 61 74 75 72 65 20 48 50 45 54     : signature HPET
  804160b810:	20 74 61 62 6c 65 20 69 73 20 69 6e 76 61 6c 69      table is invali
  804160b820:	64 00 00 00 00 00 00 00 67 65 74 5f 68 70 65 74     d.......get_hpet
  804160b830:	3a 20 68 61 72 64 77 61 72 65 5f 72 65 76 5f 69     : hardware_rev_i
  804160b840:	64 20 69 73 20 30 00 00 67 65 74 5f 68 70 65 74     d is 0..get_hpet
  804160b850:	3a 20 68 70 65 74 20 69 73 20 6e 6f 74 20 65 6e     : hpet is not en
  804160b860:	61 62 6c 65 20 74 6f 20 72 75 6e 20 69 6e 20 36     able to run in 6
  804160b870:	34 20 6d 6f 64 65 00 00 67 65 74 5f 68 70 65 74     4 mode..get_hpet
  804160b880:	3a 20 68 70 65 74 20 64 6f 65 73 6e 27 74 20 73     : hpet doesn't s
  804160b890:	75 70 70 6f 72 74 20 6c 65 67 61 63 79 20 72 65     upport legacy re
  804160b8a0:	70 6c 61 63 65 6d 65 6e 74 00 00 00 00 00 00 00     placement.......
  804160b8b0:	48 50 45 54 20 68 61 73 20 6e 6f 20 4c 65 67 61     HPET has no Lega
  804160b8c0:	63 79 52 65 70 6c 61 63 65 6d 65 6e 74 20 6d 6f     cyReplacement mo
  804160b8d0:	64 65 00 6b 65 72 6e 2f 74 69 6d 65 72 2e 63 00     de.kern/timer.c.
  804160b8e0:	46 41 43 50 00 48 50 45 54 00 68 70 65 74 20 69     FACP.HPET.hpet i
  804160b8f0:	73 20 75 6e 61 76 61 69 6c 61 62 6c 65 0a 00 68     s unavailable..h
  804160b900:	70 65 74 20 21 3d 20 4e 55 4c 4c 00 73 69 67 6e     pet != NULL.sign
  804160b910:	61 74 75 72 65 20 3d 20 25 73 0a 00 6c 65 6e 67     ature = %s..leng
  804160b920:	74 68 20 3d 20 25 30 38 78 0a 00 63 68 65 63 6b     th = %08x..check
  804160b930:	73 75 6d 20 3d 20 25 30 38 78 0a 00 6f 65 6d 5f     sum = %08x..oem_
  804160b940:	72 65 76 69 73 69 6f 6e 20 3d 20 25 30 38 78 0a     revision = %08x.
  804160b950:	00 63 72 65 61 74 6f 72 5f 69 64 20 3d 20 25 30     .creator_id = %0
  804160b960:	38 78 0a 00 63 72 65 61 74 6f 72 5f 72 65 76 69     8x..creator_revi
  804160b970:	73 69 6f 6e 20 3d 20 25 30 38 78 0a 00 68 61 72     sion = %08x..har
  804160b980:	64 77 61 72 65 5f 72 65 76 5f 69 64 20 3d 20 25     dware_rev_id = %
  804160b990:	30 38 78 0a 00 63 6f 6d 70 61 72 61 74 6f 72 5f     08x..comparator_
  804160b9a0:	63 6f 75 6e 74 20 3d 20 25 30 38 78 0a 00 63 6f     count = %08x..co
  804160b9b0:	75 6e 74 65 72 5f 73 69 7a 65 20 3d 20 25 30 38     unter_size = %08
  804160b9c0:	78 0a 00 72 65 73 65 72 76 65 64 20 3d 20 25 30     x..reserved = %0
  804160b9d0:	38 78 0a 00 6c 65 67 61 63 79 5f 72 65 70 6c 61     8x..legacy_repla
  804160b9e0:	63 65 6d 65 6e 74 20 3d 20 25 30 38 78 0a 00 70     cement = %08x..p
  804160b9f0:	63 69 5f 76 65 6e 64 6f 72 5f 69 64 20 3d 20 25     ci_vendor_id = %
  804160ba00:	30 38 78 0a 00 68 70 65 74 5f 6e 75 6d 62 65 72     08x..hpet_number
  804160ba10:	20 3d 20 25 30 38 78 0a 00 6d 69 6e 69 6d 75 6d      = %08x..minimum
  804160ba20:	5f 74 69 63 6b 20 3d 20 25 30 38 78 0a 00 61 64     _tick = %08x..ad
  804160ba30:	64 72 65 73 73 5f 73 74 72 75 63 74 75 72 65 3a     dress_structure:
  804160ba40:	0a 00 61 64 64 72 65 73 73 5f 73 70 61 63 65 5f     ..address_space_
  804160ba50:	69 64 20 3d 20 25 30 38 78 0a 00 72 65 67 69 73     id = %08x..regis
  804160ba60:	74 65 72 5f 62 69 74 5f 77 69 64 74 68 20 3d 20     ter_bit_width = 
  804160ba70:	25 30 38 78 0a 00 72 65 67 69 73 74 65 72 5f 62     %08x..register_b
  804160ba80:	69 74 5f 6f 66 66 73 65 74 20 3d 20 25 30 38 78     it_offset = %08x
  804160ba90:	0a 00 61 64 64 72 65 73 73 20 3d 20 25 30 38 6c     ..address = %08l
  804160baa0:	78 0a 00 47 43 41 50 5f 49 44 20 3d 20 25 30 31     x..GCAP_ID = %01
  804160bab0:	36 6c 78 0a 00 47 45 4e 5f 43 4f 4e 46 20 3d 20     6lx..GEN_CONF = 
  804160bac0:	25 30 31 36 6c 78 0a 00 47 49 4e 54 52 5f 53 54     %016lx..GINTR_ST
  804160bad0:	41 20 3d 20 25 30 31 36 6c 78 0a 00 4d 41 49 4e     A = %016lx..MAIN
  804160bae0:	5f 43 4e 54 20 3d 20 25 30 31 36 6c 78 0a 00 54     _CNT = %016lx..T
  804160baf0:	49 4d 30 5f 43 4f 4e 46 20 3d 20 25 30 31 36 6c     IM0_CONF = %016l
  804160bb00:	78 0a 00 54 49 4d 30 5f 43 4f 4d 50 20 3d 20 25     x..TIM0_COMP = %
  804160bb10:	30 31 36 6c 78 0a 00 54 49 4d 30 5f 46 53 42 20     016lx..TIM0_FSB 
  804160bb20:	3d 20 25 30 31 36 6c 78 0a 00 54 49 4d 31 5f 43     = %016lx..TIM1_C
  804160bb30:	4f 4e 46 20 3d 20 25 30 31 36 6c 78 0a 00 54 49     ONF = %016lx..TI
  804160bb40:	4d 31 5f 43 4f 4d 50 20 3d 20 25 30 31 36 6c 78     M1_COMP = %016lx
  804160bb50:	0a 00 54 49 4d 31 5f 46 53 42 20 3d 20 25 30 31     ..TIM1_FSB = %01
  804160bb60:	36 6c 78 0a 00 54 49 4d 32 5f 43 4f 4e 46 20 3d     6lx..TIM2_CONF =
  804160bb70:	20 25 30 31 36 6c 78 0a 00 54 49 4d 32 5f 43 4f      %016lx..TIM2_CO
  804160bb80:	4d 50 20 3d 20 25 30 31 36 6c 78 0a 00 54 49 4d     MP = %016lx..TIM
  804160bb90:	32 5f 46 53 42 20 3d 20 25 30 31 36 6c 78 0a 00     2_FSB = %016lx..
  804160bba0:	70 6d 00 68 70 65 74 31 00 0f 1f 80 00 00 00 00     pm.hpet1........
  804160bbb0:	4e 6f 20 72 75 6e 6e 61 62 6c 65 20 65 6e 76 69     No runnable envi
  804160bbc0:	72 6f 6e 6d 65 6e 74 73 20 69 6e 20 74 68 65 20     ronments in the 
  804160bbd0:	73 79 73 74 65 6d 21 0a 00 48 61 6c 74 0a 00 3c     system!..Halt..<
  804160bbe0:	75 6e 6b 6e 6f 77 6e 3e 00 61 64 64 72 20 3e 3d     unknown>.addr >=
  804160bbf0:	20 4d 41 58 5f 55 53 45 52 5f 52 45 41 44 41 42      MAX_USER_READAB
  804160bc00:	4c 45 00 6b 65 72 6e 2f 6b 64 65 62 75 67 2e 63     LE.kern/kdebug.c
  804160bc10:	00 30 31 32 33 34 35 36 37 38 39 41 42 43 44 45     .0123456789ABCDE
  804160bc20:	46 00 30 31 32 33 34 35 36 37 38 39 61 62 63 64     F.0123456789abcd
  804160bc30:	65 66 00 28 6e 75 6c 6c 29 00 65 72 72 6f 72 20     ef.(null).error 
  804160bc40:	25 64 00 75 6e 73 70 65 63 69 66 69 65 64 20 65     %d.unspecified e
  804160bc50:	72 72 6f 72 00 62 61 64 20 65 6e 76 69 72 6f 6e     rror.bad environ
  804160bc60:	6d 65 6e 74 00 69 6e 76 61 6c 69 64 20 70 61 72     ment.invalid par
  804160bc70:	61 6d 65 74 65 72 00 6f 75 74 20 6f 66 20 6d 65     ameter.out of me
  804160bc80:	6d 6f 72 79 00 6f 75 74 20 6f 66 20 65 6e 76 69     mory.out of envi
  804160bc90:	72 6f 6e 6d 65 6e 74 73 00 63 6f 72 72 75 70 74     ronments.corrupt
  804160bca0:	65 64 20 64 65 62 75 67 20 69 6e 66 6f 00 73 65     ed debug info.se
  804160bcb0:	67 6d 65 6e 74 61 74 69 6f 6e 20 66 61 75 6c 74     gmentation fault
  804160bcc0:	00 69 6e 76 61 6c 69 64 20 45 4c 46 20 69 6d 61     .invalid ELF ima
  804160bcd0:	67 65 00 6e 6f 20 73 75 63 68 20 73 79 73 74 65     ge.no such syste
  804160bce0:	6d 20 63 61 6c 6c 00 65 6e 74 72 79 20 6e 6f 74     m call.entry not
  804160bcf0:	20 66 6f 75 6e 64 00 66 0f 1f 84 00 00 00 00 00      found.f........
  804160bd00:	0c 8b 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160bd10:	bd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160bd20:	cd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160bd30:	cd 8f 60 41 80 00 00 00 26 8b 60 41 80 00 00 00     ..`A....&.`A....
  804160bd40:	cd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160bd50:	1d 8b 60 41 80 00 00 00 93 8b 60 41 80 00 00 00     ..`A......`A....
  804160bd60:	cd 8f 60 41 80 00 00 00 1d 8b 60 41 80 00 00 00     ..`A......`A....
  804160bd70:	60 8b 60 41 80 00 00 00 60 8b 60 41 80 00 00 00     `.`A....`.`A....
  804160bd80:	60 8b 60 41 80 00 00 00 60 8b 60 41 80 00 00 00     `.`A....`.`A....
  804160bd90:	60 8b 60 41 80 00 00 00 60 8b 60 41 80 00 00 00     `.`A....`.`A....
  804160bda0:	60 8b 60 41 80 00 00 00 60 8b 60 41 80 00 00 00     `.`A....`.`A....
  804160bdb0:	60 8b 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     `.`A......`A....
  804160bdc0:	cd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160bdd0:	cd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160bde0:	cd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160bdf0:	cd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160be00:	cd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160be10:	cd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160be20:	cd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160be30:	cd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160be40:	cd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160be50:	cd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160be60:	cd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160be70:	cd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160be80:	cd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160be90:	cd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160bea0:	cd 8f 60 41 80 00 00 00 7a 8f 60 41 80 00 00 00     ..`A....z.`A....
  804160beb0:	cd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160bec0:	cd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160bed0:	cd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160bee0:	cd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160bef0:	cd 8f 60 41 80 00 00 00 9a 8f 60 41 80 00 00 00     ..`A......`A....
  804160bf00:	c1 8b 60 41 80 00 00 00 b5 8d 60 41 80 00 00 00     ..`A......`A....
  804160bf10:	cd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160bf20:	cd 8f 60 41 80 00 00 00 b6 8b 60 41 80 00 00 00     ..`A......`A....
  804160bf30:	ef 8b 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160bf40:	cd 8f 60 41 80 00 00 00 ab 8b 60 41 80 00 00 00     ..`A......`A....
  804160bf50:	cd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160bf60:	e4 8e 60 41 80 00 00 00 04 8f 60 41 80 00 00 00     ..`A......`A....
  804160bf70:	cd 8f 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160bf80:	85 8c 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160bf90:	c4 8e 60 41 80 00 00 00 cd 8f 60 41 80 00 00 00     ..`A......`A....
  804160bfa0:	cd 8f 60 41 80 00 00 00 7a 8f 60 41 80 00 00 00     ..`A....z.`A....
  804160bfb0:	cd 8f 60 41 80 00 00 00 15 8b 60 41 80 00 00 00     ..`A......`A....

000000804160bfc0 <error_string>:
	...
  804160bfc8:	43 bc 60 41 80 00 00 00 55 bc 60 41 80 00 00 00     C.`A....U.`A....
  804160bfd8:	65 bc 60 41 80 00 00 00 77 bc 60 41 80 00 00 00     e.`A....w.`A....
  804160bfe8:	85 bc 60 41 80 00 00 00 99 bc 60 41 80 00 00 00     ..`A......`A....
  804160bff8:	ae bc 60 41 80 00 00 00 c1 bc 60 41 80 00 00 00     ..`A......`A....
  804160c008:	d3 bc 60 41 80 00 00 00 e7 bc 60 41 80 00 00 00     ..`A......`A....
  804160c018:	43 61 6e 27 74 20 63 61 6c 69 62 72 61 74 65 20     Can't calibrate 
  804160c028:	70 69 74 20 74 69 6d 65 72 2e 20 55 73 69 6e 67     pit timer. Using
  804160c038:	20 64 65 66 61 75 6c 74 20 66 72 65 71 75 65 6e      default frequen
  804160c048:	63 79 0a 00 25 75 0a 00 54 69 6d 65 72 20 45 72     cy..%u..Timer Er
  804160c058:	72 6f 72 0a 00 70 69 74 00 6d 61 63 3a 20 00 25     ror..pit.mac: .%
  804160c068:	78 3a 3a 00 25 78 0a 00 54 68 65 20 45 31 30 30     x::.%x..The E100
  804160c078:	30 20 68 65 61 64 65 72 20 74 79 70 65 20 69 73     0 header type is
  804160c088:	20 69 6e 76 61 6c 69 64 20 28 6e 6f 74 20 61 20      invalid (not a 
  804160c098:	64 65 76 69 63 65 20 68 65 61 64 65 72 2c 20 68     device header, h
  804160c0a8:	61 73 20 68 65 61 64 65 72 20 74 79 70 65 20 25     as header type %
  804160c0b8:	78 2e 0a 00 00 00 00 00 45 31 30 30 30 20 72 65     x.......E1000 re
  804160c0c8:	71 75 65 73 74 73 20 33 32 2d 62 69 74 20 61 64     quests 32-bit ad
  804160c0d8:	64 72 65 73 73 69 6e 67 2e 0a 00 00 00 00 00 00     dressing........
  804160c0e8:	46 6f 75 6e 64 20 65 31 30 30 30 20 6f 66 20 69     Found e1000 of i
  804160c0f8:	64 20 25 30 32 78 3a 25 30 32 78 20 61 74 20 70     d %02x:%02x at p
  804160c108:	63 69 20 25 30 32 75 3a 25 30 32 75 2e 25 75 2e     ci %02u:%02u.%u.
  804160c118:	0a 00 6b 65 72 6e 2f 61 6c 6c 6f 63 2e 63 00 43     ..kern/alloc.c.C
  804160c128:	6f 72 72 75 70 74 65 64 20 6c 69 73 74 2e 0a 00     orrupted list...
