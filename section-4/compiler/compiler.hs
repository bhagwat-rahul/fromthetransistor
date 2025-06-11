-- This is a 64 bit risc-v c compiler
main = putStrLn "Hello, World! I am a riscv-64 compiler!"

keywords = ["return", "if", "while", "for", "switch", "typedef", "sizeof", "else", "do", "break", "continue"]

datatypes = ["int", "void", "char", "bool", "float", "double", "short", "long", "struct", "union", "enum"]

-- Operators in order of descending C precedence
operators = ["!", "~", "*", "/", "%", "+", "-", "<", "<=", ">", ">=", "==", "!=", "&", "^", "|", "&&", "||", "="]

punctuation = ["{", "}", "(", ")", ",", ";", ":"]

directives = ["#include", "#define", "#ifdef", "#ifndef", "#endif", "#undef", "#pragma"]
