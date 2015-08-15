# GoldBach.asm

# This assignment belongs to 12775 and 12157, Group 16

.text
.globl main
main:

la $a0, query_msg   # read the number
li $v0, 4
syscall # now read the input
li $v0, 5
syscall # and store in $t0
move $t0, $v0 
move $t2, $t0
sub $t2, $t2, 1     # $t2 is n-1 initially
li $t1, 1			# $t2's complement with n


move $a0, $t0  # load n in argument to the function
jal goldbach # result in $v0, copy to $t1
move $t1, $v0

b done

goldbach:
move $s1, $t1		# $s1 and $s2 stores the partition to be tested
move $s2, $t2

move $a0, $t1
li $t6, 2			# $t6 stores the start of the prime testing counter
jal prime
move $t3, $v0		# $t3 now stores whether $t1 is a prime

move $a0, $t2
li $t6, 2
jal prime
move $t4, $v0       # $t4 now stores whether $t2 is a prime

and $t9, $t3, $t4	# $t9 stores whether both of $t1 and $t2 are prime
move $t3, $t9
bnez $t3, done

sub $t2, $t2, 2		# regulating the partition of n 
add $t1, $t1, 2

b goldbach

prime: 
move $t5, $a0
sub $t8, $t6, $t5  #special check for positive $t8 in case we check primarilty of 1 which is true
bgez $t8, prime_true		
div $t5, $t6
mfhi $t7
beqz $t7, prime_false 	# if remainder in $t7 is 0, we do not have argument as prime
addi $t6, $t6, 1
b prime

prime_false:
li $v0, 0
jr $ra

prime_true:
li $v0, 1
jr $ra

   

done: # print the result
la $a0, result_msg
li $v0, 4
syscall # then the value

move $a0, $s1
li $v0, 1
syscall

la $a0, space_msg
li $v0, 4
syscall

move $a0, $s2
li $v0, 1
syscall

# then newline
la $a0, nl_msg
li $v0, 4
syscall
# exit
li $v0, 10
syscall

.data
query_msg: .asciiz "Input ? "
result_msg: .asciiz "GoldBach partition is "
nl_msg: .asciiz "\n"
space_msg: .asciiz " "