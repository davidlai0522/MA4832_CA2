; adc_single_ch.s
; samples one ADC channel, PortE bit 5 (PE5), using Sample Sequencer 3(SS3)

; GPIO_PORTE and ADC0 address

GPIO_PORTE_AFSEL_R 	EQU 0x40024420
GPIO_PORTE_DEN_R   	EQU 0x4002451C
GPIO_PORTE_AMSEL_R 	EQU 0x40024528

ADC0_ACTSS_R   		EQU 0x40038000
ADC0_PC_R           EQU	0x40038FC4
ADC0_SSPRI_R        EQU	0x40038020
ADC0_EMUX_R			EQU	0x40038014
ADC0_SSMUX3_R       EQU 0x400380A0
ADC0_SSCTL3_R       EQU	0x400380A4
ADC0_IM_R           EQU 0x40038008
ADC0_PSSI_R			EQU 0x40038028
ADC0_RIS_R			EQU	0x40038004	
ADC0_SSFIFO3_R		EQU	0x400380A8	
ADC0_ISC_R			EQU	0x4003800C	

; PORT F LED CONFIGURATION
GPIO_PORTF_DATA_R  EQU 0x400253FC
GPIO_PORTF_DIR_R   EQU 0x40025400
GPIO_PORTF_AFSEL_R EQU 0x40025420
GPIO_PORTF_PUR_R   EQU 0x40025510
GPIO_PORTF_DEN_R   EQU 0x4002551C
GPIO_PORTF_AMSEL_R EQU 0x40025528
GPIO_PORTF_PCTL_R  EQU 0x4002552C
PF0                EQU 0x40025004	; 	SW2 - negative logic
PF1                EQU 0x40025008	;	RED LED
PF2                EQU 0x40025010	; 	BLUE LED - ORIG
PF3                EQU 0x40025020	;	GREEN LED
PF4                EQU 0x40025040	;	SW1 - ORIG -negative logic
PFA				   EQU 0x40025038	; 	3 colours :

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
; initialize Port E
; activate clock for PortE

		LDR R1, =SYSCTL_RCGCGPIO_R 		; R1 = address of SYSCTL_RCGCGPIO_R
		LDR R0, [R1]                	; 
		ORR R0, R0, #0x30           	; turn on GPIOE and GPIOF clock
		STR R0, [R1]                  
		NOP								; allow time for clock to finish
		NOP
		NOP   
		; TODO: edit until here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; no need to unlock PE4 and PF2
 
; Config Port E
; enable alternate function
		LDR R1, =GPIO_PORTE_AFSEL_R     
		LDR R0, [R1]                     
		ORR R0, R0, #0x20      			; enable alternate function on PE5
		STR R0, [R1] 
		
; disable digital port
		LDR R1, =GPIO_PORTE_DEN_R   	
		LDR R0, [R1]                    
		BIC R0, R0, #0x20               ; disable digital I/O on PE5
		STR R0, [R1]    
	 			
; enable analog mode
		LDR R1, =GPIO_PORTE_AMSEL_R     
		LDR R0, [R1]                    
		ORR R0, R0, #0x20    			; enable PE5 analog function
		STR R0, [R1]       

; activate clock for ADC0
		LDR R1, =SYSCTL_RCGCADC_R 		 
		LDR R0, [R1]                	 
		ORR R0, R0, #0x01           	; activate ADC0
		STR R0, [R1]                  
	  
		BL Delay						; delay subroutine -> allow time for clock to finish
		
		LDR R1, =ADC0_PC_R       
		LDR R0, [R1]           
		BIC R0, R0, #0x0F				; clear max sample rate field
		ORR R0, R0, #0x1     			; configure for 125K samples/sec
		STR R0, [R1]    

		LDR R1, =ADC0_SSPRI_R       
		LDR R0, =0x0123           		; SS3 is highest priority
		STR R0, [R1]    

		LDR R1, =ADC0_ACTSS_R       
		LDR R0, [R1]           
		BIC R0, R0, #0x08				; disable SS3 before configuration to 
		STR R0, [R1]    				; prevent erroneous execution if a trigger event were to occur

		LDR R1, =ADC0_EMUX_R       
		LDR R0, [R1]           
		BIC R0, R0, #0xF000				; SS3 is software trigger
		STR R0, [R1]    

		LDR R1, =ADC0_SSMUX3_R      
		LDR R0, [R1]           
		BIC R0, R0, #0x000F				; clear SS3 field
		ADD R0, R0, #8					; set channel -> select input pin AIN8
		STR R0, [R1]    

		LDR R1, =ADC0_SSCTL3_R       
		LDR R0, =0x0006           		; configure 1st sample -> not reading Temp sensor, not differentially sampled,
		STR R0, [R1]    				; assert raw interrupt signal at the end of conversion, first sample is last sample
		
		LDR R1, =ADC0_IM_R     
		LDR R0, [R1]           
		BIC R0, R0, #0x0008				; disable SS3 interrupts
		STR R0, [R1]    
		
		LDR R1, =ADC0_ACTSS_R      
		LDR R0, [R1]           
		ORR R0, R0, #0x0008     		; enable SS3
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
			
		LDR R4, =PF4                    ; R4 = &PF4

Loop	
		LDR R1, =ADC0_PSSI_R      
		MOV R0, #0x08					; initiate sampling in the SS3  
		STR R0, [R1]    
		
		LDR R1, =ADC0_RIS_R   			; R1 = address of ADC Raw Interrupt Status
		LDR R0, [R1]           			; check end of a conversion
		CMP	R0, #0x08    				; when a sample has completed conversion -> a raw interrupt is enabled
		BNE	Loop    
		
		LDR R1, =ADC0_SSFIFO3_R			; load SS3 result FIFO into R1
		LDR R0,[R1]
		LDR R2, =Result					; store data
		STR R0,[R2]
		
		LDR R1, =ADC0_ISC_R
		LDR R0, [R1]
		ORR R0, R0, #08					; acknowledge conversion
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
		LDR R1, =PF1                    ; R1 = &PF2
		MOV R0, #0x00                   ; R0 = 0x00 (turn off the appliance)
		STR R0, [R1]                    ; [R1] = R0, write to PF2
		
		LDR R1, =PF3                    ; R1 = &PF2
		MOV R0, #0x0E                   ; R0 = 0x04 (turn on the appliance)
		STR R0, [R1]                    ; [R1] = R0, write to PF2
		BL Delay_V2

		LDR R1, =PF3                    ; R1 = &PF2
		MOV R0, #0x00                   ; R0 = 0x04 (turn on the appliance)
		STR R0, [R1]                    ; [R1] = R0, write to PF2
		BL Delay_V2

		B Loop                          ; return
		
ON_RED
		LDR R1, =PF3                    ; R1 = &PF2
		MOV R0, #0x00                   ; R0 = 0x00 (turn off the appliance)
		STR R0, [R1]                    ; [R1] = R0, write to PF2
		
		LDR R1, =PF1                    ; R1 = &PF2
		MOV R0, #0x0E                   ; R0 = 0x04 (turn on the appliance)
		STR R0, [R1]                    ; [R1] = R0, write to PF2
		BL Delay_V2
		
		LDR R1, =PF1                    ; R1 = &PF2
		MOV R0, #0x00                   ; R0 = 0x04 (turn on the appliance)
		STR R0, [R1]                    ; [R1] = R0, write to PF2
		BL Delay_V2
		
		B Loop                          ; return	

OFF_ALL
		LDR R1, =PF1                    ; R1 = &PF2
		MOV R0, #0x00                   ; R0 = 0x00 (turn off the appliance)
		STR R0, [R1]                    ; [R1] = R0, write to PF2		
		LDR R1, =PF3                    ; R1 = &PF2
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


