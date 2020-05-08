.data
fout:	.asciiz "input.txt" #filename for output
buffer:.space 80
str1:	.asciiz "The array before: " 
str2:	.asciiz "The array after: "
str3: 	.asciiz "The mean is: "
str4:	.asciiz	"The median is: "
str5:	.asciiz "The standard deviation is: "
.align 2
array:.space 80
len:	.word 20
space: 	.asciiz " "
newline:.asciiz"\n"
messE:	.asciiz"Invalid"
average:.word 0


.text
#Open for writing
li 	$v0,13 		#syscall for open file
la 	$a0,fout	#output file name
li	$a1,0		#open for reading
li	$a2,0		#mode is ignored
syscall			#execute
move 	$s6,$v0		#file description

#Read from file
li	$v0,14		#syscall for reading file
move	$a0,$s6		#file description
la 	$a1,buffer	#address of buffer to read
la	$a2,len		#length
syscall

#testing buffer
#la	$a0,buffer
#li	$v0,4
#syscall

############################################################
#Covert char into int and put in array
li	$s0,0		
la	$a0,buffer	#address of the buffer string
move	$t0,$a0		#$t0 pointer
lb	$t1,($t0)
la	$k1,array
ble	$t1,$zero,exit_1	#if less than equal 0
jal loop_convert

#print array before sorted
la	$k1,array
jal print

#selection sort
la	$k1,array
jal selection_sort

#mean
la	$k1,array
jal mean

#median
la	$k1,array
jal median

#standard deviation
jal sd

##########################################################
#Close the file
li	$v0,16		#syscall for closing file
move	$a0,$s6		#file name to close
syscall			#close


exit: 	li $v0,10
	syscall
	
exit_1:
la	$a0,messE
li	$v0,4
syscall
j exit
	
#########################################################
loop_convert:
ble	$t1,$zero,end	#if less than equal 0
beq	$t1,'\n',else
blt	$t1,'0',not_int 		#condition for <0
bgt	$t1,'9',not_int		#condition for >9
subi	$t2,$t1,48	#-48 convert to int
mul	$s0,$s0,10	#i=i*10
add	$s0,$s0,$t2	#i+line67
addi	$t0,$t0,1	#point to next char
lb	$t1,($t0) 	#load next byte
j loop_convert

else:
addi	$t0,$t0,1	#point to next char
lb	$t1,($t0)	#load next bye
sw 	$s0,($k1)	#store into array int
addi	$k1,$k1,4	#point the next empty word in array
li	$s0,0		#reset s0
j loop_convert

not_int:
la	$a0,messE
li	$v0,4
syscall
j exit

end:
jr $ra



##############################################################
#function to print
print:
li $t1,0
li	$v0,4
la	$a0,str1
syscall

print1:
sll	$t2,$t1,2	#4i
add	$t3,$t2,$k1	#array[i]
lw	$a0,($t3)	#load word and print
li	$v0,1
syscall

#space
li	$v0,4
la	$a0,space
syscall

#print if i<20
addi	$t1,$t1,1
li	$t5,20
slt	$t4,$t1,$t5
bne	$t4,$zero,print1

#newline
li	$v0,4
la	$a0,newline
syscall

endprint:
jr $ra



###################################
#void sort(int arr[],int len) {
#        for (int i = 0; i < len-1; i++) {
#            int min_idx = i; 
#            for (int j = i+1; j < len; j++) 
#                if (arr[j] < arr[min_idx]) 
#                    min_idx = j; 
#  
#	     if(min_idx !=i){
#            	int temp = arr[min_idx]; 
#            	arr[min_idx] = arr[i]; 
#            	arr[i] = temp; 
#		}
#        } 
#    } 
selection_sort:	la	$k1,array	

		
		li	$t6,20			#len of array	
		addi	$t7,$t6,-1		#len-1
		
		li	$s1,0			#i=0
		li	$s2,0			#j=0
		li	$s3,0			#min_index

I_loop:		slt	$s4,$s1,$t7		#if i<len-1
		beq	$s4,$zero,break_iloop
		add	$s3,$zero,$s1		#$s3=min_index=i
		
		addi	$s2,$s1,1		#j=i+1

J_loop:		slt	$s4,$s2,$t6		#if j<len
		beq	$s4,$zero,break_jloop
		
		add	$s6,$0,$s3		#$s6=min_index
		sll	$s6,$s6,2		#$s6=4*min_index
		add	$s6,$s6,$k1		#s3 hold address array[min_index]
		lw	$t8,($s6)		#array[min_index]
		
		add	$s7,$0,$s2		#$s7=j
		sll	$s7,$s7,2		#$s7=4*j
		add	$s7,$s7,$k1		#s7 hold address array[j]
		lw	$t9,($s7)		#array[j]

		slt	$s4,$t9,$t8		# if (arr[j] < arr[min_idx]) 
		beq	$s4,$0,swap
		add	$s3,$0,$s2		#min_index=j
		j swap

swap:		beq	$s3,$s1,icr_j

		#swap
		add	$s7,$0,$s3	#s7=min_index
		sll	$s7,$s7,2	#$s7=4*min_index
		add	$s7,$s7,$k1	#$s7= address of array[min_index]
		lw	$k0,($s7)	#temp=array[min_index]
		
		add	$v1,$0,$s1	#$v1=i
		sll	$v1,$v1,2	#v1=4i
		add	$v1,$v1,$k1	#array[i]
		lw	$v0,($v1)	#array[i]
		
		sw	$v0,($s7)	#array[min_index]=array[i]
		sw	$k0,($v1)	#array[i]=temp
		addi	$s2,$s2,1	#j++
		add	$s3,$0,$s1	
		j	J_loop

icr_j:		addi	$s2,$s2,1	#j++
		j J_loop

break_jloop:	addi	$s1,$s1,1	#i++
		j	I_loop

break_iloop:	li	$v0,4
		la	$a0,str2
		syscall
		
#######################################################
######################################################
#print sorted array
print_sort:	li	$s1,0	#i=0
		la	$k1,array
		la	$t6,len
		lw	$t6,0($t6)
		
loop_print_sort:	slt	$t1,$s1,$t6	#if i<len
		beq	$t1,$zero,exit_print
		
		li	$v0,1
		lw	$a0,($k1)	#load each word to print
		syscall
		
		addi	$k1,$k1,4	#move pointer
		addi	$s1,$s1,1	#i++
		
		li	$v0,4
		la	$a0,space
		syscall
		j loop_print_sort
exit_print:jr $ra			
#############################################
mean:	li	$s1,0	#i=0
	la	$k1,array

	lw	$t6,len
	li	$s0,0	#sum
	li	$s3,0	#average
sum_loop:	
	lw	$t1,($k1)	#load first elements
	add	$s0,$s0,$t1
	addi	$s1,$s1,1	#i++
	addi	$k1,$k1,4	#move to next element
	blt	$s1,$t6,sum_loop
	
	mtc1 	$s0,$f12		#convert sum to floating
	cvt.s.w	$f12,$f12
	mtc1	$t6,$f14		#convert len to floating 
	cvt.s.w	$f14,$f14
	#average
	div.s	$f2,$f12,$f14
	
	#store to use later for SD
	swc1	$f2,average
	
	li	$v0,4
	la	$a0,newline
	syscall
	
	li	$v0,4
	la	$a0,str3
	syscall
	
	li	$v0,2		#print float
	mov.s	$f12,$f2
	syscall
	
	li	$v0,4
	la	$a0,newline
	syscall
	jr $ra

####################################################
##################################################
median:	li	$s0,0	#i=0
	li	$s1,2
	
	
	la	$k1,array
	lw	$t6,len

	
	div	$t6,$s1
	mfhi	$s4	#remainder
	mflo	$s5	#result(n)
	addi	$s6,$s5,-1 #result n+1
	
odd:	beq	$s4,$zero,else_even
	#return n+1
	add	$s6,$0,$s6	#s6=index
	sll	$s6,$s6,2	#4*index
	add	$s6,$s6,$k1	#$s7= address at index
	lw	$k0,($s6)	
	
	li	$v0,1
	move	$a0,$k0
	syscall	
		
else_even:	#return (n+(n+1))/2
		#return n
		add	$s5,$s5,0
		sll	$s5,$s5,2
		add	$s5,$s5,$k1
		lw	$k0,($s5)
		
		#return n+1
		add	$s6,$0,$s6	#s6=index
		sll	$s6,$s6,2	#4*index
		add	$s6,$s6,$k1	#$s7= address at index
		lw	$k1,($s6)
		
		#sum
		add	$s2,$k0,$k1
		#convert sum to float
		mtc1	$s2,$f4
		#convert 2 to float
		mtc1	$s1,$f2
		#div.s
		div.s	$f6,$f4,$f2
		
		li	$v0,4
		la	$a0,str4
		syscall
		
		li	$v0,2		#print float
		mov.s	$f12,$f6
		syscall
		
		li	$v0,4
		la	$a0,newline
		syscall
jr $ra
###########################################################
###########################################################
sd:		lw	$t6,len
		addi	$t5,$t6,-1 	#n-1
		mtc1	$t5,$f10		#convert (n-1)to float
		cvt.s.w	$f10,$f10
		
		la	$k1,array
		lwc1	$f2,average
		li	$s0,0		#i=0
		li	$s3,0		#sum 		
		mtc1	$s3,$f3		#convert sum to float
		cvt.s.w	$f3,$f3
		
loop_sd:		slt	$s2,$s0,$t6 #(if i<len)
		beq	$s2,$0,print_sd 
		lw	$s1,($k1)	#load number from array
		mtc1	$s1,$f4		#convert number to float
		cvt.s.w	$f4,$f4
		sub.s	$f6,$f4,$f2	#number[i]-average
		mul.s	$f0,$f6,$f6	#^2
		add.s	$f3,$f3,$f0
		addi	$k1,$k1,4	#next number
		addi	$s0,$s0,1	#i++
		j loop_sd

print_sd:	div.s	$f8,$f3,$f10	 #/n-1
		sqrt.s	$f1,$f8		#square root
		
		li	$v0,4
		la	$a0,str5
		syscall
		
		li	$v0,2
		mov.s	$f12,$f1
		syscall
		
		
jr	$ra

		

	
