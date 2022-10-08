.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
	# start
	addi sp, sp, -36
	sw s0, 0(sp) # a0
	sw s1, 4(sp) # a1
	sw s2, 8(sp) # a2
	sw s3, 12(sp) # m0
	sw s4, 16(sp) # m1
	sw s5, 20(sp) # input
	sw s6, 24(sp) # h
	sw s7, 28(sp) # o
	sw ra, 32(sp) # 如果函数调用完成，储存ra.

	# save the arguments
	mv s0, a0
	mv s1, a1
	mv s2, a2 

	# Read pretrained m0
	addi sp, sp, -8 # 重点啊！！！—— ra 在必须在地址的最上方。
	lw a0, 4(s1) # a[1]
	mv a1, sp # sp 指向第一个值，即row
	addi a2, sp, 4 # col
	# add a1, t1, x0 # row* ???
	# add a2, t2, x0 # col*
	jal read_matrix
	mv s3, a0

	# Read pretrained m1
	addi sp, sp, -8
	lw a0, 8(s1)
	mv a1, sp
	addi a2, sp, 4
	jal read_matrix
	mv s4, a0

	# Read input matrix
	addi sp, sp, -8
	lw a0, 12(s1)
	mv a1, sp
	addi a2, sp, 4
	jal read_matrix
	mv s5, a0

	# Compute h = matmul(m0, input)
	# malloc space for matrix h stored in s6
	lw t0, 16(sp) # m0's row
	lw t1, 4(sp) # input's col
	mul a0, t0, t1
	slli a0, a0, 2
	jal malloc
	beq a0, zero, mallocError
	mv s6, a0
	# h = matmul(m0, input)
	mv a0, s3
	lw a1, 16(sp) # 注：stack??? 先进后出？
	lw a2, 20(sp)
	mv a3, s5
	lw a4, 0(sp)
	lw a5, 4(sp)
	mv a6, s6
	jal matmul
	
	# Compute h = relu(h)
	mv a0, s6
	lw t0, 16(sp) # row
	lw t1, 4(sp) # col
	mul a1, t0, t1 # 数组中的整数个数。  您可以假设此参数与整数数组的实际长度匹配。
	jal relu

	# Compute o = matmul(m1, h)
	# malloc space for matrix o stored in s7
	lw t0, 8(sp)
	lw t1, 4(sp)
	mul a0, t0, t1
	slli a0, a0, 2
	jal malloc
	beq a0, zero, mallocError
	mv s7, a0
	# call matmul
	mv a0, s4
	lw a1, 8(sp)
	lw a2, 12(sp)
	mv a3, s6
	lw a4, 16(sp)
	lw a5, 4(sp)
	mv a6, s7
	jal matmul

	# Write output matrix o
	lw a0, 16(s1)
	mv a1, s7
	lw a2, 8(sp)
	lw a3, 4(sp)
	jal write_matrix

	# Compute and return argmax(o)
	mv a0, s7
	lw t0, 8(sp)
	lw t1, 4(sp)
	mul a1, t0, t1
	jal argmax
	mv s0, a0 

	# If enabled, print argmax(o) and newline
	bne a2, zero, skip_print
	jal print_int
	li a0, '\n'
	jal print_char

skip_print:
	# free all the spece on the heap.
	mv a0, s3
	jal free
	mv a0, s4
	jal free
	mv a0, s5
	jal free
	mv a0, s6
	jal free
	mv a0, s7
	jal free

	# epilogue
	mv a0, s0

	addi sp, sp, 24
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw s2, 8(sp)
	lw s3, 12(sp)
	lw s4, 16(sp)
	lw s5, 20(sp)
	lw s6, 24(sp)
	lw s7, 28(sp)
	lw ra, 32(sp)
	addi sp, sp, 36

	ret

mallocError:
	li a0, 26
	j exit
 
command_error:
	li a0, 31
	j exit