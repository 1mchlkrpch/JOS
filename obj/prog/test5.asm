
obj/prog/test5:     file format elf64-x86-64


Disassembly of section .text:

0000000001040000 <_start>:

    # If not, push dummy argc/argv arguments.
    # This happens when we are loaded by the kernel,
    # because the kernel does not know about passing arguments.
    # Marking argc and argv as zero.
    pushq $0
 1040000:	6a 00                	push   $0x0
    pushq $0
 1040002:	6a 00                	push   $0x0

0000000001040004 <args_exist>:


args_exist:
    movq 8(%rsp), %rsi
 1040004:	48 8b 74 24 08       	mov    0x8(%rsp),%rsi
    movq (%rsp), %rdi
 1040009:	48 8b 3c 24          	mov    (%rsp),%rdi
    xorl %ebp, %ebp
 104000d:	31 ed                	xor    %ebp,%ebp
    call libmain
 104000f:	e8 8a 01 00 00       	call   104019e <libmain>
    mov $sys_exit, %rax
 1040014:	48 c7 c0 d0 10 04 01 	mov    $0x10410d0,%rax
    call *%rax # Defined in the C though... In lib.h.
 104001b:	ff d0                	call   *%rax
    jmp .
 104001d:	eb fe                	jmp    104001d <args_exist+0x19>

000000000104001f <test_rec>:
void (*volatile sys_yield)(void);

unsigned int deep = 0;

void
test_rec(void) {
 104001f:	f3 0f 1e fa          	endbr64 
 1040023:	55                   	push   %rbp
 1040024:	48 89 e5             	mov    %rsp,%rbp
 1040027:	53                   	push   %rbx
 1040028:	48 83 ec 08          	sub    $0x8,%rsp
    void *buf;
    ++deep;
 104002c:	48 b8 a8 10 04 01 00 	movabs $0x10410a8,%rax
 1040033:	00 00 00 
 1040036:	83 00 01             	addl   $0x1,(%rax)

    if (!(rand() % 79)) {
 1040039:	48 b8 d1 01 04 01 00 	movabs $0x10401d1,%rax
 1040040:	00 00 00 
 1040043:	ff d0                	call   *%rax
 1040045:	48 63 d0             	movslq %eax,%rdx
 1040048:	48 69 d2 55 3a b2 67 	imul   $0x67b23a55,%rdx,%rdx
 104004f:	48 c1 fa 25          	sar    $0x25,%rdx
 1040053:	89 c1                	mov    %eax,%ecx
 1040055:	c1 f9 1f             	sar    $0x1f,%ecx
 1040058:	29 ca                	sub    %ecx,%edx
 104005a:	6b d2 4f             	imul   $0x4f,%edx,%edx
 104005d:	39 d0                	cmp    %edx,%eax
 104005f:	75 0c                	jne    104006d <test_rec+0x4e>
        sys_yield();
 1040061:	48 a1 b0 10 04 01 00 	movabs 0x10410b0,%rax
 1040068:	00 00 00 
 104006b:	ff d0                	call   *%rax
    }

    buf = test_alloc(rand() % 300);
 104006d:	48 b8 c0 10 04 01 00 	movabs $0x10410c0,%rax
 1040074:	00 00 00 
 1040077:	48 8b 18             	mov    (%rax),%rbx
 104007a:	48 b8 d1 01 04 01 00 	movabs $0x10401d1,%rax
 1040081:	00 00 00 
 1040084:	ff d0                	call   *%rax
 1040086:	48 63 d0             	movslq %eax,%rdx
 1040089:	48 69 d2 b5 81 4e 1b 	imul   $0x1b4e81b5,%rdx,%rdx
 1040090:	48 c1 fa 25          	sar    $0x25,%rdx
 1040094:	89 c1                	mov    %eax,%ecx
 1040096:	c1 f9 1f             	sar    $0x1f,%ecx
 1040099:	29 ca                	sub    %ecx,%edx
 104009b:	69 d2 2c 01 00 00    	imul   $0x12c,%edx,%edx
 10400a1:	29 d0                	sub    %edx,%eax
 10400a3:	0f b6 f8             	movzbl %al,%edi
 10400a6:	ff d3                	call   *%rbx
 10400a8:	48 89 c3             	mov    %rax,%rbx
    if (buf) {
 10400ab:	48 85 c0             	test   %rax,%rax
 10400ae:	74 6a                	je     104011a <test_rec+0xfb>
        if (deep < 200 && (rand() % 53)) {
 10400b0:	48 b8 a8 10 04 01 00 	movabs $0x10410a8,%rax
 10400b7:	00 00 00 
 10400ba:	81 38 c7 00 00 00    	cmpl   $0xc7,(%rax)
 10400c0:	76 22                	jbe    10400e4 <test_rec+0xc5>
            test_rec();
        }
        test_free(buf);
 10400c2:	48 a1 b8 10 04 01 00 	movabs 0x10410b8,%rax
 10400c9:	00 00 00 
 10400cc:	48 89 df             	mov    %rbx,%rdi
 10400cf:	ff d0                	call   *%rax
        if (deep < 200 && (rand() % 17)) {
            test_rec();
        }
    }

    --deep;
 10400d1:	48 b8 a8 10 04 01 00 	movabs $0x10410a8,%rax
 10400d8:	00 00 00 
 10400db:	83 28 01             	subl   $0x1,(%rax)
    return;
}
 10400de:	48 8b 5d f8          	mov    -0x8(%rbp),%rbx
 10400e2:	c9                   	leave  
 10400e3:	c3                   	ret    
        if (deep < 200 && (rand() % 53)) {
 10400e4:	48 b8 d1 01 04 01 00 	movabs $0x10401d1,%rax
 10400eb:	00 00 00 
 10400ee:	ff d0                	call   *%rax
 10400f0:	48 63 d0             	movslq %eax,%rdx
 10400f3:	48 69 d2 ed 73 48 4d 	imul   $0x4d4873ed,%rdx,%rdx
 10400fa:	48 c1 fa 24          	sar    $0x24,%rdx
 10400fe:	89 c1                	mov    %eax,%ecx
 1040100:	c1 f9 1f             	sar    $0x1f,%ecx
 1040103:	29 ca                	sub    %ecx,%edx
 1040105:	6b d2 35             	imul   $0x35,%edx,%edx
 1040108:	39 d0                	cmp    %edx,%eax
 104010a:	74 b6                	je     10400c2 <test_rec+0xa3>
            test_rec();
 104010c:	48 b8 1f 00 04 01 00 	movabs $0x104001f,%rax
 1040113:	00 00 00 
 1040116:	ff d0                	call   *%rax
 1040118:	eb a8                	jmp    10400c2 <test_rec+0xa3>
        if (deep < 200 && (rand() % 17)) {
 104011a:	48 b8 a8 10 04 01 00 	movabs $0x10410a8,%rax
 1040121:	00 00 00 
 1040124:	81 38 c7 00 00 00    	cmpl   $0xc7,(%rax)
 104012a:	77 a5                	ja     10400d1 <test_rec+0xb2>
 104012c:	48 b8 d1 01 04 01 00 	movabs $0x10401d1,%rax
 1040133:	00 00 00 
 1040136:	ff d0                	call   *%rax
 1040138:	48 63 d0             	movslq %eax,%rdx
 104013b:	48 69 d2 79 78 78 78 	imul   $0x78787879,%rdx,%rdx
 1040142:	48 c1 fa 23          	sar    $0x23,%rdx
 1040146:	89 c1                	mov    %eax,%ecx
 1040148:	c1 f9 1f             	sar    $0x1f,%ecx
 104014b:	29 ca                	sub    %ecx,%edx
 104014d:	89 d1                	mov    %edx,%ecx
 104014f:	c1 e1 04             	shl    $0x4,%ecx
 1040152:	01 ca                	add    %ecx,%edx
 1040154:	39 d0                	cmp    %edx,%eax
 1040156:	0f 84 75 ff ff ff    	je     10400d1 <test_rec+0xb2>
            test_rec();
 104015c:	48 b8 1f 00 04 01 00 	movabs $0x104001f,%rax
 1040163:	00 00 00 
 1040166:	ff d0                	call   *%rax
 1040168:	e9 64 ff ff ff       	jmp    10400d1 <test_rec+0xb2>

000000000104016d <umain>:

void
umain(int argc, char **argv) {
 104016d:	f3 0f 1e fa          	endbr64 
 1040171:	55                   	push   %rbp
 1040172:	48 89 e5             	mov    %rsp,%rbp
 1040175:	53                   	push   %rbx
 1040176:	48 83 ec 08          	sub    $0x8,%rsp
    rand_init(4);
 104017a:	bf 04 00 00 00       	mov    $0x4,%edi
 104017f:	b8 00 00 00 00       	mov    $0x0,%eax
 1040184:	48 ba 02 02 04 01 00 	movabs $0x1040202,%rdx
 104018b:	00 00 00 
 104018e:	ff d2                	call   *%rdx
    for (;;) {
        test_rec();
 1040190:	48 bb 1f 00 04 01 00 	movabs $0x104001f,%rbx
 1040197:	00 00 00 
 104019a:	ff d3                	call   *%rbx
    for (;;) {
 104019c:	eb fc                	jmp    104019a <umain+0x2d>

000000000104019e <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
 104019e:	f3 0f 1e fa          	endbr64 
 10401a2:	55                   	push   %rbp
 10401a3:	48 89 e5             	mov    %rsp,%rbp

    /* Save the name of the program so that panic() can use it */
    if (argc > 0) binaryname = argv[0];
 10401a6:	85 ff                	test   %edi,%edi
 10401a8:	7e 0d                	jle    10401b7 <libmain+0x19>
 10401aa:	48 8b 06             	mov    (%rsi),%rax
 10401ad:	48 a3 00 10 04 01 00 	movabs %rax,0x1041000
 10401b4:	00 00 00 

    /* Call user main routine */
    umain(argc, argv);
 10401b7:	48 b8 6d 01 04 01 00 	movabs $0x104016d,%rax
 10401be:	00 00 00 
 10401c1:	ff d0                	call   *%rax

#ifdef JOS_PROG
    sys_exit();
 10401c3:	48 a1 d0 10 04 01 00 	movabs 0x10410d0,%rax
 10401ca:	00 00 00 
 10401cd:	ff d0                	call   *%rax
#endif
}
 10401cf:	5d                   	pop    %rbp
 10401d0:	c3                   	ret    

00000000010401d1 <rand>:
    *seed = *seed * 1103515245 + 12345;
    return (*seed % ((unsigned int)RAND_MAX + 1));
}

int
rand(void) {
 10401d1:	f3 0f 1e fa          	endbr64 
    *seed = *seed * 1103515245 + 12345;
 10401d5:	48 ba 08 10 04 01 00 	movabs $0x1041008,%rdx
 10401dc:	00 00 00 
 10401df:	69 02 6d 4e c6 41    	imul   $0x41c64e6d,(%rdx),%eax
 10401e5:	05 39 30 00 00       	add    $0x3039,%eax
 10401ea:	89 02                	mov    %eax,(%rdx)
    return (*seed % ((unsigned int)RAND_MAX + 1));
 10401ec:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
    return (rand_r(&next));
}
 10401f1:	c3                   	ret    

00000000010401f2 <srand>:

void
srand(unsigned int seed) {
 10401f2:	f3 0f 1e fa          	endbr64 
    next = seed;
 10401f6:	89 f8                	mov    %edi,%eax
 10401f8:	a3 08 10 04 01 00 00 	movabs %eax,0x1041008
 10401ff:	00 00 
}
 1040201:	c3                   	ret    

0000000001040202 <rand_init>:

void
rand_init(unsigned int num) {
 1040202:	f3 0f 1e fa          	endbr64 
 1040206:	89 f8                	mov    %edi,%eax
    srand(((unsigned int *)_dev_urandom)[num % _dev_urandom_len]);
 1040208:	48 b9 20 10 04 01 00 	movabs $0x1041020,%rcx
 104020f:	00 00 00 
 1040212:	ba 00 00 00 00       	mov    $0x0,%edx
 1040217:	f7 31                	divl   (%rcx)
    next = seed;
 1040219:	48 b8 40 10 04 01 00 	movabs $0x1041040,%rax
 1040220:	00 00 00 
 1040223:	8b 04 90             	mov    (%rax,%rdx,4),%eax
 1040226:	a3 08 10 04 01 00 00 	movabs %eax,0x1041008
 104022d:	00 00 
}
 104022f:	c3                   	ret    
 1040230:	3c 75                	cmp    $0x75,%al
 1040232:	6e                   	outsb  %ds:(%rsi),(%dx)
 1040233:	6b 6e 6f 77          	imul   $0x77,0x6f(%rsi),%ebp
 1040237:	6e                   	outsb  %ds:(%rsi),(%dx)
 1040238:	3e                   	ds
	...
