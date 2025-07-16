# This is a 64 bit risc-v assembler
def main():
  while 1:
    print("Enter a risc-v assembly instruction\n")
    instruction = input()
    encode_instruction(instruction)

# R (register-register ALU instructions), I (ALU immediate instructions, load instructions), S (store instructions, comparison and branch instructions), B (branch instructions), U (jump instructions, jump and link instructions), and J (jump instructions)

# TODO: The templates are placeholders rn fix with actual vals
instruction_templates = {
    'add': {
        'type': 'R',
        'opcode': 0b0110011,
        'funct3': 0b000,
        'funct7': 0b0000000
    },
    'sub': {
        'type': 'R',
        'opcode': 0b0110011,
        'funct3': 0b000,
        'funct7': 0b0000000
    },
    'xor': {
        'type': 'R',
        'opcode': 0b0110011,
        'funct3': 0b000,
        'funct7': 0b0000000
    },
    'or': {
        'type': 'R',
        'opcode': 0b0110011,
        'funct3': 0b000,
        'funct7': 0b0000000
    },
    'and': {
        'type': 'R',
        'opcode': 0b0110011,
        'funct3': 0b000,
        'funct7': 0b0000000
    },
    'sll': {
        'type': 'R',
        'opcode': 0b0110011,
        'funct3': 0b000,
        'funct7': 0b0000000
    },
    'srl': {
        'type': 'R',
        'opcode': 0b0110011,
        'funct3': 0b000,
        'funct7': 0b0000000
    },
    'sra': {
        'type': 'R',
        'opcode': 0b0110011,
        'funct3': 0b000,
        'funct7': 0b0000000
    },
    'slt': {
        'type': 'R',
        'opcode': 0b0110011,
        'funct3': 0b000,
        'funct7': 0b0000000
    },
    'sltu': {
        'type': 'R',
        'opcode': 0b0110011,
        'funct3': 0b000,
        'funct7': 0b0000000
    },
    'addi': {
        'type': 'I',
        'opcode': 0b0110011,
        'funct3': 0b000,
        'funct7': 0b0000000
    },
    'xori': {
        'type': 'I',
        'opcode': 0b0110011,
        'funct3': 0b000,
        'funct7': 0b0000000
    },
    'ori': {
        'type': 'I',
        'opcode': 0b0110011,
        'funct3': 0b000,
        'funct7': 0b0000000
    },
    'andi': {
        'type': 'I',
        'opcode': 0b0110011,
        'funct3': 0b000,
        'funct7': 0b0000000
    },
    'slli': {
        'type': 'I',
        'opcode': 0b0110011,
        'funct3': 0b000,
        'funct7': 0b0000000
    },
    'srli': {
        'type': 'I',
        'opcode': 0b0110011,
        'funct3': 0b000,
        'funct7': 0b0000000
    },
    'srai': {
        'type': 'I',
        'opcode': 0b0110011,
        'funct3': 0b000,
        'funct7': 0b0000000
    },
    'slti': {
        'type': 'I',
        'opcode': 0b0110011,
        'funct3': 0b000,
        'funct7': 0b0000000
    },
    'sltiu': {
        'type': 'I',
        'opcode': 0b0110011,
        'funct3': 0b000,
        'funct7': 0b0000000
    }
}

def encode_instruction(instruction: str):
  parts = instruction.strip().split()
  opcode = parts[0]
  operands = [op.strip(',') for op in parts[1:]] if len(parts) > 1 else []
  if opcode in instruction_templates:
    print(f"Type {instruction_templates[opcode]['type']}")
  else:
    print("invalid risc-v assembly")

def remove_cmt(source: str) -> str:
    return '\n'.join(line.split('#')[0] for line in source.splitlines())

def clean_whitespace(source:str):
    return '\n'.join(' '.join(line.split()) for line in source.splitlines())

if __name__ == "__main__":
    main()
