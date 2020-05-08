.data

str:	.space 20
len: 	.word 20
newline:.asciiz "\n"
#prompt
prompt:.asciiz"Enter some text"
prompt1:.asciiz"Message: Goodbye"
space:.asciiz" "

word:.asciiz"words"
char:.asciiz"characters"

countw:.word 0	#counter for word
countc:.word 0	#counter for character

.text
main:	
	# output prompt 
	li	$v0, 54		#syscal 54 string
	la	$a0, prompt
	la	$a1,str
	lw	$a2,len
	syscall
	
	#Exit if blank input or cancel
	beq	$a1,-2,exit	
	beq	$a1,-3,exit

	#func call for character counter
	jal counter
	
	sw $v0,countc
	sw $v1,countw
	
	#print string
	la	$a0,str
	li	$v0,4
	syscall
	
	#count of word
	li	$v0,1
	lw	$a0,countw
	syscall	
	
	#space
	la  $a0, space      # print space
   	li  $v0, 4          
   	syscall
    	
   	#words
	la  $a0, word      # print space
   	li  $v0, 4          
  	syscall
    	
    	#space
	la  $a0, space      # print space
   	li  $v0, 4          
   	syscall
   	
   	#count of char
	li	$v0,1
	lw	$a0,countc
	syscall
	
	#space
	la  $a0, space      # print space
    	li  $v0, 4          
    	syscall
    	
	#characters
	la  $a0, char      # print space
    	li  $v0, 4          
    	syscall
	
	li $v0, 4       
	la $a0, newline       # load address of the string
	syscall
	
	j main
	
exit:	li	$v0, 59	#syscal 59 string
	la	$a0, prompt1
	syscall
	li	$v0,10	
	syscall

#########################################
#########################################
#########################################
counter:
	#load address str into $t0
	la 	$t0,str
	li 	$t1,0	#counter for character
	li 	$t2,1 	#counter for word
#push
	addi	$sp,$sp,-4
	sw	$s1,0($sp)
	move	$s1,$t0
	
loopc: 	lb	$t4,($s1)
	beq	$t4,'\n',loopc_exit	#newline for char
	beq	$t4,'\0',loopc_exit	#newline for null
	addi	$t1,$t1,1	#counter++ for char
	bne 	$t4,' ',next	#space for words
	addi	$t2,$t2,1	#counter++ for word
	
next:	addi	$s1,$s1,1	#move pointer to next pos
	j loopc
	
loopc_exit:	lw	$s1,0($sp) #pop
		add	$sp,$sp,4
		move 	$v0,$t1
		move	$v1,$t2
		jr $ra


















