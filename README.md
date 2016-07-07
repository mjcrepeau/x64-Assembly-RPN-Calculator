## x86_64-Assembly-RPN-Calculator
This is a simple RPN (postfix) calculator to compute expressions in the command line.

This is a project using AT&T syntax x86_64 assembly. It was written and compiled on a 64-bit Debian machine, and should work well on pretty much any 64-bit x86 linux distribution.

## Compilation
You should be able to compile on any 64-bit Intel linux machine with the following commands:
'as rpn.asm -o rpn.o'
'ld rpn.o -o rpn'

## Usage
To compute the result of '3 4 +', at a terminal type:
'./rpn 3 4 +'
