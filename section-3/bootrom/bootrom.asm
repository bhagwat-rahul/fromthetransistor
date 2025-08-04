    .section .text
    .globl _start
_start:
    la sp, __stack_top       # Load stack pointer w highest ram addr
    j 0x80001000
hang:
    j   hang                # Infinite loop fallback
