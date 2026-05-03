;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;Animations to characters:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This function does the BLINKING effect. 
; It goes to the place of the eye in the video memory
; It uses a var named eye 
; when eye=1 the eye closes and then eye = 5 (1/BLINKING = blinks per call)
; when 5>eye>1 the eye is open, if eye = 5 it is closed, and we open it
proc refresh_eye 
	mov ax, GRAPHICS
	mov es, ax  
	mov bp, [dino_height]
	add bp, [dino_x_pos]
	add bp, DINO_EYE ; add eye offset to dino current place
	
	cmp [eye], 1
	ja dont_color_eye
	mov al, [dino_color]
	mov cx, 2    
	call draw_line 
	mov [eye], BLINKING
	jmp end_refresh_eye
	
	dont_color_eye:
	cmp [eye], BLINKING
	jne eye_isnt_closed
	mov al, [background_color]
	mov cx, 2
	call draw_line
	mov al, ah
	
	eye_isnt_closed:
	dec [eye]
	end_refresh_eye:
	ret
endp refresh_eye

; This function does the moving legs effect. 
; It goes to the place of the legs in the video memory, using readable constants 
; It uses a var named leg to identify where was each leg every time
; when leg = 1 we move right leg 
; when leg = 0 we move left leg
; each time we also delete the privious up right/left leg animation  
proc refresh_legs
	mov bp, [dino_height]
	add bp, [dino_x_pos]
	push bp
	mov ax, GRAPHICS
	mov es, ax ; Graphics memory
	mov dl, [dino_color]
	mov al, [background_color]
	cmp [leg],0
	jne right_leg
	mov dl, [background_color]
	mov al, [dino_color]
	inc [leg]
	jmp left_leg
	right_leg:
	dec [leg]
	left_leg:
	; draws/covers:
	
	; Right:
	add bp, DINO_RIGHT_LEG_UP
	mov cx, 1
	call simple_draw_line
	pop bp
	push bp
	; Left:
	add bp, DINO_LEFT_LEG_DOWN 
	mov cx, 4
	call simple_draw_line
	pop bp
	push bp
	; covers/draws:
	
	; Left:
	mov al,dl	
	add bp, DINO_LEFT_LEG_UP	
	mov cx, 1 
	call simple_draw_line
	pop bp
	; Right:
	add bp, DINO_RIGHT_LEG_DOWN
	mov cx, 4
	call simple_draw_line
	ret
endp refresh_legs


; Cover all potential moving dino parts, used when jumping. 
proc clear_refreshed
	mov ax, GRAPHICS
	mov es, ax
	mov bp, [dino_height]
	add bp, [dino_x_pos]
	push bp
	mov al, [background_color] 
	; Cover up right leg 
	add bp, DINO_RIGHT_LEG_UP
	mov cx, 1
	call draw_line 
   ; Cover up left leg
	pop bp 
	push bp
	add bp, DINO_LEFT_LEG_UP
	mov cx, 1
	call draw_line 
	; Clear eye:	
	pop bp
	add bp, DINO_EYE
	mov cx, 2
	call draw_line
	ret
endp clear_refreshed

; This function makes the dino JUMP 
proc dino_jump
	mov cx, DINO_JUMP_SKIP ; The number of frames for the JUMP 
	dino_jumping:		   ; deletes previous dino 
	push cx 			   ; prints new dino at JUMP pixels higher
	mov al, [dino_color]   ; move cactuses while jumping, which also creates a delay
	push ax				   ; checks if dino is dead -> hit cactus
	mov al,[background_color]
	mov [dino_color], al
	call draw_dino
	pop ax
	mov [dino_color], al
	sub [dino_height], JUMP ; JUMP = the size of each JUMP 
	call draw_dino
	call check_dead
	cmp [cactus_move_per_jump],0 ; used for higher speeds - to make them possible...
	je skip_moving_jump
	call cactus_move
	skip_moving_jump:
	pop cx
	cmp cx, DINO_JUMP_SKIP
	jne skip_closing_speaker_jump
	call stop_sound ; stop JUMP sound
	skip_closing_speaker_jump:
	loop dino_jumping 
	ret
endp dino_jump
; This function makes the dino land after a JUMP 
proc dino_land
	mov cx, DINO_JUMP_SKIP; The number of frames for the JUMP 
	dino_landing:	      ; deletes previous dino 
	push cx	              ; prints new dino at JUMP pixels down
	mov al, [dino_color]  ; move cactuses while jumping, which also creates a delay
	push ax               ; checks if dino is dead -> hit cactus
	mov al,[background_color]
	mov [dino_color], al
	call draw_dino
	pop ax
	mov [dino_color], al
	add [dino_height], JUMP ; JUMP = size of land 
	call draw_dino
	call check_dead
	cmp [cactus_move_per_jump],1 ; used for higher speeds
	jbe skip_moving_land
	call cactus_move
	skip_moving_land:
	pop cx
	loop dino_landing

	ret
endp dino_land
;;;;;;;;;;;;;;;;;;;;;;;
;;;;Cactuses:
;;;;;;;;;;;;;;;;;;;;;;;
; The following functions all do basically the same thing with different parameters
; so I will describe only one and let it be an example for the others
; com_cac = common cactus 
; The reason that I chose to make different function for every cactus type is because every one of them as different last place value, and first place etc. to do all of thtis in one function will be exhausting and complex, and in my opinion much longer to write. 
proc com_cac
	cmp [cac_place], CAC_DEFUALT_PLACE ;checks if it is the first frame of cactus --> if it's skip the deleting part 
	je restart_comcac
	
	mov al, [cactus_color] ; deletes previous cactus
	push ax
	mov al, [background_color] 
	mov [cactus_color], al
	call common_cac
	pop ax
	mov [cactus_color], al
	jmp dont_restart_comcac
	restart_comcac: 
	mov [cac_place], BASIC_CAC_INITIAL_PLACE ; restart the cactus 
	dont_restart_comcac:
	mov ax, [cactus_skip] ;advances cactus  
	sub [cac_place], ax	
	cmp [cac_place], BASIC_CAC_LAST_PLACE ; checks if there's a need to rerool - cactus has reached the end of the screen 
	jb reroll_com_cac
	
	call common_cac ; draws a cactus object 
	call check_dead ; checks if dino was hit 
	
	jmp end_of_com_cac ; skip rerolling
	reroll_com_cac: 
	call reset_cac ; rerolls cactus 
	end_of_com_cac:
	ret
endp com_cac
; Move cactus' version 3, just like described above with some different parmeters etc.
; (setup if first cac, delete previous, draw next, till limit)
proc cac_3
	cmp [cac_place], CAC_DEFUALT_PLACE
	je restart_cac3
	mov al, [cactus_color]
	push ax
	mov al, [background_color]
	mov [cactus_color], al
	call two_cac
	pop ax
	mov [cactus_color], al
	jmp dont_restart_cac3
	restart_cac3:
	mov [cac_place],TWO_CAC_INITIAL_PLACE
	dont_restart_cac3:
	mov ax, [cactus_skip]
	sub [cac_place], ax	
	cmp [cac_place], TWO_CAC_LAST_PLACE
	jb reroll_cac_3
	call two_cac
	call check_dead
	jmp end_of_cac_3
	reroll_cac_3:
	call reset_cac
	end_of_cac_3:
	ret
endp cac_3
; Move cactus' version 2, just like described above with some different parmeters etc.
; (setup if first cac, delete previous, draw next, till limit)
proc cac_2
	cmp [cac_place], CAC_DEFUALT_PLACE
	je restart_cac2
	mov al, [cactus_color]
	push ax
	mov al, [background_color]
	mov [cactus_color], al
	call three_cacs
	pop ax
	mov [cactus_color], al
	jmp dont_restart_cac2
	restart_cac2:
	mov [cac_place], FOUR_CAC_INITIAL_PLACE
	dont_restart_cac2:
	mov ax, [cactus_skip]
	sub [cac_place], ax	
	cmp [cac_place], FOUR_CAC_LAST_PLACE
	jb reroll_cac_2	
	call three_cacs
	call check_dead
	jmp end_of_cac_2
	reroll_cac_2:
	call reset_cac
	end_of_cac_2:
	ret
endp cac_2

; Move cactus' version 1, just like described above with some different parmeters etc.
; (setup if first cac, delete previous, draw next, till limit)
proc cac_1 
	cmp [cac_place], CAC_DEFUALT_PLACE
	je restart_cac1
	mov al, [cactus_color]
	push ax
	mov al, [background_color]
	mov [cactus_color], al
	call small_basic_cacs
	pop ax
	mov [cactus_color], al
	jmp dont_restart_cac1
	restart_cac1:
	mov [cac_place], SB_CAC_INITIAL_PLACE
	dont_restart_cac1:
	mov ax, [cactus_skip]
	sub [cac_place], ax	
	cmp [cac_place], SB_CAC_LAST_PLACE
	jb reroll_cac_1
	call small_basic_cacs
	call check_dead
	jmp end_of_cac_1
	reroll_cac_1:
	call reset_cac
	end_of_cac_1:
	ret
endp cac_1

; Draws a dead dino - colors inner eye, draw a frame for the eye in the background_color
proc draw_dead_dino
    push es      
    push bp
    mov ax, GRAPHICS
    mov es, ax  
    mov bp, [dino_height] ; Draw according to current position 
    add bp, [dino_x_pos]  
    mov al, [dino_color]
    
	; Draw animation according to the dino's place and 
    ;LINE 1:   
    add bp, 322     
    ;Line2:  
	mov al, [background_color]
    mov cx,4 
    call draw_line               
    add bp, 316
    ;Line3:
	mov al, [background_color]
    mov cx, 1   
    call draw_line 
	mov al, [dino_color]
    mov cx, 2
	call draw_line
	mov al, [background_color]
    mov cx,1 
    call draw_line    
    add bp,316  
    ;Line4:
    mov al, [background_color]
    mov cx,4 
    call draw_line          
                ; The values were calculated...
                ;                       XXXXXXXXXXXXXXX  -line 1
                ;                      XXX     ,,,,,,,:X - line 2
                ;                      XX,  XX ,,,,,,,,;X - line 3
                ;                      XX,     ,,,,,,,,;X - line 4             
	pop bp
	pop es
	ret
endp draw_dead_dino 

;This function redraws the cloud  - adds CLOUD_SKIPS pixels offset to current cloud height and if it is max resets it. 
;The cloud is a very simple object/character because it doesn't interact with anything. 
proc redraw_cloud ;like eyes function, it does it every 1/2 of the times that function is called. 
	cmp [cloud_count], 0 
	ja dont_redraw_cloud
	;First Cloud:
	mov ax, [first_cloud_height]
	mov [cloud_height],ax
	call clouds_drawer
	mov ax, [cloud_height]
	mov [first_cloud_height],ax
	;Second cloud:
	mov ax, [second_cloud_height]
	mov [cloud_height],ax
	call clouds_drawer
	mov ax, [cloud_height]
	mov [second_cloud_height],ax
	;Third cloud:
	mov ax, [third_cloud_height]
	mov [cloud_height],ax
	call clouds_drawer
	mov ax, [cloud_height]
	mov [third_cloud_height],ax
	
	mov [cloud_count], 1
	dont_redraw_cloud:
	dec [cloud_count]
	ret
endp redraw_cloud

proc clouds_drawer ; gets height in cloud_height
	cmp [cloud_height], CLOUD_MAX_HEIGHT 
	jne dont_reset_cloud
	mov al, [cloud_color] ; deletes it 
	push ax
	mov al, [background_color]
	mov [cloud_color],al 
	call draw_cloud
	pop ax
	mov [cloud_color], al
	mov [cloud_height], CLOUD_INITIAL_HEIGHT ; resets it
	
	dont_reset_cloud:
	mov al, [cloud_color] ;deletes previous:
	push ax
	mov al, [background_color]
	mov [cloud_color],al 
	call draw_cloud
	pop ax
	mov [cloud_color], al
	sub [cloud_height], CLOUD_SKIPS ; draws new:
	call draw_cloud
	ret
endp clouds_drawer

;Bird:
;This function choses which kind of a bird to generate
; Low, Mid, or High according to a cactus_object_type - random number
proc generate_bird
	mov al, [cactus_object_type]
	push ax
	call random
	mov al, [cactus_object_type]
	mov bl, al
	pop ax
	mov [cactus_object_type], al
	xor bh,bh
	mov ax,bx
	mov bl, 3
	div bl
	cmp al, 1
	je mid_bird
	cmp al, 2
	je high_bird
	low_bird:
	mov [cac_place], LOW_BIRD_PLACE
	mov [bird_last_place], LOW_BIRD_LAST_PLACE
	jmp generated_bird
	mid_bird:
	mov [cac_place], MID_BIRD_PLACE
	mov [bird_last_place], MID_BIRD_LAST_PLACE
	jmp generated_bird
	high_bird:
	mov [cac_place],HIGH_BIRD_PLACE
	mov [bird_last_place], HIGH_BIRD_LAST_PLACE
	generated_bird:
	ret
endp generate_bird

; This function moves the bird till the end of the screen just like any other object
; But it also does an animation of wings to it, just like dino's blinking/ moving legs
; bird_drct is the counter, and Change_FLYING is the point of animation kind change (up/down), FLYING is the maximum value for bird_drct
proc mov_bird
	; Cover previous bird:
	cmp [cac_place], CAC_DEFUALT_PLACE
	je restart_bird
	mov al, [cactus_color]
	push ax
	mov al, [background_color]
	mov [cactus_color], al
	
	cmp [bird_drct], Change_FLYING
	jb bird_wing_down
	call draw_bird_up
	inc [bird_drct]
	mov ax, [bird_drct]
	mov bl, FLYING
	div bl 
	xor ah,ah
	mov [bird_drct], ax
	jmp over_bird_wing_down
	bird_wing_down:
	call draw_bird_down
	inc [bird_drct] 
	over_bird_wing_down:
	
	pop ax
	mov [cactus_color], al
	jmp dont_restart_bird
	restart_bird: ; Restart bird if it's a Default Cac Place
	call generate_bird
	dont_restart_bird:
	; Print new bird:
	mov ax, [cactus_skip] ; Advance:
	sub [cac_place], ax	
	mov ax, [bird_last_place]
	cmp [cac_place], ax
	jb reroll_bird	 ; check if reached limit
	
	; Print up/down bird as described above 
	cmp [bird_drct], Change_FLYING
	jb bird_wing_down_draw
	call draw_bird_up
	jmp dont_draw_wing_down
	bird_wing_down_draw:
	call draw_bird_down
	dont_draw_wing_down:
	; check if dino died
	call check_dead
	jmp end_of_mov_bird
	reroll_bird:
	call reset_cac ; reset cac if reached limit
	end_of_mov_bird:
	ret
endp mov_bird
;;;;;;;;;;;;;;;;;;;;;;
;;Ground:
;;;;;;;;;;;;;;;;;;;;;;
; Draws ground according to ground array
; The reason that I didn't make it random is because random numbers sometimes make wierd and unenjoyable patterns and it isn't important to make this random
; I used Consts BT_P and UPT_P each represents a pixel row, one up and one in the bottom.
; SI index counter = place in ground array, place in ground rows 
proc draw_ground
	push es
	mov ax, GRAPHICS
	mov es,ax ; GRAPHICS memory
	xor si,si ; Counter
	mov cx, 320
	draw_points:
	push cx
	; We decide what point to draw according to the number in the array, 1-0 = nothing, even = upper, uneven = bottom 
	xor ah,ah
	mov al, [ground+si]
	cmp al, 0
	je end_of_draw_point
	cmp al,1
	je bottom_point
	cmp ah, 0
	je upper_point
	bottom_point:
	mov al, [ground_color]
	mov bp, BT_P 
	add bp, si
	call point
	jmp end_of_draw_point
	upper_point:
	mov al, [ground_color]
	mov bp, UP_P
	add bp, si
	call point
	end_of_draw_point:
	inc si
	pop cx
	loop draw_points
	pop es
	ret
endp draw_ground

proc point ; Draws a point at [es:bp] 
	mov cx, 1
	call simple_draw_line
	ret
endp point 

proc adv_ground ; Moves ground arr 1 place forward, keeping the first byte and putting it at the end. 
	xor si,si
	mov al,[ground]
	mov cx, 319
	adv_arr:

	mov ah, [ground+si+1]
	mov [ground+si],ah
	inc si
	loop adv_arr
	mov [ground+319], al
	ret
endp adv_ground

; Summarizes all of ground funcs
; This function redraws ground (covers previous and draws new)
; In [ground_color], advancing it each time by cactus_skip times. 
proc moving_ground 
	mov al, [ground_color]
	push ax
	mov ah, [background_color]
	mov [ground_color], ah
	call draw_ground
	pop ax
	mov [ground_color],al
	mov cx, [cactus_skip] 
	advance_ground:
	push cx
	call adv_ground
	pop cx
	loop advance_ground
	call draw_ground
	ret
endp moving_ground














