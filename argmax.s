.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
	addi t0, x0, 1
	bge a1, t0, Prologue
	li a0, 36
	j exit

Prologue:
	addi sp, sp, -12
	sw s0, 0(sp) # a0 
	sw s1, 4(sp) # array1
	sw s2, 8(sp) # array2
	# sw ra, 12(sp)
	add t0, x0, x0 # size = 0
	# 0th item is s2, t2 is index;——对指针的了解,对比relu.s(默认size(a0)从1开始) and argmax.s(size 从零开始);
	lw s2, 0(a0)
	add t2, x0, x0 # index


loop_start:
	# stop the loop when the counter equals the size
	beq t0, a1, loop_end
	mv s0, a0 # Pointer a0's address
	# get  the address offset
	slli t1, t0, 2
	add s0, s0, t1 # save address
	lw s1, 0(s0) # load world

	# conditional:compare
	bge s2, s1, loop_continue
	# 中间体
	add s2, s1, x0 # s2 = s1; ---max = s1;
	add t2, t0, x0 # save index.



loop_continue: 
	addi t0, t0, 1
	j loop_start


loop_end:
	# Epilogue
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw s2, 8(sp)
	# lw ra, 12(sp)
	addi sp, sp, 12
	add a0, t2, x0
	ret

