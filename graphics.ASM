IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "movement.inc"
INCLUDE "rand.inc"
INCLUDE "graphics.inc"

DRAW_BUFFER_OFFSET equ offset screenBuffer
SCREEN_WIDTH equ 320
SCREEN_HEIGHT equ 200
PIXEL_COUNT equ SCREEN_WIDTH*SCREEN_HEIGHT

STARS_AMOUNT equ 100 ; 320

; -------------------------------------------------------------------
; CODE
; -------------------------------------------------------------------
CODESEG

PROC draw_pixel
	arg @@x:dword, @@y:dword
	USES edi, eax

	mov edi , DRAW_BUFFER_OFFSET
	mov eax, SCREEN_WIDTH
	mul [@@y]
	add eax, [@@x]

	cmp eax, PIXEL_COUNT
	jb @@draw
	ret

	@@draw:
		add edi, eax
		mov al, 15
		mov [edi], al
		
	ret

ENDP draw_pixel

PROC draw_sprite
	ARG @@spritePtr:dword , @@x:dword , @@y:dword
	LOCAL @@w:dword , @@h:dword, @@w_2:dword, @@h_2:dword
	USES eax , ebx , ecx , edx , esi , edi

	mov esi , [ @@spritePtr ]
	xor eax , eax
	lodsw ; read width in AX
	mov [@@w] , eax
	lodsw ; read height in AX
	mov [@@h] , eax
	
	;;check if it fits
	mov eax, [@@y]
	add eax, [@@h]
	cmp eax, SCREEN_HEIGHT
	ja @@return
	
	mov edi, DRAW_BUFFER_OFFSET
	mov eax, [@@y]
	mov ebx, SCREEN_WIDTH
	mul ebx
	add edi, eax
	add edi, [@@x]
	mov ecx, [@@h]
	
	@@drawLine:
		push ecx

		mov ecx , [@@w] ; need to copy a line of the sprite
		rep movsb ; copy from esi to edi
	
		add edi , SCREEN_WIDTH
		sub edi , [@@w] ; edi now points to the next line in dst
	
		pop ecx
		dec ecx
		jnz @@drawLine
	
	@@return:
	ret
ENDP draw_sprite

PROC set_video_mode ;; call with 1 to turn on, 0 to turn off
	arg @@on:dword
	uses eax
	
	cmp [@@on], 1
	je @@turn_on

	@@turn_off:
		mov ax, 03h
		jmp @@call_video_mode_interrupt

	@@turn_on:
		mov ax, 13h
		
	@@call_video_mode_interrupt:
		int 10h
 
	ret
ENDP set_video_mode

PROC add_star
	uses esi, ecx, eax, edx
	
	;;tests if should add a star 1/4 chance
	call rand16 ;; generates a random 16 bit number in eax
	cmp eax, 16383 ;; 1/4 of a 16bit number
	ja @@return 
	
	;; get random x coordinate
	xor edx, edx
	mov esi, SCREEN_WIDTH
	div esi ;; now the modulo of eax is in edx
	;; adds the star to the stars array

	mov ecx, STARS_AMOUNT
	mov esi, offset stars
	@@add_particle:
		cmp [DWORD PTR esi], 1
		je @@next
		mov [DWORD PTR esi], 1 ;; active?
		add esi, 4
		mov [DWORD PTR esi], edx ;; x coor
		add esi, 8 
		mov [DWORD PTR esi], 0 ;; y coor
		jmp @@return
	@@next:
		add esi, 12
	LOOP @@add_particle
	
	@@return:
	ret
ENDP add_star

PROC update_stars ;; updates and draws the stars
	uses esi, ecx, eax
	
	mov esi, offset stars
	mov ecx, STARS_AMOUNT
	@@update_particle:
		cmp [DWORD PTR esi], 1
		jne @@next
		INC [DWORD PTR esi + 8]
		call draw_pixel, [DWORD PTR esi + 4], [DWORD PTR esi + 8]

		cmp [DWORD PTR esi + 8], SCREEN_HEIGHT
		jb @@next 
		mov [DWORD PTR esi], 0
		mov [DWORD PTR esi + 4], 0
		mov [DWORD PTR esi + 8], 0
	@@next:
		add esi, 12
	LOOP @@update_particle	

	ret
ENDP update_stars


PROC update_powerup
    uses esi, ecx, eax, edx

    ; Increment the powerup timer if it's inactive
    cmp [powerup_active], 0
    jne @@update_position ; Skip timer if already active
    inc [powerup_timer]

    ; Check if the timer has reached the limit (10 seconds = 600 frames)
    cmp [powerup_timer], 600
    jl @@return ; Wait until the timer expires

    ; Reactivate the powerup
    mov [powerup_active], 1
    mov [powerup_timer], 0

    ; Reset the powerup's position
    call rand16            ; Generate a random X coordinate
    xor edx, edx           ; Clear edx for division
    mov esi, SCREEN_WIDTH  ; Set divisor
    div esi                ; edx contains random X coordinate
    mov [powerup_x], edx   ; Store X coordinate
    mov [powerup_y], -1    ; Start above the top of the screen

@@update_position:
    ; Update the powerup's vertical position (move down the screen)
    inc [powerup_y]

    ; Draw the powerup sprite at the new position
    call draw_sprite, offset powerup_sprite, [powerup_x], [powerup_y]

    ; If the powerup moves off the screen, deactivate it
    cmp [powerup_y], SCREEN_HEIGHT
    jl @@return ; Powerup is still on screen
    mov [powerup_x], -1 ; Deactivate powerup
    mov [powerup_y], -1 ; Deactivate powerup

    mov [powerup_active], 0 ; Deactivate powerup

	@@return:
    	ret
ENDP update_powerup

PROC update_slow
    uses esi, ecx, eax, edx

    ; Increment the powerup timer if it's inactive
    cmp [slow_active], 0
    jne @@update_position2 ; Skip timer if already active
    inc [slow_timer]

    ; Check if the timer has reached the limit (10 seconds = 600 frames)
    cmp [slow_timer], 350
    jl @@return2 ; Wait until the timer expires

    ; Reactivate the powerup
    mov [slow_active], 1
    mov [slow_timer], 0

    ; Reset the powerup's position
    call rand16            ; Generate a random X coordinate
    xor edx, edx           ; Clear edx for division
    mov esi, SCREEN_WIDTH  ; Set divisor
    div esi                ; edx contains random X coordinate
    mov [slower_x], edx   ; Store X coordinate
    mov [slower_y], -1    ; Start above the top of the screen

@@update_position2:
    ; Update the powerup's vertical position (move down the screen)
    inc [slower_y]

    ; Draw the powerup sprite at the new position
    call draw_sprite, offset slow_sprite, [slower_x], [slower_y]

    ; If the powerup moves off the screen, deactivate it
    cmp [slower_y], SCREEN_HEIGHT
    jl @@return2 ; Powerup is still on screen
    mov [slower_x], -1 ; Deactivate powerup
    mov [slower_y], -1 ; Deactivate powerup

    mov [slow_active], 0 ; Deactivate powerup

	@@return2:
    	ret
ENDP update_slow


PROC finishline
    uses esi, ecx, eax, edx

    ; Increment the powerup timer if it's inactive
    cmp [finishline_active], 0
    jne @@update_position3 ; Skip timer if already active
    inc [finishline_timer]

    ; Check if the timer has reached the limit (10 seconds = 600 frames)
    cmp [finishline_timer], 200
    jl @@return3 ; Wait until the timer expires

    ; Reactivate the powerup
    mov [finishline_active], 1
    mov [finishline_timer], 0

    ; Reset the powerup's position
    call rand16            ; Generate a random X coordinate
    xor edx, edx           ; Clear edx for division
    mov esi, SCREEN_WIDTH  ; Set divisor
    div esi                ; edx contains random X coordinate
    mov [finishline_y], -1    ; Start above the top of the screen

@@update_position3:
    ; Update the powerup's vertical position (move down the screen)
    inc [finishline_y]

   

    ; If the powerup moves off the screen, deactivate it
    cmp [finishline_y], SCREEN_HEIGHT
    jl @@return3 ; Powerup is still on screen
    mov [finishline_y], -1 ; Deactivate powerup

    mov [finishline_active], 1 ; Deactivate powerup

	@@return3:
    	ret
ENDP finishline



; opens file, read contents to imagedata, closes file
PROC open_file
	ARG	 @@filepathptr:dword, @@datapathptr:dword
	USES eax, ebx, ecx, edx, esi, edi
	
	; open file, get filehandle in AX
	mov al, 0 ; read only
	mov edx, [@@filepathptr]
	mov ah, 3dh
	int 21h
	
	mov  edx, offset openErrorMsg
	jc @@print_error ; carry flag is set if error occurs

	; read file data
	mov bx, ax ; move filehandle to bx
	mov ecx, PIXEL_COUNT
	mov edx, [@@datapathptr]
	mov ah, 3fh
	int 21h

	mov  edx, offset readErrorMsg
	jc @@print_error
	
	; close file
	mov ah, 3Eh
	int 21h
	
	mov  edx, offset closeErrorMsg
	jc @@print_error
	ret

	@@print_error:
		call set_video_mode, 0
	
		mov	ah,00h
		int	16h
		ret
ENDP open_file

PROC draw_file 
	ARG @@datapathptr:dword
	uses edi, ecx, esi
	
	mov esi, [@@datapathptr]
	mov edi, 0A0000h
	mov ecx, PIXEL_COUNT
	rep movsb
	ret
ENDP draw_file

PROC clear_screen
	USES edi, ecx, eax

	mov edi, DRAW_BUFFER_OFFSET
	mov ecx, 64000
	
	mov al, 0
	rep stosb ; repeats ecx times store al in ecx
	
	ret
ENDP clear_screen

PROC copy_buffer
	uses eax, esi, edi, ecx

	;;write from temporary screenbuffer to screen
	xor eax, eax
	cld ; ESI and EDI increase
	mov ESI, DRAW_BUFFER_OFFSET ; temporary buffer address
	mov EDI, 0A0000h ; 
	mov ECX, 64000; copying double words
	rep movsb ; ecx times
	
	ret
ENDP copy_buffer

PROC increment_game_timer
    uses eax, edx
    
    ; Assuming the game runs at 60 FPS, increment every 60 frames
    mov eax, [frame_counter] ; Frame counter
    inc eax
    mov [frame_counter], eax
    
    cmp eax, 60
    jl @@return ; If less than 60 frames, don't increment seconds
    
    xor eax, eax
    mov [frame_counter], eax
    inc [game_timer] ; Increment the game timer by 1 second
    
@@return:
    ret
ENDP increment_game_timer



PROC wait_VBLANK
	uses edi, eax

	;; wait for the screen to be fully rendered
	mov DX, 03DAH ; VGA status port
	@@waitForEnd:
	in AL, DX
	and AL, 8 ; third bit is set during VBI
	jnz @@waitForEnd
	@@waitForStart:
	in AL, DX
	and AL, 8
	jz @@waitForStart

	ret
ENDP wait_VBLANK

PROC init_screen
	call open_file, offset mainMenuFile, offset screenData

	ret
ENDP init_screen

PROC draw_main_menu
	call clear_screen

	call draw_file, offset screenData
	
	call wait_VBLANK
	
	ret
ENDP draw_main_menu

PROC draw_screen
    call clear_screen

	call increment_game_timer

	call add_star
	call update_stars

    call update_slow
    call update_powerup
    call finishline
    
   	call draw_sprite, offset finishline_sprite, 0, [finishline_y]
    call draw_sprite, offset plane, [__first_plane_x], [__first_plane_y]
    call draw_sprite, offset plane, [__second_plane_x], [__second_plane_y]
	call draw_sprite, offset comet, 50, 50

    call wait_VBLANK
    call copy_buffer

    ret
ENDP draw_screen

;;0 tie, 1 player one won, 2 player two won
PROC init_end_screen
	ARG @@endstate:dword
	uses eax 
	
	mov eax, [@@endstate]
	cmp eax, 1
	je @@plr1
	ja @@plr2
	
	call open_file, offset tieFile, offset screenData
	ret
	
	@@plr1:
	call open_file, offset plr1WinFile, offset screenData
	ret
	
	@@plr2:
	call open_file, offset plr2winFile, offset screenData
	ret
ENDP init_end_screen

PROC draw_end

call clear_screen

	call draw_file, offset screenData
	
	call wait_VBLANK

	ret
ENDP draw_end

; -------------------------------------------------------------------
; data
; -------------------------------------------------------------------
DATASEG
	openErrorMsg db "could not open file", 13, 10, '$'
	readErrorMsg db "could not read data", 13, 10, '$'
	closeErrorMsg db "error during file closing", 13, 10, '$'

    powerup_active dd 0           ; Start with powerup inactive
 	finishline_active dd 0     

    finishline_drawn db 0      ; 0 betekent niet getekend, 1 betekent getekend
    finishline_sprite 	dw 10 , 5 ; W = 10, H = 5
						db 0 , 15 , 0 , 15 , 0, 15 , 0 , 15 , 0 , 15
						db 15 , 0 , 15 , 0 , 15, 0 , 15 , 0 , 15 , 0
   						db 0 , 15 , 0 , 15 , 0, 15 , 0 , 15 , 0 , 15
   						db 15 , 0 , 15 , 0 , 15, 0 , 15 , 0 , 15 , 0
   						db 0 , 15 , 0 , 15 , 0, 15 , 0 , 15 , 0 , 15

	finishline_timer dd 0   

    powerup_timer dd 0            ; Timer for spawning a new powerup
    powerup_spawned db 0  ; 0 means no powerup has spawned, 1 means a powerup has spawned
	powerup_spawn_time dd 0   ; Random time when the powerup should spawn
	game_timer dd 0           ; Tracks elapsed time since the game started
	frame_counter dd 0      ; Counts frames to determine elapsed seconds


 	slow_active dd 0           ; Start with powerup inactive


    slow_timer dd 0            ; Timer for spawning a new powerup
    slow_spawned db 0  ; 0 means no powerup has spawned, 1 means a powerup has spawned




    star_spawn_timer dd 0       ; Timer for spawning a new star

	mainMenuFile db "mainmenu.bin", 0
	tieFile db "SPRITEDP.bin", 0
	plr1WinFile db "SPRITEDP.bin", 0
	plr2winFile db "SPRITEDP.bin", 0

	
	plane	dw 5 , 8 ; W = 5 , h = 8
			db 0 , 0 , 1 , 0 , 0
			db 0 , 0 , 15 , 0 , 0
			db 0 , 15 , 15 , 15 , 0
			db 15 , 15 , 15 , 15 , 15
			db 15 , 15 , 15 , 15 , 15
			db 28h , 0 , 0 , 0 , 28h
			db 28h , 0 , 0 , 0 , 28h
			db 30h , 0 , 0 , 0 , 30h


	powerup_sprite 	dw 5 , 5 ; W = 5, H = 5
   					db 0 , 2 , 2 , 0 , 0
   					db 2 , 0 , 0 , 0 , 2
   					db 2 , 0 , 0 , 0 , 2
   					db 2 , 0 , 0 , 0 , 2
   					db 0 , 2 , 2 , 0 , 0


   slow_sprite dw 5 , 5 ; W = 5, H = 5
   				db 0 , 4 , 4 , 0 , 0
   				db 4 , 0 , 0 , 0 , 4
   				db 4 , 0 , 0 , 0 , 4
   				db 4 , 0 , 0 , 0 , 4
   				db 0 , 4 , 4 , 0 , 0
				
	comet 	dw 5 , 5 ; W = 5, H = 5
   			db 0 , 13h , 13h , 13h , 0
   			db 14h , 14h , 6h , 14h , 14h
   			db 15h , 6h , 15h , 15h , 15h
   			db 15h , 15h , 15h , 6h , 15h
   			db 0 , 15h , 15h , 15h , 0


UDATASEG
	stars dd 101*3 dup (?)	;; first double word equals if its active, second the x coordinate, third the y coordinate
	comets dd 30*6 dup (?)	;; first double word equals if its active, second the x coordinate, third the y, fourth the x direction, fith the y direction, 6th the speed
	screenData db PIXEL_COUNT dup (?)
	screenBuffer db 64000 dup (?)


END