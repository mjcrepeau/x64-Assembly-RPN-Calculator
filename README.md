## x64-Assembly-RPN-Calculator
This is a simple RPN (postfix) calculator to compute expressions at the command line.

This project uses AT&T syntax x64 assembly.

## Compilation
You should be able to compile on any x64 Linux machine with the following commands:

1. `as rpn.asm -o rpn.o`
2. `ld rpn.o -o rpn`

## Usage
To compute the result of '3 4 +', at a terminal type:
`./rpn 3 4 +`

To input a negative number, for example to compute '12 -2 x', type:
`./rpn 12 2- x`

The current operations are supported: addition (+), subtraction (-), multiplication (x), and division (/).

NOTE: The multiplication symbol is not an asterisk (*), as that is the wildcard character.

## Other Details
The code is thoroughly commented (probably too thorough in some cases) so that anyone with basic assembly knowledge can follow along.

Because this is a simple implementation, it only works with integers, and thus performs integer division.

## Bugs/Issues
None that I know of...

## Resources
Here are some websites I used that helped with this project.

https://software.intel.com/en-us/articles/introduction-to-x64-assembly

http://eli.thegreenplace.net/2013/07/24/displaying-all-argv-in-x64-assembly

http://www.jegerlehner.ch/intel/IntelCodeTable.pdf

http://0xax.blogspot.com/2014/09/say-hello-to-x64-assembly-part-3.html
