
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
ffffffffc0200000:	00006297          	auipc	t0,0x6
ffffffffc0200004:	00028293          	mv	t0,t0
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0206000 <boot_hartid>
ffffffffc020000c:	00006297          	auipc	t0,0x6
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0206008 <boot_dtb>
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
ffffffffc0200018:	c02052b7          	lui	t0,0xc0205
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
ffffffffc0200034:	18029073          	csrw	satp,t0
ffffffffc0200038:	12000073          	sfence.vma
ffffffffc020003c:	c0205137          	lui	sp,0xc0205
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
ffffffffc0200044:	0d828293          	addi	t0,t0,216 # ffffffffc02000d8 <kern_init>
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <print_kerninfo>:
ffffffffc020004a:	1141                	addi	sp,sp,-16
ffffffffc020004c:	00001517          	auipc	a0,0x1
ffffffffc0200050:	5b450513          	addi	a0,a0,1460 # ffffffffc0201600 <etext+0x2>
ffffffffc0200054:	e406                	sd	ra,8(sp)
ffffffffc0200056:	0f6000ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc020005a:	00000597          	auipc	a1,0x0
ffffffffc020005e:	07e58593          	addi	a1,a1,126 # ffffffffc02000d8 <kern_init>
ffffffffc0200062:	00001517          	auipc	a0,0x1
ffffffffc0200066:	5be50513          	addi	a0,a0,1470 # ffffffffc0201620 <etext+0x22>
ffffffffc020006a:	0e2000ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc020006e:	00001597          	auipc	a1,0x1
ffffffffc0200072:	59058593          	addi	a1,a1,1424 # ffffffffc02015fe <etext>
ffffffffc0200076:	00001517          	auipc	a0,0x1
ffffffffc020007a:	5ca50513          	addi	a0,a0,1482 # ffffffffc0201640 <etext+0x42>
ffffffffc020007e:	0ce000ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200082:	00006597          	auipc	a1,0x6
ffffffffc0200086:	f9658593          	addi	a1,a1,-106 # ffffffffc0206018 <free_area>
ffffffffc020008a:	00001517          	auipc	a0,0x1
ffffffffc020008e:	5d650513          	addi	a0,a0,1494 # ffffffffc0201660 <etext+0x62>
ffffffffc0200092:	0ba000ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200096:	00006597          	auipc	a1,0x6
ffffffffc020009a:	13a58593          	addi	a1,a1,314 # ffffffffc02061d0 <end>
ffffffffc020009e:	00001517          	auipc	a0,0x1
ffffffffc02000a2:	5e250513          	addi	a0,a0,1506 # ffffffffc0201680 <etext+0x82>
ffffffffc02000a6:	0a6000ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc02000aa:	00006597          	auipc	a1,0x6
ffffffffc02000ae:	52558593          	addi	a1,a1,1317 # ffffffffc02065cf <end+0x3ff>
ffffffffc02000b2:	00000797          	auipc	a5,0x0
ffffffffc02000b6:	02678793          	addi	a5,a5,38 # ffffffffc02000d8 <kern_init>
ffffffffc02000ba:	40f587b3          	sub	a5,a1,a5
ffffffffc02000be:	43f7d593          	srai	a1,a5,0x3f
ffffffffc02000c2:	60a2                	ld	ra,8(sp)
ffffffffc02000c4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02000c8:	95be                	add	a1,a1,a5
ffffffffc02000ca:	85a9                	srai	a1,a1,0xa
ffffffffc02000cc:	00001517          	auipc	a0,0x1
ffffffffc02000d0:	5d450513          	addi	a0,a0,1492 # ffffffffc02016a0 <etext+0xa2>
ffffffffc02000d4:	0141                	addi	sp,sp,16
ffffffffc02000d6:	a89d                	j	ffffffffc020014c <cprintf>

ffffffffc02000d8 <kern_init>:
ffffffffc02000d8:	00006517          	auipc	a0,0x6
ffffffffc02000dc:	f4050513          	addi	a0,a0,-192 # ffffffffc0206018 <free_area>
ffffffffc02000e0:	00006617          	auipc	a2,0x6
ffffffffc02000e4:	0f060613          	addi	a2,a2,240 # ffffffffc02061d0 <end>
ffffffffc02000e8:	1141                	addi	sp,sp,-16
ffffffffc02000ea:	8e09                	sub	a2,a2,a0
ffffffffc02000ec:	4581                	li	a1,0
ffffffffc02000ee:	e406                	sd	ra,8(sp)
ffffffffc02000f0:	4fc010ef          	jal	ra,ffffffffc02015ec <memset>
ffffffffc02000f4:	12c000ef          	jal	ra,ffffffffc0200220 <dtb_init>
ffffffffc02000f8:	11e000ef          	jal	ra,ffffffffc0200216 <cons_init>
ffffffffc02000fc:	00001517          	auipc	a0,0x1
ffffffffc0200100:	5d450513          	addi	a0,a0,1492 # ffffffffc02016d0 <etext+0xd2>
ffffffffc0200104:	07e000ef          	jal	ra,ffffffffc0200182 <cputs>
ffffffffc0200108:	f43ff0ef          	jal	ra,ffffffffc020004a <print_kerninfo>
ffffffffc020010c:	687000ef          	jal	ra,ffffffffc0200f92 <pmm_init>
ffffffffc0200110:	a001                	j	ffffffffc0200110 <kern_init+0x38>

ffffffffc0200112 <cputch>:
ffffffffc0200112:	1141                	addi	sp,sp,-16
ffffffffc0200114:	e022                	sd	s0,0(sp)
ffffffffc0200116:	e406                	sd	ra,8(sp)
ffffffffc0200118:	842e                	mv	s0,a1
ffffffffc020011a:	0fe000ef          	jal	ra,ffffffffc0200218 <cons_putc>
ffffffffc020011e:	401c                	lw	a5,0(s0)
ffffffffc0200120:	60a2                	ld	ra,8(sp)
ffffffffc0200122:	2785                	addiw	a5,a5,1
ffffffffc0200124:	c01c                	sw	a5,0(s0)
ffffffffc0200126:	6402                	ld	s0,0(sp)
ffffffffc0200128:	0141                	addi	sp,sp,16
ffffffffc020012a:	8082                	ret

ffffffffc020012c <vcprintf>:
ffffffffc020012c:	1101                	addi	sp,sp,-32
ffffffffc020012e:	862a                	mv	a2,a0
ffffffffc0200130:	86ae                	mv	a3,a1
ffffffffc0200132:	00000517          	auipc	a0,0x0
ffffffffc0200136:	fe050513          	addi	a0,a0,-32 # ffffffffc0200112 <cputch>
ffffffffc020013a:	006c                	addi	a1,sp,12
ffffffffc020013c:	ec06                	sd	ra,24(sp)
ffffffffc020013e:	c602                	sw	zero,12(sp)
ffffffffc0200140:	096010ef          	jal	ra,ffffffffc02011d6 <vprintfmt>
ffffffffc0200144:	60e2                	ld	ra,24(sp)
ffffffffc0200146:	4532                	lw	a0,12(sp)
ffffffffc0200148:	6105                	addi	sp,sp,32
ffffffffc020014a:	8082                	ret

ffffffffc020014c <cprintf>:
ffffffffc020014c:	711d                	addi	sp,sp,-96
ffffffffc020014e:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
ffffffffc0200152:	8e2a                	mv	t3,a0
ffffffffc0200154:	f42e                	sd	a1,40(sp)
ffffffffc0200156:	f832                	sd	a2,48(sp)
ffffffffc0200158:	fc36                	sd	a3,56(sp)
ffffffffc020015a:	00000517          	auipc	a0,0x0
ffffffffc020015e:	fb850513          	addi	a0,a0,-72 # ffffffffc0200112 <cputch>
ffffffffc0200162:	004c                	addi	a1,sp,4
ffffffffc0200164:	869a                	mv	a3,t1
ffffffffc0200166:	8672                	mv	a2,t3
ffffffffc0200168:	ec06                	sd	ra,24(sp)
ffffffffc020016a:	e0ba                	sd	a4,64(sp)
ffffffffc020016c:	e4be                	sd	a5,72(sp)
ffffffffc020016e:	e8c2                	sd	a6,80(sp)
ffffffffc0200170:	ecc6                	sd	a7,88(sp)
ffffffffc0200172:	e41a                	sd	t1,8(sp)
ffffffffc0200174:	c202                	sw	zero,4(sp)
ffffffffc0200176:	060010ef          	jal	ra,ffffffffc02011d6 <vprintfmt>
ffffffffc020017a:	60e2                	ld	ra,24(sp)
ffffffffc020017c:	4512                	lw	a0,4(sp)
ffffffffc020017e:	6125                	addi	sp,sp,96
ffffffffc0200180:	8082                	ret

ffffffffc0200182 <cputs>:
ffffffffc0200182:	1101                	addi	sp,sp,-32
ffffffffc0200184:	e822                	sd	s0,16(sp)
ffffffffc0200186:	ec06                	sd	ra,24(sp)
ffffffffc0200188:	e426                	sd	s1,8(sp)
ffffffffc020018a:	842a                	mv	s0,a0
ffffffffc020018c:	00054503          	lbu	a0,0(a0)
ffffffffc0200190:	c51d                	beqz	a0,ffffffffc02001be <cputs+0x3c>
ffffffffc0200192:	0405                	addi	s0,s0,1
ffffffffc0200194:	4485                	li	s1,1
ffffffffc0200196:	9c81                	subw	s1,s1,s0
ffffffffc0200198:	080000ef          	jal	ra,ffffffffc0200218 <cons_putc>
ffffffffc020019c:	00044503          	lbu	a0,0(s0)
ffffffffc02001a0:	008487bb          	addw	a5,s1,s0
ffffffffc02001a4:	0405                	addi	s0,s0,1
ffffffffc02001a6:	f96d                	bnez	a0,ffffffffc0200198 <cputs+0x16>
ffffffffc02001a8:	0017841b          	addiw	s0,a5,1
ffffffffc02001ac:	4529                	li	a0,10
ffffffffc02001ae:	06a000ef          	jal	ra,ffffffffc0200218 <cons_putc>
ffffffffc02001b2:	60e2                	ld	ra,24(sp)
ffffffffc02001b4:	8522                	mv	a0,s0
ffffffffc02001b6:	6442                	ld	s0,16(sp)
ffffffffc02001b8:	64a2                	ld	s1,8(sp)
ffffffffc02001ba:	6105                	addi	sp,sp,32
ffffffffc02001bc:	8082                	ret
ffffffffc02001be:	4405                	li	s0,1
ffffffffc02001c0:	b7f5                	j	ffffffffc02001ac <cputs+0x2a>

ffffffffc02001c2 <__panic>:
ffffffffc02001c2:	00006317          	auipc	t1,0x6
ffffffffc02001c6:	fbe30313          	addi	t1,t1,-66 # ffffffffc0206180 <is_panic>
ffffffffc02001ca:	00032e03          	lw	t3,0(t1)
ffffffffc02001ce:	715d                	addi	sp,sp,-80
ffffffffc02001d0:	ec06                	sd	ra,24(sp)
ffffffffc02001d2:	e822                	sd	s0,16(sp)
ffffffffc02001d4:	f436                	sd	a3,40(sp)
ffffffffc02001d6:	f83a                	sd	a4,48(sp)
ffffffffc02001d8:	fc3e                	sd	a5,56(sp)
ffffffffc02001da:	e0c2                	sd	a6,64(sp)
ffffffffc02001dc:	e4c6                	sd	a7,72(sp)
ffffffffc02001de:	000e0363          	beqz	t3,ffffffffc02001e4 <__panic+0x22>
ffffffffc02001e2:	a001                	j	ffffffffc02001e2 <__panic+0x20>
ffffffffc02001e4:	4785                	li	a5,1
ffffffffc02001e6:	00f32023          	sw	a5,0(t1)
ffffffffc02001ea:	8432                	mv	s0,a2
ffffffffc02001ec:	103c                	addi	a5,sp,40
ffffffffc02001ee:	862e                	mv	a2,a1
ffffffffc02001f0:	85aa                	mv	a1,a0
ffffffffc02001f2:	00001517          	auipc	a0,0x1
ffffffffc02001f6:	4fe50513          	addi	a0,a0,1278 # ffffffffc02016f0 <etext+0xf2>
ffffffffc02001fa:	e43e                	sd	a5,8(sp)
ffffffffc02001fc:	f51ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200200:	65a2                	ld	a1,8(sp)
ffffffffc0200202:	8522                	mv	a0,s0
ffffffffc0200204:	f29ff0ef          	jal	ra,ffffffffc020012c <vcprintf>
ffffffffc0200208:	00002517          	auipc	a0,0x2
ffffffffc020020c:	e1050513          	addi	a0,a0,-496 # ffffffffc0202018 <etext+0xa1a>
ffffffffc0200210:	f3dff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200214:	b7f9                	j	ffffffffc02001e2 <__panic+0x20>

ffffffffc0200216 <cons_init>:
ffffffffc0200216:	8082                	ret

ffffffffc0200218 <cons_putc>:
ffffffffc0200218:	0ff57513          	zext.b	a0,a0
ffffffffc020021c:	33c0106f          	j	ffffffffc0201558 <sbi_console_putchar>

ffffffffc0200220 <dtb_init>:
ffffffffc0200220:	7119                	addi	sp,sp,-128
ffffffffc0200222:	00001517          	auipc	a0,0x1
ffffffffc0200226:	4ee50513          	addi	a0,a0,1262 # ffffffffc0201710 <etext+0x112>
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
ffffffffc0200244:	f09ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200248:	00006597          	auipc	a1,0x6
ffffffffc020024c:	db85b583          	ld	a1,-584(a1) # ffffffffc0206000 <boot_hartid>
ffffffffc0200250:	00001517          	auipc	a0,0x1
ffffffffc0200254:	4d050513          	addi	a0,a0,1232 # ffffffffc0201720 <etext+0x122>
ffffffffc0200258:	ef5ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc020025c:	00006417          	auipc	s0,0x6
ffffffffc0200260:	dac40413          	addi	s0,s0,-596 # ffffffffc0206008 <boot_dtb>
ffffffffc0200264:	600c                	ld	a1,0(s0)
ffffffffc0200266:	00001517          	auipc	a0,0x1
ffffffffc020026a:	4ca50513          	addi	a0,a0,1226 # ffffffffc0201730 <etext+0x132>
ffffffffc020026e:	edfff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200272:	00043a03          	ld	s4,0(s0)
ffffffffc0200276:	00001517          	auipc	a0,0x1
ffffffffc020027a:	4d250513          	addi	a0,a0,1234 # ffffffffc0201748 <etext+0x14a>
ffffffffc020027e:	120a0463          	beqz	s4,ffffffffc02003a6 <dtb_init+0x186>
ffffffffc0200282:	57f5                	li	a5,-3
ffffffffc0200284:	07fa                	slli	a5,a5,0x1e
ffffffffc0200286:	00fa0733          	add	a4,s4,a5
ffffffffc020028a:	431c                	lw	a5,0(a4)
ffffffffc020028c:	00ff0637          	lui	a2,0xff0
ffffffffc0200290:	6b41                	lui	s6,0x10
ffffffffc0200292:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200296:	0187969b          	slliw	a3,a5,0x18
ffffffffc020029a:	0187d51b          	srliw	a0,a5,0x18
ffffffffc020029e:	0105959b          	slliw	a1,a1,0x10
ffffffffc02002a2:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02002a6:	8df1                	and	a1,a1,a2
ffffffffc02002a8:	8ec9                	or	a3,a3,a0
ffffffffc02002aa:	0087979b          	slliw	a5,a5,0x8
ffffffffc02002ae:	1b7d                	addi	s6,s6,-1
ffffffffc02002b0:	0167f7b3          	and	a5,a5,s6
ffffffffc02002b4:	8dd5                	or	a1,a1,a3
ffffffffc02002b6:	8ddd                	or	a1,a1,a5
ffffffffc02002b8:	d00e07b7          	lui	a5,0xd00e0
ffffffffc02002bc:	2581                	sext.w	a1,a1
ffffffffc02002be:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfed9d1d>
ffffffffc02002c2:	10f59163          	bne	a1,a5,ffffffffc02003c4 <dtb_init+0x1a4>
ffffffffc02002c6:	471c                	lw	a5,8(a4)
ffffffffc02002c8:	4754                	lw	a3,12(a4)
ffffffffc02002ca:	4c81                	li	s9,0
ffffffffc02002cc:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02002d0:	0086d51b          	srliw	a0,a3,0x8
ffffffffc02002d4:	0186941b          	slliw	s0,a3,0x18
ffffffffc02002d8:	0186d89b          	srliw	a7,a3,0x18
ffffffffc02002dc:	01879a1b          	slliw	s4,a5,0x18
ffffffffc02002e0:	0187d81b          	srliw	a6,a5,0x18
ffffffffc02002e4:	0105151b          	slliw	a0,a0,0x10
ffffffffc02002e8:	0106d69b          	srliw	a3,a3,0x10
ffffffffc02002ec:	0105959b          	slliw	a1,a1,0x10
ffffffffc02002f0:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02002f4:	8d71                	and	a0,a0,a2
ffffffffc02002f6:	01146433          	or	s0,s0,a7
ffffffffc02002fa:	0086969b          	slliw	a3,a3,0x8
ffffffffc02002fe:	010a6a33          	or	s4,s4,a6
ffffffffc0200302:	8e6d                	and	a2,a2,a1
ffffffffc0200304:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200308:	8c49                	or	s0,s0,a0
ffffffffc020030a:	0166f6b3          	and	a3,a3,s6
ffffffffc020030e:	00ca6a33          	or	s4,s4,a2
ffffffffc0200312:	0167f7b3          	and	a5,a5,s6
ffffffffc0200316:	8c55                	or	s0,s0,a3
ffffffffc0200318:	00fa6a33          	or	s4,s4,a5
ffffffffc020031c:	1402                	slli	s0,s0,0x20
ffffffffc020031e:	1a02                	slli	s4,s4,0x20
ffffffffc0200320:	9001                	srli	s0,s0,0x20
ffffffffc0200322:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200326:	943a                	add	s0,s0,a4
ffffffffc0200328:	9a3a                	add	s4,s4,a4
ffffffffc020032a:	00ff0c37          	lui	s8,0xff0
ffffffffc020032e:	4b8d                	li	s7,3
ffffffffc0200330:	00001917          	auipc	s2,0x1
ffffffffc0200334:	46890913          	addi	s2,s2,1128 # ffffffffc0201798 <etext+0x19a>
ffffffffc0200338:	49bd                	li	s3,15
ffffffffc020033a:	4d91                	li	s11,4
ffffffffc020033c:	4d05                	li	s10,1
ffffffffc020033e:	00001497          	auipc	s1,0x1
ffffffffc0200342:	45248493          	addi	s1,s1,1106 # ffffffffc0201790 <etext+0x192>
ffffffffc0200346:	000a2703          	lw	a4,0(s4)
ffffffffc020034a:	004a0a93          	addi	s5,s4,4
ffffffffc020034e:	0087569b          	srliw	a3,a4,0x8
ffffffffc0200352:	0187179b          	slliw	a5,a4,0x18
ffffffffc0200356:	0187561b          	srliw	a2,a4,0x18
ffffffffc020035a:	0106969b          	slliw	a3,a3,0x10
ffffffffc020035e:	0107571b          	srliw	a4,a4,0x10
ffffffffc0200362:	8fd1                	or	a5,a5,a2
ffffffffc0200364:	0186f6b3          	and	a3,a3,s8
ffffffffc0200368:	0087171b          	slliw	a4,a4,0x8
ffffffffc020036c:	8fd5                	or	a5,a5,a3
ffffffffc020036e:	00eb7733          	and	a4,s6,a4
ffffffffc0200372:	8fd9                	or	a5,a5,a4
ffffffffc0200374:	2781                	sext.w	a5,a5
ffffffffc0200376:	09778c63          	beq	a5,s7,ffffffffc020040e <dtb_init+0x1ee>
ffffffffc020037a:	00fbea63          	bltu	s7,a5,ffffffffc020038e <dtb_init+0x16e>
ffffffffc020037e:	07a78663          	beq	a5,s10,ffffffffc02003ea <dtb_init+0x1ca>
ffffffffc0200382:	4709                	li	a4,2
ffffffffc0200384:	00e79763          	bne	a5,a4,ffffffffc0200392 <dtb_init+0x172>
ffffffffc0200388:	4c81                	li	s9,0
ffffffffc020038a:	8a56                	mv	s4,s5
ffffffffc020038c:	bf6d                	j	ffffffffc0200346 <dtb_init+0x126>
ffffffffc020038e:	ffb78ee3          	beq	a5,s11,ffffffffc020038a <dtb_init+0x16a>
ffffffffc0200392:	00001517          	auipc	a0,0x1
ffffffffc0200396:	47e50513          	addi	a0,a0,1150 # ffffffffc0201810 <etext+0x212>
ffffffffc020039a:	db3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	4aa50513          	addi	a0,a0,1194 # ffffffffc0201848 <etext+0x24a>
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
ffffffffc02003c2:	b369                	j	ffffffffc020014c <cprintf>
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
ffffffffc02003de:	00001517          	auipc	a0,0x1
ffffffffc02003e2:	38a50513          	addi	a0,a0,906 # ffffffffc0201768 <etext+0x16a>
ffffffffc02003e6:	6109                	addi	sp,sp,128
ffffffffc02003e8:	b395                	j	ffffffffc020014c <cprintf>
ffffffffc02003ea:	8556                	mv	a0,s5
ffffffffc02003ec:	186010ef          	jal	ra,ffffffffc0201572 <strlen>
ffffffffc02003f0:	8a2a                	mv	s4,a0
ffffffffc02003f2:	4619                	li	a2,6
ffffffffc02003f4:	85a6                	mv	a1,s1
ffffffffc02003f6:	8556                	mv	a0,s5
ffffffffc02003f8:	2a01                	sext.w	s4,s4
ffffffffc02003fa:	1cc010ef          	jal	ra,ffffffffc02015c6 <strncmp>
ffffffffc02003fe:	e111                	bnez	a0,ffffffffc0200402 <dtb_init+0x1e2>
ffffffffc0200400:	4c85                	li	s9,1
ffffffffc0200402:	0a91                	addi	s5,s5,4
ffffffffc0200404:	9ad2                	add	s5,s5,s4
ffffffffc0200406:	ffcafa93          	andi	s5,s5,-4
ffffffffc020040a:	8a56                	mv	s4,s5
ffffffffc020040c:	bf2d                	j	ffffffffc0200346 <dtb_init+0x126>
ffffffffc020040e:	004a2783          	lw	a5,4(s4)
ffffffffc0200412:	00ca0693          	addi	a3,s4,12
ffffffffc0200416:	0087d71b          	srliw	a4,a5,0x8
ffffffffc020041a:	01879a9b          	slliw	s5,a5,0x18
ffffffffc020041e:	0187d61b          	srliw	a2,a5,0x18
ffffffffc0200422:	0107171b          	slliw	a4,a4,0x10
ffffffffc0200426:	0107d79b          	srliw	a5,a5,0x10
ffffffffc020042a:	00caeab3          	or	s5,s5,a2
ffffffffc020042e:	01877733          	and	a4,a4,s8
ffffffffc0200432:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200436:	00eaeab3          	or	s5,s5,a4
ffffffffc020043a:	00fb77b3          	and	a5,s6,a5
ffffffffc020043e:	00faeab3          	or	s5,s5,a5
ffffffffc0200442:	2a81                	sext.w	s5,s5
ffffffffc0200444:	000c9c63          	bnez	s9,ffffffffc020045c <dtb_init+0x23c>
ffffffffc0200448:	1a82                	slli	s5,s5,0x20
ffffffffc020044a:	00368793          	addi	a5,a3,3
ffffffffc020044e:	020ada93          	srli	s5,s5,0x20
ffffffffc0200452:	9abe                	add	s5,s5,a5
ffffffffc0200454:	ffcafa93          	andi	s5,s5,-4
ffffffffc0200458:	8a56                	mv	s4,s5
ffffffffc020045a:	b5f5                	j	ffffffffc0200346 <dtb_init+0x126>
ffffffffc020045c:	008a2783          	lw	a5,8(s4)
ffffffffc0200460:	85ca                	mv	a1,s2
ffffffffc0200462:	e436                	sd	a3,8(sp)
ffffffffc0200464:	0087d51b          	srliw	a0,a5,0x8
ffffffffc0200468:	0187d61b          	srliw	a2,a5,0x18
ffffffffc020046c:	0187971b          	slliw	a4,a5,0x18
ffffffffc0200470:	0105151b          	slliw	a0,a0,0x10
ffffffffc0200474:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200478:	8f51                	or	a4,a4,a2
ffffffffc020047a:	01857533          	and	a0,a0,s8
ffffffffc020047e:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200482:	8d59                	or	a0,a0,a4
ffffffffc0200484:	00fb77b3          	and	a5,s6,a5
ffffffffc0200488:	8d5d                	or	a0,a0,a5
ffffffffc020048a:	1502                	slli	a0,a0,0x20
ffffffffc020048c:	9101                	srli	a0,a0,0x20
ffffffffc020048e:	9522                	add	a0,a0,s0
ffffffffc0200490:	118010ef          	jal	ra,ffffffffc02015a8 <strcmp>
ffffffffc0200494:	66a2                	ld	a3,8(sp)
ffffffffc0200496:	f94d                	bnez	a0,ffffffffc0200448 <dtb_init+0x228>
ffffffffc0200498:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200448 <dtb_init+0x228>
ffffffffc020049c:	00ca3783          	ld	a5,12(s4)
ffffffffc02004a0:	014a3703          	ld	a4,20(s4)
ffffffffc02004a4:	00001517          	auipc	a0,0x1
ffffffffc02004a8:	2fc50513          	addi	a0,a0,764 # ffffffffc02017a0 <etext+0x1a2>
ffffffffc02004ac:	4207d613          	srai	a2,a5,0x20
ffffffffc02004b0:	0087d31b          	srliw	t1,a5,0x8
ffffffffc02004b4:	42075593          	srai	a1,a4,0x20
ffffffffc02004b8:	0187de1b          	srliw	t3,a5,0x18
ffffffffc02004bc:	0186581b          	srliw	a6,a2,0x18
ffffffffc02004c0:	0187941b          	slliw	s0,a5,0x18
ffffffffc02004c4:	0107d89b          	srliw	a7,a5,0x10
ffffffffc02004c8:	0187d693          	srli	a3,a5,0x18
ffffffffc02004cc:	01861f1b          	slliw	t5,a2,0x18
ffffffffc02004d0:	0087579b          	srliw	a5,a4,0x8
ffffffffc02004d4:	0103131b          	slliw	t1,t1,0x10
ffffffffc02004d8:	0106561b          	srliw	a2,a2,0x10
ffffffffc02004dc:	010f6f33          	or	t5,t5,a6
ffffffffc02004e0:	0187529b          	srliw	t0,a4,0x18
ffffffffc02004e4:	0185df9b          	srliw	t6,a1,0x18
ffffffffc02004e8:	01837333          	and	t1,t1,s8
ffffffffc02004ec:	01c46433          	or	s0,s0,t3
ffffffffc02004f0:	0186f6b3          	and	a3,a3,s8
ffffffffc02004f4:	01859e1b          	slliw	t3,a1,0x18
ffffffffc02004f8:	01871e9b          	slliw	t4,a4,0x18
ffffffffc02004fc:	0107581b          	srliw	a6,a4,0x10
ffffffffc0200500:	0086161b          	slliw	a2,a2,0x8
ffffffffc0200504:	8361                	srli	a4,a4,0x18
ffffffffc0200506:	0107979b          	slliw	a5,a5,0x10
ffffffffc020050a:	0105d59b          	srliw	a1,a1,0x10
ffffffffc020050e:	01e6e6b3          	or	a3,a3,t5
ffffffffc0200512:	00cb7633          	and	a2,s6,a2
ffffffffc0200516:	0088181b          	slliw	a6,a6,0x8
ffffffffc020051a:	0085959b          	slliw	a1,a1,0x8
ffffffffc020051e:	00646433          	or	s0,s0,t1
ffffffffc0200522:	0187f7b3          	and	a5,a5,s8
ffffffffc0200526:	01fe6333          	or	t1,t3,t6
ffffffffc020052a:	01877c33          	and	s8,a4,s8
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
ffffffffc0200558:	1702                	slli	a4,a4,0x20
ffffffffc020055a:	1b02                	slli	s6,s6,0x20
ffffffffc020055c:	1782                	slli	a5,a5,0x20
ffffffffc020055e:	9301                	srli	a4,a4,0x20
ffffffffc0200560:	1402                	slli	s0,s0,0x20
ffffffffc0200562:	020b5b13          	srli	s6,s6,0x20
ffffffffc0200566:	0167eb33          	or	s6,a5,s6
ffffffffc020056a:	8c59                	or	s0,s0,a4
ffffffffc020056c:	be1ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200570:	85a2                	mv	a1,s0
ffffffffc0200572:	00001517          	auipc	a0,0x1
ffffffffc0200576:	24e50513          	addi	a0,a0,590 # ffffffffc02017c0 <etext+0x1c2>
ffffffffc020057a:	bd3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc020057e:	014b5613          	srli	a2,s6,0x14
ffffffffc0200582:	85da                	mv	a1,s6
ffffffffc0200584:	00001517          	auipc	a0,0x1
ffffffffc0200588:	25450513          	addi	a0,a0,596 # ffffffffc02017d8 <etext+0x1da>
ffffffffc020058c:	bc1ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200590:	008b05b3          	add	a1,s6,s0
ffffffffc0200594:	15fd                	addi	a1,a1,-1
ffffffffc0200596:	00001517          	auipc	a0,0x1
ffffffffc020059a:	26250513          	addi	a0,a0,610 # ffffffffc02017f8 <etext+0x1fa>
ffffffffc020059e:	bafff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc02005a2:	00001517          	auipc	a0,0x1
ffffffffc02005a6:	2a650513          	addi	a0,a0,678 # ffffffffc0201848 <etext+0x24a>
ffffffffc02005aa:	00006797          	auipc	a5,0x6
ffffffffc02005ae:	bc87bf23          	sd	s0,-1058(a5) # ffffffffc0206188 <memory_base>
ffffffffc02005b2:	00006797          	auipc	a5,0x6
ffffffffc02005b6:	bd67bf23          	sd	s6,-1058(a5) # ffffffffc0206190 <memory_size>
ffffffffc02005ba:	b3f5                	j	ffffffffc02003a6 <dtb_init+0x186>

ffffffffc02005bc <get_memory_base>:
ffffffffc02005bc:	00006517          	auipc	a0,0x6
ffffffffc02005c0:	bcc53503          	ld	a0,-1076(a0) # ffffffffc0206188 <memory_base>
ffffffffc02005c4:	8082                	ret

ffffffffc02005c6 <get_memory_size>:
ffffffffc02005c6:	00006517          	auipc	a0,0x6
ffffffffc02005ca:	bca53503          	ld	a0,-1078(a0) # ffffffffc0206190 <memory_size>
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
ffffffffc02005dc:	ba870713          	addi	a4,a4,-1112 # ffffffffc0206180 <is_panic>
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
ffffffffc02005f2:	ba07b523          	sd	zero,-1110(a5) # ffffffffc0206198 <nr_free>
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
ffffffffc02005fe:	b9ef0f13          	addi	t5,t5,-1122 # ffffffffc0206198 <nr_free>
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
    free_area[order].nr_free++;
}

static size_t buddy_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200716:	00006517          	auipc	a0,0x6
ffffffffc020071a:	a8253503          	ld	a0,-1406(a0) # ffffffffc0206198 <nr_free>
ffffffffc020071e:	8082                	ret

ffffffffc0200720 <show_buddy_info>:
        }
    }
    return -1;
}

static void show_buddy_info(const char *label) {
ffffffffc0200720:	7179                	addi	sp,sp,-48
ffffffffc0200722:	85aa                	mv	a1,a0
    cprintf("   --- %s ---\n", label);
ffffffffc0200724:	00001517          	auipc	a0,0x1
ffffffffc0200728:	13c50513          	addi	a0,a0,316 # ffffffffc0201860 <etext+0x262>
static void show_buddy_info(const char *label) {
ffffffffc020072c:	f022                	sd	s0,32(sp)
ffffffffc020072e:	ec26                	sd	s1,24(sp)
ffffffffc0200730:	e84a                	sd	s2,16(sp)
ffffffffc0200732:	e44e                	sd	s3,8(sp)
ffffffffc0200734:	e052                	sd	s4,0(sp)
ffffffffc0200736:	f406                	sd	ra,40(sp)
ffffffffc0200738:	00006497          	auipc	s1,0x6
ffffffffc020073c:	8f048493          	addi	s1,s1,-1808 # ffffffffc0206028 <free_area+0x10>
    cprintf("   --- %s ---\n", label);
ffffffffc0200740:	a0dff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc0200744:	4401                	li	s0,0
        if (free_area[i].nr_free > 0) {
            cprintf("     阶数 %2d (大小 %4d): %d 个空闲块\n", i, 1 << i, free_area[i].nr_free);
ffffffffc0200746:	4a05                	li	s4,1
ffffffffc0200748:	00001997          	auipc	s3,0x1
ffffffffc020074c:	12898993          	addi	s3,s3,296 # ffffffffc0201870 <etext+0x272>
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc0200750:	493d                	li	s2,15
ffffffffc0200752:	a021                	j	ffffffffc020075a <show_buddy_info+0x3a>
ffffffffc0200754:	2405                	addiw	s0,s0,1
ffffffffc0200756:	01240e63          	beq	s0,s2,ffffffffc0200772 <show_buddy_info+0x52>
        if (free_area[i].nr_free > 0) {
ffffffffc020075a:	4094                	lw	a3,0(s1)
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc020075c:	04e1                	addi	s1,s1,24
        if (free_area[i].nr_free > 0) {
ffffffffc020075e:	dafd                	beqz	a3,ffffffffc0200754 <show_buddy_info+0x34>
            cprintf("     阶数 %2d (大小 %4d): %d 个空闲块\n", i, 1 << i, free_area[i].nr_free);
ffffffffc0200760:	008a163b          	sllw	a2,s4,s0
ffffffffc0200764:	85a2                	mv	a1,s0
ffffffffc0200766:	854e                	mv	a0,s3
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc0200768:	2405                	addiw	s0,s0,1
            cprintf("     阶数 %2d (大小 %4d): %d 个空闲块\n", i, 1 << i, free_area[i].nr_free);
ffffffffc020076a:	9e3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc020076e:	ff2416e3          	bne	s0,s2,ffffffffc020075a <show_buddy_info+0x3a>
        }
    }
    cprintf("   --------------------------------\n");
}
ffffffffc0200772:	7402                	ld	s0,32(sp)
ffffffffc0200774:	70a2                	ld	ra,40(sp)
ffffffffc0200776:	64e2                	ld	s1,24(sp)
ffffffffc0200778:	6942                	ld	s2,16(sp)
ffffffffc020077a:	69a2                	ld	s3,8(sp)
ffffffffc020077c:	6a02                	ld	s4,0(sp)
    cprintf("   --------------------------------\n");
ffffffffc020077e:	00001517          	auipc	a0,0x1
ffffffffc0200782:	12250513          	addi	a0,a0,290 # ffffffffc02018a0 <etext+0x2a2>
}
ffffffffc0200786:	6145                	addi	sp,sp,48
    cprintf("   --------------------------------\n");
ffffffffc0200788:	b2d1                	j	ffffffffc020014c <cprintf>

ffffffffc020078a <buddy_free_pages>:
static void buddy_free_pages(struct Page *base, size_t n) {
ffffffffc020078a:	1141                	addi	sp,sp,-16
ffffffffc020078c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020078e:	16058063          	beqz	a1,ffffffffc02008ee <buddy_free_pages+0x164>
    uint32_t order = base->property;
ffffffffc0200792:	4914                	lw	a3,16(a0)
    nr_free += (1 << order);
ffffffffc0200794:	00006597          	auipc	a1,0x6
ffffffffc0200798:	a0458593          	addi	a1,a1,-1532 # ffffffffc0206198 <nr_free>
ffffffffc020079c:	4785                	li	a5,1
ffffffffc020079e:	00d797bb          	sllw	a5,a5,a3
ffffffffc02007a2:	6198                	ld	a4,0(a1)
    for (; p != base + (1 << order); p++) {
ffffffffc02007a4:	00279613          	slli	a2,a5,0x2
ffffffffc02007a8:	963e                	add	a2,a2,a5
ffffffffc02007aa:	060e                	slli	a2,a2,0x3
    nr_free += (1 << order);
ffffffffc02007ac:	97ba                	add	a5,a5,a4
ffffffffc02007ae:	e19c                	sd	a5,0(a1)
    for (; p != base + (1 << order); p++) {
ffffffffc02007b0:	962a                	add	a2,a2,a0
ffffffffc02007b2:	00c50e63          	beq	a0,a2,ffffffffc02007ce <buddy_free_pages+0x44>
ffffffffc02007b6:	87aa                	mv	a5,a0
        assert(!PageReserved(p));
ffffffffc02007b8:	6798                	ld	a4,8(a5)
ffffffffc02007ba:	8b05                	andi	a4,a4,1
ffffffffc02007bc:	ef6d                	bnez	a4,ffffffffc02008b6 <buddy_free_pages+0x12c>
        p->flags = 0;
ffffffffc02007be:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02007c2:	0007a023          	sw	zero,0(a5)
    for (; p != base + (1 << order); p++) {
ffffffffc02007c6:	02878793          	addi	a5,a5,40
ffffffffc02007ca:	fef617e3          	bne	a2,a5,ffffffffc02007b8 <buddy_free_pages+0x2e>
    while (order < MAX_ORDER - 1) {
ffffffffc02007ce:	47b5                	li	a5,13
ffffffffc02007d0:	00006f97          	auipc	t6,0x6
ffffffffc02007d4:	848f8f93          	addi	t6,t6,-1976 # ffffffffc0206018 <free_area>
ffffffffc02007d8:	0ad7e063          	bltu	a5,a3,ffffffffc0200878 <buddy_free_pages+0xee>
ffffffffc02007dc:	02069793          	slli	a5,a3,0x20
ffffffffc02007e0:	9381                	srli	a5,a5,0x20
ffffffffc02007e2:	00179613          	slli	a2,a5,0x1
ffffffffc02007e6:	963e                	add	a2,a2,a5
ffffffffc02007e8:	00006f97          	auipc	t6,0x6
ffffffffc02007ec:	830f8f93          	addi	t6,t6,-2000 # ffffffffc0206018 <free_area>
ffffffffc02007f0:	060e                	slli	a2,a2,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02007f2:	00006897          	auipc	a7,0x6
ffffffffc02007f6:	9b68b883          	ld	a7,-1610(a7) # ffffffffc02061a8 <pages>
ffffffffc02007fa:	00002817          	auipc	a6,0x2
ffffffffc02007fe:	c1683803          	ld	a6,-1002(a6) # ffffffffc0202410 <nbase>
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200802:	00006e97          	auipc	t4,0x6
ffffffffc0200806:	99eebe83          	ld	t4,-1634(t4) # ffffffffc02061a0 <npage>
ffffffffc020080a:	967e                	add	a2,a2,t6
ffffffffc020080c:	00002e17          	auipc	t3,0x2
ffffffffc0200810:	bfce3e03          	ld	t3,-1028(t3) # ffffffffc0202408 <error_string+0x38>
        uintptr_t buddy_idx = page_idx ^ (1 << order);
ffffffffc0200814:	4305                	li	t1,1
    while (order < MAX_ORDER - 1) {
ffffffffc0200816:	4f39                	li	t5,14
ffffffffc0200818:	a805                	j	ffffffffc0200848 <buddy_free_pages+0xbe>
        if (!PageProperty(buddy) || buddy->property != order) {
ffffffffc020081a:	4b8c                	lw	a1,16(a5)
ffffffffc020081c:	04d59e63          	bne	a1,a3,ffffffffc0200878 <buddy_free_pages+0xee>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200820:	0187b383          	ld	t2,24(a5)
ffffffffc0200824:	0207b283          	ld	t0,32(a5)
        free_area[order].nr_free--;
ffffffffc0200828:	4a0c                	lw	a1,16(a2)
        ClearPageProperty(buddy); // 伙伴不再是空闲块头
ffffffffc020082a:	9b75                	andi	a4,a4,-3
    prev->next = next;
ffffffffc020082c:	0053b423          	sd	t0,8(t2)
    next->prev = prev;
ffffffffc0200830:	0072b023          	sd	t2,0(t0)
        free_area[order].nr_free--;
ffffffffc0200834:	35fd                	addiw	a1,a1,-1
ffffffffc0200836:	ca0c                	sw	a1,16(a2)
        ClearPageProperty(buddy); // 伙伴不再是空闲块头
ffffffffc0200838:	e798                	sd	a4,8(a5)
        if (buddy < base) {
ffffffffc020083a:	00a7f363          	bgeu	a5,a0,ffffffffc0200840 <buddy_free_pages+0xb6>
ffffffffc020083e:	853e                	mv	a0,a5
        order++;
ffffffffc0200840:	2685                	addiw	a3,a3,1
    while (order < MAX_ORDER - 1) {
ffffffffc0200842:	0661                	addi	a2,a2,24
ffffffffc0200844:	03e68a63          	beq	a3,t5,ffffffffc0200878 <buddy_free_pages+0xee>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200848:	41150733          	sub	a4,a0,a7
ffffffffc020084c:	870d                	srai	a4,a4,0x3
ffffffffc020084e:	03c70733          	mul	a4,a4,t3
        uintptr_t buddy_idx = page_idx ^ (1 << order);
ffffffffc0200852:	00d317bb          	sllw	a5,t1,a3
ffffffffc0200856:	9742                	add	a4,a4,a6
ffffffffc0200858:	8fb9                	xor	a5,a5,a4
        struct Page *buddy = pa2page(buddy_idx * PGSIZE);
ffffffffc020085a:	07b2                	slli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020085c:	83b1                	srli	a5,a5,0xc
ffffffffc020085e:	07d7fc63          	bgeu	a5,t4,ffffffffc02008d6 <buddy_free_pages+0x14c>
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200862:	410787b3          	sub	a5,a5,a6
ffffffffc0200866:	00279713          	slli	a4,a5,0x2
ffffffffc020086a:	97ba                	add	a5,a5,a4
ffffffffc020086c:	078e                	slli	a5,a5,0x3
ffffffffc020086e:	97c6                	add	a5,a5,a7
        if (!PageProperty(buddy) || buddy->property != order) {
ffffffffc0200870:	6798                	ld	a4,8(a5)
ffffffffc0200872:	00277593          	andi	a1,a4,2
ffffffffc0200876:	f1d5                	bnez	a1,ffffffffc020081a <buddy_free_pages+0x90>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200878:	02069713          	slli	a4,a3,0x20
ffffffffc020087c:	9301                	srli	a4,a4,0x20
ffffffffc020087e:	00171793          	slli	a5,a4,0x1
ffffffffc0200882:	97ba                	add	a5,a5,a4
ffffffffc0200884:	078e                	slli	a5,a5,0x3
    SetPageProperty(base); // 标记它是一个新的空闲块头
ffffffffc0200886:	6518                	ld	a4,8(a0)
ffffffffc0200888:	9fbe                	add	t6,t6,a5
ffffffffc020088a:	008fb603          	ld	a2,8(t6)
ffffffffc020088e:	00276793          	ori	a5,a4,2
ffffffffc0200892:	e51c                	sd	a5,8(a0)
    base->property = order;
ffffffffc0200894:	c914                	sw	a3,16(a0)
    free_area[order].nr_free++;
ffffffffc0200896:	010fa783          	lw	a5,16(t6)
    list_add(&(free_area[order].free_list), &(base->page_link));
ffffffffc020089a:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020089e:	e218                	sd	a4,0(a2)
ffffffffc02008a0:	00efb423          	sd	a4,8(t6)
}
ffffffffc02008a4:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02008a6:	f110                	sd	a2,32(a0)
    elm->prev = prev;
ffffffffc02008a8:	01f53c23          	sd	t6,24(a0)
    free_area[order].nr_free++;
ffffffffc02008ac:	2785                	addiw	a5,a5,1
ffffffffc02008ae:	00ffa823          	sw	a5,16(t6)
}
ffffffffc02008b2:	0141                	addi	sp,sp,16
ffffffffc02008b4:	8082                	ret
        assert(!PageReserved(p));
ffffffffc02008b6:	00001697          	auipc	a3,0x1
ffffffffc02008ba:	04a68693          	addi	a3,a3,74 # ffffffffc0201900 <etext+0x302>
ffffffffc02008be:	00001617          	auipc	a2,0x1
ffffffffc02008c2:	01260613          	addi	a2,a2,18 # ffffffffc02018d0 <etext+0x2d2>
ffffffffc02008c6:	08500593          	li	a1,133
ffffffffc02008ca:	00001517          	auipc	a0,0x1
ffffffffc02008ce:	01e50513          	addi	a0,a0,30 # ffffffffc02018e8 <etext+0x2ea>
ffffffffc02008d2:	8f1ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02008d6:	00001617          	auipc	a2,0x1
ffffffffc02008da:	04260613          	addi	a2,a2,66 # ffffffffc0201918 <etext+0x31a>
ffffffffc02008de:	06a00593          	li	a1,106
ffffffffc02008e2:	00001517          	auipc	a0,0x1
ffffffffc02008e6:	05650513          	addi	a0,a0,86 # ffffffffc0201938 <etext+0x33a>
ffffffffc02008ea:	8d9ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc02008ee:	00001697          	auipc	a3,0x1
ffffffffc02008f2:	fda68693          	addi	a3,a3,-38 # ffffffffc02018c8 <etext+0x2ca>
ffffffffc02008f6:	00001617          	auipc	a2,0x1
ffffffffc02008fa:	fda60613          	addi	a2,a2,-38 # ffffffffc02018d0 <etext+0x2d2>
ffffffffc02008fe:	07900593          	li	a1,121
ffffffffc0200902:	00001517          	auipc	a0,0x1
ffffffffc0200906:	fe650513          	addi	a0,a0,-26 # ffffffffc02018e8 <etext+0x2ea>
ffffffffc020090a:	8b9ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc020090e <buddy_check>:

static void buddy_check(void) {
ffffffffc020090e:	7115                	addi	sp,sp,-224
ffffffffc0200910:	e1ca                	sd	s2,192(sp)
    cprintf("=== 开始伙伴系统测试 ===\n");
ffffffffc0200912:	00001517          	auipc	a0,0x1
ffffffffc0200916:	03650513          	addi	a0,a0,54 # ffffffffc0201948 <etext+0x34a>
    return nr_free;
ffffffffc020091a:	00006917          	auipc	s2,0x6
ffffffffc020091e:	87e90913          	addi	s2,s2,-1922 # ffffffffc0206198 <nr_free>
static void buddy_check(void) {
ffffffffc0200922:	ed86                	sd	ra,216(sp)
ffffffffc0200924:	e9a2                	sd	s0,208(sp)
ffffffffc0200926:	fd4e                	sd	s3,184(sp)
ffffffffc0200928:	e5a6                	sd	s1,200(sp)
ffffffffc020092a:	f952                	sd	s4,176(sp)
ffffffffc020092c:	f556                	sd	s5,168(sp)
    cprintf("=== 开始伙伴系统测试 ===\n");
ffffffffc020092e:	81fff0ef          	jal	ra,ffffffffc020014c <cprintf>
    return nr_free;
ffffffffc0200932:	00093983          	ld	s3,0(s2)
    size_t initial_free = buddy_nr_free_pages();
    cprintf("初始空闲页数: %d\n\n", initial_free);
ffffffffc0200936:	00001517          	auipc	a0,0x1
ffffffffc020093a:	03a50513          	addi	a0,a0,58 # ffffffffc0201970 <etext+0x372>
ffffffffc020093e:	85ce                	mv	a1,s3
ffffffffc0200940:	80dff0ef          	jal	ra,ffffffffc020014c <cprintf>

    
    // 1. 测试简单请求和释放操作
    
    cprintf("1. 简单的分配和释放操作\n");
ffffffffc0200944:	00001517          	auipc	a0,0x1
ffffffffc0200948:	04c50513          	addi	a0,a0,76 # ffffffffc0201990 <etext+0x392>
ffffffffc020094c:	801ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_info("初始状态");
ffffffffc0200950:	00001517          	auipc	a0,0x1
ffffffffc0200954:	06850513          	addi	a0,a0,104 # ffffffffc02019b8 <etext+0x3ba>
ffffffffc0200958:	dc9ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    struct Page *p1 = alloc_pages(16);
ffffffffc020095c:	4541                	li	a0,16
ffffffffc020095e:	61c000ef          	jal	ra,ffffffffc0200f7a <alloc_pages>
ffffffffc0200962:	842a                	mv	s0,a0
    show_buddy_info("分配 16 页后");
ffffffffc0200964:	00001517          	auipc	a0,0x1
ffffffffc0200968:	06450513          	addi	a0,a0,100 # ffffffffc02019c8 <etext+0x3ca>
ffffffffc020096c:	db5ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    assert(p1 != NULL);
ffffffffc0200970:	32040b63          	beqz	s0,ffffffffc0200ca6 <buddy_check+0x398>
    assert(buddy_nr_free_pages() == initial_free - 16);
ffffffffc0200974:	00093783          	ld	a5,0(s2)
ffffffffc0200978:	ff098713          	addi	a4,s3,-16
ffffffffc020097c:	4cf71563          	bne	a4,a5,ffffffffc0200e46 <buddy_check+0x538>
    cprintf("   - 已分配 16 页。通过。\n");
ffffffffc0200980:	00001517          	auipc	a0,0x1
ffffffffc0200984:	0a050513          	addi	a0,a0,160 # ffffffffc0201a20 <etext+0x422>
ffffffffc0200988:	fc4ff0ef          	jal	ra,ffffffffc020014c <cprintf>

    free_pages(p1, 16);
ffffffffc020098c:	8522                	mv	a0,s0
ffffffffc020098e:	45c1                	li	a1,16
ffffffffc0200990:	5f6000ef          	jal	ra,ffffffffc0200f86 <free_pages>
    show_buddy_info("释放 16 页后");
ffffffffc0200994:	00001517          	auipc	a0,0x1
ffffffffc0200998:	0b450513          	addi	a0,a0,180 # ffffffffc0201a48 <etext+0x44a>
ffffffffc020099c:	d85ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    assert(buddy_nr_free_pages() == initial_free);
ffffffffc02009a0:	00093403          	ld	s0,0(s2)
ffffffffc02009a4:	49341163          	bne	s0,s3,ffffffffc0200e26 <buddy_check+0x518>
    cprintf("   - 已释放 16 页。通过。\n");
ffffffffc02009a8:	00001517          	auipc	a0,0x1
ffffffffc02009ac:	0e050513          	addi	a0,a0,224 # ffffffffc0201a88 <etext+0x48a>
ffffffffc02009b0:	f9cff0ef          	jal	ra,ffffffffc020014c <cprintf>


    
    // 2. 测试复杂请求和释放操作 (碎片化与合并)
    
    cprintf("2. 复杂的分配和释放操作\n");
ffffffffc02009b4:	00001517          	auipc	a0,0x1
ffffffffc02009b8:	0fc50513          	addi	a0,a0,252 # ffffffffc0201ab0 <etext+0x4b2>
ffffffffc02009bc:	f90ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_info("初始状态");
ffffffffc02009c0:	00001517          	auipc	a0,0x1
ffffffffc02009c4:	ff850513          	addi	a0,a0,-8 # ffffffffc02019b8 <etext+0x3ba>
ffffffffc02009c8:	d59ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    struct Page *p2 = alloc_pages(3);  // 消耗4页
ffffffffc02009cc:	450d                	li	a0,3
ffffffffc02009ce:	5ac000ef          	jal	ra,ffffffffc0200f7a <alloc_pages>
ffffffffc02009d2:	84aa                	mv	s1,a0
    show_buddy_info("分配 3 页后");
ffffffffc02009d4:	00001517          	auipc	a0,0x1
ffffffffc02009d8:	10450513          	addi	a0,a0,260 # ffffffffc0201ad8 <etext+0x4da>
ffffffffc02009dc:	d45ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    struct Page *p3 = alloc_pages(10); // 消耗16页
ffffffffc02009e0:	4529                	li	a0,10
ffffffffc02009e2:	598000ef          	jal	ra,ffffffffc0200f7a <alloc_pages>
ffffffffc02009e6:	8a2a                	mv	s4,a0
    show_buddy_info("分配 10 页后");
ffffffffc02009e8:	00001517          	auipc	a0,0x1
ffffffffc02009ec:	10050513          	addi	a0,a0,256 # ffffffffc0201ae8 <etext+0x4ea>
ffffffffc02009f0:	d31ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    assert(p2 != NULL && p3 != NULL);
ffffffffc02009f4:	40048963          	beqz	s1,ffffffffc0200e06 <buddy_check+0x4f8>
ffffffffc02009f8:	400a0763          	beqz	s4,ffffffffc0200e06 <buddy_check+0x4f8>
    assert(buddy_nr_free_pages() == initial_free - 4 - 16);
ffffffffc02009fc:	00093783          	ld	a5,0(s2)
ffffffffc0200a00:	fec40713          	addi	a4,s0,-20
ffffffffc0200a04:	3ef71163          	bne	a4,a5,ffffffffc0200de6 <buddy_check+0x4d8>
    cprintf("   - 已分配 3 页块 (实际消耗 4 页) 和 10 页块 (实际消耗 16 页)。通过。\n");
ffffffffc0200a08:	00001517          	auipc	a0,0x1
ffffffffc0200a0c:	14850513          	addi	a0,a0,328 # ffffffffc0201b50 <etext+0x552>
ffffffffc0200a10:	f3cff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    // 逆序释放,测试合并逻辑
    free_pages(p3, 10);
ffffffffc0200a14:	45a9                	li	a1,10
ffffffffc0200a16:	8552                	mv	a0,s4
ffffffffc0200a18:	56e000ef          	jal	ra,ffffffffc0200f86 <free_pages>
    show_buddy_info("释放 10 页后");
ffffffffc0200a1c:	00001517          	auipc	a0,0x1
ffffffffc0200a20:	19450513          	addi	a0,a0,404 # ffffffffc0201bb0 <etext+0x5b2>
ffffffffc0200a24:	cfdff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    assert(buddy_nr_free_pages() == initial_free - 4);
ffffffffc0200a28:	00093783          	ld	a5,0(s2)
ffffffffc0200a2c:	ffc40713          	addi	a4,s0,-4
ffffffffc0200a30:	38f71b63          	bne	a4,a5,ffffffffc0200dc6 <buddy_check+0x4b8>
    cprintf("   - 已释放 10 页块。通过。\n");
ffffffffc0200a34:	00001517          	auipc	a0,0x1
ffffffffc0200a38:	1c450513          	addi	a0,a0,452 # ffffffffc0201bf8 <etext+0x5fa>
ffffffffc0200a3c:	f10ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    free_pages(p2, 3);
ffffffffc0200a40:	458d                	li	a1,3
ffffffffc0200a42:	8526                	mv	a0,s1
ffffffffc0200a44:	542000ef          	jal	ra,ffffffffc0200f86 <free_pages>
    show_buddy_info("释放 3 页后");
ffffffffc0200a48:	00001517          	auipc	a0,0x1
ffffffffc0200a4c:	1d850513          	addi	a0,a0,472 # ffffffffc0201c20 <etext+0x622>
ffffffffc0200a50:	cd1ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    assert(buddy_nr_free_pages() == initial_free);
ffffffffc0200a54:	00093783          	ld	a5,0(s2)
ffffffffc0200a58:	34879763          	bne	a5,s0,ffffffffc0200da6 <buddy_check+0x498>
    cprintf("   - 已释放 3 页块。通过。\n");
ffffffffc0200a5c:	00001517          	auipc	a0,0x1
ffffffffc0200a60:	1d450513          	addi	a0,a0,468 # ffffffffc0201c30 <etext+0x632>
ffffffffc0200a64:	ee8ff0ef          	jal	ra,ffffffffc020014c <cprintf>


    
    // 3. 测试请求和释放最小单元操作 (可视化分割与合并)

    cprintf("3. 最小单元操作 \n");
ffffffffc0200a68:	00001517          	auipc	a0,0x1
ffffffffc0200a6c:	1f050513          	addi	a0,a0,496 # ffffffffc0201c58 <etext+0x65a>
ffffffffc0200a70:	edcff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_info("初始状态");
ffffffffc0200a74:	00001517          	auipc	a0,0x1
ffffffffc0200a78:	f4450513          	addi	a0,a0,-188 # ffffffffc02019b8 <etext+0x3ba>
ffffffffc0200a7c:	ca5ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>

    // 分配一个最小单元
    struct Page *p_min = alloc_pages(1);
ffffffffc0200a80:	4505                	li	a0,1
ffffffffc0200a82:	4f8000ef          	jal	ra,ffffffffc0200f7a <alloc_pages>
ffffffffc0200a86:	842a                	mv	s0,a0
    assert(p_min != NULL);
ffffffffc0200a88:	2e050f63          	beqz	a0,ffffffffc0200d86 <buddy_check+0x478>
    cprintf("   - 已分配 1 页。通过。\n");
ffffffffc0200a8c:	00001517          	auipc	a0,0x1
ffffffffc0200a90:	1f450513          	addi	a0,a0,500 # ffffffffc0201c80 <etext+0x682>
ffffffffc0200a94:	eb8ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_info("分配 1 页后");
ffffffffc0200a98:	00001517          	auipc	a0,0x1
ffffffffc0200a9c:	21050513          	addi	a0,a0,528 # ffffffffc0201ca8 <etext+0x6aa>
ffffffffc0200aa0:	c81ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>

    // 释放这个最小单元
    free_pages(p_min, 1);
ffffffffc0200aa4:	4585                	li	a1,1
ffffffffc0200aa6:	8522                	mv	a0,s0
ffffffffc0200aa8:	4de000ef          	jal	ra,ffffffffc0200f86 <free_pages>
    cprintf("   - 已释放 1 页。通过。\n");
ffffffffc0200aac:	00001517          	auipc	a0,0x1
ffffffffc0200ab0:	20c50513          	addi	a0,a0,524 # ffffffffc0201cb8 <etext+0x6ba>
ffffffffc0200ab4:	e98ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_info("释放 1 页后");
ffffffffc0200ab8:	00001517          	auipc	a0,0x1
ffffffffc0200abc:	22850513          	addi	a0,a0,552 # ffffffffc0201ce0 <etext+0x6e2>
ffffffffc0200ac0:	c61ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    
    // 检查内存是否完全恢复
    assert(buddy_nr_free_pages() == initial_free);
ffffffffc0200ac4:	00093783          	ld	a5,0(s2)
ffffffffc0200ac8:	29379f63          	bne	a5,s3,ffffffffc0200d66 <buddy_check+0x458>
    cprintf("   - 测试通过: 最小单元操作正确。\n\n");
ffffffffc0200acc:	00001517          	auipc	a0,0x1
ffffffffc0200ad0:	22450513          	addi	a0,a0,548 # ffffffffc0201cf0 <etext+0x6f2>
ffffffffc0200ad4:	e78ff0ef          	jal	ra,ffffffffc020014c <cprintf>


    
    // 4. 测试请求和释放最大单元操作
    
    cprintf("4. 最大单元操作\n");
ffffffffc0200ad8:	00001517          	auipc	a0,0x1
ffffffffc0200adc:	25050513          	addi	a0,a0,592 # ffffffffc0201d28 <etext+0x72a>
ffffffffc0200ae0:	e6cff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = MAX_ORDER - 1; i >= 0; i--) {
ffffffffc0200ae4:	00005417          	auipc	s0,0x5
ffffffffc0200ae8:	68440413          	addi	s0,s0,1668 # ffffffffc0206168 <free_area+0x150>
ffffffffc0200aec:	44b9                	li	s1,14
    cprintf("4. 最大单元操作\n");
ffffffffc0200aee:	87a2                	mv	a5,s0
    for (int i = MAX_ORDER - 1; i >= 0; i--) {
ffffffffc0200af0:	56fd                	li	a3,-1
        if (!list_empty(&(free_area[i].free_list))) {
ffffffffc0200af2:	6798                	ld	a4,8(a5)
ffffffffc0200af4:	16f71563          	bne	a4,a5,ffffffffc0200c5e <buddy_check+0x350>
    for (int i = MAX_ORDER - 1; i >= 0; i--) {
ffffffffc0200af8:	34fd                	addiw	s1,s1,-1
ffffffffc0200afa:	17a1                	addi	a5,a5,-24
ffffffffc0200afc:	fed49be3          	bne	s1,a3,ffffffffc0200af2 <buddy_check+0x1e4>
ffffffffc0200b00:	4a81                	li	s5,0
    int max_order = find_max_order();
    show_buddy_info("初始状态");
ffffffffc0200b02:	00001517          	auipc	a0,0x1
ffffffffc0200b06:	eb650513          	addi	a0,a0,-330 # ffffffffc02019b8 <etext+0x3ba>
ffffffffc0200b0a:	c17ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    int max_block_size = (1 << max_order);
    // 分配这个最大的块
    struct Page *p_max = alloc_pages(max_block_size);
ffffffffc0200b0e:	8556                	mv	a0,s5
ffffffffc0200b10:	46a000ef          	jal	ra,ffffffffc0200f7a <alloc_pages>
ffffffffc0200b14:	8a2a                	mv	s4,a0
    show_buddy_info("分配最大块后");
ffffffffc0200b16:	00001517          	auipc	a0,0x1
ffffffffc0200b1a:	22a50513          	addi	a0,a0,554 # ffffffffc0201d40 <etext+0x742>
ffffffffc0200b1e:	c03ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    assert(p_max != NULL);
ffffffffc0200b22:	220a0263          	beqz	s4,ffffffffc0200d46 <buddy_check+0x438>
    cprintf("   - 已分配最大块。通过。\n");
ffffffffc0200b26:	00001517          	auipc	a0,0x1
ffffffffc0200b2a:	24250513          	addi	a0,a0,578 # ffffffffc0201d68 <etext+0x76a>
ffffffffc0200b2e:	e1eff0ef          	jal	ra,ffffffffc020014c <cprintf>
    assert(buddy_nr_free_pages() == initial_free - max_block_size);
ffffffffc0200b32:	00093783          	ld	a5,0(s2)
ffffffffc0200b36:	41598733          	sub	a4,s3,s5
ffffffffc0200b3a:	1ef71663          	bne	a4,a5,ffffffffc0200d26 <buddy_check+0x418>

    // 释放这个最大的块
    free_pages(p_max, max_block_size);
ffffffffc0200b3e:	85d6                	mv	a1,s5
ffffffffc0200b40:	8552                	mv	a0,s4
ffffffffc0200b42:	444000ef          	jal	ra,ffffffffc0200f86 <free_pages>
    show_buddy_info("释放最大块后");
ffffffffc0200b46:	00001517          	auipc	a0,0x1
ffffffffc0200b4a:	28250513          	addi	a0,a0,642 # ffffffffc0201dc8 <etext+0x7ca>
ffffffffc0200b4e:	bd3ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    assert(buddy_nr_free_pages() == initial_free);
ffffffffc0200b52:	00093783          	ld	a5,0(s2)
ffffffffc0200b56:	1af99863          	bne	s3,a5,ffffffffc0200d06 <buddy_check+0x3f8>
    cprintf("   - 已释放最大块。通过。\n");
ffffffffc0200b5a:	00001517          	auipc	a0,0x1
ffffffffc0200b5e:	28650513          	addi	a0,a0,646 # ffffffffc0201de0 <etext+0x7e2>
ffffffffc0200b62:	deaff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int i = MAX_ORDER - 1; i >= 0; i--) {
ffffffffc0200b66:	47b9                	li	a5,14
ffffffffc0200b68:	56fd                	li	a3,-1
        if (!list_empty(&(free_area[i].free_list))) {
ffffffffc0200b6a:	6418                	ld	a4,8(s0)
ffffffffc0200b6c:	00871663          	bne	a4,s0,ffffffffc0200b78 <buddy_check+0x26a>
    for (int i = MAX_ORDER - 1; i >= 0; i--) {
ffffffffc0200b70:	37fd                	addiw	a5,a5,-1
ffffffffc0200b72:	1421                	addi	s0,s0,-24
ffffffffc0200b74:	fed79be3          	bne	a5,a3,ffffffffc0200b6a <buddy_check+0x25c>
    
    // 再次查找最大块,阶数应该和之前一样
    assert(find_max_order() == max_order);
ffffffffc0200b78:	16f49763          	bne	s1,a5,ffffffffc0200ce6 <buddy_check+0x3d8>
    cprintf("   - 验证通过: 最大块再次可用。\n");
ffffffffc0200b7c:	00001517          	auipc	a0,0x1
ffffffffc0200b80:	2ac50513          	addi	a0,a0,684 # ffffffffc0201e28 <etext+0x82a>
ffffffffc0200b84:	dc8ff0ef          	jal	ra,ffffffffc020014c <cprintf>

    cprintf("5. “穿插打孔”碎片化与合并\n");
ffffffffc0200b88:	00001517          	auipc	a0,0x1
ffffffffc0200b8c:	2d050513          	addi	a0,a0,720 # ffffffffc0201e58 <etext+0x85a>
ffffffffc0200b90:	dbcff0ef          	jal	ra,ffffffffc020014c <cprintf>
    show_buddy_info("初始状态");
ffffffffc0200b94:	00001517          	auipc	a0,0x1
ffffffffc0200b98:	e2450513          	addi	a0,a0,-476 # ffffffffc02019b8 <etext+0x3ba>
ffffffffc0200b9c:	b85ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    const int ALLOC_COUNT = 20;
    const int ALLOC_SIZE = 4;
    struct Page *allocated[ALLOC_COUNT];

    for (int i = 0; i < ALLOC_COUNT; i++) {
ffffffffc0200ba0:	1104                	addi	s1,sp,160
    show_buddy_info("初始状态");
ffffffffc0200ba2:	840a                	mv	s0,sp
        allocated[i] = alloc_pages(ALLOC_SIZE);
ffffffffc0200ba4:	4511                	li	a0,4
ffffffffc0200ba6:	3d4000ef          	jal	ra,ffffffffc0200f7a <alloc_pages>
ffffffffc0200baa:	e008                	sd	a0,0(s0)
        assert(allocated[i] != NULL);
ffffffffc0200bac:	cd4d                	beqz	a0,ffffffffc0200c66 <buddy_check+0x358>
    for (int i = 0; i < ALLOC_COUNT; i++) {
ffffffffc0200bae:	0421                	addi	s0,s0,8
ffffffffc0200bb0:	fe941ae3          	bne	s0,s1,ffffffffc0200ba4 <buddy_check+0x296>
    }
    show_buddy_info("分配 20 个 4 页块后");
ffffffffc0200bb4:	00001517          	auipc	a0,0x1
ffffffffc0200bb8:	2ec50513          	addi	a0,a0,748 # ffffffffc0201ea0 <etext+0x8a2>
ffffffffc0200bbc:	b65ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    cprintf("   - 连续分配了 %d 个 %d 页大小的块. OK.\n", ALLOC_COUNT, ALLOC_SIZE);
ffffffffc0200bc0:	4611                	li	a2,4
ffffffffc0200bc2:	45d1                	li	a1,20
ffffffffc0200bc4:	00001517          	auipc	a0,0x1
ffffffffc0200bc8:	2fc50513          	addi	a0,a0,764 # ffffffffc0201ec0 <etext+0x8c2>
ffffffffc0200bcc:	d80ff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200bd0:	840a                	mv	s0,sp
    // 释放偶数块，制造孔洞
    for (int i = 0; i < ALLOC_COUNT; i += 2) {
        free_pages(allocated[i], ALLOC_SIZE);
ffffffffc0200bd2:	6008                	ld	a0,0(s0)
ffffffffc0200bd4:	4591                	li	a1,4
    for (int i = 0; i < ALLOC_COUNT; i += 2) {
ffffffffc0200bd6:	0441                	addi	s0,s0,16
        free_pages(allocated[i], ALLOC_SIZE);
ffffffffc0200bd8:	3ae000ef          	jal	ra,ffffffffc0200f86 <free_pages>
    for (int i = 0; i < ALLOC_COUNT; i += 2) {
ffffffffc0200bdc:	fe941be3          	bne	s0,s1,ffffffffc0200bd2 <buddy_check+0x2c4>
    }
    show_buddy_info("释放所有偶数块后");
ffffffffc0200be0:	00001517          	auipc	a0,0x1
ffffffffc0200be4:	31850513          	addi	a0,a0,792 # ffffffffc0201ef8 <etext+0x8fa>
ffffffffc0200be8:	b39ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    cprintf("   - 释放了所有偶数块，制造碎片. OK.\n");
ffffffffc0200bec:	00001517          	auipc	a0,0x1
ffffffffc0200bf0:	32c50513          	addi	a0,a0,812 # ffffffffc0201f18 <etext+0x91a>
ffffffffc0200bf4:	d58ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    assert(buddy_nr_free_pages() == initial_free - (ALLOC_COUNT / 2) * ALLOC_SIZE);
ffffffffc0200bf8:	00093703          	ld	a4,0(s2)
ffffffffc0200bfc:	fd898793          	addi	a5,s3,-40
ffffffffc0200c00:	0020                	addi	s0,sp,8
ffffffffc0200c02:	1124                	addi	s1,sp,168
ffffffffc0200c04:	08e79163          	bne	a5,a4,ffffffffc0200c86 <buddy_check+0x378>

    // 释放奇数块，触发合并
    for (int i = 1; i < ALLOC_COUNT; i += 2) {
        free_pages(allocated[i], ALLOC_SIZE);
ffffffffc0200c08:	6008                	ld	a0,0(s0)
ffffffffc0200c0a:	4591                	li	a1,4
    for (int i = 1; i < ALLOC_COUNT; i += 2) {
ffffffffc0200c0c:	0441                	addi	s0,s0,16
        free_pages(allocated[i], ALLOC_SIZE);
ffffffffc0200c0e:	378000ef          	jal	ra,ffffffffc0200f86 <free_pages>
    for (int i = 1; i < ALLOC_COUNT; i += 2) {
ffffffffc0200c12:	fe941be3          	bne	s0,s1,ffffffffc0200c08 <buddy_check+0x2fa>
    }
    show_buddy_info("释放所有奇数块后");
ffffffffc0200c16:	00001517          	auipc	a0,0x1
ffffffffc0200c1a:	38250513          	addi	a0,a0,898 # ffffffffc0201f98 <etext+0x99a>
ffffffffc0200c1e:	b03ff0ef          	jal	ra,ffffffffc0200720 <show_buddy_info>
    cprintf("   - 释放了所有奇数块，触发合并. OK.\n");
ffffffffc0200c22:	00001517          	auipc	a0,0x1
ffffffffc0200c26:	39650513          	addi	a0,a0,918 # ffffffffc0201fb8 <etext+0x9ba>
ffffffffc0200c2a:	d22ff0ef          	jal	ra,ffffffffc020014c <cprintf>

    assert(buddy_nr_free_pages() == initial_free);
ffffffffc0200c2e:	00093783          	ld	a5,0(s2)
ffffffffc0200c32:	08f99a63          	bne	s3,a5,ffffffffc0200cc6 <buddy_check+0x3b8>
    cprintf("   - PASS: 碎片化合并测试正确.\n\n");
ffffffffc0200c36:	00001517          	auipc	a0,0x1
ffffffffc0200c3a:	3ba50513          	addi	a0,a0,954 # ffffffffc0201ff0 <etext+0x9f2>
ffffffffc0200c3e:	d0eff0ef          	jal	ra,ffffffffc020014c <cprintf>

    cprintf("=== 伙伴系统测试完成 ===\n");
}
ffffffffc0200c42:	644e                	ld	s0,208(sp)
ffffffffc0200c44:	60ee                	ld	ra,216(sp)
ffffffffc0200c46:	64ae                	ld	s1,200(sp)
ffffffffc0200c48:	690e                	ld	s2,192(sp)
ffffffffc0200c4a:	79ea                	ld	s3,184(sp)
ffffffffc0200c4c:	7a4a                	ld	s4,176(sp)
ffffffffc0200c4e:	7aaa                	ld	s5,168(sp)
    cprintf("=== 伙伴系统测试完成 ===\n");
ffffffffc0200c50:	00001517          	auipc	a0,0x1
ffffffffc0200c54:	3d050513          	addi	a0,a0,976 # ffffffffc0202020 <etext+0xa22>
}
ffffffffc0200c58:	612d                	addi	sp,sp,224
    cprintf("=== 伙伴系统测试完成 ===\n");
ffffffffc0200c5a:	cf2ff06f          	j	ffffffffc020014c <cprintf>
    int max_block_size = (1 << max_order);
ffffffffc0200c5e:	4a85                	li	s5,1
    struct Page *p_max = alloc_pages(max_block_size);
ffffffffc0200c60:	009a9abb          	sllw	s5,s5,s1
ffffffffc0200c64:	bd79                	j	ffffffffc0200b02 <buddy_check+0x1f4>
        assert(allocated[i] != NULL);
ffffffffc0200c66:	00001697          	auipc	a3,0x1
ffffffffc0200c6a:	22268693          	addi	a3,a3,546 # ffffffffc0201e88 <etext+0x88a>
ffffffffc0200c6e:	00001617          	auipc	a2,0x1
ffffffffc0200c72:	c6260613          	addi	a2,a2,-926 # ffffffffc02018d0 <etext+0x2d2>
ffffffffc0200c76:	12a00593          	li	a1,298
ffffffffc0200c7a:	00001517          	auipc	a0,0x1
ffffffffc0200c7e:	c6e50513          	addi	a0,a0,-914 # ffffffffc02018e8 <etext+0x2ea>
ffffffffc0200c82:	d40ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() == initial_free - (ALLOC_COUNT / 2) * ALLOC_SIZE);
ffffffffc0200c86:	00001697          	auipc	a3,0x1
ffffffffc0200c8a:	2ca68693          	addi	a3,a3,714 # ffffffffc0201f50 <etext+0x952>
ffffffffc0200c8e:	00001617          	auipc	a2,0x1
ffffffffc0200c92:	c4260613          	addi	a2,a2,-958 # ffffffffc02018d0 <etext+0x2d2>
ffffffffc0200c96:	13400593          	li	a1,308
ffffffffc0200c9a:	00001517          	auipc	a0,0x1
ffffffffc0200c9e:	c4e50513          	addi	a0,a0,-946 # ffffffffc02018e8 <etext+0x2ea>
ffffffffc0200ca2:	d20ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p1 != NULL);
ffffffffc0200ca6:	00001697          	auipc	a3,0x1
ffffffffc0200caa:	d3a68693          	addi	a3,a3,-710 # ffffffffc02019e0 <etext+0x3e2>
ffffffffc0200cae:	00001617          	auipc	a2,0x1
ffffffffc0200cb2:	c2260613          	addi	a2,a2,-990 # ffffffffc02018d0 <etext+0x2d2>
ffffffffc0200cb6:	0d100593          	li	a1,209
ffffffffc0200cba:	00001517          	auipc	a0,0x1
ffffffffc0200cbe:	c2e50513          	addi	a0,a0,-978 # ffffffffc02018e8 <etext+0x2ea>
ffffffffc0200cc2:	d00ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() == initial_free);
ffffffffc0200cc6:	00001697          	auipc	a3,0x1
ffffffffc0200cca:	d9a68693          	addi	a3,a3,-614 # ffffffffc0201a60 <etext+0x462>
ffffffffc0200cce:	00001617          	auipc	a2,0x1
ffffffffc0200cd2:	c0260613          	addi	a2,a2,-1022 # ffffffffc02018d0 <etext+0x2d2>
ffffffffc0200cd6:	13d00593          	li	a1,317
ffffffffc0200cda:	00001517          	auipc	a0,0x1
ffffffffc0200cde:	c0e50513          	addi	a0,a0,-1010 # ffffffffc02018e8 <etext+0x2ea>
ffffffffc0200ce2:	ce0ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(find_max_order() == max_order);
ffffffffc0200ce6:	00001697          	auipc	a3,0x1
ffffffffc0200cea:	12268693          	addi	a3,a3,290 # ffffffffc0201e08 <etext+0x80a>
ffffffffc0200cee:	00001617          	auipc	a2,0x1
ffffffffc0200cf2:	be260613          	addi	a2,a2,-1054 # ffffffffc02018d0 <etext+0x2d2>
ffffffffc0200cf6:	11f00593          	li	a1,287
ffffffffc0200cfa:	00001517          	auipc	a0,0x1
ffffffffc0200cfe:	bee50513          	addi	a0,a0,-1042 # ffffffffc02018e8 <etext+0x2ea>
ffffffffc0200d02:	cc0ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() == initial_free);
ffffffffc0200d06:	00001697          	auipc	a3,0x1
ffffffffc0200d0a:	d5a68693          	addi	a3,a3,-678 # ffffffffc0201a60 <etext+0x462>
ffffffffc0200d0e:	00001617          	auipc	a2,0x1
ffffffffc0200d12:	bc260613          	addi	a2,a2,-1086 # ffffffffc02018d0 <etext+0x2d2>
ffffffffc0200d16:	11b00593          	li	a1,283
ffffffffc0200d1a:	00001517          	auipc	a0,0x1
ffffffffc0200d1e:	bce50513          	addi	a0,a0,-1074 # ffffffffc02018e8 <etext+0x2ea>
ffffffffc0200d22:	ca0ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() == initial_free - max_block_size);
ffffffffc0200d26:	00001697          	auipc	a3,0x1
ffffffffc0200d2a:	06a68693          	addi	a3,a3,106 # ffffffffc0201d90 <etext+0x792>
ffffffffc0200d2e:	00001617          	auipc	a2,0x1
ffffffffc0200d32:	ba260613          	addi	a2,a2,-1118 # ffffffffc02018d0 <etext+0x2d2>
ffffffffc0200d36:	11600593          	li	a1,278
ffffffffc0200d3a:	00001517          	auipc	a0,0x1
ffffffffc0200d3e:	bae50513          	addi	a0,a0,-1106 # ffffffffc02018e8 <etext+0x2ea>
ffffffffc0200d42:	c80ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p_max != NULL);
ffffffffc0200d46:	00001697          	auipc	a3,0x1
ffffffffc0200d4a:	01268693          	addi	a3,a3,18 # ffffffffc0201d58 <etext+0x75a>
ffffffffc0200d4e:	00001617          	auipc	a2,0x1
ffffffffc0200d52:	b8260613          	addi	a2,a2,-1150 # ffffffffc02018d0 <etext+0x2d2>
ffffffffc0200d56:	11400593          	li	a1,276
ffffffffc0200d5a:	00001517          	auipc	a0,0x1
ffffffffc0200d5e:	b8e50513          	addi	a0,a0,-1138 # ffffffffc02018e8 <etext+0x2ea>
ffffffffc0200d62:	c60ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() == initial_free);
ffffffffc0200d66:	00001697          	auipc	a3,0x1
ffffffffc0200d6a:	cfa68693          	addi	a3,a3,-774 # ffffffffc0201a60 <etext+0x462>
ffffffffc0200d6e:	00001617          	auipc	a2,0x1
ffffffffc0200d72:	b6260613          	addi	a2,a2,-1182 # ffffffffc02018d0 <etext+0x2d2>
ffffffffc0200d76:	10600593          	li	a1,262
ffffffffc0200d7a:	00001517          	auipc	a0,0x1
ffffffffc0200d7e:	b6e50513          	addi	a0,a0,-1170 # ffffffffc02018e8 <etext+0x2ea>
ffffffffc0200d82:	c40ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p_min != NULL);
ffffffffc0200d86:	00001697          	auipc	a3,0x1
ffffffffc0200d8a:	eea68693          	addi	a3,a3,-278 # ffffffffc0201c70 <etext+0x672>
ffffffffc0200d8e:	00001617          	auipc	a2,0x1
ffffffffc0200d92:	b4260613          	addi	a2,a2,-1214 # ffffffffc02018d0 <etext+0x2d2>
ffffffffc0200d96:	0fc00593          	li	a1,252
ffffffffc0200d9a:	00001517          	auipc	a0,0x1
ffffffffc0200d9e:	b4e50513          	addi	a0,a0,-1202 # ffffffffc02018e8 <etext+0x2ea>
ffffffffc0200da2:	c20ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() == initial_free);
ffffffffc0200da6:	00001697          	auipc	a3,0x1
ffffffffc0200daa:	cba68693          	addi	a3,a3,-838 # ffffffffc0201a60 <etext+0x462>
ffffffffc0200dae:	00001617          	auipc	a2,0x1
ffffffffc0200db2:	b2260613          	addi	a2,a2,-1246 # ffffffffc02018d0 <etext+0x2d2>
ffffffffc0200db6:	0f000593          	li	a1,240
ffffffffc0200dba:	00001517          	auipc	a0,0x1
ffffffffc0200dbe:	b2e50513          	addi	a0,a0,-1234 # ffffffffc02018e8 <etext+0x2ea>
ffffffffc0200dc2:	c00ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() == initial_free - 4);
ffffffffc0200dc6:	00001697          	auipc	a3,0x1
ffffffffc0200dca:	e0268693          	addi	a3,a3,-510 # ffffffffc0201bc8 <etext+0x5ca>
ffffffffc0200dce:	00001617          	auipc	a2,0x1
ffffffffc0200dd2:	b0260613          	addi	a2,a2,-1278 # ffffffffc02018d0 <etext+0x2d2>
ffffffffc0200dd6:	0eb00593          	li	a1,235
ffffffffc0200dda:	00001517          	auipc	a0,0x1
ffffffffc0200dde:	b0e50513          	addi	a0,a0,-1266 # ffffffffc02018e8 <etext+0x2ea>
ffffffffc0200de2:	be0ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() == initial_free - 4 - 16);
ffffffffc0200de6:	00001697          	auipc	a3,0x1
ffffffffc0200dea:	d3a68693          	addi	a3,a3,-710 # ffffffffc0201b20 <etext+0x522>
ffffffffc0200dee:	00001617          	auipc	a2,0x1
ffffffffc0200df2:	ae260613          	addi	a2,a2,-1310 # ffffffffc02018d0 <etext+0x2d2>
ffffffffc0200df6:	0e500593          	li	a1,229
ffffffffc0200dfa:	00001517          	auipc	a0,0x1
ffffffffc0200dfe:	aee50513          	addi	a0,a0,-1298 # ffffffffc02018e8 <etext+0x2ea>
ffffffffc0200e02:	bc0ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p2 != NULL && p3 != NULL);
ffffffffc0200e06:	00001697          	auipc	a3,0x1
ffffffffc0200e0a:	cfa68693          	addi	a3,a3,-774 # ffffffffc0201b00 <etext+0x502>
ffffffffc0200e0e:	00001617          	auipc	a2,0x1
ffffffffc0200e12:	ac260613          	addi	a2,a2,-1342 # ffffffffc02018d0 <etext+0x2d2>
ffffffffc0200e16:	0e400593          	li	a1,228
ffffffffc0200e1a:	00001517          	auipc	a0,0x1
ffffffffc0200e1e:	ace50513          	addi	a0,a0,-1330 # ffffffffc02018e8 <etext+0x2ea>
ffffffffc0200e22:	ba0ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() == initial_free);
ffffffffc0200e26:	00001697          	auipc	a3,0x1
ffffffffc0200e2a:	c3a68693          	addi	a3,a3,-966 # ffffffffc0201a60 <etext+0x462>
ffffffffc0200e2e:	00001617          	auipc	a2,0x1
ffffffffc0200e32:	aa260613          	addi	a2,a2,-1374 # ffffffffc02018d0 <etext+0x2d2>
ffffffffc0200e36:	0d700593          	li	a1,215
ffffffffc0200e3a:	00001517          	auipc	a0,0x1
ffffffffc0200e3e:	aae50513          	addi	a0,a0,-1362 # ffffffffc02018e8 <etext+0x2ea>
ffffffffc0200e42:	b80ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() == initial_free - 16);
ffffffffc0200e46:	00001697          	auipc	a3,0x1
ffffffffc0200e4a:	baa68693          	addi	a3,a3,-1110 # ffffffffc02019f0 <etext+0x3f2>
ffffffffc0200e4e:	00001617          	auipc	a2,0x1
ffffffffc0200e52:	a8260613          	addi	a2,a2,-1406 # ffffffffc02018d0 <etext+0x2d2>
ffffffffc0200e56:	0d200593          	li	a1,210
ffffffffc0200e5a:	00001517          	auipc	a0,0x1
ffffffffc0200e5e:	a8e50513          	addi	a0,a0,-1394 # ffffffffc02018e8 <etext+0x2ea>
ffffffffc0200e62:	b60ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200e66 <buddy_init_memmap>:
static void buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200e66:	1141                	addi	sp,sp,-16
ffffffffc0200e68:	e406                	sd	ra,8(sp)
ffffffffc0200e6a:	e022                	sd	s0,0(sp)
    assert(n > 0);
ffffffffc0200e6c:	c5fd                	beqz	a1,ffffffffc0200f5a <buddy_init_memmap+0xf4>
    for (struct Page *p = base; p < base + n; p++) {
ffffffffc0200e6e:	00259693          	slli	a3,a1,0x2
ffffffffc0200e72:	96ae                	add	a3,a3,a1
ffffffffc0200e74:	068e                	slli	a3,a3,0x3
ffffffffc0200e76:	96aa                	add	a3,a3,a0
ffffffffc0200e78:	87aa                	mv	a5,a0
ffffffffc0200e7a:	00d57f63          	bgeu	a0,a3,ffffffffc0200e98 <buddy_init_memmap+0x32>
        assert(PageReserved(p));
ffffffffc0200e7e:	6798                	ld	a4,8(a5)
ffffffffc0200e80:	8b05                	andi	a4,a4,1
ffffffffc0200e82:	cf45                	beqz	a4,ffffffffc0200f3a <buddy_init_memmap+0xd4>
        p->flags = 0;
ffffffffc0200e84:	0007b423          	sd	zero,8(a5)
        p->property = 0; 
ffffffffc0200e88:	0007a823          	sw	zero,16(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200e8c:	0007a023          	sw	zero,0(a5)
    for (struct Page *p = base; p < base + n; p++) {
ffffffffc0200e90:	02878793          	addi	a5,a5,40
ffffffffc0200e94:	fed7e5e3          	bltu	a5,a3,ffffffffc0200e7e <buddy_init_memmap+0x18>
ffffffffc0200e98:	00005417          	auipc	s0,0x5
ffffffffc0200e9c:	30040413          	addi	s0,s0,768 # ffffffffc0206198 <nr_free>
ffffffffc0200ea0:	00043283          	ld	t0,0(s0)
ffffffffc0200ea4:	00005397          	auipc	t2,0x5
ffffffffc0200ea8:	17438393          	addi	t2,t2,372 # ffffffffc0206018 <free_area>
        while (order + 1 < MAX_ORDER && (1 << (order + 1)) <= total_pages) {
ffffffffc0200eac:	4605                	li	a2,1
ffffffffc0200eae:	4839                	li	a6,14
    for (struct Page *p = base; p < base + n; p++) {
ffffffffc0200eb0:	4781                	li	a5,0
        while (order + 1 < MAX_ORDER && (1 << (order + 1)) <= total_pages) {
ffffffffc0200eb2:	0017871b          	addiw	a4,a5,1
ffffffffc0200eb6:	00e6173b          	sllw	a4,a2,a4
ffffffffc0200eba:	0007869b          	sext.w	a3,a5
ffffffffc0200ebe:	06e5e263          	bltu	a1,a4,ffffffffc0200f22 <buddy_init_memmap+0xbc>
ffffffffc0200ec2:	0785                	addi	a5,a5,1
ffffffffc0200ec4:	ff0797e3          	bne	a5,a6,ffffffffc0200eb2 <buddy_init_memmap+0x4c>
ffffffffc0200ec8:	000a0f37          	lui	t5,0xa0
ffffffffc0200ecc:	6e91                	lui	t4,0x4
ffffffffc0200ece:	46b9                	li	a3,14
ffffffffc0200ed0:	15000893          	li	a7,336
ffffffffc0200ed4:	00179713          	slli	a4,a5,0x1
    __list_add(elm, listelm, listelm->next);
ffffffffc0200ed8:	97ba                	add	a5,a5,a4
ffffffffc0200eda:	078e                	slli	a5,a5,0x3
ffffffffc0200edc:	979e                	add	a5,a5,t2
ffffffffc0200ede:	0087bf83          	ld	t6,8(a5)
        free_area[order].nr_free++;
ffffffffc0200ee2:	0107ae03          	lw	t3,16(a5)
        list_add(&(free_area[order].free_list), &(p->page_link));
ffffffffc0200ee6:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0200eea:	00efb023          	sd	a4,0(t6)
        SetPageProperty(p); // 标记它是一个空闲块的头部
ffffffffc0200eee:	00853303          	ld	t1,8(a0)
ffffffffc0200ef2:	e798                	sd	a4,8(a5)
        list_add(&(free_area[order].free_list), &(p->page_link));
ffffffffc0200ef4:	01138733          	add	a4,t2,a7
    elm->prev = prev;
ffffffffc0200ef8:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc0200efa:	03f53023          	sd	t6,32(a0)
        free_area[order].nr_free++;
ffffffffc0200efe:	001e071b          	addiw	a4,t3,1
ffffffffc0200f02:	cb98                	sw	a4,16(a5)
        SetPageProperty(p); // 标记它是一个空闲块的头部
ffffffffc0200f04:	00236793          	ori	a5,t1,2
        p->property = order;
ffffffffc0200f08:	c914                	sw	a3,16(a0)
        SetPageProperty(p); // 标记它是一个空闲块的头部
ffffffffc0200f0a:	e51c                	sd	a5,8(a0)
        total_pages -= (1 << order);
ffffffffc0200f0c:	41d585b3          	sub	a1,a1,t4
        nr_free += (1 << order);
ffffffffc0200f10:	92f6                	add	t0,t0,t4
        p += (1 << order);
ffffffffc0200f12:	957a                	add	a0,a0,t5
    while (total_pages > 0) {
ffffffffc0200f14:	fdd1                	bnez	a1,ffffffffc0200eb0 <buddy_init_memmap+0x4a>
}
ffffffffc0200f16:	60a2                	ld	ra,8(sp)
ffffffffc0200f18:	00543023          	sd	t0,0(s0)
ffffffffc0200f1c:	6402                	ld	s0,0(sp)
ffffffffc0200f1e:	0141                	addi	sp,sp,16
ffffffffc0200f20:	8082                	ret
        nr_free += (1 << order);
ffffffffc0200f22:	00d61ebb          	sllw	t4,a2,a3
ffffffffc0200f26:	00179713          	slli	a4,a5,0x1
        p += (1 << order);
ffffffffc0200f2a:	002e9f13          	slli	t5,t4,0x2
ffffffffc0200f2e:	00f708b3          	add	a7,a4,a5
ffffffffc0200f32:	9f76                	add	t5,t5,t4
ffffffffc0200f34:	088e                	slli	a7,a7,0x3
ffffffffc0200f36:	0f0e                	slli	t5,t5,0x3
ffffffffc0200f38:	b745                	j	ffffffffc0200ed8 <buddy_init_memmap+0x72>
        assert(PageReserved(p));
ffffffffc0200f3a:	00001697          	auipc	a3,0x1
ffffffffc0200f3e:	10e68693          	addi	a3,a3,270 # ffffffffc0202048 <etext+0xa4a>
ffffffffc0200f42:	00001617          	auipc	a2,0x1
ffffffffc0200f46:	98e60613          	addi	a2,a2,-1650 # ffffffffc02018d0 <etext+0x2d2>
ffffffffc0200f4a:	02b00593          	li	a1,43
ffffffffc0200f4e:	00001517          	auipc	a0,0x1
ffffffffc0200f52:	99a50513          	addi	a0,a0,-1638 # ffffffffc02018e8 <etext+0x2ea>
ffffffffc0200f56:	a6cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc0200f5a:	00001697          	auipc	a3,0x1
ffffffffc0200f5e:	96e68693          	addi	a3,a3,-1682 # ffffffffc02018c8 <etext+0x2ca>
ffffffffc0200f62:	00001617          	auipc	a2,0x1
ffffffffc0200f66:	96e60613          	addi	a2,a2,-1682 # ffffffffc02018d0 <etext+0x2d2>
ffffffffc0200f6a:	02700593          	li	a1,39
ffffffffc0200f6e:	00001517          	auipc	a0,0x1
ffffffffc0200f72:	97a50513          	addi	a0,a0,-1670 # ffffffffc02018e8 <etext+0x2ea>
ffffffffc0200f76:	a4cff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200f7a <alloc_pages>:
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
    return pmm_manager->alloc_pages(n);
ffffffffc0200f7a:	00005797          	auipc	a5,0x5
ffffffffc0200f7e:	2367b783          	ld	a5,566(a5) # ffffffffc02061b0 <pmm_manager>
ffffffffc0200f82:	6f9c                	ld	a5,24(a5)
ffffffffc0200f84:	8782                	jr	a5

ffffffffc0200f86 <free_pages>:
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    pmm_manager->free_pages(base, n);
ffffffffc0200f86:	00005797          	auipc	a5,0x5
ffffffffc0200f8a:	22a7b783          	ld	a5,554(a5) # ffffffffc02061b0 <pmm_manager>
ffffffffc0200f8e:	739c                	ld	a5,32(a5)
ffffffffc0200f90:	8782                	jr	a5

ffffffffc0200f92 <pmm_init>:
     pmm_manager = &buddy_pmm_manager;
ffffffffc0200f92:	00001797          	auipc	a5,0x1
ffffffffc0200f96:	0de78793          	addi	a5,a5,222 # ffffffffc0202070 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200f9a:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200f9c:	7179                	addi	sp,sp,-48
ffffffffc0200f9e:	f022                	sd	s0,32(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fa0:	00001517          	auipc	a0,0x1
ffffffffc0200fa4:	10850513          	addi	a0,a0,264 # ffffffffc02020a8 <buddy_pmm_manager+0x38>
     pmm_manager = &buddy_pmm_manager;
ffffffffc0200fa8:	00005417          	auipc	s0,0x5
ffffffffc0200fac:	20840413          	addi	s0,s0,520 # ffffffffc02061b0 <pmm_manager>
void pmm_init(void) {
ffffffffc0200fb0:	f406                	sd	ra,40(sp)
ffffffffc0200fb2:	ec26                	sd	s1,24(sp)
ffffffffc0200fb4:	e44e                	sd	s3,8(sp)
ffffffffc0200fb6:	e84a                	sd	s2,16(sp)
ffffffffc0200fb8:	e052                	sd	s4,0(sp)
     pmm_manager = &buddy_pmm_manager;
ffffffffc0200fba:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fbc:	990ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    pmm_manager->init();
ffffffffc0200fc0:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200fc2:	00005497          	auipc	s1,0x5
ffffffffc0200fc6:	20648493          	addi	s1,s1,518 # ffffffffc02061c8 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200fca:	679c                	ld	a5,8(a5)
ffffffffc0200fcc:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200fce:	57f5                	li	a5,-3
ffffffffc0200fd0:	07fa                	slli	a5,a5,0x1e
ffffffffc0200fd2:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();
ffffffffc0200fd4:	de8ff0ef          	jal	ra,ffffffffc02005bc <get_memory_base>
ffffffffc0200fd8:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc0200fda:	decff0ef          	jal	ra,ffffffffc02005c6 <get_memory_size>
    if (mem_size == 0) {
ffffffffc0200fde:	14050d63          	beqz	a0,ffffffffc0201138 <pmm_init+0x1a6>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200fe2:	892a                	mv	s2,a0
    cprintf("physcial memory map:\n");
ffffffffc0200fe4:	00001517          	auipc	a0,0x1
ffffffffc0200fe8:	10c50513          	addi	a0,a0,268 # ffffffffc02020f0 <buddy_pmm_manager+0x80>
ffffffffc0200fec:	960ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200ff0:	01298a33          	add	s4,s3,s2
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200ff4:	864e                	mv	a2,s3
ffffffffc0200ff6:	fffa0693          	addi	a3,s4,-1
ffffffffc0200ffa:	85ca                	mv	a1,s2
ffffffffc0200ffc:	00001517          	auipc	a0,0x1
ffffffffc0201000:	10c50513          	addi	a0,a0,268 # ffffffffc0202108 <buddy_pmm_manager+0x98>
ffffffffc0201004:	948ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0201008:	c80007b7          	lui	a5,0xc8000
ffffffffc020100c:	8652                	mv	a2,s4
ffffffffc020100e:	0d47e463          	bltu	a5,s4,ffffffffc02010d6 <pmm_init+0x144>
ffffffffc0201012:	00006797          	auipc	a5,0x6
ffffffffc0201016:	1bd78793          	addi	a5,a5,445 # ffffffffc02071cf <end+0xfff>
ffffffffc020101a:	757d                	lui	a0,0xfffff
ffffffffc020101c:	8d7d                	and	a0,a0,a5
ffffffffc020101e:	8231                	srli	a2,a2,0xc
ffffffffc0201020:	00005797          	auipc	a5,0x5
ffffffffc0201024:	18c7b023          	sd	a2,384(a5) # ffffffffc02061a0 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201028:	00005797          	auipc	a5,0x5
ffffffffc020102c:	18a7b023          	sd	a0,384(a5) # ffffffffc02061a8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201030:	000807b7          	lui	a5,0x80
ffffffffc0201034:	002005b7          	lui	a1,0x200
ffffffffc0201038:	02f60563          	beq	a2,a5,ffffffffc0201062 <pmm_init+0xd0>
ffffffffc020103c:	00261593          	slli	a1,a2,0x2
ffffffffc0201040:	00c586b3          	add	a3,a1,a2
ffffffffc0201044:	fec007b7          	lui	a5,0xfec00
ffffffffc0201048:	97aa                	add	a5,a5,a0
ffffffffc020104a:	068e                	slli	a3,a3,0x3
ffffffffc020104c:	96be                	add	a3,a3,a5
ffffffffc020104e:	87aa                	mv	a5,a0
        SetPageReserved(pages + i);
ffffffffc0201050:	6798                	ld	a4,8(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201052:	02878793          	addi	a5,a5,40 # fffffffffec00028 <end+0x3e9f9e58>
        SetPageReserved(pages + i);
ffffffffc0201056:	00176713          	ori	a4,a4,1
ffffffffc020105a:	fee7b023          	sd	a4,-32(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020105e:	fef699e3          	bne	a3,a5,ffffffffc0201050 <pmm_init+0xbe>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201062:	95b2                	add	a1,a1,a2
ffffffffc0201064:	fec006b7          	lui	a3,0xfec00
ffffffffc0201068:	96aa                	add	a3,a3,a0
ffffffffc020106a:	058e                	slli	a1,a1,0x3
ffffffffc020106c:	96ae                	add	a3,a3,a1
ffffffffc020106e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201072:	0af6e763          	bltu	a3,a5,ffffffffc0201120 <pmm_init+0x18e>
ffffffffc0201076:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0201078:	77fd                	lui	a5,0xfffff
ffffffffc020107a:	00fa75b3          	and	a1,s4,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020107e:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201080:	04b6ee63          	bltu	a3,a1,ffffffffc02010dc <pmm_init+0x14a>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201084:	601c                	ld	a5,0(s0)
ffffffffc0201086:	7b9c                	ld	a5,48(a5)
ffffffffc0201088:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020108a:	00001517          	auipc	a0,0x1
ffffffffc020108e:	0d650513          	addi	a0,a0,214 # ffffffffc0202160 <buddy_pmm_manager+0xf0>
ffffffffc0201092:	8baff0ef          	jal	ra,ffffffffc020014c <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201096:	00004597          	auipc	a1,0x4
ffffffffc020109a:	f6a58593          	addi	a1,a1,-150 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc020109e:	00005797          	auipc	a5,0x5
ffffffffc02010a2:	12b7b123          	sd	a1,290(a5) # ffffffffc02061c0 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02010a6:	c02007b7          	lui	a5,0xc0200
ffffffffc02010aa:	0af5e363          	bltu	a1,a5,ffffffffc0201150 <pmm_init+0x1be>
ffffffffc02010ae:	6090                	ld	a2,0(s1)
}
ffffffffc02010b0:	7402                	ld	s0,32(sp)
ffffffffc02010b2:	70a2                	ld	ra,40(sp)
ffffffffc02010b4:	64e2                	ld	s1,24(sp)
ffffffffc02010b6:	6942                	ld	s2,16(sp)
ffffffffc02010b8:	69a2                	ld	s3,8(sp)
ffffffffc02010ba:	6a02                	ld	s4,0(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02010bc:	40c58633          	sub	a2,a1,a2
ffffffffc02010c0:	00005797          	auipc	a5,0x5
ffffffffc02010c4:	0ec7bc23          	sd	a2,248(a5) # ffffffffc02061b8 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02010c8:	00001517          	auipc	a0,0x1
ffffffffc02010cc:	0b850513          	addi	a0,a0,184 # ffffffffc0202180 <buddy_pmm_manager+0x110>
}
ffffffffc02010d0:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02010d2:	87aff06f          	j	ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc02010d6:	c8000637          	lui	a2,0xc8000
ffffffffc02010da:	bf25                	j	ffffffffc0201012 <pmm_init+0x80>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02010dc:	6705                	lui	a4,0x1
ffffffffc02010de:	177d                	addi	a4,a4,-1
ffffffffc02010e0:	96ba                	add	a3,a3,a4
ffffffffc02010e2:	8efd                	and	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02010e4:	00c6d793          	srli	a5,a3,0xc
ffffffffc02010e8:	02c7f063          	bgeu	a5,a2,ffffffffc0201108 <pmm_init+0x176>
    pmm_manager->init_memmap(base, n);
ffffffffc02010ec:	6010                	ld	a2,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc02010ee:	fff80737          	lui	a4,0xfff80
ffffffffc02010f2:	973e                	add	a4,a4,a5
ffffffffc02010f4:	00271793          	slli	a5,a4,0x2
ffffffffc02010f8:	97ba                	add	a5,a5,a4
ffffffffc02010fa:	6a18                	ld	a4,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02010fc:	8d95                	sub	a1,a1,a3
ffffffffc02010fe:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201100:	81b1                	srli	a1,a1,0xc
ffffffffc0201102:	953e                	add	a0,a0,a5
ffffffffc0201104:	9702                	jalr	a4
}
ffffffffc0201106:	bfbd                	j	ffffffffc0201084 <pmm_init+0xf2>
        panic("pa2page called with invalid pa");
ffffffffc0201108:	00001617          	auipc	a2,0x1
ffffffffc020110c:	81060613          	addi	a2,a2,-2032 # ffffffffc0201918 <etext+0x31a>
ffffffffc0201110:	06a00593          	li	a1,106
ffffffffc0201114:	00001517          	auipc	a0,0x1
ffffffffc0201118:	82450513          	addi	a0,a0,-2012 # ffffffffc0201938 <etext+0x33a>
ffffffffc020111c:	8a6ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201120:	00001617          	auipc	a2,0x1
ffffffffc0201124:	01860613          	addi	a2,a2,24 # ffffffffc0202138 <buddy_pmm_manager+0xc8>
ffffffffc0201128:	06300593          	li	a1,99
ffffffffc020112c:	00001517          	auipc	a0,0x1
ffffffffc0201130:	fb450513          	addi	a0,a0,-76 # ffffffffc02020e0 <buddy_pmm_manager+0x70>
ffffffffc0201134:	88eff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("DTB memory info not available");
ffffffffc0201138:	00001617          	auipc	a2,0x1
ffffffffc020113c:	f8860613          	addi	a2,a2,-120 # ffffffffc02020c0 <buddy_pmm_manager+0x50>
ffffffffc0201140:	04b00593          	li	a1,75
ffffffffc0201144:	00001517          	auipc	a0,0x1
ffffffffc0201148:	f9c50513          	addi	a0,a0,-100 # ffffffffc02020e0 <buddy_pmm_manager+0x70>
ffffffffc020114c:	876ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201150:	86ae                	mv	a3,a1
ffffffffc0201152:	00001617          	auipc	a2,0x1
ffffffffc0201156:	fe660613          	addi	a2,a2,-26 # ffffffffc0202138 <buddy_pmm_manager+0xc8>
ffffffffc020115a:	07e00593          	li	a1,126
ffffffffc020115e:	00001517          	auipc	a0,0x1
ffffffffc0201162:	f8250513          	addi	a0,a0,-126 # ffffffffc02020e0 <buddy_pmm_manager+0x70>
ffffffffc0201166:	85cff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc020116a <printnum>:
ffffffffc020116a:	02069813          	slli	a6,a3,0x20
ffffffffc020116e:	7179                	addi	sp,sp,-48
ffffffffc0201170:	02085813          	srli	a6,a6,0x20
ffffffffc0201174:	e052                	sd	s4,0(sp)
ffffffffc0201176:	03067a33          	remu	s4,a2,a6
ffffffffc020117a:	f022                	sd	s0,32(sp)
ffffffffc020117c:	ec26                	sd	s1,24(sp)
ffffffffc020117e:	e84a                	sd	s2,16(sp)
ffffffffc0201180:	f406                	sd	ra,40(sp)
ffffffffc0201182:	e44e                	sd	s3,8(sp)
ffffffffc0201184:	84aa                	mv	s1,a0
ffffffffc0201186:	892e                	mv	s2,a1
ffffffffc0201188:	fff7041b          	addiw	s0,a4,-1
ffffffffc020118c:	2a01                	sext.w	s4,s4
ffffffffc020118e:	03067e63          	bgeu	a2,a6,ffffffffc02011ca <printnum+0x60>
ffffffffc0201192:	89be                	mv	s3,a5
ffffffffc0201194:	00805763          	blez	s0,ffffffffc02011a2 <printnum+0x38>
ffffffffc0201198:	347d                	addiw	s0,s0,-1
ffffffffc020119a:	85ca                	mv	a1,s2
ffffffffc020119c:	854e                	mv	a0,s3
ffffffffc020119e:	9482                	jalr	s1
ffffffffc02011a0:	fc65                	bnez	s0,ffffffffc0201198 <printnum+0x2e>
ffffffffc02011a2:	1a02                	slli	s4,s4,0x20
ffffffffc02011a4:	00001797          	auipc	a5,0x1
ffffffffc02011a8:	01c78793          	addi	a5,a5,28 # ffffffffc02021c0 <buddy_pmm_manager+0x150>
ffffffffc02011ac:	020a5a13          	srli	s4,s4,0x20
ffffffffc02011b0:	9a3e                	add	s4,s4,a5
ffffffffc02011b2:	7402                	ld	s0,32(sp)
ffffffffc02011b4:	000a4503          	lbu	a0,0(s4)
ffffffffc02011b8:	70a2                	ld	ra,40(sp)
ffffffffc02011ba:	69a2                	ld	s3,8(sp)
ffffffffc02011bc:	6a02                	ld	s4,0(sp)
ffffffffc02011be:	85ca                	mv	a1,s2
ffffffffc02011c0:	87a6                	mv	a5,s1
ffffffffc02011c2:	6942                	ld	s2,16(sp)
ffffffffc02011c4:	64e2                	ld	s1,24(sp)
ffffffffc02011c6:	6145                	addi	sp,sp,48
ffffffffc02011c8:	8782                	jr	a5
ffffffffc02011ca:	03065633          	divu	a2,a2,a6
ffffffffc02011ce:	8722                	mv	a4,s0
ffffffffc02011d0:	f9bff0ef          	jal	ra,ffffffffc020116a <printnum>
ffffffffc02011d4:	b7f9                	j	ffffffffc02011a2 <printnum+0x38>

ffffffffc02011d6 <vprintfmt>:
ffffffffc02011d6:	7119                	addi	sp,sp,-128
ffffffffc02011d8:	f4a6                	sd	s1,104(sp)
ffffffffc02011da:	f0ca                	sd	s2,96(sp)
ffffffffc02011dc:	ecce                	sd	s3,88(sp)
ffffffffc02011de:	e8d2                	sd	s4,80(sp)
ffffffffc02011e0:	e4d6                	sd	s5,72(sp)
ffffffffc02011e2:	e0da                	sd	s6,64(sp)
ffffffffc02011e4:	fc5e                	sd	s7,56(sp)
ffffffffc02011e6:	f06a                	sd	s10,32(sp)
ffffffffc02011e8:	fc86                	sd	ra,120(sp)
ffffffffc02011ea:	f8a2                	sd	s0,112(sp)
ffffffffc02011ec:	f862                	sd	s8,48(sp)
ffffffffc02011ee:	f466                	sd	s9,40(sp)
ffffffffc02011f0:	ec6e                	sd	s11,24(sp)
ffffffffc02011f2:	892a                	mv	s2,a0
ffffffffc02011f4:	84ae                	mv	s1,a1
ffffffffc02011f6:	8d32                	mv	s10,a2
ffffffffc02011f8:	8a36                	mv	s4,a3
ffffffffc02011fa:	02500993          	li	s3,37
ffffffffc02011fe:	5b7d                	li	s6,-1
ffffffffc0201200:	00001a97          	auipc	s5,0x1
ffffffffc0201204:	ff4a8a93          	addi	s5,s5,-12 # ffffffffc02021f4 <buddy_pmm_manager+0x184>
ffffffffc0201208:	00001b97          	auipc	s7,0x1
ffffffffc020120c:	1c8b8b93          	addi	s7,s7,456 # ffffffffc02023d0 <error_string>
ffffffffc0201210:	000d4503          	lbu	a0,0(s10)
ffffffffc0201214:	001d0413          	addi	s0,s10,1
ffffffffc0201218:	01350a63          	beq	a0,s3,ffffffffc020122c <vprintfmt+0x56>
ffffffffc020121c:	c121                	beqz	a0,ffffffffc020125c <vprintfmt+0x86>
ffffffffc020121e:	85a6                	mv	a1,s1
ffffffffc0201220:	0405                	addi	s0,s0,1
ffffffffc0201222:	9902                	jalr	s2
ffffffffc0201224:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201228:	ff351ae3          	bne	a0,s3,ffffffffc020121c <vprintfmt+0x46>
ffffffffc020122c:	00044603          	lbu	a2,0(s0)
ffffffffc0201230:	02000793          	li	a5,32
ffffffffc0201234:	4c81                	li	s9,0
ffffffffc0201236:	4881                	li	a7,0
ffffffffc0201238:	5c7d                	li	s8,-1
ffffffffc020123a:	5dfd                	li	s11,-1
ffffffffc020123c:	05500513          	li	a0,85
ffffffffc0201240:	4825                	li	a6,9
ffffffffc0201242:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201246:	0ff5f593          	zext.b	a1,a1
ffffffffc020124a:	00140d13          	addi	s10,s0,1
ffffffffc020124e:	04b56263          	bltu	a0,a1,ffffffffc0201292 <vprintfmt+0xbc>
ffffffffc0201252:	058a                	slli	a1,a1,0x2
ffffffffc0201254:	95d6                	add	a1,a1,s5
ffffffffc0201256:	4194                	lw	a3,0(a1)
ffffffffc0201258:	96d6                	add	a3,a3,s5
ffffffffc020125a:	8682                	jr	a3
ffffffffc020125c:	70e6                	ld	ra,120(sp)
ffffffffc020125e:	7446                	ld	s0,112(sp)
ffffffffc0201260:	74a6                	ld	s1,104(sp)
ffffffffc0201262:	7906                	ld	s2,96(sp)
ffffffffc0201264:	69e6                	ld	s3,88(sp)
ffffffffc0201266:	6a46                	ld	s4,80(sp)
ffffffffc0201268:	6aa6                	ld	s5,72(sp)
ffffffffc020126a:	6b06                	ld	s6,64(sp)
ffffffffc020126c:	7be2                	ld	s7,56(sp)
ffffffffc020126e:	7c42                	ld	s8,48(sp)
ffffffffc0201270:	7ca2                	ld	s9,40(sp)
ffffffffc0201272:	7d02                	ld	s10,32(sp)
ffffffffc0201274:	6de2                	ld	s11,24(sp)
ffffffffc0201276:	6109                	addi	sp,sp,128
ffffffffc0201278:	8082                	ret
ffffffffc020127a:	87b2                	mv	a5,a2
ffffffffc020127c:	00144603          	lbu	a2,1(s0)
ffffffffc0201280:	846a                	mv	s0,s10
ffffffffc0201282:	00140d13          	addi	s10,s0,1
ffffffffc0201286:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020128a:	0ff5f593          	zext.b	a1,a1
ffffffffc020128e:	fcb572e3          	bgeu	a0,a1,ffffffffc0201252 <vprintfmt+0x7c>
ffffffffc0201292:	85a6                	mv	a1,s1
ffffffffc0201294:	02500513          	li	a0,37
ffffffffc0201298:	9902                	jalr	s2
ffffffffc020129a:	fff44783          	lbu	a5,-1(s0)
ffffffffc020129e:	8d22                	mv	s10,s0
ffffffffc02012a0:	f73788e3          	beq	a5,s3,ffffffffc0201210 <vprintfmt+0x3a>
ffffffffc02012a4:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02012a8:	1d7d                	addi	s10,s10,-1
ffffffffc02012aa:	ff379de3          	bne	a5,s3,ffffffffc02012a4 <vprintfmt+0xce>
ffffffffc02012ae:	b78d                	j	ffffffffc0201210 <vprintfmt+0x3a>
ffffffffc02012b0:	fd060c1b          	addiw	s8,a2,-48
ffffffffc02012b4:	00144603          	lbu	a2,1(s0)
ffffffffc02012b8:	846a                	mv	s0,s10
ffffffffc02012ba:	fd06069b          	addiw	a3,a2,-48
ffffffffc02012be:	0006059b          	sext.w	a1,a2
ffffffffc02012c2:	02d86463          	bltu	a6,a3,ffffffffc02012ea <vprintfmt+0x114>
ffffffffc02012c6:	00144603          	lbu	a2,1(s0)
ffffffffc02012ca:	002c169b          	slliw	a3,s8,0x2
ffffffffc02012ce:	0186873b          	addw	a4,a3,s8
ffffffffc02012d2:	0017171b          	slliw	a4,a4,0x1
ffffffffc02012d6:	9f2d                	addw	a4,a4,a1
ffffffffc02012d8:	fd06069b          	addiw	a3,a2,-48
ffffffffc02012dc:	0405                	addi	s0,s0,1
ffffffffc02012de:	fd070c1b          	addiw	s8,a4,-48
ffffffffc02012e2:	0006059b          	sext.w	a1,a2
ffffffffc02012e6:	fed870e3          	bgeu	a6,a3,ffffffffc02012c6 <vprintfmt+0xf0>
ffffffffc02012ea:	f40ddce3          	bgez	s11,ffffffffc0201242 <vprintfmt+0x6c>
ffffffffc02012ee:	8de2                	mv	s11,s8
ffffffffc02012f0:	5c7d                	li	s8,-1
ffffffffc02012f2:	bf81                	j	ffffffffc0201242 <vprintfmt+0x6c>
ffffffffc02012f4:	fffdc693          	not	a3,s11
ffffffffc02012f8:	96fd                	srai	a3,a3,0x3f
ffffffffc02012fa:	00ddfdb3          	and	s11,s11,a3
ffffffffc02012fe:	00144603          	lbu	a2,1(s0)
ffffffffc0201302:	2d81                	sext.w	s11,s11
ffffffffc0201304:	846a                	mv	s0,s10
ffffffffc0201306:	bf35                	j	ffffffffc0201242 <vprintfmt+0x6c>
ffffffffc0201308:	000a2c03          	lw	s8,0(s4)
ffffffffc020130c:	00144603          	lbu	a2,1(s0)
ffffffffc0201310:	0a21                	addi	s4,s4,8
ffffffffc0201312:	846a                	mv	s0,s10
ffffffffc0201314:	bfd9                	j	ffffffffc02012ea <vprintfmt+0x114>
ffffffffc0201316:	4705                	li	a4,1
ffffffffc0201318:	008a0593          	addi	a1,s4,8
ffffffffc020131c:	01174463          	blt	a4,a7,ffffffffc0201324 <vprintfmt+0x14e>
ffffffffc0201320:	1a088e63          	beqz	a7,ffffffffc02014dc <vprintfmt+0x306>
ffffffffc0201324:	000a3603          	ld	a2,0(s4)
ffffffffc0201328:	46c1                	li	a3,16
ffffffffc020132a:	8a2e                	mv	s4,a1
ffffffffc020132c:	2781                	sext.w	a5,a5
ffffffffc020132e:	876e                	mv	a4,s11
ffffffffc0201330:	85a6                	mv	a1,s1
ffffffffc0201332:	854a                	mv	a0,s2
ffffffffc0201334:	e37ff0ef          	jal	ra,ffffffffc020116a <printnum>
ffffffffc0201338:	bde1                	j	ffffffffc0201210 <vprintfmt+0x3a>
ffffffffc020133a:	000a2503          	lw	a0,0(s4)
ffffffffc020133e:	85a6                	mv	a1,s1
ffffffffc0201340:	0a21                	addi	s4,s4,8
ffffffffc0201342:	9902                	jalr	s2
ffffffffc0201344:	b5f1                	j	ffffffffc0201210 <vprintfmt+0x3a>
ffffffffc0201346:	4705                	li	a4,1
ffffffffc0201348:	008a0593          	addi	a1,s4,8
ffffffffc020134c:	01174463          	blt	a4,a7,ffffffffc0201354 <vprintfmt+0x17e>
ffffffffc0201350:	18088163          	beqz	a7,ffffffffc02014d2 <vprintfmt+0x2fc>
ffffffffc0201354:	000a3603          	ld	a2,0(s4)
ffffffffc0201358:	46a9                	li	a3,10
ffffffffc020135a:	8a2e                	mv	s4,a1
ffffffffc020135c:	bfc1                	j	ffffffffc020132c <vprintfmt+0x156>
ffffffffc020135e:	00144603          	lbu	a2,1(s0)
ffffffffc0201362:	4c85                	li	s9,1
ffffffffc0201364:	846a                	mv	s0,s10
ffffffffc0201366:	bdf1                	j	ffffffffc0201242 <vprintfmt+0x6c>
ffffffffc0201368:	85a6                	mv	a1,s1
ffffffffc020136a:	02500513          	li	a0,37
ffffffffc020136e:	9902                	jalr	s2
ffffffffc0201370:	b545                	j	ffffffffc0201210 <vprintfmt+0x3a>
ffffffffc0201372:	00144603          	lbu	a2,1(s0)
ffffffffc0201376:	2885                	addiw	a7,a7,1
ffffffffc0201378:	846a                	mv	s0,s10
ffffffffc020137a:	b5e1                	j	ffffffffc0201242 <vprintfmt+0x6c>
ffffffffc020137c:	4705                	li	a4,1
ffffffffc020137e:	008a0593          	addi	a1,s4,8
ffffffffc0201382:	01174463          	blt	a4,a7,ffffffffc020138a <vprintfmt+0x1b4>
ffffffffc0201386:	14088163          	beqz	a7,ffffffffc02014c8 <vprintfmt+0x2f2>
ffffffffc020138a:	000a3603          	ld	a2,0(s4)
ffffffffc020138e:	46a1                	li	a3,8
ffffffffc0201390:	8a2e                	mv	s4,a1
ffffffffc0201392:	bf69                	j	ffffffffc020132c <vprintfmt+0x156>
ffffffffc0201394:	03000513          	li	a0,48
ffffffffc0201398:	85a6                	mv	a1,s1
ffffffffc020139a:	e03e                	sd	a5,0(sp)
ffffffffc020139c:	9902                	jalr	s2
ffffffffc020139e:	85a6                	mv	a1,s1
ffffffffc02013a0:	07800513          	li	a0,120
ffffffffc02013a4:	9902                	jalr	s2
ffffffffc02013a6:	0a21                	addi	s4,s4,8
ffffffffc02013a8:	6782                	ld	a5,0(sp)
ffffffffc02013aa:	46c1                	li	a3,16
ffffffffc02013ac:	ff8a3603          	ld	a2,-8(s4)
ffffffffc02013b0:	bfb5                	j	ffffffffc020132c <vprintfmt+0x156>
ffffffffc02013b2:	000a3403          	ld	s0,0(s4)
ffffffffc02013b6:	008a0713          	addi	a4,s4,8
ffffffffc02013ba:	e03a                	sd	a4,0(sp)
ffffffffc02013bc:	14040263          	beqz	s0,ffffffffc0201500 <vprintfmt+0x32a>
ffffffffc02013c0:	0fb05763          	blez	s11,ffffffffc02014ae <vprintfmt+0x2d8>
ffffffffc02013c4:	02d00693          	li	a3,45
ffffffffc02013c8:	0cd79163          	bne	a5,a3,ffffffffc020148a <vprintfmt+0x2b4>
ffffffffc02013cc:	00044783          	lbu	a5,0(s0)
ffffffffc02013d0:	0007851b          	sext.w	a0,a5
ffffffffc02013d4:	cf85                	beqz	a5,ffffffffc020140c <vprintfmt+0x236>
ffffffffc02013d6:	00140a13          	addi	s4,s0,1
ffffffffc02013da:	05e00413          	li	s0,94
ffffffffc02013de:	000c4563          	bltz	s8,ffffffffc02013e8 <vprintfmt+0x212>
ffffffffc02013e2:	3c7d                	addiw	s8,s8,-1
ffffffffc02013e4:	036c0263          	beq	s8,s6,ffffffffc0201408 <vprintfmt+0x232>
ffffffffc02013e8:	85a6                	mv	a1,s1
ffffffffc02013ea:	0e0c8e63          	beqz	s9,ffffffffc02014e6 <vprintfmt+0x310>
ffffffffc02013ee:	3781                	addiw	a5,a5,-32
ffffffffc02013f0:	0ef47b63          	bgeu	s0,a5,ffffffffc02014e6 <vprintfmt+0x310>
ffffffffc02013f4:	03f00513          	li	a0,63
ffffffffc02013f8:	9902                	jalr	s2
ffffffffc02013fa:	000a4783          	lbu	a5,0(s4)
ffffffffc02013fe:	3dfd                	addiw	s11,s11,-1
ffffffffc0201400:	0a05                	addi	s4,s4,1
ffffffffc0201402:	0007851b          	sext.w	a0,a5
ffffffffc0201406:	ffe1                	bnez	a5,ffffffffc02013de <vprintfmt+0x208>
ffffffffc0201408:	01b05963          	blez	s11,ffffffffc020141a <vprintfmt+0x244>
ffffffffc020140c:	3dfd                	addiw	s11,s11,-1
ffffffffc020140e:	85a6                	mv	a1,s1
ffffffffc0201410:	02000513          	li	a0,32
ffffffffc0201414:	9902                	jalr	s2
ffffffffc0201416:	fe0d9be3          	bnez	s11,ffffffffc020140c <vprintfmt+0x236>
ffffffffc020141a:	6a02                	ld	s4,0(sp)
ffffffffc020141c:	bbd5                	j	ffffffffc0201210 <vprintfmt+0x3a>
ffffffffc020141e:	4705                	li	a4,1
ffffffffc0201420:	008a0c93          	addi	s9,s4,8
ffffffffc0201424:	01174463          	blt	a4,a7,ffffffffc020142c <vprintfmt+0x256>
ffffffffc0201428:	08088d63          	beqz	a7,ffffffffc02014c2 <vprintfmt+0x2ec>
ffffffffc020142c:	000a3403          	ld	s0,0(s4)
ffffffffc0201430:	0a044d63          	bltz	s0,ffffffffc02014ea <vprintfmt+0x314>
ffffffffc0201434:	8622                	mv	a2,s0
ffffffffc0201436:	8a66                	mv	s4,s9
ffffffffc0201438:	46a9                	li	a3,10
ffffffffc020143a:	bdcd                	j	ffffffffc020132c <vprintfmt+0x156>
ffffffffc020143c:	000a2783          	lw	a5,0(s4)
ffffffffc0201440:	4719                	li	a4,6
ffffffffc0201442:	0a21                	addi	s4,s4,8
ffffffffc0201444:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201448:	8fb5                	xor	a5,a5,a3
ffffffffc020144a:	40d786bb          	subw	a3,a5,a3
ffffffffc020144e:	02d74163          	blt	a4,a3,ffffffffc0201470 <vprintfmt+0x29a>
ffffffffc0201452:	00369793          	slli	a5,a3,0x3
ffffffffc0201456:	97de                	add	a5,a5,s7
ffffffffc0201458:	639c                	ld	a5,0(a5)
ffffffffc020145a:	cb99                	beqz	a5,ffffffffc0201470 <vprintfmt+0x29a>
ffffffffc020145c:	86be                	mv	a3,a5
ffffffffc020145e:	00001617          	auipc	a2,0x1
ffffffffc0201462:	d9260613          	addi	a2,a2,-622 # ffffffffc02021f0 <buddy_pmm_manager+0x180>
ffffffffc0201466:	85a6                	mv	a1,s1
ffffffffc0201468:	854a                	mv	a0,s2
ffffffffc020146a:	0ce000ef          	jal	ra,ffffffffc0201538 <printfmt>
ffffffffc020146e:	b34d                	j	ffffffffc0201210 <vprintfmt+0x3a>
ffffffffc0201470:	00001617          	auipc	a2,0x1
ffffffffc0201474:	d7060613          	addi	a2,a2,-656 # ffffffffc02021e0 <buddy_pmm_manager+0x170>
ffffffffc0201478:	85a6                	mv	a1,s1
ffffffffc020147a:	854a                	mv	a0,s2
ffffffffc020147c:	0bc000ef          	jal	ra,ffffffffc0201538 <printfmt>
ffffffffc0201480:	bb41                	j	ffffffffc0201210 <vprintfmt+0x3a>
ffffffffc0201482:	00001417          	auipc	s0,0x1
ffffffffc0201486:	d5640413          	addi	s0,s0,-682 # ffffffffc02021d8 <buddy_pmm_manager+0x168>
ffffffffc020148a:	85e2                	mv	a1,s8
ffffffffc020148c:	8522                	mv	a0,s0
ffffffffc020148e:	e43e                	sd	a5,8(sp)
ffffffffc0201490:	0fc000ef          	jal	ra,ffffffffc020158c <strnlen>
ffffffffc0201494:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201498:	01b05b63          	blez	s11,ffffffffc02014ae <vprintfmt+0x2d8>
ffffffffc020149c:	67a2                	ld	a5,8(sp)
ffffffffc020149e:	00078a1b          	sext.w	s4,a5
ffffffffc02014a2:	3dfd                	addiw	s11,s11,-1
ffffffffc02014a4:	85a6                	mv	a1,s1
ffffffffc02014a6:	8552                	mv	a0,s4
ffffffffc02014a8:	9902                	jalr	s2
ffffffffc02014aa:	fe0d9ce3          	bnez	s11,ffffffffc02014a2 <vprintfmt+0x2cc>
ffffffffc02014ae:	00044783          	lbu	a5,0(s0)
ffffffffc02014b2:	00140a13          	addi	s4,s0,1
ffffffffc02014b6:	0007851b          	sext.w	a0,a5
ffffffffc02014ba:	d3a5                	beqz	a5,ffffffffc020141a <vprintfmt+0x244>
ffffffffc02014bc:	05e00413          	li	s0,94
ffffffffc02014c0:	bf39                	j	ffffffffc02013de <vprintfmt+0x208>
ffffffffc02014c2:	000a2403          	lw	s0,0(s4)
ffffffffc02014c6:	b7ad                	j	ffffffffc0201430 <vprintfmt+0x25a>
ffffffffc02014c8:	000a6603          	lwu	a2,0(s4)
ffffffffc02014cc:	46a1                	li	a3,8
ffffffffc02014ce:	8a2e                	mv	s4,a1
ffffffffc02014d0:	bdb1                	j	ffffffffc020132c <vprintfmt+0x156>
ffffffffc02014d2:	000a6603          	lwu	a2,0(s4)
ffffffffc02014d6:	46a9                	li	a3,10
ffffffffc02014d8:	8a2e                	mv	s4,a1
ffffffffc02014da:	bd89                	j	ffffffffc020132c <vprintfmt+0x156>
ffffffffc02014dc:	000a6603          	lwu	a2,0(s4)
ffffffffc02014e0:	46c1                	li	a3,16
ffffffffc02014e2:	8a2e                	mv	s4,a1
ffffffffc02014e4:	b5a1                	j	ffffffffc020132c <vprintfmt+0x156>
ffffffffc02014e6:	9902                	jalr	s2
ffffffffc02014e8:	bf09                	j	ffffffffc02013fa <vprintfmt+0x224>
ffffffffc02014ea:	85a6                	mv	a1,s1
ffffffffc02014ec:	02d00513          	li	a0,45
ffffffffc02014f0:	e03e                	sd	a5,0(sp)
ffffffffc02014f2:	9902                	jalr	s2
ffffffffc02014f4:	6782                	ld	a5,0(sp)
ffffffffc02014f6:	8a66                	mv	s4,s9
ffffffffc02014f8:	40800633          	neg	a2,s0
ffffffffc02014fc:	46a9                	li	a3,10
ffffffffc02014fe:	b53d                	j	ffffffffc020132c <vprintfmt+0x156>
ffffffffc0201500:	03b05163          	blez	s11,ffffffffc0201522 <vprintfmt+0x34c>
ffffffffc0201504:	02d00693          	li	a3,45
ffffffffc0201508:	f6d79de3          	bne	a5,a3,ffffffffc0201482 <vprintfmt+0x2ac>
ffffffffc020150c:	00001417          	auipc	s0,0x1
ffffffffc0201510:	ccc40413          	addi	s0,s0,-820 # ffffffffc02021d8 <buddy_pmm_manager+0x168>
ffffffffc0201514:	02800793          	li	a5,40
ffffffffc0201518:	02800513          	li	a0,40
ffffffffc020151c:	00140a13          	addi	s4,s0,1
ffffffffc0201520:	bd6d                	j	ffffffffc02013da <vprintfmt+0x204>
ffffffffc0201522:	00001a17          	auipc	s4,0x1
ffffffffc0201526:	cb7a0a13          	addi	s4,s4,-841 # ffffffffc02021d9 <buddy_pmm_manager+0x169>
ffffffffc020152a:	02800513          	li	a0,40
ffffffffc020152e:	02800793          	li	a5,40
ffffffffc0201532:	05e00413          	li	s0,94
ffffffffc0201536:	b565                	j	ffffffffc02013de <vprintfmt+0x208>

ffffffffc0201538 <printfmt>:
ffffffffc0201538:	715d                	addi	sp,sp,-80
ffffffffc020153a:	02810313          	addi	t1,sp,40
ffffffffc020153e:	f436                	sd	a3,40(sp)
ffffffffc0201540:	869a                	mv	a3,t1
ffffffffc0201542:	ec06                	sd	ra,24(sp)
ffffffffc0201544:	f83a                	sd	a4,48(sp)
ffffffffc0201546:	fc3e                	sd	a5,56(sp)
ffffffffc0201548:	e0c2                	sd	a6,64(sp)
ffffffffc020154a:	e4c6                	sd	a7,72(sp)
ffffffffc020154c:	e41a                	sd	t1,8(sp)
ffffffffc020154e:	c89ff0ef          	jal	ra,ffffffffc02011d6 <vprintfmt>
ffffffffc0201552:	60e2                	ld	ra,24(sp)
ffffffffc0201554:	6161                	addi	sp,sp,80
ffffffffc0201556:	8082                	ret

ffffffffc0201558 <sbi_console_putchar>:
ffffffffc0201558:	4781                	li	a5,0
ffffffffc020155a:	00005717          	auipc	a4,0x5
ffffffffc020155e:	ab673703          	ld	a4,-1354(a4) # ffffffffc0206010 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201562:	88ba                	mv	a7,a4
ffffffffc0201564:	852a                	mv	a0,a0
ffffffffc0201566:	85be                	mv	a1,a5
ffffffffc0201568:	863e                	mv	a2,a5
ffffffffc020156a:	00000073          	ecall
ffffffffc020156e:	87aa                	mv	a5,a0
ffffffffc0201570:	8082                	ret

ffffffffc0201572 <strlen>:
ffffffffc0201572:	00054783          	lbu	a5,0(a0)
ffffffffc0201576:	872a                	mv	a4,a0
ffffffffc0201578:	4501                	li	a0,0
ffffffffc020157a:	cb81                	beqz	a5,ffffffffc020158a <strlen+0x18>
ffffffffc020157c:	0505                	addi	a0,a0,1
ffffffffc020157e:	00a707b3          	add	a5,a4,a0
ffffffffc0201582:	0007c783          	lbu	a5,0(a5)
ffffffffc0201586:	fbfd                	bnez	a5,ffffffffc020157c <strlen+0xa>
ffffffffc0201588:	8082                	ret
ffffffffc020158a:	8082                	ret

ffffffffc020158c <strnlen>:
ffffffffc020158c:	4781                	li	a5,0
ffffffffc020158e:	e589                	bnez	a1,ffffffffc0201598 <strnlen+0xc>
ffffffffc0201590:	a811                	j	ffffffffc02015a4 <strnlen+0x18>
ffffffffc0201592:	0785                	addi	a5,a5,1
ffffffffc0201594:	00f58863          	beq	a1,a5,ffffffffc02015a4 <strnlen+0x18>
ffffffffc0201598:	00f50733          	add	a4,a0,a5
ffffffffc020159c:	00074703          	lbu	a4,0(a4)
ffffffffc02015a0:	fb6d                	bnez	a4,ffffffffc0201592 <strnlen+0x6>
ffffffffc02015a2:	85be                	mv	a1,a5
ffffffffc02015a4:	852e                	mv	a0,a1
ffffffffc02015a6:	8082                	ret

ffffffffc02015a8 <strcmp>:
ffffffffc02015a8:	00054783          	lbu	a5,0(a0)
ffffffffc02015ac:	0005c703          	lbu	a4,0(a1)
ffffffffc02015b0:	cb89                	beqz	a5,ffffffffc02015c2 <strcmp+0x1a>
ffffffffc02015b2:	0505                	addi	a0,a0,1
ffffffffc02015b4:	0585                	addi	a1,a1,1
ffffffffc02015b6:	fee789e3          	beq	a5,a4,ffffffffc02015a8 <strcmp>
ffffffffc02015ba:	0007851b          	sext.w	a0,a5
ffffffffc02015be:	9d19                	subw	a0,a0,a4
ffffffffc02015c0:	8082                	ret
ffffffffc02015c2:	4501                	li	a0,0
ffffffffc02015c4:	bfed                	j	ffffffffc02015be <strcmp+0x16>

ffffffffc02015c6 <strncmp>:
ffffffffc02015c6:	c20d                	beqz	a2,ffffffffc02015e8 <strncmp+0x22>
ffffffffc02015c8:	962e                	add	a2,a2,a1
ffffffffc02015ca:	a031                	j	ffffffffc02015d6 <strncmp+0x10>
ffffffffc02015cc:	0505                	addi	a0,a0,1
ffffffffc02015ce:	00e79a63          	bne	a5,a4,ffffffffc02015e2 <strncmp+0x1c>
ffffffffc02015d2:	00b60b63          	beq	a2,a1,ffffffffc02015e8 <strncmp+0x22>
ffffffffc02015d6:	00054783          	lbu	a5,0(a0)
ffffffffc02015da:	0585                	addi	a1,a1,1
ffffffffc02015dc:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02015e0:	f7f5                	bnez	a5,ffffffffc02015cc <strncmp+0x6>
ffffffffc02015e2:	40e7853b          	subw	a0,a5,a4
ffffffffc02015e6:	8082                	ret
ffffffffc02015e8:	4501                	li	a0,0
ffffffffc02015ea:	8082                	ret

ffffffffc02015ec <memset>:
ffffffffc02015ec:	ca01                	beqz	a2,ffffffffc02015fc <memset+0x10>
ffffffffc02015ee:	962a                	add	a2,a2,a0
ffffffffc02015f0:	87aa                	mv	a5,a0
ffffffffc02015f2:	0785                	addi	a5,a5,1
ffffffffc02015f4:	feb78fa3          	sb	a1,-1(a5)
ffffffffc02015f8:	fec79de3          	bne	a5,a2,ffffffffc02015f2 <memset+0x6>
ffffffffc02015fc:	8082                	ret
