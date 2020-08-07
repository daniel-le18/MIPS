.data 
file_input: .space 20
buffer_read: .space 1024
str1: .asciiz "Please enter the filename to compress or <enter> to exit: "
original_file_size: .word 0
compress_file_size: .word 0
str2: .asciiz "Original data:\n"
buffer_comp: .space 1024
str3: .asciiz "\nCompressed data:\n"
str4: .asciiz "\nOriginal file size: "
str5: .asciiz "\nCompressed file size: "
buffer_uncomp: .space 1024
str6: .asciiz "\nUncompressed Data:\n"
str7: .asciiz "Error opening file. Terminating program!\n"
str8: .asciiz "\n"
.include "print.asm"
.text 
main:	
	#open,read,close file
	jal data_process
	
	#print message
	la $t0,str2
	print_str ($t0)
	
	#print message
	move $t0,$s5
	print_str ($t0)
	
	#compress function
	move $a0,$s5		#allocated $s5 buffer
	move $a1,$s6		#allocated $s6 compress buffer
	lw $a2,original_file_size	#load original file size
	jal compress
	sw $v0,compress_file_size	#save compress file size
	
	#decompressing 
	move $a0,$s6		#allocated $s6 compress buffer
	move $a1,$s7		#allocated $s7 compress buffer
	lw $a2,compress_file_size#load compress file size
	jal de_compress

	
	#print message
	la $t0,str3
	print_str ($t0)
	
	#print message
	move 	$t0,$s6
	lw	$a2,compress_file_size
	li	$s0,0
	
	#print compressed string char syscall then int syscall
	print1:		
		beq	$s0,$a2,end_print1
		lb	$a0,($s6)
		print_char($a0)
		 
		addi	$s6,$s6,1	#jump 1 byte to int
		
		lb	$a0,($s6)
		subi	$a0,$a0,'0'	#convert byte of int to int
		print_int($a0)
		
		addi	$s6,$s6,1	#jump 1 byte to char again
		addi	$s0,$s0,2	#size+=2
		j print1
	end_print1:
	
	#print message
	la $t0,str6
	print_str ($t0)
	
	#print uncompress
	move $t0,$s7
	print_str ($s7)


	#print message
	la $t0,str4
	print_str ($t0)
	
	#print original file size
	lw $t0,original_file_size
	print_int ($t0)
	
	#print message
	la $t0,str5
	print_str ($t0)
	
	#print compress file size
	lw $t0,compress_file_size
	print_int ($t0)
	
	#print message
	la $t0,str8
	print_str ($t0)
	

	j main

exit1:
	#error if open
	la $t0,str7
	print_str ($t0)

exit:

	li $v0, 10
	syscall
	
	
###########################################################################
data_process:
	#heap allocate buffer,buffer compress,buffer uncompress
	li $s1,1024
	heap_allocate ($s1)
	move $s5,$v0				#file read data will be stored at address in $s5
	heap_allocate ($s1)
	move $s6,$v0				#compress data will be stored at address in $s6
	heap_allocate ($s1)
	move $s7,$v0				#uncompress data will be stored at address in $s7
	
	#print message
	la $t0,str1
	print_str ($t0)
	
	#read input file name
	la $t0,file_input
	r_input($t0)
	
	#if just enter end program
	lb $t0,file_input
	beq $t0,'\n',exit
	

	#remove \n in input file name and put \0 to string file input
	la $t0,file_input 
	remove: 	lb $s1,($t0)
		bne $s1,10,next
		sb $zero,($t0)
		j skip
	next:  add $t0,$t0,1
		j remove
	skip:

	#opening file
	la $t0,file_input
	o_file($t0)
	
	
	#if error print error and terminate the program
	bltz $v0,exit1
	
	#read the file
	move $s1,$v0
	move $a1,$s5
	r_file($s1)
	
	#closing the file and storing the size of file
	move $t2,$v0
	c_file($s1)
	sw $t2,original_file_size
	jr $ra
######################################################################################
#############################################################################################
compress:	li $s0,0				#filesize counter 
		move $s4,$a1			#s4=allocated address compress buffer
	
for_loop:
		lb $t0,($a0)		#load char
		li $s1,1			#i=1
		li $s2,1			#count=1
		
while_loop:	add $t2,$s1,$a0			#str[i+1]
		lb $t1,($t2)			#load next char
		bne $t0,$t1,while_exit		#str[i] != str[i+1]
		addi $s1,$s1,1			#i++						
		addi $s2,$s2,1			#count++			
		j while_loop
												
while_exit:	sb $t0,($a1)			#save char into $a1						
		add $s3,$s2,'0'			#conver int to byte to save					
		sb $s3,1($a1)			#save count in byte					
		add $a0,$a0,$s2			#update address by count					
		add $s0,$s0,$s2			#update loop counter for file size					
		addi $a1,$a1,2			#jump 2 byte into next char							
		bne $s0,$a2,for_loop		#loop to file size $a2					
		sub $v0,$a1,$s4			#comp_size				
		jr $ra
######################################################
de_compress:	li	$s0,0			#i=0
		add	$a2,$a2,$0		#size of compressed
		
while1:		bge	$s0,$a2,done1			#while(i>=len)
		lb	$t0,($a0)		#load first byte char
		lb	$s2,1($a0)		#load int byte (value int)
		sub	$s2,$s2,'0'
		addi	$a0,$a0,2		#jump to next byte char
		li	$t1,0			#j=0
		
while2:	 	bge	$t1,$s2,incr			#while(j>= value int)
		sb	$t0,($a1)		#store char in in $a2 that many times
		addi	$a1,$a1,1		#jump to next empty byte to store
		addi	$t1,$t1,1		#j++	
		j while2

incr:		addi	$s0,$s0,2		#jump 2 byte in size
		j while1			
			
done1:		jr $ra	



	
	
