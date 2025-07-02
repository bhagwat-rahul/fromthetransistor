# Notes from reading the risc v ratified spec

RISC-V has been designed to support a variety of things:-
1. not arch specific so it can supp fpga, asic, simulation whatever impl types
2. can integrate with any other risc v or non risc v hw (io, compute, mem, accel's, et.)
3. both 32 - 64 bit w variable length instr optional
4. fully virtualisable for hypervisor dev
5. easy to experiment with diff privilege arch designs.

# Some terminology

a *core* is defined as anything containing it's own ifetch unit.

each core could support multiple *harts* (hardware threads) through multi threading.

*coprocessor* is anything attached to a core sequenced w riscv ins streams but can have additional state, extensions etc.

*accelerator* is non programmable fixed function unit w specialised exclusions

# behavior

Behavior of riscv programs depends on eei (exec env interface):-
defines no of harts, init state of harts, priv modes, what is impl in sw and what in hw

*bare metal* is where harts are directly in hw and instr's have access to direct addr space. an exec env beginning on power on reset.

*risc v os* systems to provide multiple user level exec env's multiplexing user-level harts onto physical threads and controlling acc via virt memory.

*risc v hypervisors* multiple supervisor level exec envs for guest os's

*emulators* emulate hart on underlying system.

4 base isa's technically riscv is a family of isa's:-
1. RV32I - 32 bit int
2. RV64I - 64 bit int
3. RV32E - subset of rv32I (half amt of regs, for microcontrollers)
4. RV64E - subset of rv64I (half amt of regs, for microcontrollers)
if needed new rv128i can be made for larger addr space
base sets represent signed ints w 2's complements representation.

rv32i has 40 instructions, and can emulate any extension except A (additional hw needed for atomicity)
(also if using machine-mode privileged arch you need the 6 csr instructions)
