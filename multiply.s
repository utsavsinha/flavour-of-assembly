# This assignment belongs to 12775 and 12157, Group 16

# Line 109 can be uncommented to produce intermediate results

.text
        .globl main

main:
		la $s1, first        	 # initialize the first number pointer, $s1
        la $s2, second           # initialize the second number pointer, $s2
        la $s3, temp			 # initialize the temporary product holder pointer, $s3
		la $s4, adding			 # initialize the adding pointer, $s4
		la $t5, pointers		 # initialize the pointers management list, $t5
		
		sw $0, 0($t5)		# storing base addresses of all the lists used in a list denoted by $t5
		sw $s3, 4($t5)		
		sw $s4, 8($t5)		
		sw $s1, 16($t5)
		sw $s2, 20($t5)
		
#  Read the numbers and push then into the list
		
		li $s5, 0
		li $a1, 1				# for push to know that 1st number is being input
		li $s0, 0 				# for top of list to be assigned to zero as we call push for the first number

##### to print a list, move the top pointer of the specific list to $a1 and call jal print ######

#-----------------------------------------------------------------
# Reading the input
#-----------------------------------------------------------------
		li $a3, 2		
loop_first:  
		li $v0, 4
        la $a0, ask1
        syscall             # Ask for a number
        li $v0, 5
        syscall             # Read an integer in $v0
        lw $t0, endmark
        bgt $v0, $t0, loop_first_end  # if $v0 > endmark then exit loop
        move $a0, $v0       # $a0 is the argument of push
		li $a1, 1			
        jal push            # push $v0 into the list         
        b loop_first

loop_first_end:
		li $a1, 2			# for push to know that 2nd number is being input
		move $s6, $s0       # now, $s6 stores the top of the first number's list
		li $s0, 0 			# for top of list to be assigned to zero as we call push for the second number
		
loop_second:  
		li $v0, 4
        la $a0, ask2
        syscall             
        li $v0, 5
        syscall             
        lw $t0, endmark
        bgt $v0, $t0, loop_second_end  
        move $a0, $v0       	# $a0 is the argument of push
		li $a1, 2				# for push to know that 2nd number is being input
        jal push            	# push $v0 into the list          
        b loop_second

loop_second_end:
		move $s7, $s0       # now, $s7 stores the top of the second number's list
		li $s0, 0		
	#	j exit

#--------------------------------------------------------------
# Multiply begins
#--------------------------------------------------------------
	
# temp stores the intermediate product. initializing it to contain all 0 at the start of multiplication #
initialize_temp:
		li $t9, 10000 ###
		li $t4, 0		# pointer to the top of temp list
		li $v1, 0		# pointer to the top of temp list
		
initialize_temp_loop:
		beq $t9, $0, initialize_temp_over
		li $a0, 0
		li $a1, 3		# to recognize that element is being pushed in "temp" list 
		jal push
		addi $t9, $t9, -1
		b initialize_temp_loop

initialize_temp_over:
		move $t4, $s0  # $s0 returns the top of the list in which element was pushd just previously. so $t4 is top of "temp"
		move $v1, $s0  # $v1 will always contain the top pointer of the "temp" list
		
		sw $v1, 24($t5)  # storing the far end of "temp" list
		
		move $t8, $s7								# $t8 now points to the top of the "second" number list

loop_B:
		beq $t8, $0, multiply_over
		lw $a0, 0($t8)							# $a0 stores B[i] with which whole of A(first number) is to be multiplied
		move $t7, $s6							# $t7 would now be used to manipulate "first" number list
		li $a2, 0								# initializing the carry to 0
		j loop_A
	loop_A_back:		
		li $a2, 0			# initializing the carry for "addd"
		move $t2, $s5		#move $t2, $t6		# $t2 has the top pointer of the "adding" list now
		move $t7, $t4		# $t4 contains the "temp" top pointer. $t7 also contains it now
		lw $t9, 8($t5)
		j addd
addd_back:
		
		#la $a0, printing_temp   #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
		#li $v0, 4				#  PRINTING INTERMEDIATE RESULTS IN REVERSED ORDER WITH TRAILING ZERO'S  #
		#syscall				#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
		#move $a1, $v1			#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
		#lw $a2, 4($t5)			#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
		#jal print				#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
		
		move $s0, $s5		#move $s0, $t6		# $s0 should contain the top pointer of the "adding" list to be deallocated
		jal dealloc_adding
		lw $t8, 4($t8)
		b loop_B
		
		j exit 
	
multiply_over:		
		la $a0, multiply_finished
        li $v0, 4
        syscall            # print a new line and final comment
		move $a1, $v1
		lw $a2, 4($t5)
		jal pretty_print
		
		j exit
	
#-----------------------------------------------------------------------------------
# loop A begins
#------------------------------------------------------------------------------------
loop_A:
		beq $t7, $0, digit_mult_over
		lw $t1, 0($t7)
		mult $t1, $a0
		mflo $t3								# $t3 stores $t1*$a0
		add $t3, $t3, $a2						# adding the carry to the multiplication of corresponding digits of A and B
		li $a3, 10
		div $t3, $a3
		
		# now we have to push the remainder in "rev" and qutient as carry for the next operation
		
		mflo $a2								# the quotient in mflo acts as the carry and is stored in $a2
		move $a3, $a0
		mfhi $a0
		li $a1, 4		# for push to identify "rev", $a0 is being pushed, so a copy of B[i] is stored in $a3 temporarily
		jal push
		move $a0, $a3							# restoring B[i] in $a0
		lw $t7, 4($t7)
		b loop_A
		
digit_mult_over:
		li $a1, 4						# for push to identify "rev"
		move $a0, $a2					# pushng the last carry in "rev" list
		jal push
		
		move $s5, $s0					# $s5 stores the top of "rev" list
		j loop_A_back
		
#------------------------------------------------------------------------
# addd: defining the "addd" function that adds temp and adding lists
#--------------------------------------------------------------------------

addd:
		bgt $t9, $t2, addd_return				#beq $t2, $0, addd_return		# $t2 has top pointer of adding list
		lw $t1, 0($t9)				#lw $t1, 0($t2)
		lw $t3, 0($t7)
		
		add $t3, $t3, $t1		# adding corresponding digits of A and b lists
		add $t3, $t3, $a2		# adding the carry
		li $a3, 10
		div $t3, $a3
		mfhi $t3				# store remainder in $t3
		mflo $a2				# the quotient acts as the carry and is stored in $a2 for the next iteration
		sw $t3, 0($t7)			# storing the added value back in temp
		lw $t7, 4($t7)			# moving towards the more significant bits in the "temp" list
		addi $t9, $t9, 8		#lw $t2, 4($t2)			# moving towards the more significant bits in the "adding" list

		b addd
		
addd_return:
		beq $a2, $0, addd_over_finally		# until carry is non-zero, continue to move towards more significant bits of temp
		lw $t3, 0($t7)
		add $t3, $t3, $a2		# adding the carry
		li $a3, 10
		div $t3, $a3
		mfhi $t3				# store remainder in $t3
		mflo $a2				# the quotient acts as the carry and is stored in $a2 for the next iteration
		sw $t3, 0($t7)			# storing the added value back in temp
		lw $t7, 4($t7)			# moving towards the more significant bits in the "temp" list
		b addd_return
		
# now we need to fix the least significant bit of "temp" as it cannot change any longer in the multiplication algorithm. So moving the top pointer of temp, $t4 permanently 4 bytes
addd_over_finally:
		lw $t4, 4($t4)
		j addd_back
		
#------------------------------------------------------------------------------
# dealloc - used to deallocate a list
#		Input: $s0 contains the top pointer of the list to be deallocated
# 		Output: $s0 contains the top pointer of the deallocated list ( which is essentially 0 )
#------------------------------------------------------------------------------

#------------------- dealloc_adding -----------------------------#
dealloc_adding:
		sub $sp, $sp, 4
        sw $ra, 0($sp)     # save the return address into stack
		lw $a2, 8($t5)		# $a2 now stores the base address of "adding" list
		
dealloc_adding_loop:
		blt $s0, $a2, dealloc_adding_over			#beq $s0, $0, dealloc_adding_over
		addi $s4, $s4, -8
		lw $s0, 4($s0)
		b dealloc_adding_loop

dealloc_adding_over:
		li $s5, 0			#li $t6, 0				# top pointer of "adding" is initialized to 0
		lw $ra, 0($sp)
        addi $sp, $sp, 4   		# restore the return address from stack		
        jr $ra             		# return
				
#------------------------------------------------------------------
# exit - exiting the program
#------------------------------------------------------------------
		
exit:  # Print the good bye message
        li $v0, 4
        la $a0, bye        # Print the message
        syscall
        li $v0, 5
        syscall            # wait for Enter
        li $v0, 10
        syscall            # end of program

#------------------------------------------------------------------
# pretty_print: It is used to print the final answer in required order as print alone prints it in reverse order
#------------------------------------------------------------------------

pretty_print:
		sub $sp, $sp, 4
        sw $ra, 0($sp)     # save the return address into stack
		lw $a2, 4($t5)		# the base of the "temp" list
		lw $a1, 0($a2)
		lw $a3, 24($t5)		# stores the far end of "temp" list
		li $t0, 0			# this variable will take care that if one of A or B is 0, then 0 is indeed printed
		
pretty_print_dummy_loop:
		bne $a1, $0, pretty_print_loop
		addi $a2, $a2, 8
		lw $a1, 0($a2)
		b pretty_print_dummy_loop

pretty_print_loop:
		bgt $a2, $a3, pretty_print_over
		lw $a0, 0($a2)     # load the data field
        li $v0, 1
        syscall            # print the data
        la $a0, blank
        li $v0, 4
        syscall            # print a blank 
        addi $a2, $a2, 8		#lw $t0, 4($t0)     # $t0 points to the next element
		addi $t0, $t0, 1
        b pretty_print_loop
		
pretty_print_over:
		beq $t0, $0, print_zero
print_zero_back:
		la $a0, nl
        li $v0, 4
        syscall            # print a new line
		lw $ra, 0($sp)
        addi $sp, $sp, 4   # restore the return address from stack
		
        jr $ra             # return

print_zero:
		li $a0, 0
		li $v0, 1
		syscall
		j print_zero_back		
		
#------------------------------------------------------------------
# print - print the linked list 
#		Input: $a1 points to the top of the list
#				$a2 points to the end of the list
#------------------------------------------------------------------
print:  sub $sp, $sp, 4
        sw $ra, 0($sp)     # save the return address into stack

        move $t0, $a1      # $t0 points to the top of the list
		
loop_print:  
		blt $t0, $a2, print_return		#beq $t0, $0, print_return   # the link field = 0 => end of the list
        lw $a0, 0($t0)     # load the data field
        li $v0, 1
        syscall            # print the data
        la $a0, blank
        li $v0, 4
        syscall            # print a blank 
        lw $t0, 4($t0)		#lw $t0, 4($t0)     # $t0 points to the next element
        b loop_print

print_return:    
		la $a0, nl
        li $v0, 4
        syscall            # print a new line
        lw $ra, 0($sp)
        addi $sp, $sp, 4   # restore the return address from stack
		
        jr $ra             # return
		
#------------------------------------------------------------------
# push - add an element at the top of the list
#   Input:  $a0 - the element
#   		$a1 - the flag for required linked list
#   Output: none
#			$s0 contains top of the list where a number was pushed
#------------------------------------------------------------------
push:   sub $sp, $sp, 4
        sw $ra, 0($sp)     # save the return address into stack
        move $t0, $a0      # save the argument in $t0

        li $a0, 8          	# a list element occupies 8 bytes
		li $t1, 1   		# $a1 = 1 is for first number, 2 is for 2nd no, 3 for temp, 4 for adding and 5 for prod
        beq $a1, $t1, allocate_first
back_first:
		li $t1, 2
		beq $a1, $t1, allocate_second
back_second:
		li $t1, 3
		beq $a1, $t1, allocate_temp
back_temp:
		li $t1, 4
		beq $a1, $t1, allocate_adding
back_adding:
		li $t1, 5
		beq $a1, $t1, allocate_prod
back_prod:
		li $t1, 6
		beq $a1, $t1, allocate_rev
back_all:
	
        sw $t0, 0($v0)     # fill the data field
        sw $s0, 4($v0)     # fill the link field
        move $s0, $v0      # update the top of the list
        lw $ra, 0($sp)
        addi $sp, $sp, 4   # restore the return address from stack

        jr $ra             # return
		
#------------------------------------------------------------------
# allocate_something - a procedure to allocate memory
#   Input:  $a0 - the number of bytes to allocate
#   Output: $v0 - the address of the first byte
#------------------------------------------------------------------

allocate_first:
		move $v0, $s1      # $v0 points to the top of the heap
        add $s1, $s1, $a0  # move the top $a0 bytes up
        j back_first       # return

allocate_second:
		move $v0, $s2      # $v0 points to the top of the heap
        add $s2, $s2, $a0  # move the top $a0 bytes up
        j back_second      # return		
		
allocate_temp:
		move $v0, $s3      # $v0 points to the top of the heap
        add $s3, $s3, $a0  # move the top $a0 bytes up
        j back_temp        # return		
		
allocate_adding:
		move $v0, $s4      # $v0 points to the top of the heap
        add $s4, $s4, $a0  # move the top $a0 bytes up
        j back_adding      # return	
		
allocate_prod:
		move $v0, $s5      # $v0 points to the top of the heap
        add $s5, $s5, $a0  # move the top $a0 bytes up
        j back_prod        # return
		
allocate_rev:
		move $v0, $t9      # $v0 points to the top of the heap
        add $t9, $t9, $a0  # move the top $a0 bytes up
        j back_all         # return

#------------------------------------------------------------------
.data

pointers:	.space 1000
first:		.space 10000
second:		.space 10000
temp:		.space 100000			
adding:		.space 10000
prod:		.space 100000	 
rev: 		.space 10000		
ask1:     	.asciiz "Enter an integer (> 9 for ending 1st no): "
ask2: 		.asciiz "Enter an integer (> 9 for ending 2nd no): "
endmark: .word 9
bye:     .asciiz "\nPress enter to exit..."
blank:   .asciiz " "
nl:      .asciiz "\n" 
iteration1:		.asciiz "1st reverse   "
multiply_finished:		.asciiz "\nMultiplication is over, result is:\n   "
printing_temp:		.asciiz "Printing intermediate product in reversed order with trailing zero's\n   "









