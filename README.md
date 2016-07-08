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

## Other Details
The code is thoroughly commented (probably too thorough in some cases) so that anyone with basic assembly knowledge can follow along.

Since this is a simple implementation, it only works with integers, and thus performs integer division.

## Bugs/Issues
Currently, there is no support for negative input numbers. For example:

`./rpn 3 -7 x` should produce -21, but gives an error.

This is the next improvement I plan to make.
