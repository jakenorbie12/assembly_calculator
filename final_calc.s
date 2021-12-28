         .data
msg1:   .asciiz "Welcome to the SPIM Calculator!"
msg2:   .asciiz "The available functions are: add, sub, mult, div, mod, sq, fact, sum, b2d and exit"
nl:     .asciiz "\n"
inpt1:  .asciiz "Put in First Integer: "
inpt2:  .asciiz "Put in Second Integer: "
inpt3:  .asciiz "Put in Function (1=add, 2=sub, 3=mult, 4=div, 5=mod, 6=sq, 7=fact, 8=sum, 9=b2d, 10=exit): "
excpt:  .asciiz "Please enter valid inputs!"
oput:   .asciiz "The Result is: "


         .text
main:   li $v0, 4
        la $a0, msg1 
        syscall                 #load and call the welcome message
        la $a0, nl
        syscall
        la $a0, msg2
        syscall                 #load and call list of available functions
        la $a0, nl
        syscall
core_lp:        
        li $v0, 4               #since core_lp is looped back to, reload proper system call into v0
        la $a0, nl
        syscall
        la $a0, inpt3
        syscall                 #load and call function input statement
        li $v0, 5
        syscall                 #record input integer
        addi $s2, $v0, 0        #move to s2
        li $t0, 10              #if exit, go to exit loop
        beq $s2, $t0, exit_f    
        li $v0, 4
        la $a0, nl
        syscall
        la $a0, inpt1
        syscall                 #load and call first integer input statement
        li $v0, 5               #retrieve integer
        syscall
        addi $s0, $v0, 0        #move to s0 register
        li $v0, 4
        la $a0, nl
        syscall
        li $t0, 6               #check if command is square, factorial, or binary to decimal. If so, go to them since only one int is used
        beq $s2, $t0, sq_f
        li $t0, 7
        beq $s2, $t0, fact_f
        li $t0, 9
        beq $s2, $t0, b2d_f     
        la $a0, inpt2
        syscall                 #load and call second integer input statement
        li $v0, 5               #retrieve integer
        syscall
        addi $s1, $v0, 0        #move to s1 register
        li $v0, 4
        la $a0, nl
        syscall
        li $t0, 1               #load the rest of the command numbers and jump to correct function that uses two integers 
        beq $s2, $t0, add_f 
        li $t0, 2
        beq $s2, $t0, sub_f
        li $t0, 3
        beq $s2, $t0, mult_f
        li $t0, 4
        beq $s2, $t0, div_f
        li $t0, 5
        beq $s2, $t0, mod_f
        li $t0, 8
        beq $s2, $t0, sum_f
        j except_2              #if the command is not valid (not equal to 1-10), jump to exception loop

add_f:  la $a0, oput            #load and print output statment
        li $v0, 4
        syscall
        add $a0, $s0, $s1       #perform add operation to a0
        li $v0, 1               #load print system call and print
        syscall
        j core_lp               #jump back to core loop
sub_f:  la $a0, oput            #load and print output statment
        li $v0, 4
        syscall
        sub $a0, $s0, $s1       #perform subtraction operation and send to a0
        li $v0, 1               #load print system call and print
        syscall
        j core_lp               #jump back to core loop
mult_f: la $a0, oput            #load and print output statment
        li $v0, 4
        syscall
        mul $a0, $s0, $s1       #multiply integers and send answer to a0
        li $v0, 1               #load print system call and print
        syscall
        j core_lp               #jump back to core loop
div_f:  la $a0, oput            #load and print output statment
        li $v0, 4
        syscall
        div $s0, $s1            #perform division operation (sends to lo)
        li $v0, 1               #load print system call
        mflo $a0                #move output to a0 and print it
        syscall
        j core_lp               #jump back to core loop
mod_f:  la $a0, oput            #load and print output statment
        li $v0, 4
        syscall
        div $s0, $s1            #perform modulus operation (sends remainder to hi)
        li $v0, 1               #load print system call
        mfhi $a0                #move remainer to a0 and print it
        syscall
        j core_lp               #jump back to core loop
sq_f:   la $a0, oput            #load and print output statment
        li $v0, 4               
        syscall
        mul $a0, $s0, $s0       #multiply integer with itself, and send to a0
        li $v0, 1               #load print system call and print
        syscall
        j core_lp               #jump back to core loop
fact_f: blt $s0, $zero, except_2        #if input is less than 0, jump to invalid exception loop
        la $a0, oput            #load and print output statment
        li $v0, 4
        syscall
        addi $t1, $s0, 0        #transfer first multiplication number to t1
        li $t2, 1               #load value of 1 into t2
        jal fact_h              #jal to factorial helper function
        li $v0, 1               #load print integer system call
        beq $t1, $zero, except  #if factorial answer is 0, go to exception to set it to 1
        addi $a0, $t1, 0        #move output to a0 and print it
        syscall
        j core_lp               #jump back to core loop
fact_h: sub $s0, $s0, $t2       #subtract s0 by 1 to get (n-1)
        beq $s0, $zero, exit_h  #if (n-1) = 0 than go to loop-breaking loop
        mul $t1, $t1, $s0       #multiply current factorial by (n-1)
        j fact_h                #loop back to top of loop
sum_f:  bge $s0, $s1, except_2  #if lower number is equal to or greater, go to invalid input loop
        la $a0, oput            #load and print output statment      
        li $v0, 4
        syscall
        addi $t1, $s0, 0        #move s0 to t1 for total (initial value)
        jal sum_h               #jal to sum helper loop
        li $v0, 1
        addi $a0, $t1, 0        #move output to a0 and print it
        syscall
        j core_lp               #jump back to core loop
sum_h:  bge $s0, $s1, exit_h    #if n has reached m+1, exit loop
        addi $s0, $s0, 1        #increase n to n+1
        add $t1, $t1, $s0       #add n by n+1
        j sum_h                 #jump to top of loop
b2d_f:  la $a0, oput            #load and print output statment
        li $v0, 4
        syscall
        li $t1, 10              #load initial set values of 10 and 1
        li $t5, 1
        li $t2, 1               #load n, which starts at 1
        li $t3, 2               #load multiplier (constant 2)
        li $s3, 0               #load total (starts at 0)
        jal b2d_he              #jal to b2d helper loop
        li $v0, 1
        addi $a0, $s3, 0        #move output to a0 and print it
        syscall
        j core_lp               #jump back to core loop
b2d_he: beq $s0, $zero, exit_h  #if s0 equals 0, enter jal return loop
        and $t4, $s0, $t5       #perform and operation on number and 1 (so t4 is 1 if number is odd or 0 if number is even)
        mul $t4, $t4, $t2       #multiply 1 or 0 by 2^n (1 for first slot, 2 for second, etc.)
        add $s3, $s3, $t4       #add to total in s3
        mul $t2, $t2, $t3       #increase 2^n by 2 (effectively increasing n by 1)
        div $s0, $t1            #divide current number by 10 and move that to s0 (shifting one to the right)
        mflo $s0
        j b2d_he                #jump to top of loop
exit_h: jr $ra                  #jump back to linked point. This is used to return to jal lines
except: addi $a0, $zero, 1      #if factorial of 0 is called, it normally returns 0. This exception makes it so factorial of 0 returns 1
        syscall
        j core_lp               #jump back to core loop
except_2:
        li $v0, 4               #load and print that an invalid input has been made
        la $a0, excpt
        syscall
        j core_lp               #jump back to core loop
exit_f: li $v0, 10              #load exit system call and exit
        syscall