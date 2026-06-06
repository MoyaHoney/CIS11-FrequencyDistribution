; Class name: 			26SPR-CIS-11-22428
; Student name:			Justin Sweers, Keanu Arao, Suleny Perez
; Assignment #:			Final Project
; Program name:			Character Counter for Names
; Program description:	Counts the amount of occurances for all legal ASCII characters within a given name.
; Expected input:		Letters (A-Z || a-z); Spaces allowed; Newline delimited. 30 character maximum.
; Expected output:		Each letter occurance that's (<= 1), followed by number of occurances, seperated by newlines. Spaces are not counted.
; Side effects:			Premature termination on illegal character.
; How to run:			Assemble, open assembled program in Simulate.exe, run and check the console for input/output.

.ORIG x3000

; =========================
; Pre-Main Data
; =========================
PROMPT 			.STRINGZ	"Please enter your full name and hit enter: \n"
INP				.BLKW		#50			; Input buffer
; =========================
; Main Routine
; =========================

LD R6, RSA								; R6 is reserved as the RSA (Register Save Area)
JSR INPUT
JSR VALIDATE
JSR OUTPUT

HALT


INPUT
; =========================
; Input Subroutine
; Gets input from the user until newline is entered. Outputs to INP. 30 characters max.
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
	LDR R0, R6, #0
	LDR R1, R6, #1
	LDR R2, R6, #2
	LDR R3, R6, #3
	LDR R4, R6, #4
	LDR R5, R6, #5
	LDR R7, R6, #7
	RET


; =========================
; Invalid Input Subroutine
; Displays error message and ends program
; =========================
INVALID
	LEA R0, ERR
	PUTS
	HALT
ERR				.STRINGZ	"Illegal character entered. Ending program.\n"

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
	; R3 is current character VALUE,
	; R5 is IndexPosition of current character for use in COUNTS array.
	LEA R0, INP
	AND R1, R1, #0
	AND R2, R2, #0
	LDR R3, R0, #0
		
VALLOOP									; Validate subroutine "Loop" label.
	; Test if (current character value) == (ASCII Space)
	LD R2, ASC_SP
	NOT R2, R2							; Two's compliment to negative.
	ADD R2, R2, #1
	ADD R3, R2, R3
	BRz VALCONT							; Current character is (ASCII Space), initiate C-style "continue".
	LD R2, ASC_SP						; Restore back to positive.
	ADD R3, R2, R3
	; Test if (current character value) == (UPPERCASE)
	; if ch >= ASC_LA AND ch <= ASC_LZ do:
        ; ch <- ch - (ASC_LA - ASC_UA)
        ; COUNTS[ch - ASC_UA] <- COUNTS[ch - ASC_UA] + 1
        ; continue
	LD R2, ASC_UA						; R2 == ASC_UA
	NOT R2, R2							; Two's compliment to negative.
	ADD R2, R2, #1
	AND R5, R5, #0						; Copy R2 to R5
	ADD R5, R2, R5
	ADD R5, R3, R5						; R5 == ASC_UA - ch (ch's index in COUNTS)
	BRn INVALID							; Value is below ASCII range.
	; Get upper limit of ASCII capital Letters.
	LD R2, ASC_UZ						; R2 == ASC_UZ
	NOT R2, R2							; Two's compliment to negative.
	ADD R2, R2, #1
	ADD R3, R2, R3						; R3 = ASC_UZ - ch
	BRp VALTLC							; Test for upper bound, INCLUDING lowercase
	LD R2, ASC_UA
	NOT R2, R2							; Two's compliment of ASC_UA
	ADD R2, R2, #1
	ADD R3, R2, R3						; ASC_UA - ch
	AND R2, R2, #0						; Clear R2 for reuse.
	LD R2, ASC_UZ						; Restore R3 from previous testing value (ASC_UZ - ch)
	ADD R3, R2, R3
	BR ADDCOU
	
VALTLC									; Validate subroutine "Test Lower Case" label.
	LD R2, ASC_UZ						; Restore R3 back to base position from offset before branch point.
	ADD R3, R2, R3
	LD R2, ASC_LA						; R2 == ASC_LA
	NOT R2, R2							; Two's compliment to negative.
	ADD R2, R2, #1
	AND R5, R5, #0						; Copy R2 to R5
	ADD R5, R2, R5
	ADD R5, R3, R5						; R5 == ASC_LA - ch (ch's index in COUNTS)
	BRn INVALID							; Value is between uppercase and lowercase, non-alphabetical character.
	; Get upper limit of ASCII lowercase letters.
	LD R2, ASC_LZ						; R2 == ASC_LZ
	NOT R2, R2							; Two's compliment to negative.
	ADD R2, R2, #1
	ADD R3, R2, R3						; R3 = ASC_LZ - ch
	; If non-positive, ch is within lowercase bounds
	BRp INVALID
	LD R2, ASC_LZ						; Restore R3 == ch
	ADD R3, R2, R3
	AND R2, R2, #0						; Get constant of #-32 to offset lowercase to uppercase ch.
	ADD R2, R2, #-16
	ADD R2, R2, #-16
	ADD R3, R2, R3						; Offset ch to become a uppercase letter.
	
ADDCOU
	LEA R0, COUNTS						; Get address of COUNTS.
	ADD R0, R0, R5						; Offset by index of number captured.
	LDR R2, R0, #0						; R2 = COUNTS[ch]++, save back to array.
	ADD R2, R2, #1
	STR R2, R0, #0
	
VALCONT									; Validate subroutine "Continue" label. C-style "for-loop" processes handled here. Branched from various places inside VALLOOP.
	; Increment (counter), set new (current character) ptr & value
	ADD R1, R1, #1						; Increment counter
	LEA R0, INP							; Set new current character ptr
	ADD R0, R0, R1
	LDR R3, R0, #0						; Set new character value
	; Test loop condition
	BRz VALEXIT							; Current character is 0x00, which is not a valid keyboard character, end loop.
	BR VALLOOP
	
	
VALEXIT
	LDR R0, R6, #0
	LDR R1, R6, #1
	LDR R2, R6, #2
	LDR R3, R6, #3
	LDR R4, R6, #4
	LDR R5, R6, #5
	LDR R7, R6, #7
	RET


; =========================
; Output Subroutine
; Displays only letters with non-zero counts
; =========================

OUTPUT
	STR R0, R6, #0
	STR R1, R6, #1
	STR R2, R6, #2
	STR R3, R6, #3
	STR R4, R6, #4
	STR R5, R6, #5
	STR R7, R6, #7
	
	AND R1, R1, #0		; R1 == Loop Counter

OUTLOOP
	ADD R2, R1, #-15	; R2 == #-26 (for the 26 letters of the alphabet?)
	ADD R2, R2, #-11
	BRz OUTDONE

	LEA R3, COUNTS		; address of counts[i]
	ADD R3, R3, R1
	
	LDR R4, R3, #0		; load count
	
	BRz NEXTCHAR		; if count = 0 go to next character
	
	LEA R0, OUTPUT1		; print "Count of "
	PUTS

	LD R5, ASC_UA		; print letter
	ADD R0, R1, R5
	OUT
	
	LEA R0, OUTPUT2		; print " is "
	PUTS

	;LD R5, ASC_Z
	;ADD R0, R4, R5
	;OUT
	
	LD R5, ASC_UA		; Offset to beggining of numeric ASCII characters
	ADD R5, R5, #-16
	ADD R5, R5, #-1
	ADD R0, R4, R5		; Offset again by number of appearences of character, up to nine.
	OUT

	LD R0, ASC_NL
	OUT

NEXTCHAR
	ADD R1, R1, #1
	BR OUTLOOP
OUTDONE
	LDR R0, R6, #0
	LDR R1, R6, #1
	LDR R2, R6, #2
	LDR R3, R6, #3
	LDR R4, R6, #4
	LDR R5, R6, #5
	LDR R7, R6, #7
RET


	
; Data

COUNTS			.BLKW		#26			; Count buffer for A-Z
RSA				.BLKW		#8			; Register Save Area

ASC_UA  		.FILL		#65			; ASCII Uppercase "A"
ASC_UZ			.FILL		#90			; ASCII Uppercase "Z"
ASC_LA			.FILL		#97			; ASCII Lowercase "a"
ASC_LZ			.FILL		#122		; ASCII Lowercase "z"
ASC_SP			.FILL		#32			; ASCII Space " "
ASC_NL			.FILL		#10			; ASCII Newline
IN_LEN			.FILL		#50			; Same value as input buffer size

OUTPUT1			.STRINGZ	"Count of "
OUTPUT2			.STRINGZ	" is "

.END