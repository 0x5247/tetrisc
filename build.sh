#!/usr/bin/env bash

llvm-mc -triple=riscv32-unknown-elf -mattr=+c,+zmmul,+Zcb -filetype=obj -show-encoding ./src/main.s -o main.o && \

ld.lld -m elf32lriscv -e _start main.o && \

qemu-riscv32 a.out
