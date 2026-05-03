;;;;;;;;;;;;;;;;;;;;;;;;;
;;;TOOLS:
;;;;;;;;;;;;;;;;;;;;;;;;;
; Function Checks if a dino colored pixel touches a cactus colored pixel or the other way, while also placing cx bits starting from [es:bp] and increasing bp, every time. ES needs to be in GRAPHICS memory
; So the function will actually draw pixels to screen. 
proc draw_line 
	drawing_line:
	; comparing to know if dino hit cac/ cac hit dino
	cmp al, [background_color] ; Maybe we are only deleting the last character to animate it
	je not_dead
	cmp al, [cactus_color];  maybe cac hit dino:
	jne check_dino_hit_cac
	mov ah,al
	mov al, [dino_color]
	cmp [es:bp], al
	mov al,ah
	jne not_dead
	mov [hit_cactus], 0 ; hit cactus is a flag, when it is triggerd the dino didn't hit cactus, but if it hits when it turns to zero so the check_dead function will know that it needs to decrease life 
	jmp not_dead
	; dino hut cactus:
	check_dino_hit_cac:
	mov ah, al
	mov al, [cactus_color]
	cmp al, [background_color]
	mov al,ah 
	je not_dead
	mov ah, al
	mov al, [cactus_color]
	cmp [es:bp],al
	mov al,ah
	jne not_dead
	mov [hit_cactus], 0  ; hit cactus is a flag, when it is triggerd the dino didn't hit cactus, but if it hits when it turns to zero so the check_dead function will know that it needs to decrease life 
	
	not_dead: ; coloring 
	mov [es:bp], al
	inc bp 
	
	loop drawing_line
	ret
endp draw_line
proc simple_draw_line ; length in cx, color at al, needs to be at GRAPHICS
	simple_drawing_line:
	mov [es:bp], al
	inc bp 
	loop simple_drawing_line
	ret
endp simple_draw_line

; Function puts a delay of 55 milie-seconds 
proc delay
	mov ax, 40h
	mov es, ax
	mov ax, [CLOCK] ;CLOCK points to time memory
	
	delay_first_tick :
	cmp ax, [CLOCK]
	je delay_first_tick 
	ret
endp delay

proc make_sound ; note at bx 
	in al, 61h; open speaker
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, bx
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	ret
endp make_sound
proc stop_sound
	; close the speaker - stop sound
	push ax
	in al, 61h
	and al, 11111100b
	out 61h, al
	pop ax
	ret
endp stop_sound

; death function is used when a dino dies [dino_life] = 0 
; plays a sound of a collision
; animates dead dino 
; checks if there's a new record
; waits for an escape key to return to menu
proc death
	call draw_dino ; draw dino 
	call draw_dead_dino ; animate it so it will look dead 
	mov bx, Death_Note
	call make_sound
	call delay 	;play it for a bit
	call delay 	
	call stop_sound
	call compare_run_times ; compare run time... check if there's a new record
	death_wait_for_esc:
 ; print  a message:
	lea bp, [death_mess]
	mov dl, 8
	mov dh, 13
	mov cx, 22
	mov bl, [ground_color]
	call advanced_printing
	mov ah, 0 
	int 16h
	cmp al, 27
	je death_escape
	jmp death_wait_for_esc
	death_escape:
	call menu
endp death
;check if dino is dead 
proc check_dead
	cmp [hit_cactus], 0 ; hit cactus is a flag, if it's zero we know that dino got hit 
	jne isnt_dead		; else we know that he didin't
	dec [dino_life] 	; but if it's we will dec dino's life
	mov [hit_cactus], 1 ; also we will reset it
	cmp [dino_life], 0  ; and now we will check if dino can keep going (has extra life)
	jne isnt_dead_but_hit ; if he can we return to game but regenerate things 
	call death ; if he can't we activate death
	isnt_dead_but_hit:
	call game		; so we call game 
	isnt_dead:
	ret
endp check_dead

proc set_background ; sets a background according to [background_color], just fills video memory with [background_color] values.
	push es
	push bp
	xor bp,bp
	mov ax, 0a000h
	mov es, ax
	mov al, [background_color]
	mov cx, SCREEN_SIZE
	fill_screen:
	mov [es:bp], al
	inc bp
	loop fill_screen
	pop bp
	pop es
	ret
endp set_background	

proc reset_cursor ; to write on the beggining of the screen
	xor dx,dx
	xor bx,bx
	mov ah, 2 
	int 10h
	ret
endp reset_cursor