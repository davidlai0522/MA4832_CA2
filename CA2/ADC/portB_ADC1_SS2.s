; GPIO_PORTB and ADC1 address, SS2

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


; initialize Port B
; activate clock for PortB

		LDR R1, =SYSCTL_RCGCGPIO_R 		; R1 = address of SYSCTL_RCGCGPIO_R
		LDR R0, [R1]                	; 
		ORR R0, R0, #0x02           	; turn on GPIOB clock
		STR R0, [R1]                  
		NOP								; allow time for clock to finish
		NOP
		NOP   

 
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
		BIC R0, R0, #0x0F				; disable SS2 before configuration to 
		STR R0, [R1]    				; prevent erroneous execution if a trigger event were to occur

		LDR R1, =ADC1_EMUX_R       
		LDR R0, [R1]           
		BIC R0, R0, #0x0F00				; SS3 is software trigger
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
		
		LDR R1, =ADC1_SSFIFO2_R			; load SS3 result FIFO into R1
		LDR R0,[R1]
		LDR R2, =Result					; store data
		STR R0,[R2]
		
		LDR R1, =ADC1_ISC_R
		LDR R0, [R1]
		ORR R0, R0, #04					; acknowledge conversion
		STR R0, [R1]
		
		B Loop
Delay									; Delay subroutine
		MOV R7,#0x0F
					
Countdown
		SUBS R7, #1						; subtract and set the flags based on the result
		BNE Countdown		 
		
		BX LR   						; return from subroutine
		ALIGN
		END