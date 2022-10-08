.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:
	# 三不知:
	# 1)dot原理还未完全理解。
	# 2)移位
	# 3)考虑寄存器(value)的变化

	# Error checks
    li t0, 1
    blt a1, t0, exception
    blt a2, t0, exception
    blt a4, t0, exception
    blt a5, t0, exception
    bne a2, a4, exception

	# Prologue
    addi sp, sp, -32
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw ra, 28(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    mv s4, a4
    mv s5, a5
    mv s6, a6
    li t0, 0     # set t0 as row index
    li t1, 0     # set t1 as column index
    
outer_loop_start:
    li t1, 0 # ???

inner_loop_start:
    mul t2, t0, s2    # set t2 as the start index of t0 th row in m0
    slli t2, t2, 2
    add a0, t2, s0 # 3个一起，记住地址。重点：下个回合，从哪个地址开始呀？

    slli t3, t1, 2
    add a1, t3, s3 # 间隔，记住地址。(要搞好几次呢！)
    mv a2, s2
    li a3, 1 # a1's stride
    mv a4, s5 # a3's stride
    
    # save size, 不然就给糟蹋了。
    addi sp, sp, -8
    sw t0, 0(sp)
    sw t1, 4(sp)
    
    jal dot # 小心寄存器的变化。
    
    lw t0, 0(sp)
    lw t1, 4(sp)
    addi sp, sp, 8


    mul t2, t0, s5
    add t2, t2, t1
    slli t2, t2, 2
    add t2, t2, s6
    sw a0, 0(t2) # 把东西放在准确的位置。
    
    addi t1, t1, 1
    bne t1, s5, inner_loop_start

inner_loop_end:
    addi t0, t0, 1
    bne t0, s1, outer_loop_start

outer_loop_end:

	# Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32

	ret

exception:
    li a0, 38
    j exit
