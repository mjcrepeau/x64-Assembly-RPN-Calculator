# Matthew Crepeau

# Compile with:
# as -gen-debug rpn.asm -o rpn.o
# ld rpn.o -o rpn

# Simple rpn calculator

# Registers in use:
# r13 - holds argc
# r14 - holds number of processed command line args
# r15 - holds number of values on the result stack

.section .data
err_msg:
	.asciz "There was an error.\n"

output:
	.space 32, 0x0		# Create an empty buffer, 32 bytes (the result will always fit in this)

.section .text
.global _start
_start:
	mov (%rsp), %r13	# The first thing on the stack is argc, save it
	sub $1, %r13		# Don't count argv[0] (the program name)

	push %rbp		# Save rbp, as is convention
	mov %rsp, %rbp		# Save rsp for future use, rsp will change as we push/pop

	mov $0, %r14		# Keep track of processed arguments

	mov $0, %r15		# Keep track of the current number of result values on the stack

read_token:
	# If we have processed all arguments, the stack should have the answer
	cmp %r14, %r13
	je result

	# Calculate the next argument's address
	movq $3, %rax		# Skip rbp, argc, argv[0] on the stack
	add %r14, %rax		# Skip processed arguments

	# Move the next argument into rax for evaluation
	mov (%rbp, %rax, 8), %rax

	# Increment since we are processing the argument
	add $1, %r14

	# First, check if it is an operator (+, -, x, /)
	mov %rax, %rdi		# In preparation for a possible atoi call
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
	movq $0, %rax		# Will hold the return value
	mov $10, %rcx 		# Will hold the multiplier (10, since we're using decimal)

atoi_loop:
	movb (%rdi), %bl	# Move a byte from the string into bl

	cmpb $0x00, %bl		# Check for null byte (end of string)
	je atoi_ret		# Return if end of string

	cmpb $0x2d, %bl		# Check for negative number (i.e. -2 must be entered 2-)
	je atoi_isneg

	sub $48, %bl		# Subtract 48 to go from ascii value to decimal
	imul %rcx, %rax		# Multiply previous number by the multiplier
	add %rbx, %rax		# Add new decimal part to previous number
	inc %rdi		# Increment the address (move forward one byte in the string)
	jmp atoi_loop

atoi_ret:
	ret

atoi_isneg:
	imul $-1, %rax		# Make it negative
	inc %rdi		# Prevents a weird bug that prints a comma; not sure why this happens
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
	idiv %r8		# Take rax, divide by r8, and store the quotient in rax and remainder in rdx

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

	mov %rax, %rsi		# rax contains the buffer, this is for the call to write
	mov %rax, %rdi		# This is for the call to strlen

	call strlen

	mov %rax, %rdx		# rax now contains the length of the buffer
	mov $1, %rax		# Syscall for write (man 2 write)
	mov $1, %rdi		# Write to stdout
	#mov $output, %rsi	# Use the buffer
	syscall

# Exit
	# epilogue
        movq %rbp, %rsp
        popq %rbp

	mov $60, %rax
	syscall

itoa:
	mov $output, %r8	# Buffer
	add $30, %r8		# Move to almost the end, leaving a null byte
	movb $0x0a, (%r8)	# Write newline
	dec %r8			# Decrement buffer

	mov $10, %r9		# Base (we're usign decimal)
	mov %rdi, %rax		# Number to convert -> rax

	# We need to write a '-' when we're done
	mov $0, %r10		# Negative marker
	cmp $0, %rax
	jl itoa_isneg

write_num:
	xor %rdx, %rdx		# Clear for division
	idiv %r9		# Divide the number by 10
	add $48, %rdx		# Add 48 to remainder to convert to ascii
	movb %dl, (%r8)		# Move the converted byte to the buffer
	dec %r8			# Decrement the buffer pointer
	cmp $0, %rax		# If the quotient is 0, we're done
	je write_end
	jmp write_num

itoa_isneg:
	mov $1, %r10		# This means later we need to write a '-'
	imul $-1, %rax		# Make the number positive now and convert to ascii
	jmp write_num

write_end:
	cmp $0, %r10
	jne write_neg
	mov %r8, %rax		# Return a pointer to the beginning of the string
	ret

write_neg:
	movb $0x2d, (%r8)	# Write a '-' to the buffer
	mov %r8, %rax		# Return a pointer to the beginning of the string
	ret

strlen:
	mov $0, %rax		# Holds the size, to be incremented
	mov %rdi, %r8		# Holds the buffer

strlen_loop:
	cmp $0, (%r8)		# Check for null byte
	je strlen_end
	inc %r8
	inc %rax
	jmp strlen_loop

strlen_end:
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
