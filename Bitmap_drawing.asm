#RESOLUTION
.eqv WIDTH 64
.eqv HEIGHT 64
##############MANUAL#################
####SET UNIT WIDTH AND HEIGHT IN PIXEL 4/4
####DISPLAY WIDE AND HEIGHT IN PIXEL 256/256
####BASE ADDRESS FOR DISPLAY USING $gp
# colors
.eqv	RED 	0x00FF0000
.eqv	GREEN 	0x0000FF00
.eqv	BLUE	0x000000FF
.eqv	WHITE 	0X00FFFFFF
.eqv	YELLOW	0X00FFFF00
.eqv	CYAN	0X0000FFFF
.eqv	MEGENTA	0X00FF00FF

.data
colors:.word	RED,GREEN,BLUE,WHITE,YELLOW,CYAN,MEGENTA
###########################################################
############################################################
.text
main:
	# set up starting position
	addi 	$a1, $0, WIDTH    # a0 = X = WIDTH/2
	sra 	$a1, $a1, 1
	addi 	$a2, $0, HEIGHT   # a1 = Y = HEIGHT/2
	sra 	$a2, $a2, 1
	
	la	$s1,colors	
	li	$t3,0
#program's loop
big_loop:
	#draw top side
	beq	$t3,7,reset	#condition to loop changing colors marque effect
	bgt	$t3,7,reset	#condition to loop changing colors marque effect
	mul	$t3,$t3,4	#4i
	add	$t1,$t3,$s1 	#$t1 holds address colors	
	jal top

	#draw right side
	mul	$t3,$t3,4	#4i
	add	$t1,$t3,$s1 	#$t1 holds address colors
	jal right
	
	#draw bottom 
	mul	$t3,$t3,4	#4i
	add	$t1,$t3,$s1 	#$t1 holds address colors
	jal bot
	
	#draw left side
	mul	$t3,$t3,4	#4i
	add	$t1,$t3,$s1 	#$t1 holds address colors
	jal left
	
	addi	$t3,$t3,1	#i++ for marquee
	
	
	# check for input
	lw $t0, 0xffff0000  #t1 holds if input available
    	beq $t0, 0,big_loop   #If no input, keep displaying
	
	# process input
	lw 	$s2, 0xffff0004
	beq	$s2, 32, exit	# input space
	beq	$s2, 119,move_up 	# input w
	beq	$s2, 115,move_down 	# input s
	beq	$s2, 97,move_left  	# input a
	beq	$s2, 100,move_right	# input d
	# invalid input, ignore	

jal pause 		#function to pause 5ms each draw loop back for marquee effect	
j	big_loop

reset:	li	$t3,0
	la	$s1,colors
	mul	$t3,$t3,4	#4i
	add	$t1,$t3,$s1 	#$t1 holds address colors
		
j big_loop

#control move 		
move_up :	jal draw_black		#draw black box
		addi	$a2,$a2,-1	#y goes up
		#draw the box again
		jal top			
		jal right
		jal bot
		jal left
		jal pause
		j big_loop

move_down:	jal draw_black		#draw black box
		addi	$a2,$a2,1	#y goes down
		#draw the box again
		jal top			
		jal right
		jal bot
		jal left
		jal pause
		j big_loop
		
move_left:	jal draw_black		#draw black box
		addi	$a1,$a1,-1	#x goes left
		#draw the box again
		jal top			
		jal right
		jal bot
		jal left
		jal pause
		j big_loop
		
move_right:	jal draw_black		#draw black box
		addi	$a1,$a1,1	#x goes right
		#draw the box again
		jal top			
		jal right
		jal bot
		jal left
		jal pause
		j big_loop	
####################################################################
###################################################################
#program ends if space is pressed		
exit:	li	$v0, 10
	syscall

#################################################
# subroutine to draw a pixel
# $a0 = X
# $a1 = Y
# $a2 = color
draw_pixel:
	# s1 = address = $gp + 4*(x + y*width)
	mul	$t9, $a2, WIDTH   # y * WIDTH
	add	$t9, $t9, $a1	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a3, ($t9)	  # store color at memory location
	jr 	$ra
################################
######DRAW BLACK BOX########
		#control conditons for 4 sides
draw_black:	li	$t5,0
		li	$t6,0
		li	$t7,0
		li	$t8,0
		#stack
		addi 	$sp, $sp, -4
  		sw 	$ra, 0($sp)  
#black out the top,same logics as drawing the box but using only black color 0		
black_top:	li	$a3,0		#load black 
		jal 	draw_pixel	#draw black pixel
		addi	$a1,$a1,1	#next position to the right
		addi	$t5,$t5,1	#i++
		blt	$t5,7,black_top	#check i<7
#black out the right 			
black_right:	li	$a3,0		#load black
		jal 	draw_pixel	#draw black pixel
		addi	$a2,$a2,1	#next position going down
		addi	$t6,$t6,1	#i++
		blt	$t6,7,black_right#check i<7
#black out the bottom 			
black_bot:	li	$a3,0		#load black	
		jal 	draw_pixel	#draw black pixel
		addi	$a1,$a1,-1	#next position going left
		addi	$t7,$t7,1	#i++
		blt 	$t7,7,black_bot	#check i<7
#black out the left 			
black_left:	li	$a3,0		#load black	
		jal	draw_pixel	#draw black pixel
		addi	$a2,$a2,-1	#next position going up
		addi	$t8,$t8,1	#i++
		blt	$t8,7,black_left	#check i<7
		
done:		lw 	$ra, 0($sp)
  		addi	$sp, $sp, 4
		jr	$ra
#################################################
# subroutine to pause
pause:	li $a0,5 	#delay of mili seconds
	li $v0,32
	syscall	
	jr	$ra
#################################################

# subroutine to draw top
top:	li	$s0,0		#i=0
	#stack
	addi 	$sp, $sp, -4
  	sw 	$ra, 0($sp)  

  	
loop:	lw	$a3,($t1)	#load first color
	jal draw_pixel		#draw

	addi	$t1,$t1,4	#next color
	addi	$a1,$a1,1	#next position going right
	addi	$s0,$s0,1	#i++
	blt	$s0,7,loop	#check i<7 


	lw 	$ra, 0($sp)
  	addi	$sp, $sp, 4
	jr 	$ra
#################################################
# subroutine to draw right
right: 	li	$s0,0		#i=0
	#stack
	addi 	$sp, $sp, -4
  	sw 	$ra, 0($sp) 
  	
loop_1:	lw	$a3,($t1)	#load first color
	jal draw_pixel		#draw
	
	addi	$t1,$t1,4	#next color
	addi	$a2,$a2,1	#next position going down
	addi	$s0,$s0,1	#i++
	blt	$s0,7,loop_1	#check i<7
	
	lw 	$ra, 0($sp)
  	addi 	$sp, $sp, 4
	jr	$ra	
#################################################
# subroutine to draw bottom
bot:	li	$s0,0		#i=0
	#stack
	addi $sp, $sp, -4
  	sw $ra, 0($sp) 	
 
loop_2:	lw	$a3,($t1)	#load first color
	jal draw_pixel		#draw 

	addi	$t1,$t1,4	#next color
	addi	$a1,$a1,-1	#next position going left
	addi	$s0,$s0,1	#i++
	blt	$s0,7,loop_2	#check i<7
	
	lw 	$ra, 0($sp)
  	addi 	$sp, $sp, 4
	jr	$ra
#################################################
# subroutine to draw left
left:	li	$s0,0		#i=0
	#stack
	addi	$sp, $sp, -4
  	sw 	$ra, 0($sp) 	
 
loop_3:	lw	$a3,($t1)	#load first color
	jal draw_pixel		#draw

	addi	$t1,$t1,4	#next color
	addi	$a2,$a2,-1	#next position going up
	addi	$s0,$s0,1	#i++
	blt	$s0,7,loop_3	#check i<7
	
	lw 	$ra, 0($sp)
  	addi 	$sp, $sp, 4
	jr	$ra
######################################END PROGRAM 8###############################
