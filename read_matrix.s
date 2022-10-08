.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
#     以读取权限打开文件。  文件路径作为参数 (a0) 提供。
#
# 1.从文件中读取行数和列数（记住：这是文件中的前两个整数）。 fopen 打开文件进行读取或写入。
# 2.将这些整数存储在内存中提供的指针处（a1 表示行，a2 表示列）。fread 从文件中读取字节到内存中的缓冲区。 后续读取将从文件的后面部分读取。
#
# 3.在堆上分配空间来存储矩阵。  （提示：使用上一步中的行数和列数来确定要分配多少空间。）
#
# 4.从文件中读取矩阵到上一步分配的内存中。
#
# 5.关闭文件。
#
# 6.返回指向内存中矩阵的指针。
# ==============================================================================
read_matrix:

	# Prologue

	addi sp, sp, -24
	sw s0, 0(sp)
	sw s1, 4(sp)
	sw s2, 8(sp)
	sw s3, 12(sp) # 文件描述符
	sw s4, 16(sp) # matrix's size
	sw ra, 20(sp) # matrix

	# store a1,a2
	
	add s1, a1, x0 # Pointer to row.
	add s2, a2, x0 # Pointre to col.

	addi a1, x0, 0 
	jal fopen

	mv s3, a0 # 文件描述符
	addi t0, x0, -1
	beq a0, t0, fopenError # if a0 = -1,error



	add a1, s1, x0 
	addi a2, x0, 4
	jal fread # 从文件中读取行数.
	addi t0, x0, 4
	bne a0, t0, freadError

	mv a0, s3
	mv a1, s2
	addi a2, x0, 4
	jal fread # 从文件中读取列数.
	addi t0, x0, 4
	bne a0, t0, freadError	

	# allocate space on the heap to store the matrix
	lw t0, 0(s1) # 取值
	lw t1, 0(s2)
	mul s4, t0, t1
	slli s4, s4, 2 # s4 = 3*3*4

	mv a0, s4
	# malloc(row*col)
	jal malloc
	beq a0, zero, mallocError
	
	mv s0, a0


	# read the matrix
	mv a0, s3
	mv a1, s0
	mv a2, s4
	jal fread
	bne a0, s4, freadError

	# fclose;
	add a0, x0, s3
	jal fclose
	addi t0, x0, -1
	beq a0, t0, fcloseError



	# Epilogue
	mv a0, s0

	lw s0, 0(sp)
	lw s1, 4(sp)
	lw s2, 8(sp)
	lw s3, 12(sp) # 文件描述符
	lw s4, 16(sp) # matrix's size
	lw ra, 20(sp) # matrix
	addi sp, sp, 24

	ret

mallocError:
	li a0, 26
	j exit
fopenError:
	li a0, 27
	j exit
fcloseError:
	li a0, 28
	j exit
freadError:
	li a0, 29
	j exit