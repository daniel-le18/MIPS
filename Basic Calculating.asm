.data
name:	.space	20	

#3 variables to hold input
a:	.word	0	#initialize a to 0
b:	.word 	0	#initialize b to 0
c:	.word	0	#initialize c to 0

#3 variables to hold output
result: .word	0	#initialize result to 0
result1:.word	0	#initialize result1 to 0
result2:.word	0	#initialize result2 to 

#prompt
prompt:	.asciiz	"Please enter your name: "
prompt1:.asciiz "Please enter first integer between 1-100: "
prompt2:.asciiz"Please enter second integer between 1-100: "
prompt3:.asciiz"Please enter your third integer between 1-100: "
promptrs:.asciiz"Your answers are: "
space:.asciiz" "
msg:	.asciiz "Hello "

.text
main:	
	# output prompt name
	li	$v0, 4		#syscal 4 string
	la	$a0, prompt	
	syscall
	
	# input name
	li	$v0, 8	#take in a string
	li	$a1, 20	#using 20 of space
	la	$a0, name	#save input to name
	syscall
	
	#output prompt1 int
	li 	$v0,4		#syscal 4 string prompt 1
	la	$a0,prompt1	
	syscall
	#input 1st int
	li	$v0,5		#syscal 5 int, take in an int and save it to $v0
	syscall
	sw 	$v0,a		#save int from $v0  to a
	
	
	#output prompt2 int
	li	$v0,4		#syscal 4 string prompt2
	la	$a0,prompt2
	syscall
	#input 2nd int
	li	$v0,5		#syscal 5 int, take in an int and save it to $v0
	syscall
	sw 	$v0,b		#save int from $v0 to b

	
	#output prompt3 int
	li	$v0,4		#syscal 4 string prompt3
	la	$a0,prompt3
	syscall
	#input 3rd int
	li	$v0,5		#syscal 5 int , take in an int and save it to $v0
	syscall
	sw 	$v0,c		#save int from $v0  to c
	
	#load a,b,c for caculations
	lw	$s0,a
	lw	$s1,b
	lw	$s2,c
	
	#result=2a-b+9
	add 	$t1,$s0,$s0	#2a=a+a
	sub	$t2,$t1,$s1	#2a-b
	addi	$t3,$t2,9	#(2a-b)+9
	sw 	$t3,result	#save into result
	
	
	#result1=c-b+(a-5)
	sub	$t4,$s2,$s1	#$t4=c-b
	subi	$t5,$s0,5	#$t5=a-5
	add	$t6,$t4,$t5	#result=$t4+$t5
	sw 	$t6,result1	#save into result1
	
	
	#result2=(a-3)+(b+4)-(c+7)
	
	subi	$t7,$s0,3	#$t7=a-3
	addi	$t8,$s1,4	#$t8=b+4
	addi	$t9,$s2,7	#$t9=c+7
	add	$t7,$t7,$t8	#$t7=$t7+$t8
	sub	$t7,$t7,$t9	#$t7=$t7-$t9
	sw	$t7,result2	#save into result2
	
	

	# say hello
	li	$v0, 4	#syscal4 string
	la	$a0, msg	#display msg
	syscall
	
	li	$v0, 4	#syscal4 string
	la	$a0, name	#display name
	syscall
	
	#print out results
	li	$v0,4	
	la 	$a0,promptrs
	syscall
	
	#print out result
	li	$v0,1
	lw	$a0,result
	syscall
	
	#space
	la  $a0, space      # print space
    	li  $v0, 4          
    	syscall
    	
	#print out result1
	li	$v0,1
	lw	$a0,result1
	syscall
	
	#space
	la  $a0, space      # print space
    	li  $v0, 4          
    	syscall
    	
	#print out result2
	li	$v0,1
	lw	$a0,result2
	syscall
	
	
	
exit:	li	$v0, 10
	syscall
