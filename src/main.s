.align 0x2

.set STDIN, 0x0
.set STDOUT, 0x1

.set SYS_FCNTL64, 0x19
.set SYS_IOCTL, 0x1d
.set SYS_READ, 0x3f
.set SYS_WRITE, 0x40
.set SYS_EXIT, 0x5d
.set SYS_GETRANDOM, 0x116
.set SYS_CNT64, 0x197 # SYS_CLOCK_NANOSLEEP_TIME64

.set TCGETS, 0x5401
.set TCSETSF, 0x5404

.set ICANON, 0x2
.set ECHO, 0x8

.set F_GETFL, 0x3
.set F_SETFL, 0x4
.set O_NONBLOCK, 0x800

.set ESC, 0x1b#- 0x11

.set GRID_STATE, 0xc8 + 0x1 + 0x14 + (0xa * 0x2)
.set RAND_NUMS, 0xff
.set KERN_TERM, 0x2c

.globl _start
_start:
.option push
.option norelax
	la gp, __global_pointer$
.option pop

	# sp: buffer for storing random numbers
	# s0: pointer to current random number
	# s1: time remaining for the block to drop
	# s2: row position
	# s3: column position
	# s4: orientation
	# s5: block type
	# s6: block type of next block
	# s7: time step

	# s8: aaab bb00 0000 0000 0000 0000 000c defg
	#  - a: current level
	#  - b: level ups through line completion
	#  - c: text showing the level needs update
	#  - d: text showing the lines needs update
	#  - e: score for hiding next block
	#  - f: instruction is shown
	#  - g: next block is hidden

	# s9:  lines completed
	# s10: score
	# s11: grid state

	la t0, block_string
	la t1, blocks_grid_offset
	la t2, delay_duration
	la t3, xdigits
	la t4, grid_string
	la t5, fixed_block_string
	la t6, instructions

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

	# [1] info.txt
	c.lbu a0, (a1)

	c.andi a0, 0x7

	li s7, 0x100

	slli a1, a0, 0x5
	sub s7, s7, a1

	snez a1, a0
	c.slli a0, 0x1d
	c.slli a1, 0x4
	or s8, a0, a1

	ori s8, s8, 0x3
	c.li s9, 0x0
	c.li s10, 0x0

	# setting up stdin
	addi sp, sp, -KERN_TERM

	c.li a0, STDIN
	li a1, TCGETS
	c.mv a2, sp
	li a7, SYS_IOCTL
	ecall

	lw a0, 0xc(sp)

	sw a0, 0x24(sp) # lflag_swp

	c.andi a0, ~(ICANON|ECHO)

	sw a0, 0xc(sp)

	c.li a0, STDIN
	li a1, TCSETSF
	c.mv a2, sp
	li a7, SYS_IOCTL
	ecall

	c.li a0, STDIN
	c.li a1, F_GETFL
	li a7, SYS_FCNTL64
	ecall

	sw a0, 0x28(sp) # fflags

	li a1, O_NONBLOCK
	or a2, a0, a1

	c.li a0, STDIN
	c.li a1, F_SETFL
	li a7, SYS_FCNTL64
	ecall

	addi sp, sp, -GRID_STATE

	addi s11, sp, 0xb

	# [2] info.txt
	c.li a0, 0x1
	sb a0, (0x00 * 0xb) - 0x1(s11)
	sb a0, (0x01 * 0xb) - 0x1(s11)
	sb a0, (0x02 * 0xb) - 0x1(s11)
	sb a0, (0x03 * 0xb) - 0x1(s11)
	sb a0, (0x04 * 0xb) - 0x1(s11)
	sb a0, (0x05 * 0xb) - 0x1(s11)
	sb a0, (0x06 * 0xb) - 0x1(s11)
	sb a0, (0x07 * 0xb) - 0x1(s11)
	sb a0, (0x08 * 0xb) - 0x1(s11)
	sb a0, (0x09 * 0xb) - 0x1(s11)
	sb a0, (0x0a * 0xb) - 0x1(s11)
	sb a0, (0x0b * 0xb) - 0x1(s11)
	sb a0, (0x0c * 0xb) - 0x1(s11)
	sb a0, (0x0d * 0xb) - 0x1(s11)
	sb a0, (0x0e * 0xb) - 0x1(s11)
	sb a0, (0x0f * 0xb) - 0x1(s11)
	sb a0, (0x10 * 0xb) - 0x1(s11)
	sb a0, (0x11 * 0xb) - 0x1(s11)
	sb a0, (0x12 * 0xb) - 0x1(s11)
	sb a0, (0x13 * 0xb) - 0x1(s11)
	sb a0, (0x14 * 0xb) - 0x1(s11)
	sb a0, (0x14 * 0xb) + 0x0(s11)
	sb a0, (0x14 * 0xb) + 0x1(s11)
	sb a0, (0x14 * 0xb) + 0x2(s11)
	sb a0, (0x14 * 0xb) + 0x3(s11)
	sb a0, (0x14 * 0xb) + 0x4(s11)
	sb a0, (0x14 * 0xb) + 0x5(s11)
	sb a0, (0x14 * 0xb) + 0x6(s11)
	sb a0, (0x14 * 0xb) + 0x7(s11)
	sb a0, (0x14 * 0xb) + 0x8(s11)
	sb a0, (0x14 * 0xb) + 0x9(s11)

	c.li a0, STDOUT
	la a1, game_init
	li a2, 0x371
	li a7, SYS_WRITE
	ecall

	addi sp, sp, -RAND_NUMS

	c.mv a0, sp
	li a1, RAND_NUMS
	c.li a2, 0x0
	li a7, SYS_GETRANDOM
	ecall

	add s0, sp, a1

	c.addi s0, -0x1
	c.lbu a0, (s0)

	# s6 = a0 % 7
	li a1, 0x25
	c.mul a1, a0
	c.srli a1, 0x8
	sub a2, a0, a1
	c.slli a2, 0x18
	c.srli a2, 0x19
	c.add a1, a2
	c.srli a1, 0x2
	slli a2, a1, 0x3
	c.add a0, a1
	sub s6, a0, a2

loop_init:
	c.li s2, 0x0
	c.li s3, 0x4
	c.li s4, 0x1
	c.mv s5, s6
	c.mv s1, s7

	bgt s0, sp, 0f

	c.mv a0, sp
	li a1, RAND_NUMS
	c.li a2, 0x0
	li a7, SYS_GETRANDOM
	ecall

	c.add s0, a1

0:
	c.addi s0, -0x1
	c.lbu a0, (s0)

	# s6 = a0 % 7
	li a1, 0x25
	c.mul a1, a0
	c.srli a1, 0x8
	sub a2, a0, a1
	c.slli a2, 0x18
	c.srli a2, 0x19
	c.add a1, a2
	c.srli a1, 0x2
	slli a2, a1, 0x3
	c.add a0, a1
	sub s6, a0, a2

	c.jal prep_block_string_init

	addi a0, t0, (0x4 * 0xa * 0x2) + 0xf
	c.mv a1, s10

0:
	andi a3, a1, 0xf
	c.add a3, t3
	c.addi a0, -0x1

	c.lbu a3, (a3)
	c.sb a3, (a0)

	c.srli a1, 0x4
	c.bnez a1, 0b

	addi a1, t0, 0x4 * 0xa
	li a2, (0x4 * 0xa) + 0xf

	andi a3, s8, 0x1
	c.bnez a3, 0f

	slli a5, s6, 0x4
	add a5, a5, t5

	c.lw a0, 0x0(a5)
	lw a3, 0x4(a5)
	lw a4, 0x8(a5)
	lw a5, 0xc(a5)

	sw a0, (0x4 * 0xa) + 0xf + 0x8 + 0x0(a1)
	sw a3, (0x4 * 0xa) + 0xf + 0x8 + 0x4(a1)
	sw a4, (0x4 * 0xa) + 0xf + 0x8 + 0x10 + 0x0(a1)
	sw a5, (0x4 * 0xa) + 0xf + 0x8 + 0x10 + 0x4(a1)

	addi a2, a2, 0x20

0:
	andi a3, s8, 0x1 << 0x3
	c.beqz a3, 2f

	c.addi a1, -0xf
	c.addi a2, 0xf

	lw a3, -0xf(t0)
	lw a4, -0xb(t0)
	lw a5, -0x7(t0)
	lh a6, -0x3(t0)

	sw a3, (a1)
	sw a4, 0x4(a1)
	sw a5, 0x8(a1)
	sh a6, 0xc(a1)

	addi a4, a1, 0xf
	c.mv a5, s9

1:
	andi a3, a5, 0xf
	c.add a3, t3
	c.addi a4, -0x1

	c.lbu a3, (a3)
	c.sb a3, (a4)

	c.srli a5, 0x4
	c.bnez a5, 1b

2:
	andi a3, s8, 0x1 << 0x4
	c.beqz a3, 0f

	c.addi a1, -0x8
	c.addi a2, 0x8

	// this should be possible with Zilsd extention
	// but qemu said "illegal instruction"
	//ld a4, -0xf - 0x8(t0)
	//sd a4, (a1)

	lw a3, -0xf - 0x8(t0)
	lw a4, -0xf - 0x4(t0)

	sw a3, (a1)
	sw a4, 0x4(a1)

	srli a3, s8, 0x1d
	ori a3, a3, 0x30

	sb a3, 0x7(a1)

0:
	c.li a0, STDOUT
	li a7, SYS_WRITE
	ecall

	andi a3, s8, 0x3 << 0x3
	beqz a3, 0f

	lw a0, 0x0(t0)
	lw a1, 0x4(t0)
	lh a2, 0x8(t0)

	sw a0, (0xa * 0x1) + 0x0(t0)
	sw a1, (0xa * 0x1) + 0x4(t0)
	sh a2, (0xa * 0x1) + 0x8(t0)

	sw a0, (0xa * 0x2) + 0x0(t0)
	sw a1, (0xa * 0x2) + 0x4(t0)
	sh a2, (0xa * 0x2) + 0x8(t0)

	sw a0, (0xa * 0x3) + 0x0(t0)
	sw a1, (0xa * 0x3) + 0x4(t0)
	sh a2, (0xa * 0x3) + 0x8(t0)

0:
	li a0, 0xfc000003
	and s8, s8, a0
	slli a0, s8, 0x2
	c.andi a0, 0x1 << 0x2
	or s8, s8, a0

	c.jal can_fit_block
	c.bnez a0, loop_end

loop_start:
	c.li a0, 0x0
	c.li a1, 0x0
	c.mv a2, t2
	c.li a3, 0x0
	li a7, SYS_CNT64
	ecall

	c.addi s1, -0x1
	c.beqz s1, desn

	c.li a0, STDIN
	addi a1, sp, -0x1
	c.li a2, 0x1
	li a7, SYS_READ
	ecall

	blez a0, loop_start

	c.lbu a1, (a1)

	li a0, '7'
	beq a1, a0, left

	c.addi a0, 0x2 # '9'
	beq a1, a0, right

	c.addi a0, -0x1 # '8'
	beq a1, a0, turn

	c.addi a0, -0x3 # '5'
	beq a1, a0, drop

	c.addi a0, 0x1 # '6'
	beq a1, a0, down

	c.addi a0, -0x2 # '4'
	beq a1, a0, accelerate

	c.addi a0, -0x3 # '1'
	beq a1, a0, toggle_view_next

	c.addi a0, -0x1 # '0'
	beq a1, a0, toggle_view_instruction

	c.addi a0, -0x10 # ' '
	beq a1, a0, drop

	c.j loop_start

left:
	c.addi s3, -0x1

	c.jal can_fit_block
	c.beqz a0, 0f

	c.addi s3, 0x1

	c.j loop_start

right:
	c.addi s3, 0x1

	c.jal can_fit_block
	c.beqz a0, 0f

	c.addi s3, -0x1

	c.j loop_start

turn:
	c.addi s4, 0x1
	andi s4, s4, 0x3

	c.jal can_fit_block
	c.beqz a0, 0f

	c.addi s4, 0x3
	andi s4, s4, 0x3

	c.j loop_start

desn:
	c.mv s1, s7

down:
	c.addi s2, 0x1

	c.jal can_fit_block
	c.bnez a0, 1f

0:
	c.jal prep_block_string

	c.li a0, STDOUT
	c.mv a1, t0
	li a2, (0x4 * 0xa) * 2
	li a7, SYS_WRITE
	ecall

	c.j loop_start

drop:
	c.li a4, -0x1

0:
	c.addi s2, 0x1

	# NOTE the a4 register is used here after confirming that
	# it's not used anywhere in the `can_fit_block` function
	c.addi a4, 0x1

	c.jal can_fit_block
	c.beqz a0, 0b

	srli a2, s8, 0x1d
	c.mul a4, a2

	c.add s10, a4

	c.addi s2, -0x1

	c.jal prep_block_string

	c.li a0, STDOUT
	c.mv a1, t0
	li a2, (0x4 * 0xa) * 0x2
	li a7, SYS_WRITE
	ecall

	c.addi s2, 0x1

1:
	c.addi s2, -0x1

0:
	andi a0, s8, 0x1 << 0x2

	c.add s10, a0

	slli a0, s5, 0x5
	add a1, a0, t1
	slli a0, s4, 0x3
	c.add a1, a0

	c.li a3, 0x1

	lb a2, (0x0 * 0x2) + 0x0(a1)
	c.add a2, s2
	c.li a0, 0xb
	c.mul a0, a2
	lb a2, (0x0 * 0x2) + 0x1(a1)
	c.add a2, s3
	c.add a0, a2
	c.add a0, s11
	c.sb a3, (a0)

	lb a2, (0x1 * 0x2) + 0x0(a1)
	c.add a2, s2
	c.li a0, 0xb
	c.mul a0, a2
	lb a2, (0x1 * 0x2) + 0x1(a1)
	c.add a2, s3
	c.add a0, a2
	c.add a0, s11
	c.sb a3, (a0)

	lb a2, (0x2 * 0x2) + 0x0(a1)
	c.add a2, s2
	c.li a0, 0xb
	c.mul a0, a2
	lb a2, (0x2 * 0x2) + 0x1(a1)
	c.add a2, s3
	c.add a0, a2
	c.add a0, s11
	c.sb a3, (a0)

	lb a2, (0x3 * 0x2) + 0x0(a1)
	c.add a2, s2

	addi a4, a2, 0x1

	c.li a0, 0xb
	c.mul a0, a2

	add a6, a0, s11

	lb a2, (0x3 * 0x2) + 0x1(a1)
	c.add a2, s3
	c.add a0, a2
	c.add a0, s11
	c.sb a3, (a0)

	li a3, 0x2020303

	c.li a0, 0x0
	c.li a5, 0x0

	lw a1, -(0x0 * 0xb) + 0x0(a6)
	lw a2, -(0x0 * 0xb) + 0x4(a6)
	c.add a1, a2
	lhu a2, -(0x0 * 0xb) + 0x8(a6)
	c.add a1, a2

	c.xor a1, a3
	seqz a1, a1

	c.add a5, a1

	c.or a0, a1

	lw a1, -(0x1 * 0xb) + 0x0(a6)
	lw a2, -(0x1 * 0xb) + 0x4(a6)
	c.add a1, a2
	lhu a2, -(0x1 * 0xb) + 0x8(a6)
	c.add a1, a2

	c.xor a1, a3
	seqz a1, a1

	c.add a5, a1

	c.slli a1, 0x1
	c.or a0, a1

	lw a1, -(0x2 * 0xb) + 0x0(a6)
	lw a2, -(0x2 * 0xb) + 0x4(a6)
	c.add a1, a2
	lhu a2, -(0x2 * 0xb) + 0x8(a6)
	c.add a1, a2

	c.xor a1, a3
	seqz a1, a1

	c.add a5, a1

	c.slli a1, 0x2
	c.or a0, a1

	lw a1, -(0x3 * 0xb) + 0x0(a6)
	lw a2, -(0x3 * 0xb) + 0x4(a6)
	c.add a1, a2
	lhu a2, -(0x3 * 0xb) + 0x8(a6)
	c.add a1, a2

	c.xor a1, a3
	seqz a1, a1

	c.add a5, a1

	c.slli a1, 0x3
	c.or a0, a1

	c.beqz a0, loop_init

	c.add s9, a5

	srli a1, s8, 0x1d

	sll a5, a5, a5
	c.mul a5, a1

	c.add s10, a5

	ori s8, s8, 0x8

	c.li a2, 0x7
	beq a1, a2, 0f

	srli a3, s8, 0x1a
	c.and a3, a2
	c.addi a3, 0x5

	srl a3, s9, a3
	c.beqz a3, 0f

	lui a1, 0x24000
	c.add s8, a1
	ori s8, s8, 0x10

	c.addi s7, -0x20

0:
	andi a1, a0, 0x1
	c.bnez a1, 0f

	c.srli a0, 0x1
	c.addi a4, -0x1
	c.addi a6, -0xb
	c.j 0b

0:
	c.mv a3, s11
	c.li a5, 0x1

0:
	c.lw a1, 0x0(a3)
	lw a2, 0x4(a3)
	c.add a1, a2
	lhu a2, 0x8(a3)
	c.add a1, a2

	c.bnez a1, 0f

	c.addi a3, 0xb
	c.addi a5, 0x1
	c.j 0b

0:
	c.sub a4, a5

0:
	andi a1, a0, 0x1
	c.beqz a1, 2f

	c.mv a2, a6

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
	c.bnez a0, 0b

2:
	c.srli a0, 0x1
	c.addi a6, -0xb
	c.bnez a0, 0b

//* TODO romove these
	la ra, loop_init
	c.j print_grid
//*/

	li a0, 0xcd
	c.li a1, -0xa

	c.mul a0, a5
	c.srli a0, 0xb
	c.mul a1, a0
	ori a0, a0, 0x30
	c.add a1, a5
	ori a1, a1, 0x30

	c.slli a1, 0x8
	c.or a0, a1

	c.li a2, 0x1a
	c.mul a2, a4
	c.addi a2, 0x1c

	sh a0, 0x2(t4)

	li a6, 0x2e202e20
	sw a6, 0x8 + (0x4 * 0x0)(t4)
	sw a6, 0x8 + (0x4 * 0x1)(t4)
	sw a6, 0x8 + (0x4 * 0x2)(t4)
	sw a6, 0x8 + (0x4 * 0x3)(t4)
	sw a6, 0x8 + (0x4 * 0x4)(t4)

	li a6, 0x5d5b2e20
	addi a0, t4, 0x22
	c.addi a3, 0xb

	li a7, 0xffff

0:
	c.lbu a1, 0x1 + (0x2 * 0x0)(a3)
	c.slli a1, 0x4
	srl a5, a6, a1
	c.slli a5, 0x10
	c.lbu a1, 0x2 * 0x0(a3)
	c.slli a1, 0x4
	srl a1, a6, a1
	and a1, a1, a7
	c.or a1, a5
	sw a1, 0x4 * 0x0(a0)

	c.lbu a1, 0x1 + (0x2 * 0x1)(a3)
	c.slli a1, 0x4
	srl a5, a6, a1
	c.slli a5, 0x10
	c.lbu a1, 0x2 * 0x1(a3)
	c.slli a1, 0x4
	srl a1, a6, a1
	and a1, a1, a7
	c.or a1, a5
	sw a1, 0x4 * 0x1(a0)

	lbu a1, 0x1 + (0x2 * 0x2)(a3)
	c.slli a1, 0x4
	srl a5, a6, a1
	c.slli a5, 0x10
	lbu a1, 0x2 * 0x2(a3)
	c.slli a1, 0x4
	srl a1, a6, a1
	and a1, a1, a7
	c.or a1, a5
	sw a1, 0x4 * 0x2(a0)

	lbu a1, 0x1 + (0x2 * 0x3)(a3)
	c.slli a1, 0x4
	srl a5, a6, a1
	c.slli a5, 0x10
	lbu a1, 0x2 * 0x3(a3)
	c.slli a1, 0x4
	srl a1, a6, a1
	and a1, a1, a7
	c.or a1, a5
	sw a1, 0x4 * 0x3(a0)

	lbu a1, 0x1 + (0x2 * 0x4)(a3)
	c.slli a1, 0x4
	srl a5, a6, a1
	c.slli a5, 0x10
	lbu a1, 0x2 * 0x4(a3)
	c.slli a1, 0x4
	srl a1, a6, a1
	and a1, a1, a7
	c.or a1, a5
	sw a1, 0x4 * 0x4(a0)

	c.addi a3, 0xb
	c.addi a0, 0x1a

	c.addi a4, -0x1
	c.bnez a4, 0b

	c.li a0, STDOUT
	c.mv a1, t4
	li a7, SYS_WRITE
	ecall

	c.j loop_init

accelerate:
	srli a0, s8, 0x1d
	c.li a1, 0x7
	beq a0, a1, loop_start   # checking if we're already at max level

	lui a0, 0x20000
	c.li a1, 0x10

	c.addi s7, -0x20         # decreasing the time step (which means more speed)

	c.add s8, a0             # adding 1 to the level
	or s8, s8, a1            # setting "text showing the level needs update" to true

	c.j loop_start

toggle_view_next:
	li a0, 0xfc000003        # setting the "score for hiding next block" to false
	and s8, s8, a0           # while preseving all the other values such as level

	xori s8, s8, 0x1         # and toggling the "next block is hidden" flag

	li a4, 0x7 << 0x4        # setting the offset to the blank string

	andi a0, s8, 0x1
	c.bnez a0, 0f

	slli a4, s6, 0x4         # and if next block is not hidden, set it to the corresponding block

0:
	add a4, a4, t5

	addi a1, t0, (0x4 * 0xa * 0x2) + 0xf

	c.lw a0, 0x0(a4)
	lw a2, 0x4(a4)
	lw a3, 0x8(a4)
	lw a4, 0xc(a4)

	sw a0, 0x8 + 0x0(a1)
	sw a2, 0x8 + 0x4(a1)
	sw a3, 0x8 + 0x10 + 0x0(a1)
	sw a4, 0x8 + 0x10 + 0x4(a1)

	c.li a0, STDOUT
	li a2, 0x20
	li a7, SYS_WRITE
	ecall

	c.j loop_start

toggle_view_instruction:
	c.mv a1, t6
	li a2, 0x99

	andi a0, s8, 0x2
	c.beqz a0, 0f

	c.add a1, a2

0:
	c.li a0, STDOUT
	li a7, SYS_WRITE
	ecall

	xori s8, s8, 0x2

	c.j loop_start

loop_end:
	addi sp, sp, RAND_NUMS + GRID_STATE

	# reseting stdin
	c.li a0, STDIN
	li a1, F_SETFL
	lw a2, 0x28(sp)
	li a7, SYS_FCNTL64
	ecall

	lw a0, 0x24(sp)
	sw a0, 0xc(sp)

	c.li a0, STDIN
	li a1, TCSETSF
	c.mv a2, sp
	li a7, SYS_IOCTL
	ecall

	addi sp, sp, KERN_TERM

	addi a1, sp, -0xe

	c.li a0, ESC
	c.sb a0, 0x0(a1)
	li a0, '['
	c.sb a0, 0x1(a1)
	li a0, ';'
	sb a0, 0x4(a1)
	li a0, 'H'
	sb a0, 0x7(a1)

	li a0, 0x3532
	c.sh a0, 0x2(a1)
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
	slli a2, s5, 0x5
	add a1, a2, t1
	slli a2, s4, 0x3
	c.add a1, a2

	c.li a0, 0x0

	lb a2, (0x0 * 0x2) + 0x0(a1)
	c.add a2, s2

	sltz a3, a2
	c.add a0, a3

	c.li a3, 0xb
	c.mul a3, a2
	lb a2, (0x0 * 0x2) + 0x1(a1)
	c.add a2, s3
	c.add a3, a2
	c.add a3, s11
	c.lbu a3, (a3)
	c.add a0, a3

	lb a2, (0x1 * 0x2) + 0x0(a1)
	c.add a2, s2

	sltz a3, a2
	c.add a0, a3

	c.li a3, 0xb
	c.mul a3, a2
	lb a2, (0x1 * 0x2) + 0x1(a1)
	c.add a2, s3
	c.add a3, a2
	c.add a3, s11
	c.lbu a3, (a3)
	c.add a0, a3

	lb a2, (0x2 * 0x2) + 0x0(a1)
	c.add a2, s2

	sltz a3, a2
	c.add a0, a3

	c.li a3, 0xb
	c.mul a3, a2
	lb a2, (0x2 * 0x2) + 0x1(a1)
	c.add a2, s3
	c.add a3, a2
	c.add a3, s11
	c.lbu a3, (a3)
	c.add a0, a3

	lb a2, (0x3 * 0x2) + 0x0(a1)
	c.add a2, s2

	sltz a3, a2
	c.add a0, a3

	c.li a3, 0xb
	c.mul a3, a2
	lb a2, (0x3 * 0x2) + 0x1(a1)
	c.add a2, s3
	c.add a3, a2
	c.add a3, s11
	c.lbu a3, (a3)
	c.add a0, a3

	c.jr ra

prep_block_string:
	lhu a0, (0x4 * 0xa) + (0x0 * 0xa) + 0x2(t0)
	lhu a1, (0x4 * 0xa) + (0x0 * 0xa) + 0x5(t0)
	lhu a2, (0x4 * 0xa) + (0x1 * 0xa) + 0x2(t0)
	lhu a3, (0x4 * 0xa) + (0x1 * 0xa) + 0x5(t0)
	lhu a4, (0x4 * 0xa) + (0x2 * 0xa) + 0x2(t0)
	lhu a5, (0x4 * 0xa) + (0x2 * 0xa) + 0x5(t0)
	lhu a6, (0x4 * 0xa) + (0x3 * 0xa) + 0x2(t0)
	lhu a7, (0x4 * 0xa) + (0x3 * 0xa) + 0x5(t0)

	sh a0, (0x0 * 0xa) + 0x2(t0)
	sh a1, (0x0 * 0xa) + 0x5(t0)
	sh a2, (0x1 * 0xa) + 0x2(t0)
	sh a3, (0x1 * 0xa) + 0x5(t0)
	sh a4, (0x2 * 0xa) + 0x2(t0)
	sh a5, (0x2 * 0xa) + 0x5(t0)
	sh a6, (0x3 * 0xa) + 0x2(t0)
	sh a7, (0x3 * 0xa) + 0x5(t0)

prep_block_string_init:
	slli a0, s5, 0x5
	add a7, a0, t1
	slli a0, s4, 0x3
	c.add a7, a0

	c.addi sp, -0x8

	lb a0, (0x0 * 0x2) + 0x0(a7)
	lb a4, (0x0 * 0x2) + 0x1(a7)
	lb a1, (0x1 * 0x2) + 0x0(a7)
	lb a5, (0x1 * 0x2) + 0x1(a7)
	lb a2, (0x2 * 0x2) + 0x0(a7)
	lb a6, (0x2 * 0x2) + 0x1(a7)
	lb a3, (0x3 * 0x2) + 0x0(a7)
	lb a7, (0x3 * 0x2) + 0x1(a7)

	c.add a0, s2
	c.add a1, s2
	c.add a2, s2
	c.add a3, s2
	c.add a4, s3
	c.add a5, s3
	c.add a6, s3
	c.add a7, s3

	sb a0, (0x0 * 0x2) + 0x0(sp)
	sb a4, (0x0 * 0x2) + 0x1(sp)
	sb a1, (0x1 * 0x2) + 0x0(sp)
	sb a5, (0x1 * 0x2) + 0x1(sp)
	sb a2, (0x2 * 0x2) + 0x0(sp)
	sb a6, (0x2 * 0x2) + 0x1(sp)
	sb a3, (0x3 * 0x2) + 0x0(sp)
	sb a7, (0x3 * 0x2) + 0x1(sp)

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

	c.slli a1, 0x8
	c.or a1, a2

	sh a1, (0x4 * 0xa) + (0x0 * 0xa) + 0x2(t0)

	lbu a0, (0x1 * 0x2) + 0x0(sp)

	c.addi a0, 0x1

	mul a2, a0, a4
	c.srli a2, 0xb
	mul a3, a2, a5
	ori a2, a2, 0x30
	add a1, a0, a3
	ori a1, a1, 0x30

	c.slli a1, 0x8
	c.or a1, a2

	sh a1, (0x4 * 0xa) + (0x1 * 0xa) + 0x2(t0)

	lbu a0, (0x2 * 0x2) + 0x0(sp)

	c.addi a0, 0x1

	mul a2, a0, a4
	c.srli a2, 0xb
	mul a3, a2, a5
	ori a2, a2, 0x30
	add a1, a0, a3
	ori a1, a1, 0x30

	c.slli a1, 0x8
	c.or a1, a2

	sh a1, (0x4 * 0xa) + (0x2 * 0xa) + 0x2(t0)

	lbu a0, (0x3 * 0x2) + 0x0(sp)

	c.addi a0, 0x1

	mul a2, a0, a4
	c.srli a2, 0xb
	mul a3, a2, a5
	ori a2, a2, 0x30
	add a1, a0, a3
	ori a1, a1, 0x30

	c.slli a1, 0x8
	c.or a1, a2

	sh a1, (0x4 * 0xa) + (0x3 * 0xa) + 0x2(t0)

	lbu a0, (0x0 * 0x2) + 0x1(sp)

	c.slli a0, 0x1
	c.addi a0, 0x19

	mul a2, a0, a4
	c.srli a2, 0xb
	mul a3, a2, a5
	ori a2, a2, 0x30
	add a1, a0, a3
	ori a1, a1, 0x30

	c.slli a1, 0x8
	c.or a1, a2

	sh a1, (0x4 * 0xa) + (0x0 * 0xa) + 0x5(t0)

	lbu a0, (0x1 * 0x2) + 0x1(sp)

	c.slli a0, 0x1
	c.addi a0, 0x19

	mul a2, a0, a4
	c.srli a2, 0xb
	mul a3, a2, a5
	ori a2, a2, 0x30
	add a1, a0, a3
	ori a1, a1, 0x30

	c.slli a1, 0x8
	c.or a1, a2

	sh a1, (0x4 * 0xa) + (0x1 * 0xa) + 0x5(t0)

	lbu a0, (0x2 * 0x2) + 0x1(sp)

	c.slli a0, 0x1
	c.addi a0, 0x19

	mul a2, a0, a4
	c.srli a2, 0xb
	mul a3, a2, a5
	ori a2, a2, 0x30
	add a1, a0, a3
	ori a1, a1, 0x30

	c.slli a1, 0x8
	c.or a1, a2

	sh a1, (0x4 * 0xa) + (0x2 * 0xa) + 0x5(t0)

	lbu a0, (0x3 * 0x2) + 0x1(sp)

	c.slli a0, 0x1
	c.addi a0, 0x19

	mul a2, a0, a4
	c.srli a2, 0xb
	mul a3, a2, a5
	ori a2, a2, 0x30
	add a1, a0, a3
	ori a1, a1, 0x30

	c.slli a1, 0x8
	c.or a1, a2

	sh a1, (0x4 * 0xa) + (0x3 * 0xa) + 0x5(t0)

	c.addi sp, 0x8

	c.jr ra

// functions below are for debugging

// uses t registers for arguments
print_reg:
	c.addi sp, -(0x4 * 0x4)
	sw a0, (0x4 * 0x0)(sp)
	sw a1, (0x4 * 0x1)(sp)
	sw a2, (0x4 * 0x2)(sp)
	sw a3, (0x4 * 0x3)(sp)

	c.li a1, '\n'
	sb a1, -0x1(sp)

	li a1, '0'
	sb a1, -0x2(sp)
	sb a1, -0x3(sp)
	sb a1, -0x4(sp)
	sb a1, -0x5(sp)
	sb a1, -0x6(sp)
	sb a1, -0x7(sp)
	sb a1, -0x8(sp)
	sb a1, -0x9(sp)

	addi a0, sp, -0x1
	c.mv a1, t0
	la a2, xdigits

0:
	andi a3, a1, 0xf
	add a3, a2, a3
	c.lbu a3, (a3)

	c.addi a0, -0x1
	sb a3, (a0)

	c.srli a1, 0x4
	c.bnez a1, 0b

	c.li a0, STDOUT
	addi a1, sp, -0x9
	li a2, 0x9
	li a7, SYS_WRITE
	ecall

	lw a0, (0x4 * 0x0)(sp)
	lw a1, (0x4 * 0x1)(sp)
	lw a2, (0x4 * 0x2)(sp)
	lw a3, (0x4 * 0x3)(sp)
	c.addi sp, (0x4 * 0x4)

	c.jr ra

// uses t registers for arguments
place_cur:
	c.addi sp, -(0x4 * 0x4)
	sw a0, (0x4 * 0x0)(sp)
	sw a1, (0x4 * 0x1)(sp)
	sw a2, (0x4 * 0x2)(sp)
	sw a3, (0x4 * 0x3)(sp)

	addi a3, sp, -0x8

	c.li a2, ESC
	sb a2, 0x0(a3)
	li a2, '['
	sb a2, 0x1(a3)
	li a2, ';'
	sb a2, 0x4(a3)
	li a2, 'H'
	sb a2, 0x7(a3)

	sh t0, 0x2(a3)
	sh t1, 0x5(a3)

	c.li a0, STDOUT
	mv a1, a3
	c.li a2, 0x8
	li a7, SYS_WRITE
	ecall

	lw a0, (0x4 * 0x0)(sp)
	lw a1, (0x4 * 0x1)(sp)
	lw a2, (0x4 * 0x2)(sp)
	lw a3, (0x4 * 0x3)(sp)
	c.addi sp, (0x4 * 0x4)

	c.jr ra

print_grid:
	addi sp, sp, -0x20b

	c.mv a0, sp

	c.li a1, ESC
	sb a1, (a0)
	c.addi a0, 0x1

	li a1, '['
	sb a1, (a0)
	c.addi a0, 0x1

	li a1, 'H'
	sb a1, (a0)
	c.addi a0, 0x1

	c.mv a2, s11

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
	c.lbu a1, (a2)
	c.addi a2, 0x1

	li a5, 0x5d5b2e20

	#snez a1, a1
	c.slli a1, 0x4

	srl a1, a5, a1

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
	.ascii "[1;17H0" # update level
	.byte ESC
	.ascii "[2;10H       0" # update lines completed

block_string:
	.byte ESC
	.ascii "[10;01H ." # clearing previously drawn block on the grid
	.byte ESC
	.ascii "[10;01H ."
	.byte ESC
	.ascii "[10;01H ."
	.byte ESC
	.ascii "[10;01H ."

	.byte ESC
	.ascii "[10;01H[]" # drawing the block on the grid
	.byte ESC
	.ascii "[10;01H[]"
	.byte ESC
	.ascii "[10;01H[]"
	.byte ESC
	.ascii "[10;01H[]"

	.byte ESC
	.ascii "[3;10H       0" # update score

	.byte ESC
	.ascii "[11;14H"
	.ascii "        " # draw the current next block
	.byte ESC
	.ascii "[1B"
	.byte ESC
	.ascii "[8D"
	.ascii "        "

grid_string:
	.byte ESC
	.ascii "[01;25H"
	.ascii " , , , , , , , , , ,\n"
	.byte ESC, '[', '2', '4', 'C'
	.ascii " , , , , , , , , , ,\n"
	.byte ESC, '[', '2', '4', 'C'
	.ascii " , , , , , , , , , ,\n"
	.byte ESC, '[', '2', '4', 'C'
	.ascii " , , , , , , , , , ,\n"
	.byte ESC, '[', '2', '4', 'C'
	.ascii " , , , , , , , , , ,\n"
	.byte ESC, '[', '2', '4', 'C'
	.ascii " , , , , , , , , , ,\n"
	.byte ESC, '[', '2', '4', 'C'
	.ascii " , , , , , , , , , ,\n"
	.byte ESC, '[', '2', '4', 'C'
	.ascii " , , , , , , , , , ,\n"
	.byte ESC, '[', '2', '4', 'C'
	.ascii " , , , , , , , , , ,\n"
	.byte ESC, '[', '2', '4', 'C'
	.ascii " , , , , , , , , , ,\n"
	.byte ESC, '[', '2', '4', 'C'
	.ascii " , , , , , , , , , ,\n"
	.byte ESC, '[', '2', '4', 'C'
	.ascii " , , , , , , , , , ,\n"
	.byte ESC, '[', '2', '4', 'C'
	.ascii " , , , , , , , , , ,\n"
	.byte ESC, '[', '2', '4', 'C'
	.ascii " , , , , , , , , , ,\n"
	.byte ESC, '[', '2', '4', 'C'
	.ascii " , , , , , , , , , ,\n"
	.byte ESC, '[', '2', '4', 'C'
	.ascii " , , , , , , , , , ,\n"
	.byte ESC, '[', '2', '4', 'C'
	.ascii " , , , , , , , , , ,\n"
	.byte ESC, '[', '2', '4', 'C'
	.ascii " , , , , , , , , , ,\n"
	.byte ESC, '[', '2', '4', 'C'
	.ascii " , , , , , , , , , ,\n"
	.byte ESC, '[', '2', '4', 'C'
	.ascii " , , , , , , , , , ,\n"

.section .rodata
delay_duration:
 .dword 0
 .dword 23157137828039747 / 11578565000

xdigits: .ascii "0123456789ABCDEF"

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

fixed_block_string:
	.ascii "[][][][]"
	.ascii "        "

	.ascii "[][][]  "
	.ascii "    []  "

	.ascii "[][][]  "
	.ascii "[]      "

	.ascii "[][][]  "
	.ascii "  []    "

	.ascii "  [][]  "
	.ascii "[][]    "

	.ascii "[][]    "
	.ascii "  [][]  "

	.ascii "[][]    "
	.ascii "[][]    "

	.ascii "        "
	.ascii "        "

splash: # len: 0x4b
	.byte ESC
	.ascii "[2J"

	.byte ESC
	.ascii "[11;30H"
	.ascii "[ ]"

	.byte ESC
	.ascii "[12;30H"
	.ascii "T E T R I S C"

	.byte ESC
	.ascii "[13;40H"
	.ascii "[ ]"

	.byte ESC
	.ascii "[21;25H"
	.ascii "YOUR LEVEL? (0-7) - "

game_init: # len: 0x371
	.byte ESC
	.ascii "[?25l"

	.byte ESC
	.ascii "[2J"

	.byte ESC, '[', 'H'
	.byte ESC, '[', '2', '2', 'C'
	.ascii "<! . . . . . . . . . .!>\n"
	.byte ESC, '[', '2', '2', 'C'
	.ascii "<! . . . . . . . . . .!>\n"
	.byte ESC, '[', '2', '2', 'C'
	.ascii "<! . . . . . . . . . .!>\n"
	.byte ESC, '[', '2', '2', 'C'
	.ascii "<! . . . . . . . . . .!>\n"
	.byte ESC, '[', '2', '2', 'C'
	.ascii "<! . . . . . . . . . .!>\n"
	.byte ESC, '[', '2', '2', 'C'
	.ascii "<! . . . . . . . . . .!>\n"
	.byte ESC, '[', '2', '2', 'C'
	.ascii "<! . . . . . . . . . .!>\n"
	.byte ESC, '[', '2', '2', 'C'
	.ascii "<! . . . . . . . . . .!>\n"
	.byte ESC, '[', '2', '2', 'C'
	.ascii "<! . . . . . . . . . .!>\n"
	.byte ESC, '[', '2', '2', 'C'
	.ascii "<! . . . . . . . . . .!>\n"
	.byte ESC, '[', '2', '2', 'C'
	.ascii "<! . . . . . . . . . .!>\n"
	.byte ESC, '[', '2', '2', 'C'
	.ascii "<! . . . . . . . . . .!>\n"
	.byte ESC, '[', '2', '2', 'C'
	.ascii "<! . . . . . . . . . .!>\n"
	.byte ESC, '[', '2', '2', 'C'
	.ascii "<! . . . . . . . . . .!>\n"
	.byte ESC, '[', '2', '2', 'C'
	.ascii "<! . . . . . . . . . .!>\n"
	.byte ESC, '[', '2', '2', 'C'
	.ascii "<! . . . . . . . . . .!>\n"
	.byte ESC, '[', '2', '2', 'C'
	.ascii "<! . . . . . . . . . .!>\n"
	.byte ESC, '[', '2', '2', 'C'
	.ascii "<! . . . . . . . . . .!>\n"
	.byte ESC, '[', '2', '2', 'C'
	.ascii "<! . . . . . . . . . .!>\n"
	.byte ESC, '[', '2', '2', 'C'
	.ascii "<! . . . . . . . . . .!>\n"

	.byte ESC, '[', '2', '2', 'C'
	.ascii "<!====================!>\n"
	.byte ESC, '[', '2', '4', 'C'
	.ascii "\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/"

	.byte ESC
	.ascii "[1;1H"
	.ascii "LEVEL:          0\n"
	.ascii "LINES:          0\n"
	.ascii "SCORE:          0\n"

instructions: # len: 0x99
	.byte ESC
	.ascii "[1;55H"
	.ascii "7: LEFT"

	.byte ESC
	.ascii "[2;55H"
	.ascii "8: TURN"

	.byte ESC
	.ascii "[3;55H"
	.ascii "9: RIGHT"

	.byte ESC
	.ascii "[4;55H"
	.ascii "5: DROP"

	.byte ESC
	.ascii "[5;55H"
	.ascii "6: DOWN"

	.byte ESC
	.ascii "[6;55H"
	.ascii "4: ACCELERATE"

	.byte ESC
	.ascii "[7;55H"
	.ascii "1: SHOW NEXT"

	.byte ESC
	.ascii "[8;55H"
	.ascii "0: ERASE THIS TEXT"

	.byte ESC
	.ascii "[9;51H"
	.ascii "SPACE: DROP"

cleared_instructions: # len: 0x99
	.byte ESC
	.ascii "[1;55H"
	.ascii "       "

	.byte ESC
	.ascii "[2;55H"
	.ascii "       "

	.byte ESC
	.ascii "[3;55H"
	.ascii "        "

	.byte ESC
	.ascii "[4;55H"
	.ascii "       "

	.byte ESC
	.ascii "[5;55H"
	.ascii "       "

	.byte ESC
	.ascii "[6;55H"
	.ascii "             "

	.byte ESC
	.ascii "[7;55H"
	.ascii "            "

	.byte ESC
	.ascii "[8;55H"
	.ascii "                  "

	.byte ESC
	.ascii "[9;51H"
	.ascii "           "
