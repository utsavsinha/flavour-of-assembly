# This assignment belongs to 12775 and 12157, Group 16

.text
        .globl main

main:
		la $s0, heap        # initialize the heap pointer, $s0
        li  $s1, 0          # initialize the top of the list, $s1
        la $s2, tree		# initialize the tree pointer, $s0
		li $s3, 0			# initialize the top of the list, $s3

#  Read the numbers and push then into the list

		li $v0, 4
        la $a0, ask
        syscall             # Ask for a number
        li $v0, 5
        syscall             # Read an integer in $v0
        lw $t0, endmark
		beq $v0, $t0, exit	# to handle the case when 1st input is itself 0
		j loop1_c
		
loop1:  li $v0, 4
        la $a0, ask
        syscall             # Ask for a number
        li $v0, 5
        syscall             # Read an integer in $v0
loop1_c:
        lw $t0, endmark
        beq $v0, $t0, initialize  # if $v0 = endmark then exit loop
        move $a0, $v0       # $a0 is the argument of push
        jal push            # push $v0 into the list
       # jal print           # print the current list
        b loop1

initialize:
		move $t0, $s1
		lw $a0, 0($t0)     # load the data field
		move $t6, $a0      # $t6 stores previous value
		jal push2		   # push $a0 into the list
		lw $t0, 4($t0)
		li $t7, 1	
		
manipulate:
		
		beq $t0, $0, ret2
		lw $a0, 0($t0)     # load the data field
		move $t5, $a0	   # $t5 tempoarily stores new loaded value
		move $a0, $t7
		bne $t6, $t5, push2counter
here:	
		lw $t0, 4($t0)    # increasing counter in heap
		move $t6, $t5     # $t6 stores previous value
		addi $t7, $t7, 1
		b manipulate

push2counter:
		move $t9, $ra
		jal push2
		li $t7, 0
		move $a0, $t5
		jal push2
		add $t7, $t7, $0
		move $ra, $t9
		#jr $ra
		j here
		
push2:  sub $sp, $sp, 4
        sw $ra, 0($sp)     # save the return address into stack
        move $t3, $a0      # save the argument in $t3

        li $a0, 8          # a list element occupies 8 bytes
        jal new2            # allocate a block of 8 bytes, $v0 will point to the block

        sw $t3, 0($v0)     # fill the data field
        sw $s3, 4($v0)     # fill the link field
        move $s3, $v0      # update the top of the list

        lw $ra, 0($sp)
        addi $sp, $sp, 4   # restore the return address from stack

        jr $ra             # return

new2:   move $v0, $s2      # $v0 points to the top of the heap
        add $s2, $s2, $a0  # move the top $a0 bytes up
        jr $ra             # return		
		
print2:  sub $sp, $sp, 4
        sw $ra, 0($sp)     # save the return address into stack

        move $t0, $s3      # $t0 points to the top of the list
loop3:  beq $t0, $0, exit   # the link field = 0 => end of the list
        lw $a0, 0($t0)     # load the data field
        li $v0, 1
        syscall            # print the data
        la $a0, blank
        li $v0, 4
        syscall            # print a blank line
        lw $t0, 4($t0)     # $t0 points to the next element
        b loop3

ret2:    
		move $a0, $t7
		jal push2
		j print2
	#	la $a0, nl
      #  li $v0, 4
     #   syscall            # print a new line
      #  lw $ra, 0($sp)
     #   addi $sp, $sp, 4   # restore the return address from stack
      #  j exit             # return

		
exit:  # Print the good bye message

        li $v0, 4
        la $a0, bye        # Print the message
        syscall
        li $v0, 5
        syscall            # wait for Enter
        li $v0, 10
        syscall            # end of program

#------------------------------------------------------------------
# print - print the linked list ($s1 points to the top of the list)
#------------------------------------------------------------------
print:  sub $sp, $sp, 4
        sw $ra, 0($sp)     # save the return address into stack

        move $t0, $s1      # $t0 points to the top of the list
loop2:  beq $t0, $0, ret   # the link field = 0 => end of the list
        lw $a0, 0($t0)     # load the data field
        li $v0, 1
        syscall            # print the data
        la $a0, blank
        li $v0, 4
        syscall            # print a blank line
        lw $t0, 4($t0)     # $t0 points to the next element
        b loop2

ret:    la $a0, nl
        li $v0, 4
        syscall            # print a new line

        lw $ra, 0($sp)
        addi $sp, $sp, 4   # restore the return address from stack

        jr $ra             # return

#------------------------------------------------------------------
# push - add an element at the top of the list
#   Input:  $a0 - the element
#   Output: none
#------------------------------------------------------------------
push:   sub $sp, $sp, 4
        sw $ra, 0($sp)     # save the return address into stack
        move $t0, $a0      # save the argument in $t0

        li $a0, 8          # a list element occupies 8 bytes
        jal new            # allocate a block of 8 bytes, $v0 will point to the block

        sw $t0, 0($v0)     # fill the data field
        sw $s1, 4($v0)     # fill the link field
        move $s1, $v0      # update the top of the list

        lw $ra, 0($sp)
        addi $sp, $sp, 4   # restore the return address from stack

        jr $ra             # return

#------------------------------------------------------------------
# new - a procedure to allocate memory
#   Input:  $a0 - the number of bytes to allocate
#   Output: $v0 - the address of the first byte
#------------------------------------------------------------------
new:    move $v0, $s0      # $v0 points to the top of the heap
        add $s0, $s0, $a0  # move the top $a0 bytes up
        jr $ra             # return

#------------------------------------------------------------------
        .data
heap:    .space 10000
tree:    .space 20000
ask:     .asciiz "Enter an integer (0 for exit): "
endmark: .word 0
bye:     .asciiz "\nPress enter to exit..."
blank:   .asciiz " "
nl:      .asciiz "\n" 












