.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:

	# Prologue
	addi sp, sp, -20
	sw s0, 0(sp) 
	sw s1, 4(sp) # 指向内存中矩阵的指针（存储为整数数组）
	sw s2, 8(sp) # row
	sw s3, 12(sp) # col
	sw ra, 16(sp) # ???文件描述符

	# store a1, a2
	mv s1, a1 
	mv s2, a2
	mv s3, a3

	addi a1, x0, 1
	jal fopen
 
	addi t0, x0, -1
	beq a0, t0, fopenError
	mv s0, a0 # 文件描述符。

	# write row
	mv a0, s0
	addi sp, sp, -4
	sw s2, 0(sp)
	mv a1, sp # ???
	addi a2, x0, 1
	addi a3, x0, 4

	jal fwrite
	addi sp, sp, 4 # lw 呢？
	addi t0, x0, 1
	bne a0, t0, fwriteError

	# write col
	mv a0, s0
	addi sp, sp, -4
	sw s3, 0(sp)

	mv a1, sp # col
	addi a2, x0, 1
	addi a3, x0, 4

	jal fwrite
	addi sp, sp, 4
	addi t0, x0, 1 # 一调用 jal，a0,a1,a2...临时变量发生改变。
	bne a0, t0, fwriteError

	# write matrix
	mv a0, s0
	mv a1, s1
	mul a2, s2, s3 
	addi a3, x0, 4
	jal fwrite
	mul t0, s2, s3
	bne a0, t0, fwriteError

	# close File
	mv a0, s0
	jal fclose
	addi t0, x0, -1
	beq a0, t0, fcloseError

	# Epilogue
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw s2, 8(sp)
	lw s3, 12(sp)
	lw ra, 16(sp) # 在这ra干嘛的？
	addi sp, sp, 20
	
	ret

fopenError:
	li a0, 27
	j exit

fwriteError:
	li a0, 30
	j exit

fcloseError:
	li a0, 28
	j exit