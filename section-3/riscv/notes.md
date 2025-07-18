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

fence instr will help in telling the cache to load / not load certain things (to prevent illegal mem accs)

XLEN is current bit width ILEN is max bitwidth
IALIGN is what bit widths instructions are aligned at
16 bits is halfword, 32 word, 64 double word and 128 quad word

a hart has single byte addressable space of 2^xlen-1 bytes
risc v is primarily little endian but has big end support
expetion is anything unusual interrupt is anything causing a transfer of control in a hart.
in rv32i you have 32 regs with x0 hardwired to 0 + a program counter.
std calling convention dictates x1 to hold ret addr for a call and x5 as alt link reg.
x2 is stack pointer. don't have to be these vals but a lot of sw performs better if so.

except for csr (control status regs) all immediate vals are always sign extended.
sign exists in leftmost bit to keep things simple for hw (b 32 in 32 b reg)

any encoding w ilen bits  = 0 | 1 is illegal so an aligned area cant be all 1s / 0s.
for std instructions sign bit for imm's always in bit 31 for alignment.

nop encoded as ADDI x0, x0, 0. shouldn't change any state except program counter (pc).
(addi chosen as it takes fewest resources and you can also optimize away in id unit)

instr's in rv32i:- (64 is similar just double width where applicable)

2 types of control transfers are unconditional jumps and conditional branches

jal (jump and link):- encodes signed offset (multiples of 2-bytes, sign extended)
therefore can jump +- 1 MiB. stores addr of instr following jump into rd, x1 is return addr reg and x5 is alt link reg (std calling convention)

jalr is an imm (I) instr where target addr is obtained by adding sign extended 12 bit
imm to rs1 then setting lsb of res to 0, addr of following written to rd.
use x0 as dest if result not required.
plain direct jumps (pseudocoded jr) are encoded jalr w rd = x0, eg. RET encoded as jalr:-
with rd = x0, rs1 = x1, and imm = 0.

all unconditional jumps are relative to pc for supporting pos'n independent code.
jalr was defined to enable 2 instr sequence to jmp anywhere in the absolute addr range.
lui can first load rs1 with upper 20 bits and jalr can add in lower bits.
same for auipc + jalr
