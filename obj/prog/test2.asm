
obj/prog/test2:     file format elf64-x86-64


Disassembly of section .text:

0000000001010000 <_start>:

    # If not, push dummy argc/argv arguments.
    # This happens when we are loaded by the kernel,
    # because the kernel does not know about passing arguments.
    # Marking argc and argv as zero.
    pushq $0
 1010000:	6a 00                	push   $0x0
    pushq $0
 1010002:	6a 00                	push   $0x0

0000000001010004 <args_exist>:


args_exist:
    movq 8(%rsp), %rsi
 1010004:	48 8b 74 24 08       	mov    0x8(%rsp),%rsi
    movq (%rsp), %rdi
 1010009:	48 8b 3c 24          	mov    (%rsp),%rdi
    xorl %ebp, %ebp
 101000d:	31 ed                	xor    %ebp,%ebp
    call libmain
 101000f:	e8 5d 00 00 00       	call   1010071 <libmain>
    mov $sys_exit, %rax
 1010014:	48 c7 c0 18 10 01 01 	mov    $0x1011018,%rax
    call *%rax # Defined in the C though... In lib.h.
 101001b:	ff d0                	call   *%rax
    jmp .
 101001d:	eb fe                	jmp    101001d <args_exist+0x19>

000000000101001f <umain>:
void (*volatile GRADE3_FUNC)(unsigned);
void (*volatile xc(GRADE3_FAIL, GRADE3_PFX1))(void);
#endif

void
umain(int argc, char **argv) {
 101001f:	f3 0f 1e fa          	endbr64 
 1010023:	55                   	push   %rbp
 1010024:	48 89 e5             	mov    %rsp,%rbp
 1010027:	41 54                	push   %r12
 1010029:	53                   	push   %rbx
    int test2_i;
    int test2_j;

#if !defined(GRADE3_TEST)
    cprintf("TEST2 LOADED.\n");
 101002a:	48 b8 10 10 01 01 00 	movabs $0x1011010,%rax
 1010031:	00 00 00 
 1010034:	48 8b 10             	mov    (%rax),%rdx
 1010037:	48 bf a8 00 01 01 00 	movabs $0x10100a8,%rdi
 101003e:	00 00 00 
 1010041:	b8 00 00 00 00       	mov    $0x0,%eax
 1010046:	ff d2                	call   *%rdx
 1010048:	bb 05 00 00 00       	mov    $0x5,%ebx
#endif

    for (test2_j = 0; test2_j < 5; ++test2_j) {
        for (test2_i = 0; test2_i < 10000; ++test2_i)
            ;
        sys_yield();
 101004d:	49 bc 08 10 01 01 00 	movabs $0x1011008,%r12
 1010054:	00 00 00 
umain(int argc, char **argv) {
 1010057:	b8 10 27 00 00       	mov    $0x2710,%eax
        for (test2_i = 0; test2_i < 10000; ++test2_i)
 101005c:	83 e8 01             	sub    $0x1,%eax
 101005f:	75 fb                	jne    101005c <umain+0x3d>
        sys_yield();
 1010061:	49 8b 04 24          	mov    (%r12),%rax
 1010065:	ff d0                	call   *%rax
    for (test2_j = 0; test2_j < 5; ++test2_j) {
 1010067:	83 eb 01             	sub    $0x1,%ebx
 101006a:	75 eb                	jne    1010057 <umain+0x38>
    }
}
 101006c:	5b                   	pop    %rbx
 101006d:	41 5c                	pop    %r12
 101006f:	5d                   	pop    %rbp
 1010070:	c3                   	ret    

0000000001010071 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
 1010071:	f3 0f 1e fa          	endbr64 
 1010075:	55                   	push   %rbp
 1010076:	48 89 e5             	mov    %rsp,%rbp

    /* Save the name of the program so that panic() can use it */
    if (argc > 0) binaryname = argv[0];
 1010079:	85 ff                	test   %edi,%edi
 101007b:	7e 0d                	jle    101008a <libmain+0x19>
 101007d:	48 8b 06             	mov    (%rsi),%rax
 1010080:	48 a3 00 10 01 01 00 	movabs %rax,0x1011000
 1010087:	00 00 00 

    /* Call user main routine */
    umain(argc, argv);
 101008a:	48 b8 1f 00 01 01 00 	movabs $0x101001f,%rax
 1010091:	00 00 00 
 1010094:	ff d0                	call   *%rax

#ifdef JOS_PROG
    sys_exit();
 1010096:	48 a1 18 10 01 01 00 	movabs 0x1011018,%rax
 101009d:	00 00 00 
 10100a0:	ff d0                	call   *%rax
#endif
}
 10100a2:	5d                   	pop    %rbp
 10100a3:	c3                   	ret    
 10100a4:	0f 1f 40 00          	nopl   0x0(%rax)
 10100a8:	54                   	push   %rsp
 10100a9:	45 53                	rex.RB push %r11
 10100ab:	54                   	push   %rsp
 10100ac:	32 20                	xor    (%rax),%ah
 10100ae:	4c                   	rex.WR
 10100af:	4f                   	rex.WRXB
 10100b0:	41                   	rex.B
 10100b1:	44                   	rex.R
 10100b2:	45                   	rex.RB
 10100b3:	44                   	rex.R
 10100b4:	2e 0a 00             	cs or  (%rax),%al
 10100b7:	3c 75                	cmp    $0x75,%al
 10100b9:	6e                   	outsb  %ds:(%rsi),(%dx)
 10100ba:	6b 6e 6f 77          	imul   $0x77,0x6f(%rsi),%ebp
 10100be:	6e                   	outsb  %ds:(%rsi),(%dx)
 10100bf:	3e                   	ds
	...
