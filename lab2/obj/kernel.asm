
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	00006297          	auipc	t0,0x6
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0206000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	00006297          	auipc	t0,0x6
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0206008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)

    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200034:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200038:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc020003c:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200044:	0d828293          	addi	t0,t0,216 # ffffffffc02000d8 <kern_init>
    jr t0
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020004a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[];
    cprintf("Special kernel symbols:\n");
ffffffffc020004c:	00002517          	auipc	a0,0x2
ffffffffc0200050:	d5450513          	addi	a0,a0,-684 # ffffffffc0201da0 <etext+0x4>
void print_kerninfo(void) {
ffffffffc0200054:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200056:	0f6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", (uintptr_t)kern_init);
ffffffffc020005a:	00000597          	auipc	a1,0x0
ffffffffc020005e:	07e58593          	addi	a1,a1,126 # ffffffffc02000d8 <kern_init>
ffffffffc0200062:	00002517          	auipc	a0,0x2
ffffffffc0200066:	d5e50513          	addi	a0,a0,-674 # ffffffffc0201dc0 <etext+0x24>
ffffffffc020006a:	0e2000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020006e:	00002597          	auipc	a1,0x2
ffffffffc0200072:	d2e58593          	addi	a1,a1,-722 # ffffffffc0201d9c <etext>
ffffffffc0200076:	00002517          	auipc	a0,0x2
ffffffffc020007a:	d6a50513          	addi	a0,a0,-662 # ffffffffc0201de0 <etext+0x44>
ffffffffc020007e:	0ce000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200082:	00006597          	auipc	a1,0x6
ffffffffc0200086:	f9658593          	addi	a1,a1,-106 # ffffffffc0206018 <free_area>
ffffffffc020008a:	00002517          	auipc	a0,0x2
ffffffffc020008e:	d7650513          	addi	a0,a0,-650 # ffffffffc0201e00 <etext+0x64>
ffffffffc0200092:	0ba000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200096:	00006597          	auipc	a1,0x6
ffffffffc020009a:	47a58593          	addi	a1,a1,1146 # ffffffffc0206510 <end>
ffffffffc020009e:	00002517          	auipc	a0,0x2
ffffffffc02000a2:	d8250513          	addi	a0,a0,-638 # ffffffffc0201e20 <etext+0x84>
ffffffffc02000a6:	0a6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - (char*)kern_init + 1023) / 1024);
ffffffffc02000aa:	00007597          	auipc	a1,0x7
ffffffffc02000ae:	86558593          	addi	a1,a1,-1947 # ffffffffc020690f <end+0x3ff>
ffffffffc02000b2:	00000797          	auipc	a5,0x0
ffffffffc02000b6:	02678793          	addi	a5,a5,38 # ffffffffc02000d8 <kern_init>
ffffffffc02000ba:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000be:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02000c2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000c4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02000c8:	95be                	add	a1,a1,a5
ffffffffc02000ca:	85a9                	srai	a1,a1,0xa
ffffffffc02000cc:	00002517          	auipc	a0,0x2
ffffffffc02000d0:	d7450513          	addi	a0,a0,-652 # ffffffffc0201e40 <etext+0xa4>
}
ffffffffc02000d4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000d6:	a89d                	j	ffffffffc020014c <cprintf>

ffffffffc02000d8 <kern_init>:

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc02000d8:	00006517          	auipc	a0,0x6
ffffffffc02000dc:	f4050513          	addi	a0,a0,-192 # ffffffffc0206018 <free_area>
ffffffffc02000e0:	00006617          	auipc	a2,0x6
ffffffffc02000e4:	43060613          	addi	a2,a2,1072 # ffffffffc0206510 <end>
int kern_init(void) {
ffffffffc02000e8:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc02000ea:	8e09                	sub	a2,a2,a0
ffffffffc02000ec:	4581                	li	a1,0
int kern_init(void) {
ffffffffc02000ee:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc02000f0:	49b010ef          	jal	ra,ffffffffc0201d8a <memset>
    dtb_init();
ffffffffc02000f4:	12c000ef          	jal	ra,ffffffffc0200220 <dtb_init>
    cons_init();  // init the console
ffffffffc02000f8:	11e000ef          	jal	ra,ffffffffc0200216 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc02000fc:	00002517          	auipc	a0,0x2
ffffffffc0200100:	d7450513          	addi	a0,a0,-652 # ffffffffc0201e70 <etext+0xd4>
ffffffffc0200104:	07e000ef          	jal	ra,ffffffffc0200182 <cputs>

    print_kerninfo();
ffffffffc0200108:	f43ff0ef          	jal	ra,ffffffffc020004a <print_kerninfo>

    // grade_backtrace();
    pmm_init();  // init physical memory management
ffffffffc020010c:	0d1000ef          	jal	ra,ffffffffc02009dc <pmm_init>

    /* do nothing */
    while (1)
ffffffffc0200110:	a001                	j	ffffffffc0200110 <kern_init+0x38>

ffffffffc0200112 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200112:	1141                	addi	sp,sp,-16
ffffffffc0200114:	e022                	sd	s0,0(sp)
ffffffffc0200116:	e406                	sd	ra,8(sp)
ffffffffc0200118:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020011a:	0fe000ef          	jal	ra,ffffffffc0200218 <cons_putc>
    (*cnt) ++;
ffffffffc020011e:	401c                	lw	a5,0(s0)
}
ffffffffc0200120:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200122:	2785                	addiw	a5,a5,1
ffffffffc0200124:	c01c                	sw	a5,0(s0)
}
ffffffffc0200126:	6402                	ld	s0,0(sp)
ffffffffc0200128:	0141                	addi	sp,sp,16
ffffffffc020012a:	8082                	ret

ffffffffc020012c <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020012c:	1101                	addi	sp,sp,-32
ffffffffc020012e:	862a                	mv	a2,a0
ffffffffc0200130:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200132:	00000517          	auipc	a0,0x0
ffffffffc0200136:	fe050513          	addi	a0,a0,-32 # ffffffffc0200112 <cputch>
ffffffffc020013a:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc020013c:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc020013e:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200140:	7ee010ef          	jal	ra,ffffffffc020192e <vprintfmt>
    return cnt;
}
ffffffffc0200144:	60e2                	ld	ra,24(sp)
ffffffffc0200146:	4532                	lw	a0,12(sp)
ffffffffc0200148:	6105                	addi	sp,sp,32
ffffffffc020014a:	8082                	ret

ffffffffc020014c <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc020014c:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc020014e:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200152:	8e2a                	mv	t3,a0
ffffffffc0200154:	f42e                	sd	a1,40(sp)
ffffffffc0200156:	f832                	sd	a2,48(sp)
ffffffffc0200158:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020015a:	00000517          	auipc	a0,0x0
ffffffffc020015e:	fb850513          	addi	a0,a0,-72 # ffffffffc0200112 <cputch>
ffffffffc0200162:	004c                	addi	a1,sp,4
ffffffffc0200164:	869a                	mv	a3,t1
ffffffffc0200166:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc0200168:	ec06                	sd	ra,24(sp)
ffffffffc020016a:	e0ba                	sd	a4,64(sp)
ffffffffc020016c:	e4be                	sd	a5,72(sp)
ffffffffc020016e:	e8c2                	sd	a6,80(sp)
ffffffffc0200170:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc0200172:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc0200174:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200176:	7b8010ef          	jal	ra,ffffffffc020192e <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc020017a:	60e2                	ld	ra,24(sp)
ffffffffc020017c:	4512                	lw	a0,4(sp)
ffffffffc020017e:	6125                	addi	sp,sp,96
ffffffffc0200180:	8082                	ret

ffffffffc0200182 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200182:	1101                	addi	sp,sp,-32
ffffffffc0200184:	e822                	sd	s0,16(sp)
ffffffffc0200186:	ec06                	sd	ra,24(sp)
ffffffffc0200188:	e426                	sd	s1,8(sp)
ffffffffc020018a:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc020018c:	00054503          	lbu	a0,0(a0)
ffffffffc0200190:	c51d                	beqz	a0,ffffffffc02001be <cputs+0x3c>
ffffffffc0200192:	0405                	addi	s0,s0,1
ffffffffc0200194:	4485                	li	s1,1
ffffffffc0200196:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200198:	080000ef          	jal	ra,ffffffffc0200218 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020019c:	00044503          	lbu	a0,0(s0)
ffffffffc02001a0:	008487bb          	addw	a5,s1,s0
ffffffffc02001a4:	0405                	addi	s0,s0,1
ffffffffc02001a6:	f96d                	bnez	a0,ffffffffc0200198 <cputs+0x16>
    (*cnt) ++;
ffffffffc02001a8:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001ac:	4529                	li	a0,10
ffffffffc02001ae:	06a000ef          	jal	ra,ffffffffc0200218 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001b2:	60e2                	ld	ra,24(sp)
ffffffffc02001b4:	8522                	mv	a0,s0
ffffffffc02001b6:	6442                	ld	s0,16(sp)
ffffffffc02001b8:	64a2                	ld	s1,8(sp)
ffffffffc02001ba:	6105                	addi	sp,sp,32
ffffffffc02001bc:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc02001be:	4405                	li	s0,1
ffffffffc02001c0:	b7f5                	j	ffffffffc02001ac <cputs+0x2a>

ffffffffc02001c2 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001c2:	00006317          	auipc	t1,0x6
ffffffffc02001c6:	2fe30313          	addi	t1,t1,766 # ffffffffc02064c0 <is_panic>
ffffffffc02001ca:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001ce:	715d                	addi	sp,sp,-80
ffffffffc02001d0:	ec06                	sd	ra,24(sp)
ffffffffc02001d2:	e822                	sd	s0,16(sp)
ffffffffc02001d4:	f436                	sd	a3,40(sp)
ffffffffc02001d6:	f83a                	sd	a4,48(sp)
ffffffffc02001d8:	fc3e                	sd	a5,56(sp)
ffffffffc02001da:	e0c2                	sd	a6,64(sp)
ffffffffc02001dc:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001de:	000e0363          	beqz	t3,ffffffffc02001e4 <__panic+0x22>
    vcprintf(fmt, ap);
    cprintf("\n");
    va_end(ap);

panic_dead:
    while (1) {
ffffffffc02001e2:	a001                	j	ffffffffc02001e2 <__panic+0x20>
    is_panic = 1;
ffffffffc02001e4:	4785                	li	a5,1
ffffffffc02001e6:	00f32023          	sw	a5,0(t1)
    va_start(ap, fmt);
ffffffffc02001ea:	8432                	mv	s0,a2
ffffffffc02001ec:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001ee:	862e                	mv	a2,a1
ffffffffc02001f0:	85aa                	mv	a1,a0
ffffffffc02001f2:	00002517          	auipc	a0,0x2
ffffffffc02001f6:	c9e50513          	addi	a0,a0,-866 # ffffffffc0201e90 <etext+0xf4>
    va_start(ap, fmt);
ffffffffc02001fa:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001fc:	f51ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200200:	65a2                	ld	a1,8(sp)
ffffffffc0200202:	8522                	mv	a0,s0
ffffffffc0200204:	f29ff0ef          	jal	ra,ffffffffc020012c <vcprintf>
    cprintf("\n");
ffffffffc0200208:	00002517          	auipc	a0,0x2
ffffffffc020020c:	1d850513          	addi	a0,a0,472 # ffffffffc02023e0 <buddy_pmm_manager+0x328>
ffffffffc0200210:	f3dff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200214:	b7f9                	j	ffffffffc02001e2 <__panic+0x20>

ffffffffc0200216 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200216:	8082                	ret

ffffffffc0200218 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200218:	0ff57513          	zext.b	a0,a0
ffffffffc020021c:	2db0106f          	j	ffffffffc0201cf6 <sbi_console_putchar>

ffffffffc0200220 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc0200220:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc0200222:	00002517          	auipc	a0,0x2
ffffffffc0200226:	c8e50513          	addi	a0,a0,-882 # ffffffffc0201eb0 <etext+0x114>
void dtb_init(void) {
ffffffffc020022a:	fc86                	sd	ra,120(sp)
ffffffffc020022c:	f8a2                	sd	s0,112(sp)
ffffffffc020022e:	e8d2                	sd	s4,80(sp)
ffffffffc0200230:	f4a6                	sd	s1,104(sp)
ffffffffc0200232:	f0ca                	sd	s2,96(sp)
ffffffffc0200234:	ecce                	sd	s3,88(sp)
ffffffffc0200236:	e4d6                	sd	s5,72(sp)
ffffffffc0200238:	e0da                	sd	s6,64(sp)
ffffffffc020023a:	fc5e                	sd	s7,56(sp)
ffffffffc020023c:	f862                	sd	s8,48(sp)
ffffffffc020023e:	f466                	sd	s9,40(sp)
ffffffffc0200240:	f06a                	sd	s10,32(sp)
ffffffffc0200242:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc0200244:	f09ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200248:	00006597          	auipc	a1,0x6
ffffffffc020024c:	db85b583          	ld	a1,-584(a1) # ffffffffc0206000 <boot_hartid>
ffffffffc0200250:	00002517          	auipc	a0,0x2
ffffffffc0200254:	c7050513          	addi	a0,a0,-912 # ffffffffc0201ec0 <etext+0x124>
ffffffffc0200258:	ef5ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020025c:	00006417          	auipc	s0,0x6
ffffffffc0200260:	dac40413          	addi	s0,s0,-596 # ffffffffc0206008 <boot_dtb>
ffffffffc0200264:	600c                	ld	a1,0(s0)
ffffffffc0200266:	00002517          	auipc	a0,0x2
ffffffffc020026a:	c6a50513          	addi	a0,a0,-918 # ffffffffc0201ed0 <etext+0x134>
ffffffffc020026e:	edfff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200272:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200276:	00002517          	auipc	a0,0x2
ffffffffc020027a:	c7250513          	addi	a0,a0,-910 # ffffffffc0201ee8 <etext+0x14c>
    if (boot_dtb == 0) {
ffffffffc020027e:	120a0463          	beqz	s4,ffffffffc02003a6 <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200282:	57f5                	li	a5,-3
ffffffffc0200284:	07fa                	slli	a5,a5,0x1e
ffffffffc0200286:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc020028a:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020028c:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200290:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200292:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200296:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020029a:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020029e:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002a2:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002a6:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002a8:	8ec9                	or	a3,a3,a0
ffffffffc02002aa:	0087979b          	slliw	a5,a5,0x8
ffffffffc02002ae:	1b7d                	addi	s6,s6,-1
ffffffffc02002b0:	0167f7b3          	and	a5,a5,s6
ffffffffc02002b4:	8dd5                	or	a1,a1,a3
ffffffffc02002b6:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc02002b8:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002bc:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc02002be:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfed99dd>
ffffffffc02002c2:	10f59163          	bne	a1,a5,ffffffffc02003c4 <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc02002c6:	471c                	lw	a5,8(a4)
ffffffffc02002c8:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc02002ca:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002cc:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02002d0:	0086d51b          	srliw	a0,a3,0x8
ffffffffc02002d4:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002d8:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002dc:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002e0:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002e4:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002e8:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002ec:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002f0:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002f4:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002f6:	01146433          	or	s0,s0,a7
ffffffffc02002fa:	0086969b          	slliw	a3,a3,0x8
ffffffffc02002fe:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200302:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200304:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200308:	8c49                	or	s0,s0,a0
ffffffffc020030a:	0166f6b3          	and	a3,a3,s6
ffffffffc020030e:	00ca6a33          	or	s4,s4,a2
ffffffffc0200312:	0167f7b3          	and	a5,a5,s6
ffffffffc0200316:	8c55                	or	s0,s0,a3
ffffffffc0200318:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020031c:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020031e:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200320:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200322:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200326:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200328:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020032a:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc020032e:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200330:	00002917          	auipc	s2,0x2
ffffffffc0200334:	c0890913          	addi	s2,s2,-1016 # ffffffffc0201f38 <etext+0x19c>
ffffffffc0200338:	49bd                	li	s3,15
        switch (token) {
ffffffffc020033a:	4d91                	li	s11,4
ffffffffc020033c:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020033e:	00002497          	auipc	s1,0x2
ffffffffc0200342:	bf248493          	addi	s1,s1,-1038 # ffffffffc0201f30 <etext+0x194>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200346:	000a2703          	lw	a4,0(s4)
ffffffffc020034a:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020034e:	0087569b          	srliw	a3,a4,0x8
ffffffffc0200352:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200356:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020035a:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020035e:	0107571b          	srliw	a4,a4,0x10
ffffffffc0200362:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200364:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200368:	0087171b          	slliw	a4,a4,0x8
ffffffffc020036c:	8fd5                	or	a5,a5,a3
ffffffffc020036e:	00eb7733          	and	a4,s6,a4
ffffffffc0200372:	8fd9                	or	a5,a5,a4
ffffffffc0200374:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc0200376:	09778c63          	beq	a5,s7,ffffffffc020040e <dtb_init+0x1ee>
ffffffffc020037a:	00fbea63          	bltu	s7,a5,ffffffffc020038e <dtb_init+0x16e>
ffffffffc020037e:	07a78663          	beq	a5,s10,ffffffffc02003ea <dtb_init+0x1ca>
ffffffffc0200382:	4709                	li	a4,2
ffffffffc0200384:	00e79763          	bne	a5,a4,ffffffffc0200392 <dtb_init+0x172>
ffffffffc0200388:	4c81                	li	s9,0
ffffffffc020038a:	8a56                	mv	s4,s5
ffffffffc020038c:	bf6d                	j	ffffffffc0200346 <dtb_init+0x126>
ffffffffc020038e:	ffb78ee3          	beq	a5,s11,ffffffffc020038a <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc0200392:	00002517          	auipc	a0,0x2
ffffffffc0200396:	c1e50513          	addi	a0,a0,-994 # ffffffffc0201fb0 <etext+0x214>
ffffffffc020039a:	db3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	c4a50513          	addi	a0,a0,-950 # ffffffffc0201fe8 <etext+0x24c>
}
ffffffffc02003a6:	7446                	ld	s0,112(sp)
ffffffffc02003a8:	70e6                	ld	ra,120(sp)
ffffffffc02003aa:	74a6                	ld	s1,104(sp)
ffffffffc02003ac:	7906                	ld	s2,96(sp)
ffffffffc02003ae:	69e6                	ld	s3,88(sp)
ffffffffc02003b0:	6a46                	ld	s4,80(sp)
ffffffffc02003b2:	6aa6                	ld	s5,72(sp)
ffffffffc02003b4:	6b06                	ld	s6,64(sp)
ffffffffc02003b6:	7be2                	ld	s7,56(sp)
ffffffffc02003b8:	7c42                	ld	s8,48(sp)
ffffffffc02003ba:	7ca2                	ld	s9,40(sp)
ffffffffc02003bc:	7d02                	ld	s10,32(sp)
ffffffffc02003be:	6de2                	ld	s11,24(sp)
ffffffffc02003c0:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc02003c2:	b369                	j	ffffffffc020014c <cprintf>
}
ffffffffc02003c4:	7446                	ld	s0,112(sp)
ffffffffc02003c6:	70e6                	ld	ra,120(sp)
ffffffffc02003c8:	74a6                	ld	s1,104(sp)
ffffffffc02003ca:	7906                	ld	s2,96(sp)
ffffffffc02003cc:	69e6                	ld	s3,88(sp)
ffffffffc02003ce:	6a46                	ld	s4,80(sp)
ffffffffc02003d0:	6aa6                	ld	s5,72(sp)
ffffffffc02003d2:	6b06                	ld	s6,64(sp)
ffffffffc02003d4:	7be2                	ld	s7,56(sp)
ffffffffc02003d6:	7c42                	ld	s8,48(sp)
ffffffffc02003d8:	7ca2                	ld	s9,40(sp)
ffffffffc02003da:	7d02                	ld	s10,32(sp)
ffffffffc02003dc:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003de:	00002517          	auipc	a0,0x2
ffffffffc02003e2:	b2a50513          	addi	a0,a0,-1238 # ffffffffc0201f08 <etext+0x16c>
}
ffffffffc02003e6:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003e8:	b395                	j	ffffffffc020014c <cprintf>
                int name_len = strlen(name);
ffffffffc02003ea:	8556                	mv	a0,s5
ffffffffc02003ec:	125010ef          	jal	ra,ffffffffc0201d10 <strlen>
ffffffffc02003f0:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003f2:	4619                	li	a2,6
ffffffffc02003f4:	85a6                	mv	a1,s1
ffffffffc02003f6:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02003f8:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003fa:	16b010ef          	jal	ra,ffffffffc0201d64 <strncmp>
ffffffffc02003fe:	e111                	bnez	a0,ffffffffc0200402 <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc0200400:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc0200402:	0a91                	addi	s5,s5,4
ffffffffc0200404:	9ad2                	add	s5,s5,s4
ffffffffc0200406:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc020040a:	8a56                	mv	s4,s5
ffffffffc020040c:	bf2d                	j	ffffffffc0200346 <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc020040e:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200412:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200416:	0087d71b          	srliw	a4,a5,0x8
ffffffffc020041a:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020041e:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200422:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200426:	0107d79b          	srliw	a5,a5,0x10
ffffffffc020042a:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020042e:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200432:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200436:	00eaeab3          	or	s5,s5,a4
ffffffffc020043a:	00fb77b3          	and	a5,s6,a5
ffffffffc020043e:	00faeab3          	or	s5,s5,a5
ffffffffc0200442:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200444:	000c9c63          	bnez	s9,ffffffffc020045c <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc0200448:	1a82                	slli	s5,s5,0x20
ffffffffc020044a:	00368793          	addi	a5,a3,3
ffffffffc020044e:	020ada93          	srli	s5,s5,0x20
ffffffffc0200452:	9abe                	add	s5,s5,a5
ffffffffc0200454:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc0200458:	8a56                	mv	s4,s5
ffffffffc020045a:	b5f5                	j	ffffffffc0200346 <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc020045c:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200460:	85ca                	mv	a1,s2
ffffffffc0200462:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200464:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200468:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020046c:	0187971b          	slliw	a4,a5,0x18
ffffffffc0200470:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200474:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200478:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020047a:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020047e:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200482:	8d59                	or	a0,a0,a4
ffffffffc0200484:	00fb77b3          	and	a5,s6,a5
ffffffffc0200488:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc020048a:	1502                	slli	a0,a0,0x20
ffffffffc020048c:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020048e:	9522                	add	a0,a0,s0
ffffffffc0200490:	0b7010ef          	jal	ra,ffffffffc0201d46 <strcmp>
ffffffffc0200494:	66a2                	ld	a3,8(sp)
ffffffffc0200496:	f94d                	bnez	a0,ffffffffc0200448 <dtb_init+0x228>
ffffffffc0200498:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200448 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc020049c:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc02004a0:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc02004a4:	00002517          	auipc	a0,0x2
ffffffffc02004a8:	a9c50513          	addi	a0,a0,-1380 # ffffffffc0201f40 <etext+0x1a4>
           fdt32_to_cpu(x >> 32);
ffffffffc02004ac:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004b0:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc02004b4:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004b8:	0187de1b          	srliw	t3,a5,0x18
ffffffffc02004bc:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004c0:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004c4:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004c8:	0187d693          	srli	a3,a5,0x18
ffffffffc02004cc:	01861f1b          	slliw	t5,a2,0x18
ffffffffc02004d0:	0087579b          	srliw	a5,a4,0x8
ffffffffc02004d4:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004d8:	0106561b          	srliw	a2,a2,0x10
ffffffffc02004dc:	010f6f33          	or	t5,t5,a6
ffffffffc02004e0:	0187529b          	srliw	t0,a4,0x18
ffffffffc02004e4:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004e8:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004ec:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004f0:	0186f6b3          	and	a3,a3,s8
ffffffffc02004f4:	01859e1b          	slliw	t3,a1,0x18
ffffffffc02004f8:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004fc:	0107581b          	srliw	a6,a4,0x10
ffffffffc0200500:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200504:	8361                	srli	a4,a4,0x18
ffffffffc0200506:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020050a:	0105d59b          	srliw	a1,a1,0x10
ffffffffc020050e:	01e6e6b3          	or	a3,a3,t5
ffffffffc0200512:	00cb7633          	and	a2,s6,a2
ffffffffc0200516:	0088181b          	slliw	a6,a6,0x8
ffffffffc020051a:	0085959b          	slliw	a1,a1,0x8
ffffffffc020051e:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200522:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200526:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020052a:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020052e:	0088989b          	slliw	a7,a7,0x8
ffffffffc0200532:	011b78b3          	and	a7,s6,a7
ffffffffc0200536:	005eeeb3          	or	t4,t4,t0
ffffffffc020053a:	00c6e733          	or	a4,a3,a2
ffffffffc020053e:	006c6c33          	or	s8,s8,t1
ffffffffc0200542:	010b76b3          	and	a3,s6,a6
ffffffffc0200546:	00bb7b33          	and	s6,s6,a1
ffffffffc020054a:	01d7e7b3          	or	a5,a5,t4
ffffffffc020054e:	016c6b33          	or	s6,s8,s6
ffffffffc0200552:	01146433          	or	s0,s0,a7
ffffffffc0200556:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc0200558:	1702                	slli	a4,a4,0x20
ffffffffc020055a:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020055c:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc020055e:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200560:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200562:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200566:	0167eb33          	or	s6,a5,s6
ffffffffc020056a:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc020056c:	be1ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc0200570:	85a2                	mv	a1,s0
ffffffffc0200572:	00002517          	auipc	a0,0x2
ffffffffc0200576:	9ee50513          	addi	a0,a0,-1554 # ffffffffc0201f60 <etext+0x1c4>
ffffffffc020057a:	bd3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020057e:	014b5613          	srli	a2,s6,0x14
ffffffffc0200582:	85da                	mv	a1,s6
ffffffffc0200584:	00002517          	auipc	a0,0x2
ffffffffc0200588:	9f450513          	addi	a0,a0,-1548 # ffffffffc0201f78 <etext+0x1dc>
ffffffffc020058c:	bc1ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200590:	008b05b3          	add	a1,s6,s0
ffffffffc0200594:	15fd                	addi	a1,a1,-1
ffffffffc0200596:	00002517          	auipc	a0,0x2
ffffffffc020059a:	a0250513          	addi	a0,a0,-1534 # ffffffffc0201f98 <etext+0x1fc>
ffffffffc020059e:	bafff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB init completed\n");
ffffffffc02005a2:	00002517          	auipc	a0,0x2
ffffffffc02005a6:	a4650513          	addi	a0,a0,-1466 # ffffffffc0201fe8 <etext+0x24c>
        memory_base = mem_base;
ffffffffc02005aa:	00006797          	auipc	a5,0x6
ffffffffc02005ae:	f087bf23          	sd	s0,-226(a5) # ffffffffc02064c8 <memory_base>
        memory_size = mem_size;
ffffffffc02005b2:	00006797          	auipc	a5,0x6
ffffffffc02005b6:	f167bf23          	sd	s6,-226(a5) # ffffffffc02064d0 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc02005ba:	b3f5                	j	ffffffffc02003a6 <dtb_init+0x186>

ffffffffc02005bc <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02005bc:	00006517          	auipc	a0,0x6
ffffffffc02005c0:	f0c53503          	ld	a0,-244(a0) # ffffffffc02064c8 <memory_base>
ffffffffc02005c4:	8082                	ret

ffffffffc02005c6 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
ffffffffc02005c6:	00006517          	auipc	a0,0x6
ffffffffc02005ca:	f0a53503          	ld	a0,-246(a0) # ffffffffc02064d0 <memory_size>
ffffffffc02005ce:	8082                	ret

ffffffffc02005d0 <buddy_init>:
    return order;
}

// 初始化伙伴系统
static void buddy_init(void) {
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc02005d0:	00006797          	auipc	a5,0x6
ffffffffc02005d4:	a4878793          	addi	a5,a5,-1464 # ffffffffc0206018 <free_area>
ffffffffc02005d8:	00006717          	auipc	a4,0x6
ffffffffc02005dc:	ba870713          	addi	a4,a4,-1112 # ffffffffc0206180 <kmem_caches>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02005e0:	e79c                	sd	a5,8(a5)
ffffffffc02005e2:	e39c                	sd	a5,0(a5)
        list_init(&(free_area[i].free_list));
        free_area[i].nr_free = 0;
ffffffffc02005e4:	0007a823          	sw	zero,16(a5)
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc02005e8:	07e1                	addi	a5,a5,24
ffffffffc02005ea:	fee79be3          	bne	a5,a4,ffffffffc02005e0 <buddy_init+0x10>
    }
    nr_free = 0;
ffffffffc02005ee:	00006797          	auipc	a5,0x6
ffffffffc02005f2:	ee07b523          	sd	zero,-278(a5) # ffffffffc02064d8 <nr_free>
}
ffffffffc02005f6:	8082                	ret

ffffffffc02005f8 <buddy_alloc_pages>:
    }
}

// 分配页面
static struct Page *buddy_alloc_pages(size_t n) {
    if (n == 0) return NULL;
ffffffffc02005f8:	cd61                	beqz	a0,ffffffffc02006d0 <buddy_alloc_pages+0xd8>
    if (n > nr_free) return NULL;
ffffffffc02005fa:	00006f17          	auipc	t5,0x6
ffffffffc02005fe:	edef0f13          	addi	t5,t5,-290 # ffffffffc02064d8 <nr_free>
ffffffffc0200602:	000f3e83          	ld	t4,0(t5)
ffffffffc0200606:	0caee563          	bltu	t4,a0,ffffffffc02006d0 <buddy_alloc_pages+0xd8>
    while ((1 << order) < n) {
ffffffffc020060a:	4785                	li	a5,1
ffffffffc020060c:	0cf50463          	beq	a0,a5,ffffffffc02006d4 <buddy_alloc_pages+0xdc>
    uint32_t order = 0;
ffffffffc0200610:	4601                	li	a2,0
        order++;
ffffffffc0200612:	2605                	addiw	a2,a2,1
    while ((1 << order) < n) {
ffffffffc0200614:	00c79e3b          	sllw	t3,a5,a2
ffffffffc0200618:	feae6de3          	bltu	t3,a0,ffffffffc0200612 <buddy_alloc_pages+0x1a>
    // 计算所需最小阶数
    uint32_t order = get_order(n);
    uint32_t current_order;

    // 从所需阶数开始，向上查找可用的更大块
    for (current_order = order; current_order < MAX_ORDER; current_order++) {
ffffffffc020061c:	47b9                	li	a5,14
ffffffffc020061e:	0ac7ee63          	bltu	a5,a2,ffffffffc02006da <buddy_alloc_pages+0xe2>
    uint32_t order = 0;
ffffffffc0200622:	87b2                	mv	a5,a2
ffffffffc0200624:	00006697          	auipc	a3,0x6
ffffffffc0200628:	9f468693          	addi	a3,a3,-1548 # ffffffffc0206018 <free_area>
    for (current_order = order; current_order < MAX_ORDER; current_order++) {
ffffffffc020062c:	453d                	li	a0,15
ffffffffc020062e:	a021                	j	ffffffffc0200636 <buddy_alloc_pages+0x3e>
ffffffffc0200630:	2785                	addiw	a5,a5,1
ffffffffc0200632:	08a78f63          	beq	a5,a0,ffffffffc02006d0 <buddy_alloc_pages+0xd8>
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
ffffffffc0200636:	02079593          	slli	a1,a5,0x20
ffffffffc020063a:	9181                	srli	a1,a1,0x20
ffffffffc020063c:	00159713          	slli	a4,a1,0x1
ffffffffc0200640:	972e                	add	a4,a4,a1
ffffffffc0200642:	070e                	slli	a4,a4,0x3
ffffffffc0200644:	9736                	add	a4,a4,a3
ffffffffc0200646:	00873803          	ld	a6,8(a4)
        if (!list_empty(&(free_area[current_order].free_list))) {
ffffffffc020064a:	fee803e3          	beq	a6,a4,ffffffffc0200630 <buddy_alloc_pages+0x38>
    __list_del(listelm->prev, listelm->next);
ffffffffc020064e:	00083303          	ld	t1,0(a6)
ffffffffc0200652:	00883883          	ld	a7,8(a6)

    // 从找到的空闲链表中取出一个块
    list_entry_t *le = list_next(&(free_area[current_order].free_list));
    struct Page *page = le2page(le, page_link);
    list_del(le);
    free_area[current_order].nr_free--;
ffffffffc0200656:	4b0c                	lw	a1,16(a4)
    struct Page *page = le2page(le, page_link);
ffffffffc0200658:	fe880513          	addi	a0,a6,-24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020065c:	01133423          	sd	a7,8(t1)
    next->prev = prev;
ffffffffc0200660:	0068b023          	sd	t1,0(a7)
    free_area[current_order].nr_free--;
ffffffffc0200664:	35fd                	addiw	a1,a1,-1
ffffffffc0200666:	cb0c                	sw	a1,16(a4)

    // 如果找到的块比需要的大，则进行切分
    while (current_order > order) {
ffffffffc0200668:	04f67863          	bgeu	a2,a5,ffffffffc02006b8 <buddy_alloc_pages+0xc0>
ffffffffc020066c:	37fd                	addiw	a5,a5,-1
ffffffffc020066e:	02079593          	slli	a1,a5,0x20
ffffffffc0200672:	9181                	srli	a1,a1,0x20
ffffffffc0200674:	00159713          	slli	a4,a1,0x1
ffffffffc0200678:	972e                	add	a4,a4,a1
ffffffffc020067a:	070e                	slli	a4,a4,0x3
ffffffffc020067c:	96ba                	add	a3,a3,a4
        current_order--;
        // 切分后的另一半（伙伴）
        struct Page *buddy = page + (1 << current_order);
ffffffffc020067e:	4f85                	li	t6,1
ffffffffc0200680:	a011                	j	ffffffffc0200684 <buddy_alloc_pages+0x8c>
ffffffffc0200682:	37fd                	addiw	a5,a5,-1
ffffffffc0200684:	00ff95bb          	sllw	a1,t6,a5
ffffffffc0200688:	00259713          	slli	a4,a1,0x2
ffffffffc020068c:	972e                	add	a4,a4,a1
ffffffffc020068e:	070e                	slli	a4,a4,0x3
    __list_add(elm, listelm, listelm->next);
ffffffffc0200690:	0086b883          	ld	a7,8(a3)
ffffffffc0200694:	972a                	add	a4,a4,a0
        buddy->property = current_order; // 记录伙伴的阶数
ffffffffc0200696:	cb1c                	sw	a5,16(a4)
        list_add(&(free_area[current_order].free_list), &(buddy->page_link));
        free_area[current_order].nr_free++;
ffffffffc0200698:	4a8c                	lw	a1,16(a3)
        list_add(&(free_area[current_order].free_list), &(buddy->page_link));
ffffffffc020069a:	01870313          	addi	t1,a4,24
    prev->next = next->prev = elm;
ffffffffc020069e:	0068b023          	sd	t1,0(a7)
ffffffffc02006a2:	0066b423          	sd	t1,8(a3)
    elm->prev = prev;
ffffffffc02006a6:	ef14                	sd	a3,24(a4)
    elm->next = next;
ffffffffc02006a8:	03173023          	sd	a7,32(a4)
        free_area[current_order].nr_free++;
ffffffffc02006ac:	0015871b          	addiw	a4,a1,1
ffffffffc02006b0:	ca98                	sw	a4,16(a3)
    while (current_order > order) {
ffffffffc02006b2:	16a1                	addi	a3,a3,-24
ffffffffc02006b4:	fcf617e3          	bne	a2,a5,ffffffffc0200682 <buddy_alloc_pages+0x8a>
    }

    // 标记分配出去的块为非空闲，并记录其阶数
    ClearPageProperty(page); 
ffffffffc02006b8:	ff083783          	ld	a5,-16(a6)
    page->property = order;
    nr_free -= (1 << order);
ffffffffc02006bc:	41ce8e33          	sub	t3,t4,t3
    page->property = order;
ffffffffc02006c0:	fec82c23          	sw	a2,-8(a6)
    ClearPageProperty(page); 
ffffffffc02006c4:	9bf5                	andi	a5,a5,-3
ffffffffc02006c6:	fef83823          	sd	a5,-16(a6)
    nr_free -= (1 << order);
ffffffffc02006ca:	01cf3023          	sd	t3,0(t5)
    
    return page;
ffffffffc02006ce:	8082                	ret
    if (n == 0) return NULL;
ffffffffc02006d0:	4501                	li	a0,0
}
ffffffffc02006d2:	8082                	ret
    while ((1 << order) < n) {
ffffffffc02006d4:	4e05                	li	t3,1
    uint32_t order = 0;
ffffffffc02006d6:	4601                	li	a2,0
ffffffffc02006d8:	b7a9                	j	ffffffffc0200622 <buddy_alloc_pages+0x2a>
    if (current_order == MAX_ORDER) { // 没找到
ffffffffc02006da:	47bd                	li	a5,15
ffffffffc02006dc:	fef60ae3          	beq	a2,a5,ffffffffc02006d0 <buddy_alloc_pages+0xd8>
    return listelm->next;
ffffffffc02006e0:	02061713          	slli	a4,a2,0x20
ffffffffc02006e4:	9301                	srli	a4,a4,0x20
ffffffffc02006e6:	00171793          	slli	a5,a4,0x1
ffffffffc02006ea:	97ba                	add	a5,a5,a4
ffffffffc02006ec:	00379713          	slli	a4,a5,0x3
ffffffffc02006f0:	00006797          	auipc	a5,0x6
ffffffffc02006f4:	92878793          	addi	a5,a5,-1752 # ffffffffc0206018 <free_area>
ffffffffc02006f8:	97ba                	add	a5,a5,a4
ffffffffc02006fa:	0087b803          	ld	a6,8(a5)
    free_area[current_order].nr_free--;
ffffffffc02006fe:	4b98                	lw	a4,16(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200700:	00083583          	ld	a1,0(a6)
ffffffffc0200704:	00883683          	ld	a3,8(a6)
ffffffffc0200708:	377d                	addiw	a4,a4,-1
    struct Page *page = le2page(le, page_link);
ffffffffc020070a:	fe880513          	addi	a0,a6,-24
    prev->next = next;
ffffffffc020070e:	e594                	sd	a3,8(a1)
    next->prev = prev;
ffffffffc0200710:	e28c                	sd	a1,0(a3)
    free_area[current_order].nr_free--;
ffffffffc0200712:	cb98                	sw	a4,16(a5)
    while (current_order > order) {
ffffffffc0200714:	b755                	j	ffffffffc02006b8 <buddy_alloc_pages+0xc0>

ffffffffc0200716 <buddy_nr_free_pages>:
    nr_free += (1 << order);
}

static size_t buddy_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200716:	00006517          	auipc	a0,0x6
ffffffffc020071a:	dc253503          	ld	a0,-574(a0) # ffffffffc02064d8 <nr_free>
ffffffffc020071e:	8082                	ret

ffffffffc0200720 <buddy_check>:

// 检查函数，用于测试
static void buddy_check(void) {
    //待添加
}
ffffffffc0200720:	8082                	ret

ffffffffc0200722 <buddy_free_pages>:
static void buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0200722:	1141                	addi	sp,sp,-16
ffffffffc0200724:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200726:	18058163          	beqz	a1,ffffffffc02008a8 <buddy_free_pages+0x186>
    while ((1 << order) < n) {
ffffffffc020072a:	4705                	li	a4,1
    uint32_t order = 0;
ffffffffc020072c:	4681                	li	a3,0
    while ((1 << order) < n) {
ffffffffc020072e:	4785                	li	a5,1
ffffffffc0200730:	12e58d63          	beq	a1,a4,ffffffffc020086a <buddy_free_pages+0x148>
        order++;
ffffffffc0200734:	2685                	addiw	a3,a3,1
    while ((1 << order) < n) {
ffffffffc0200736:	00d7983b          	sllw	a6,a5,a3
ffffffffc020073a:	feb86de3          	bltu	a6,a1,ffffffffc0200734 <buddy_free_pages+0x12>
    for (; p != base + (1 << order); p++) {
ffffffffc020073e:	00281793          	slli	a5,a6,0x2
ffffffffc0200742:	97c2                	add	a5,a5,a6
ffffffffc0200744:	078e                	slli	a5,a5,0x3
ffffffffc0200746:	00f50633          	add	a2,a0,a5
ffffffffc020074a:	c38d                	beqz	a5,ffffffffc020076c <buddy_free_pages+0x4a>
    struct Page *p = base;
ffffffffc020074c:	87aa                	mv	a5,a0
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020074e:	6798                	ld	a4,8(a5)
ffffffffc0200750:	8b0d                	andi	a4,a4,3
ffffffffc0200752:	10071f63          	bnez	a4,ffffffffc0200870 <buddy_free_pages+0x14e>
        p->flags = 0;
ffffffffc0200756:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020075a:	0007a023          	sw	zero,0(a5)
    for (; p != base + (1 << order); p++) {
ffffffffc020075e:	02878793          	addi	a5,a5,40
ffffffffc0200762:	fec796e3          	bne	a5,a2,ffffffffc020074e <buddy_free_pages+0x2c>
        uintptr_t buddy_idx = page_idx ^ (1 << order);
ffffffffc0200766:	4805                	li	a6,1
ffffffffc0200768:	00d8183b          	sllw	a6,a6,a3
    while (order < MAX_ORDER -1) {
ffffffffc020076c:	47b5                	li	a5,13
ffffffffc020076e:	00006297          	auipc	t0,0x6
ffffffffc0200772:	8aa28293          	addi	t0,t0,-1878 # ffffffffc0206018 <free_area>
ffffffffc0200776:	0ad7e163          	bltu	a5,a3,ffffffffc0200818 <buddy_free_pages+0xf6>
ffffffffc020077a:	02069793          	slli	a5,a3,0x20
ffffffffc020077e:	9381                	srli	a5,a5,0x20
ffffffffc0200780:	00179613          	slli	a2,a5,0x1
ffffffffc0200784:	963e                	add	a2,a2,a5
ffffffffc0200786:	00006297          	auipc	t0,0x6
ffffffffc020078a:	89228293          	addi	t0,t0,-1902 # ffffffffc0206018 <free_area>
ffffffffc020078e:	060e                	slli	a2,a2,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200790:	00006317          	auipc	t1,0x6
ffffffffc0200794:	d5833303          	ld	t1,-680(t1) # ffffffffc02064e8 <pages>
ffffffffc0200798:	00002897          	auipc	a7,0x2
ffffffffc020079c:	2208b883          	ld	a7,544(a7) # ffffffffc02029b8 <nbase>
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02007a0:	00006f17          	auipc	t5,0x6
ffffffffc02007a4:	d40f3f03          	ld	t5,-704(t5) # ffffffffc02064e0 <npage>
ffffffffc02007a8:	9616                	add	a2,a2,t0
ffffffffc02007aa:	00002e97          	auipc	t4,0x2
ffffffffc02007ae:	206ebe83          	ld	t4,518(t4) # ffffffffc02029b0 <error_string+0x38>
        uintptr_t buddy_idx = page_idx ^ (1 << order);
ffffffffc02007b2:	4e05                	li	t3,1
    while (order < MAX_ORDER -1) {
ffffffffc02007b4:	4fb9                	li	t6,14
ffffffffc02007b6:	a805                	j	ffffffffc02007e6 <buddy_free_pages+0xc4>
        if (!PageProperty(buddy) || buddy->property != order) {
ffffffffc02007b8:	4b8c                	lw	a1,16(a5)
ffffffffc02007ba:	04d59f63          	bne	a1,a3,ffffffffc0200818 <buddy_free_pages+0xf6>
    __list_del(listelm->prev, listelm->next);
ffffffffc02007be:	0187b383          	ld	t2,24(a5)
ffffffffc02007c2:	0207b803          	ld	a6,32(a5)
        free_area[order].nr_free--;
ffffffffc02007c6:	4a0c                	lw	a1,16(a2)
        ClearPageProperty(buddy);
ffffffffc02007c8:	9b75                	andi	a4,a4,-3
    prev->next = next;
ffffffffc02007ca:	0103b423          	sd	a6,8(t2)
    next->prev = prev;
ffffffffc02007ce:	00783023          	sd	t2,0(a6)
        free_area[order].nr_free--;
ffffffffc02007d2:	35fd                	addiw	a1,a1,-1
ffffffffc02007d4:	ca0c                	sw	a1,16(a2)
        ClearPageProperty(buddy);
ffffffffc02007d6:	e798                	sd	a4,8(a5)
        if (buddy < base) {
ffffffffc02007d8:	00a7f363          	bgeu	a5,a0,ffffffffc02007de <buddy_free_pages+0xbc>
ffffffffc02007dc:	853e                	mv	a0,a5
        order++; // 阶数加一，继续向上尝试合并
ffffffffc02007de:	2685                	addiw	a3,a3,1
    while (order < MAX_ORDER -1) {
ffffffffc02007e0:	0661                	addi	a2,a2,24
ffffffffc02007e2:	09f68263          	beq	a3,t6,ffffffffc0200866 <buddy_free_pages+0x144>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02007e6:	406507b3          	sub	a5,a0,t1
ffffffffc02007ea:	878d                	srai	a5,a5,0x3
ffffffffc02007ec:	03d787b3          	mul	a5,a5,t4
        uintptr_t buddy_idx = page_idx ^ (1 << order);
ffffffffc02007f0:	00de183b          	sllw	a6,t3,a3
ffffffffc02007f4:	97c6                	add	a5,a5,a7
ffffffffc02007f6:	0107c7b3          	xor	a5,a5,a6
        struct Page *buddy = pa2page(buddy_idx * PGSIZE);
ffffffffc02007fa:	07b2                	slli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02007fc:	83b1                	srli	a5,a5,0xc
ffffffffc02007fe:	09e7f963          	bgeu	a5,t5,ffffffffc0200890 <buddy_free_pages+0x16e>
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200802:	411787b3          	sub	a5,a5,a7
ffffffffc0200806:	00279713          	slli	a4,a5,0x2
ffffffffc020080a:	97ba                	add	a5,a5,a4
ffffffffc020080c:	078e                	slli	a5,a5,0x3
ffffffffc020080e:	979a                	add	a5,a5,t1
        if (!PageProperty(buddy) || buddy->property != order) {
ffffffffc0200810:	6798                	ld	a4,8(a5)
ffffffffc0200812:	00277593          	andi	a1,a4,2
ffffffffc0200816:	f1cd                	bnez	a1,ffffffffc02007b8 <buddy_free_pages+0x96>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200818:	02069713          	slli	a4,a3,0x20
ffffffffc020081c:	9301                	srli	a4,a4,0x20
ffffffffc020081e:	00171793          	slli	a5,a4,0x1
ffffffffc0200822:	97ba                	add	a5,a5,a4
ffffffffc0200824:	078e                	slli	a5,a5,0x3
    SetPageProperty(base);
ffffffffc0200826:	6518                	ld	a4,8(a0)
ffffffffc0200828:	92be                	add	t0,t0,a5
ffffffffc020082a:	0082b583          	ld	a1,8(t0)
ffffffffc020082e:	00276793          	ori	a5,a4,2
    nr_free += (1 << order);
ffffffffc0200832:	00006617          	auipc	a2,0x6
ffffffffc0200836:	ca660613          	addi	a2,a2,-858 # ffffffffc02064d8 <nr_free>
    free_area[order].nr_free++;
ffffffffc020083a:	0102a703          	lw	a4,16(t0)
    base->property = order;
ffffffffc020083e:	c914                	sw	a3,16(a0)
    SetPageProperty(base);
ffffffffc0200840:	e51c                	sd	a5,8(a0)
    list_add(&(free_area[order].free_list), &(base->page_link));
ffffffffc0200842:	01850693          	addi	a3,a0,24
    nr_free += (1 << order);
ffffffffc0200846:	621c                	ld	a5,0(a2)
    prev->next = next->prev = elm;
ffffffffc0200848:	e194                	sd	a3,0(a1)
ffffffffc020084a:	00d2b423          	sd	a3,8(t0)
}
ffffffffc020084e:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200850:	f10c                	sd	a1,32(a0)
    elm->prev = prev;
ffffffffc0200852:	00553c23          	sd	t0,24(a0)
    free_area[order].nr_free++;
ffffffffc0200856:	2705                	addiw	a4,a4,1
    nr_free += (1 << order);
ffffffffc0200858:	983e                	add	a6,a6,a5
    free_area[order].nr_free++;
ffffffffc020085a:	00e2a823          	sw	a4,16(t0)
    nr_free += (1 << order);
ffffffffc020085e:	01063023          	sd	a6,0(a2)
}
ffffffffc0200862:	0141                	addi	sp,sp,16
ffffffffc0200864:	8082                	ret
ffffffffc0200866:	6811                	lui	a6,0x4
ffffffffc0200868:	bf45                	j	ffffffffc0200818 <buddy_free_pages+0xf6>
    for (; p != base + (1 << order); p++) {
ffffffffc020086a:	02850613          	addi	a2,a0,40
ffffffffc020086e:	bdf9                	j	ffffffffc020074c <buddy_free_pages+0x2a>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200870:	00001697          	auipc	a3,0x1
ffffffffc0200874:	7c868693          	addi	a3,a3,1992 # ffffffffc0202038 <etext+0x29c>
ffffffffc0200878:	00001617          	auipc	a2,0x1
ffffffffc020087c:	79060613          	addi	a2,a2,1936 # ffffffffc0202008 <etext+0x26c>
ffffffffc0200880:	07f00593          	li	a1,127
ffffffffc0200884:	00001517          	auipc	a0,0x1
ffffffffc0200888:	79c50513          	addi	a0,a0,1948 # ffffffffc0202020 <etext+0x284>
ffffffffc020088c:	937ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200890:	00001617          	auipc	a2,0x1
ffffffffc0200894:	7d060613          	addi	a2,a2,2000 # ffffffffc0202060 <etext+0x2c4>
ffffffffc0200898:	06a00593          	li	a1,106
ffffffffc020089c:	00001517          	auipc	a0,0x1
ffffffffc02008a0:	7e450513          	addi	a0,a0,2020 # ffffffffc0202080 <etext+0x2e4>
ffffffffc02008a4:	91fff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc02008a8:	00001697          	auipc	a3,0x1
ffffffffc02008ac:	75868693          	addi	a3,a3,1880 # ffffffffc0202000 <etext+0x264>
ffffffffc02008b0:	00001617          	auipc	a2,0x1
ffffffffc02008b4:	75860613          	addi	a2,a2,1880 # ffffffffc0202008 <etext+0x26c>
ffffffffc02008b8:	07900593          	li	a1,121
ffffffffc02008bc:	00001517          	auipc	a0,0x1
ffffffffc02008c0:	76450513          	addi	a0,a0,1892 # ffffffffc0202020 <etext+0x284>
ffffffffc02008c4:	8ffff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02008c8 <buddy_init_memmap>:
static void buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc02008c8:	1141                	addi	sp,sp,-16
ffffffffc02008ca:	e406                	sd	ra,8(sp)
ffffffffc02008cc:	e022                	sd	s0,0(sp)
    assert(n > 0);
ffffffffc02008ce:	c5fd                	beqz	a1,ffffffffc02009bc <buddy_init_memmap+0xf4>
    for (struct Page *p = base; p < base + n; p++) {
ffffffffc02008d0:	00259693          	slli	a3,a1,0x2
ffffffffc02008d4:	96ae                	add	a3,a3,a1
ffffffffc02008d6:	068e                	slli	a3,a3,0x3
ffffffffc02008d8:	96aa                	add	a3,a3,a0
ffffffffc02008da:	87aa                	mv	a5,a0
ffffffffc02008dc:	00d57f63          	bgeu	a0,a3,ffffffffc02008fa <buddy_init_memmap+0x32>
        assert(PageReserved(p));
ffffffffc02008e0:	6798                	ld	a4,8(a5)
ffffffffc02008e2:	8b05                	andi	a4,a4,1
ffffffffc02008e4:	cf45                	beqz	a4,ffffffffc020099c <buddy_init_memmap+0xd4>
        p->flags = 0;
ffffffffc02008e6:	0007b423          	sd	zero,8(a5)
        p->property = 0; 
ffffffffc02008ea:	0007a823          	sw	zero,16(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02008ee:	0007a023          	sw	zero,0(a5)
    for (struct Page *p = base; p < base + n; p++) {
ffffffffc02008f2:	02878793          	addi	a5,a5,40
ffffffffc02008f6:	fed7e5e3          	bltu	a5,a3,ffffffffc02008e0 <buddy_init_memmap+0x18>
ffffffffc02008fa:	00006417          	auipc	s0,0x6
ffffffffc02008fe:	bde40413          	addi	s0,s0,-1058 # ffffffffc02064d8 <nr_free>
ffffffffc0200902:	00043283          	ld	t0,0(s0)
ffffffffc0200906:	00005397          	auipc	t2,0x5
ffffffffc020090a:	71238393          	addi	t2,t2,1810 # ffffffffc0206018 <free_area>
        while (order + 1 < MAX_ORDER && (1 << (order + 1)) <= total_pages) {
ffffffffc020090e:	4605                	li	a2,1
ffffffffc0200910:	4839                	li	a6,14
    for (struct Page *p = base; p < base + n; p++) {
ffffffffc0200912:	4781                	li	a5,0
        while (order + 1 < MAX_ORDER && (1 << (order + 1)) <= total_pages) {
ffffffffc0200914:	0017871b          	addiw	a4,a5,1
ffffffffc0200918:	00e6173b          	sllw	a4,a2,a4
ffffffffc020091c:	0007869b          	sext.w	a3,a5
ffffffffc0200920:	06e5e263          	bltu	a1,a4,ffffffffc0200984 <buddy_init_memmap+0xbc>
ffffffffc0200924:	0785                	addi	a5,a5,1
ffffffffc0200926:	ff0797e3          	bne	a5,a6,ffffffffc0200914 <buddy_init_memmap+0x4c>
ffffffffc020092a:	000a0f37          	lui	t5,0xa0
ffffffffc020092e:	6e91                	lui	t4,0x4
ffffffffc0200930:	46b9                	li	a3,14
ffffffffc0200932:	15000893          	li	a7,336
ffffffffc0200936:	00179713          	slli	a4,a5,0x1
    __list_add(elm, listelm, listelm->next);
ffffffffc020093a:	97ba                	add	a5,a5,a4
ffffffffc020093c:	078e                	slli	a5,a5,0x3
ffffffffc020093e:	979e                	add	a5,a5,t2
ffffffffc0200940:	0087bf83          	ld	t6,8(a5)
        free_area[order].nr_free++;
ffffffffc0200944:	0107ae03          	lw	t3,16(a5)
        list_add(&(free_area[order].free_list), &(p->page_link));
ffffffffc0200948:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020094c:	00efb023          	sd	a4,0(t6)
        SetPageProperty(p); // 标记它是一个空闲块的头部
ffffffffc0200950:	00853303          	ld	t1,8(a0)
ffffffffc0200954:	e798                	sd	a4,8(a5)
        list_add(&(free_area[order].free_list), &(p->page_link));
ffffffffc0200956:	01138733          	add	a4,t2,a7
    elm->prev = prev;
ffffffffc020095a:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc020095c:	03f53023          	sd	t6,32(a0)
        free_area[order].nr_free++;
ffffffffc0200960:	001e071b          	addiw	a4,t3,1
ffffffffc0200964:	cb98                	sw	a4,16(a5)
        SetPageProperty(p); // 标记它是一个空闲块的头部
ffffffffc0200966:	00236793          	ori	a5,t1,2
        p->property = order;
ffffffffc020096a:	c914                	sw	a3,16(a0)
        SetPageProperty(p); // 标记它是一个空闲块的头部
ffffffffc020096c:	e51c                	sd	a5,8(a0)
        total_pages -= (1 << order);
ffffffffc020096e:	41d585b3          	sub	a1,a1,t4
        nr_free += (1 << order);
ffffffffc0200972:	92f6                	add	t0,t0,t4
        p += (1 << order);
ffffffffc0200974:	957a                	add	a0,a0,t5
    while (total_pages > 0) {
ffffffffc0200976:	fdd1                	bnez	a1,ffffffffc0200912 <buddy_init_memmap+0x4a>
}
ffffffffc0200978:	60a2                	ld	ra,8(sp)
ffffffffc020097a:	00543023          	sd	t0,0(s0)
ffffffffc020097e:	6402                	ld	s0,0(sp)
ffffffffc0200980:	0141                	addi	sp,sp,16
ffffffffc0200982:	8082                	ret
        nr_free += (1 << order);
ffffffffc0200984:	00d61ebb          	sllw	t4,a2,a3
ffffffffc0200988:	00179713          	slli	a4,a5,0x1
        p += (1 << order);
ffffffffc020098c:	002e9f13          	slli	t5,t4,0x2
ffffffffc0200990:	00f708b3          	add	a7,a4,a5
ffffffffc0200994:	9f76                	add	t5,t5,t4
ffffffffc0200996:	088e                	slli	a7,a7,0x3
ffffffffc0200998:	0f0e                	slli	t5,t5,0x3
ffffffffc020099a:	b745                	j	ffffffffc020093a <buddy_init_memmap+0x72>
        assert(PageReserved(p));
ffffffffc020099c:	00001697          	auipc	a3,0x1
ffffffffc02009a0:	6f468693          	addi	a3,a3,1780 # ffffffffc0202090 <etext+0x2f4>
ffffffffc02009a4:	00001617          	auipc	a2,0x1
ffffffffc02009a8:	66460613          	addi	a2,a2,1636 # ffffffffc0202008 <etext+0x26c>
ffffffffc02009ac:	02b00593          	li	a1,43
ffffffffc02009b0:	00001517          	auipc	a0,0x1
ffffffffc02009b4:	67050513          	addi	a0,a0,1648 # ffffffffc0202020 <etext+0x284>
ffffffffc02009b8:	80bff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc02009bc:	00001697          	auipc	a3,0x1
ffffffffc02009c0:	64468693          	addi	a3,a3,1604 # ffffffffc0202000 <etext+0x264>
ffffffffc02009c4:	00001617          	auipc	a2,0x1
ffffffffc02009c8:	64460613          	addi	a2,a2,1604 # ffffffffc0202008 <etext+0x26c>
ffffffffc02009cc:	02700593          	li	a1,39
ffffffffc02009d0:	00001517          	auipc	a0,0x1
ffffffffc02009d4:	65050513          	addi	a0,a0,1616 # ffffffffc0202020 <etext+0x284>
ffffffffc02009d8:	feaff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02009dc <pmm_init>:

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    // pmm_manager = &default_pmm_manager; 
    // pmm_manager = &buddy_pmm_manager;
    pmm_manager = &slub_pmm_manager;  // 使用SLUB分配器
ffffffffc02009dc:	00002797          	auipc	a5,0x2
ffffffffc02009e0:	d5478793          	addi	a5,a5,-684 # ffffffffc0202730 <slub_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02009e4:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02009e6:	7179                	addi	sp,sp,-48
ffffffffc02009e8:	f022                	sd	s0,32(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02009ea:	00001517          	auipc	a0,0x1
ffffffffc02009ee:	70650513          	addi	a0,a0,1798 # ffffffffc02020f0 <buddy_pmm_manager+0x38>
    pmm_manager = &slub_pmm_manager;  // 使用SLUB分配器
ffffffffc02009f2:	00006417          	auipc	s0,0x6
ffffffffc02009f6:	afe40413          	addi	s0,s0,-1282 # ffffffffc02064f0 <pmm_manager>
void pmm_init(void) {
ffffffffc02009fa:	f406                	sd	ra,40(sp)
ffffffffc02009fc:	ec26                	sd	s1,24(sp)
ffffffffc02009fe:	e44e                	sd	s3,8(sp)
ffffffffc0200a00:	e84a                	sd	s2,16(sp)
ffffffffc0200a02:	e052                	sd	s4,0(sp)
    pmm_manager = &slub_pmm_manager;  // 使用SLUB分配器
ffffffffc0200a04:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200a06:	f46ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    pmm_manager->init();
ffffffffc0200a0a:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200a0c:	00006497          	auipc	s1,0x6
ffffffffc0200a10:	afc48493          	addi	s1,s1,-1284 # ffffffffc0206508 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200a14:	679c                	ld	a5,8(a5)
ffffffffc0200a16:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200a18:	57f5                	li	a5,-3
ffffffffc0200a1a:	07fa                	slli	a5,a5,0x1e
ffffffffc0200a1c:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();
ffffffffc0200a1e:	b9fff0ef          	jal	ra,ffffffffc02005bc <get_memory_base>
ffffffffc0200a22:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc0200a24:	ba3ff0ef          	jal	ra,ffffffffc02005c6 <get_memory_size>
    if (mem_size == 0) {
ffffffffc0200a28:	14050d63          	beqz	a0,ffffffffc0200b82 <pmm_init+0x1a6>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200a2c:	892a                	mv	s2,a0
    cprintf("physcial memory map:\n");
ffffffffc0200a2e:	00001517          	auipc	a0,0x1
ffffffffc0200a32:	70a50513          	addi	a0,a0,1802 # ffffffffc0202138 <buddy_pmm_manager+0x80>
ffffffffc0200a36:	f16ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200a3a:	01298a33          	add	s4,s3,s2
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200a3e:	864e                	mv	a2,s3
ffffffffc0200a40:	fffa0693          	addi	a3,s4,-1
ffffffffc0200a44:	85ca                	mv	a1,s2
ffffffffc0200a46:	00001517          	auipc	a0,0x1
ffffffffc0200a4a:	70a50513          	addi	a0,a0,1802 # ffffffffc0202150 <buddy_pmm_manager+0x98>
ffffffffc0200a4e:	efeff0ef          	jal	ra,ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0200a52:	c80007b7          	lui	a5,0xc8000
ffffffffc0200a56:	8652                	mv	a2,s4
ffffffffc0200a58:	0d47e463          	bltu	a5,s4,ffffffffc0200b20 <pmm_init+0x144>
ffffffffc0200a5c:	00007797          	auipc	a5,0x7
ffffffffc0200a60:	ab378793          	addi	a5,a5,-1357 # ffffffffc020750f <end+0xfff>
ffffffffc0200a64:	757d                	lui	a0,0xfffff
ffffffffc0200a66:	8d7d                	and	a0,a0,a5
ffffffffc0200a68:	8231                	srli	a2,a2,0xc
ffffffffc0200a6a:	00006797          	auipc	a5,0x6
ffffffffc0200a6e:	a6c7bb23          	sd	a2,-1418(a5) # ffffffffc02064e0 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200a72:	00006797          	auipc	a5,0x6
ffffffffc0200a76:	a6a7bb23          	sd	a0,-1418(a5) # ffffffffc02064e8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200a7a:	000807b7          	lui	a5,0x80
ffffffffc0200a7e:	002005b7          	lui	a1,0x200
ffffffffc0200a82:	02f60563          	beq	a2,a5,ffffffffc0200aac <pmm_init+0xd0>
ffffffffc0200a86:	00261593          	slli	a1,a2,0x2
ffffffffc0200a8a:	00c586b3          	add	a3,a1,a2
ffffffffc0200a8e:	fec007b7          	lui	a5,0xfec00
ffffffffc0200a92:	97aa                	add	a5,a5,a0
ffffffffc0200a94:	068e                	slli	a3,a3,0x3
ffffffffc0200a96:	96be                	add	a3,a3,a5
ffffffffc0200a98:	87aa                	mv	a5,a0
        SetPageReserved(pages + i);
ffffffffc0200a9a:	6798                	ld	a4,8(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200a9c:	02878793          	addi	a5,a5,40 # fffffffffec00028 <end+0x3e9f9b18>
        SetPageReserved(pages + i);
ffffffffc0200aa0:	00176713          	ori	a4,a4,1
ffffffffc0200aa4:	fee7b023          	sd	a4,-32(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200aa8:	fef699e3          	bne	a3,a5,ffffffffc0200a9a <pmm_init+0xbe>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200aac:	95b2                	add	a1,a1,a2
ffffffffc0200aae:	fec006b7          	lui	a3,0xfec00
ffffffffc0200ab2:	96aa                	add	a3,a3,a0
ffffffffc0200ab4:	058e                	slli	a1,a1,0x3
ffffffffc0200ab6:	96ae                	add	a3,a3,a1
ffffffffc0200ab8:	c02007b7          	lui	a5,0xc0200
ffffffffc0200abc:	0af6e763          	bltu	a3,a5,ffffffffc0200b6a <pmm_init+0x18e>
ffffffffc0200ac0:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0200ac2:	77fd                	lui	a5,0xfffff
ffffffffc0200ac4:	00fa75b3          	and	a1,s4,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200ac8:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200aca:	04b6ee63          	bltu	a3,a1,ffffffffc0200b26 <pmm_init+0x14a>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200ace:	601c                	ld	a5,0(s0)
ffffffffc0200ad0:	7b9c                	ld	a5,48(a5)
ffffffffc0200ad2:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200ad4:	00001517          	auipc	a0,0x1
ffffffffc0200ad8:	6d450513          	addi	a0,a0,1748 # ffffffffc02021a8 <buddy_pmm_manager+0xf0>
ffffffffc0200adc:	e70ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200ae0:	00004597          	auipc	a1,0x4
ffffffffc0200ae4:	52058593          	addi	a1,a1,1312 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200ae8:	00006797          	auipc	a5,0x6
ffffffffc0200aec:	a0b7bc23          	sd	a1,-1512(a5) # ffffffffc0206500 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200af0:	c02007b7          	lui	a5,0xc0200
ffffffffc0200af4:	0af5e363          	bltu	a1,a5,ffffffffc0200b9a <pmm_init+0x1be>
ffffffffc0200af8:	6090                	ld	a2,0(s1)
}
ffffffffc0200afa:	7402                	ld	s0,32(sp)
ffffffffc0200afc:	70a2                	ld	ra,40(sp)
ffffffffc0200afe:	64e2                	ld	s1,24(sp)
ffffffffc0200b00:	6942                	ld	s2,16(sp)
ffffffffc0200b02:	69a2                	ld	s3,8(sp)
ffffffffc0200b04:	6a02                	ld	s4,0(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200b06:	40c58633          	sub	a2,a1,a2
ffffffffc0200b0a:	00006797          	auipc	a5,0x6
ffffffffc0200b0e:	9ec7b723          	sd	a2,-1554(a5) # ffffffffc02064f8 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200b12:	00001517          	auipc	a0,0x1
ffffffffc0200b16:	6b650513          	addi	a0,a0,1718 # ffffffffc02021c8 <buddy_pmm_manager+0x110>
}
ffffffffc0200b1a:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200b1c:	e30ff06f          	j	ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0200b20:	c8000637          	lui	a2,0xc8000
ffffffffc0200b24:	bf25                	j	ffffffffc0200a5c <pmm_init+0x80>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200b26:	6705                	lui	a4,0x1
ffffffffc0200b28:	177d                	addi	a4,a4,-1
ffffffffc0200b2a:	96ba                	add	a3,a3,a4
ffffffffc0200b2c:	8efd                	and	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0200b2e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200b32:	02c7f063          	bgeu	a5,a2,ffffffffc0200b52 <pmm_init+0x176>
    pmm_manager->init_memmap(base, n);
ffffffffc0200b36:	6010                	ld	a2,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc0200b38:	fff80737          	lui	a4,0xfff80
ffffffffc0200b3c:	973e                	add	a4,a4,a5
ffffffffc0200b3e:	00271793          	slli	a5,a4,0x2
ffffffffc0200b42:	97ba                	add	a5,a5,a4
ffffffffc0200b44:	6a18                	ld	a4,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200b46:	8d95                	sub	a1,a1,a3
ffffffffc0200b48:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200b4a:	81b1                	srli	a1,a1,0xc
ffffffffc0200b4c:	953e                	add	a0,a0,a5
ffffffffc0200b4e:	9702                	jalr	a4
}
ffffffffc0200b50:	bfbd                	j	ffffffffc0200ace <pmm_init+0xf2>
        panic("pa2page called with invalid pa");
ffffffffc0200b52:	00001617          	auipc	a2,0x1
ffffffffc0200b56:	50e60613          	addi	a2,a2,1294 # ffffffffc0202060 <etext+0x2c4>
ffffffffc0200b5a:	06a00593          	li	a1,106
ffffffffc0200b5e:	00001517          	auipc	a0,0x1
ffffffffc0200b62:	52250513          	addi	a0,a0,1314 # ffffffffc0202080 <etext+0x2e4>
ffffffffc0200b66:	e5cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200b6a:	00001617          	auipc	a2,0x1
ffffffffc0200b6e:	61660613          	addi	a2,a2,1558 # ffffffffc0202180 <buddy_pmm_manager+0xc8>
ffffffffc0200b72:	06300593          	li	a1,99
ffffffffc0200b76:	00001517          	auipc	a0,0x1
ffffffffc0200b7a:	5b250513          	addi	a0,a0,1458 # ffffffffc0202128 <buddy_pmm_manager+0x70>
ffffffffc0200b7e:	e44ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("DTB memory info not available");
ffffffffc0200b82:	00001617          	auipc	a2,0x1
ffffffffc0200b86:	58660613          	addi	a2,a2,1414 # ffffffffc0202108 <buddy_pmm_manager+0x50>
ffffffffc0200b8a:	04b00593          	li	a1,75
ffffffffc0200b8e:	00001517          	auipc	a0,0x1
ffffffffc0200b92:	59a50513          	addi	a0,a0,1434 # ffffffffc0202128 <buddy_pmm_manager+0x70>
ffffffffc0200b96:	e2cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200b9a:	86ae                	mv	a3,a1
ffffffffc0200b9c:	00001617          	auipc	a2,0x1
ffffffffc0200ba0:	5e460613          	addi	a2,a2,1508 # ffffffffc0202180 <buddy_pmm_manager+0xc8>
ffffffffc0200ba4:	07e00593          	li	a1,126
ffffffffc0200ba8:	00001517          	auipc	a0,0x1
ffffffffc0200bac:	58050513          	addi	a0,a0,1408 # ffffffffc0202128 <buddy_pmm_manager+0x70>
ffffffffc0200bb0:	e12ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200bb4 <slub_init_memmap>:
                kmem_caches[i].num);
    }
}

void slub_init_memmap(struct Page *base, size_t n) {
    base_pmm->init_memmap(base, n);
ffffffffc0200bb4:	00001797          	auipc	a5,0x1
ffffffffc0200bb8:	5147b783          	ld	a5,1300(a5) # ffffffffc02020c8 <buddy_pmm_manager+0x10>
ffffffffc0200bbc:	8782                	jr	a5

ffffffffc0200bbe <slub_alloc_pages>:
}

struct Page *slub_alloc_pages(size_t n) {
    return base_pmm->alloc_pages(n);
ffffffffc0200bbe:	00001797          	auipc	a5,0x1
ffffffffc0200bc2:	5127b783          	ld	a5,1298(a5) # ffffffffc02020d0 <buddy_pmm_manager+0x18>
ffffffffc0200bc6:	8782                	jr	a5

ffffffffc0200bc8 <slub_free_pages>:
}

void slub_free_pages(struct Page *base, size_t n) {
    base_pmm->free_pages(base, n);
ffffffffc0200bc8:	00001797          	auipc	a5,0x1
ffffffffc0200bcc:	5107b783          	ld	a5,1296(a5) # ffffffffc02020d8 <buddy_pmm_manager+0x20>
ffffffffc0200bd0:	8782                	jr	a5

ffffffffc0200bd2 <slub_nr_free_pages>:
}

size_t slub_nr_free_pages(void) {
    return base_pmm->nr_free_pages();
ffffffffc0200bd2:	00001797          	auipc	a5,0x1
ffffffffc0200bd6:	50e7b783          	ld	a5,1294(a5) # ffffffffc02020e0 <buddy_pmm_manager+0x28>
ffffffffc0200bda:	8782                	jr	a5

ffffffffc0200bdc <slub_init>:
void slub_init(void) {
ffffffffc0200bdc:	7139                	addi	sp,sp,-64
ffffffffc0200bde:	f822                	sd	s0,48(sp)
ffffffffc0200be0:	f426                	sd	s1,40(sp)
ffffffffc0200be2:	f04a                	sd	s2,32(sp)
ffffffffc0200be4:	ec4e                	sd	s3,24(sp)
ffffffffc0200be6:	e852                	sd	s4,16(sp)
ffffffffc0200be8:	e456                	sd	s5,8(sp)
ffffffffc0200bea:	e05a                	sd	s6,0(sp)
ffffffffc0200bec:	fc06                	sd	ra,56(sp)
    base_pmm->init();
ffffffffc0200bee:	00001797          	auipc	a5,0x1
ffffffffc0200bf2:	4d27b783          	ld	a5,1234(a5) # ffffffffc02020c0 <buddy_pmm_manager+0x8>
ffffffffc0200bf6:	9782                	jalr	a5
        kmem_caches[i].num = (page_size - slab_struct_size) / cache_sizes[i];
ffffffffc0200bf8:	6a05                	lui	s4,0x1
ffffffffc0200bfa:	00005417          	auipc	s0,0x5
ffffffffc0200bfe:	59640413          	addi	s0,s0,1430 # ffffffffc0206190 <kmem_caches+0x10>
ffffffffc0200c02:	00005917          	auipc	s2,0x5
ffffffffc0200c06:	7be90913          	addi	s2,s2,1982 # ffffffffc02063c0 <names.0>
ffffffffc0200c0a:	00002997          	auipc	s3,0x2
ffffffffc0200c0e:	ae698993          	addi	s3,s3,-1306 # ffffffffc02026f0 <cache_sizes>
ffffffffc0200c12:	00005497          	auipc	s1,0x5
ffffffffc0200c16:	56e48493          	addi	s1,s1,1390 # ffffffffc0206180 <kmem_caches>
ffffffffc0200c1a:	00005b17          	auipc	s6,0x5
ffffffffc0200c1e:	7b6b0b13          	addi	s6,s6,1974 # ffffffffc02063d0 <names.0+0x10>
    base_pmm->init();
ffffffffc0200c22:	46c1                	li	a3,16
        kmem_caches[i].num = (page_size - slab_struct_size) / cache_sizes[i];
ffffffffc0200c24:	fd8a0a13          	addi	s4,s4,-40 # fd8 <kern_entry-0xffffffffc01ff028>
        snprintf(names[i], 32, "kmem_cache_%lu", cache_sizes[i]);
ffffffffc0200c28:	00001a97          	auipc	s5,0x1
ffffffffc0200c2c:	5e0a8a93          	addi	s5,s5,1504 # ffffffffc0202208 <buddy_pmm_manager+0x150>
ffffffffc0200c30:	a019                	j	ffffffffc0200c36 <slub_init+0x5a>
        kmem_caches[i].objsize = cache_sizes[i];
ffffffffc0200c32:	0009b683          	ld	a3,0(s3)
        kmem_caches[i].num = (page_size - slab_struct_size) / cache_sizes[i];
ffffffffc0200c36:	02da5833          	divu	a6,s4,a3
ffffffffc0200c3a:	01040713          	addi	a4,s0,16
ffffffffc0200c3e:	02040793          	addi	a5,s0,32
        kmem_caches[i].objsize = cache_sizes[i];
ffffffffc0200c42:	fed43823          	sd	a3,-16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200c46:	ec18                	sd	a4,24(s0)
ffffffffc0200c48:	e818                	sd	a4,16(s0)
ffffffffc0200c4a:	f41c                	sd	a5,40(s0)
ffffffffc0200c4c:	f01c                	sd	a5,32(s0)
ffffffffc0200c4e:	e400                	sd	s0,8(s0)
ffffffffc0200c50:	e000                	sd	s0,0(s0)
        snprintf(names[i], 32, "kmem_cache_%lu", cache_sizes[i]);
ffffffffc0200c52:	854a                	mv	a0,s2
ffffffffc0200c54:	8656                	mv	a2,s5
ffffffffc0200c56:	02000593          	li	a1,32
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0200c5a:	04840413          	addi	s0,s0,72
ffffffffc0200c5e:	09a1                	addi	s3,s3,8
        kmem_caches[i].num = (page_size - slab_struct_size) / cache_sizes[i];
ffffffffc0200c60:	fb043823          	sd	a6,-80(s0)
        snprintf(names[i], 32, "kmem_cache_%lu", cache_sizes[i]);
ffffffffc0200c64:	04c010ef          	jal	ra,ffffffffc0201cb0 <snprintf>
        kmem_caches[i].name = names[i];
ffffffffc0200c68:	ff243423          	sd	s2,-24(s0)
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0200c6c:	02090913          	addi	s2,s2,32
ffffffffc0200c70:	fd6411e3          	bne	s0,s6,ffffffffc0200c32 <slub_init+0x56>
    cprintf("SLUB allocator initialized\n");
ffffffffc0200c74:	00001517          	auipc	a0,0x1
ffffffffc0200c78:	5a450513          	addi	a0,a0,1444 # ffffffffc0202218 <buddy_pmm_manager+0x160>
ffffffffc0200c7c:	cd0ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("Cache configurations:\n");
ffffffffc0200c80:	00001517          	auipc	a0,0x1
ffffffffc0200c84:	5b850513          	addi	a0,a0,1464 # ffffffffc0202238 <buddy_pmm_manager+0x180>
ffffffffc0200c88:	cc4ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0200c8c:	00005917          	auipc	s2,0x5
ffffffffc0200c90:	73490913          	addi	s2,s2,1844 # ffffffffc02063c0 <names.0>
        cprintf("  %s: objsize=%lu, num_per_slab=%lu\n", 
ffffffffc0200c94:	00001417          	auipc	s0,0x1
ffffffffc0200c98:	5bc40413          	addi	s0,s0,1468 # ffffffffc0202250 <buddy_pmm_manager+0x198>
ffffffffc0200c9c:	6494                	ld	a3,8(s1)
ffffffffc0200c9e:	6090                	ld	a2,0(s1)
ffffffffc0200ca0:	60ac                	ld	a1,64(s1)
ffffffffc0200ca2:	8522                	mv	a0,s0
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0200ca4:	04848493          	addi	s1,s1,72
        cprintf("  %s: objsize=%lu, num_per_slab=%lu\n", 
ffffffffc0200ca8:	ca4ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0200cac:	ff2498e3          	bne	s1,s2,ffffffffc0200c9c <slub_init+0xc0>
}
ffffffffc0200cb0:	70e2                	ld	ra,56(sp)
ffffffffc0200cb2:	7442                	ld	s0,48(sp)
ffffffffc0200cb4:	74a2                	ld	s1,40(sp)
ffffffffc0200cb6:	7902                	ld	s2,32(sp)
ffffffffc0200cb8:	69e2                	ld	s3,24(sp)
ffffffffc0200cba:	6a42                	ld	s4,16(sp)
ffffffffc0200cbc:	6aa2                	ld	s5,8(sp)
ffffffffc0200cbe:	6b02                	ld	s6,0(sp)
ffffffffc0200cc0:	6121                	addi	sp,sp,64
ffffffffc0200cc2:	8082                	ret

ffffffffc0200cc4 <kmem_cache_alloc>:
}

/* ========== 对象分配与释放 ========== */

/* 从kmem_cache中分配一个对象 */
void *kmem_cache_alloc(struct kmem_cache *cache) {
ffffffffc0200cc4:	7179                	addi	sp,sp,-48
ffffffffc0200cc6:	e84a                	sd	s2,16(sp)
    return list->next == list;
ffffffffc0200cc8:	02853903          	ld	s2,40(a0)
ffffffffc0200ccc:	f022                	sd	s0,32(sp)
ffffffffc0200cce:	f406                	sd	ra,40(sp)
ffffffffc0200cd0:	ec26                	sd	s1,24(sp)
ffffffffc0200cd2:	e44e                	sd	s3,8(sp)
    struct slab *slab = NULL;
    
    // 1. 优先从partial链表中分配
    if (!list_empty(&cache->slabs_partial)) {
ffffffffc0200cd4:	02050793          	addi	a5,a0,32
void *kmem_cache_alloc(struct kmem_cache *cache) {
ffffffffc0200cd8:	842a                	mv	s0,a0
    if (!list_empty(&cache->slabs_partial)) {
ffffffffc0200cda:	06f90a63          	beq	s2,a5,ffffffffc0200d4e <kmem_cache_alloc+0x8a>
        list_del(&slab->slab_link);
        list_add(&cache->slabs_partial, &slab->slab_link);
    }
    
    // 从slab的freelist中分配对象
    void *objp = (void *)((uintptr_t)slab->s_mem + slab->free * cache->objsize);
ffffffffc0200cde:	6110                	ld	a2,0(a0)
ffffffffc0200ce0:	01c92483          	lw	s1,28(s2)
        slab->free = (next_addr - base_addr) / cache->objsize;
    } else {
        slab->free = -1; // 没有更多空闲对象
    }
    
    slab->inuse++;
ffffffffc0200ce4:	01892703          	lw	a4,24(s2)
    
    // 如果slab满了,移到full链表
    if (slab->inuse == cache->num) {
ffffffffc0200ce8:	6508                	ld	a0,8(a0)
    void *objp = (void *)((uintptr_t)slab->s_mem + slab->free * cache->objsize);
ffffffffc0200cea:	02c484b3          	mul	s1,s1,a2
    slab->inuse++;
ffffffffc0200cee:	2705                	addiw	a4,a4,1
    if (slab->inuse == cache->num) {
ffffffffc0200cf0:	883a                	mv	a6,a4
    void *objp = (void *)((uintptr_t)slab->s_mem + slab->free * cache->objsize);
ffffffffc0200cf2:	01093583          	ld	a1,16(s2)
        slab->free = -1; // 没有更多空闲对象
ffffffffc0200cf6:	56fd                	li	a3,-1
    void *objp = (void *)((uintptr_t)slab->s_mem + slab->free * cache->objsize);
ffffffffc0200cf8:	94ae                	add	s1,s1,a1
    if (node->next != NULL) {
ffffffffc0200cfa:	609c                	ld	a5,0(s1)
ffffffffc0200cfc:	c791                	beqz	a5,ffffffffc0200d08 <kmem_cache_alloc+0x44>
        slab->free = (next_addr - base_addr) / cache->objsize;
ffffffffc0200cfe:	8f8d                	sub	a5,a5,a1
ffffffffc0200d00:	02c7d7b3          	divu	a5,a5,a2
ffffffffc0200d04:	0007869b          	sext.w	a3,a5
ffffffffc0200d08:	00d92e23          	sw	a3,28(s2)
    slab->inuse++;
ffffffffc0200d0c:	00e92c23          	sw	a4,24(s2)
    if (slab->inuse == cache->num) {
ffffffffc0200d10:	02a81363          	bne	a6,a0,ffffffffc0200d36 <kmem_cache_alloc+0x72>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d14:	00093683          	ld	a3,0(s2)
ffffffffc0200d18:	00893703          	ld	a4,8(s2)
        list_del(&slab->slab_link);
        list_add(&cache->slabs_full, &slab->slab_link);
ffffffffc0200d1c:	01040593          	addi	a1,s0,16
    prev->next = next;
ffffffffc0200d20:	e698                	sd	a4,8(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200d22:	6c1c                	ld	a5,24(s0)
    next->prev = prev;
ffffffffc0200d24:	e314                	sd	a3,0(a4)
    prev->next = next->prev = elm;
ffffffffc0200d26:	0127b023          	sd	s2,0(a5)
ffffffffc0200d2a:	01243c23          	sd	s2,24(s0)
    elm->next = next;
ffffffffc0200d2e:	00f93423          	sd	a5,8(s2)
    elm->prev = prev;
ffffffffc0200d32:	00b93023          	sd	a1,0(s2)
    }
    
    // 清零对象内存
    memset(objp, 0, cache->objsize);
ffffffffc0200d36:	4581                	li	a1,0
ffffffffc0200d38:	8526                	mv	a0,s1
ffffffffc0200d3a:	050010ef          	jal	ra,ffffffffc0201d8a <memset>
    
    return objp;
}
ffffffffc0200d3e:	70a2                	ld	ra,40(sp)
ffffffffc0200d40:	7402                	ld	s0,32(sp)
ffffffffc0200d42:	6942                	ld	s2,16(sp)
ffffffffc0200d44:	69a2                	ld	s3,8(sp)
ffffffffc0200d46:	8526                	mv	a0,s1
ffffffffc0200d48:	64e2                	ld	s1,24(sp)
ffffffffc0200d4a:	6145                	addi	sp,sp,48
ffffffffc0200d4c:	8082                	ret
    return list->next == list;
ffffffffc0200d4e:	03853983          	ld	s3,56(a0)
    else if (!list_empty(&cache->slabs_free)) {
ffffffffc0200d52:	03050793          	addi	a5,a0,48
ffffffffc0200d56:	02f98d63          	beq	s3,a5,ffffffffc0200d90 <kmem_cache_alloc+0xcc>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d5a:	0009b583          	ld	a1,0(s3)
ffffffffc0200d5e:	0089b683          	ld	a3,8(s3)
    void *objp = (void *)((uintptr_t)slab->s_mem + slab->free * cache->objsize);
ffffffffc0200d62:	6110                	ld	a2,0(a0)
    slab->inuse++;
ffffffffc0200d64:	0189a703          	lw	a4,24(s3)
    prev->next = next;
ffffffffc0200d68:	e594                	sd	a3,8(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200d6a:	751c                	ld	a5,40(a0)
    void *objp = (void *)((uintptr_t)slab->s_mem + slab->free * cache->objsize);
ffffffffc0200d6c:	01c9a483          	lw	s1,28(s3)
    next->prev = prev;
ffffffffc0200d70:	e28c                	sd	a1,0(a3)
    prev->next = next->prev = elm;
ffffffffc0200d72:	0137b023          	sd	s3,0(a5)
ffffffffc0200d76:	03353423          	sd	s3,40(a0)
    slab->inuse++;
ffffffffc0200d7a:	2705                	addiw	a4,a4,1
    if (slab->inuse == cache->num) {
ffffffffc0200d7c:	6508                	ld	a0,8(a0)
    elm->prev = prev;
ffffffffc0200d7e:	0129b023          	sd	s2,0(s3)
    void *objp = (void *)((uintptr_t)slab->s_mem + slab->free * cache->objsize);
ffffffffc0200d82:	02c484b3          	mul	s1,s1,a2
    elm->next = next;
ffffffffc0200d86:	00f9b423          	sd	a5,8(s3)
    if (slab->inuse == cache->num) {
ffffffffc0200d8a:	883a                	mv	a6,a4
}
ffffffffc0200d8c:	894e                	mv	s2,s3
ffffffffc0200d8e:	b795                	j	ffffffffc0200cf2 <kmem_cache_alloc+0x2e>
    return base_pmm->alloc_pages(n);
ffffffffc0200d90:	4505                	li	a0,1
ffffffffc0200d92:	00001797          	auipc	a5,0x1
ffffffffc0200d96:	33e7b783          	ld	a5,830(a5) # ffffffffc02020d0 <buddy_pmm_manager+0x18>
ffffffffc0200d9a:	9782                	jalr	a5
ffffffffc0200d9c:	84aa                	mv	s1,a0
    if (page == NULL) {
ffffffffc0200d9e:	d145                	beqz	a0,ffffffffc0200d3e <kmem_cache_alloc+0x7a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200da0:	00005697          	auipc	a3,0x5
ffffffffc0200da4:	7486b683          	ld	a3,1864(a3) # ffffffffc02064e8 <pages>
ffffffffc0200da8:	40d506b3          	sub	a3,a0,a3
ffffffffc0200dac:	00002797          	auipc	a5,0x2
ffffffffc0200db0:	c047b783          	ld	a5,-1020(a5) # ffffffffc02029b0 <error_string+0x38>
ffffffffc0200db4:	868d                	srai	a3,a3,0x3
ffffffffc0200db6:	02f686b3          	mul	a3,a3,a5
ffffffffc0200dba:	00002797          	auipc	a5,0x2
ffffffffc0200dbe:	bfe7b783          	ld	a5,-1026(a5) # ffffffffc02029b8 <nbase>
    void *kva = page2kva(page);
ffffffffc0200dc2:	00005717          	auipc	a4,0x5
ffffffffc0200dc6:	71e73703          	ld	a4,1822(a4) # ffffffffc02064e0 <npage>
ffffffffc0200dca:	96be                	add	a3,a3,a5
ffffffffc0200dcc:	00c69793          	slli	a5,a3,0xc
ffffffffc0200dd0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200dd2:	06b2                	slli	a3,a3,0xc
ffffffffc0200dd4:	06e7f363          	bgeu	a5,a4,ffffffffc0200e3a <kmem_cache_alloc+0x176>
    for (size_t i = 0; i < cache->num - 1; i++) {
ffffffffc0200dd8:	6408                	ld	a0,8(s0)
    void *kva = page2kva(page);
ffffffffc0200dda:	00005797          	auipc	a5,0x5
ffffffffc0200dde:	72e7b783          	ld	a5,1838(a5) # ffffffffc0206508 <va_pa_offset>
ffffffffc0200de2:	96be                	add	a3,a3,a5
    slab->s_mem = (void *)((uintptr_t)kva + SLUB_ALIGN_SIZE(sizeof(struct slab)));
ffffffffc0200de4:	02868893          	addi	a7,a3,40
ffffffffc0200de8:	0116b823          	sd	a7,16(a3)
    slab->inuse = 0;
ffffffffc0200dec:	0006bc23          	sd	zero,24(a3)
    slab->cache = cache;
ffffffffc0200df0:	f280                	sd	s0,32(a3)
    for (size_t i = 0; i < cache->num - 1; i++) {
ffffffffc0200df2:	fff50813          	addi	a6,a0,-1
        node->next = (struct freelist_node *)((uintptr_t)objp + cache->objsize);
ffffffffc0200df6:	6010                	ld	a2,0(s0)
    slab->s_mem = (void *)((uintptr_t)kva + SLUB_ALIGN_SIZE(sizeof(struct slab)));
ffffffffc0200df8:	87c6                	mv	a5,a7
    for (size_t i = 0; i < cache->num - 1; i++) {
ffffffffc0200dfa:	00080c63          	beqz	a6,ffffffffc0200e12 <kmem_cache_alloc+0x14e>
ffffffffc0200dfe:	4701                	li	a4,0
        node->next = (struct freelist_node *)((uintptr_t)objp + cache->objsize);
ffffffffc0200e00:	85be                	mv	a1,a5
ffffffffc0200e02:	97b2                	add	a5,a5,a2
ffffffffc0200e04:	e19c                	sd	a5,0(a1)
    for (size_t i = 0; i < cache->num - 1; i++) {
ffffffffc0200e06:	0705                	addi	a4,a4,1
ffffffffc0200e08:	ff071ce3          	bne	a4,a6,ffffffffc0200e00 <kmem_cache_alloc+0x13c>
        node->next = (struct freelist_node *)((uintptr_t)objp + cache->objsize);
ffffffffc0200e0c:	02c707b3          	mul	a5,a4,a2
ffffffffc0200e10:	97c6                	add	a5,a5,a7
    __list_add(elm, listelm, listelm->next);
ffffffffc0200e12:	7c18                	ld	a4,56(s0)
    last_node->next = NULL;
ffffffffc0200e14:	0007b023          	sd	zero,0(a5)
    prev->next = next->prev = elm;
ffffffffc0200e18:	fc14                	sd	a3,56(s0)
    elm->next = next;
ffffffffc0200e1a:	e698                	sd	a4,8(a3)
    prev->next = next;
ffffffffc0200e1c:	00e9b423          	sd	a4,8(s3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200e20:	741c                	ld	a5,40(s0)
    next->prev = prev;
ffffffffc0200e22:	01373023          	sd	s3,0(a4)
}
ffffffffc0200e26:	4805                	li	a6,1
    prev->next = next->prev = elm;
ffffffffc0200e28:	e394                	sd	a3,0(a5)
ffffffffc0200e2a:	f414                	sd	a3,40(s0)
    elm->prev = prev;
ffffffffc0200e2c:	0126b023          	sd	s2,0(a3)
    elm->next = next;
ffffffffc0200e30:	e69c                	sd	a5,8(a3)
}
ffffffffc0200e32:	8936                	mv	s2,a3
ffffffffc0200e34:	4705                	li	a4,1
ffffffffc0200e36:	4481                	li	s1,0
ffffffffc0200e38:	bd6d                	j	ffffffffc0200cf2 <kmem_cache_alloc+0x2e>
    void *kva = page2kva(page);
ffffffffc0200e3a:	00001617          	auipc	a2,0x1
ffffffffc0200e3e:	43e60613          	addi	a2,a2,1086 # ffffffffc0202278 <buddy_pmm_manager+0x1c0>
ffffffffc0200e42:	05800593          	li	a1,88
ffffffffc0200e46:	00001517          	auipc	a0,0x1
ffffffffc0200e4a:	45a50513          	addi	a0,a0,1114 # ffffffffc02022a0 <buddy_pmm_manager+0x1e8>
ffffffffc0200e4e:	b74ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200e52 <kmem_cache_free>:

/* 释放一个对象到kmem_cache */
void kmem_cache_free(struct kmem_cache *cache, void *objp) {
ffffffffc0200e52:	872e                	mv	a4,a1
    if (objp == NULL) {
ffffffffc0200e54:	cdb9                	beqz	a1,ffffffffc0200eb2 <kmem_cache_free+0x60>
        return;
    }
    
    // 根据对象地址找到所属的slab
    // slab结构在页的开头
    uintptr_t page_addr = ROUNDDOWN((uintptr_t)objp, PGSIZE);
ffffffffc0200e56:	77fd                	lui	a5,0xfffff
ffffffffc0200e58:	8fed                	and	a5,a5,a1
    struct slab *slab = (struct slab *)page_addr;
    
    // 验证slab是否属于此cache
    if (slab->cache != cache) {
ffffffffc0200e5a:	7394                	ld	a3,32(a5)
ffffffffc0200e5c:	04a69c63          	bne	a3,a0,ffffffffc0200eb4 <kmem_cache_free+0x62>
        cprintf("Error: object %p does not belong to cache %s\n", objp, cache->name);
        return;
    }
    
    // 计算对象的索引
    uintptr_t offset = (uintptr_t)objp - (uintptr_t)slab->s_mem;
ffffffffc0200e60:	0107b803          	ld	a6,16(a5) # fffffffffffff010 <end+0x3fdf8b00>
    int obj_index = offset / cache->objsize;
ffffffffc0200e64:	00053883          	ld	a7,0(a0)
    
    // 将对象添加回freelist
    struct freelist_node *node = (struct freelist_node *)objp;
    if (slab->free >= 0) {
ffffffffc0200e68:	4fd0                	lw	a2,28(a5)
    uintptr_t offset = (uintptr_t)objp - (uintptr_t)slab->s_mem;
ffffffffc0200e6a:	410586b3          	sub	a3,a1,a6
    int obj_index = offset / cache->objsize;
ffffffffc0200e6e:	0316d6b3          	divu	a3,a3,a7
        void *next_free = (void *)((uintptr_t)slab->s_mem + slab->free * cache->objsize);
        node->next = (struct freelist_node *)next_free;
    } else {
        node->next = NULL;
ffffffffc0200e72:	4581                	li	a1,0
    int obj_index = offset / cache->objsize;
ffffffffc0200e74:	2681                	sext.w	a3,a3
    if (slab->free >= 0) {
ffffffffc0200e76:	00064663          	bltz	a2,ffffffffc0200e82 <kmem_cache_free+0x30>
        void *next_free = (void *)((uintptr_t)slab->s_mem + slab->free * cache->objsize);
ffffffffc0200e7a:	03160633          	mul	a2,a2,a7
ffffffffc0200e7e:	010605b3          	add	a1,a2,a6
    }
    slab->free = obj_index;
    
    int was_full = (slab->inuse == cache->num);
ffffffffc0200e82:	4f90                	lw	a2,24(a5)
ffffffffc0200e84:	e30c                	sd	a1,0(a4)
ffffffffc0200e86:	650c                	ld	a1,8(a0)
    slab->inuse--;
ffffffffc0200e88:	fff6071b          	addiw	a4,a2,-1
    slab->free = obj_index;
ffffffffc0200e8c:	cfd4                	sw	a3,28(a5)
    slab->inuse--;
ffffffffc0200e8e:	cf98                	sw	a4,24(a5)
ffffffffc0200e90:	0007069b          	sext.w	a3,a4
    
    // 根据使用情况调整slab在链表中的位置
    if (slab->inuse == 0) {
ffffffffc0200e94:	ee89                	bnez	a3,ffffffffc0200eae <kmem_cache_free+0x5c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200e96:	6390                	ld	a2,0(a5)
ffffffffc0200e98:	6794                	ld	a3,8(a5)
        // slab完全空闲,移到free链表
        list_del(&slab->slab_link);
        list_add(&cache->slabs_free, &slab->slab_link);
ffffffffc0200e9a:	03050593          	addi	a1,a0,48
    prev->next = next;
ffffffffc0200e9e:	e614                	sd	a3,8(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200ea0:	7d18                	ld	a4,56(a0)
    next->prev = prev;
ffffffffc0200ea2:	e290                	sd	a2,0(a3)
    prev->next = next->prev = elm;
ffffffffc0200ea4:	e31c                	sd	a5,0(a4)
ffffffffc0200ea6:	fd1c                	sd	a5,56(a0)
    elm->next = next;
ffffffffc0200ea8:	e798                	sd	a4,8(a5)
    elm->prev = prev;
ffffffffc0200eaa:	e38c                	sd	a1,0(a5)
}
ffffffffc0200eac:	8082                	ret
    } else if (was_full) {
ffffffffc0200eae:	00b60a63          	beq	a2,a1,ffffffffc0200ec2 <kmem_cache_free+0x70>
        // slab从full变为partial
        list_del(&slab->slab_link);
        list_add(&cache->slabs_partial, &slab->slab_link);
    }
}
ffffffffc0200eb2:	8082                	ret
        cprintf("Error: object %p does not belong to cache %s\n", objp, cache->name);
ffffffffc0200eb4:	6130                	ld	a2,64(a0)
ffffffffc0200eb6:	00001517          	auipc	a0,0x1
ffffffffc0200eba:	40250513          	addi	a0,a0,1026 # ffffffffc02022b8 <buddy_pmm_manager+0x200>
ffffffffc0200ebe:	a8eff06f          	j	ffffffffc020014c <cprintf>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200ec2:	6390                	ld	a2,0(a5)
ffffffffc0200ec4:	6794                	ld	a3,8(a5)
        list_add(&cache->slabs_partial, &slab->slab_link);
ffffffffc0200ec6:	02050593          	addi	a1,a0,32
    prev->next = next;
ffffffffc0200eca:	e614                	sd	a3,8(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200ecc:	7518                	ld	a4,40(a0)
    next->prev = prev;
ffffffffc0200ece:	e290                	sd	a2,0(a3)
    prev->next = next->prev = elm;
ffffffffc0200ed0:	e31c                	sd	a5,0(a4)
ffffffffc0200ed2:	f51c                	sd	a5,40(a0)
    elm->next = next;
ffffffffc0200ed4:	e798                	sd	a4,8(a5)
    elm->prev = prev;
ffffffffc0200ed6:	e38c                	sd	a1,0(a5)
}
ffffffffc0200ed8:	8082                	ret

ffffffffc0200eda <slub_alloc>:
    return NULL; // 大小超出范围
}

/* 分配任意大小的内存(类似kmalloc) */
void *slub_alloc(size_t size) {
    if (size == 0) {
ffffffffc0200eda:	c14d                	beqz	a0,ffffffffc0200f7c <slub_alloc+0xa2>
        return NULL;
    }
    
    if (size > SLUB_MAX_SIZE) {
ffffffffc0200edc:	6785                	lui	a5,0x1
ffffffffc0200ede:	80078713          	addi	a4,a5,-2048 # 800 <kern_entry-0xffffffffc01ff800>
ffffffffc0200ee2:	06a77163          	bgeu	a4,a0,ffffffffc0200f44 <slub_alloc+0x6a>
        // 大于最大对象大小,直接分配页
        size_t n = ROUNDUP(size, PGSIZE) / PGSIZE;
ffffffffc0200ee6:	17fd                	addi	a5,a5,-1
void *slub_alloc(size_t size) {
ffffffffc0200ee8:	1141                	addi	sp,sp,-16
        size_t n = ROUNDUP(size, PGSIZE) / PGSIZE;
ffffffffc0200eea:	953e                	add	a0,a0,a5
void *slub_alloc(size_t size) {
ffffffffc0200eec:	e406                	sd	ra,8(sp)
    return base_pmm->alloc_pages(n);
ffffffffc0200eee:	8131                	srli	a0,a0,0xc
ffffffffc0200ef0:	00001797          	auipc	a5,0x1
ffffffffc0200ef4:	1e07b783          	ld	a5,480(a5) # ffffffffc02020d0 <buddy_pmm_manager+0x18>
ffffffffc0200ef8:	9782                	jalr	a5
        struct Page *page = slub_alloc_pages(n);
        if (page == NULL) {
ffffffffc0200efa:	c159                	beqz	a0,ffffffffc0200f80 <slub_alloc+0xa6>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200efc:	00005697          	auipc	a3,0x5
ffffffffc0200f00:	5ec6b683          	ld	a3,1516(a3) # ffffffffc02064e8 <pages>
ffffffffc0200f04:	40d506b3          	sub	a3,a0,a3
ffffffffc0200f08:	868d                	srai	a3,a3,0x3
ffffffffc0200f0a:	00002517          	auipc	a0,0x2
ffffffffc0200f0e:	aa653503          	ld	a0,-1370(a0) # ffffffffc02029b0 <error_string+0x38>
ffffffffc0200f12:	02a686b3          	mul	a3,a3,a0
ffffffffc0200f16:	00002517          	auipc	a0,0x2
ffffffffc0200f1a:	aa253503          	ld	a0,-1374(a0) # ffffffffc02029b8 <nbase>
            return NULL;
        }
        return page2kva(page);
ffffffffc0200f1e:	00005717          	auipc	a4,0x5
ffffffffc0200f22:	5c273703          	ld	a4,1474(a4) # ffffffffc02064e0 <npage>
ffffffffc0200f26:	96aa                	add	a3,a3,a0
ffffffffc0200f28:	00c69793          	slli	a5,a3,0xc
ffffffffc0200f2c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f2e:	06b2                	slli	a3,a3,0xc
ffffffffc0200f30:	04e7fc63          	bgeu	a5,a4,ffffffffc0200f88 <slub_alloc+0xae>
    if (cache == NULL) {
        return NULL;
    }
    
    return kmem_cache_alloc(cache);
}
ffffffffc0200f34:	60a2                	ld	ra,8(sp)
        return page2kva(page);
ffffffffc0200f36:	00005517          	auipc	a0,0x5
ffffffffc0200f3a:	5d253503          	ld	a0,1490(a0) # ffffffffc0206508 <va_pa_offset>
ffffffffc0200f3e:	9536                	add	a0,a0,a3
}
ffffffffc0200f40:	0141                	addi	sp,sp,16
ffffffffc0200f42:	8082                	ret
    size = SLUB_ALIGN_SIZE(size);
ffffffffc0200f44:	051d                	addi	a0,a0,7
ffffffffc0200f46:	9961                	andi	a0,a0,-8
ffffffffc0200f48:	46c1                	li	a3,16
ffffffffc0200f4a:	00001717          	auipc	a4,0x1
ffffffffc0200f4e:	7a670713          	addi	a4,a4,1958 # ffffffffc02026f0 <cache_sizes>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0200f52:	4781                	li	a5,0
ffffffffc0200f54:	4621                	li	a2,8
        if (cache_sizes[i] >= size) {
ffffffffc0200f56:	00a6f963          	bgeu	a3,a0,ffffffffc0200f68 <slub_alloc+0x8e>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0200f5a:	2785                	addiw	a5,a5,1
ffffffffc0200f5c:	0721                	addi	a4,a4,8
ffffffffc0200f5e:	00c78f63          	beq	a5,a2,ffffffffc0200f7c <slub_alloc+0xa2>
        if (cache_sizes[i] >= size) {
ffffffffc0200f62:	6314                	ld	a3,0(a4)
ffffffffc0200f64:	fea6ebe3          	bltu	a3,a0,ffffffffc0200f5a <slub_alloc+0x80>
            return &kmem_caches[i];
ffffffffc0200f68:	00379513          	slli	a0,a5,0x3
ffffffffc0200f6c:	97aa                	add	a5,a5,a0
ffffffffc0200f6e:	078e                	slli	a5,a5,0x3
    return kmem_cache_alloc(cache);
ffffffffc0200f70:	00005517          	auipc	a0,0x5
ffffffffc0200f74:	21050513          	addi	a0,a0,528 # ffffffffc0206180 <kmem_caches>
ffffffffc0200f78:	953e                	add	a0,a0,a5
ffffffffc0200f7a:	b3a9                	j	ffffffffc0200cc4 <kmem_cache_alloc>
        return NULL;
ffffffffc0200f7c:	4501                	li	a0,0
}
ffffffffc0200f7e:	8082                	ret
ffffffffc0200f80:	60a2                	ld	ra,8(sp)
        return NULL;
ffffffffc0200f82:	4501                	li	a0,0
}
ffffffffc0200f84:	0141                	addi	sp,sp,16
ffffffffc0200f86:	8082                	ret
        return page2kva(page);
ffffffffc0200f88:	00001617          	auipc	a2,0x1
ffffffffc0200f8c:	2f060613          	addi	a2,a2,752 # ffffffffc0202278 <buddy_pmm_manager+0x1c0>
ffffffffc0200f90:	10300593          	li	a1,259
ffffffffc0200f94:	00001517          	auipc	a0,0x1
ffffffffc0200f98:	30c50513          	addi	a0,a0,780 # ffffffffc02022a0 <buddy_pmm_manager+0x1e8>
ffffffffc0200f9c:	a26ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200fa0 <slub_check>:
    }
}

/* ========== 测试函数 ========== */

void slub_check(void) {
ffffffffc0200fa0:	7171                	addi	sp,sp,-176
    cprintf("=== SLUB allocator check begin ===\n");
ffffffffc0200fa2:	00001517          	auipc	a0,0x1
ffffffffc0200fa6:	34650513          	addi	a0,a0,838 # ffffffffc02022e8 <buddy_pmm_manager+0x230>
void slub_check(void) {
ffffffffc0200faa:	f506                	sd	ra,168(sp)
ffffffffc0200fac:	ed26                	sd	s1,152(sp)
ffffffffc0200fae:	e94a                	sd	s2,144(sp)
ffffffffc0200fb0:	e54e                	sd	s3,136(sp)
ffffffffc0200fb2:	f122                	sd	s0,160(sp)
ffffffffc0200fb4:	e152                	sd	s4,128(sp)
ffffffffc0200fb6:	fcd6                	sd	s5,120(sp)
ffffffffc0200fb8:	f8da                	sd	s6,112(sp)
ffffffffc0200fba:	f4de                	sd	s7,104(sp)
ffffffffc0200fbc:	f0e2                	sd	s8,96(sp)
ffffffffc0200fbe:	ece6                	sd	s9,88(sp)
ffffffffc0200fc0:	e8ea                	sd	s10,80(sp)
    cprintf("=== SLUB allocator check begin ===\n");
ffffffffc0200fc2:	98aff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 测试1: 基本的分配和释放
    cprintf("Test 1: Basic allocation and free\n");
ffffffffc0200fc6:	00001517          	auipc	a0,0x1
ffffffffc0200fca:	34a50513          	addi	a0,a0,842 # ffffffffc0202310 <buddy_pmm_manager+0x258>
ffffffffc0200fce:	97eff0ef          	jal	ra,ffffffffc020014c <cprintf>
    return kmem_cache_alloc(cache);
ffffffffc0200fd2:	00005517          	auipc	a0,0x5
ffffffffc0200fd6:	1f650513          	addi	a0,a0,502 # ffffffffc02061c8 <kmem_caches+0x48>
ffffffffc0200fda:	cebff0ef          	jal	ra,ffffffffc0200cc4 <kmem_cache_alloc>
ffffffffc0200fde:	89aa                	mv	s3,a0
ffffffffc0200fe0:	00005517          	auipc	a0,0x5
ffffffffc0200fe4:	1e850513          	addi	a0,a0,488 # ffffffffc02061c8 <kmem_caches+0x48>
ffffffffc0200fe8:	cddff0ef          	jal	ra,ffffffffc0200cc4 <kmem_cache_alloc>
ffffffffc0200fec:	00001917          	auipc	s2,0x1
ffffffffc0200ff0:	70490913          	addi	s2,s2,1796 # ffffffffc02026f0 <cache_sizes>
ffffffffc0200ff4:	84aa                	mv	s1,a0
ffffffffc0200ff6:	874a                	mv	a4,s2
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0200ff8:	4781                	li	a5,0
ffffffffc0200ffa:	4621                	li	a2,8
        if (cache_sizes[i] >= size) {
ffffffffc0200ffc:	03f00593          	li	a1,63
ffffffffc0201000:	a029                	j	ffffffffc020100a <slub_check+0x6a>
ffffffffc0201002:	6714                	ld	a3,8(a4)
ffffffffc0201004:	0721                	addi	a4,a4,8
ffffffffc0201006:	02d5e563          	bltu	a1,a3,ffffffffc0201030 <slub_check+0x90>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc020100a:	2785                	addiw	a5,a5,1
ffffffffc020100c:	fec79be3          	bne	a5,a2,ffffffffc0201002 <slub_check+0x62>
    void *p1 = slub_alloc(32);
    void *p2 = slub_alloc(32);
    void *p3 = slub_alloc(64);
    assert(p1 != NULL && p2 != NULL && p3 != NULL);
ffffffffc0201010:	00001697          	auipc	a3,0x1
ffffffffc0201014:	32868693          	addi	a3,a3,808 # ffffffffc0202338 <buddy_pmm_manager+0x280>
ffffffffc0201018:	00001617          	auipc	a2,0x1
ffffffffc020101c:	ff060613          	addi	a2,a2,-16 # ffffffffc0202008 <etext+0x26c>
ffffffffc0201020:	12f00593          	li	a1,303
ffffffffc0201024:	00001517          	auipc	a0,0x1
ffffffffc0201028:	27c50513          	addi	a0,a0,636 # ffffffffc02022a0 <buddy_pmm_manager+0x1e8>
ffffffffc020102c:	996ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
            return &kmem_caches[i];
ffffffffc0201030:	00379513          	slli	a0,a5,0x3
ffffffffc0201034:	97aa                	add	a5,a5,a0
ffffffffc0201036:	00379513          	slli	a0,a5,0x3
ffffffffc020103a:	00005417          	auipc	s0,0x5
ffffffffc020103e:	14640413          	addi	s0,s0,326 # ffffffffc0206180 <kmem_caches>
    return kmem_cache_alloc(cache);
ffffffffc0201042:	9522                	add	a0,a0,s0
ffffffffc0201044:	c81ff0ef          	jal	ra,ffffffffc0200cc4 <kmem_cache_alloc>
ffffffffc0201048:	8a2a                	mv	s4,a0
    assert(p1 != NULL && p2 != NULL && p3 != NULL);
ffffffffc020104a:	fc0983e3          	beqz	s3,ffffffffc0201010 <slub_check+0x70>
ffffffffc020104e:	d0e9                	beqz	s1,ffffffffc0201010 <slub_check+0x70>
ffffffffc0201050:	d161                	beqz	a0,ffffffffc0201010 <slub_check+0x70>
    assert(p1 != p2);
ffffffffc0201052:	7f348863          	beq	s1,s3,ffffffffc0201842 <slub_check+0x8a2>
    cprintf("  Allocated: p1=%p, p2=%p, p3=%p\n", p1, p2, p3);
ffffffffc0201056:	86aa                	mv	a3,a0
ffffffffc0201058:	8626                	mv	a2,s1
ffffffffc020105a:	85ce                	mv	a1,s3
ffffffffc020105c:	00001517          	auipc	a0,0x1
ffffffffc0201060:	31450513          	addi	a0,a0,788 # ffffffffc0202370 <buddy_pmm_manager+0x2b8>
ffffffffc0201064:	8e8ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    uintptr_t page_addr = ROUNDDOWN((uintptr_t)objp, PGSIZE);
ffffffffc0201068:	77fd                	lui	a5,0xfffff
ffffffffc020106a:	00f9f7b3          	and	a5,s3,a5
    if (slab->cache != NULL && 
ffffffffc020106e:	7388                	ld	a0,32(a5)
ffffffffc0201070:	c119                	beqz	a0,ffffffffc0201076 <slub_check+0xd6>
ffffffffc0201072:	60857b63          	bgeu	a0,s0,ffffffffc0201688 <slub_check+0x6e8>
        cprintf("Warning: slub_free called on direct page allocation\n");
ffffffffc0201076:	00001517          	auipc	a0,0x1
ffffffffc020107a:	32250513          	addi	a0,a0,802 # ffffffffc0202398 <buddy_pmm_manager+0x2e0>
ffffffffc020107e:	8ceff0ef          	jal	ra,ffffffffc020014c <cprintf>
    uintptr_t page_addr = ROUNDDOWN((uintptr_t)objp, PGSIZE);
ffffffffc0201082:	77fd                	lui	a5,0xfffff
ffffffffc0201084:	8fe5                	and	a5,a5,s1
    if (slab->cache != NULL && 
ffffffffc0201086:	7388                	ld	a0,32(a5)
ffffffffc0201088:	c119                	beqz	a0,ffffffffc020108e <slub_check+0xee>
ffffffffc020108a:	5e857563          	bgeu	a0,s0,ffffffffc0201674 <slub_check+0x6d4>
        cprintf("Warning: slub_free called on direct page allocation\n");
ffffffffc020108e:	00001517          	auipc	a0,0x1
ffffffffc0201092:	30a50513          	addi	a0,a0,778 # ffffffffc0202398 <buddy_pmm_manager+0x2e0>
ffffffffc0201096:	8b6ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    uintptr_t page_addr = ROUNDDOWN((uintptr_t)objp, PGSIZE);
ffffffffc020109a:	77fd                	lui	a5,0xfffff
ffffffffc020109c:	00fa77b3          	and	a5,s4,a5
    if (slab->cache != NULL && 
ffffffffc02010a0:	7388                	ld	a0,32(a5)
ffffffffc02010a2:	c119                	beqz	a0,ffffffffc02010a8 <slub_check+0x108>
ffffffffc02010a4:	5a857e63          	bgeu	a0,s0,ffffffffc0201660 <slub_check+0x6c0>
        cprintf("Warning: slub_free called on direct page allocation\n");
ffffffffc02010a8:	00001517          	auipc	a0,0x1
ffffffffc02010ac:	2f050513          	addi	a0,a0,752 # ffffffffc0202398 <buddy_pmm_manager+0x2e0>
ffffffffc02010b0:	89cff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    slub_free(p1);
    slub_free(p2);
    slub_free(p3);
    cprintf("  Test 1 passed!\n");
ffffffffc02010b4:	00001517          	auipc	a0,0x1
ffffffffc02010b8:	31c50513          	addi	a0,a0,796 # ffffffffc02023d0 <buddy_pmm_manager+0x318>
ffffffffc02010bc:	890ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 测试2: 重复分配释放
    cprintf("Test 2: Repeated allocation and free\n");
ffffffffc02010c0:	00001517          	auipc	a0,0x1
ffffffffc02010c4:	32850513          	addi	a0,a0,808 # ffffffffc02023e8 <buddy_pmm_manager+0x330>
ffffffffc02010c8:	8a8a                	mv	s5,sp
ffffffffc02010ca:	882ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    void *ptrs[10];
    for (int i = 0; i < 10; i++) {
ffffffffc02010ce:	05010a13          	addi	s4,sp,80
    cprintf("Test 2: Repeated allocation and free\n");
ffffffffc02010d2:	8b56                	mv	s6,s5
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc02010d4:	44a1                	li	s1,8
        if (cache_sizes[i] >= size) {
ffffffffc02010d6:	07f00993          	li	s3,127
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc02010da:	87ca                	mv	a5,s2
ffffffffc02010dc:	4501                	li	a0,0
ffffffffc02010de:	a029                	j	ffffffffc02010e8 <slub_check+0x148>
        if (cache_sizes[i] >= size) {
ffffffffc02010e0:	6798                	ld	a4,8(a5)
ffffffffc02010e2:	07a1                	addi	a5,a5,8
ffffffffc02010e4:	02e9e563          	bltu	s3,a4,ffffffffc020110e <slub_check+0x16e>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc02010e8:	2505                	addiw	a0,a0,1
ffffffffc02010ea:	fe951be3          	bne	a0,s1,ffffffffc02010e0 <slub_check+0x140>
        ptrs[i] = slub_alloc(128);
        assert(ptrs[i] != NULL);
ffffffffc02010ee:	00001697          	auipc	a3,0x1
ffffffffc02010f2:	32268693          	addi	a3,a3,802 # ffffffffc0202410 <buddy_pmm_manager+0x358>
ffffffffc02010f6:	00001617          	auipc	a2,0x1
ffffffffc02010fa:	f1260613          	addi	a2,a2,-238 # ffffffffc0202008 <etext+0x26c>
ffffffffc02010fe:	13d00593          	li	a1,317
ffffffffc0201102:	00001517          	auipc	a0,0x1
ffffffffc0201106:	19e50513          	addi	a0,a0,414 # ffffffffc02022a0 <buddy_pmm_manager+0x1e8>
ffffffffc020110a:	8b8ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
            return &kmem_caches[i];
ffffffffc020110e:	00351793          	slli	a5,a0,0x3
ffffffffc0201112:	953e                	add	a0,a0,a5
ffffffffc0201114:	050e                	slli	a0,a0,0x3
    return kmem_cache_alloc(cache);
ffffffffc0201116:	9522                	add	a0,a0,s0
ffffffffc0201118:	badff0ef          	jal	ra,ffffffffc0200cc4 <kmem_cache_alloc>
        ptrs[i] = slub_alloc(128);
ffffffffc020111c:	00ab3023          	sd	a0,0(s6)
        assert(ptrs[i] != NULL);
ffffffffc0201120:	d579                	beqz	a0,ffffffffc02010ee <slub_check+0x14e>
    for (int i = 0; i < 10; i++) {
ffffffffc0201122:	0b21                	addi	s6,s6,8
ffffffffc0201124:	fb4b1be3          	bne	s6,s4,ffffffffc02010da <slub_check+0x13a>
    uintptr_t page_addr = ROUNDDOWN((uintptr_t)objp, PGSIZE);
ffffffffc0201128:	74fd                	lui	s1,0xfffff
        cprintf("Warning: slub_free called on direct page allocation\n");
ffffffffc020112a:	00001997          	auipc	s3,0x1
ffffffffc020112e:	26e98993          	addi	s3,s3,622 # ffffffffc0202398 <buddy_pmm_manager+0x2e0>
        slab->cache >= &kmem_caches[0] && 
ffffffffc0201132:	00005b17          	auipc	s6,0x5
ffffffffc0201136:	28eb0b13          	addi	s6,s6,654 # ffffffffc02063c0 <names.0>
ffffffffc020113a:	a039                	j	ffffffffc0201148 <slub_check+0x1a8>
        cprintf("Warning: slub_free called on direct page allocation\n");
ffffffffc020113c:	854e                	mv	a0,s3
ffffffffc020113e:	80eff0ef          	jal	ra,ffffffffc020014c <cprintf>
    }
    for (int i = 0; i < 10; i++) {
ffffffffc0201142:	0aa1                	addi	s5,s5,8
ffffffffc0201144:	035a0263          	beq	s4,s5,ffffffffc0201168 <slub_check+0x1c8>
        slub_free(ptrs[i]);
ffffffffc0201148:	000ab583          	ld	a1,0(s5)
    if (objp == NULL) {
ffffffffc020114c:	d9fd                	beqz	a1,ffffffffc0201142 <slub_check+0x1a2>
    uintptr_t page_addr = ROUNDDOWN((uintptr_t)objp, PGSIZE);
ffffffffc020114e:	0095f7b3          	and	a5,a1,s1
    if (slab->cache != NULL && 
ffffffffc0201152:	7388                	ld	a0,32(a5)
ffffffffc0201154:	d565                	beqz	a0,ffffffffc020113c <slub_check+0x19c>
ffffffffc0201156:	fe8563e3          	bltu	a0,s0,ffffffffc020113c <slub_check+0x19c>
        slab->cache >= &kmem_caches[0] && 
ffffffffc020115a:	ff6571e3          	bgeu	a0,s6,ffffffffc020113c <slub_check+0x19c>
    for (int i = 0; i < 10; i++) {
ffffffffc020115e:	0aa1                	addi	s5,s5,8
        kmem_cache_free(slab->cache, objp);
ffffffffc0201160:	cf3ff0ef          	jal	ra,ffffffffc0200e52 <kmem_cache_free>
    for (int i = 0; i < 10; i++) {
ffffffffc0201164:	ff5a12e3          	bne	s4,s5,ffffffffc0201148 <slub_check+0x1a8>
    }
    cprintf("  Test 2 passed!\n");
ffffffffc0201168:	00001517          	auipc	a0,0x1
ffffffffc020116c:	2b850513          	addi	a0,a0,696 # ffffffffc0202420 <buddy_pmm_manager+0x368>
ffffffffc0201170:	fddfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 测试3: 不同大小的分配
    cprintf("Test 3: Different sizes\n");
ffffffffc0201174:	00001517          	auipc	a0,0x1
ffffffffc0201178:	2c450513          	addi	a0,a0,708 # ffffffffc0202438 <buddy_pmm_manager+0x380>
ffffffffc020117c:	fd1fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    return kmem_cache_alloc(cache);
ffffffffc0201180:	00005517          	auipc	a0,0x5
ffffffffc0201184:	00050513          	mv	a0,a0
ffffffffc0201188:	b3dff0ef          	jal	ra,ffffffffc0200cc4 <kmem_cache_alloc>
ffffffffc020118c:	89aa                	mv	s3,a0
ffffffffc020118e:	00005517          	auipc	a0,0x5
ffffffffc0201192:	03a50513          	addi	a0,a0,58 # ffffffffc02061c8 <kmem_caches+0x48>
ffffffffc0201196:	b2fff0ef          	jal	ra,ffffffffc0200cc4 <kmem_cache_alloc>
ffffffffc020119a:	84aa                	mv	s1,a0
ffffffffc020119c:	00001717          	auipc	a4,0x1
ffffffffc02011a0:	55470713          	addi	a4,a4,1364 # ffffffffc02026f0 <cache_sizes>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc02011a4:	4781                	li	a5,0
ffffffffc02011a6:	4621                	li	a2,8
        if (cache_sizes[i] >= size) {
ffffffffc02011a8:	03f00593          	li	a1,63
ffffffffc02011ac:	a029                	j	ffffffffc02011b6 <slub_check+0x216>
ffffffffc02011ae:	6714                	ld	a3,8(a4)
ffffffffc02011b0:	0721                	addi	a4,a4,8
ffffffffc02011b2:	3ad5ef63          	bltu	a1,a3,ffffffffc0201570 <slub_check+0x5d0>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc02011b6:	2785                	addiw	a5,a5,1
ffffffffc02011b8:	fec79be3          	bne	a5,a2,ffffffffc02011ae <slub_check+0x20e>
        return NULL;
ffffffffc02011bc:	4a01                	li	s4,0
ffffffffc02011be:	00001717          	auipc	a4,0x1
ffffffffc02011c2:	53270713          	addi	a4,a4,1330 # ffffffffc02026f0 <cache_sizes>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc02011c6:	4781                	li	a5,0
ffffffffc02011c8:	4621                	li	a2,8
        if (cache_sizes[i] >= size) {
ffffffffc02011ca:	07f00593          	li	a1,127
ffffffffc02011ce:	a029                	j	ffffffffc02011d8 <slub_check+0x238>
ffffffffc02011d0:	6714                	ld	a3,8(a4)
ffffffffc02011d2:	0721                	addi	a4,a4,8
ffffffffc02011d4:	3ad5e863          	bltu	a1,a3,ffffffffc0201584 <slub_check+0x5e4>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc02011d8:	2785                	addiw	a5,a5,1
ffffffffc02011da:	fec79be3          	bne	a5,a2,ffffffffc02011d0 <slub_check+0x230>
        return NULL;
ffffffffc02011de:	4a81                	li	s5,0
ffffffffc02011e0:	00001717          	auipc	a4,0x1
ffffffffc02011e4:	51070713          	addi	a4,a4,1296 # ffffffffc02026f0 <cache_sizes>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc02011e8:	4781                	li	a5,0
ffffffffc02011ea:	4621                	li	a2,8
        if (cache_sizes[i] >= size) {
ffffffffc02011ec:	0ff00593          	li	a1,255
ffffffffc02011f0:	a029                	j	ffffffffc02011fa <slub_check+0x25a>
ffffffffc02011f2:	6714                	ld	a3,8(a4)
ffffffffc02011f4:	0721                	addi	a4,a4,8
ffffffffc02011f6:	3ad5e163          	bltu	a1,a3,ffffffffc0201598 <slub_check+0x5f8>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc02011fa:	2785                	addiw	a5,a5,1
ffffffffc02011fc:	fec79be3          	bne	a5,a2,ffffffffc02011f2 <slub_check+0x252>
        return NULL;
ffffffffc0201200:	4b01                	li	s6,0
ffffffffc0201202:	00001717          	auipc	a4,0x1
ffffffffc0201206:	4ee70713          	addi	a4,a4,1262 # ffffffffc02026f0 <cache_sizes>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc020120a:	4781                	li	a5,0
ffffffffc020120c:	4621                	li	a2,8
        if (cache_sizes[i] >= size) {
ffffffffc020120e:	1ff00593          	li	a1,511
ffffffffc0201212:	a029                	j	ffffffffc020121c <slub_check+0x27c>
ffffffffc0201214:	6714                	ld	a3,8(a4)
ffffffffc0201216:	0721                	addi	a4,a4,8
ffffffffc0201218:	38d5ea63          	bltu	a1,a3,ffffffffc02015ac <slub_check+0x60c>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc020121c:	2785                	addiw	a5,a5,1
ffffffffc020121e:	fec79be3          	bne	a5,a2,ffffffffc0201214 <slub_check+0x274>
        return NULL;
ffffffffc0201222:	4b81                	li	s7,0
ffffffffc0201224:	00001717          	auipc	a4,0x1
ffffffffc0201228:	4cc70713          	addi	a4,a4,1228 # ffffffffc02026f0 <cache_sizes>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc020122c:	4781                	li	a5,0
ffffffffc020122e:	4621                	li	a2,8
        if (cache_sizes[i] >= size) {
ffffffffc0201230:	3ff00593          	li	a1,1023
ffffffffc0201234:	a029                	j	ffffffffc020123e <slub_check+0x29e>
ffffffffc0201236:	6714                	ld	a3,8(a4)
ffffffffc0201238:	0721                	addi	a4,a4,8
ffffffffc020123a:	30d5e763          	bltu	a1,a3,ffffffffc0201548 <slub_check+0x5a8>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc020123e:	2785                	addiw	a5,a5,1
ffffffffc0201240:	fec79be3          	bne	a5,a2,ffffffffc0201236 <slub_check+0x296>
        return NULL;
ffffffffc0201244:	4c01                	li	s8,0
ffffffffc0201246:	00001717          	auipc	a4,0x1
ffffffffc020124a:	4aa70713          	addi	a4,a4,1194 # ffffffffc02026f0 <cache_sizes>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc020124e:	4781                	li	a5,0
ffffffffc0201250:	4621                	li	a2,8
        if (cache_sizes[i] >= size) {
ffffffffc0201252:	7ff00593          	li	a1,2047
ffffffffc0201256:	a029                	j	ffffffffc0201260 <slub_check+0x2c0>
ffffffffc0201258:	6714                	ld	a3,8(a4)
ffffffffc020125a:	0721                	addi	a4,a4,8
ffffffffc020125c:	30d5e063          	bltu	a1,a3,ffffffffc020155c <slub_check+0x5bc>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201260:	2785                	addiw	a5,a5,1
ffffffffc0201262:	fec79be3          	bne	a5,a2,ffffffffc0201258 <slub_check+0x2b8>
        return NULL;
ffffffffc0201266:	4c81                	li	s9,0
    void *p256 = slub_alloc(256);
    void *p512 = slub_alloc(512);
    void *p1024 = slub_alloc(1024);
    void *p2048 = slub_alloc(2048);
    
    assert(p16 != NULL && p32 != NULL && p64 != NULL && p128 != NULL);
ffffffffc0201268:	60098d63          	beqz	s3,ffffffffc0201882 <slub_check+0x8e2>
ffffffffc020126c:	60048b63          	beqz	s1,ffffffffc0201882 <slub_check+0x8e2>
ffffffffc0201270:	600a0963          	beqz	s4,ffffffffc0201882 <slub_check+0x8e2>
ffffffffc0201274:	600a8763          	beqz	s5,ffffffffc0201882 <slub_check+0x8e2>
    assert(p256 != NULL && p512 != NULL && p1024 != NULL && p2048 != NULL);
ffffffffc0201278:	5e0b0563          	beqz	s6,ffffffffc0201862 <slub_check+0x8c2>
ffffffffc020127c:	5e0b8363          	beqz	s7,ffffffffc0201862 <slub_check+0x8c2>
ffffffffc0201280:	5e0c0163          	beqz	s8,ffffffffc0201862 <slub_check+0x8c2>
ffffffffc0201284:	5c0c8f63          	beqz	s9,ffffffffc0201862 <slub_check+0x8c2>
    
    cprintf("  Allocated sizes: 16=%p, 32=%p, 64=%p, 128=%p\n", p16, p32, p64, p128);
ffffffffc0201288:	8756                	mv	a4,s5
ffffffffc020128a:	86d2                	mv	a3,s4
ffffffffc020128c:	8626                	mv	a2,s1
ffffffffc020128e:	85ce                	mv	a1,s3
ffffffffc0201290:	00001517          	auipc	a0,0x1
ffffffffc0201294:	24850513          	addi	a0,a0,584 # ffffffffc02024d8 <buddy_pmm_manager+0x420>
ffffffffc0201298:	eb5fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("                   256=%p, 512=%p, 1024=%p, 2048=%p\n", p256, p512, p1024, p2048);
ffffffffc020129c:	8766                	mv	a4,s9
ffffffffc020129e:	86e2                	mv	a3,s8
ffffffffc02012a0:	865e                	mv	a2,s7
ffffffffc02012a2:	85da                	mv	a1,s6
ffffffffc02012a4:	00001517          	auipc	a0,0x1
ffffffffc02012a8:	26450513          	addi	a0,a0,612 # ffffffffc0202508 <buddy_pmm_manager+0x450>
ffffffffc02012ac:	ea1fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    uintptr_t page_addr = ROUNDDOWN((uintptr_t)objp, PGSIZE);
ffffffffc02012b0:	77fd                	lui	a5,0xfffff
ffffffffc02012b2:	00f9f7b3          	and	a5,s3,a5
    if (slab->cache != NULL && 
ffffffffc02012b6:	7388                	ld	a0,32(a5)
ffffffffc02012b8:	c119                	beqz	a0,ffffffffc02012be <slub_check+0x31e>
ffffffffc02012ba:	38857963          	bgeu	a0,s0,ffffffffc020164c <slub_check+0x6ac>
        cprintf("Warning: slub_free called on direct page allocation\n");
ffffffffc02012be:	00001517          	auipc	a0,0x1
ffffffffc02012c2:	0da50513          	addi	a0,a0,218 # ffffffffc0202398 <buddy_pmm_manager+0x2e0>
ffffffffc02012c6:	e87fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    uintptr_t page_addr = ROUNDDOWN((uintptr_t)objp, PGSIZE);
ffffffffc02012ca:	77fd                	lui	a5,0xfffff
ffffffffc02012cc:	8fe5                	and	a5,a5,s1
    if (slab->cache != NULL && 
ffffffffc02012ce:	7388                	ld	a0,32(a5)
ffffffffc02012d0:	c119                	beqz	a0,ffffffffc02012d6 <slub_check+0x336>
ffffffffc02012d2:	36857363          	bgeu	a0,s0,ffffffffc0201638 <slub_check+0x698>
        cprintf("Warning: slub_free called on direct page allocation\n");
ffffffffc02012d6:	00001517          	auipc	a0,0x1
ffffffffc02012da:	0c250513          	addi	a0,a0,194 # ffffffffc0202398 <buddy_pmm_manager+0x2e0>
ffffffffc02012de:	e6ffe0ef          	jal	ra,ffffffffc020014c <cprintf>
    uintptr_t page_addr = ROUNDDOWN((uintptr_t)objp, PGSIZE);
ffffffffc02012e2:	77fd                	lui	a5,0xfffff
ffffffffc02012e4:	00fa77b3          	and	a5,s4,a5
    if (slab->cache != NULL && 
ffffffffc02012e8:	7388                	ld	a0,32(a5)
ffffffffc02012ea:	c119                	beqz	a0,ffffffffc02012f0 <slub_check+0x350>
ffffffffc02012ec:	32857c63          	bgeu	a0,s0,ffffffffc0201624 <slub_check+0x684>
        cprintf("Warning: slub_free called on direct page allocation\n");
ffffffffc02012f0:	00001517          	auipc	a0,0x1
ffffffffc02012f4:	0a850513          	addi	a0,a0,168 # ffffffffc0202398 <buddy_pmm_manager+0x2e0>
ffffffffc02012f8:	e55fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    uintptr_t page_addr = ROUNDDOWN((uintptr_t)objp, PGSIZE);
ffffffffc02012fc:	77fd                	lui	a5,0xfffff
ffffffffc02012fe:	00faf7b3          	and	a5,s5,a5
    if (slab->cache != NULL && 
ffffffffc0201302:	7388                	ld	a0,32(a5)
ffffffffc0201304:	c119                	beqz	a0,ffffffffc020130a <slub_check+0x36a>
ffffffffc0201306:	30857563          	bgeu	a0,s0,ffffffffc0201610 <slub_check+0x670>
        cprintf("Warning: slub_free called on direct page allocation\n");
ffffffffc020130a:	00001517          	auipc	a0,0x1
ffffffffc020130e:	08e50513          	addi	a0,a0,142 # ffffffffc0202398 <buddy_pmm_manager+0x2e0>
ffffffffc0201312:	e3bfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    uintptr_t page_addr = ROUNDDOWN((uintptr_t)objp, PGSIZE);
ffffffffc0201316:	77fd                	lui	a5,0xfffff
ffffffffc0201318:	00fb77b3          	and	a5,s6,a5
    if (slab->cache != NULL && 
ffffffffc020131c:	7388                	ld	a0,32(a5)
ffffffffc020131e:	c119                	beqz	a0,ffffffffc0201324 <slub_check+0x384>
ffffffffc0201320:	2c857e63          	bgeu	a0,s0,ffffffffc02015fc <slub_check+0x65c>
        cprintf("Warning: slub_free called on direct page allocation\n");
ffffffffc0201324:	00001517          	auipc	a0,0x1
ffffffffc0201328:	07450513          	addi	a0,a0,116 # ffffffffc0202398 <buddy_pmm_manager+0x2e0>
ffffffffc020132c:	e21fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    uintptr_t page_addr = ROUNDDOWN((uintptr_t)objp, PGSIZE);
ffffffffc0201330:	77fd                	lui	a5,0xfffff
ffffffffc0201332:	00fbf7b3          	and	a5,s7,a5
    if (slab->cache != NULL && 
ffffffffc0201336:	7388                	ld	a0,32(a5)
ffffffffc0201338:	c119                	beqz	a0,ffffffffc020133e <slub_check+0x39e>
ffffffffc020133a:	2a857763          	bgeu	a0,s0,ffffffffc02015e8 <slub_check+0x648>
        cprintf("Warning: slub_free called on direct page allocation\n");
ffffffffc020133e:	00001517          	auipc	a0,0x1
ffffffffc0201342:	05a50513          	addi	a0,a0,90 # ffffffffc0202398 <buddy_pmm_manager+0x2e0>
ffffffffc0201346:	e07fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    uintptr_t page_addr = ROUNDDOWN((uintptr_t)objp, PGSIZE);
ffffffffc020134a:	77fd                	lui	a5,0xfffff
ffffffffc020134c:	00fc77b3          	and	a5,s8,a5
    if (slab->cache != NULL && 
ffffffffc0201350:	7388                	ld	a0,32(a5)
ffffffffc0201352:	c119                	beqz	a0,ffffffffc0201358 <slub_check+0x3b8>
ffffffffc0201354:	28857063          	bgeu	a0,s0,ffffffffc02015d4 <slub_check+0x634>
        cprintf("Warning: slub_free called on direct page allocation\n");
ffffffffc0201358:	00001517          	auipc	a0,0x1
ffffffffc020135c:	04050513          	addi	a0,a0,64 # ffffffffc0202398 <buddy_pmm_manager+0x2e0>
ffffffffc0201360:	dedfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    uintptr_t page_addr = ROUNDDOWN((uintptr_t)objp, PGSIZE);
ffffffffc0201364:	77fd                	lui	a5,0xfffff
ffffffffc0201366:	00fcf7b3          	and	a5,s9,a5
    if (slab->cache != NULL && 
ffffffffc020136a:	7388                	ld	a0,32(a5)
ffffffffc020136c:	c119                	beqz	a0,ffffffffc0201372 <slub_check+0x3d2>
ffffffffc020136e:	24857963          	bgeu	a0,s0,ffffffffc02015c0 <slub_check+0x620>
        cprintf("Warning: slub_free called on direct page allocation\n");
ffffffffc0201372:	00001517          	auipc	a0,0x1
ffffffffc0201376:	02650513          	addi	a0,a0,38 # ffffffffc0202398 <buddy_pmm_manager+0x2e0>
ffffffffc020137a:	dd3fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    slub_free(p128);
    slub_free(p256);
    slub_free(p512);
    slub_free(p1024);
    slub_free(p2048);
    cprintf("  Test 3 passed!\n");
ffffffffc020137e:	00001517          	auipc	a0,0x1
ffffffffc0201382:	1c250513          	addi	a0,a0,450 # ffffffffc0202540 <buddy_pmm_manager+0x488>
ffffffffc0201386:	dc7fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 测试4: 填充slab(触发slab扩展)
    cprintf("Test 4: Fill slab (trigger slab growth)\n");
ffffffffc020138a:	00001517          	auipc	a0,0x1
ffffffffc020138e:	1ce50513          	addi	a0,a0,462 # ffffffffc0202558 <buddy_pmm_manager+0x4a0>
ffffffffc0201392:	dbbfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201396:	4a01                	li	s4,0
    cprintf("Test 4: Fill slab (trigger slab growth)\n");
ffffffffc0201398:	00001797          	auipc	a5,0x1
ffffffffc020139c:	35878793          	addi	a5,a5,856 # ffffffffc02026f0 <cache_sizes>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc02013a0:	46a1                	li	a3,8
        if (cache_sizes[i] >= size) {
ffffffffc02013a2:	03f00613          	li	a2,63
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc02013a6:	2a05                	addiw	s4,s4,1
ffffffffc02013a8:	4eda0d63          	beq	s4,a3,ffffffffc02018a2 <slub_check+0x902>
        if (cache_sizes[i] >= size) {
ffffffffc02013ac:	6798                	ld	a4,8(a5)
ffffffffc02013ae:	07a1                	addi	a5,a5,8
ffffffffc02013b0:	fee67be3          	bgeu	a2,a4,ffffffffc02013a6 <slub_check+0x406>
            return &kmem_caches[i];
ffffffffc02013b4:	003a1b93          	slli	s7,s4,0x3
ffffffffc02013b8:	014b8ab3          	add	s5,s7,s4
ffffffffc02013bc:	0a8e                	slli	s5,s5,0x3
ffffffffc02013be:	015404b3          	add	s1,s0,s5
    struct kmem_cache *cache = get_kmem_cache(64);
    int num_objs = cache->num * 3; // 分配3个slab的对象
ffffffffc02013c2:	649c                	ld	a5,8(s1)
ffffffffc02013c4:	00179b1b          	slliw	s6,a5,0x1
ffffffffc02013c8:	00fb0cbb          	addw	s9,s6,a5
    void **objs = (void **)slub_alloc(num_objs * sizeof(void *));
ffffffffc02013cc:	003c9513          	slli	a0,s9,0x3
ffffffffc02013d0:	b0bff0ef          	jal	ra,ffffffffc0200eda <slub_alloc>
    int num_objs = cache->num * 3; // 分配3个slab的对象
ffffffffc02013d4:	8b66                	mv	s6,s9
    void **objs = (void **)slub_alloc(num_objs * sizeof(void *));
ffffffffc02013d6:	8c2a                	mv	s8,a0
    
    for (int i = 0; i < num_objs; i++) {
ffffffffc02013d8:	03905663          	blez	s9,ffffffffc0201404 <slub_check+0x464>
ffffffffc02013dc:	fffc899b          	addiw	s3,s9,-1
ffffffffc02013e0:	02099793          	slli	a5,s3,0x20
ffffffffc02013e4:	01d7d993          	srli	s3,a5,0x1d
ffffffffc02013e8:	00850793          	addi	a5,a0,8
ffffffffc02013ec:	8d2a                	mv	s10,a0
ffffffffc02013ee:	99be                	add	s3,s3,a5
        objs[i] = kmem_cache_alloc(cache);
ffffffffc02013f0:	8526                	mv	a0,s1
ffffffffc02013f2:	8d3ff0ef          	jal	ra,ffffffffc0200cc4 <kmem_cache_alloc>
ffffffffc02013f6:	00ad3023          	sd	a0,0(s10)
        assert(objs[i] != NULL);
ffffffffc02013fa:	3e050463          	beqz	a0,ffffffffc02017e2 <slub_check+0x842>
    for (int i = 0; i < num_objs; i++) {
ffffffffc02013fe:	0d21                	addi	s10,s10,8
ffffffffc0201400:	ff3d18e3          	bne	s10,s3,ffffffffc02013f0 <slub_check+0x450>
    }
    cprintf("  Allocated %d objects from cache_%lu\n", num_objs, cache->objsize);
ffffffffc0201404:	014b87b3          	add	a5,s7,s4
ffffffffc0201408:	078e                	slli	a5,a5,0x3
ffffffffc020140a:	97a2                	add	a5,a5,s0
ffffffffc020140c:	6390                	ld	a2,0(a5)
ffffffffc020140e:	85e6                	mv	a1,s9
ffffffffc0201410:	00001517          	auipc	a0,0x1
ffffffffc0201414:	17850513          	addi	a0,a0,376 # ffffffffc0202588 <buddy_pmm_manager+0x4d0>
ffffffffc0201418:	d35fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    return listelm->next;
ffffffffc020141c:	6c9c                	ld	a5,24(s1)
    
    // 检查链表状态
    int full_count = 0, partial_count = 0, free_count = 0;
    list_entry_t *le;
    
    for (le = list_next(&cache->slabs_full); le != &cache->slabs_full; le = list_next(le)) {
ffffffffc020141e:	010a8713          	addi	a4,s5,16
ffffffffc0201422:	9722                	add	a4,a4,s0
    int full_count = 0, partial_count = 0, free_count = 0;
ffffffffc0201424:	4581                	li	a1,0
    for (le = list_next(&cache->slabs_full); le != &cache->slabs_full; le = list_next(le)) {
ffffffffc0201426:	00e78663          	beq	a5,a4,ffffffffc0201432 <slub_check+0x492>
ffffffffc020142a:	679c                	ld	a5,8(a5)
        full_count++;
ffffffffc020142c:	2585                	addiw	a1,a1,1
    for (le = list_next(&cache->slabs_full); le != &cache->slabs_full; le = list_next(le)) {
ffffffffc020142e:	fee79ee3          	bne	a5,a4,ffffffffc020142a <slub_check+0x48a>
ffffffffc0201432:	749c                	ld	a5,40(s1)
    }
    for (le = list_next(&cache->slabs_partial); le != &cache->slabs_partial; le = list_next(le)) {
ffffffffc0201434:	020a8713          	addi	a4,s5,32
ffffffffc0201438:	9722                	add	a4,a4,s0
    int full_count = 0, partial_count = 0, free_count = 0;
ffffffffc020143a:	4601                	li	a2,0
    for (le = list_next(&cache->slabs_partial); le != &cache->slabs_partial; le = list_next(le)) {
ffffffffc020143c:	00e78663          	beq	a5,a4,ffffffffc0201448 <slub_check+0x4a8>
ffffffffc0201440:	679c                	ld	a5,8(a5)
        partial_count++;
ffffffffc0201442:	2605                	addiw	a2,a2,1
    for (le = list_next(&cache->slabs_partial); le != &cache->slabs_partial; le = list_next(le)) {
ffffffffc0201444:	fee79ee3          	bne	a5,a4,ffffffffc0201440 <slub_check+0x4a0>
ffffffffc0201448:	7c9c                	ld	a5,56(s1)
    }
    for (le = list_next(&cache->slabs_free); le != &cache->slabs_free; le = list_next(le)) {
ffffffffc020144a:	030a8713          	addi	a4,s5,48
ffffffffc020144e:	9722                	add	a4,a4,s0
    int full_count = 0, partial_count = 0, free_count = 0;
ffffffffc0201450:	4681                	li	a3,0
    for (le = list_next(&cache->slabs_free); le != &cache->slabs_free; le = list_next(le)) {
ffffffffc0201452:	00e78663          	beq	a5,a4,ffffffffc020145e <slub_check+0x4be>
ffffffffc0201456:	679c                	ld	a5,8(a5)
        free_count++;
ffffffffc0201458:	2685                	addiw	a3,a3,1
    for (le = list_next(&cache->slabs_free); le != &cache->slabs_free; le = list_next(le)) {
ffffffffc020145a:	fee79ee3          	bne	a5,a4,ffffffffc0201456 <slub_check+0x4b6>
    }
    
    cprintf("  Slab lists: full=%d, partial=%d, free=%d\n", full_count, partial_count, free_count);
ffffffffc020145e:	00001517          	auipc	a0,0x1
ffffffffc0201462:	16250513          	addi	a0,a0,354 # ffffffffc02025c0 <buddy_pmm_manager+0x508>
ffffffffc0201466:	ce7fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 释放所有对象
    for (int i = 0; i < num_objs; i++) {
ffffffffc020146a:	03905463          	blez	s9,ffffffffc0201492 <slub_check+0x4f2>
ffffffffc020146e:	fffb079b          	addiw	a5,s6,-1
ffffffffc0201472:	02079713          	slli	a4,a5,0x20
ffffffffc0201476:	01d75793          	srli	a5,a4,0x1d
ffffffffc020147a:	008c0a13          	addi	s4,s8,8 # ff0008 <kern_entry-0xffffffffbf20fff8>
ffffffffc020147e:	89e2                	mv	s3,s8
ffffffffc0201480:	9a3e                	add	s4,s4,a5
        kmem_cache_free(cache, objs[i]);
ffffffffc0201482:	0009b583          	ld	a1,0(s3)
ffffffffc0201486:	8526                	mv	a0,s1
    for (int i = 0; i < num_objs; i++) {
ffffffffc0201488:	09a1                	addi	s3,s3,8
        kmem_cache_free(cache, objs[i]);
ffffffffc020148a:	9c9ff0ef          	jal	ra,ffffffffc0200e52 <kmem_cache_free>
    for (int i = 0; i < num_objs; i++) {
ffffffffc020148e:	ff499ae3          	bne	s3,s4,ffffffffc0201482 <slub_check+0x4e2>
    if (objp == NULL) {
ffffffffc0201492:	020c0563          	beqz	s8,ffffffffc02014bc <slub_check+0x51c>
    uintptr_t page_addr = ROUNDDOWN((uintptr_t)objp, PGSIZE);
ffffffffc0201496:	77fd                	lui	a5,0xfffff
ffffffffc0201498:	00fc77b3          	and	a5,s8,a5
    if (slab->cache != NULL && 
ffffffffc020149c:	7388                	ld	a0,32(a5)
ffffffffc020149e:	c909                	beqz	a0,ffffffffc02014b0 <slub_check+0x510>
ffffffffc02014a0:	00856863          	bltu	a0,s0,ffffffffc02014b0 <slub_check+0x510>
        slab->cache >= &kmem_caches[0] && 
ffffffffc02014a4:	00005797          	auipc	a5,0x5
ffffffffc02014a8:	f1c78793          	addi	a5,a5,-228 # ffffffffc02063c0 <names.0>
ffffffffc02014ac:	32f56763          	bltu	a0,a5,ffffffffc02017da <slub_check+0x83a>
        cprintf("Warning: slub_free called on direct page allocation\n");
ffffffffc02014b0:	00001517          	auipc	a0,0x1
ffffffffc02014b4:	ee850513          	addi	a0,a0,-280 # ffffffffc0202398 <buddy_pmm_manager+0x2e0>
ffffffffc02014b8:	c95fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    }
    slub_free(objs);
    cprintf("  Test 4 passed!\n");
ffffffffc02014bc:	00001517          	auipc	a0,0x1
ffffffffc02014c0:	13450513          	addi	a0,a0,308 # ffffffffc02025f0 <buddy_pmm_manager+0x538>
ffffffffc02014c4:	c89fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 测试5: 边界情况
    cprintf("Test 5: Edge cases\n");
ffffffffc02014c8:	00001517          	auipc	a0,0x1
ffffffffc02014cc:	14050513          	addi	a0,a0,320 # ffffffffc0202608 <buddy_pmm_manager+0x550>
ffffffffc02014d0:	c7dfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    return kmem_cache_alloc(cache);
ffffffffc02014d4:	00005517          	auipc	a0,0x5
ffffffffc02014d8:	cac50513          	addi	a0,a0,-852 # ffffffffc0206180 <kmem_caches>
ffffffffc02014dc:	fe8ff0ef          	jal	ra,ffffffffc0200cc4 <kmem_cache_alloc>
    void *p_zero = slub_alloc(0);
    assert(p_zero == NULL);
    slub_free(NULL); // 不应崩溃
    
    void *p_small = slub_alloc(1); // 最小分配
    assert(p_small != NULL);
ffffffffc02014e0:	34050163          	beqz	a0,ffffffffc0201822 <slub_check+0x882>
    uintptr_t page_addr = ROUNDDOWN((uintptr_t)objp, PGSIZE);
ffffffffc02014e4:	77fd                	lui	a5,0xfffff
ffffffffc02014e6:	8fe9                	and	a5,a5,a0
    if (slab->cache != NULL && 
ffffffffc02014e8:	739c                	ld	a5,32(a5)
ffffffffc02014ea:	cb89                	beqz	a5,ffffffffc02014fc <slub_check+0x55c>
ffffffffc02014ec:	0087e863          	bltu	a5,s0,ffffffffc02014fc <slub_check+0x55c>
        slab->cache >= &kmem_caches[0] && 
ffffffffc02014f0:	00005717          	auipc	a4,0x5
ffffffffc02014f4:	ed070713          	addi	a4,a4,-304 # ffffffffc02063c0 <names.0>
ffffffffc02014f8:	2ce7ec63          	bltu	a5,a4,ffffffffc02017d0 <slub_check+0x830>
        cprintf("Warning: slub_free called on direct page allocation\n");
ffffffffc02014fc:	00001517          	auipc	a0,0x1
ffffffffc0201500:	e9c50513          	addi	a0,a0,-356 # ffffffffc0202398 <buddy_pmm_manager+0x2e0>
ffffffffc0201504:	c49fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    int full_count = 0, partial_count = 0, free_count = 0;
ffffffffc0201508:	00001717          	auipc	a4,0x1
ffffffffc020150c:	1e870713          	addi	a4,a4,488 # ffffffffc02026f0 <cache_sizes>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201510:	4781                	li	a5,0
ffffffffc0201512:	4621                	li	a2,8
        if (cache_sizes[i] >= size) {
ffffffffc0201514:	7ff00593          	li	a1,2047
ffffffffc0201518:	a029                	j	ffffffffc0201522 <slub_check+0x582>
ffffffffc020151a:	6714                	ld	a3,8(a4)
ffffffffc020151c:	0721                	addi	a4,a4,8
ffffffffc020151e:	16d5ef63          	bltu	a1,a3,ffffffffc020169c <slub_check+0x6fc>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201522:	2785                	addiw	a5,a5,1
ffffffffc0201524:	fec79be3          	bne	a5,a2,ffffffffc020151a <slub_check+0x57a>
    slub_free(p_small);
    
    void *p_max = slub_alloc(SLUB_MAX_SIZE); // 最大对象
    assert(p_max != NULL);
ffffffffc0201528:	00001697          	auipc	a3,0x1
ffffffffc020152c:	10868693          	addi	a3,a3,264 # ffffffffc0202630 <buddy_pmm_manager+0x578>
ffffffffc0201530:	00001617          	auipc	a2,0x1
ffffffffc0201534:	ad860613          	addi	a2,a2,-1320 # ffffffffc0202008 <etext+0x26c>
ffffffffc0201538:	18d00593          	li	a1,397
ffffffffc020153c:	00001517          	auipc	a0,0x1
ffffffffc0201540:	d6450513          	addi	a0,a0,-668 # ffffffffc02022a0 <buddy_pmm_manager+0x1e8>
ffffffffc0201544:	c7ffe0ef          	jal	ra,ffffffffc02001c2 <__panic>
            return &kmem_caches[i];
ffffffffc0201548:	00379513          	slli	a0,a5,0x3
ffffffffc020154c:	97aa                	add	a5,a5,a0
ffffffffc020154e:	00379513          	slli	a0,a5,0x3
    return kmem_cache_alloc(cache);
ffffffffc0201552:	9522                	add	a0,a0,s0
ffffffffc0201554:	f70ff0ef          	jal	ra,ffffffffc0200cc4 <kmem_cache_alloc>
ffffffffc0201558:	8c2a                	mv	s8,a0
ffffffffc020155a:	b1f5                	j	ffffffffc0201246 <slub_check+0x2a6>
            return &kmem_caches[i];
ffffffffc020155c:	00379513          	slli	a0,a5,0x3
ffffffffc0201560:	97aa                	add	a5,a5,a0
ffffffffc0201562:	00379513          	slli	a0,a5,0x3
    return kmem_cache_alloc(cache);
ffffffffc0201566:	9522                	add	a0,a0,s0
ffffffffc0201568:	f5cff0ef          	jal	ra,ffffffffc0200cc4 <kmem_cache_alloc>
ffffffffc020156c:	8caa                	mv	s9,a0
ffffffffc020156e:	b9ed                	j	ffffffffc0201268 <slub_check+0x2c8>
            return &kmem_caches[i];
ffffffffc0201570:	00379513          	slli	a0,a5,0x3
ffffffffc0201574:	97aa                	add	a5,a5,a0
ffffffffc0201576:	00379513          	slli	a0,a5,0x3
    return kmem_cache_alloc(cache);
ffffffffc020157a:	9522                	add	a0,a0,s0
ffffffffc020157c:	f48ff0ef          	jal	ra,ffffffffc0200cc4 <kmem_cache_alloc>
ffffffffc0201580:	8a2a                	mv	s4,a0
ffffffffc0201582:	b935                	j	ffffffffc02011be <slub_check+0x21e>
            return &kmem_caches[i];
ffffffffc0201584:	00379513          	slli	a0,a5,0x3
ffffffffc0201588:	97aa                	add	a5,a5,a0
ffffffffc020158a:	00379513          	slli	a0,a5,0x3
    return kmem_cache_alloc(cache);
ffffffffc020158e:	9522                	add	a0,a0,s0
ffffffffc0201590:	f34ff0ef          	jal	ra,ffffffffc0200cc4 <kmem_cache_alloc>
ffffffffc0201594:	8aaa                	mv	s5,a0
ffffffffc0201596:	b1a9                	j	ffffffffc02011e0 <slub_check+0x240>
            return &kmem_caches[i];
ffffffffc0201598:	00379513          	slli	a0,a5,0x3
ffffffffc020159c:	97aa                	add	a5,a5,a0
ffffffffc020159e:	00379513          	slli	a0,a5,0x3
    return kmem_cache_alloc(cache);
ffffffffc02015a2:	9522                	add	a0,a0,s0
ffffffffc02015a4:	f20ff0ef          	jal	ra,ffffffffc0200cc4 <kmem_cache_alloc>
ffffffffc02015a8:	8b2a                	mv	s6,a0
ffffffffc02015aa:	b9a1                	j	ffffffffc0201202 <slub_check+0x262>
            return &kmem_caches[i];
ffffffffc02015ac:	00379513          	slli	a0,a5,0x3
ffffffffc02015b0:	97aa                	add	a5,a5,a0
ffffffffc02015b2:	00379513          	slli	a0,a5,0x3
    return kmem_cache_alloc(cache);
ffffffffc02015b6:	9522                	add	a0,a0,s0
ffffffffc02015b8:	f0cff0ef          	jal	ra,ffffffffc0200cc4 <kmem_cache_alloc>
ffffffffc02015bc:	8baa                	mv	s7,a0
ffffffffc02015be:	b19d                	j	ffffffffc0201224 <slub_check+0x284>
        slab->cache >= &kmem_caches[0] && 
ffffffffc02015c0:	00005797          	auipc	a5,0x5
ffffffffc02015c4:	e0078793          	addi	a5,a5,-512 # ffffffffc02063c0 <names.0>
ffffffffc02015c8:	daf575e3          	bgeu	a0,a5,ffffffffc0201372 <slub_check+0x3d2>
        kmem_cache_free(slab->cache, objp);
ffffffffc02015cc:	85e6                	mv	a1,s9
ffffffffc02015ce:	885ff0ef          	jal	ra,ffffffffc0200e52 <kmem_cache_free>
ffffffffc02015d2:	b375                	j	ffffffffc020137e <slub_check+0x3de>
        slab->cache >= &kmem_caches[0] && 
ffffffffc02015d4:	00005797          	auipc	a5,0x5
ffffffffc02015d8:	dec78793          	addi	a5,a5,-532 # ffffffffc02063c0 <names.0>
ffffffffc02015dc:	d6f57ee3          	bgeu	a0,a5,ffffffffc0201358 <slub_check+0x3b8>
        kmem_cache_free(slab->cache, objp);
ffffffffc02015e0:	85e2                	mv	a1,s8
ffffffffc02015e2:	871ff0ef          	jal	ra,ffffffffc0200e52 <kmem_cache_free>
ffffffffc02015e6:	bbbd                	j	ffffffffc0201364 <slub_check+0x3c4>
        slab->cache >= &kmem_caches[0] && 
ffffffffc02015e8:	00005797          	auipc	a5,0x5
ffffffffc02015ec:	dd878793          	addi	a5,a5,-552 # ffffffffc02063c0 <names.0>
ffffffffc02015f0:	d4f577e3          	bgeu	a0,a5,ffffffffc020133e <slub_check+0x39e>
        kmem_cache_free(slab->cache, objp);
ffffffffc02015f4:	85de                	mv	a1,s7
ffffffffc02015f6:	85dff0ef          	jal	ra,ffffffffc0200e52 <kmem_cache_free>
ffffffffc02015fa:	bb81                	j	ffffffffc020134a <slub_check+0x3aa>
        slab->cache >= &kmem_caches[0] && 
ffffffffc02015fc:	00005797          	auipc	a5,0x5
ffffffffc0201600:	dc478793          	addi	a5,a5,-572 # ffffffffc02063c0 <names.0>
ffffffffc0201604:	d2f570e3          	bgeu	a0,a5,ffffffffc0201324 <slub_check+0x384>
        kmem_cache_free(slab->cache, objp);
ffffffffc0201608:	85da                	mv	a1,s6
ffffffffc020160a:	849ff0ef          	jal	ra,ffffffffc0200e52 <kmem_cache_free>
ffffffffc020160e:	b30d                	j	ffffffffc0201330 <slub_check+0x390>
        slab->cache >= &kmem_caches[0] && 
ffffffffc0201610:	00005797          	auipc	a5,0x5
ffffffffc0201614:	db078793          	addi	a5,a5,-592 # ffffffffc02063c0 <names.0>
ffffffffc0201618:	cef579e3          	bgeu	a0,a5,ffffffffc020130a <slub_check+0x36a>
        kmem_cache_free(slab->cache, objp);
ffffffffc020161c:	85d6                	mv	a1,s5
ffffffffc020161e:	835ff0ef          	jal	ra,ffffffffc0200e52 <kmem_cache_free>
ffffffffc0201622:	b9d5                	j	ffffffffc0201316 <slub_check+0x376>
        slab->cache >= &kmem_caches[0] && 
ffffffffc0201624:	00005797          	auipc	a5,0x5
ffffffffc0201628:	d9c78793          	addi	a5,a5,-612 # ffffffffc02063c0 <names.0>
ffffffffc020162c:	ccf572e3          	bgeu	a0,a5,ffffffffc02012f0 <slub_check+0x350>
        kmem_cache_free(slab->cache, objp);
ffffffffc0201630:	85d2                	mv	a1,s4
ffffffffc0201632:	821ff0ef          	jal	ra,ffffffffc0200e52 <kmem_cache_free>
ffffffffc0201636:	b1d9                	j	ffffffffc02012fc <slub_check+0x35c>
        slab->cache >= &kmem_caches[0] && 
ffffffffc0201638:	00005797          	auipc	a5,0x5
ffffffffc020163c:	d8878793          	addi	a5,a5,-632 # ffffffffc02063c0 <names.0>
ffffffffc0201640:	c8f57be3          	bgeu	a0,a5,ffffffffc02012d6 <slub_check+0x336>
        kmem_cache_free(slab->cache, objp);
ffffffffc0201644:	85a6                	mv	a1,s1
ffffffffc0201646:	80dff0ef          	jal	ra,ffffffffc0200e52 <kmem_cache_free>
ffffffffc020164a:	b961                	j	ffffffffc02012e2 <slub_check+0x342>
        slab->cache >= &kmem_caches[0] && 
ffffffffc020164c:	00005797          	auipc	a5,0x5
ffffffffc0201650:	d7478793          	addi	a5,a5,-652 # ffffffffc02063c0 <names.0>
ffffffffc0201654:	c6f575e3          	bgeu	a0,a5,ffffffffc02012be <slub_check+0x31e>
        kmem_cache_free(slab->cache, objp);
ffffffffc0201658:	85ce                	mv	a1,s3
ffffffffc020165a:	ff8ff0ef          	jal	ra,ffffffffc0200e52 <kmem_cache_free>
ffffffffc020165e:	b1b5                	j	ffffffffc02012ca <slub_check+0x32a>
        slab->cache >= &kmem_caches[0] && 
ffffffffc0201660:	00005797          	auipc	a5,0x5
ffffffffc0201664:	d6078793          	addi	a5,a5,-672 # ffffffffc02063c0 <names.0>
ffffffffc0201668:	a4f570e3          	bgeu	a0,a5,ffffffffc02010a8 <slub_check+0x108>
        kmem_cache_free(slab->cache, objp);
ffffffffc020166c:	85d2                	mv	a1,s4
ffffffffc020166e:	fe4ff0ef          	jal	ra,ffffffffc0200e52 <kmem_cache_free>
ffffffffc0201672:	b489                	j	ffffffffc02010b4 <slub_check+0x114>
        slab->cache >= &kmem_caches[0] && 
ffffffffc0201674:	00005797          	auipc	a5,0x5
ffffffffc0201678:	d4c78793          	addi	a5,a5,-692 # ffffffffc02063c0 <names.0>
ffffffffc020167c:	a0f579e3          	bgeu	a0,a5,ffffffffc020108e <slub_check+0xee>
        kmem_cache_free(slab->cache, objp);
ffffffffc0201680:	85a6                	mv	a1,s1
ffffffffc0201682:	fd0ff0ef          	jal	ra,ffffffffc0200e52 <kmem_cache_free>
ffffffffc0201686:	bc11                	j	ffffffffc020109a <slub_check+0xfa>
        slab->cache >= &kmem_caches[0] && 
ffffffffc0201688:	00005797          	auipc	a5,0x5
ffffffffc020168c:	d3878793          	addi	a5,a5,-712 # ffffffffc02063c0 <names.0>
ffffffffc0201690:	9ef573e3          	bgeu	a0,a5,ffffffffc0201076 <slub_check+0xd6>
        kmem_cache_free(slab->cache, objp);
ffffffffc0201694:	85ce                	mv	a1,s3
ffffffffc0201696:	fbcff0ef          	jal	ra,ffffffffc0200e52 <kmem_cache_free>
ffffffffc020169a:	b2e5                	j	ffffffffc0201082 <slub_check+0xe2>
            return &kmem_caches[i];
ffffffffc020169c:	00379513          	slli	a0,a5,0x3
ffffffffc02016a0:	97aa                	add	a5,a5,a0
ffffffffc02016a2:	00379513          	slli	a0,a5,0x3
    return kmem_cache_alloc(cache);
ffffffffc02016a6:	9522                	add	a0,a0,s0
ffffffffc02016a8:	e1cff0ef          	jal	ra,ffffffffc0200cc4 <kmem_cache_alloc>
    assert(p_max != NULL);
ffffffffc02016ac:	e6050ee3          	beqz	a0,ffffffffc0201528 <slub_check+0x588>
    uintptr_t page_addr = ROUNDDOWN((uintptr_t)objp, PGSIZE);
ffffffffc02016b0:	77fd                	lui	a5,0xfffff
ffffffffc02016b2:	8fe9                	and	a5,a5,a0
    if (slab->cache != NULL && 
ffffffffc02016b4:	739c                	ld	a5,32(a5)
ffffffffc02016b6:	cb89                	beqz	a5,ffffffffc02016c8 <slub_check+0x728>
ffffffffc02016b8:	0087e863          	bltu	a5,s0,ffffffffc02016c8 <slub_check+0x728>
        slab->cache >= &kmem_caches[0] && 
ffffffffc02016bc:	00005717          	auipc	a4,0x5
ffffffffc02016c0:	d0470713          	addi	a4,a4,-764 # ffffffffc02063c0 <names.0>
ffffffffc02016c4:	10e7e163          	bltu	a5,a4,ffffffffc02017c6 <slub_check+0x826>
        cprintf("Warning: slub_free called on direct page allocation\n");
ffffffffc02016c8:	00001517          	auipc	a0,0x1
ffffffffc02016cc:	cd050513          	addi	a0,a0,-816 # ffffffffc0202398 <buddy_pmm_manager+0x2e0>
ffffffffc02016d0:	a7dfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    slub_free(p_max);
    cprintf("  Test 5 passed!\n");
ffffffffc02016d4:	00001517          	auipc	a0,0x1
ffffffffc02016d8:	f6c50513          	addi	a0,a0,-148 # ffffffffc0202640 <buddy_pmm_manager+0x588>
ffffffffc02016dc:	a71fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 测试6: 内存写入测试
    cprintf("Test 6: Memory write test\n");
ffffffffc02016e0:	00001517          	auipc	a0,0x1
ffffffffc02016e4:	f7850513          	addi	a0,a0,-136 # ffffffffc0202658 <buddy_pmm_manager+0x5a0>
ffffffffc02016e8:	a65fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc02016ec:	4781                	li	a5,0
ffffffffc02016ee:	46a1                	li	a3,8
        if (cache_sizes[i] >= size) {
ffffffffc02016f0:	02700613          	li	a2,39
ffffffffc02016f4:	a031                	j	ffffffffc0201700 <slub_check+0x760>
ffffffffc02016f6:	00893703          	ld	a4,8(s2)
ffffffffc02016fa:	0921                	addi	s2,s2,8
ffffffffc02016fc:	02e66563          	bltu	a2,a4,ffffffffc0201726 <slub_check+0x786>
    for (int i = 0; i < SLUB_CACHE_NUM; i++) {
ffffffffc0201700:	2785                	addiw	a5,a5,1
ffffffffc0201702:	fed79ae3          	bne	a5,a3,ffffffffc02016f6 <slub_check+0x756>
    int *pi = (int *)slub_alloc(sizeof(int) * 10);
    assert(pi != NULL);
ffffffffc0201706:	00001697          	auipc	a3,0x1
ffffffffc020170a:	f7268693          	addi	a3,a3,-142 # ffffffffc0202678 <buddy_pmm_manager+0x5c0>
ffffffffc020170e:	00001617          	auipc	a2,0x1
ffffffffc0201712:	8fa60613          	addi	a2,a2,-1798 # ffffffffc0202008 <etext+0x26c>
ffffffffc0201716:	19400593          	li	a1,404
ffffffffc020171a:	00001517          	auipc	a0,0x1
ffffffffc020171e:	b8650513          	addi	a0,a0,-1146 # ffffffffc02022a0 <buddy_pmm_manager+0x1e8>
ffffffffc0201722:	aa1fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
            return &kmem_caches[i];
ffffffffc0201726:	00379513          	slli	a0,a5,0x3
ffffffffc020172a:	97aa                	add	a5,a5,a0
ffffffffc020172c:	00379513          	slli	a0,a5,0x3
    return kmem_cache_alloc(cache);
ffffffffc0201730:	9522                	add	a0,a0,s0
ffffffffc0201732:	d92ff0ef          	jal	ra,ffffffffc0200cc4 <kmem_cache_alloc>
    assert(pi != NULL);
ffffffffc0201736:	872a                	mv	a4,a0
    for (int i = 0; i < 10; i++) {
ffffffffc0201738:	4781                	li	a5,0
ffffffffc020173a:	4629                	li	a2,10
    assert(pi != NULL);
ffffffffc020173c:	d569                	beqz	a0,ffffffffc0201706 <slub_check+0x766>
        pi[i] = i * i;
ffffffffc020173e:	02f786bb          	mulw	a3,a5,a5
    for (int i = 0; i < 10; i++) {
ffffffffc0201742:	2785                	addiw	a5,a5,1
ffffffffc0201744:	0711                	addi	a4,a4,4
        pi[i] = i * i;
ffffffffc0201746:	fed72e23          	sw	a3,-4(a4)
    for (int i = 0; i < 10; i++) {
ffffffffc020174a:	fec79ae3          	bne	a5,a2,ffffffffc020173e <slub_check+0x79e>
ffffffffc020174e:	86aa                	mv	a3,a0
    }
    for (int i = 0; i < 10; i++) {
ffffffffc0201750:	4781                	li	a5,0
ffffffffc0201752:	4829                	li	a6,10
        assert(pi[i] == i * i);
ffffffffc0201754:	02f7873b          	mulw	a4,a5,a5
ffffffffc0201758:	4290                	lw	a2,0(a3)
ffffffffc020175a:	0ae61463          	bne	a2,a4,ffffffffc0201802 <slub_check+0x862>
    for (int i = 0; i < 10; i++) {
ffffffffc020175e:	2785                	addiw	a5,a5,1
ffffffffc0201760:	0691                	addi	a3,a3,4
ffffffffc0201762:	ff0799e3          	bne	a5,a6,ffffffffc0201754 <slub_check+0x7b4>
    uintptr_t page_addr = ROUNDDOWN((uintptr_t)objp, PGSIZE);
ffffffffc0201766:	77fd                	lui	a5,0xfffff
ffffffffc0201768:	8fe9                	and	a5,a5,a0
    if (slab->cache != NULL && 
ffffffffc020176a:	739c                	ld	a5,32(a5)
ffffffffc020176c:	cb89                	beqz	a5,ffffffffc020177e <slub_check+0x7de>
ffffffffc020176e:	0087e863          	bltu	a5,s0,ffffffffc020177e <slub_check+0x7de>
        slab->cache >= &kmem_caches[0] && 
ffffffffc0201772:	00005717          	auipc	a4,0x5
ffffffffc0201776:	c4e70713          	addi	a4,a4,-946 # ffffffffc02063c0 <names.0>
ffffffffc020177a:	04e7e163          	bltu	a5,a4,ffffffffc02017bc <slub_check+0x81c>
        cprintf("Warning: slub_free called on direct page allocation\n");
ffffffffc020177e:	00001517          	auipc	a0,0x1
ffffffffc0201782:	c1a50513          	addi	a0,a0,-998 # ffffffffc0202398 <buddy_pmm_manager+0x2e0>
ffffffffc0201786:	9c7fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    }
    slub_free(pi);
    cprintf("  Test 6 passed!\n");
ffffffffc020178a:	00001517          	auipc	a0,0x1
ffffffffc020178e:	f0e50513          	addi	a0,a0,-242 # ffffffffc0202698 <buddy_pmm_manager+0x5e0>
ffffffffc0201792:	9bbfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    cprintf("=== SLUB allocator check passed! ===\n");
}
ffffffffc0201796:	740a                	ld	s0,160(sp)
ffffffffc0201798:	70aa                	ld	ra,168(sp)
ffffffffc020179a:	64ea                	ld	s1,152(sp)
ffffffffc020179c:	694a                	ld	s2,144(sp)
ffffffffc020179e:	69aa                	ld	s3,136(sp)
ffffffffc02017a0:	6a0a                	ld	s4,128(sp)
ffffffffc02017a2:	7ae6                	ld	s5,120(sp)
ffffffffc02017a4:	7b46                	ld	s6,112(sp)
ffffffffc02017a6:	7ba6                	ld	s7,104(sp)
ffffffffc02017a8:	7c06                	ld	s8,96(sp)
ffffffffc02017aa:	6ce6                	ld	s9,88(sp)
ffffffffc02017ac:	6d46                	ld	s10,80(sp)
    cprintf("=== SLUB allocator check passed! ===\n");
ffffffffc02017ae:	00001517          	auipc	a0,0x1
ffffffffc02017b2:	f0250513          	addi	a0,a0,-254 # ffffffffc02026b0 <buddy_pmm_manager+0x5f8>
}
ffffffffc02017b6:	614d                	addi	sp,sp,176
    cprintf("=== SLUB allocator check passed! ===\n");
ffffffffc02017b8:	995fe06f          	j	ffffffffc020014c <cprintf>
        kmem_cache_free(slab->cache, objp);
ffffffffc02017bc:	85aa                	mv	a1,a0
ffffffffc02017be:	853e                	mv	a0,a5
ffffffffc02017c0:	e92ff0ef          	jal	ra,ffffffffc0200e52 <kmem_cache_free>
ffffffffc02017c4:	b7d9                	j	ffffffffc020178a <slub_check+0x7ea>
ffffffffc02017c6:	85aa                	mv	a1,a0
ffffffffc02017c8:	853e                	mv	a0,a5
ffffffffc02017ca:	e88ff0ef          	jal	ra,ffffffffc0200e52 <kmem_cache_free>
ffffffffc02017ce:	b719                	j	ffffffffc02016d4 <slub_check+0x734>
ffffffffc02017d0:	85aa                	mv	a1,a0
ffffffffc02017d2:	853e                	mv	a0,a5
ffffffffc02017d4:	e7eff0ef          	jal	ra,ffffffffc0200e52 <kmem_cache_free>
ffffffffc02017d8:	bb05                	j	ffffffffc0201508 <slub_check+0x568>
ffffffffc02017da:	85e2                	mv	a1,s8
ffffffffc02017dc:	e76ff0ef          	jal	ra,ffffffffc0200e52 <kmem_cache_free>
ffffffffc02017e0:	b9f1                	j	ffffffffc02014bc <slub_check+0x51c>
        assert(objs[i] != NULL);
ffffffffc02017e2:	00001697          	auipc	a3,0x1
ffffffffc02017e6:	dce68693          	addi	a3,a3,-562 # ffffffffc02025b0 <buddy_pmm_manager+0x4f8>
ffffffffc02017ea:	00001617          	auipc	a2,0x1
ffffffffc02017ee:	81e60613          	addi	a2,a2,-2018 # ffffffffc0202008 <etext+0x26c>
ffffffffc02017f2:	16700593          	li	a1,359
ffffffffc02017f6:	00001517          	auipc	a0,0x1
ffffffffc02017fa:	aaa50513          	addi	a0,a0,-1366 # ffffffffc02022a0 <buddy_pmm_manager+0x1e8>
ffffffffc02017fe:	9c5fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(pi[i] == i * i);
ffffffffc0201802:	00001697          	auipc	a3,0x1
ffffffffc0201806:	e8668693          	addi	a3,a3,-378 # ffffffffc0202688 <buddy_pmm_manager+0x5d0>
ffffffffc020180a:	00000617          	auipc	a2,0x0
ffffffffc020180e:	7fe60613          	addi	a2,a2,2046 # ffffffffc0202008 <etext+0x26c>
ffffffffc0201812:	19900593          	li	a1,409
ffffffffc0201816:	00001517          	auipc	a0,0x1
ffffffffc020181a:	a8a50513          	addi	a0,a0,-1398 # ffffffffc02022a0 <buddy_pmm_manager+0x1e8>
ffffffffc020181e:	9a5fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p_small != NULL);
ffffffffc0201822:	00001697          	auipc	a3,0x1
ffffffffc0201826:	dfe68693          	addi	a3,a3,-514 # ffffffffc0202620 <buddy_pmm_manager+0x568>
ffffffffc020182a:	00000617          	auipc	a2,0x0
ffffffffc020182e:	7de60613          	addi	a2,a2,2014 # ffffffffc0202008 <etext+0x26c>
ffffffffc0201832:	18900593          	li	a1,393
ffffffffc0201836:	00001517          	auipc	a0,0x1
ffffffffc020183a:	a6a50513          	addi	a0,a0,-1430 # ffffffffc02022a0 <buddy_pmm_manager+0x1e8>
ffffffffc020183e:	985fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p1 != p2);
ffffffffc0201842:	00001697          	auipc	a3,0x1
ffffffffc0201846:	b1e68693          	addi	a3,a3,-1250 # ffffffffc0202360 <buddy_pmm_manager+0x2a8>
ffffffffc020184a:	00000617          	auipc	a2,0x0
ffffffffc020184e:	7be60613          	addi	a2,a2,1982 # ffffffffc0202008 <etext+0x26c>
ffffffffc0201852:	13000593          	li	a1,304
ffffffffc0201856:	00001517          	auipc	a0,0x1
ffffffffc020185a:	a4a50513          	addi	a0,a0,-1462 # ffffffffc02022a0 <buddy_pmm_manager+0x1e8>
ffffffffc020185e:	965fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p256 != NULL && p512 != NULL && p1024 != NULL && p2048 != NULL);
ffffffffc0201862:	00001697          	auipc	a3,0x1
ffffffffc0201866:	c3668693          	addi	a3,a3,-970 # ffffffffc0202498 <buddy_pmm_manager+0x3e0>
ffffffffc020186a:	00000617          	auipc	a2,0x0
ffffffffc020186e:	79e60613          	addi	a2,a2,1950 # ffffffffc0202008 <etext+0x26c>
ffffffffc0201872:	15000593          	li	a1,336
ffffffffc0201876:	00001517          	auipc	a0,0x1
ffffffffc020187a:	a2a50513          	addi	a0,a0,-1494 # ffffffffc02022a0 <buddy_pmm_manager+0x1e8>
ffffffffc020187e:	945fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p16 != NULL && p32 != NULL && p64 != NULL && p128 != NULL);
ffffffffc0201882:	00001697          	auipc	a3,0x1
ffffffffc0201886:	bd668693          	addi	a3,a3,-1066 # ffffffffc0202458 <buddy_pmm_manager+0x3a0>
ffffffffc020188a:	00000617          	auipc	a2,0x0
ffffffffc020188e:	77e60613          	addi	a2,a2,1918 # ffffffffc0202008 <etext+0x26c>
ffffffffc0201892:	14f00593          	li	a1,335
ffffffffc0201896:	00001517          	auipc	a0,0x1
ffffffffc020189a:	a0a50513          	addi	a0,a0,-1526 # ffffffffc02022a0 <buddy_pmm_manager+0x1e8>
ffffffffc020189e:	925fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    int num_objs = cache->num * 3; // 分配3个slab的对象
ffffffffc02018a2:	00803783          	ld	a5,8(zero) # 8 <kern_entry-0xffffffffc01ffff8>
ffffffffc02018a6:	9002                	ebreak

ffffffffc02018a8 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02018a8:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02018ac:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02018ae:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02018b2:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02018b4:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02018b8:	f022                	sd	s0,32(sp)
ffffffffc02018ba:	ec26                	sd	s1,24(sp)
ffffffffc02018bc:	e84a                	sd	s2,16(sp)
ffffffffc02018be:	f406                	sd	ra,40(sp)
ffffffffc02018c0:	e44e                	sd	s3,8(sp)
ffffffffc02018c2:	84aa                	mv	s1,a0
ffffffffc02018c4:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02018c6:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02018ca:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02018cc:	03067e63          	bgeu	a2,a6,ffffffffc0201908 <printnum+0x60>
ffffffffc02018d0:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02018d2:	00805763          	blez	s0,ffffffffc02018e0 <printnum+0x38>
ffffffffc02018d6:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02018d8:	85ca                	mv	a1,s2
ffffffffc02018da:	854e                	mv	a0,s3
ffffffffc02018dc:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02018de:	fc65                	bnez	s0,ffffffffc02018d6 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02018e0:	1a02                	slli	s4,s4,0x20
ffffffffc02018e2:	00001797          	auipc	a5,0x1
ffffffffc02018e6:	e8678793          	addi	a5,a5,-378 # ffffffffc0202768 <slub_pmm_manager+0x38>
ffffffffc02018ea:	020a5a13          	srli	s4,s4,0x20
ffffffffc02018ee:	9a3e                	add	s4,s4,a5
}
ffffffffc02018f0:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02018f2:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02018f6:	70a2                	ld	ra,40(sp)
ffffffffc02018f8:	69a2                	ld	s3,8(sp)
ffffffffc02018fa:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02018fc:	85ca                	mv	a1,s2
ffffffffc02018fe:	87a6                	mv	a5,s1
}
ffffffffc0201900:	6942                	ld	s2,16(sp)
ffffffffc0201902:	64e2                	ld	s1,24(sp)
ffffffffc0201904:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201906:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201908:	03065633          	divu	a2,a2,a6
ffffffffc020190c:	8722                	mv	a4,s0
ffffffffc020190e:	f9bff0ef          	jal	ra,ffffffffc02018a8 <printnum>
ffffffffc0201912:	b7f9                	j	ffffffffc02018e0 <printnum+0x38>

ffffffffc0201914 <sprintputch>:
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
    b->cnt ++;
ffffffffc0201914:	499c                	lw	a5,16(a1)
    if (b->buf < b->ebuf) {
ffffffffc0201916:	6198                	ld	a4,0(a1)
ffffffffc0201918:	6594                	ld	a3,8(a1)
    b->cnt ++;
ffffffffc020191a:	2785                	addiw	a5,a5,1
ffffffffc020191c:	c99c                	sw	a5,16(a1)
    if (b->buf < b->ebuf) {
ffffffffc020191e:	00d77763          	bgeu	a4,a3,ffffffffc020192c <sprintputch+0x18>
        *b->buf ++ = ch;
ffffffffc0201922:	00170793          	addi	a5,a4,1
ffffffffc0201926:	e19c                	sd	a5,0(a1)
ffffffffc0201928:	00a70023          	sb	a0,0(a4)
    }
}
ffffffffc020192c:	8082                	ret

ffffffffc020192e <vprintfmt>:
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020192e:	7119                	addi	sp,sp,-128
ffffffffc0201930:	f4a6                	sd	s1,104(sp)
ffffffffc0201932:	f0ca                	sd	s2,96(sp)
ffffffffc0201934:	ecce                	sd	s3,88(sp)
ffffffffc0201936:	e8d2                	sd	s4,80(sp)
ffffffffc0201938:	e4d6                	sd	s5,72(sp)
ffffffffc020193a:	e0da                	sd	s6,64(sp)
ffffffffc020193c:	fc5e                	sd	s7,56(sp)
ffffffffc020193e:	f06a                	sd	s10,32(sp)
ffffffffc0201940:	fc86                	sd	ra,120(sp)
ffffffffc0201942:	f8a2                	sd	s0,112(sp)
ffffffffc0201944:	f862                	sd	s8,48(sp)
ffffffffc0201946:	f466                	sd	s9,40(sp)
ffffffffc0201948:	ec6e                	sd	s11,24(sp)
ffffffffc020194a:	892a                	mv	s2,a0
ffffffffc020194c:	84ae                	mv	s1,a1
ffffffffc020194e:	8d32                	mv	s10,a2
ffffffffc0201950:	8a36                	mv	s4,a3
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201952:	02500993          	li	s3,37
        width = precision = -1;
ffffffffc0201956:	5b7d                	li	s6,-1
ffffffffc0201958:	00001a97          	auipc	s5,0x1
ffffffffc020195c:	e44a8a93          	addi	s5,s5,-444 # ffffffffc020279c <slub_pmm_manager+0x6c>
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201960:	00001b97          	auipc	s7,0x1
ffffffffc0201964:	018b8b93          	addi	s7,s7,24 # ffffffffc0202978 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201968:	000d4503          	lbu	a0,0(s10)
ffffffffc020196c:	001d0413          	addi	s0,s10,1
ffffffffc0201970:	01350a63          	beq	a0,s3,ffffffffc0201984 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201974:	c121                	beqz	a0,ffffffffc02019b4 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201976:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201978:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020197a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020197c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201980:	ff351ae3          	bne	a0,s3,ffffffffc0201974 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201984:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201988:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020198c:	4c81                	li	s9,0
ffffffffc020198e:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201990:	5c7d                	li	s8,-1
ffffffffc0201992:	5dfd                	li	s11,-1
ffffffffc0201994:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201998:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020199a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020199e:	0ff5f593          	zext.b	a1,a1
ffffffffc02019a2:	00140d13          	addi	s10,s0,1
ffffffffc02019a6:	04b56263          	bltu	a0,a1,ffffffffc02019ea <vprintfmt+0xbc>
ffffffffc02019aa:	058a                	slli	a1,a1,0x2
ffffffffc02019ac:	95d6                	add	a1,a1,s5
ffffffffc02019ae:	4194                	lw	a3,0(a1)
ffffffffc02019b0:	96d6                	add	a3,a3,s5
ffffffffc02019b2:	8682                	jr	a3
}
ffffffffc02019b4:	70e6                	ld	ra,120(sp)
ffffffffc02019b6:	7446                	ld	s0,112(sp)
ffffffffc02019b8:	74a6                	ld	s1,104(sp)
ffffffffc02019ba:	7906                	ld	s2,96(sp)
ffffffffc02019bc:	69e6                	ld	s3,88(sp)
ffffffffc02019be:	6a46                	ld	s4,80(sp)
ffffffffc02019c0:	6aa6                	ld	s5,72(sp)
ffffffffc02019c2:	6b06                	ld	s6,64(sp)
ffffffffc02019c4:	7be2                	ld	s7,56(sp)
ffffffffc02019c6:	7c42                	ld	s8,48(sp)
ffffffffc02019c8:	7ca2                	ld	s9,40(sp)
ffffffffc02019ca:	7d02                	ld	s10,32(sp)
ffffffffc02019cc:	6de2                	ld	s11,24(sp)
ffffffffc02019ce:	6109                	addi	sp,sp,128
ffffffffc02019d0:	8082                	ret
            padc = '0';
ffffffffc02019d2:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02019d4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02019d8:	846a                	mv	s0,s10
ffffffffc02019da:	00140d13          	addi	s10,s0,1
ffffffffc02019de:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02019e2:	0ff5f593          	zext.b	a1,a1
ffffffffc02019e6:	fcb572e3          	bgeu	a0,a1,ffffffffc02019aa <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02019ea:	85a6                	mv	a1,s1
ffffffffc02019ec:	02500513          	li	a0,37
ffffffffc02019f0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02019f2:	fff44783          	lbu	a5,-1(s0)
ffffffffc02019f6:	8d22                	mv	s10,s0
ffffffffc02019f8:	f73788e3          	beq	a5,s3,ffffffffc0201968 <vprintfmt+0x3a>
ffffffffc02019fc:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201a00:	1d7d                	addi	s10,s10,-1
ffffffffc0201a02:	ff379de3          	bne	a5,s3,ffffffffc02019fc <vprintfmt+0xce>
ffffffffc0201a06:	b78d                	j	ffffffffc0201968 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201a08:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201a0c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a10:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201a12:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201a16:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201a1a:	02d86463          	bltu	a6,a3,ffffffffc0201a42 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201a1e:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201a22:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201a26:	0186873b          	addw	a4,a3,s8
ffffffffc0201a2a:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201a2e:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201a30:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201a34:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201a36:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201a3a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201a3e:	fed870e3          	bgeu	a6,a3,ffffffffc0201a1e <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201a42:	f40ddce3          	bgez	s11,ffffffffc020199a <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201a46:	8de2                	mv	s11,s8
ffffffffc0201a48:	5c7d                	li	s8,-1
ffffffffc0201a4a:	bf81                	j	ffffffffc020199a <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201a4c:	fffdc693          	not	a3,s11
ffffffffc0201a50:	96fd                	srai	a3,a3,0x3f
ffffffffc0201a52:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a56:	00144603          	lbu	a2,1(s0)
ffffffffc0201a5a:	2d81                	sext.w	s11,s11
ffffffffc0201a5c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201a5e:	bf35                	j	ffffffffc020199a <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201a60:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a64:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201a68:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a6a:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201a6c:	bfd9                	j	ffffffffc0201a42 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201a6e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201a70:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201a74:	01174463          	blt	a4,a7,ffffffffc0201a7c <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201a78:	1a088e63          	beqz	a7,ffffffffc0201c34 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201a7c:	000a3603          	ld	a2,0(s4)
ffffffffc0201a80:	46c1                	li	a3,16
ffffffffc0201a82:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201a84:	2781                	sext.w	a5,a5
ffffffffc0201a86:	876e                	mv	a4,s11
ffffffffc0201a88:	85a6                	mv	a1,s1
ffffffffc0201a8a:	854a                	mv	a0,s2
ffffffffc0201a8c:	e1dff0ef          	jal	ra,ffffffffc02018a8 <printnum>
            break;
ffffffffc0201a90:	bde1                	j	ffffffffc0201968 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201a92:	000a2503          	lw	a0,0(s4)
ffffffffc0201a96:	85a6                	mv	a1,s1
ffffffffc0201a98:	0a21                	addi	s4,s4,8
ffffffffc0201a9a:	9902                	jalr	s2
            break;
ffffffffc0201a9c:	b5f1                	j	ffffffffc0201968 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201a9e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201aa0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201aa4:	01174463          	blt	a4,a7,ffffffffc0201aac <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201aa8:	18088163          	beqz	a7,ffffffffc0201c2a <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201aac:	000a3603          	ld	a2,0(s4)
ffffffffc0201ab0:	46a9                	li	a3,10
ffffffffc0201ab2:	8a2e                	mv	s4,a1
ffffffffc0201ab4:	bfc1                	j	ffffffffc0201a84 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201ab6:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201aba:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201abc:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201abe:	bdf1                	j	ffffffffc020199a <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201ac0:	85a6                	mv	a1,s1
ffffffffc0201ac2:	02500513          	li	a0,37
ffffffffc0201ac6:	9902                	jalr	s2
            break;
ffffffffc0201ac8:	b545                	j	ffffffffc0201968 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201aca:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201ace:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201ad0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201ad2:	b5e1                	j	ffffffffc020199a <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201ad4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201ad6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201ada:	01174463          	blt	a4,a7,ffffffffc0201ae2 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201ade:	14088163          	beqz	a7,ffffffffc0201c20 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201ae2:	000a3603          	ld	a2,0(s4)
ffffffffc0201ae6:	46a1                	li	a3,8
ffffffffc0201ae8:	8a2e                	mv	s4,a1
ffffffffc0201aea:	bf69                	j	ffffffffc0201a84 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201aec:	03000513          	li	a0,48
ffffffffc0201af0:	85a6                	mv	a1,s1
ffffffffc0201af2:	e03e                	sd	a5,0(sp)
ffffffffc0201af4:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201af6:	85a6                	mv	a1,s1
ffffffffc0201af8:	07800513          	li	a0,120
ffffffffc0201afc:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201afe:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201b00:	6782                	ld	a5,0(sp)
ffffffffc0201b02:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201b04:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201b08:	bfb5                	j	ffffffffc0201a84 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201b0a:	000a3403          	ld	s0,0(s4)
ffffffffc0201b0e:	008a0713          	addi	a4,s4,8
ffffffffc0201b12:	e03a                	sd	a4,0(sp)
ffffffffc0201b14:	14040263          	beqz	s0,ffffffffc0201c58 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201b18:	0fb05763          	blez	s11,ffffffffc0201c06 <vprintfmt+0x2d8>
ffffffffc0201b1c:	02d00693          	li	a3,45
ffffffffc0201b20:	0cd79163          	bne	a5,a3,ffffffffc0201be2 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201b24:	00044783          	lbu	a5,0(s0)
ffffffffc0201b28:	0007851b          	sext.w	a0,a5
ffffffffc0201b2c:	cf85                	beqz	a5,ffffffffc0201b64 <vprintfmt+0x236>
ffffffffc0201b2e:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201b32:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201b36:	000c4563          	bltz	s8,ffffffffc0201b40 <vprintfmt+0x212>
ffffffffc0201b3a:	3c7d                	addiw	s8,s8,-1
ffffffffc0201b3c:	036c0263          	beq	s8,s6,ffffffffc0201b60 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201b40:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201b42:	0e0c8e63          	beqz	s9,ffffffffc0201c3e <vprintfmt+0x310>
ffffffffc0201b46:	3781                	addiw	a5,a5,-32
ffffffffc0201b48:	0ef47b63          	bgeu	s0,a5,ffffffffc0201c3e <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201b4c:	03f00513          	li	a0,63
ffffffffc0201b50:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201b52:	000a4783          	lbu	a5,0(s4)
ffffffffc0201b56:	3dfd                	addiw	s11,s11,-1
ffffffffc0201b58:	0a05                	addi	s4,s4,1
ffffffffc0201b5a:	0007851b          	sext.w	a0,a5
ffffffffc0201b5e:	ffe1                	bnez	a5,ffffffffc0201b36 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201b60:	01b05963          	blez	s11,ffffffffc0201b72 <vprintfmt+0x244>
ffffffffc0201b64:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201b66:	85a6                	mv	a1,s1
ffffffffc0201b68:	02000513          	li	a0,32
ffffffffc0201b6c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201b6e:	fe0d9be3          	bnez	s11,ffffffffc0201b64 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201b72:	6a02                	ld	s4,0(sp)
ffffffffc0201b74:	bbd5                	j	ffffffffc0201968 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201b76:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201b78:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201b7c:	01174463          	blt	a4,a7,ffffffffc0201b84 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201b80:	08088d63          	beqz	a7,ffffffffc0201c1a <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201b84:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201b88:	0a044d63          	bltz	s0,ffffffffc0201c42 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201b8c:	8622                	mv	a2,s0
ffffffffc0201b8e:	8a66                	mv	s4,s9
ffffffffc0201b90:	46a9                	li	a3,10
ffffffffc0201b92:	bdcd                	j	ffffffffc0201a84 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201b94:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201b98:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201b9a:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201b9c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201ba0:	8fb5                	xor	a5,a5,a3
ffffffffc0201ba2:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201ba6:	02d74163          	blt	a4,a3,ffffffffc0201bc8 <vprintfmt+0x29a>
ffffffffc0201baa:	00369793          	slli	a5,a3,0x3
ffffffffc0201bae:	97de                	add	a5,a5,s7
ffffffffc0201bb0:	639c                	ld	a5,0(a5)
ffffffffc0201bb2:	cb99                	beqz	a5,ffffffffc0201bc8 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201bb4:	86be                	mv	a3,a5
ffffffffc0201bb6:	00001617          	auipc	a2,0x1
ffffffffc0201bba:	be260613          	addi	a2,a2,-1054 # ffffffffc0202798 <slub_pmm_manager+0x68>
ffffffffc0201bbe:	85a6                	mv	a1,s1
ffffffffc0201bc0:	854a                	mv	a0,s2
ffffffffc0201bc2:	0ce000ef          	jal	ra,ffffffffc0201c90 <printfmt>
ffffffffc0201bc6:	b34d                	j	ffffffffc0201968 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201bc8:	00001617          	auipc	a2,0x1
ffffffffc0201bcc:	bc060613          	addi	a2,a2,-1088 # ffffffffc0202788 <slub_pmm_manager+0x58>
ffffffffc0201bd0:	85a6                	mv	a1,s1
ffffffffc0201bd2:	854a                	mv	a0,s2
ffffffffc0201bd4:	0bc000ef          	jal	ra,ffffffffc0201c90 <printfmt>
ffffffffc0201bd8:	bb41                	j	ffffffffc0201968 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201bda:	00001417          	auipc	s0,0x1
ffffffffc0201bde:	ba640413          	addi	s0,s0,-1114 # ffffffffc0202780 <slub_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201be2:	85e2                	mv	a1,s8
ffffffffc0201be4:	8522                	mv	a0,s0
ffffffffc0201be6:	e43e                	sd	a5,8(sp)
ffffffffc0201be8:	142000ef          	jal	ra,ffffffffc0201d2a <strnlen>
ffffffffc0201bec:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201bf0:	01b05b63          	blez	s11,ffffffffc0201c06 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201bf4:	67a2                	ld	a5,8(sp)
ffffffffc0201bf6:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201bfa:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201bfc:	85a6                	mv	a1,s1
ffffffffc0201bfe:	8552                	mv	a0,s4
ffffffffc0201c00:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201c02:	fe0d9ce3          	bnez	s11,ffffffffc0201bfa <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201c06:	00044783          	lbu	a5,0(s0)
ffffffffc0201c0a:	00140a13          	addi	s4,s0,1
ffffffffc0201c0e:	0007851b          	sext.w	a0,a5
ffffffffc0201c12:	d3a5                	beqz	a5,ffffffffc0201b72 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201c14:	05e00413          	li	s0,94
ffffffffc0201c18:	bf39                	j	ffffffffc0201b36 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201c1a:	000a2403          	lw	s0,0(s4)
ffffffffc0201c1e:	b7ad                	j	ffffffffc0201b88 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201c20:	000a6603          	lwu	a2,0(s4)
ffffffffc0201c24:	46a1                	li	a3,8
ffffffffc0201c26:	8a2e                	mv	s4,a1
ffffffffc0201c28:	bdb1                	j	ffffffffc0201a84 <vprintfmt+0x156>
ffffffffc0201c2a:	000a6603          	lwu	a2,0(s4)
ffffffffc0201c2e:	46a9                	li	a3,10
ffffffffc0201c30:	8a2e                	mv	s4,a1
ffffffffc0201c32:	bd89                	j	ffffffffc0201a84 <vprintfmt+0x156>
ffffffffc0201c34:	000a6603          	lwu	a2,0(s4)
ffffffffc0201c38:	46c1                	li	a3,16
ffffffffc0201c3a:	8a2e                	mv	s4,a1
ffffffffc0201c3c:	b5a1                	j	ffffffffc0201a84 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201c3e:	9902                	jalr	s2
ffffffffc0201c40:	bf09                	j	ffffffffc0201b52 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201c42:	85a6                	mv	a1,s1
ffffffffc0201c44:	02d00513          	li	a0,45
ffffffffc0201c48:	e03e                	sd	a5,0(sp)
ffffffffc0201c4a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201c4c:	6782                	ld	a5,0(sp)
ffffffffc0201c4e:	8a66                	mv	s4,s9
ffffffffc0201c50:	40800633          	neg	a2,s0
ffffffffc0201c54:	46a9                	li	a3,10
ffffffffc0201c56:	b53d                	j	ffffffffc0201a84 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201c58:	03b05163          	blez	s11,ffffffffc0201c7a <vprintfmt+0x34c>
ffffffffc0201c5c:	02d00693          	li	a3,45
ffffffffc0201c60:	f6d79de3          	bne	a5,a3,ffffffffc0201bda <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201c64:	00001417          	auipc	s0,0x1
ffffffffc0201c68:	b1c40413          	addi	s0,s0,-1252 # ffffffffc0202780 <slub_pmm_manager+0x50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201c6c:	02800793          	li	a5,40
ffffffffc0201c70:	02800513          	li	a0,40
ffffffffc0201c74:	00140a13          	addi	s4,s0,1
ffffffffc0201c78:	bd6d                	j	ffffffffc0201b32 <vprintfmt+0x204>
ffffffffc0201c7a:	00001a17          	auipc	s4,0x1
ffffffffc0201c7e:	b07a0a13          	addi	s4,s4,-1273 # ffffffffc0202781 <slub_pmm_manager+0x51>
ffffffffc0201c82:	02800513          	li	a0,40
ffffffffc0201c86:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201c8a:	05e00413          	li	s0,94
ffffffffc0201c8e:	b565                	j	ffffffffc0201b36 <vprintfmt+0x208>

ffffffffc0201c90 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201c90:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201c92:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201c96:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201c98:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201c9a:	ec06                	sd	ra,24(sp)
ffffffffc0201c9c:	f83a                	sd	a4,48(sp)
ffffffffc0201c9e:	fc3e                	sd	a5,56(sp)
ffffffffc0201ca0:	e0c2                	sd	a6,64(sp)
ffffffffc0201ca2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201ca4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201ca6:	c89ff0ef          	jal	ra,ffffffffc020192e <vprintfmt>
}
ffffffffc0201caa:	60e2                	ld	ra,24(sp)
ffffffffc0201cac:	6161                	addi	sp,sp,80
ffffffffc0201cae:	8082                	ret

ffffffffc0201cb0 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
ffffffffc0201cb0:	711d                	addi	sp,sp,-96
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
    struct sprintbuf b = {str, str + size - 1, 0};
ffffffffc0201cb2:	15fd                	addi	a1,a1,-1
    va_start(ap, fmt);
ffffffffc0201cb4:	03810313          	addi	t1,sp,56
    struct sprintbuf b = {str, str + size - 1, 0};
ffffffffc0201cb8:	95aa                	add	a1,a1,a0
snprintf(char *str, size_t size, const char *fmt, ...) {
ffffffffc0201cba:	f406                	sd	ra,40(sp)
ffffffffc0201cbc:	fc36                	sd	a3,56(sp)
ffffffffc0201cbe:	e0ba                	sd	a4,64(sp)
ffffffffc0201cc0:	e4be                	sd	a5,72(sp)
ffffffffc0201cc2:	e8c2                	sd	a6,80(sp)
ffffffffc0201cc4:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc0201cc6:	e01a                	sd	t1,0(sp)
    struct sprintbuf b = {str, str + size - 1, 0};
ffffffffc0201cc8:	e42a                	sd	a0,8(sp)
ffffffffc0201cca:	e82e                	sd	a1,16(sp)
ffffffffc0201ccc:	cc02                	sw	zero,24(sp)
    if (str == NULL || b.buf > b.ebuf) {
ffffffffc0201cce:	c115                	beqz	a0,ffffffffc0201cf2 <snprintf+0x42>
ffffffffc0201cd0:	02a5e163          	bltu	a1,a0,ffffffffc0201cf2 <snprintf+0x42>
        return -E_INVAL;
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
ffffffffc0201cd4:	00000517          	auipc	a0,0x0
ffffffffc0201cd8:	c4050513          	addi	a0,a0,-960 # ffffffffc0201914 <sprintputch>
ffffffffc0201cdc:	869a                	mv	a3,t1
ffffffffc0201cde:	002c                	addi	a1,sp,8
ffffffffc0201ce0:	c4fff0ef          	jal	ra,ffffffffc020192e <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
ffffffffc0201ce4:	67a2                	ld	a5,8(sp)
ffffffffc0201ce6:	00078023          	sb	zero,0(a5)
    return b.cnt;
ffffffffc0201cea:	4562                	lw	a0,24(sp)
}
ffffffffc0201cec:	70a2                	ld	ra,40(sp)
ffffffffc0201cee:	6125                	addi	sp,sp,96
ffffffffc0201cf0:	8082                	ret
        return -E_INVAL;
ffffffffc0201cf2:	5575                	li	a0,-3
ffffffffc0201cf4:	bfe5                	j	ffffffffc0201cec <snprintf+0x3c>

ffffffffc0201cf6 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201cf6:	4781                	li	a5,0
ffffffffc0201cf8:	00004717          	auipc	a4,0x4
ffffffffc0201cfc:	31873703          	ld	a4,792(a4) # ffffffffc0206010 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201d00:	88ba                	mv	a7,a4
ffffffffc0201d02:	852a                	mv	a0,a0
ffffffffc0201d04:	85be                	mv	a1,a5
ffffffffc0201d06:	863e                	mv	a2,a5
ffffffffc0201d08:	00000073          	ecall
ffffffffc0201d0c:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201d0e:	8082                	ret

ffffffffc0201d10 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0201d10:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0201d14:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0201d16:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0201d18:	cb81                	beqz	a5,ffffffffc0201d28 <strlen+0x18>
        cnt ++;
ffffffffc0201d1a:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0201d1c:	00a707b3          	add	a5,a4,a0
ffffffffc0201d20:	0007c783          	lbu	a5,0(a5)
ffffffffc0201d24:	fbfd                	bnez	a5,ffffffffc0201d1a <strlen+0xa>
ffffffffc0201d26:	8082                	ret
    }
    return cnt;
}
ffffffffc0201d28:	8082                	ret

ffffffffc0201d2a <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201d2a:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201d2c:	e589                	bnez	a1,ffffffffc0201d36 <strnlen+0xc>
ffffffffc0201d2e:	a811                	j	ffffffffc0201d42 <strnlen+0x18>
        cnt ++;
ffffffffc0201d30:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201d32:	00f58863          	beq	a1,a5,ffffffffc0201d42 <strnlen+0x18>
ffffffffc0201d36:	00f50733          	add	a4,a0,a5
ffffffffc0201d3a:	00074703          	lbu	a4,0(a4)
ffffffffc0201d3e:	fb6d                	bnez	a4,ffffffffc0201d30 <strnlen+0x6>
ffffffffc0201d40:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201d42:	852e                	mv	a0,a1
ffffffffc0201d44:	8082                	ret

ffffffffc0201d46 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201d46:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201d4a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201d4e:	cb89                	beqz	a5,ffffffffc0201d60 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201d50:	0505                	addi	a0,a0,1
ffffffffc0201d52:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201d54:	fee789e3          	beq	a5,a4,ffffffffc0201d46 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201d58:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201d5c:	9d19                	subw	a0,a0,a4
ffffffffc0201d5e:	8082                	ret
ffffffffc0201d60:	4501                	li	a0,0
ffffffffc0201d62:	bfed                	j	ffffffffc0201d5c <strcmp+0x16>

ffffffffc0201d64 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201d64:	c20d                	beqz	a2,ffffffffc0201d86 <strncmp+0x22>
ffffffffc0201d66:	962e                	add	a2,a2,a1
ffffffffc0201d68:	a031                	j	ffffffffc0201d74 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0201d6a:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201d6c:	00e79a63          	bne	a5,a4,ffffffffc0201d80 <strncmp+0x1c>
ffffffffc0201d70:	00b60b63          	beq	a2,a1,ffffffffc0201d86 <strncmp+0x22>
ffffffffc0201d74:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0201d78:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201d7a:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0201d7e:	f7f5                	bnez	a5,ffffffffc0201d6a <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201d80:	40e7853b          	subw	a0,a5,a4
}
ffffffffc0201d84:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201d86:	4501                	li	a0,0
ffffffffc0201d88:	8082                	ret

ffffffffc0201d8a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201d8a:	ca01                	beqz	a2,ffffffffc0201d9a <memset+0x10>
ffffffffc0201d8c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201d8e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201d90:	0785                	addi	a5,a5,1
ffffffffc0201d92:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201d96:	fec79de3          	bne	a5,a2,ffffffffc0201d90 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201d9a:	8082                	ret
