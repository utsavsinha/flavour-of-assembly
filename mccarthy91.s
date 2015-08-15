# mcCarthy91.asm

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
li $t1, 1
li $t2, 10

move $a0, $t0  # load n in argument to the function
jal mccarthy91 # result in $v0, copy to $t1
move $t1, $v0

b done

mccarthy91 :
slti $t1, $a0, 101     
bgtz $t1, recurse
sub $v0, $a0, $t2				# storing (n-10) or ($a0-$t2) in result i.e. $t1 when n >= 101
jr $ra
recurse: 
addi $a0, $a0, 11
addi $sp, $sp, -4
sw $ra, 0($sp)
jal mccarthy91
move $a0, $v0  			 # the result so far becomes the argument of the outer mcCarthy91 function
jal mccarthy91            # for calling the nested recursive function
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra           


   
   

done: # print the result
la $a0, result_msg
li $v0, 4
syscall # then the value
move $a0, $t1
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
result_msg: .asciiz "McCarthy91 = "
nl_msg: .asciiz "\n"
