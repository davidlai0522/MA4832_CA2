; adc_single_ch.s
; samples one ADC channel, PortE bit 5 (PE5), using Sample Sequencer 3(SS3)

; GPIO_PORTB and ADC1 address

GPIO_PORTB_AFSEL_R 	EQU 0x40005420
GPIO_PORTB_DEN_R   	EQU 0x4000551C
GPIO_PORTB_AMSEL_R 	EQU 0x40005528

ADC1_ACTSS_R   		EQU 0x40039000
ADC1_PC_R           EQU	0x40039FC4
ADC1_SSPRI_R        EQU	0x40039020
ADC1_EMUX_R			EQU	0x40039014
ADC1_SSMUX2_R       EQU 0x40039080
ADC1_SSCTL2_R       EQU	0x40039084
ADC1_IM_R           EQU 0x40039008
ADC1_PSSI_R			EQU 0x40039028
ADC1_RIS_R			EQU	0x40039004	
ADC1_SSFIFO2_R		EQU	0x40039088	
ADC1_ISC_R			EQU	0x4003900C	

; PORT F LED CONFIGURATION
GPIO_PORTF_DATA_R  EQU 0x400253FC
GPIO_PORTF_DIR_R   EQU 0x40025400
GPIO_PORTF_AFSEL_R EQU 0x40025420
GPIO_PORTF_PUR_R   EQU 0x40025510
GPIO_PORTF_DEN_R   EQU 0x4002551C
GPIO_PORTF_AMSEL_R EQU 0x40025528
GPIO_PORTF_PCTL_R  EQU 0x4002552C
PF1                EQU 0x40025008	;	RED LED
PF2                EQU 0x40025010	; 	BLUE LED - ORIG
PF3                EQU 0x40025020	;	GREEN LED

; PORT B GPIO
GPIO_PORTB_DATA_R  EQU 0x400053FC
GPIO_PORTB_DIR_R   EQU 0x40005400
GPIO_PORTB_AFSEL_R EQU 0x40005420
GPIO_PORTB_PUR_R   EQU 0x40005510
GPIO_PORTB_DEN_R   EQU 0x4000551C
GPIO_PORTB_AMSEL_R EQU 0x40005528
GPIO_PORTB_PCTL_R  EQU 0x4000552C
PB0                EQU 0x40005004	; 	RED
PB1                EQU 0x40005008	;	GREEN LED


; PORT E DIP SWITCH
GPIO_PORTE_DATA_R  EQU 0x400243FC
GPIO_PORTE_DIR_R   EQU 0x40024400
GPIO_PORTE_AFSEL_R EQU 0x40024420
GPIO_PORTE_PUR_R   EQU 0x40024510
GPIO_PORTE_DEN_R   EQU 0x4002451C
GPIO_PORTE_AMSEL_R EQU 0x40024528
GPIO_PORTE_PCTL_R  EQU 0x4002452C
PE123				EQU 0x40024038

VAL_1V				EQU 0x000004D9
VAL_2V				EQU 0x000009B2
	
SYSCTL_RCGCGPIO_R  	EQU 0x400FE608		; GPIO run mode clock gating control

SYSCTL_RCGCADC_R 	EQU 0x400FE638		; ADC run mode clock gating control

		THUMB
		AREA    DATA, ALIGN=4 
		EXPORT  Result [DATA,SIZE=4]
Result  SPACE   4


		AREA    |.text|, CODE, READONLY, ALIGN=2
		THUMB
		EXPORT  Start

Start
; initialize Port BEF
; activate clock for Port BEF

		LDR R1, =SYSCTL_RCGCGPIO_R 		; R1 = address of SYSCTL_RCGCGPIO_R
		LDR R0, [R1]                	; 
		ORR R0, R0, #0x32           	; turn on GPIOE and GPIOF clock
		STR R0, [R1]                  
		NOP								; allow time for clock to finish
		NOP
		NOP   

; no need to unlock PE4 and PF2
 
 ; PORT B (0123
 	
; no need to unlock Port B bits
; disable analog mode
		LDR R1, =GPIO_PORTB_AMSEL_R     
		LDR R0, [R1]                    
		BIC R0, R0, #0x0F    			; Clear bit 0-3, disable analog function
		STR R0, [R1]       
	
; configure as GPIO
		LDR R1, =GPIO_PORTB_PCTL_R      
		LDR R0, [R1]  
		BIC R0, R0,#0x000000FF			; bit clear PortB bit 0 & 1
		BIC R0, R0,#0X0000FF00			; bit clear PortB bit 2 & 3 
		STR R0, [R1]     
    
; set direction register
		LDR R1, =GPIO_PORTB_DIR_R       
		LDR R0, [R1]                    
		ORR R0, R0, #0x0F     			; set PortB bit 0-3 as output (0: input, 1: output)
		STR R0, [R1]    
	
; disable alternate function
		LDR R1, =GPIO_PORTB_AFSEL_R     
		LDR R0, [R1]                     
		BIC R0, R0, #0x0F    			; disable alternate function on PortB bit 0-3
		STR R0, [R1] 

; enable digital port
		LDR R1, =GPIO_PORTB_DEN_R   	
		LDR R0, [R1]                    
		ORR R0, #0x0F               	; enable PortB digital I/O      
		STR R0, [R1]    
    	    



















; PORT E 123

; disable analog mode
		LDR R1, =GPIO_PORTE_AMSEL_R     
		LDR R0, [R1]                    
		BIC R0, R0, #0x0E    			; disable analog mode on PortA bit 1-3
		STR R0, [R1]       
	
;configure as GPIO
		LDR R1, =GPIO_PORTE_PCTL_R      
		LDR R0, [R1]  
		BIC R0, R0,#0x0000FFF0			; clear PortA bit 123
		STR R0, [R1]     
    
;set direction register
		LDR R1, =GPIO_PORTE_DIR_R       
		LDR R0, [R1]                    
		BIC R0, R0, #0x0E     			; set PortA bit 1-3 input (0: input, 1: output)
		STR R0, [R1]    
	
; disable alternate function
		LDR R1, =GPIO_PORTE_AFSEL_R     
		LDR R0, [R1]                     
		BIC R0, R0, #0x0E      			; disable alternate function on PortA bit 1-3
		STR R0, [R1] 

; pull-up resistors on switch pins
		LDR R1, =GPIO_PORTE_PUR_R      	; 
		LDR R0, [R1]                   	; 
		ORR R0, R0, #0x0E              	; enable pull-up on PortA bit 1-3
		STR R0, [R1]                   

; enable digital port
		LDR R1, =GPIO_PORTE_DEN_R   	
		LDR R0, [R1]                    
		ORR R0, R0, #0x0E               ; enable digital I/O on PortA bit 1-3
		STR R0, [R1]    













; Config Port F
; disable analog functionality
		LDR R1, =GPIO_PORTF_AMSEL_R     
		LDR R0, [R1]                    
		BIC R0, #0x0E                  	; 0 means analog is off
		STR R0, [R1]       
		
		;configure as GPIO
		LDR R1, =GPIO_PORTF_PCTL_R      
		LDR R0, [R1]   
		BIC R0, R0,	#0x00000FF0			; Clears bit 1 & 2
		BIC R0, R0, #0x000FF000         ; Clears bit 3 & 4
		STR R0, [R1]     
		
		;set direction register
		LDR R1, =GPIO_PORTF_DIR_R       
		LDR R0, [R1]                    
		ORR R0, R0, #0x0E               ; PF 1,2,3 output 
		BIC R0, R0, #0x10               ; Make PF4 built-in button input
		STR R0, [R1]    
		
		; regular port function
		LDR R1, =GPIO_PORTF_AFSEL_R     
		LDR R0, [R1]                     
		BIC R0, R0, #0x1E               ; 0 means disable alternate function
		STR R0, [R1] 
		
		; pull-up resistors on switch pins
		LDR R1, =GPIO_PORTF_PUR_R       ; R1 = &GPIO_PORTF_PUR_R
		LDR R0, [R1]                    ; R0 = [R1]
		ORR R0, R0, #0x10               ; R0 = R0|0x10 (enable pull-up on PF4)
		STR R0, [R1]                    ; [R1] = R0

		; enable digital port
		LDR R1, =GPIO_PORTF_DEN_R       ; 7) enable Port F digital port
		LDR R0, [R1]                    
		ORR R0,#0x0E                    ; 1 means enable digital I/O
		ORR R0, R0, #0x10               ; R0 = R0|0x10 (enable digital I/O on PF4)
		STR R0, [R1]    

		
		
		
		






















		

	
		
 
 
 
 
; Config Port B
; enable alternate function
		LDR R1, =GPIO_PORTB_AFSEL_R     
		LDR R0, [R1]                     
		ORR R0, R0, #0x20      			; enable alternate function on PB5
		STR R0, [R1] 
		
; disable digital port
		LDR R1, =GPIO_PORTB_DEN_R   	
		LDR R0, [R1]                    
		BIC R0, R0, #0x20               ; disable digital I/O on PB5
		STR R0, [R1]    
	 			
; enable analog mode
		LDR R1, =GPIO_PORTB_AMSEL_R     
		LDR R0, [R1]                    
		ORR R0, R0, #0x20    			; enable PB5 analog function
		STR R0, [R1]       

; activate clock for ADC0
		LDR R1, =SYSCTL_RCGCADC_R 		 
		LDR R0, [R1]                	 
		ORR R0, R0, #0x02           	; activate ADC1
		STR R0, [R1]                  
	  
		BL Delay						; delay subroutine -> allow time for clock to finish
		
		LDR R1, =ADC1_PC_R       
		LDR R0, [R1]           
		BIC R0, R0, #0x0F				; clear max sample rate field
		ORR R0, R0, #0x1     			; configure for 125K samples/sec
		STR R0, [R1]    

		LDR R1, =ADC1_SSPRI_R       
		LDR R0, =0x1023           		; SS2 is highest priority
		STR R0, [R1]    

		LDR R1, =ADC1_ACTSS_R       
		LDR R0, [R1]           
		BIC R0, R0, #0x04				; disable SS2 before configuration to 
		STR R0, [R1]    				; prevent erroneous execution if a trigger event were to occur

		LDR R1, =ADC1_EMUX_R       
		LDR R0, [R1]           
		BIC R0, R0, #0x0F00				; SS2 is software trigger
		STR R0, [R1]    

		LDR R1, =ADC1_SSMUX2_R      
		LDR R0, [R1]           
		BIC R0, R0, #0x000F				; clear SS2 field
		ADD R0, R0, #11					; set channel -> select input pin AIN11
		STR R0, [R1]    

		LDR R1, =ADC1_SSCTL2_R       
		LDR R0, =0x0006           		; configure 1st sample -> not reading Temp sensor, not differentially sampled,
		STR R0, [R1]    				; assert raw interrupt signal at the end of conversion, first sample is last sample
		
		LDR R1, =ADC1_IM_R     
		LDR R0, [R1]           
		BIC R0, R0, #0x0004				; disable SS2 interrupts
		STR R0, [R1]    
		
		LDR R1, =ADC1_ACTSS_R      
		LDR R0, [R1]           
		ORR R0, R0, #0x0004     		; enable SS2
		STR R0, [R1]    


Loop	
		LDR R1, =ADC1_PSSI_R      
		MOV R0, #0x04					; initiate sampling in the SS2  
		STR R0, [R1]    
		
		LDR R1, =ADC1_RIS_R   			; R1 = address of ADC Raw Interrupt Status
		LDR R0, [R1]           			; check end of a conversion
		CMP	R0, #0x04    				; when a sample has completed conversion -> a raw interrupt is enabled
		BNE	Loop    
		
		LDR R1, =ADC1_SSFIFO2_R			; load SS2 result FIFO into R1
		LDR R0,[R1]
		LDR R2, =Result					; store data
		STR R0,[R2]
		
		LDR R1, =ADC1_ISC_R
		LDR R0, [R1]
		ORR R0, R0, #04					; acknowledge conversion
		STR R0, [R1]
		
COMPARE_1V_MSB
		LDR R0, [R2]
		LSR R0, R0, #08
		CMP R0, #0x04
		BEQ COMPARE_1V_LSB
		BGT COMPARE_2V_MSB
		BLT OFF_ALL
		
COMPARE_1V_LSB
		LDR R0, [R2]
		BIC R0, R0, #0xF00
		CMP R0, #0xD9
		BGT COMPARE_2V_MSB
		BLE OFF_ALL
		
COMPARE_2V_MSB
		LDR R0, [R2]
		LSR R0, R0, #08
		CMP R0, #0x09
		BEQ COMPARE_2V_LSB
		BGT ON_RED
		BLT ON_GREEN

COMPARE_2V_LSB
		LDR R0, [R2]
		BIC R0, R0, #0xF00
		CMP R0, #0xB2
		BGT ON_RED
		BLE ON_GREEN
		
ON_GREEN
		LDR R1, =PB1                    ; R1 = &PF2
		MOV R0, #0x00                   ; R0 = 0x00 (turn off the appliance)
		STR R0, [R1]                    ; [R1] = R0, write to PF2
		
		LDR R1, =PB0                    ; R1 = &PF2
		MOV R0, #0x0E                   ; R0 = 0x04 (turn on the appliance)
		STR R0, [R1]                    ; [R1] = R0, write to PF2
		BL Delay_V2

		LDR R1, =PB0                    ; R1 = &PF2
		MOV R0, #0x00                   ; R0 = 0x04 (turn on the appliance)
		STR R0, [R1]                    ; [R1] = R0, write to PF2
		BL Delay_V2

		B Loop                          ; return
		
ON_RED
		LDR R1, =PB0                    ; R1 = &PF2
		MOV R0, #0x00                   ; R0 = 0x00 (turn off the appliance)
		STR R0, [R1]                    ; [R1] = R0, write to PF2
		
		LDR R1, =PB1                    ; R1 = &PF2
		MOV R0, #0x0E                   ; R0 = 0x04 (turn on the appliance)
		STR R0, [R1]                    ; [R1] = R0, write to PF2
		BL Delay_V2
		
		LDR R1, =PB1                    ; R1 = &PF2
		MOV R0, #0x00                   ; R0 = 0x04 (turn on the appliance)
		STR R0, [R1]                    ; [R1] = R0, write to PF2
		BL Delay_V2
		
		B Loop                          ; return	

OFF_ALL
		LDR R1, =PB1                    ; R1 = &PF2
		MOV R0, #0x00                   ; R0 = 0x00 (turn off the appliance)
		STR R0, [R1]                    ; [R1] = R0, write to PF2		
		LDR R1, =PB0                    ; R1 = &PF2
		MOV R0, #0x00                   ; R0 = 0x00 (turn off the appliance)
		STR R0, [R1]                    ; [R1] = R0, write to PF
		B Loop

Delay									; Delay subroutine
		MOV R7,#0x0F
					
Countdown
		SUBS R7, #1						; subtract and set the flags based on the result
		BNE Countdown		 
		
		BX LR   						; return from subroutine
		
Delay_V2									; Delay subroutine
		MOV R7,#0xFFFFFF
					
Countdown_V2
		SUBS R7, #5						; subtract and set the flags based on the result
		BNE Countdown_V2		 
		
		BX LR   						; return from subroutine

		ALIGN                			; make sure the end of this section is aligned
		END                  			; end of file


