## x86_64-Assembly-RPN-Calculator
This is a simple RPN (postfix) calculator to compute expressions at the command line.

This project uses AT&T syntax x64 assembly.

## Compilation
You should be able to compile on any x64 Linux machine with the following commands:

1. `as rpn.asm -o rpn.o`
2. `ld rpn.o -o rpn`

## Usage
To compute the result of '3 4 +', at a terminal type:
`./rpn 3 4 +`

The current operations are supported: addition (+), subtraction (-), multiplication (x), and division (/).

NOTE: The multiplication symbol is not an asterisk (*), as that is the wildcard character.

## Bugs
Currently itoa converts the int into a string that is backwards... I am currently working on a new method of writing the string backwards to fix this.
