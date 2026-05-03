;	This function prints the screen variable in a 320*200 vga mode, 
;	It does that by taking the values from screen - covering 8 places in a row with each value
;	Then Duplicates the row for more 7 times which creates a state that every value from 
;	screen variable is like a square of it's color on the screen
; 	The right side is text-only so the function skips it. 
proc print_screen
	;Go Graphics
	push es
	mov ax, GRAPHICS
	mov es, ax
	;step 1: go across all of screen array
	xor si,si ; place in screen
	xor di,di ; place in graphics memory
	mov cx, 25
	screen_go_over:
	push cx
	mov cx, 40 ; screen's size is 40*25 
	;step 2: place blocks:
	screen_place_blocks:
	mov al, [screen+si] ; color of block
	
	push cx
	mov cx, 8 ; each cell represnets 8*8 
	screen_cols:
	push ax
	mov ax, si
	mov bl, 40
	div bl
	mov dh, ah
	pop ax
	cmp dh, 14
	jb maybe_text ; left side is text-only
	right_side_color:
	mov [es:di], al
	maybe_text:
	
	inc di
	loop screen_cols

	inc si
	pop cx
	loop screen_place_blocks
	; copies current row to next 7 
	; skips the text-left-side: 
	mov cx, 7 
	switch_rows:
	push cx
	add di, 112 ;  (skip left side)
	mov cx, 208 
	screen_copy_rows:
	mov al, [es:di-320]
	mov [es:di], al
	inc di
	loop screen_copy_rows
	pop cx
	loop switch_rows
	pop cx
	loop screen_go_over
	pop es
	ret
endp print_screen

;	This function does the same as the print_screen function 
;	But it only prints the inner part of the game board 
;	It does that with the same idea of print_screen but with skips at the other-then inner board parts
proc print_inner_board
	;Go Graphics
	push es
	mov ax, GRAPHICS
	mov es, ax
	;step 1: go across all of screen array
	mov si, 120 ; place in screen
	mov di, 7680 ; place in graphics memory
	mov cx, 19
	board_go_over:
	add di, 120
	add si, 15 
	push cx
	mov cx, 10 ; screen's size is 40*25 
	;step 2: place blocks:
	board_place_blocks:
	mov al, [screen+si] ; color of block
	push cx
	mov cx, 8 ; each cell represnets 8*8 
	board_cols:
	mov [es:di], al 
	inc di
	loop board_cols
	inc si
	pop cx
	loop board_place_blocks
	;Copy current row to next 7
	mov cx, 7 
	board_copy_rows:
	push cx
	add di, 220 
	mov cx, 100
	board_copy_pix:
	mov al, [es:di-320]
	mov [es:di], al
	inc di
	loop board_copy_pix
	pop cx
	loop board_copy_rows
	add si, 15 ; adjust screen pointer
	add di, 120; adjust graphics memory pointer
	pop cx
	loop board_go_over
	pop es
	ret
endp print_inner_board
;	This function rotates shapes (90deg) by switching the rows with columns (starting from the last row of the shape)
;    XX 	for example will be:	X
; 	  XX						   XX
;							   	   X
; It gets the shape type from it's address which is stored at [block]
proc rotate_shape
	mov bx, [block]
	mov cx, SHAPE_SIZE
	; First part  - find the beginning row of the shape: 
    mov si, 16 ;	last place is [bx+15], 16 -1 = 15
	find_beginning: 
	dec si
	mov al, [bx+si]
	cmp al, 0
	je find_beginning
	; Second part:
	; Found it, now caculate how long does the rotating loop needs to be
	; and where do we start from 
	mov ax, 15 ;	15 => last place in shape's array 
	sub ax, si   
	mov bl, SHAPE_SIZE
	div bl
	xor ah,ah  
	mov cx, SHAPE_SIZE
	sub cx, ax
	mul bl
	mov si, 15 ;	15 => last place in shape's array  
	sub si, ax
	add si, [block]
	mov di, cx
	; Third Part - rotating a 4x4 array (90deg):
	rotate_cols: 
	push cx    
	push di 
	sub di, cx       
	
	mov cx, SHAPE_SIZE
	rotate_rows:
	push si        
	sub si, cx
	inc si
	mov al, [si] ; si => place in current to-be-rotated shape.
	mov [help_arr+di], al ; di == offset in help_arr
	add di, SHAPE_SIZE     
	pop si   
	loop rotate_rows  
	sub si, SHAPE_SIZE
	pop di   
	pop cx
	loop rotate_cols	
	; Finished rotating, now just copy it from the help_arr:
	
	call copy_to_help_shape ; Copys rotated shape to another array 
	call clear_help_arr ; Cleans it for next time
    lea dx, [help_shape]
    mov [block],dx 
	ret
endp rotate_shape

; help arr is used to help rotating a shape
; There is a need to clean it for next time 
; After each use  
proc clear_help_arr
	mov cx, 16 ; 4x4 = 16 
	xor si,si
	clear_help:
	mov [help_arr+si], 0 ; 0 = blank 
	inc si
	loop clear_help
	ret
endp clear_help_arr

; Copys help_arr to help_shape
; So I will be able to clean help_arr
; And use help_shape
proc copy_to_help_shape
	xor si,si
	mov cx,16
	copy_paste_arr:
	mov al, [help_arr+si]
	mov [help_shape+si],al
	inc si
	loop copy_paste_arr
	ret
endp copy_to_help_shape


; This function creates a delay while waiting for a user-input
; It uses the time-memory, waiting for it's ticks to come 
; It does that according to game_speed which goes down as levels progress
proc wait_for_key
	push es
	cmp [skip_delay], 1 ; If user wants to drop the shape down 
	je skip_delay_loop
	mov ax, 40h
	mov es, ax
	mov ax, [CLOCK] ;Clock points to time memory
	call get_input
	first_tick :
	cmp ax, [CLOCK]
	je first_tick 
	cmp [game_speed], 0 ;loops first decrease value and then compare it so we better check 0 situation before entering a loop.
	je skip_delay_loop  ;also this way we can skip loop's code
	
	cmp [skip_delay], 1; If user wants to drop the shape down 
	je skip_delay_loop
	mov cx, [game_speed]
	delay_loop:
	push cx
	call get_input
	cmp [speed_row],1 
	je skip_delay_loop_with_pop
	pop cx
	mov ax, [CLOCK] 
	tick :
	cmp ax, [CLOCK]
	je tick
	loop delay_loop
	jmp skip_delay_loop
	skip_delay_loop_with_pop:
	pop cx
	skip_delay_loop:
	mov [speed_row], 0
	pop es
	ret
endp wait_for_key

; This function gets input if there is one (without waiting)
; If input is [S] shape skips to next row  by triggering [speed_row]
; Else if it is [A], [D] the shape_x_place decreases/increases by 1 
; Else if it is [ENTER] => shape drops down by triggering [skip_delay]
; Else if it is [SPACE] => shape rotates
; It does all of that while checking if a move is possible with the 
; copy_try function and the possible flag. 
; If a move is illegal the function returns shape to previous state
; *If the move is a rotate it trys to rotate more until back at original place\reaches legal place. 
proc get_input
	mov ah, 1 
	int 16h        
	jz no_input
	mov ah, 0 
	int 16h
    cmp al, 'd'
	je move_block_right
	cmp al, 'D'
	je move_block_right
	cmp al, 'a'
	je move_block_left
	cmp al, 'A'
	je move_block_left
	cmp al, 0dh ; (enter)
	je go_down
	cmp al, 's'
	je s_pressed_skip_row
	cmp al, 'S'
	je s_pressed_skip_row
	cmp al, 20h ; space
	je rotate_space
	jmp no_input
	s_pressed_skip_row:
	mov [speed_row], 1
	jmp no_input 
	
	go_down:
	mov [skip_delay],1
	jmp no_input
	
	move_block_right:	
	call shape_clear
	inc [shape_x_place]
	call copy_try
	cmp [possible], 1
	jne not_out_of_bounds_right
	dec [shape_x_place]
	dec [possible]
	
	not_out_of_bounds_right:
	mov bx, [block]
	call copy_to_screen
	call print_inner_board
	jmp no_input
	
	no_input: ; to avoide out-of-range jumps
	jmp get_input_end
	
	move_block_left:
	call shape_clear
	dec [shape_x_place]
	call copy_try
	cmp [possible], 1
	jne not_out_of_bounds_left
	inc [shape_x_place]
	dec [possible]
	
	not_out_of_bounds_left:
	mov bx, [block]
	call copy_to_screen
	call print_inner_board
	jmp get_input_end
	
	rotate_space:
	call shape_clear
	try_rotating_again:
	mov [possible],0
	call rotate_shape
	mov bx, [block]
	call copy_try
	cmp [possible],0
	je not_out_of_bounds_right ; just print it there
	dec [shape_x_place] ; try to move the shape a bit for rotating.
	mov [possible],0
	mov bx, [block]
	call copy_try
	cmp [possible],0
	je not_out_of_bounds_right ; just print it there
	inc [shape_x_place]
	jmp try_rotating_again
	
	get_input_end:
	ret
endp get_input 

; This function goes across screen array (the inner board part) -- >checking if a whole row is filled
; If there is such a row it advances the above rows to it's place and up, deleting it and increasing [points] var
; In the way.
; It also makes a sound if that happens.
proc line_completed
	mov di, 175		
	mov cx,18
	go_over_screen:; Step 1 - Find a completed row if there's such 
	xor dx,dx ;dx used to see if row all colored; yes=> 0, else => 1
			  ;bx = colored rows sum
	push cx
	mov cx, 10
	go_over_screen_rows:
	cmp [screen+di], 0
	jne colored_row
	mov dx, 1
	colored_row:
	inc di
	loop go_over_screen_rows
	add di, 30
	cmp dx, 0 
	jne dont_adavance_screen
	push di
	inc [points]
	
	sub di, 40
	
	mov ax, di
	sub ax,120
	mov bl, 40
	div bl
	xor ah,ah
	mov cx,ax
	dec cx
	;;;
	advance_go_over_screen: ; step 2 - if there's such a row - advance other rows to it's place!:
	mov bx, JMP_NOTE ; make JUMP sound
	call make_sound 
	push cx
	
	mov cx, 10
	advance_cells:
	mov al, [screen+di-40]
	mov [screen+di],al
	inc di
	loop advance_cells
	sub di, 50
	pop cx
	loop advance_go_over_screen
	pop di
	
	dont_adavance_screen:
	pop cx
	loop go_over_screen
	ret
endp line_completed

; Function is used to clear a shape from previous place when needed
proc shape_clear 
	mov [clear_shape], 1
	mov bx, [block]
	call copy_to_screen 
	mov [clear_shape], 0
	ret
endp shape_clear

; Function calculates player's new score according to [level], [points] and previous [score] 
; Every CHANGE_LEVEL_SCORE, score resets and level goes up till player beats game or loses.
; NOTE: player's score also increases for every drawn square on screen. 
proc calc_score
	xor ax,ax
	cmp [points], 1
	je calc_one_line
	cmp [points], 2
	je calc_two_line
	cmp [points], 3
	je calc_three_line
	cmp [points], SHAPE_SIZE
	je calc_four_line
	jmp end_of_calc_score ; no completed lines :( 
	calc_one_line: ;+SCORE_PER_X_LINES*[level] 
	mov ax, 40
	jmp end_of_calc_score
	calc_two_line:
	mov ax,100
	jmp end_of_calc_score
	calc_three_line:
	mov ax,300
	jmp end_of_calc_score
	calc_four_line:
	mov ax, 1200
	end_of_calc_score:
	xor bh,bh
	mov bx, [level]
	inc bx
	xor dx,dx
	mul bx
	add ax, [score]
	jnc didnt_reach_limit ; in case that score somehow suprassed 0FFFFH
	mov [score], CHANGE_LEVEL_SCORE
	jmp skip_adding_to_score
	didnt_reach_limit:
	mov [score], ax
	skip_adding_to_score:
	mov ax, [points]
	add [filled_lines],ax 
	mov [points],0
	
	cmp [score], CHANGE_LEVEL_SCORE ; Advance to next level if reached tp CHANGE_LEVEL_SCORE
	jnae dont_advance_to_next_level
	sub [score], CHANGE_LEVEL_SCORE
	inc [level]
	cmp [game_speed], MIN_SPEED
	je dont_decrease_speed
	dec [game_speed]
	dont_decrease_speed:
	cmp [level], 16 ; If finished level 15, end game. 
	jne nevermind_didnt_finish
	call won_tetris
	nevermind_didnt_finish:
	dont_advance_to_next_level:
	ret
endp calc_score

; Displays a victory message and final score
proc won_tetris
	mov cx, 8 ; length
	mov bl, 0FH ; color
	mov dl, 16 ;place:
	mov dh,8
	lea bp, [beat_game_msg]
	call advanced_printing
	call display_score
	jmp tetris_ended
	ret
endp won_tetris

; This function is used to display score on screen 
; It basically uses the num_to_text function and prints 
; The outcome. 
proc display_score
	lea si, [score] ; Print score 
	lea di, [score_msg]
	add di, 11
	call num_to_text
	mov cx, 12
	mov bl, 0FH
	mov dl, 0
	mov dh,SHAPE_SIZE
	lea bp, [score_msg]
	call advanced_printing
	
	lea si, [filled_lines] ; Print filled_lines
	lea di, [lines_msg]
	add di, 10
	call num_to_text
	mov cx, 11
	mov bl, 0FH
	mov dl, 1
	mov dh,10
	lea bp, [lines_msg]
	call advanced_printing
		
	
	lea si, [level] ; Print current level 
	lea di, [level_msg]
	add di, 8
	call num_to_text

	mov cx, 9
	mov bl, 0FH
	mov dl, 1
	mov dh,12
	lea bp, [level_msg]
	call advanced_printing
	ret
endp display_score

; This fucntion resets the tetris game. 
; The important parts of screen array 
; And the score/speed/and more values.
; Which are required for the game 
; to run properly.
proc reset_tetris
	; Reset board:
	xor si,si
	mov cx, 80
	up_cover:
	mov [screen+si],0
	inc si
	loop up_cover
	
	mov cx, 14
	frame_head_p1:
	mov [screen+si],0
	inc si 
	loop frame_head_p1
	mov cx, 12
	frame_head_p2:
	mov [screen+si],WHITE
	inc si 
	loop frame_head_p2
	mov cx, 14
	frame_head_p3:
	mov [screen+si],0
	inc si 
	loop frame_head_p3
	
	mov cx, 19 
	frame_rows:
	push cx
	mov cx, 14
	frame_body_p1:
	mov [screen+si],0
	inc si 
	loop frame_body_p1
	mov [screen+si], WHITE
	inc si
	mov cx, 10
	frame_body_p2:
	mov [screen+si],0
	inc si 
	loop frame_body_p2 ; p=> part
	mov [screen+si], WHITE
	inc si
	mov cx, 14
	frame_body_p3:
	mov [screen+si],0
	inc si 
	loop frame_body_p3
	pop cx
	loop frame_rows
	
	
	; Reset scores:
	mov [score], 0
	mov [level], 0
	mov [points], 0
	mov [filled_lines], 0 
	
	; Reset messages:
	mov [lines_msg+10], 30h 
	mov [lines_msg+9], 30h
	mov [lines_msg+8], 30h
	mov [lines_msg+7], 30h
	
	mov [score_msg+11], 30h
	mov [score_msg+10], 30h
	mov [score_msg+9], 30h
	mov [score_msg+8], 30h
	mov [score_msg+7], 30h
	
	mov [level_msg+8], 30h 
	mov [level_msg+7], 30h
	; Reset speed:
	mov [game_speed], INITIAL_GSPEED
	; I chose not to reset bag !
	
	ret
endp reset_tetris




