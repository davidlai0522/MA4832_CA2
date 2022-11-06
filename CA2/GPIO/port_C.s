; rd_PORTC.s
; reads PORTC Bit 4-7 (Pins PC4 - PC7 are connected to dip switch) 

; GPIO_PORTC address

GPIO_PORTC_DATA_R  	EQU 0x400063FC
GPIO_PORTC_DIR_R   	EQU 0x40006400
GPIO_PORTC_AFSEL_R 	EQU 0x40006420
GPIO_PORTC_PUR_R   	EQU 0x40006510
GPIO_PORTC_DEN_R   	EQU 0x4000651C
GPIO_PORTC_AMSEL_R 	EQU 0x40006528
GPIO_PORTC_PCTL_R  	EQU 0x4000652C
PC_0				EQU 0x40006004
PC_1				EQU 0x40006008
PC_2				EQU 0x40006010
PC_3				EQU 0x40006020
PC_4				EQU 0x40006040
PC_5				EQU 0x40006080
PC_6				EQU 0x40006100
PC_7				EQU 0x40006200				
PC_4567				EQU 0x400063C0		; PORTC bit 4-7
	
SYSCTL_RCGCGPIO_R  	EQU 0x400FE608		; GPIO run mode clock gating control

		THUMB
		AREA    DATA, ALIGN=4 
		EXPORT  Result [DATA,SIZE=4]
Result  SPACE   4

		AREA    |.text|, CODE, READONLY, ALIGN=2
		THUMB
		EXPORT  Start

Start

; initialize Port C
; enable digital I/O, ensure alt. functions off.

; activate clock for PORTC
		LDR R1, =SYSCTL_RCGCGPIO_R 		; R1 = address of SYSCTL_RCGCGPIO_R 
		LDR R0, [R1]                	; 
		ORR R0, R0, #0x01           	; turn on GPIOC clock
		STR R0, [R1]                  
		NOP								; allow time for clock to finish
		NOP
		NOP   
		
; no need to unlock Port C bits

; disable analog mode
		LDR R1, =GPIO_PORTC_AMSEL_R     
		LDR R0, [R1]                    
		BIC R0, R0, #0xF0    			; disable analog mode on PORTC bit 4-7
		STR R0, [R1]       
	
;configure as GPIO
		LDR R1, =GPIO_PORTC_PCTL_R      
		LDR R0, [R1]  
		BIC R0, R0,#0x00FF0000			; clear PORTC bit 4 & 5
		BIC R0, R0,#0XFF000000			; clear PORTC bit 6 & 7 
		STR R0, [R1]     
    
;set direction register
		LDR R1, =GPIO_PORTC_DIR_R       
		LDR R0, [R1]                    
		BIC R0, R0, #0xF0     			; set PORTC bit 4-7 input (0: input, 1: output)
		STR R0, [R1]    
	
; disable alternate function
		LDR R1, =GPIO_PORTC_AFSEL_R     
		LDR R0, [R1]                     
		BIC R0, R0, #0xF0      			; disable alternate function on PORTC bit 4-7
		STR R0, [R1] 

; pull-up resistors on switch pins
		LDR R1, =GPIO_PORTC_PUR_R      	; 
		LDR R0, [R1]                   	; 
		ORR R0, R0, #0xF0              	; enable pull-up on PORTC bit 4-7
		STR R0, [R1]                   

; enable digital port
		LDR R1, =GPIO_PORTC_DEN_R   	
		LDR R0, [R1]                    
		ORR R0, R0, #0xF0               ; enable digital I/O on PORTC bit 4-7
		STR R0, [R1]    
    	    
		LDR R1, =PC_4567
	
Loop
		LDR R0, [R1]					; R0 = dip switch status
		LDR R2, =Result
		STR R0,[R2]						; store data

		B Loop

		ALIGN                			; make sure the end of this section is aligned
		END                  			; end of file

