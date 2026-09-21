IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "movement.inc"
INCLUDE "graphics.inc"
INCLUDE "rand.inc"
INCLUDE "keyb.inc"
INCLUDE "playwav.inc"


; -------------------------------------------------------------------
; CODE
; -------------------------------------------------------------------
CODESEG

PROC waitForKey
    USES eax

    mov ah, 00h ; get keystroke
    int 16h
    ret
ENDP waitForKey

PROC main
    sti            ; Set the Interrupt Flag => enable interrupts
    cld            ; Clear the Direction Flag
    
    push ds
    pop es
    

    @@init:
    ; Initiates the random number generator
    call rand_init
    ; Set graphics mode VGA
    call set_video_mode, 1
    ; Init the graphics
    call init_screen
    call startMusic
    
    ; Init keyboard
    call __keyb_installKeyboardHandler

    ; Check booleanFlag and jump to game loop if false (0)
    cmp [booleanFlag], 0
    je @@game_loop  ; Jump to game loop if booleanFlag is false


    @@main_menu:
    call draw_main_menu
    call __check_keys
    ; Check if booleanFlag changes during the menu
    cmp [booleanFlag], 0
    je @@game_loop  ; Jump to game loop if booleanFlag becomes false

    cmp [__running], 1
    je @@main_menu


    @@game_loop:
    call draw_screen
    call __check_keys
    call check_collisions ; runs all collision checks in movement
    
    cmp [__winning_player], 0
    jne @@game_ended
    cmp [__running], 1
    je @@game_loop

    
    @@game_ended:
    call init_end_screen, [__winning_player]
    @@game_end_loop:
    call draw_end
    call __check_keys
    
    cmp [__running], 1
    je @@game_end_loop


    @@close:
    ; Set graphics mode to text
    call set_video_mode, 0
    ; Close keyboard
    call __keyb_uninstallKeyboardHandler
    call stopMusic
    ; Terminate process with return code
    mov ax, 4C00h
    int 21h
ENDP main

; -------------------------------------------------------------------
; STACK
; -------------------------------------------------------------------
STACK 1000h

END main
