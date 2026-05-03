;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Other Pages than menu and game
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	rules page: prints rules header and info, waits for an escape to go back to menu 
proc rules_page
	mov ax, 2 ; hide mouse
	int 33h
	mov bl, [background_color]
	push bx
	mov [background_color], BLACK
	call set_background
	pop bx
	mov [background_color], bl
	call reset_cursor; write on the beggining of the screen
	lea dx, [rules_header]
	call simple_print
	rules_wait_for_esc:
	mov ah, 0 
	int 16h
	cmp al, 27
	je rules_escape
	jmp rules_wait_for_esc
	rules_escape:
	call menu
endp rules_page

;	rules page: prints rules header and info, waits for an escape to go back to menu, or a number input which will represent an alternative colors mode
;	The game uses a lot of vars so it is easy to make changes like that, I decided to make this an option because it sounded cool
;	After each color mode there's a number represting it, clicking on it will result a color change to chosen mode
;	Works with simple int 16,0 code, each number has a JUMP and label. 
;	*Choosing a color will bring you back to menu
proc colors_page 
	mov ax, 2 ; hide mouse
	int 33h
	mov bl, [background_color]
	push bx
	mov [background_color], BLACK
	call set_background
	pop bx
	mov [background_color], bl	
	call reset_cursor; write on the beggining of the screen
	lea dx, [colors_header]
	call simple_print
	
	colors_wait_for_esc:
	mov ah, 0 
	int 16h
	cmp al, 27
	je colors_escape
	cmp al, 31h 
	je ORG_colors
	cmp al, 32h
	je RGB_colors
	cmp al, 33h 
	je BW_colors
	cmp al, 34h 
	je alien_colors
	cmp al, 35h
	je nether_colors
	
	jmp colors_wait_for_esc
	ORG_colors:
	mov [dino_color], DARK_GRAY 
    mov [background_color],WHITE
    mov [cactus_color], LIGHT_GRAY
	mov [cloud_color], LIGHT_GRAY
	jmp colors_escape
	
	RGB_colors:
	mov [dino_color],RED
    mov [background_color], LIGHT_GREEN
    mov [cactus_color],BLUE
	jmp colors_escape

	BW_colors:
	mov [dino_color],WHITE 
    mov [background_color],DARK_GRAY
    mov [cactus_color],BLACK
	jmp colors_escape

	alien_colors:
	mov [ground_color], DARK_GRAY
	mov [dino_color],YELLOW 
    mov [background_color],LIGHT_GRAY
    mov [cactus_color],MAGNETA
	jmp colors_escape

	nether_colors:
	mov [dino_color],BLACK 
    mov [background_color], RED
    mov [cactus_color], WHITE 
	colors_escape:
	call menu
endp colors_page

;menu:
;	There are 3 levels buttons: easy - 2 extra life, regular - 1 extra life, pro - no extra life, clicking on a level will start the game with the chosen level
;	There are also a colors button and a rules button which takes you up to these pages
;	menu also resets somethings so the game will work 
;	There is also a brand-new tetris button to play some tetris 
;	There are tons of compares and jumps (if(s)) that checks which and if a button was pressed (the values were calculated knowing that a charcter is a 8x8pixels object). 
proc menu 	
	mov sp, 1000 ;reset stack 
	call reset_tetris
	;resets:
	;colors:
	cmp [night], 1
	jne skip_reset_night
	mov [night], 0
	call invert_colors
	skip_reset_night:
	;
	mov [run_time_sum], 0 
	call reset_cursor ; write on the beggining of the screen
	;score:
	xor si,si
	mov cx, 6
	reset_text:
	mov [run_time_text+si], '0'
	inc si
	loop reset_text
	;background:
	mov bl, [background_color]
	push bx
	mov [background_color], BLACK
	call set_background
	;Set Background:
	mov bl, [dino_color]
	push bx
	mov [dino_color],MENU_DINO_COLOR
	mov cx, 6
	mov bx, 45160
	draw_menu_background:
	push cx
	mov [cactus_height],bx
	call basic_cactus
	pop cx
	sub bx,20 
	sub bx,cx
	sub bx,cx
	push cx
	mov [dino_height],bx
	call draw_dino
	call refresh_eye
	call refresh_legs
	add bx, 79
	pop cx
	loop draw_menu_background
	call draw_dead_dino
	pop bx
	mov [dino_color], bl
	pop bx
	mov [background_color], bl
	call reset_game
	;print messages:
	mov bl, WHITE 
	mov dh, 1
	mov dl, START_OF_ROW
	lea bp, [menu_header]
	mov cx, 38
	call advanced_printing

	add dh, ROW_SPACING
	mov cx, 4
	lea bp, [lvl_1_but]
	call advanced_printing
	add dh, ROW_SPACING
	mov cx, 7
	lea bp, [lvl_2_but]
	call advanced_printing
	add dh, ROW_SPACING
	mov cx, 3
	lea bp, [lvl_3_but]
	call advanced_printing
	
	add dh, ROW_SPACING
	add dh, ROW_SPACING
	mov bl, RED
	mov cx, 6
	lea bp, [colors_button]
	call advanced_printing
	
	mov al, 2
	mov bh, 0
	mov cx, 6
	mov dl, 34
	mov dh, 21
	lea bp, [tetris_mesg]
	mov ah, 13h
	int 10h
	
	;get input from the mouse, to decide which label to open in menu 
	menu_mouse_setup:
	mov ax,0h
	int 33h
	
	mov ax,1h
	int 33h
	menu_mouse_input:
	call mouse_status
	cmp bx,01h 
	je got_input
	jmp menu_mouse_input
	
	got_input:
	shr cx, 1 ;in this mode there are only 320 pixels in a row
	
	;according to labels/messages corddinates open each label. 
	;You can also click, 2 pixels up/down, so it won't be uneasy to open a label (a solution to human error)
	
	cmp cx, 272
	jae check_if_rules
	
	jmp check_if_easy
	check_if_rules:
	cmp dx, 16
	jnbe check_tetris
	call rules_page
	check_tetris:
	cmp dx,166 
	jnae invalid_input
	cmp dx, 178 
	jnbe invalid_input
	call tetris
	check_if_easy:
	cmp cx, 40
	jnbe check_pro
	cmp dx,38 
	jnae check_pro
	cmp dx, 50
	jnbe check_pro
	mov [dino_life], 3
	call game 
	
	check_pro:
	cmp cx, 32
	ja check_regular
	cmp dx, 94
	jnae check_regular
	cmp dx, 106 
	jnbe check_regular
	mov [dino_life], 1 
	call game
	
	check_regular:
	cmp cx, 64
	ja check_if_colors
	cmp dx, 62
	jnae check_if_colors
	cmp dx, 74
	jnbe check_if_colors
	mov [dino_life], 2
	call game
	
	
	check_if_colors:
	cmp cx, 56
	ja invalid_input
	cmp dx, 166
	jnae invalid_input
	cmp dx, 178
	jnbe invalid_input
	call colors_page
	
	invalid_input:
	jmp menu_mouse_setup
endp menu 