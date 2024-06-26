.INCLUDE "macros.inc"
.INCLUDE "x16.inc"
.INCLUDE "serial.inc"
.SEGMENT "LOADADDR"
	.WORD $0801
.SEGMENT "BASICSTUB"
	.WORD START-2
	.BYTE $00,$00,$9E
	.BYTE "2061"
	.BYTE $00,$00,$00
.SEGMENT "STARTUP"
START:
	JMP MAIN
.SEGMENT "CODE"
;; USE cat BUILD.PRG > /dev/ttyUSB0 TO SEND FILE
MAIN:
	JSR INIT_IRQ
	JSR SETUP
	JSR UART_SETUP
	RTS
SETUP:
	LDA	#$FF					;SET STORE ADDRESS TO $A000
	STA STORE_ADDR				
	LDA #$9F
	STA STORE_ADDR + 1
	LDA #$01
	STA STORE_BANK				;SET STORE BANK TO 1
	RTS
UART_SETUP:
	LDA #INTR_SETUP				;ENABLE THE DATA READY INTERRUPT ON THE UART
	STA INTERRUPT_ENABLE		
	LDA #FIFO_SETUP				;ENABLE FIFO BUFFER
	STA FIFO_CONTROL			
	LDA #%10000000				;SETS BAUD RATE DIVISOR TO 1
	STA LINE_CONTROL			
	LDA #<BAUD_RATE_DIVISOR	
	STA DIVISOR_LATCH_LOW
	LDA #>BAUD_RATE_DIVISOR
	STA DIVISOR_LATCH_HI
	LDA #LCR_SETUP				;SETS WORD LENGTH TO 8 BITS
	STA LINE_CONTROL
	LDA #%00100011				;MAKES UART READY TO SEND AND RECIEVE DATA
	STA MODEM_CONTROL			;ALSO ENABLE AUTOFLOW CONTROL
	RTS
DEFAULT_IRQ: .ADDR 0
IRQ_HANDLING:
	INIT_IRQ:	
		LDA CINV				;SAVE THE DEFAULT IRQ POINTER
		STA DEFAULT_IRQ
		LDA CINV+1
		STA DEFAULT_IRQ+1
		SEI						;DISABLE INTERRUPTS
		LDA #<CUSTOM_IRQ		;REPLACE IRQ POINTER WITH CUSTOM POINTER
		STA CINV
		LDA #>CUSTOM_IRQ
		STA CINV+1
		CLI						;RE-ENABLE INTERRUPTS
		RTS
	CUSTOM_IRQ:
		JSR SERIAL_IRQ
		JMP (DEFAULT_IRQ)
	SERIAL_IRQ:
		LDA INTERRUPT_IDENT		;DETERMINE IF INTERRUPT IS CAUSED BY UART
		AND #%00000100
		CMP #%00000100
		BEQ TRANSFER_DATA
		RTS
TRANSFER_DATA:
		LDA STORE_ADDR				;INCREMENT THE STORE ADDRESS POINTER LOW BYTE
		INC
		STA STORE_ADDR
		CMP #$00					;IF THE POINTER OVERFLOWED CONTINUE
		BNE @STORE_DATA
		LDA STORE_ADDR + 1			;INCREMENT THE STORE ADDRESS POINTER HIGH BYTE
		INC
		STA STORE_ADDR + 1
		CMP #$C0					;IF THE HIGH BYTE IS $C0, THEN CONTINUE
		BNE @STORE_DATA
		LDA STORE_BANK				;INCREMENT THE BANK TO STORE THE DATA
		INC
		STA STORE_BANK
		LDA #$A0
		STA STORE_ADDR + 1			;RESET THE STORE ADDRESS POINTER
	@STORE_DATA:
		LDA STORE_BANK				;SET THE BANK TO STORE THE DATA
		STA $00
		LDA RX_BUFFER				;READ DATA FROM THE UART AND STORE IT TO BANKED RAM
		STA (STORE_ADDR)
	@DISPLAY_LOADING:
		LDA LINE_STATUS				;CHECK IF ALL DATA HAS BEEN SENT
		AND #%00000001
		CMP #$01
		BEQ @DETECT_DATA			;IF ALL DATA HAS BEEN SENT CONTINUE
		LDA VERA_H
		ORA #%00100001				;SET VERA AUTOINCREMENT TO 2
		AND #%00100001
		STA VERA_H	
		LDA #$66					;PRINT CHARACTER $66 TO SCREEN
		STA VERA_DATA0				
	@DETECT_DATA:
		LDA LINE_STATUS				;IF THERE IS STILL DATA IN THE FIFO
		ORA #%11111110				;KEEP READING AND STORING THE DATA
		CMP #$FF
		BEQ TRANSFER_DATA
		RTS