; Genertaes a new block - shape, resets place values
; The new block's ID (place in memory) is stored at [next_block] - modular code
; The old shape ID was passed to [block] (points to current moving block)
proc gen_block
	mov [shape_height], 0
	mov [shape_x_place], 3
	mov [skip_delay], 0
	mov al, [next_block]
	mov [generated_block], al
	lea bx, [block]
	call block_identify
	call gen_random
	ret
endp gen_block

; This function identifies block according to a random number
; Loads it's address to dx, and puts that at the place in memory which bx is pointing to.
; Gets random number at [generated_block], Returns: shape's address at memory at [bx]
proc block_identify
	cmp [generated_block], 0
	je gen_shape1
	cmp [generated_block], 1
	je gen_shape2
	cmp [generated_block], 2
	je gen_shape3
	cmp [generated_block], 3
	je gen_shape4
	cmp [generated_block], 4
	je gen_shape5
	cmp [generated_block], 5
	je gen_shape6
	;cmp [generated_block], 6
	;je gen_shape7

	;gen_shape7:
	lea dx, [shape7]
	mov [bx], dx
	jmp gen_end
	gen_shape6:
	lea dx, [shape6]
	mov [bx], dx
	jmp gen_end

	gen_shape5:
	lea dx, [shape5]
	mov [bx], dx
	jmp gen_end

	gen_shape4:
	lea dx, [shape4]
	mov [bx], dx
	jmp gen_end

	gen_shape3:
	lea dx, [shape3]
	mov [bx], dx
	jmp gen_end

	gen_shape2:
	lea dx, [shape2]
	mov [bx], dx
	jmp gen_end

	gen_shape1:
	lea dx, [shape1]
	mov [bx], dx
	gen_end:
	ret
endp block_identify

; The main function which runs the whole game
; The used functions already basically describe the whole process. 
proc tetris_game
	;Setup:
	mov [possible], 0
	call gen_block
	call draw_next_piece
	call print_screen

	mov al, 2
	mov bh, 0
	mov cx, 6
	mov dl, SHAPE_SIZE
	mov dh, 2
	lea bp, [tetris_mesg]
	mov ah, 13h
	int 10h

	mov cx, 11
	mov bl, 0FH
	mov dl, 27
	mov dh,3
	lea bp, [next_piece_msg]
	call advanced_printing
	mov [score], 0
	call display_score

	;GAME:
	play_tetris:
	mov bx, [block] ; copy's block to screen and printing it
	call copy_to_screen ; copy the shape to screen var
	call print_inner_board ; print current board state 
	call wait_for_key ; get input, delay
	call shape_clear ; deletes block from [screen]
	call stop_sound ; in case that one was played 

	add [shape_height], 40 ; block trys to go down 
	call copy_try
	cmp [possible], 0 
	jne block_is_placed ; if can't go down anymore
	jmp play_tetris

	block_is_placed:
	sub [shape_height],40 ; Print placed block check if a line was completed, calculate score, generate new block
	call copy_to_screen ; copy the shape to screen var
	call print_inner_board ; print current board state 
	call line_completed ; check if a line was completed 
	call calc_score ; add score 
	call display_score ; updates displayed score
	call gen_block

	call draw_next_piece ; draws next piece, prints screen, message  
	call print_screen
		
	mov cx, 11
	mov bl, 0FH
	mov dl, 27
	mov dh,3
	lea bp, [next_piece_msg]
	call advanced_printing
	
	
	mov [possible], 0 ; If it isn't possible to generate a block => end game
	mov bx, [block]
	call copy_try    ; check if we can place the next block/shape 
	cmp [possible],1 
	je end_game

	

	jmp play_tetris

	end_game: ; prints last block/shape 
	sub [shape_height], 40 
	mov bx, [block]
	mov [clear_shape],0
	call copy_to_screen
	call print_inner_board
	ret
endp tetris_game

; Gets a Character array address in bx, an ID, 
; Copys the SHAPE_SIZE on SHAPE_SIZE shape colored cells to screen
; Also if [clear_shape] flag is equal to 1 => instead of copying the colored cells 
; It covers them with black
proc copy_to_screen 
	; 40*SHAPE_SIZE+15									
	mov di, BOARD_FALL_START								
	add di, [shape_height]
	add di, [shape_x_place]; place of printing
	xor si,si
	mov cx,SHAPE_SIZE
	copy_shape_rows:
	push cx
	mov cx, SHAPE_SIZE
	copy_screen_shape:
	mov al, [bx+si] ;color 
	cmp al, 0 		
	je copy_no_shape
	cmp [clear_shape], 1 
	je copy_cover_with_black
	mov [screen+di],al ;place color 
	inc [score] ;increaase player's score for every drawn square, which means rotating also gives you extra points.
	jmp copy_no_shape
	copy_cover_with_black:
	mov [screen+di],BLACK ;place black square instead of colored one
	copy_no_shape:
	inc si
	inc di  
	loop copy_screen_shape
	add di, 36 ; 40 - SHAPE_SIZE = 36 
	pop cx
	loop copy_shape_rows
	ret
endp copy_to_screen

	; Does the same as copy_to_screen but instead of coloring things
	; It only trys, and returns if it is possible using the [possible] FLAG
	; [possible] => 1 => isn't possible
	; [possible] => 0 => is possible
proc copy_try
	; 40*SHAPE_SIZE+15									
	mov di, BOARD_FALL_START									
	add di, [shape_height]
	add di, [shape_x_place] ; place of printing
	xor si,si
	mov cx,SHAPE_SIZE 
	copy_try_shape_rows:
	push cx
	mov cx, SHAPE_SIZE
	copy_try_screen_shape:
	mov al, [bx+si]
	cmp al, 0 
	je copy_try_no_shape
	cmp [screen+di], 0 ; background
	je copy_try_no_shape
	mov [possible], 1
	jmp copy_try_end
	copy_try_no_shape:
	inc si
	inc di  
	loop copy_try_screen_shape
	add di, 36
	pop cx
	loop copy_try_shape_rows
	jmp copy_try_end_without_pop
	copy_try_end:
	pop cx
	copy_try_end_without_pop:
	ret
endp copy_try

; This function copys the next piece to the right side of screen
; (First it copys a blank array to there, to clean the place)  
proc draw_next_piece
	mov al, [next_block]
	mov [generated_block],al 
	lea bx, [next_shape]
	call block_identify

	mov ax, [shape_height]
	push ax
	mov [shape_height], NEXT_PIECE_PLACE
	;clean:
	mov [clear_shape],1
	lea bx, [clean_shape]
	call copy_to_screen
	mov [clear_shape], 0

	;draw:
	mov bx, [next_shape]
	call copy_to_screen
	pop ax
	mov [shape_height], ax
	ret
endp draw_next_piece

; This function runs the tetris game when called 
; does some resets, cleans background, generates first random (next_block), 
; prints end of game message when game ends
; waits for [esc] to exit to menu 
proc tetris
	mov ax, 2 ; hide mouse
	int 33h
	xor al,al
	xchg al, [background_color]
	push ax
	call set_background
	pop ax
	mov [background_color],al
	call gen_random
	call tetris_game
	tetris_ended:
	gameover_wait_for_esc:
 ; print  a message:
	lea bp, [death_mess]
	mov dl, 8
	mov dh, 15
	mov cx, 22
	mov bl, WHITE
	call advanced_printing
	mov ah, 0 
	int 16h
	cmp al, 27
	je gameover_escape
	jmp gameover_wait_for_esc
	gameover_escape:
	call menu
endp tetris