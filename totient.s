# Totient.asm

# This assignment belongs to 12775 and 12157, Group 16

.text
.globl main
main:

la $a0, query_msg   # read the number
li $v0, 4
syscall # now read the input
li $v0, 5
syscall # and store in $t0
move $t0, $v0 # store the base value in $t1
move $t1, $t0    # storing a copy of n always in $t1
li $t7, 0     # $t7 stores the answer i.e totient(n)

jal loop # result in $v0, copy to $t1
move $t1, $v0

b done

loop:
blez $t0, done				# the decreasing counter $t0 has become 0, so we are done
move $t2, $t1				# $t2 stores n for gcd purposes
move $t3, $t0	# $t3 stores counter, i.e number less than n whose co-primarility is to be checked
b gcd

gcd:						# finds gcd of x,y where y is $t3 and x is $t2
beqz $t3, gcd_return		# if y is not zero, finr gcd recursively again
move $t4, $t2				# storing a temporary copy of x since x is changed in next line
#move $t5, $t3
move $t2, $t3				# x = y
div $t4, $t3
mfhi $t3					# y = x%y
b gcd

gcd_return:
slti $t8, $t2, 2			# if $t2 < 2, then $t8 = 1 else $t8 = 0 i.e if gcd is < 2, $t8 = 1
bgtz $t8, incrementing		# if $t8 > 0, i.e gcd < 2, then a co-prime counter of n is found
j back

incrementing:
addi $t7, $t7, 1			# incrementing the totient function
j back

back:						# counter is decreased by 1 and the loop is continued
addi $t0, $t0, -1
b loop  
   
   

done: # print the result
la $a0, result_msg
li $v0, 4
syscall # then the value
move $a0, $t7
li $v0, 1
syscall # then newline
la $a0, nl_msg
li $v0, 4
syscall
# exit
li $v0, 10
syscall

.data
query_msg: .asciiz "Input ? "
result_msg: .asciiz "totient = "
nl_msg: .asciiz "\n"
