
obj/prog/test6:     file format elf64-x86-64


Disassembly of section .text:

0000000001050000 <_start>:

    # If not, push dummy argc/argv arguments.
    # This happens when we are loaded by the kernel,
    # because the kernel does not know about passing arguments.
    # Marking argc and argv as zero.
    pushq $0
 1050000:	6a 00                	push   $0x0
    pushq $0
 1050002:	6a 00                	push   $0x0

0000000001050004 <args_exist>:


args_exist:
    movq 8(%rsp), %rsi
 1050004:	48 8b 74 24 08       	mov    0x8(%rsp),%rsi
    movq (%rsp), %rdi
 1050009:	48 8b 3c 24          	mov    (%rsp),%rdi
    xorl %ebp, %ebp
 105000d:	31 ed                	xor    %ebp,%ebp
    call libmain
 105000f:	e8 93 01 00 00       	call   10501a7 <libmain>
    mov $sys_exit, %rax
 1050014:	48 c7 c0 d0 10 05 01 	mov    $0x10510d0,%rax
    call *%rax # Defined in the C though... In lib.h.
 105001b:	ff d0                	call   *%rax
    jmp .
 105001d:	eb fe                	jmp    105001d <args_exist+0x19>

000000000105001f <test_rec>:
void (*volatile sys_yield)(void);

unsigned int deep = 0;

void
test_rec(void) {
 105001f:	f3 0f 1e fa          	endbr64 
 1050023:	55                   	push   %rbp
 1050024:	48 89 e5             	mov    %rsp,%rbp
 1050027:	53                   	push   %rbx
 1050028:	48 83 ec 08          	sub    $0x8,%rsp
    void *buf;
    ++deep;
 105002c:	48 b8 a8 10 05 01 00 	movabs $0x10510a8,%rax
 1050033:	00 00 00 
 1050036:	83 00 01             	addl   $0x1,(%rax)

    if (!(rand() % 47)) {
 1050039:	48 b8 da 01 05 01 00 	movabs $0x10501da,%rax
 1050040:	00 00 00 
 1050043:	ff d0                	call   *%rax
 1050045:	48 63 d0             	movslq %eax,%rdx
 1050048:	48 69 d2 5d 41 4c ae 	imul   $0xffffffffae4c415d,%rdx,%rdx
 105004f:	48 c1 ea 20          	shr    $0x20,%rdx
 1050053:	01 c2                	add    %eax,%edx
 1050055:	c1 fa 05             	sar    $0x5,%edx
 1050058:	89 c1                	mov    %eax,%ecx
 105005a:	c1 f9 1f             	sar    $0x1f,%ecx
 105005d:	29 ca                	sub    %ecx,%edx
 105005f:	6b d2 2f             	imul   $0x2f,%edx,%edx
 1050062:	39 d0                	cmp    %edx,%eax
 1050064:	75 0c                	jne    1050072 <test_rec+0x53>
        sys_yield();
 1050066:	48 a1 b0 10 05 01 00 	movabs 0x10510b0,%rax
 105006d:	00 00 00 
 1050070:	ff d0                	call   *%rax
    }

    buf = test_alloc(rand() % 200);
 1050072:	48 b8 c0 10 05 01 00 	movabs $0x10510c0,%rax
 1050079:	00 00 00 
 105007c:	48 8b 18             	mov    (%rax),%rbx
 105007f:	48 b8 da 01 05 01 00 	movabs $0x10501da,%rax
 1050086:	00 00 00 
 1050089:	ff d0                	call   *%rax
 105008b:	48 63 d0             	movslq %eax,%rdx
 105008e:	48 69 d2 1f 85 eb 51 	imul   $0x51eb851f,%rdx,%rdx
 1050095:	48 c1 fa 26          	sar    $0x26,%rdx
 1050099:	89 c1                	mov    %eax,%ecx
 105009b:	c1 f9 1f             	sar    $0x1f,%ecx
 105009e:	29 ca                	sub    %ecx,%edx
 10500a0:	69 d2 c8 00 00 00    	imul   $0xc8,%edx,%edx
 10500a6:	29 d0                	sub    %edx,%eax
 10500a8:	0f b6 f8             	movzbl %al,%edi
 10500ab:	ff d3                	call   *%rbx
 10500ad:	48 89 c3             	mov    %rax,%rbx
    if (buf) {
 10500b0:	48 85 c0             	test   %rax,%rax
 10500b3:	74 6d                	je     1050122 <test_rec+0x103>
        if (deep <= 173 && (rand() % 41)) {
 10500b5:	48 b8 a8 10 05 01 00 	movabs $0x10510a8,%rax
 10500bc:	00 00 00 
 10500bf:	81 38 ad 00 00 00    	cmpl   $0xad,(%rax)
 10500c5:	76 22                	jbe    10500e9 <test_rec+0xca>
            test_rec();
        }
        test_free(buf);
 10500c7:	48 a1 b8 10 05 01 00 	movabs 0x10510b8,%rax
 10500ce:	00 00 00 
 10500d1:	48 89 df             	mov    %rbx,%rdi
 10500d4:	ff d0                	call   *%rax
        if (deep <= 173 && (rand() % 29)) {
            test_rec();
        }
    }

    --deep;
 10500d6:	48 b8 a8 10 05 01 00 	movabs $0x10510a8,%rax
 10500dd:	00 00 00 
 10500e0:	83 28 01             	subl   $0x1,(%rax)
    return;
}
 10500e3:	48 8b 5d f8          	mov    -0x8(%rbp),%rbx
 10500e7:	c9                   	leave  
 10500e8:	c3                   	ret    
        if (deep <= 173 && (rand() % 41)) {
 10500e9:	48 b8 da 01 05 01 00 	movabs $0x10501da,%rax
 10500f0:	00 00 00 
 10500f3:	ff d0                	call   *%rax
 10500f5:	48 63 d0             	movslq %eax,%rdx
 10500f8:	48 69 d2 3f 06 e7 63 	imul   $0x63e7063f,%rdx,%rdx
 10500ff:	48 c1 fa 24          	sar    $0x24,%rdx
 1050103:	89 c1                	mov    %eax,%ecx
 1050105:	c1 f9 1f             	sar    $0x1f,%ecx
 1050108:	29 ca                	sub    %ecx,%edx
 105010a:	8d 0c 92             	lea    (%rdx,%rdx,4),%ecx
 105010d:	8d 14 ca             	lea    (%rdx,%rcx,8),%edx
 1050110:	39 d0                	cmp    %edx,%eax
 1050112:	74 b3                	je     10500c7 <test_rec+0xa8>
            test_rec();
 1050114:	48 b8 1f 00 05 01 00 	movabs $0x105001f,%rax
 105011b:	00 00 00 
 105011e:	ff d0                	call   *%rax
 1050120:	eb a5                	jmp    10500c7 <test_rec+0xa8>
        if (deep <= 173 && (rand() % 29)) {
 1050122:	48 b8 a8 10 05 01 00 	movabs $0x10510a8,%rax
 1050129:	00 00 00 
 105012c:	81 38 ad 00 00 00    	cmpl   $0xad,(%rax)
 1050132:	77 a2                	ja     10500d6 <test_rec+0xb7>
 1050134:	48 b8 da 01 05 01 00 	movabs $0x10501da,%rax
 105013b:	00 00 00 
 105013e:	ff d0                	call   *%rax
 1050140:	48 63 d0             	movslq %eax,%rdx
 1050143:	48 69 d2 09 cb 3d 8d 	imul   $0xffffffff8d3dcb09,%rdx,%rdx
 105014a:	48 c1 ea 20          	shr    $0x20,%rdx
 105014e:	01 c2                	add    %eax,%edx
 1050150:	c1 fa 04             	sar    $0x4,%edx
 1050153:	89 c1                	mov    %eax,%ecx
 1050155:	c1 f9 1f             	sar    $0x1f,%ecx
 1050158:	29 ca                	sub    %ecx,%edx
 105015a:	6b d2 1d             	imul   $0x1d,%edx,%edx
 105015d:	39 d0                	cmp    %edx,%eax
 105015f:	0f 84 71 ff ff ff    	je     10500d6 <test_rec+0xb7>
            test_rec();
 1050165:	48 b8 1f 00 05 01 00 	movabs $0x105001f,%rax
 105016c:	00 00 00 
 105016f:	ff d0                	call   *%rax
 1050171:	e9 60 ff ff ff       	jmp    10500d6 <test_rec+0xb7>

0000000001050176 <umain>:

void
umain(int argc, char **argv) {
 1050176:	f3 0f 1e fa          	endbr64 
 105017a:	55                   	push   %rbp
 105017b:	48 89 e5             	mov    %rsp,%rbp
 105017e:	53                   	push   %rbx
 105017f:	48 83 ec 08          	sub    $0x8,%rsp
    rand_init(5);
 1050183:	bf 05 00 00 00       	mov    $0x5,%edi
 1050188:	b8 00 00 00 00       	mov    $0x0,%eax
 105018d:	48 ba 0b 02 05 01 00 	movabs $0x105020b,%rdx
 1050194:	00 00 00 
 1050197:	ff d2                	call   *%rdx
    for (;;) {
        test_rec();
 1050199:	48 bb 1f 00 05 01 00 	movabs $0x105001f,%rbx
 10501a0:	00 00 00 
 10501a3:	ff d3                	call   *%rbx
    for (;;) {
 10501a5:	eb fc                	jmp    10501a3 <umain+0x2d>

00000000010501a7 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
 10501a7:	f3 0f 1e fa          	endbr64 
 10501ab:	55                   	push   %rbp
 10501ac:	48 89 e5             	mov    %rsp,%rbp

    /* Save the name of the program so that panic() can use it */
    if (argc > 0) binaryname = argv[0];
 10501af:	85 ff                	test   %edi,%edi
 10501b1:	7e 0d                	jle    10501c0 <libmain+0x19>
 10501b3:	48 8b 06             	mov    (%rsi),%rax
 10501b6:	48 a3 00 10 05 01 00 	movabs %rax,0x1051000
 10501bd:	00 00 00 

    /* Call user main routine */
    umain(argc, argv);
 10501c0:	48 b8 76 01 05 01 00 	movabs $0x1050176,%rax
 10501c7:	00 00 00 
 10501ca:	ff d0                	call   *%rax

#ifdef JOS_PROG
    sys_exit();
 10501cc:	48 a1 d0 10 05 01 00 	movabs 0x10510d0,%rax
 10501d3:	00 00 00 
 10501d6:	ff d0                	call   *%rax
#endif
}
 10501d8:	5d                   	pop    %rbp
 10501d9:	c3                   	ret    

00000000010501da <rand>:
    *seed = *seed * 1103515245 + 12345;
    return (*seed % ((unsigned int)RAND_MAX + 1));
}

int
rand(void) {
 10501da:	f3 0f 1e fa          	endbr64 
    *seed = *seed * 1103515245 + 12345;
 10501de:	48 ba 08 10 05 01 00 	movabs $0x1051008,%rdx
 10501e5:	00 00 00 
 10501e8:	69 02 6d 4e c6 41    	imul   $0x41c64e6d,(%rdx),%eax
 10501ee:	05 39 30 00 00       	add    $0x3039,%eax
 10501f3:	89 02                	mov    %eax,(%rdx)
    return (*seed % ((unsigned int)RAND_MAX + 1));
 10501f5:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
    return (rand_r(&next));
}
 10501fa:	c3                   	ret    

00000000010501fb <srand>:

void
srand(unsigned int seed) {
 10501fb:	f3 0f 1e fa          	endbr64 
    next = seed;
 10501ff:	89 f8                	mov    %edi,%eax
 1050201:	a3 08 10 05 01 00 00 	movabs %eax,0x1051008
 1050208:	00 00 
}
 105020a:	c3                   	ret    

000000000105020b <rand_init>:

void
rand_init(unsigned int num) {
 105020b:	f3 0f 1e fa          	endbr64 
 105020f:	89 f8                	mov    %edi,%eax
    srand(((unsigned int *)_dev_urandom)[num % _dev_urandom_len]);
 1050211:	48 b9 20 10 05 01 00 	movabs $0x1051020,%rcx
 1050218:	00 00 00 
 105021b:	ba 00 00 00 00       	mov    $0x0,%edx
 1050220:	f7 31                	divl   (%rcx)
    next = seed;
 1050222:	48 b8 40 10 05 01 00 	movabs $0x1051040,%rax
 1050229:	00 00 00 
 105022c:	8b 04 90             	mov    (%rax,%rdx,4),%eax
 105022f:	a3 08 10 05 01 00 00 	movabs %eax,0x1051008
 1050236:	00 00 
}
 1050238:	c3                   	ret    
 1050239:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
 1050240:	3c 75                	cmp    $0x75,%al
 1050242:	6e                   	outsb  %ds:(%rsi),(%dx)
 1050243:	6b 6e 6f 77          	imul   $0x77,0x6f(%rsi),%ebp
 1050247:	6e                   	outsb  %ds:(%rsi),(%dx)
 1050248:	3e                   	ds
	...
