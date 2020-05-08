.macro heap_allocate (%a)
	move $a0,%a
	li $v0,9
	syscall
.end_macro
####################################################
.macro print_int (%b)
	li $v0,1
	add $a0, $zero, %b
	syscall
.end_macro
#####################################################	
.macro print_str (%c)
	li $v0, 4
	move $a0, %c
	syscall
.end_macro
####################################################	
.macro print_char (%d)
	li $v0,11
	add $a0, $zero, %d
	syscall
.end_macro
###################################################
.macro r_input(%e)
	li $v0, 8
	move $a0, %e
	li $a1,1024
	syscall
.end_macro  
##################################################
.macro	o_file(%f)
	li   $v0, 13      
	move   $a0, %f   
  	li   $a1, 0       
  	li   $a2, 0       
  	syscall 
.end_macro
######################################
.macro r_file(%g)
	li   $v0, 14      
	move   $a0, %g        
  	li   $a2, 1024       
  	syscall 
.end_macro
##########################################
.macro c_file(%h)
	li   $v0, 16      
	move   $a0, $s1               
  	syscall
.end_macro