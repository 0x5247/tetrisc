.align 0x2

.globl _start

.include "src/constants.inc"

.set GRID_STATE, 0xc8 + 0x1 + 0x14 + (0xa * 0x2)
.set RAND_NUMS, 0xff
.set KERN_TERM, 0x2c

_start:
.option push
.option norelax
	la gp, __global_pointer$
.option pop

	c.li a0, STDOUT
	la a1, splash
	li a2, 0x4b
	li a7, SYS_WRITE
	ecall

	c.li a0, STDIN
	addi a1, sp, -0x1
	c.li a2, 0x1
	li a7, SYS_READ
	ecall
	
	li s6, 0x30

	blez a0, 0f
	lb s6, (a1)

0:
	c.li a0, STDOUT
	la a1, game_init
	li a2, 0x363
	li a7, SYS_WRITE
	ecall

	li s4, 0x80
	#c.slli s4, 0x2 /////// /////// ///////

	c.li t1, 0x0
	c.li s7, 0x0
	c.li s8, 0x3

	addi sp, sp, -GRID_STATE

	addi s9, sp, 0xb

	c.li a0, 0x1

	sb a0, (0x00 * 0xb) - 0x1(s9)
	sb a0, (0x01 * 0xb) - 0x1(s9)
	sb a0, (0x02 * 0xb) - 0x1(s9)
	sb a0, (0x03 * 0xb) - 0x1(s9)
	sb a0, (0x04 * 0xb) - 0x1(s9)
	sb a0, (0x05 * 0xb) - 0x1(s9)
	sb a0, (0x06 * 0xb) - 0x1(s9)
	sb a0, (0x07 * 0xb) - 0x1(s9)
	sb a0, (0x08 * 0xb) - 0x1(s9)
	sb a0, (0x09 * 0xb) - 0x1(s9)
	sb a0, (0x0a * 0xb) - 0x1(s9)
	sb a0, (0x0b * 0xb) - 0x1(s9)
	sb a0, (0x0c * 0xb) - 0x1(s9)
	sb a0, (0x0d * 0xb) - 0x1(s9)
	sb a0, (0x0e * 0xb) - 0x1(s9)
	sb a0, (0x0f * 0xb) - 0x1(s9)
	sb a0, (0x10 * 0xb) - 0x1(s9)
	sb a0, (0x11 * 0xb) - 0x1(s9)
	sb a0, (0x12 * 0xb) - 0x1(s9)
	sb a0, (0x13 * 0xb) - 0x1(s9)
	sb a0, (0x14 * 0xb) - 0x1(s9)
	sb a0, (0x14 * 0xb) + 0x0(s9)
	sb a0, (0x14 * 0xb) + 0x1(s9)
	sb a0, (0x14 * 0xb) + 0x2(s9)
	sb a0, (0x14 * 0xb) + 0x3(s9)
	sb a0, (0x14 * 0xb) + 0x4(s9)
	sb a0, (0x14 * 0xb) + 0x5(s9)
	sb a0, (0x14 * 0xb) + 0x6(s9)
	sb a0, (0x14 * 0xb) + 0x7(s9)
	sb a0, (0x14 * 0xb) + 0x8(s9)
	sb a0, (0x14 * 0xb) + 0x9(s9)

	la s10, blocks_grid_offset

	la s11, block_string

	la t2, fixed_block_string

	addi sp, sp, -RAND_NUMS

	mv t3, sp
	c.li t4, 0x0

	la t5, delay_duration
	la t6, grid_string

	addi sp, sp, -KERN_TERM

	li a0, STDIN
	li a1, TCGETS
	mv a2, sp
	li a7, SYS_IOCTL
	ecall

	lw a0, 0xc(sp)

	sw a0, 0x24(sp) # lflag_swp

	li a1, ICANON
	ori a1, a1, ECHO
	c.not a1
	c.and a0, a1

	sw a0, 0xc(sp)

	li a0, STDIN
	li a1, TCSETSF
	mv a2, sp
	li a7, SYS_IOCTL
	ecall

	li a0, STDIN
	li a1, F_GETFL
	li a7, SYS_FCNTL64
	ecall

	sw a0, 0x28(sp) # fflags

	li a1, O_NONBLOCK
	or a0, a0, a1

	mv a2, a0
	li a0, STDIN
	li a1, F_SETFL
	li a7, SYS_FCNTL64
	ecall

	jal print_grid

	mv a0, t3
	li a1, RAND_NUMS
	c.li a2, 0x0
	li a7, SYS_GETRANDOM
	ecall

	li t4, RAND_NUMS - 0x1

	add a1, t3, t4
	lbu a0, (a1)

	andi t6, a0, 0x3 # 0b11
	c.srli a0, 0x6
	add t6, t6, a0

loop_init:
	c.li s0, 0x0
	c.li s1, 0x4
	c.li s2, 0x1
	c.li s5, 0x0

	bnez t4, 0f

	mv a0, t3
	li a1, RAND_NUMS
	c.li a2, 0x0
	li a7, SYS_GETRANDOM
	ecall

	li t4, RAND_NUMS

0:
	mv s3, t6

	c.addi t4, -0x1

	add a1, t3, t4
	lbu a0, (a1)

	li a1, 0x25
	mul a1, a0, a1
	c.srli a1, 0x8
	sub a2, a0, a1
	c.slli a2, 0x18
	c.srli a2, 0x19
	c.add a1, a2
	c.srli a1, 0x2
	slli a2, a1, 0x3
	c.add a0, a1
	//sub t6, a0, a2 #?
	c.sub a0, a2
	andi t6, a0, 0xff

	#c.li s3, 0x1 /////// /////// ///////

	jal prep_block_string_init

	la a6, xdigits

	addi a0, s11, (0x4 * 0xa * 0x2) + 0xf
	mv a1, s7

0:
	andi a3, a1, 0xf
	add a3, a6, a3
	c.addi a0, -0x1

	lb a3, (a3)
	sb a3, (a0)

	c.srli a1, 0x4
	bnez a1, 0b

	c.li a0, STDOUT
	addi a1, s11, 0x4 * 0xa
	li a2, (0x4 * 0xa) + 0xf
	li a7, SYS_WRITE

	andi a3, s8, 0x1
	bnez a3, 0f

	addi a2, a1, (0x4 * 0xa) + 0xf + 0x26
	slli a4, t6, 0x3
	add a3, t2, a4

	lw a4, 0x4(a3)
	lw a3, (a3)

1:
	lb a5, (a3)
	sb a5, (a2)

	c.addi a2, 0x1
	c.addi a3, 0x1
	c.addi a4, -0x1
	bgtz a4, 1b

	c.sub a2, a1

0:
	andi a3, s8, 0x3 << 0x3
	beqz a3, 0f

	addi a1, a1, -0x4 * 0xa
	addi a2, a2, 0x4 * 0xa

	lhu a4, (0x4 * 0xa) + (0x0 * 0xa) + 0x2(s11)
	lhu a5, (0x4 * 0xa) + (0x0 * 0xa) + 0x5(s11)

	sh a4, (0x0 * 0xa) + 0x2(s11)
	sh a5, (0x0 * 0xa) + 0x5(s11)

	sh a4, (0x1 * 0xa) + 0x2(s11)
	sh a5, (0x1 * 0xa) + 0x5(s11)

	sh a4, (0x2 * 0xa) + 0x2(s11)
	sh a5, (0x2 * 0xa) + 0x5(s11)

	sh a4, (0x3 * 0xa) + 0x2(s11)
	sh a5, (0x3 * 0xa) + 0x5(s11)

	mv a4, a1
	mv a5, t1

1:
	andi a3, a5, 0xf
	add a3, a6, a3
	c.addi a4, -0x1

	lb a3, (a3)
	sb a3, (a4)

	c.srli a5, 0x4
	bnez a5, 1b

	c.addi a1, -0xf
	c.addi a2, 0xf

	andi a3, s8, 0x1 << 0x4
	beqz a3, 0f

	c.addi a1, -0x8
	c.addi a2, 0x8

	beqz a3, 0f

0:
	ecall

	andi s8, s8, 0x3
	slli a0, s8, 0x2
	c.andi a0, 0x1 << 0x2
	or s8, s8, a0

	jal can_fit_block
	bnez a0, loop_end

loop_start:
	c.li a0, 0x0
	c.li a1, 0x0
	mv a2, t5
	c.li a3, 0x0
	li a7, SYS_CNT64
	ecall

	c.addi s5, 0x1
	beq s4, s5, desn

	c.li a0, STDIN
	addi a1, sp, -0x1
	c.li a2, 0x1
	li a7, SYS_READ
	ecall
	
	blez a0, loop_start

	lb a1, (a1)

	li a0, '7'
	beq a1, a0, left

	li a0, '9'
	beq a1, a0, right

	li a0, '8'
	beq a1, a0, turn

	li a0, '5'
	beq a1, a0, drop

	li a0, ' '
	beq a1, a0, drop

	li a0, '6'
	beq a1, a0, down

	li a0, '1'
	beq a1, a0, toggle_view_next

	li a0, '0'
	beq a1, a0, instr

	c.li a0, '\n'
	beq a1, a0, loop_end // remove this

	j loop_start

left:
	c.addi s1, -0x1

	jal can_fit_block
	bnez a0, 0f

	jal prep_block_string

	c.li a0, STDOUT
	mv a1, s11
	li a2, (0x4 * 0xa) * 0x2
	li a7, SYS_WRITE
	ecall

	j loop_start

0:
	c.addi s1, 0x1

	j loop_start

right:
	c.addi s1, 0x1

	jal can_fit_block
	bnez a0, 0f

	jal prep_block_string

	c.li a0, STDOUT
	mv a1, s11
	li a2, (0x4 * 0xa) * 2
	li a7, SYS_WRITE
	ecall

	j loop_start

0:
	c.addi s1, -0x1

	j loop_start

turn:
	c.addi s2, 0x1
	andi s2, s2, 0x3

	jal can_fit_block
	bnez a0, 0f

	jal prep_block_string

	c.li a0, STDOUT
	mv a1, s11
	li a2, (0x4 * 0xa) * 0x2
	li a7, SYS_WRITE
	ecall

	j loop_start

0:
	c.addi s2, 0x3
	andi s2, s2, 0x3

	j loop_start

desn:
	c.li s5, 0x0

down:
	c.addi s0, 0x1

	jal can_fit_block
	bnez a0, 0f

	jal prep_block_string

	c.li a0, STDOUT
	mv a1, s11
	li a2, (0x4 * 0xa) * 2
	li a7, SYS_WRITE
	ecall

	j loop_start

drop:
	c.li s5, 0x0

	slli a0, s3, 0x5
	add a2, a0, s10
	slli a0, s2, 0x3
	c.add a2, a0

	lb a1, (0x3 * 0x2) + 0x0(a2)
	c.add a1, s0
	c.li a0, 0x14
	c.sub a0, a1

	add s7, s7, a0

1:
	c.addi s0, 0x1

	jal can_fit_block
	beqz a0, 1b

	c.addi s0, -0x1

	jal prep_block_string

	c.li a0, STDOUT
	mv a1, s11
	li a2, (0x4 * 0xa) * 0x2
	li a7, SYS_WRITE
	ecall

	c.j 1f

0:
	c.addi s0, -0x1

	slli a0, s3, 0x5
	add a2, a0, s10
	slli a0, s2, 0x3
	c.add a2, a0

	lb a1, (0x3 * 0x2) + 0x0(a2)
	c.add a1, s0
	c.li a0, 0x14
	c.sub a0, a1

	add s7, s7, a0

1:
	andi a0, s8, 0x4
	srli a1, a0, 0x2
	c.add a0, a1

	add s7, s7, a0

	slli a0, s3, 0x5
	add a2, a0, s10
	slli a0, s2, 0x3
	c.add a2, a0

	c.li a3, 0x1

	lb a1, (0x0 * 0x2) + 0x0(a2)
	c.add a1, s0
	c.li a0, 0xb
	mul a0, a0, a1
	lb a1, (0x0 * 0x2) + 0x1(a2)
	c.add a1, s1
	c.add a0, a1
	add a0, a0, s9
	sb a3, (a0)

	lb a1, (0x1 * 0x2) + 0x0(a2)
	c.add a1, s0
	c.li a0, 0xb
	mul a0, a0, a1
	lb a1, (0x1 * 0x2) + 0x1(a2)
	c.add a1, s1
	c.add a0, a1
	add a0, a0, s9
	sb a3, (a0)

	lb a1, (0x2 * 0x2) + 0x0(a2)
	c.add a1, s0
	c.li a0, 0xb
	mul a0, a0, a1
	lb a1, (0x2 * 0x2) + 0x1(a2)
	c.add a1, s1
	c.add a0, a1
	add a0, a0, s9
	sb a3, (a0)

	lb a1, (0x3 * 0x2) + 0x0(a2)
	c.add a1, s0
	c.li a0, 0xb
	mul a0, a0, a1
	add a4, a0, s9
	lb a1, (0x3 * 0x2) + 0x1(a2)
	c.add a1, s1
	c.add a0, a1
	add a0, a0, s9
	sb a3, (a0)

	li a3, 0x2020303 # filled line

	c.li a0, 0x0
	c.li a5, 0x0

	lw a1, -(0x0 * 0xb) + 0x0(a4)
	lw a2, -(0x0 * 0xb) + 0x4(a4)
	c.add a1, a2
	lhu a2, -(0x0 * 0xb) + 0x8(a4)
	c.add a1, a2

	c.xor a1, a3
	seqz a1, a1

	c.add a5, a1

	c.or a0, a1

	lw a1, -(0x1 * 0xb) + 0x0(a4)
	lw a2, -(0x1 * 0xb) + 0x4(a4)
	c.add a1, a2
	lhu a2, -(0x1 * 0xb) + 0x8(a4)
	c.add a1, a2

	c.xor a1, a3
	seqz a1, a1

	c.add a5, a1

	c.slli a1, 0x1
	c.or a0, a1

	lw a1, -(0x2 * 0xb) + 0x0(a4)
	lw a2, -(0x2 * 0xb) + 0x4(a4)
	c.add a1, a2
	lhu a2, -(0x2 * 0xb) + 0x8(a4)
	c.add a1, a2

	c.xor a1, a3
	seqz a1, a1

	c.add a5, a1

	c.slli a1, 0x2
	c.or a0, a1

	lw a1, -(0x3 * 0xb) + 0x0(a4)
	lw a2, -(0x3 * 0xb) + 0x4(a4)
	c.add a1, a2
	lhu a2, -(0x3 * 0xb) + 0x8(a4)
	c.add a1, a2

	c.xor a1, a3
	seqz a1, a1

	c.add a5, a1

	c.slli a1, 0x3
	c.or a0, a1

	beqz a0, loop_init

	add t1, t1, a5

	sll a5, a5, a5
	add s7, s7, a5

	ori s8, s8, 0x8

0:
	andi a1, a0, 0x1
	bnez a1, 0f

	c.srli a0, 0x1
	c.addi a4, -0xb
	c.j 0b

0:
	mv a3, s9

0:
	lw a1, 0x0(a3)
	lw a2, 0x4(a3)
	c.add a1, a2
	lhu a2, 0x8(a3)
	c.add a1, a2

	bnez a1, 0f

	c.addi a3, 0xb
	c.j 0b

0:
	andi a1, a0, 0x1
	beqz a1, 2f

	c.mv a2, a4

1:
	lw a1, -0xb + 0x0(a2)
	sw a1, 0x0(a2)
	lw a1, -0xb + 0x4(a2)
	sw a1, 0x4(a2)
	lhu a1, -0xb + 0x8(a2)
	sh a1, 0x8(a2)

	c.addi a2, -0xb
	bge a2, a3, 1b

	c.srli a0, 0x1
	bnez a0, 0b

2:
	c.srli a0, 0x1
	c.addi a4, -0xb
	bnez a0, 0b

	jal print_grid

	j loop_init

3:
	li t0, 0x3231
	li a7, 0x3130
	jal place_cur

	mv t0, a0
	jal print_reg

	j loop_init

toggle_view_next:
	andi s8, s8, 0x3
	xori s8, s8, 0x1

	c.li a0, STDOUT
	addi a1, s11, (0x4 * 0xa * 0x2) + 0xf
	li a7, SYS_WRITE

	andi a6, s8, 0x1
	beqz a6, 0f

	c.li a2, 0x1e
	ecall

	j loop_start

0:
	slli a4, t6, 0x3
	add a3, t2, a4

	addi a1, a1, 0x1e
	addi a2, a1, 0x8

	lw a4, 0x4(a3)
	lw a3, (a3)

0:
	lb a6, (a3)
	sb a6, (a2)

	c.addi a2, 0x1
	c.addi a3, 0x1
	c.addi a4, -0x1
	bgtz a4, 0b

	c.sub a2, a1

	ecall

	j loop_start

instr:
	la a1, instructions
	li a2, 0x8b

	andi a0, s8, 0x2
	beqz a0, 0f

	c.add a1, a2

0:
	c.li a0, STDOUT
	li a7, SYS_WRITE
	ecall

	xori s8, s8, 0x2

	j loop_start

loop_end:
	c.li a0, STDIN
	li a1, F_SETFL
	lw a2, 0x28(sp)
	li a7, SYS_FCNTL64
	ecall

	lw a0, 0x24(sp)
	sw a0, 0xc(sp)

	c.li a0, STDIN
	li a1, TCSETSF
	mv a2, sp
	li a7, SYS_IOCTL
	ecall

	addi sp, sp, GRID_STATE + RAND_NUMS + KERN_TERM

	addi a1, sp, -0xe

	c.li a0, ESC
	sb a0, 0x0(a1)
	li a0, '['
	sb a0, 0x1(a1)
	li a0, ';'
	sb a0, 0x4(a1)
	li a0, 'H'
	sb a0, 0x7(a1)

	li a0, 0x3532
	sh a0, 0x2(a1)
	li a0, 0x3130
	sh a0, 0x5(a1)

	c.li a0, ESC
	sb a0, 0x8(a1)
	li a0, '['
	sb a0, 0x9(a1)
	li a0, '?'
	sb a0, 0xa(a1)
	li a0, '2'
	sb a0, 0xb(a1)
	li a0, '5'
	sb a0, 0xc(a1)
	li a0, 'h'
	sb a0, 0xd(a1)

	c.li a0, STDOUT
	li a2, 0xe
	li a7, SYS_WRITE
	ecall

	c.li a0, 0x0

exit:
	li a7, SYS_EXIT
	ecall
	c.j .

can_fit_block:
	slli a1, s3, 0x5
	add a3, a1, s10
	slli a1, s2, 0x3
	c.add a3, a1

	c.li a0, 0x0

	lb a2, (0x0 * 0x2) + 0x0(a3)
	add a2, a2, s0

	sltz a1, a2
	c.add a0, a1

	c.li a1, 0xb
	mul a1, a1, a2
	lb a2, (0x0 * 0x2) + 0x1(a3)
	add a2, a2, s1
	c.add a1, a2
	add a1, a1, s9
	lbu a1, (a1)
	c.add a0, a1

	lb a2, (0x1 * 0x2) + 0x0(a3)
	add a2, a2, s0

	sltz a1, a2
	c.add a0, a1

	c.li a1, 0xb
	mul a1, a1, a2
	lb a2, (0x1 * 0x2) + 0x1(a3)
	add a2, a2, s1
	c.add a1, a2
	add a1, a1, s9
	lbu a1, (a1)
	c.add a0, a1

	lb a2, (0x2 * 0x2) + 0x0(a3)
	add a2, a2, s0

	sltz a1, a2
	c.add a0, a1

	c.li a1, 0xb
	mul a1, a1, a2
	lb a2, (0x2 * 0x2) + 0x1(a3)
	add a2, a2, s1
	c.add a1, a2
	add a1, a1, s9
	lbu a1, (a1)
	c.add a0, a1

	lb a2, (0x3 * 0x2) + 0x0(a3)
	add a2, a2, s0

	sltz a1, a2
	c.add a0, a1

	c.li a1, 0xb
	mul a1, a1, a2
	lb a2, (0x3 * 0x2) + 0x1(a3)
	add a2, a2, s1
	c.add a1, a2
	add a1, a1, s9
	lbu a1, (a1)
	c.add a0, a1

	c.jr ra

prep_block_string:
	lhu a0, (0x4 * 0xa) + (0x0 * 0xa) + 0x2(s11)
	sh a0, (0x0 * 0xa) + 0x2(s11)
	lhu a0, (0x4 * 0xa) + (0x0 * 0xa) + 0x5(s11)
	sh a0, (0x0 * 0xa) + 0x5(s11)

	lhu a0, (0x4 * 0xa) + (0x1 * 0xa) + 0x2(s11)
	sh a0, (0x1 * 0xa) + 0x2(s11)
	lhu a0, (0x4 * 0xa) + (0x1 * 0xa) + 0x5(s11)
	sh a0, (0x1 * 0xa) + 0x5(s11)

	lhu a0, (0x4 * 0xa) + (0x2 * 0xa) + 0x2(s11)
	sh a0, (0x2 * 0xa) + 0x2(s11)
	lhu a0, (0x4 * 0xa) + (0x2 * 0xa) + 0x5(s11)
	sh a0, (0x2 * 0xa) + 0x5(s11)

	lhu a0, (0x4 * 0xa) + (0x3 * 0xa) + 0x2(s11)
	sh a0, (0x3 * 0xa) + 0x2(s11)
	lhu a0, (0x4 * 0xa) + (0x3 * 0xa) + 0x5(s11)
	sh a0, (0x3 * 0xa) + 0x5(s11)

prep_block_string_init:
	slli a0, s3, 0x5
	add a1, a0, s10
	slli a0, s2, 0x3
	c.add a1, a0

	c.addi sp, -0x8

	lb a0, (0x0 * 0x2) + 0x0(a1)
	c.add a0, s0
	sb a0, (0x0 * 0x2) + 0x0(sp)
	lb a0, (0x0 * 0x2) + 0x1(a1)
	c.add a0, s1
	sb a0, (0x0 * 0x2) + 0x1(sp)

	lb a0, (0x1 * 0x2) + 0x0(a1)
	c.add a0, s0
	sb a0, (0x1 * 0x2) + 0x0(sp)
	lb a0, (0x1 * 0x2) + 0x1(a1)
	c.add a0, s1
	sb a0, (0x1 * 0x2) + 0x1(sp)

	lb a0, (0x2 * 0x2) + 0x0(a1)
	c.add a0, s0
	sb a0, (0x2 * 0x2) + 0x0(sp)
	lb a0, (0x2 * 0x2) + 0x1(a1)
	c.add a0, s1
	sb a0, (0x2 * 0x2) + 0x1(sp)

	lb a0, (0x3 * 0x2) + 0x0(a1)
	c.add a0, s0
	sb a0, (0x3 * 0x2) + 0x0(sp)
	lb a0, (0x3 * 0x2) + 0x1(a1)
	c.add a0, s1
	sb a0, (0x3 * 0x2) + 0x1(sp)

	li a4, 0xcd
	c.li a5, -0xa

	lbu a0, (0x0 * 0x2) + 0x0(sp)

	c.addi a0, 0x1
	
	mul a2, a0, a4
	c.srli a2, 0xb
	mul a3, a2, a5
	ori a2, a2, 0x30
	add a1, a0, a3
	ori a1, a1, 0x30

	sb a2, (0x4 * 0xa) + (0x0 * 0xa) + 0x2(s11)
	sb a1, (0x4 * 0xa) + (0x0 * 0xa) + 0x3(s11)

	lbu a0, (0x1 * 0x2) + 0x0(sp)

	c.addi a0, 0x1
	
	mul a2, a0, a4
	c.srli a2, 0xb
	mul a3, a2, a5
	ori a2, a2, 0x30
	add a1, a0, a3
	ori a1, a1, 0x30

	sb a2, (0x4 * 0xa) + (0x1 * 0xa) + 0x2(s11)
	sb a1, (0x4 * 0xa) + (0x1 * 0xa) + 0x3(s11)

	lbu a0, (0x2 * 0x2) + 0x0(sp)

	c.addi a0, 0x1
	
	mul a2, a0, a4
	c.srli a2, 0xb
	mul a3, a2, a5
	ori a2, a2, 0x30
	add a1, a0, a3
	ori a1, a1, 0x30

	sb a2, (0x4 * 0xa) + (0x2 * 0xa) + 0x2(s11)
	sb a1, (0x4 * 0xa) + (0x2 * 0xa) + 0x3(s11)

	lbu a0, (0x3 * 0x2) + 0x0(sp)

	c.addi a0, 0x1

	mul a2, a0, a4
	c.srli a2, 0xb
	mul a3, a2, a5
	ori a2, a2, 0x30
	add a1, a0, a3
	ori a1, a1, 0x30

	sb a2, (0x4 * 0xa) + (0x3 * 0xa) + 0x2(s11)
	sb a1, (0x4 * 0xa) + (0x3 * 0xa) + 0x3(s11)

	lbu a0, (0x0 * 0x2) + 0x1(sp)

	c.slli a0, 0x1
	c.addi a0, 0x19

	mul a2, a0, a4
	c.srli a2, 0xb
	mul a3, a2, a5
	ori a2, a2, 0x30
	add a1, a0, a3
	ori a1, a1, 0x30

	sb a2, (0x4 * 0xa) + (0x0 * 0xa) + 0x5(s11)
	sb a1, (0x4 * 0xa) + (0x0 * 0xa) + 0x6(s11)

	lbu a0, (0x1 * 0x2) + 0x1(sp)

	c.slli a0, 0x1
	c.addi a0, 0x19

	mul a2, a0, a4
	c.srli a2, 0xb
	mul a3, a2, a5
	ori a2, a2, 0x30
	add a1, a0, a3
	ori a1, a1, 0x30

	sb a2, (0x4 * 0xa) + (0x1 * 0xa) + 0x5(s11)
	sb a1, (0x4 * 0xa) + (0x1 * 0xa) + 0x6(s11)

	lbu a0, (0x2 * 0x2) + 0x1(sp)

	c.slli a0, 0x1
	c.addi a0, 0x19

	mul a2, a0, a4
	c.srli a2, 0xb
	mul a3, a2, a5
	ori a2, a2, 0x30
	add a1, a0, a3
	ori a1, a1, 0x30

	sb a2, (0x4 * 0xa) + (0x2 * 0xa) + 0x5(s11)
	sb a1, (0x4 * 0xa) + (0x2 * 0xa) + 0x6(s11)

	lbu a0, (0x3 * 0x2) + 0x1(sp)

	c.slli a0, 0x1
	c.addi a0, 0x19

	mul a2, a0, a4
	c.srli a2, 0xb
	mul a3, a2, a5
	ori a2, a2, 0x30
	add a1, a0, a3
	ori a1, a1, 0x30

	sb a2, (0x4 * 0xa) + (0x3 * 0xa) + 0x5(s11)
	sb a1, (0x4 * 0xa) + (0x3 * 0xa) + 0x6(s11)

	c.addi sp, 0x8

	c.jr ra

print_grid:
	addi sp, sp, -0x20b

	mv a0, sp
	
	c.li a1, ESC
	sb a1, (a0)
	c.addi a0, 0x1

	li a1, '['
	sb a1, (a0)
	c.addi a0, 0x1

	li a1, 'H'
	sb a1, (a0)
	c.addi a0, 0x1

	mv a2, s9

	c.li a3, 0x14

0:
	c.li a4, 0xa

	c.li a1, ESC
	sb a1, (a0)
	c.addi a0, 0x1

	li a1, '['
	sb a1, (a0)
	c.addi a0, 0x1

	li a1, '2'
	sb a1, (a0)
	c.addi a0, 0x1

	li a1, '4'
	sb a1, (a0)
	c.addi a0, 0x1

	li a1, 'C'
	sb a1, (a0)
	c.addi a0, 0x1

1:
	lb a1, (a2)
	c.addi a2, 0x1

	la a5, dot

	#snez a1, a1
	c.slli a1, 0x1

	c.add a5, a1

	lhu a1, (a5)
	sh a1, (a0)
	c.addi a0, 0x2

	c.addi a4, -0x1
	bnez a4, 1b

	c.li a1, '\n'
	sb a1, (a0)
	c.addi a0, 0x1

	c.addi a2, 0x1
	c.addi a3, -0x1
	bnez a3, 0b

	c.li a0, STDOUT
	mv a1, sp
	li a2, 0x20b
	li a7, SYS_WRITE
	ecall

	addi sp, sp, 0x20b

	c.jr ra

.section .data
	.byte ESC
	.ascii "[1;17H0"
	.byte ESC
	.ascii "[2;10H       0"

block_string:
	.byte ESC
	.ascii "[10;01H ."
	.byte ESC
	.ascii "[10;01H ."
	.byte ESC
	.ascii "[10;01H ."
	.byte ESC
	.ascii "[10;01H ."

	.byte ESC
	.ascii "[10;01H[]"
	.byte ESC
	.ascii "[10;01H[]"
	.byte ESC
	.ascii "[10;01H[]"
	.byte ESC
	.ascii "[10;01H[]"

	.byte ESC
	.ascii "[3;10H       0"

	.byte ESC
	.ascii "[13;16H"
	.ascii "        "
	.byte ESC
	.ascii "[1B"
	.byte ESC
	.ascii "[8D"
	.ascii "      "
	.byte ESC
	.ascii "[13;16H"

	.skip 0x12

grid_string:
	.byte ESC, '[', 'H'
	.byte ESC, '[', '2', '6', 'C'
	.ascii " . . . . . . . . . .\n"
	.byte ESC, '[', '2', '6', 'C'
	.ascii " . . . . . . . . . .\n"
	.byte ESC, '[', '2', '6', 'C'
	.ascii " . . . . . . . . . .\n"
	.byte ESC, '[', '2', '6', 'C'
	.ascii " . . . . . . . . . .\n"
	.byte ESC, '[', '2', '6', 'C'
	.ascii " . . . . . . . . . .\n"
	.byte ESC, '[', '2', '6', 'C'
	.ascii " . . . . . . . . . .\n"
	.byte ESC, '[', '2', '6', 'C'
	.ascii " . . . . . . . . . .\n"
	.byte ESC, '[', '2', '6', 'C'
	.ascii " . . . . . . . . . .\n"
	.byte ESC, '[', '2', '6', 'C'
	.ascii " . . . . . . . . . .\n"
	.byte ESC, '[', '2', '6', 'C'
	.ascii " . . . . . . . . . .\n"
	.byte ESC, '[', '2', '6', 'C'
	.ascii " . . . . . . . . . .\n"
	.byte ESC, '[', '2', '6', 'C'
	.ascii " . . . . . . . . . .\n"
	.byte ESC, '[', '2', '6', 'C'
	.ascii " . . . . . . . . . .\n"
	.byte ESC, '[', '2', '6', 'C'
	.ascii " . . . . . . . . . .\n"
	.byte ESC, '[', '2', '6', 'C'
	.ascii " . . . . . . . . . .\n"
	.byte ESC, '[', '2', '6', 'C'
	.ascii " . . . . . . . . . .\n"
	.byte ESC, '[', '2', '6', 'C'
	.ascii " . . . . . . . . . .\n"
	.byte ESC, '[', '2', '6', 'C'
	.ascii " . . . . . . . . . .\n"
	.byte ESC, '[', '2', '6', 'C'
	.ascii " . . . . . . . . . .\n"
	.byte ESC, '[', '2', '6', 'C'
	.ascii " . . . . . . . . . .\n"

grid_string_end:

.section .rodata
grid_string_len: .word grid_string_end - grid_string

dot: .ascii " .[]"

delay_duration:
 .dword 0
 .dword 23157137828039747 / 11578565000

blocks_grid_offset:
	.byte -1, 0, 0, 0, 1, 0, 2, 0 # I
	.byte 0, -1, 0, 0, 0, 1, 0, 2
	.byte -1, 0, 0, 0, 1, 0, 2, 0
	.byte 0, -1, 0, 0, 0, 1, 0, 2

	.byte -1, 1, 0, 1, -1, 2, 1, 1 # J
	.byte 0, 0, 0, 1, 0, 2, 1, 2
	.byte 1, 0, -1, 1, 0, 1, 1, 1
	.byte -1, 0, 0, 0, 0, 1, 0, 2

	.byte -1, 1, 0, 1, 1, 1, 1, 2 # L
	.byte 0, 0, 0, 2, 0, 1, 1, 0
	.byte -1, 0, -1, 1, 0, 1, 1, 1
	.byte 0, 0, 0, 1, -1, 2, 0, 2

	.byte -1, 1, 0, 1, 0, 2, 1, 1 # T
	.byte 0, 2, 0, 1, 0, 0, 1, 1
	.byte 0, 0, -1, 1, 0, 1, 1, 1
	.byte -1, 1, 0, 1, 0, 0, 0, 2

	.byte -1, 0, 0, 0, 0, 1, 1, 1 # S
	.byte 0, 0, 0, 1, 1, -1, 1, 0 
	.byte -1, 0, 0, 0, 0, 1, 1, 1
	.byte 0, 0, 0, 1, 1, -1, 1, 0 

	.byte 0, 0, 0, 1, -1, 1, 1, 0 # Z
	.byte 0, -1, 0, 0, 1, 0, 1, 1
	.byte 0, 0, 0, 1, -1, 1, 1, 0
	.byte 0, -1, 0, 0, 1, 0, 1, 1

	.byte 0, 0, 1, 0, 0, 1, 1, 1 # O
	.byte 0, 0, 1, 0, 0, 1, 1, 1
	.byte 0, 0, 1, 0, 0, 1, 1, 1
	.byte 0, 0, 1, 0, 0, 1, 1, 1

xdigits: .ascii "0123456789ABCDEF"

fixed_block_string:
	.word block_string_I
	.word block_string_I_end - block_string_I

	.word block_string_J
	.word block_string_J_end - block_string_J

	.word block_string_L
	.word block_string_L_end - block_string_L

	.word block_string_T
	.word block_string_T_end - block_string_T

	.word block_string_S
	.word block_string_S_end - block_string_S

	.word block_string_Z
	.word block_string_Z_end - block_string_Z

	.word block_string_O
	.word block_string_O_end - block_string_O

block_string_I:
	.ascii "[][][][]"

block_string_I_end:

block_string_J:
	.ascii "[][][]"
	.byte ESC
	.ascii "[1B"
	.byte ESC
	.ascii "[2D"
	.ascii "[]"

block_string_J_end:

block_string_L:
	.ascii "[][][]"
	.byte ESC
	.ascii "[1B"
	.byte ESC
	.ascii "[6D"
	.ascii "[]"

block_string_L_end:

block_string_T:
	.ascii "[][][]"
	.byte ESC
	.ascii "[1B"
	.byte ESC
	.ascii "[4D"
	.ascii "[]"

block_string_T_end:

block_string_S:
	.ascii "  [][]"
	.byte ESC
	.ascii "[1B"
	.byte ESC
	.ascii "[6D"
	.ascii "[][]"

block_string_S_end:

block_string_Z:
	.ascii "[][]"
	.byte ESC
	.ascii "[1B"
	.byte ESC
	.ascii "[2D"
	.ascii "[][]"

block_string_Z_end:

block_string_O:
	.ascii "[][]"
	.byte ESC
	.ascii "[1B"
	.byte ESC
	.ascii "[4D"
	.ascii "[][]"

block_string_O_end:

