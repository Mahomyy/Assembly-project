;-----------------------------------------------------------
; 32-bit Keyboard functionality.
;-----------------------------------------------------------
IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "keyb.inc"
INCLUDE "movement.inc"

;-----------------------------------------------------------
; CODE
;-----------------------------------------------------------
CODESEG


PROC HandleKey 
USES eax, ebx, ecx, edx
    
   movzx eax, al                     
   movzx eax, [byte ptr offset keybscancodes + eax]

    mov bl, [offset __keyb_keyboardState + eax]  ; Load key state

    ; Check if the key is pressed
    xor dx, dx
    sub dx, bx                                   
    cmp dx, cx
    je @F                                         
    
    mov eax, [ebx]                               
    mov edx, [speed]
    cmp cl, 0
    je DoAdd
    sub eax, edx                               
    jmp @F
DoAdd:
    add eax, edx                                 
    mov [ebx], eax                              
 
 @F:
    RET
ENDP HandleKey 

PROC __check_keys
   USES eax, ebx, ecx, edx

    ; Handle "ESC" key for stopping
    movzx eax, [byte ptr offset keybscancodes + 11]    ; ESC key scancode
    mov bl, [offset __keyb_keyboardState + eax]
    xor dx, dx
    sub dx, bx
    cmp dx, cx
    je @@skipESC
    mov [__running], 0
@@skipESC:

       movzx ebx, [byte ptr offset keybscancodes + 2]    ; get scancode for "S"
    mov bl, [offset __keyb_keyboardState + ebx]        
     xor ax, ax
    sub ax, bx  ; if key is pressed, AX = FFFF, otherwise AX = 0000
    cmp ax, cx
    je @@skipS

    cmp [powerupflag], 1
    je @@speed  ; Jump to game loop if booleanFlag is false

   cmp [powerupflag2], 1
    je @@slow  ; Jump to game loop if booleanFlag is false




call move, 1, 0, 1  
jmp @@skipS 


@@speed:
call move, 1, 0, 2
jmp @@skipS 




@@slow:
call move, 1, 0, 0 


@@skipS:

    ; Handle "Q" key 
    movzx ebx, [byte ptr offset keybscancodes + 1]    ; get scancode for "Q"
    mov bl, [offset __keyb_keyboardState + ebx]        
    xor ax, ax
    sub ax, bx  ; if key is pressed, AX = FFFF, otherwise AX = 0000
    cmp ax, cx
    je @@skipQ

    cmp [powerupflag], 1
    je @@speedQ  ; Jump to game loop if booleanFlag is false


call move, 1, -1, 0  
jmp @@skipQ 


@@speedQ:
call move, 1, -2, 0              
@@skipQ:


    ; Handle "D" key 
    movzx ebx, [byte ptr offset keybscancodes + 3]    ; get scancode for "D"
    mov bl, [offset __keyb_keyboardState + ebx]         ; obtain corresponding key state
    xor ax, ax
    sub ax, bx  ; if key is pressed, AX = FFFF, otherwise AX = 0000
    cmp ax, cx
    je @@skipD
   
 cmp [powerupflag], 1
    je @@speedD  ; Jump to game loop if booleanFlag is false


call move, 1, 1, 0  
jmp @@skipD


@@speedD:
call move, 1, 2, 0              

@@skipD:

    ; Handle "Z" key 
    movzx ebx, [byte ptr offset keybscancodes + 0]    ; get scancode for "Z"
    mov bl, [offset __keyb_keyboardState + ebx]         ; obtain corresponding key state
    xor ax, ax
    sub ax, bx  ; if key is pressed, AX = FFFF, otherwise AX = 0000
    cmp ax, cx
    je @@skipZ
   cmp [powerupflag], 1
    je @@speedZ  ; Jump to game loop if booleanFlag is false


call move, 1, 0, -1  
jmp @@skipZ 


@@speedZ:
call move, 1, 0, -2             
@@skipZ:

    ; Handle "L" key 
    movzx ebx, [byte ptr offset keybscancodes + 7]    ; get scancode for "L"
    mov bl, [offset __keyb_keyboardState + ebx]         ; obtain corresponding key state
    xor ax, ax
    sub ax, bx  ; if key is pressed, AX = FFFF, otherwise AX = 0000
    cmp ax, cx
    je @@skipL

 cmp [powerupflag], 2
    je @@speedL  ; Jump to game loop if booleanFlag is false

     cmp [powerupflag2], 2
    je @@slowL  ; Jump to game loop if booleanFlag is false



call move, 2, 0, 1 
jmp @@skipL 


@@speedL:
call move, 2, 0, 2    
jmp @@skipL 


@@slowL:
call move, 2, 0, 0


@@skipL:

    ; Handle "O" key 
    movzx ebx, [byte ptr offset keybscancodes + 5]    ; get scancode for "O"
    mov bl, [offset __keyb_keyboardState + ebx]         ; obtain corresponding key state
    xor ax, ax
    sub ax, bx  ; if key is pressed, AX = FFFF, otherwise AX = 0000
    cmp ax, cx
    je @@skipO
 cmp [powerupflag], 2
    je @@speedO  ; Jump to game loop if booleanFlag is false


call move, 2, 0, -1 
jmp @@skipO 


@@speedO:
call move, 2, 0, -2               
@@skipO:

    ; Handle "M" key 
    movzx ebx, [byte ptr offset keybscancodes + 8]    ; get scancode for "M"
    mov bl, [offset __keyb_keyboardState + ebx]         ; obtain corresponding key state
    xor ax, ax
    sub ax, bx  ; if key is pressed, AX = FFFF, otherwise AX = 0000
    cmp ax, cx
    je @@skipM
    call move, 2, 1, 0           
@@skipM:


    ; Handle "K" key 
    movzx ebx, [byte ptr offset keybscancodes + 6]    ; get scancode for "K"
    mov bl, [offset __keyb_keyboardState + ebx]         ; obtain corresponding key state
    xor ax, ax
    sub ax, bx  ; if key is pressed, AX = FFFF, otherwise AX = 0000
    cmp ax, cx
    je @@skipK
  cmp [powerupflag], 2
    je @@speedK  ; Jump to game loop if booleanFlag is false


call move, 2, -1, 0
jmp @@skipK 


@@speedK:
call move, 2, -2, 0           
@@skipK:


 ; Handle "" key 
movzx ebx, [byte ptr offset keybscancodes + 12]    ; get scancode for "ENTER"
mov bl, [offset __keyb_keyboardState + ebx]      ; obtain corresponding key state
xor ax, ax
sub ax, bx  ; if key is pressed, AX = FFFF, otherwise AX = 0000
cmp ax, cx
je @@skipenter
  mov [booleanFlag], 0  ; Set the boolean flag to false (0)

@@skipenter:
    RET
ENDP __check_keys

; Installs the custom keyboard handler
PROC __keyb_installKeyboardHandler
    push	ebp
    mov		ebp, esp

	push	eax
	push	ebx
	push	ecx
	push	edx
	push	edi
	push	ds
	push	es
		
	; clear state buffer and the two state bytes
	cld
	mov		ecx, (128 / 2) + 1
	mov		edi, offset __keyb_keyboardState
	xor		eax, eax
	rep		stosw
	
	; store current handler
	push	es			
	mov		eax, 3509h			; get current interrupt handler 09h
	int		21h					; in ES:EBX
	mov		[originalKeyboardHandlerS], es	; store SELECTOR
	mov		[originalKeyboardHandlerO], ebx	; store OFFSET
	pop		es
		
	; set new handler
	push	ds
	mov		ax, cs
	mov		ds, ax
	mov		edx, offset keyboardHandler			; new OFFSET
	mov		eax, 2509h							; set custom interrupt handler 09h
	int		21h									; uses DS:EDX
	pop		ds
	
	pop		es
	pop		ds
	pop		edi
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax	
    
    mov		esp, ebp
    pop		ebp
    ret
ENDP __keyb_installKeyboardHandler

; Restores the original keyboard handler
PROC __keyb_uninstallKeyboardHandler
    push	ebp
    mov		ebp, esp

	push	eax
	push	edx
	push	ds
		
	mov		edx, [originalKeyboardHandlerO]		; retrieve OFFSET
	mov		ds, [originalKeyboardHandlerS]		; retrieve SELECTOR
	mov		eax, 2509h							; set original interrupt handler 09h
	int		21h									; uses DS:EDX
	
	pop		ds
	pop		edx
	pop		eax
	
    mov		esp, ebp
    pop		ebp
    ret
ENDP __keyb_uninstallKeyboardHandler

; Keyboard handler (Interrupt function, DO NOT CALL MANUALLY!)
PROC keyboardHandler
	KEY_BUFFER	EQU 60h			; the port of the keyboard buffer
	KEY_CONTROL	EQU 61h			; the port of the keyboard controller
	PIC_PORT	EQU 20h			; the port of the peripheral

	push	eax
	push	ebx
	push	esi
	push	ds
	
	; setup DS for access to data variables
	mov		ax, _DATA
	mov		ds, ax
	
	; handle the keyboard input
	sti							; re-enable CPU interrupts
	in		al, KEY_BUFFER		; get the key that was pressed from the keyboard
	mov		bl, al				; store scan code for later use
	mov		[__keyb_rawScanCode], al	; store the key in global variable
	in		al, KEY_CONTROL		; set the control register to reflect key was read
	or		al, 82h				; set the proper bits to reset the keyboard flip flop
	out		KEY_CONTROL, al		; send the new data back to the control register
	and		al, 7fh				; mask off high bit
	out		KEY_CONTROL, al		; complete the reset
	mov		al, 20h				; reset command
	out		PIC_PORT, al		; tell PIC to re-enable interrupts

	; process the retrieved scan code and update __keyboardState and __keysActive
	; scan codes of 128 or larger are key release codes
	mov		al, bl				; put scan code in al
	shl		ax, 1				; bit 7 is now bit 0 in ah
	not		ah
	and		ah, 1				; ah now contains 0 if key released, and 1 if key pressed
	shr		al, 1				; al now contains the actual scan code ([0;127])
	xor		ebx, ebx	
	mov		bl, al				; bl now contains the actual scan code ([0;127])
	lea		esi, [__keyb_keyboardState + ebx]	; load address of key relative to __keyboardState in ebx
	mov		al, [esi]			; load the keyboard state of the scan code in al
	; al = tracked state (0 or 1) of pressed key (the value in memory)
	; ah = physical state (0 or 1) of pressed key
	neg		al
	add		al, ah				; al contains -1, 0 or +1 (-1 on key release, 0 on no change and +1 on key press)
	add		[__keyb_keysActive], al	; update __keysActive counter
	mov		al, ah
	mov		[esi], al			; update tracked state
	
	pop		ds
	pop		esi
	pop		ebx
	pop		eax
	
	iretd
ENDP keyboardHandler

;-----------------------------------------------------------
; DATA
;-----------------------------------------------------------
DATASEG
  originalKeyboardHandlerS	dw ?			; SELECTOR of original keyboard handler
  originalKeyboardHandlerO	dd ?			; OFFSET of original keyboard handler
  test_file2 db "IMAGE.bin", 0
  keybscancodes   db 11h, 1Eh, 1Fh, 20h, 2Dh, 18h,25h, 26h, 27h, 39h, 04h, 01h, 39h

  booleanFlag db 1  ; Boolean flag, initially true (1)

  speed dd 1 ; Initial speed

__running db 1 ; if the game is running
__keyb_keyboardState		db 128 dup(?)	; state for all 128 keys
__keyb_rawScanCode			db ?			; scan code of last pressed key
__keyb_keysActive			db ?			; number of actively pressed keys

END
