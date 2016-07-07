## x86_64-Assembly-RPN-Calculator
This is a simple RPN (postfix) calculator to compute expressions at the command line.

This is a project using AT&T syntax x86_64 assembly. It was written and compiled on a 64-bit Debian machine, and should work well on pretty much any 64-bit x86 linux distribution.

## Compilation
You should be able to compile on any 64-bit Linux Intel machine with the following commands:

1. `as rpn.asm -o rpn.o`
2. `ld rpn.o -o rpn`

## Usage
To compute the result of '3 4 +', at a terminal type:
`./rpn 3 4 +`

The current operations are supported: addition (+), subtraction (-), multiplication (x), and division (/).

NOTE: The multiplication symbol is not an asterisk (*), as that is the wildcard character.
