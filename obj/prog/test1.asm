
obj/prog/test1:     file format elf64-x86-64


Disassembly of section .text:

0000000001000000 <_start>:

    # If not, push dummy argc/argv arguments.
    # This happens when we are loaded by the kernel,
    # because the kernel does not know about passing arguments.
    # Marking argc and argv as zero.
    pushq $0
 1000000:	6a 00                	push   $0x0
    pushq $0
 1000002:	6a 00                	push   $0x0

0000000001000004 <args_exist>:


args_exist:
    movq 8(%rsp), %rsi
 1000004:	48 8b 74 24 08       	mov    0x8(%rsp),%rsi
    movq (%rsp), %rdi
 1000009:	48 8b 3c 24          	mov    (%rsp),%rdi
    xorl %ebp, %ebp
 100000d:	31 ed                	xor    %ebp,%ebp
    call libmain
 100000f:	e8 3f 00 00 00       	call   1000053 <libmain>
    mov $sys_exit, %rax
 1000014:	48 c7 c0 10 10 00 01 	mov    $0x1001010,%rax
    call *%rax # Defined in the C though... In lib.h.
 100001b:	ff d0                	call   *%rax
    jmp .
 100001d:	eb fe                	jmp    100001d <args_exist+0x19>

000000000100001f <umain>:
void (*volatile sys_yield)(void);

void foo();
void
umain(int argc, char **argv) {
 100001f:	f3 0f 1e fa          	endbr64 
 1000023:	55                   	push   %rbp
 1000024:	48 89 e5             	mov    %rsp,%rbp
 1000027:	41 54                	push   %r12
 1000029:	53                   	push   %rbx
 100002a:	bb 03 00 00 00       	mov    $0x3,%ebx
    int i, j;

    for (j = 0; j < 3; ++j) {
        for (i = 0; i < 10000; ++i)
            ;
        sys_yield();
 100002f:	49 bc 08 10 00 01 00 	movabs $0x1001008,%r12
 1000036:	00 00 00 
umain(int argc, char **argv) {
 1000039:	b8 10 27 00 00       	mov    $0x2710,%eax
        for (i = 0; i < 10000; ++i)
 100003e:	83 e8 01             	sub    $0x1,%eax
 1000041:	75 fb                	jne    100003e <umain+0x1f>
        sys_yield();
 1000043:	49 8b 04 24          	mov    (%r12),%rax
 1000047:	ff d0                	call   *%rax
    for (j = 0; j < 3; ++j) {
 1000049:	83 eb 01             	sub    $0x1,%ebx
 100004c:	75 eb                	jne    1000039 <umain+0x1a>
    }
}
 100004e:	5b                   	pop    %rbx
 100004f:	41 5c                	pop    %r12
 1000051:	5d                   	pop    %rbp
 1000052:	c3                   	ret    

0000000001000053 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
 1000053:	f3 0f 1e fa          	endbr64 
 1000057:	55                   	push   %rbp
 1000058:	48 89 e5             	mov    %rsp,%rbp

    /* Save the name of the program so that panic() can use it */
    if (argc > 0) binaryname = argv[0];
 100005b:	85 ff                	test   %edi,%edi
 100005d:	7e 0d                	jle    100006c <libmain+0x19>
 100005f:	48 8b 06             	mov    (%rsi),%rax
 1000062:	48 a3 00 10 00 01 00 	movabs %rax,0x1001000
 1000069:	00 00 00 

    /* Call user main routine */
    umain(argc, argv);
 100006c:	48 b8 1f 00 00 01 00 	movabs $0x100001f,%rax
 1000073:	00 00 00 
 1000076:	ff d0                	call   *%rax

#ifdef JOS_PROG
    sys_exit();
 1000078:	48 a1 10 10 00 01 00 	movabs 0x1001010,%rax
 100007f:	00 00 00 
 1000082:	ff d0                	call   *%rax
#endif
}
 1000084:	5d                   	pop    %rbp
 1000085:	c3                   	ret    
 1000086:	66 90                	xchg   %ax,%ax
 1000088:	3c 75                	cmp    $0x75,%al
 100008a:	6e                   	outsb  %ds:(%rsi),(%dx)
 100008b:	6b 6e 6f 77          	imul   $0x77,0x6f(%rsi),%ebp
 100008f:	6e                   	outsb  %ds:(%rsi),(%dx)
 1000090:	3e                   	ds
	...
