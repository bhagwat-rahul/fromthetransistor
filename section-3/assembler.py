# This is a 64 bit risc-v assembler
def main():
  while 1:
    print("Enter a risc-v assembly instruction\n")
    instruction = input()
    encode_instruction(instruction)

# R (register-register ALU instructions), I (ALU immediate instructions, load instructions), S (store instructions, comparison and branch instructions), B (branch instructions), U (jump instructions, jump and link instructions), and J (jump instructions)

R_instr = []
I_instr = []
S_instr = []
B_instr = []
SB_instr = []
U_instr = []
J_instr = []
UJ_instr = []

def encode_instruction(instruction: str):
  if instruction in (R_instr):
    print("register")
  elif instruction in (I_instr):
    print("immediate")
  elif instruction in (S_instr):
    print("store")
  elif instruction in (B_instr):
    print("branch")
  elif instruction in (U_instr):
    print("jump-link")
  elif instruction in (B_instr):
    print("jump")
  else:
    print("invalid risc-v assembly")

if __name__ == "__main__":
    main()
