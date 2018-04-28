# GOOD COPY

.equ PS2, 0xFF200100
.equ ADDR_JP1_LEGO, 0xFF200060
.equ ADDR_7SEG1, 0xFF200020
.equ ADDR_7SEG2, 0xFF200030
.equ TIMER0_BASE, 0xFF202000
.equ TIMER1_BASE, 0xFF202020
.equ TIMER0_STATUS, 0
.equ TIMER0_CONTROL, 4
.equ TIMER0_PERIODL, 8
.equ TIMER0_PERIODH, 12
.equ TICKSPERSEC, 100000000 #100 x 10^6 (1s)
.equ DELAY_PERIOD, 10000000 #10 x 10^6  (0.1s)
.equ DELAY_PERIOD2, 1000000 #10 x 10^6  (0.01s)
.equ ADDR_AUDIO,0xff203040
.equ FiveSec,0x00000040
.equ FreqSec,0x00000010


.data
TIMER_MAX:
    .word 100000 
TIMER_MAX_2:
    .word 100000000 
TIMER_MAX_3:
    .word 10000
TIMER_MAX_4:
    .word 1000
Password:
    .word 0x00000000
Break_code:
    .word 0x00000000
Break_code_bksp:
    .word 0x00000000
High:
    .word 24000
Low: 
    .word 24000
High2: 
    .word 12000
Low2: 
    .word 12000
AudioCounter: 
    .word 0
FreqCounter: 
    .word 0

.text
.global _start

/************************************************/
/*********** INITIALIZE STACK POINTER ***********/
/************************************************/

_start:
    movia sp, 0x17fff80
    br main
    
/************************************************/
/**************** SUBROUTINES *******************/
/************************************************/

/////////////////////////////////////////////////
            # 7-SEG DISPLAY SUBROUTINES
/////////////////////////////////////////////////
Say_locked:
    subi sp, sp, 4
    stw ra, 0(sp)
    
    movia r2, ADDR_7SEG2
    movia r3, 0x385c   #LO
    stwio r3, 0(r2)    # Write to 7-seg display 
        
    movia r2, ADDR_7SEG1
    movia r3, 0x5846795e   #CKED
    stwio r3, 0(r2)
    
    ldw ra, 0(sp)
    addi sp, sp, 4
    ret
    
    # HEX-DISPLAY subroutine
Say_open:
    subi sp, sp, 4
    stw ra, 0(sp)
    
    movia r2, ADDR_7SEG2
    movia r3, 0x0000   
    stwio r3, 0(r2)    
        
    movia r2, ADDR_7SEG1
    movia r3, 0x5c737954   #OPEN
    stwio r3, 0(r2)
    
    ldw ra, 0(sp)
    addi sp, sp, 4
    ret

    # HEX-DISPLAY subroutine
Say_type:
    subi sp, sp, 4
    stw ra, 0(sp)
    
    movia r2, ADDR_7SEG2
    movia r3, 0x0000   
    stwio r3, 0(r2)    # Write to 7-seg display 
        
    movia r2, ADDR_7SEG1
    movia r3, 0x786e7379   #TYPE
    stwio r3, 0(r2)

    ldw ra, 0(sp)
    addi sp, sp, 4
    ret
    
    #timer subroutine counts till 10 seconds

/////////////////////////////////////////////////
                # TIMER SUBROUTINES
/////////////////////////////////////////////////

/* r2 contains the base address, r8 is used to load/store and r9 contains the duration */
Timer_Start:
    subi sp, sp, 4
    stw ra, 0(sp)

    movia r2, TIMER0_BASE   #first stop the timer 
    addi r8, r0, 0x8
    stwio r8, TIMER0_CONTROL(r2)
    addi r8, r0, %lo(TICKSPERSEC)   #set the period
    stwio r8, TIMER0_PERIODL(r2)
    addi r8, r0, %hi(TICKSPERSEC)
    stwio r8, TIMER0_PERIODH(r2)
    addi r8, r0, 0x6    #start the timer and set it to repeat
    stwio r8, TIMER0_CONTROL(r2)
    addi r9, r0, 1      #set the timer for 10 seconds
Onesec:
    ldwio r8, TIMER0_STATUS(r2)     #check TO bit
    andi r8, r8, 0x1
    beq r8, r0, Onesec
    movi r8, 0x0        #clear TO bit
    stwio r8, TIMER0_STATUS(r8)
    subi r9, r9, 1      #decrement counter
    bne r9, r0, Onesec
    addi r8, r0, 0x8    #stop the counter
    stwio r8, TIMER0_CONTROL(r2)    

    ldw ra, 0(sp)
    addi sp, sp, 4
    ret
Timer_Start_another:
    subi sp, sp, 4
    stw ra, 0(sp)

    movia r2, TIMER0_BASE   #first stop the timer 
    addi r8, r0, 0x8
    stwio r8, TIMER0_CONTROL(r2)
    addi r8, r0, %lo(TICKSPERSEC)   #set the period
    stwio r8, TIMER0_PERIODL(r2)
    addi r8, r0, %hi(TICKSPERSEC)
    stwio r8, TIMER0_PERIODH(r2)
    addi r8, r0, 0x6    #start the timer and set it to repeat
    stwio r8, TIMER0_CONTROL(r2)
    addi r9, r0, 10000      #set the timer for 10 seconds
Onesec_another:
    ldwio r8, TIMER0_STATUS(r2)     #check TO bit
    andi r8, r8, 0x1
    beq r8, r0, Onesec_another
    movi r8, 0x0        #clear TO bit
    stwio r8, TIMER0_STATUS(r8)
    subi r9, r9, 1      #decrement counter
    bne r9, r0, Onesec_another
    addi r8, r0, 0x8    #stop the counter
    stwio r8, TIMER0_CONTROL(r2)    

    ldw ra, 0(sp)
    addi sp, sp, 4
    ret

/////////////////////////////////////////////////
    # TIMERS USED FOR BUFFERING THE MOTORS
/////////////////////////////////////////////////

/* timers used for buffering the motors */
Timer_Delay_On:
    #ldw r10, 0(sp)
    subi sp, sp, 4
    stw ra, 0(sp)

    movia r2, TIMER1_BASE   #first stop the timer 
    addi r8, r0, 0x8
    stwio r8, TIMER0_CONTROL(r2)
    addi r8, r0, %lo(DELAY_PERIOD2)  #set the period
    stwio r8, TIMER0_PERIODL(r2)
    addi r8, r0, %hi(DELAY_PERIOD2)
    stwio r8, TIMER0_PERIODH(r2)
    addi r8, r0, 0x6    #start the timer  repeat
    stwio r8, TIMER0_CONTROL(r2)
    addi r9, r0, 1  #number of times to run the timer
Onesec_Delay_On:
    ldwio r8, TIMER0_STATUS(r2)     #check TO bit
    andi r8, r8, 0x1
    beq r8, r0, Onesec_Delay_On
    movi r8, 0x0        #clear TO bit
    stwio r8, TIMER0_STATUS(r8)
    subi r9, r9, 1
    bne r9, r0, Onesec_Delay_On
    movia r9, 0xfffffffc
    movia r13, ADDR_JP1_LEGO
    stwio r9,0(r13) #stop the motor
    
    ldw ra, 0(sp)
    addi sp, sp, 4
    ret

Timer_Delay_On_Secondary:
    #ldw r10, 0(sp)
    subi sp, sp, 4
    stw ra, 0(sp)

    movia r2, TIMER1_BASE   #first stop the timer 
    addi r8, r0, 0x8
    stwio r8, TIMER0_CONTROL(r2)
    addi r8, r0, %lo(DELAY_PERIOD2)  #set the period
    stwio r8, TIMER0_PERIODL(r2)
    addi r8, r0, %hi(DELAY_PERIOD2)
    stwio r8, TIMER0_PERIODH(r2)
    addi r8, r0, 0x6    #start the timer  repeat
    stwio r8, TIMER0_CONTROL(r2)
    addi r9, r0, 1  #number of times to run the timer
Onesec_Delay_On_Secondary:
    ldwio r8, TIMER0_STATUS(r2)     #check TO bit
    andi r8, r8, 0x1
    beq r8, r0, Onesec_Delay_On
    movi r8, 0x0        #clear TO bit
    stwio r8, TIMER0_STATUS(r8)
    subi r9, r9, 1
    bne r9, r0, Onesec_Delay_On_Secondary
    movia r9, 0xfffffff3
    movia r13, ADDR_JP1_LEGO
    stwio r9,0(r13) #start the motor
    
    ldw ra, 0(sp)
    addi sp, sp, 4
    ret

Timer_Delay_Off:
    #ldw r10, 0(sp)
    subi sp, sp, 4
    stw ra, 0(sp)

    movia r2, TIMER1_BASE   #first stop the timer 
    addi r8, r0, 0x8
    stwio r8, TIMER0_CONTROL(r2)
    addi r8, r0, %lo(DELAY_PERIOD2)  #set the period
    stwio r8, TIMER0_PERIODL(r2)
    addi r8, r0, %hi(DELAY_PERIOD2)
    stwio r8, TIMER0_PERIODH(r2)
    addi r8, r0, 0x6    #start the timer but don't repeat
    stwio r8, TIMER0_CONTROL(r2)
    addi r9, r0, 1  #set the timer for __ seconds
Onesec_Delay_Off:
    ldwio r8, TIMER0_STATUS(r2)     #check TO bit
    andi r8, r8, 0x1
    beq r8, r0, Onesec_Delay_Off
    movi r8, 0x0        #clear TO bit
    stwio r8, TIMER0_STATUS(r8)
    subi r9, r9, 1
    bne r9, r0, Onesec_Delay_Off
    movia r9, 0xffffffff
    movia r13, ADDR_JP1_LEGO
    stwio r9,0(r13) #stop the motor
    
    ldw ra, 0(sp)
    addi sp, sp, 4
    ret

Timer_Delay_Off_Secondary:
    #ldw r10, 0(sp)
    subi sp, sp, 4
    stw ra, 0(sp)

    movia r2, TIMER1_BASE   #first stop the timer 
    addi r8, r0, 0x8
    stwio r8, TIMER0_CONTROL(r2)
    addi r8, r0, %lo(DELAY_PERIOD2)  #set the period
    stwio r8, TIMER0_PERIODL(r2)
    addi r8, r0, %hi(DELAY_PERIOD2)
    stwio r8, TIMER0_PERIODH(r2)
    addi r8, r0, 0x6    #start the timer but don't repeat
    stwio r8, TIMER0_CONTROL(r2)
    addi r9, r0, 1  #set the timer for __ seconds
Onesec_Delay_Off_Secondary:
    ldwio r8, TIMER0_STATUS(r2)     #check TO bit
    andi r8, r8, 0x1
    beq r8, r0, Onesec_Delay_Off
    movi r8, 0x0        #clear TO bit
    stwio r8, TIMER0_STATUS(r8)
    subi r9, r9, 1
    bne r9, r0, Onesec_Delay_Off_Secondary
    movia r9, 0xffffffff
    movia r13, ADDR_JP1_LEGO
    stwio r9,0(r13) #stop the motor
    
    ldw ra, 0(sp)
    addi sp, sp, 4
    ret

/////////////////////////////////////////////////
                    # AUDIO
/////////////////////////////////////////////////

Audio:
    subi sp, sp, 4
    stw ra, 0(sp)

    PlayHigh:
     movia r2,ADDR_AUDIO
     movia r3,0x60000000
     stwio r3,8(r2)
     stwio r3,12(r2)
     movia r5,High
     ldw r4,0(r5)
     beq r4,r0,PlayLow
     subi r4,r4,1
     stw r4,0(r5)
     #br PlayHigh
     
    PlayLow:
        movia r2,ADDR_AUDIO
        movia  r3,0x10000000
        stwio r3,8(r2)
        stwio r3,12(r2)
        movia r5,Low
        ldw r4,0(r5)
        beq r4,r0,checkCount
        subi r4,r4,1
        stw r4,0(r5)
        br PlayHigh
     #br PlayLow 

    checkCount:
       movia r4,AudioCounter
       ldw r4,0(r4)
       movia r5,FiveSec
       
       beq r4,r5,AudioEnd 
       addi r4,r4,1
       movia r6,AudioCounter 
        stw r4,0(r6)   
       addi r6,r0,24000
       movia r7,High
       movia r8,Low 
       stw r6,0(r7)
       stw r6,0(r8)
       br PlayHigh
            
        #movia r3,High     
AudioEnd: 

	movia r10, 24000

	movia r9, High
	stw r10, 0(r9)
	movia r9, Low
	stw r10, 0(r9)

	movia r10, 12000

	movia r9, High2
	stw r10, 0(r9)
	movia r9, Low2
	stw r10, 0(r9)

	movia r9, AudioCounter
	stw r0, 0(r9)
	movia r9, FreqCounter
	stw r0, 0(r9)

    ldw ra, 0(sp)
    addi sp, sp, 4
    ret

/************************************************/
/********** START OF THE MAIN PROGRAM ***********/
/************************************************/

# /* password is only set in the beginning so use polling */
# /* data read from PS2 into r2 */
# /* stored into r4 (max 4 characters due to each character being 1 byte) */

#clear r4 since password will be stored here
#r5 contains the make code for the enter button
#r6 contains max number of iterations 
#r7 is the counter
main:
    call Say_type

/////////////////////////////////////////////////
            # SET UP THE PASSWORD
/////////////////////////////////////////////////

Initialize_password:
    andi r4, r4, 0
    movia r5, 0x5A
    movia r6, 0x05
    movia r7, 0x00
    movia r10, 0xf0
PS2_read_valid:
    movia r9, PS2
    ldwio r2, 0(r9)     #clear fifo
    srli r8, r2, 15
    andi r8, r8, 0x1
    bne r8, r0, PS2_read_valid
PS2_wait_read_valid:
    ldwio r2, 0(r9)
    srli r8, r2, 15
    andi r8, r8, 0x1
    beq r8, r0, PS2_wait_read_valid
    andi r2, r2, 0xFF   #read from fifo
    beq r2, r5, Password_set    #check if enter is pressed
    #addi r7, r7, 0x01  #increment counter
    #bgeu r7, r6, PS2_wait_read_valid   #wait for [enter] if max pwd length met
Store_Password:
    beq r2, r10, Check_break_code
    
    movia r12, Break_code   #check if last bit is 0/1 to determine if even/odd
    ldw r13, 0(r12)
    andi r13, r13, 0x01
    movia r14, 0x01
    beq r13, r14, Check_break_code
    
    slli r4, r4, 8
    add r4, r4, r2
    br PS2_wait_read_valid
Check_break_code:   #may have to check if this code is 0xF0 later
    movia r12, Break_code   
    ldw r13, 0(r12)
    addi r13, r13, 1
    stw r13, 0(r12)
    
    movia r9, PS2
    ldwio r2, 0(r9) #break codes are at least 2 bytes long (handle 3 bytes later)
    #ldwio r2, 0(r9)
    br PS2_wait_read_valid  #may have to loop here to clear fifo
Password_set:   #password is set, clear PS2 fifo
    ldwio r2, 0(r9)
    srli r8, r2, 15
    andi r8, r8, 0x1
    bne r8, r0, Password_set
Password_prologue:
    subi sp, sp, 4  #store password in r4 onto the stack
    stw r4, 0(sp)   
    movia r12, Password
    stw r4, 0(r12)  
Password_prologue_clear_fifo:
    movia r9, PS2
    ldwio r2, 0(r9)     #clear fifo
    srli r8, r2, 15
    andi r8, r8, 0x1
    bne r8, r0, Password_prologue_clear_fifo
    call Say_locked
    
    movia r12, Break_code       #reset this Break_code back to 0
    movia r13, 0x00000000
    stw r13, 0(r12)
    #dont need r2, r5, r6, r7
    #need r4 because it contains the password
    
/////////////////////////////////////////////////
                 # CHECK SENSORS
/////////////////////////////////////////////////	

ReadSensors:
    movia r8, ADDR_JP1_LEGO
    movia r10, 0x07f557ff
    stwio r10, 4(r8)
    loop1:
    movia r11, 0xfffeffff
    stwio r11, 0(r8)
    ldwio r5, 0(r8)
    srli r6, r5, 17
    andi r6, r6, 0x1
    bne r0, r6, loop1
    good1:
    srli r5, r5, 27
    andi r5, r5, 0x0f
    movia r9, 0xa
    bgeu r5,r9,Check_if_fifo_cleared

    br ReadSensors

Check_if_fifo_cleared:
	movia r9, PS2
   ldwio r2, 0(r9)     #clear fifo
    srli r8, r2, 15
    andi r8, r8, 0x1
    bne r8, r0, Check_if_fifo_cleared
    call Say_locked

/////////////////////////////////////////////////
                 # CHECK PASSWORD
/////////////////////////////////////////////////

Check_password_0:
    andi r4, r4, 0
    movia r15, 0x00
Check_password:
    movia r9, PS2
    movia r5, 0x5A  # [enter]
    movia r6, 0x66  # [bksp]
    movia r7, 0xf0  # [break] 
    movia r16, 0x04 # max characters
Check_password_1:   #stores max 4 keys (32 bits)
    ldwio r2, 0(r9)
    srli r8, r2, 15
    andi r8, r8, 0x1
    beq r8, r0, Check_password_1
    andi r2, r2, 0xFF   #read from fifo
    #beq r2, r5, Check_password_2    #check if enter is pressed
    #beq r2, r6, Check_password_3   #check if backspace is pressed  
Disregard_break_codes:
    beq r2, r7, Handle_break_codes
    
    movia r12, Break_code   #check if last bit is 0/1 to determine if even/odd
    ldw r13, 0(r12)
    andi r13, r13, 0x01
    movia r14, 0x01
    beq r13, r14, Handle_break_codes
    
    #br Check_password
    
    beq r2, r5, Check_password_2    #check if enter is pressed
    beq r2, r6, Check_password_3    #check if backspace is pressed
    bgeu r15, r16, Check_password
Store_incoming_codes:
    slli r4, r4, 8
    add r4, r4, r2  
    
    addi r15, r15, 1
    #ldwio r2, 0(r9)        #handle break code
    #ldwio r2, 0(r9)
    br Check_password
Handle_break_codes:
    movia r12, Break_code   
    ldw r13, 0(r12)
    addi r13, r13, 1
    stw r13, 0(r12)
    br Check_password 
# [enter] handler
Check_password_2:

    movia r10, Password
    ldw r11, 0(r10)
    beq r4, r11, Check_password_4   #password entered is right
    andi r4, r4, 0      #clear entered password
    
    subi sp, sp, 4
    stw r15, 0(sp)
    call Audio
    ldw r15, 0(sp)

    movia r12, Break_code       #reset this Break_code back to 0
    movia r13, 0x00000000
    stw r13, 0(r12)
    
    movia r15, 0x00         #reset the number of characters already read
    
    br Check_password
# [bksp] handler
Check_password_3:
    #ldwio r2, 0(r9)        #handle break code
    #ldwio r2, 0(r9)
    
    #movia r12, Break_code_bksp     
    #ldw r13, 0(r12)
    #addi r13, r13, 1
    #stw r13, 0(r12)
    
    
    srli r4, r4, 8
    subi r15, r15, 1
    br Check_password
Check_password_4:
    call Say_open
    #br Check_password_4
    # /* call motors subroutine to open the door
    #  * call timer subroutine to automatically close the door
    #  * call motors subroutine to close the door
    #  * loop back to the beginning of the program loop
    #  */
    

    /************ main motors code ***********/

/////////////////////////////////////////////////
                 # MAIN MOTORS
/////////////////////////////////////////////////

Motor_setup:    
    movia  r13, ADDR_JP1_LEGO   #get the base address
    movia  r10, 0x07f557ff     # set direction for motors and sensors to output and sensor data register to inputs
    stwio  r10, 4(r13)
Clkwise:
    movia r9, 0xfffffffc    # motor0 enabled (bit0=0), direction set to foward (bit1=0) 
    stwio r9, 0(r13)        # motor is on
    call Timer_Delay_Off    #turn motor off after 0.01s
    movia r12,TIMER_MAX
    ldw r11,0(r12)
    subi r11,r11,1
    stw r11,0(r12)
    call Timer_Delay_On     #turn motor on after 0.01s
    movia r12,TIMER_MAX
    ldw r11,0(r12)
    subi r11,r11,1
    stw r11,0(r12)
    beq r11, r0, Next_motor       #run motor for 0.6 seconds
    br Clkwise   
Next_motor: 
    movia  r13, ADDR_JP1_LEGO   #get the base address
    movia r9, 0xfffffff3        #turn off main motor (  MAY HAVE TO TURN ON SECONDARY MOTOR HERE)
    stwio r9, 0(r13)            # motor is off
    call Say_locked
    movia r12,TIMER_MAX        #reset TIMER_MAX
    movia r11, 100000
    stw r11,0(r12)
    call Say_open

/////////////////////////////////////////////////
                 # 15s DELAY
/////////////////////////////////////////////////

Delayyy:
    call Timer_Start_another        # keep door open for length of the timer
    
    movia r12, TIMER_MAX_3
    ldw r8, 0(r12)
    subi r8, r8, 1
    stw r8, 0(r12)
    bne r8, r0, Delayyy
    
    movia r12,TIMER_MAX_3        #reset TIMER_MAX
    movia r11, 10000
    stw r11,0(r12)

/////////////////////////////////////////////////
               # SECONDARY MOTORS
/////////////////////////////////////////////////

Secondary_motor_setup:
    movia  r13, ADDR_JP1_LEGO   #get the base address
    movia  r10, 0x07f557ff     # set direction for motors and sensors to output and sensor data register to inputs
    stwio  r10, 4(r13)

    #initially move the motor backward to get in a position where it can fall
Secondary_cntclkwise:
    movia r9, 0xfffffffb    # motor1 enabled (bit2=0), direction set to reverse (bit3=1) 
    stwio r9, 0(r13) 
    call Say_locked
    br End_of_Program
    movia r12, TIMER_MAX_4
    ldw r8, 0(r12)
    subi r8, r8, 1
    stw r8, 0(r12)
    bne r8, r0, Secondary_cntclkwise

    movia r12,TIMER_MAX_4        #reset TIMER_MAX
    movia r11, 1000
    stw r11,0(r12)
Secondary_control_close:
    movia r9, 0xfffffff3    # motor1 enabled (bit2=0), direction set to forward (bit3=0) 
    stwio r9, 0(r13)
    

    #call Timer_Delay_Off_Secondary    #turn motor off after 0.01s
    movia r12,TIMER_MAX
    ldw r11,0(r12)
    subi r11,r11,1
    stw r11,0(r12)

   # call Timer_Delay_On_Secondary     #turn motor on after 0.01s
    movia r12,TIMER_MAX
    ldw r11,0(r12)
    subi r11,r11,1
    stw r11,0(r12)
    beq r11, r0, End_of_Program    
    br Secondary_control_close
  
/////////////////////////////////////////////////
            # CHECK SENSORS AGAIN
/////////////////////////////////////////////////

End_of_Program:
    br ReadSensors
   
