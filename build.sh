#!/usr/bin/env bash

catch() {
	if (( $? != 0 )); then
		echo "error:" $1 >&2
		exit
	fi
}

cleanup() {
	fcleanup $old_files
}

old_files=$(find . -maxdepth 1 -type f -printf '%P ')
trap cleanup EXIT INT TERM

llvm-mc -triple=riscv32-unknown-elf -mattr=+c,+zmmul,+Zcb -filetype=obj -show-encoding ./src/main.s -o main.o
catch "compilation failed"

ld.lld -m elf32lriscv -e _start main.o; catch "linking failed"

if [ "$1" = "-d" ]; then
	llvm-objdump --arch-name=riscv32 --mattr=+c,+zmmul,+Zcb -M no-aliases -d
	exit
fi

clear

if [ "$1" = "-x" ]; then
	qemu-riscv32 a.out | xxd
	exit
fi

qemu-riscv32 a.out
echo "exit code $?"

