; The SERIAL RS232 IO base, which depends on the IO and Hi/Lo jumper settings on the card.
IO_BASE = $9FE8

RX_BUFFER           = IO_BASE               ;READ ONLY
TX_HOLDING          = IO_BASE               ;WRITE ONLY
INTERRUPT_ENABLE    = IO_BASE + 1
INTERRUPT_IDENT     = IO_BASE + 2           ;READ ONLY
FIFO_CONTROL        = IO_BASE + 2           ;WRITE ONLY
LINE_CONTROL        = IO_BASE + 3
MODEM_CONTROL       = IO_BASE + 4
LINE_STATUS         = IO_BASE + 5
MODEM_STATUS        = IO_BASE + 6
SCRATCH             = IO_BASE + 7

; Used to set baud rate by setting Divsor Latch to 1 (LINE_STATUS)
DIVISOR_LATCH_LOW   = IO_BASE
DIVISOR_LATCH_HI    = IO_BASE + 1


;; Line Control Register Flags
; Bit 7				: Divisor Latch
; Bit 6				: Break Control
; Bit 5				: Sticky Parity
; Bit 4				: Parity Select
; Bit 3				: Parity Enable (0 for none)
; Bit 2				: Stop Bits (0 to 1 stop bit)
; Bits 0 & 1	: Word Length (both to 1 = 8-bits)
; No Partity, 1 Stop, 8-Bits
LCR_SETUP  = %00000011

;; Interrupt Enable Flags
; Bits 7-4		: Unused (always cleared)
; Bit 3				: 1 = Enable Modem Status Interrupt
; Bit 2				: 1 = Enable Receiver Line Status Intterupt
; Bit 1				: 1 = Enable THRE (Transmission Holding Register) Interrupt
; Bit 0				: 1 = Enable Received Data Available Interrupt
INTR_SETUP = %00000001

;; FIFO Control Register Flags
; Bits 7-6		: Buffer size (00 = $01, 01 = $04, 10 = $08, 11 = $0E)
; Bits 5-4		: Reserved
; Bit 3				: When FCR0 set, assert !RXRDY and !TXRDY pins
; Bit 2				: Clears TX FIFO and counter
; Bit 1				: Clears RX FIFO and counter
; Bit 0				: Enable FIFO Buffers
FIFO_SETUP = %00000111

;BAUD_RATE_DIVISOR = $0025
; 9600 (for testing 9-pin RS232)
;BAUD_RATE_DIVISOR = $0079
; 2400
;BAUD_RATE_DIVISOR = $01E0
; 9600 (for testing 9-pin RS232)
BAUD_RATE_DIVISOR = $0001

;;ADDRESS WHERE THE LOW RAM SERIAL VALUE IS STORED
LO_STORE_ADDR = $22

;; ADDRESS WHERE THE HIGH RAM SERIAL VALUE IS STORED
HI_STORE_ADDR = $24

;; BANK WHERE THE SERIAL VALUE IS STORED
STORE_BANK = $26
