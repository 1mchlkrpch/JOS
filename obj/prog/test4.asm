
obj/prog/test4:     file format elf64-x86-64


Disassembly of section .text:

0000000001030000 <_start>:

    # If not, push dummy argc/argv arguments.
    # This happens when we are loaded by the kernel,
    # because the kernel does not know about passing arguments.
    # Marking argc and argv as zero.
    pushq $0
 1030000:	6a 00                	push   $0x0
    pushq $0
 1030002:	6a 00                	push   $0x0

0000000001030004 <args_exist>:


args_exist:
    movq 8(%rsp), %rsi
 1030004:	48 8b 74 24 08       	mov    0x8(%rsp),%rsi
    movq (%rsp), %rdi
 1030009:	48 8b 3c 24          	mov    (%rsp),%rdi
    xorl %ebp, %ebp
 103000d:	31 ed                	xor    %ebp,%ebp
    call libmain
 103000f:	e8 33 00 00 00       	call   1030047 <libmain>
    mov $sys_exit, %rax
 1030014:	48 c7 c0 10 10 03 01 	mov    $0x1031010,%rax
    call *%rax # Defined in the C though... In lib.h.
 103001b:	ff d0                	call   *%rax
    jmp .
 103001d:	eb fe                	jmp    103001d <args_exist+0x19>

000000000103001f <umain>:

int (*volatile cprintf)(const char *fmt, ...);

void
umain(int argc, char **argv) {
 103001f:	f3 0f 1e fa          	endbr64 
 1030023:	55                   	push   %rbp
 1030024:	48 89 e5             	mov    %rsp,%rbp
    cprintf("TEST4 LOADED.\n");
 1030027:	48 b8 08 10 03 01 00 	movabs $0x1031008,%rax
 103002e:	00 00 00 
 1030031:	48 8b 10             	mov    (%rax),%rdx
 1030034:	48 bf 80 00 03 01 00 	movabs $0x1030080,%rdi
 103003b:	00 00 00 
 103003e:	b8 00 00 00 00       	mov    $0x0,%eax
 1030043:	ff d2                	call   *%rdx

    for (;;)
 1030045:	eb fe                	jmp    1030045 <umain+0x26>

0000000001030047 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
 1030047:	f3 0f 1e fa          	endbr64 
 103004b:	55                   	push   %rbp
 103004c:	48 89 e5             	mov    %rsp,%rbp

    /* Save the name of the program so that panic() can use it */
    if (argc > 0) binaryname = argv[0];
 103004f:	85 ff                	test   %edi,%edi
 1030051:	7e 0d                	jle    1030060 <libmain+0x19>
 1030053:	48 8b 06             	mov    (%rsi),%rax
 1030056:	48 a3 00 10 03 01 00 	movabs %rax,0x1031000
 103005d:	00 00 00 

    /* Call user main routine */
    umain(argc, argv);
 1030060:	48 b8 1f 00 03 01 00 	movabs $0x103001f,%rax
 1030067:	00 00 00 
 103006a:	ff d0                	call   *%rax

#ifdef JOS_PROG
    sys_exit();
 103006c:	48 a1 10 10 03 01 00 	movabs 0x1031010,%rax
 1030073:	00 00 00 
 1030076:	ff d0                	call   *%rax
#endif
}
 1030078:	5d                   	pop    %rbp
 1030079:	c3                   	ret    
 103007a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
 1030080:	54                   	push   %rsp
 1030081:	45 53                	rex.RB push %r11
 1030083:	54                   	push   %rsp
 1030084:	34 20                	xor    $0x20,%al
 1030086:	4c                   	rex.WR
 1030087:	4f                   	rex.WRXB
 1030088:	41                   	rex.B
 1030089:	44                   	rex.R
 103008a:	45                   	rex.RB
 103008b:	44                   	rex.R
 103008c:	2e 0a 00             	cs or  (%rax),%al
 103008f:	3c 75                	cmp    $0x75,%al
 1030091:	6e                   	outsb  %ds:(%rsi),(%dx)
 1030092:	6b 6e 6f 77          	imul   $0x77,0x6f(%rsi),%ebp
 1030096:	6e                   	outsb  %ds:(%rsi),(%dx)
 1030097:	3e                   	ds
	...
