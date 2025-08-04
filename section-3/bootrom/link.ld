OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
  RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 0x1000   /* 4KiB RAM */
}

SECTIONS
{
  .text :
  {
    *(.text*)
  } > RAM

  . = ORIGIN(RAM) + LENGTH(RAM);
  __stack_top = .;
}
