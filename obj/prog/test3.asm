
obj/prog/test3:     file format elf64-x86-64


Disassembly of section .text:

0000000001020000 <_start>:

    # If not, push dummy argc/argv arguments.
    # This happens when we are loaded by the kernel,
    # because the kernel does not know about passing arguments.
    # Marking argc and argv as zero.
    pushq $0
 1020000:	6a 00                	push   $0x0
    pushq $0
 1020002:	6a 00                	push   $0x0

0000000001020004 <args_exist>:


args_exist:
    movq 8(%rsp), %rsi
 1020004:	48 8b 74 24 08       	mov    0x8(%rsp),%rsi
    movq (%rsp), %rdi
 1020009:	48 8b 3c 24          	mov    (%rsp),%rdi
    xorl %ebp, %ebp
 102000d:	31 ed                	xor    %ebp,%ebp
    call libmain
 102000f:	e8 7b 00 00 00       	call   102008f <libmain>
    mov $sys_exit, %rax
 1020014:	48 c7 c0 18 10 02 01 	mov    $0x1021018,%rax
    call *%rax # Defined in the C though... In lib.h.
 102001b:	ff d0                	call   *%rax
    jmp .
 102001d:	eb fe                	jmp    102001d <args_exist+0x19>

000000000102001f <umain>:
void (*volatile sys_yield)(void);
int (*volatile cprintf)(const char *fmt, ...);

void
umain(int argc, char **argv) {
 102001f:	f3 0f 1e fa          	endbr64 
 1020023:	55                   	push   %rbp
 1020024:	48 89 e5             	mov    %rsp,%rbp
 1020027:	41 57                	push   %r15
 1020029:	41 56                	push   %r14
 102002b:	41 55                	push   %r13
 102002d:	41 54                	push   %r12
 102002f:	53                   	push   %rbx
 1020030:	48 83 ec 08          	sub    $0x8,%rsp
    int i, j;

    for (j = 0; j < 3; ++j) {
        for (i = 0; i < 100; ++i){
 1020034:	41 be 03 00 00 00    	mov    $0x3,%r14d
            cprintf("%d\n", i);
 102003a:	49 bd 08 10 02 01 00 	movabs $0x1021008,%r13
 1020041:	00 00 00 
 1020044:	49 bc c8 00 02 01 00 	movabs $0x10200c8,%r12
 102004b:	00 00 00 
        }
        sys_yield();
 102004e:	49 bf 10 10 02 01 00 	movabs $0x1021010,%r15
 1020055:	00 00 00 
        for (i = 0; i < 100; ++i){
 1020058:	bb 00 00 00 00       	mov    $0x0,%ebx
            cprintf("%d\n", i);
 102005d:	49 8b 55 00          	mov    0x0(%r13),%rdx
 1020061:	89 de                	mov    %ebx,%esi
 1020063:	4c 89 e7             	mov    %r12,%rdi
 1020066:	b8 00 00 00 00       	mov    $0x0,%eax
 102006b:	ff d2                	call   *%rdx
        for (i = 0; i < 100; ++i){
 102006d:	83 c3 01             	add    $0x1,%ebx
 1020070:	83 fb 64             	cmp    $0x64,%ebx
 1020073:	75 e8                	jne    102005d <umain+0x3e>
        sys_yield();
 1020075:	49 8b 07             	mov    (%r15),%rax
 1020078:	ff d0                	call   *%rax
    for (j = 0; j < 3; ++j) {
 102007a:	41 83 ee 01          	sub    $0x1,%r14d
 102007e:	75 d8                	jne    1020058 <umain+0x39>
    }
}
 1020080:	48 83 c4 08          	add    $0x8,%rsp
 1020084:	5b                   	pop    %rbx
 1020085:	41 5c                	pop    %r12
 1020087:	41 5d                	pop    %r13
 1020089:	41 5e                	pop    %r14
 102008b:	41 5f                	pop    %r15
 102008d:	5d                   	pop    %rbp
 102008e:	c3                   	ret    

000000000102008f <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
 102008f:	f3 0f 1e fa          	endbr64 
 1020093:	55                   	push   %rbp
 1020094:	48 89 e5             	mov    %rsp,%rbp

    /* Save the name of the program so that panic() can use it */
    if (argc > 0) binaryname = argv[0];
 1020097:	85 ff                	test   %edi,%edi
 1020099:	7e 0d                	jle    10200a8 <libmain+0x19>
 102009b:	48 8b 06             	mov    (%rsi),%rax
 102009e:	48 a3 00 10 02 01 00 	movabs %rax,0x1021000
 10200a5:	00 00 00 

    /* Call user main routine */
    umain(argc, argv);
 10200a8:	48 b8 1f 00 02 01 00 	movabs $0x102001f,%rax
 10200af:	00 00 00 
 10200b2:	ff d0                	call   *%rax

#ifdef JOS_PROG
    sys_exit();
 10200b4:	48 a1 18 10 02 01 00 	movabs 0x1021018,%rax
 10200bb:	00 00 00 
 10200be:	ff d0                	call   *%rax
#endif
}
 10200c0:	5d                   	pop    %rbp
 10200c1:	c3                   	ret    
 10200c2:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
 10200c8:	25 64 0a 00 3c       	and    $0x3c000a64,%eax
 10200cd:	75 6e                	jne    102013d <libmain+0xae>
 10200cf:	6b 6e 6f 77          	imul   $0x77,0x6f(%rsi),%ebp
 10200d3:	6e                   	outsb  %ds:(%rsi),(%dx)
 10200d4:	3e                   	ds
	...
