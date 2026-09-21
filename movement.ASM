IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT, ds:FLAT, es:FLAT, fs:FLAT, gs:FLAT

INCLUDE "movement.inc"
INCLUDE 'KEYB.inc'

CODESEG

PROC move
    arg @@plane_id:dword, @@delta_x:dword, @@delta_y:dword
    uses eax, ebx
   
    mov eax, [@@plane_id]
    cmp eax, 1
    je @@move_first_plane
    cmp eax, 2
    je @@move_second_plane
    
    @@move_first_plane:
    ; Update __first_plane_x += delta_x
    mov ebx, [__first_plane_x]
    add ebx, [@@delta_x]
    mov [__first_plane_x], ebx

    ; Update __first_plane_y += delta_y
    mov ebx, [__first_plane_y]
    add ebx, [@@delta_y]
    mov [__first_plane_y], ebx
    ret

    @@move_second_plane:
    ; Update __second_plane_x += delta_x
    mov ebx, [__second_plane_x]
    add ebx, [@@delta_x]
    mov [__second_plane_x], ebx

    ; Update __second_plane_y += delta_y
    mov ebx, [__second_plane_y]
    add ebx, [@@delta_y]
    mov [__second_plane_y], ebx
    ret
ENDP move

PROC check_collision_with_plane ; RETURNS ECX
    ARG @@p_x:dword, @@p_y:dword, @@x_pos:dword, @@y_pos:dword, @@width:dword, @@height:dword 
    USES eax, ebx
    
    ;; check if the rightside > than the plate left side
    mov eax, [@@x_pos]
    mov ebx, [@@width]
    add eax, ebx
    mov ebx, [@@p_x]
    cmp eax, ebx
    jb @@not_colliding
    
    ;; check if the leftside < than the plane right side
    mov eax, [@@p_x]
    mov ebx, [plane_width]
    add eax, ebx
    mov ebx, [@@x_pos]
    cmp ebx, eax
    ja @@not_colliding
    
    ;; check if the bottom is < than the plane top
    mov eax, [@@y_pos]
    mov ebx, [@@height]
    add eax, ebx
    mov ebx, [@@p_y]
    cmp eax, ebx
    ja @@not_colliding
    
    ;; check if the top is > than the plane bottom
    mov eax, [@@p_y]
    mov ebx, [plane_height]
    add eax, ebx
    mov ebx, [@@y_pos]
    cmp ebx, eax
    jb @@not_colliding
    
    ;; is colliding
    mov ecx, 1
    ret

    @@not_colliding:
        mov ecx, 0
    ret
ENDP check_collision_with_plane

PROC check_collision_with_planes
    ARG @@x_pos:dword, @@y_pos:dword, @@width:dword, @@height:dword
    USES ecx

    ;; returns 1 in ecx if colliding
    call check_collision_with_plane, [__first_plane_x], [__first_plane_y], [@@x_pos], [@@y_pos], [@@width], [@@height]
    
    ret
ENDP check_collision_with_planes

PROC check_powerup_collisons
    USES ecx

    ;; check plane 1 collision with powerup 1
    call check_collision_with_plane, [__first_plane_x], [__first_plane_y], [powerup_x], [powerup_y], 5, 7
    cmp ecx, 1
    jne @@check1p2
    mov [powerupflag], 1
    jmp @@check2p1

    ;; check plane 2 collision with powerup 1
    @@check1p2:
    call check_collision_with_plane, [__second_plane_x], [__second_plane_y], [powerup_x], [powerup_y], 5, 7
    cmp ecx, 1
    jne @@check2p1
    mov [powerupflag], 2

    ;; check plane 1 collision with powerup 2
    @@check2p1:
    call check_collision_with_plane, [__first_plane_x], [__first_plane_y], [slower_x], [slower_y], 5, 7
    cmp ecx, 1
    jne @@check2p2
    mov [powerupflag2], 1
    ret

    ;; check plane 2 collision with powerup 2
    @@check2p2:
    call check_collision_with_plane, [__second_plane_x], [__second_plane_y], [slower_x], [slower_y], 5, 7
    cmp ecx, 1
    jne @@return
    mov [powerupflag2], 2
    
    @@return:
        ret
ENDP check_powerup_collisons

PROC finishline_collision
    USES eax, ebx, ecx, edx

    ; ----------------------------
    ; Check collision with first plane
    ; ----------------------------

    mov eax, [__first_plane_y]        ; Plane Y (top edge)
    mov ebx, [finishline_y]           ; Powerup Y (top edge)
    cmp ebx, eax                      ; Check if powerup Y > plane Y
    jl  @@check_second_plane           ; If finishline_y > first_plane_y, jump to check second plane

    ; Collision with first plane detected
    mov [powerupflag], 2
    ret

    @@check_second_plane:
    ; ----------------------------
    ; Check collision with second plane
    ; ----------------------------

    mov eax, [__second_plane_y]       ; Second plane Y (top edge)
    mov ebx, [finishline_y]           ; Powerup Y (top edge)
    cmp ebx, eax                      ; Check if powerup Y > second plane Y
    jl @@no_collision                 ; If finishline_y > second_plane_y, jump to no collision

    ; Collision with second plane detected
    mov [powerupflag], 2
    ret

    @@no_collision:
    ; No collision detected
    ret

ENDP finishline_collision

PROC check_collisions 

    call finishline_collision 
    call check_powerup_collisons

    ret
ENDP check_collisions



; -------------------------------------------------------------------
; DATA
; -------------------------------------------------------------------
DATASEG
    
    __winning_player dd 0
    __first_plane_x      dd 80
    __first_plane_y      dd 150
    __second_plane_x     dd 210
    __second_plane_y     dd 150 
    powerup_x dd 160
    powerup_y dd -1 
    
    plane_width dd 5
    plane_height dd 8

   slower_x dd 160
   slower_y dd -1 
   finishline_y dd -10
   

   powerupflag db 0  ; Boolean flag, initially true (1)
   powerupflag2 db 0  ; Boolean flag, initially true (1)
    finishlineflag db 0
    __slowdown_timer dd 0, 0 ; Timers for each plane (plane 1 and plane 2)
    timer dd 0, 0
END