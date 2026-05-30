; Class name: 			26SPR-CIS-11-22428
; Student name:			Justin Sweers, Keanu Arao, Suleny Perez
; Assignment #:			Final Project
; Program name:			Character Counter for Names
; Program description:	Counts the amount of occurances for all legal ASCII characters within a given name.
; Expected input:		Letters (A-Z || a-z); Spaces allowed; Newline delimited. 100 character maximum.
; Expected output:		Each letter occurance that's (<= 1), followed by number of occurances, seperated by newlines. Spaces are not counted.
; Side effects:			Premature termination on illegal character.
; How to run:			Assemble, open assembled program in Simulate.exe, run and check the console for input/output.

.ORIG x3000

; =========================
; Main Routine
; =========================

LD R6, RSA								; R6 is reserved as the RSA (Register Save Area)
JSR INPUT

HALT


INPUT
; =========================
; Input Subroutine
; Gets input from the user until newline is entered. Outputs to INP. 100 characters max.
; =========================
	; Save registers R0-R7 to the stack, excluding R6 since it is constant.
	STR R0, R6, #0
	STR R1, R6, #1
	STR R2, R6, #2
	STR R3, R6, #3
	STR R4, R6, #4
	STR R5, R6, #5
	STR R7, R6, #7
	; Prompt user for input.
	LEA R0, PROMPT
	PUTS
	; Address of Input Buffer saved to R3.
	LEA R3, INP
	; Init character counter at R1 to #1, and get initial character.
	GETC
	ADD R1, R1, #1
	OUT
	
INLOOP									; Input subroutine "loop" label.
	; Test if string has hit upper bound.
	LD R4, IN_LEN
	NOT R4, R4							; Two's compliment to negative.
	ADD R4, R4, #1
	ADD R1, R1, R4
	BRz INDONE							; Input buffer filled, must return.
	LD R4, IN_LEN						; Two's compliment back to positive. 
	ADD R1, R1, R4
	; Test if character in R0 is Newline.
	LD R2, ASC_NL
	NOT R2, R2							; Two's compliment to negative.
	ADD R2, R2, #1
	ADD R0, R0, R2
	BRz INDONE							; Newline encountered, input is finished.
	LD R2, ASC_NL						; Two's compliment back to positive.
	ADD R0, R0, R2
	; Store the character (R0) to the input buffer (R3), offset by the character counter (R1).
	ADD R3, R1, R3
	STR R0, R3, #-1						; Offset by -1 to account for the difference in (character counter)'s and (input buffer)'s starting index.
	NOT R1, R1
	ADD R1, R1, #1
	ADD R3, R1, R3
	NOT R1, R1
	ADD R1, R1, #1
	; Get another character, increment character counter by #1.
	GETC
	OUT
	ADD R1, R1, #1
	BR INLOOP

INDONE									; Input subroutine "Done" label. Used to escape from INLOOP.
	; Load registers R0-R7 to the stack, excluding R6 since it is constant.
	LTR R0, R6, #0
	LTR R1, R6, #1
	LTR R2, R6, #2
	LTR R3, R6, #3
	LTR R4, R6, #4
	LTR R5, R6, #5
	LTR R7, R6, #7
	RET


; =========================
; Invalid Input Subroutine
; Displays error message and ends program
; =========================
INVALID
	LEA R0, ERR
	PUTS
	HALT


; =========================
; Validate Subroutine
; Validates input and counts letter frequency
; =========================
VALIDATE
; Save registers R0-R7 to the stack, excluding R6 since it is constant.
STR R0, R6, #0
	STR R1, R6, #1
	STR R2, R6, #2
	STR R3, R6, #3
	STR R4, R6, #4
	STR R5, R6, #5
	STR R7, R6, #7

	; Init values — 
	; R0 is the current character PTR,
	; R1 is iterative counter,
	; R2 is compartive (==, >=, etc.) operand,
	; R3 is current character VALUE.
	LEA R0, INP
	AND R1, R1, #0
	AND R2, R2, #0
	LDI R3, R0
		
VALLOOP									; Validate subroutine "Loop" label.
	; Test if (current character value) == (ASCII Space)
	LD R2, ASC_SP
	NOT R2, R2							; Two's compliment to negative.
	ADD R2, R2, #1
	ADD R3, R2, R3
	BRz VALCONT							; Current character is (ASCII Space), initiate C-style "continue".
	LD R2, ASC_SP						; Restore back to positive.
	
	
VALCONT									; Validate subroutine "Continue" label. C-style "for-loop" processes handled here. Branched from various places inside VALLOOP.
	; Increment (counter), set new (current character) ptr & value
	ADD R1, R1, #1						; Increment counter
	LEA R0, INP							; Set new current character ptr
	ADD R0, R0, R1
	LDI R3, R0							; Set new character value
	; Test loop condition
	BRz VALEXIT							; Current character is 0x00, which is not a valid keyboard character, end loop.
	BR VALLOOP
	
	
VALEXIT
	LTR R0, R6, #0
	LTR R1, R6, #1
	LTR R2, R6, #2
	LTR R3, R6, #3
	LTR R4, R6, #4
	LTR R5, R6, #5
	LTR R7, R6, #7
	RET
	
; Data

COUNTS			.BLKW		#26			; Count buffer for A-Z
INP				.BLKW		#100		; Input buffer
RSA				.BLKW		#80			; Register Save Area

ASC_UA  		.FILL		#65			; ASCII Uppercase "A"
ASC_UZ			.FILL		#90			; ASCII Uppercase "Z"
ASC_LA			.FILL		#97			; ASCII Lowercase "a"
ASC_LZ			.FILL		#122		; ASCII Lowercase "z"
ASC_SP			.FILL		#32			; ASCII Space " "
ASC_NL			.FILL		#10			; ASCII Newline
IN_LEN			.FILL		#100		; Same value as input buffer size

PROMPT 			.STRINGZ	"Please enter your full name and hit enter: \n"
ERR				.STRINGZ	"Illegal character entered. Ending program.\n"
OUTPUT1			.STRINGZ	"Count of "
OUTPUT2			.STRINGZ	" is "

.END