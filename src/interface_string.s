.align 0x2

.globl splash
.globl game_init
.globl instructions
.globl cleared_instructions

.include "src/constants.inc"

.section .rodata
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
	.ascii "YOUR LEVEL? (0-9) - "

game_init: # len: 0x363
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

instructions: # len: 0x8b
	.byte ESC
	.ascii "[2;55H"
	.ascii "7: LEFT"

	.byte ESC
	.ascii "[3;55H"
	.ascii "8: TURN"

	.byte ESC
	.ascii "[4;55H"
	.ascii "9: RIGHT"

	.byte ESC
	.ascii "[5;55H"
	.ascii "5: DROP"

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

game_init_end:

cleared_instructions: # len: 0x8b
	.byte ESC
	.ascii "[2;55H"
	.ascii "       "

	.byte ESC
	.ascii "[3;55H"
	.ascii "       "

	.byte ESC
	.ascii "[4;55H"
	.ascii "        "

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
