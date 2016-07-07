# Matthew Crepeau

# Compile with:
# as -gen-debug rpn.asm -o rpn.o
# ld rpn.o -o rpn

#Simple rpn calculator

# Registers in use:
# r13 - holds argc
# r14 - holds number of processed command line args
# r15 - holds number of values on the result stack

.section .data
err_msg:
	.asciz "There was an error.\n"

output:
	.space 32, 0x0

.section .text
.global _start
_start:
	mov (%rsp), %r13	# The first thing on the stack is the number of command line args
	sub $1, %r13		# Don't count argv[0] (the program name)

	# Prologue
	pushq %rbp
	mov %rsp, %rbp		# Save rsp for future use

	# Keep track of processed arguments
	mov $0, %r14

	# Keep track of the current number of result values on the stack
	mov $0, %r15

read_token:
	# If we have processed all arguments, the stack should have the answer
	cmp %r14, %r13
	je result

	# Calculate the next argument's address
	movq $3, %rax	# Skip rbp, argc, argv[0] on the stack
	add %r14, %rax	# Skip processed arguments

	# Move the next argument into rax for evaluation
	mov (%rbp, %rax, 8), %rax

	# Increment since we are processing the argument
	add $1, %r14

	# First, check if it is an operator (+, -, x, /)
	mov %rax, %rdi	# In preparation for a possible atoi call
	xor %rax, %rax
	movb (%rdi), %al

	cmpb $0x2b, %al
	je addition

	cmpb $0x2d, %al
	je subtract

	cmpb $0x78, %al
	je multiply

	cmpb $0x2f, %al
	je divide

	# Otherwise, assume it is a value so convert to int, push it onto the stack, and start over
	call atoi
	pushq %rax
	add $1, %r15
	jmp read_token

atoi:
	movq $0, %rax	# Will hold the return value
	mov $10, %rcx 	# Will hold the multiplier (10, since we're using decimal)

atoi_loop:
	movb (%rdi), %bl	# Move a byte from the string into bl
	cmpb $0x00, %bl		# Check for null byte (end of string)
	je atoi_ret		# Return if end of string
	sub $48, %bl		# Subtract 48 to go from ascii value to decimal
	imul %rcx, %rax		# Multiply previous number by the multiplier
	add %rbx, %rax		# Add new decimal part to previous number
	inc %rdi		# Increment the address (move forward one byte in the string)
	jmp atoi_loop

atoi_ret:
	ret

addition:
	# All operators require 2 arguments
	cmp $2, %r15
	jl error

	# Pop the two args, convert to int, and do the math with them
	pop %r8
	pop %r9
	add %r8, %r9

	# Push the result, subtract 1 from result stack count
	push %r9
	sub $1, %r15
	jmp read_token

subtract:
	# All operators require 2 arguments
	cmp $2, %r15
	jl error

	# Pop the two args and do the math with them
	pop %r8
	pop %r9
	sub %r8, %r9

	# Push the result, subtract 1 from result stack count
	push %r9
	sub $1, %r15
	jmp read_token

multiply:
	# All operators require 2 arguments
	cmp $2, %r15
	jl error

	# Pop the two args and do the math with them
	pop %r8
	pop %r9
	imul %r8, %r9

	# Push the result, subtract 1 from result stack count
	push %r9
	sub $1, %r15
	jmp read_token

divide:
	# All operators require 2 arguments
	cmp $2, %r15
	jl error

	# Pop the two args and do the math with them
	pop %r8
	pop %rax
	xor %rdx, %rdx
	idiv %r8	# Take rax, divide by r8, and store the quotient in rax and remainder in rdx

	# Push the result, subtract 1 from result stack count
	push %rax
	sub $1, %r15
	jmp read_token

result:
	# There should only be one value on the stack!
	cmp $1, %r15
	jne error

	pop %rdi
	call itoa

	mov %rax, %rdx		# rax contains the length
	mov $1, %rax		# Syscall for write (man 2 write)
	mov $1, %rdi		# Write to stdout
	mov $output, %rsi	# Use the buffer
	syscall

	# Exit

	# epilogue
        movq %rbp, %rsp
        popq %rbp
	
	mov $60, %rax
	syscall

itoa:
	mov $output, %r8	# Buffer
	mov $10, %r9		# Base (we're usign decimal)
	mov %rdi, %rax		# Number to convert -> rax
	mov $0, %r10		# Length of new string, to be incremented

	# Add a '-' if it's negative
	cmp $0, %rax
	jl write_neg

write_num:
	xor %rdx, %rdx		# Clear for division
	idiv %r9		# Divide the number by 10
	add $48, %rdx		# Add 48 to remainder to convert to ascii
	movb %dl, (%r8)		# Move the converted byte to the buffer
	inc %r8			# Increment the buffer pointer
	add $1, %r10		# Increment the length
	cmp $0, %rax		# If the quotient is 0, we're done
	je write_end
	jmp write_num

write_neg:
	movb $0x2d, (%r8)	# Write a '-' to the buffer
	inc %r8
	add $1, %r10
	imul $-1, %rax		# Make the number positive now and convert to ascii
	jmp write_num

write_end:
	movb $0x0a, (%r8)	# Write a newline
	inc %r8
	add $1, %r10
	movb $0, (%r8)		# Write a null byte
	inc %r8
	mov %r10, %rax
	ret

error:
	# Print the error message by calling write (man 2 write)
	mov $1, %rax
	mov $1, %rdi
	mov $err_msg, %rsi
	mov $20, %rdx
	syscall
	mov $60, %rax
	syscall
