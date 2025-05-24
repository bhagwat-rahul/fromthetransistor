# This is a 64 bit risc-v assembler
def main():
  print("Enter a risc-v assembly instruction\n")
  while 1:
    instruction = input()
    encode_instruction(instruction) # Add rs1 and rs2 and store result in rd

def encode_instruction(instruction: str):
  if instruction.__contains__("add "):
    print("add")
  elif instruction.__contains__("sub "):
    print("subtract")
  else:
    print("that doesn't look like valid risc-v assembly")

if __name__ == "__main__":
    main()
