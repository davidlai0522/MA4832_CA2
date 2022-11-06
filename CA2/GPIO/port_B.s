; rd_PORTB.s
; reads PORTB Bit 4-7 (Pins PB4 - PB7 are connected to dip switch) 

; GPIO_PORTB address

GPIO_PORTB_DATA_R  	EQU 0x400053FC
GPIO_PORTB_DIR_R   	EQU 0x40005400
GPIO_PORTB_AFSEL_R 	EQU 0x40005420
GPIO_PORTB_PUR_R   	EQU 0x40005510
GPIO_PORTB_DEN_R   	EQU 0x4000551C
GPIO_PORTB_AMSEL_R 	EQU 0x40005528
GPIO_PORTB_PCTL_R  	EQU 0x4000552C
PB_0				EQU 0x40005004
PB_1				EQU 0x40005008
PB_2				EQU 0x40005010
PB_3				EQU 0x40005020
PB_4				EQU 0x40005040
PB_5				EQU 0x40005080
PB_6				EQU 0x40005100
PB_7				EQU 0x40005200				
PB_4567				EQU 0x400053C0		; PORTB bit 4-7
	
SYSCTL_RCGCGPIO_R  	EQU 0x400FE608		; GPIO run mode clock gating control

		THUMB
		AREA    DATA, ALIGN=4 
		EXPORT  Result [DATA,SIZE=4]
Result  SPACE   4

		AREA    |.text|, CODE, READONLY, ALIGN=2
		THUMB
		EXPORT  Start

Start

; initialize Port B
; enable digital I/O, ensure alt. functions off.

; activate clock for PORTB
		LDR R1, =SYSCTL_RCGCGPIO_R 		; R1 = address of SYSCTL_RCGCGPIO_R 
		LDR R0, [R1]                	; 
		ORR R0, R0, #0x01           	; turn on GPIOB clock
		STR R0, [R1]                  
		NOP								; allow time for clock to finish
		NOP
		NOP   
		
; no need to unlock Port B bits

; disable analog mode
		LDR R1, =GPIO_PORTB_AMSEL_R     
		LDR R0, [R1]                    
		BIC R0, R0, #0xF0    			; disable analog mode on PORTB bit 4-7
		STR R0, [R1]       
	
;configure as GPIO
		LDR R1, =GPIO_PORTB_PCTL_R      
		LDR R0, [R1]  
		BIC R0, R0,#0x00FF0000			; clear PORTB bit 4 & 5
		BIC R0, R0,#0XFF000000			; clear PORTB bit 6 & 7 
		STR R0, [R1]     
    
;set direction register
		LDR R1, =GPIO_PORTB_DIR_R       
		LDR R0, [R1]                    
		BIC R0, R0, #0xF0     			; set PORTB bit 4-7 input (0: input, 1: output)
		STR R0, [R1]    
	
; disable alternate function
		LDR R1, =GPIO_PORTB_AFSEL_R     
		LDR R0, [R1]                     
		BIC R0, R0, #0xF0      			; disable alternate function on PORTB bit 4-7
		STR R0, [R1] 

; pull-up resistors on switch pins
		LDR R1, =GPIO_PORTB_PUR_R      	; 
		LDR R0, [R1]                   	; 
		ORR R0, R0, #0xF0              	; enable pull-up on PORTB bit 4-7
		STR R0, [R1]                   

; enable digital port
		LDR R1, =GPIO_PORTB_DEN_R   	
		LDR R0, [R1]                    
		ORR R0, R0, #0xF0               ; enable digital I/O on PORTB bit 4-7
		STR R0, [R1]    
    	    
		LDR R1, =PB_4567
	
Loop
		LDR R0, [R1]					; R0 = dip switch status
		LDR R2, =Result
		STR R0,[R2]						; store data

		B Loop

		ALIGN                			; make sure the end of this section is aligned
		END                  			; end of file

