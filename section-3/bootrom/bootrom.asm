.section .text
.globl _start

_start:
  li t0, 42         # Load 42 into register t0
  li t1, 23         # Load 23 into register t1
  add t2, t0, t1    # t2 = t0 + t1 (t2 will hold 65)

inf_loop:
  j inf_loop        # Infinite loop
