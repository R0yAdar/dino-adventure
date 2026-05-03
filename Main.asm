; Game Adventure by Roy Adar
; All the rights are reserved 
;--------------------------------------------------------------;
IDEAL
MODEL small
STACK 1000h
DATASEG
;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;; T E T R I S
;;;;;;;;;;;;;;;;;;;;;;;;
game_speed dw INITIAL_GSPEED
MAX_SHAPE_SIZE EQU 4
INITIAL_GSPEED EQU 10
MIN_SPEED EQU 4
screen db 2 dup (40 dup (0)) ; screen is 40*25 ; Tetris header
	   db 14 dup(0),12 dup(WHITE),14 dup (0)   ; Up LIMIT
	   db 19 dup (14 dup(0),WHITE,10 dup(0),WHITE, 14 dup (0)) ; 19 rows out of 25 - game rows 
	   db 14 dup(0),12 dup(WHITE),14 dup (0)   ; Bottom LIMIT
	   db 2 dup (40 dup (0))      
speed_row db 0; go fast=>1 |

shape_x_place dw 3

help_arr db 16 dup(0)

SHAPE_SIZE EQU 4 ; the size of course is 4x4 but this const is only for 1 dimension of the shape size.

filled_lines dw 0 
points dw 0
level dw 0 
score dw 0 


CHANGE_LEVEL_SCORE EQU 60000

BOARD_FALL_START EQU 175 ; THE LINE WHICH SHAPES BEGIN TO FALL FROM

skip_delay db 0 ; 1=> skip | 0=> don't skip

NEXT_PIECE_PLACE EQU 95

	   ;example of small screen:
	   ;XXXXXXX
	   ;X     X
	   ;X  Y  X
	   ;X  Y  X
	   ;X YY  X
	   ;XXXXXXX
	   ;10*19	- starting from row 4 (3*40*8^2 = 7680), ends at row 23 (20*40*8^2=51200)
BOARD_START EQU 7680
BOARD_END EQU 51200 
SCREEN_BOARD EQU 120
SCREEN_BOARD_SKIP EQU 14
CLOCK EQU es:6CH
; Game Mechanics: 
; They Stop Moving when tackling an object 
; After being placed, program checks if a row is completed, starting from the lowest row 
; If a row has been completed - advance all above screen rows...
; To turn a character 90(deg) (switch rows with cols), User Needs to click on [SPACE] 
; To go all the way down click on [enter]
; To go left/right use [a]/[d] accordingly 

possible db 0 ; 0=> possible|1=>can't
tetris_mesg db 'T',13,'E',14,'T',11,'R',4,'I',12,'S',10
shape_height dw 0 
clear_shape db 0 ; 0 => no | 1 => yes

lines_msg db 'Lines: 0000'


bag db 0,1,2,3,4,5,6
bag_took db 7 dup(0)
taken db 0 

;Shapes:
shape1 db 0,13,0,0
	   db 13,13,13,0
	   db 0,0,0,0   
	   db 0,0,0,0   
	   
shape2 db 14,14,0,0
	   db 14,14,0,0
	   db 0,0,0,0
	   db 0,0,0,0   
	   
shape3 db 11,11,11,11
	   db 0,0,0,0
	   db 0,0,0,0
	   db 0,0,0,0 

shape4 db 1,0,0,0
	   db 1,1,1,0
	   db 0,0,0,0
	   db 0,0,0,0  

shape5 db 0,0,12,0
	   db 12,12,12,0
	   db 0,0,0,0
	   db 0,0,0,0 

shape6 db 0,10,10,0
	   db 10,10,0,0
	   db 0,0,0,0
	   db 0,0,0,0     

shape7  db 4,4,0,0
	    db 0,4,4,0
	    db 0,0,0,0
	    db 0,0,0,0  
	   
	  
	   
help_shape db 16 dup (0)
clean_shape db 16 dup(1)
next_block db 0 ; identifier
next_shape dw 0 ; place in memory
generated_block db 	0 ; identifier
block dw ? ; place in memory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	DINO:
;;;;;;;;
;HI:
run_time_sum dw 0

HI_LENGTH equ 5 
HI_COLOR equ 1111b
SCORE_PER_MOV equ 2
filename db 'rcrd.txt',0 ; the filne-name of the dino-game's record storing .txt file
filehandle dw ?  
data_from_file db 6 dup(?) ; record

;Night - Weather
night db 0 ;
;Ground:
BT_P equ 62400
UP_P equ 62720 
GROUND_SKIP equ 10
ground db 2 dup(1,1,0,1,1,1,1,1,2,2,2,2,2,2,2,2,2,0,0,0,1,1,1,1,1,1,0,2,2,2,1,1,1,1,1,0,0,1,1,1,2,0,2,0,0,0,0,1,1,1,2,0,1,1,1,1,1,1,1,2,2,2,0,1,2,1,0,0,2,2,2,2,2,2,2,2,1,1,1,0,2,1,1,0,1,1,1,1,1,2,2,2,2,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,2,2,2,1,1,1,0,1,0,0,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,1,1,2,1,2,0,0,0,0,0,0,2,2,2,0,0,2,2,2,1,1,1,0,2)
ground_color db 7
;Consts:
GROUND_LINE equ 61760
;Background:
background_color db LIGHT_GRAY
cloud_color db WHITE
cloud_height dw CLOUD_INITIAL_HEIGHT
first_cloud_height dw CLOUD_INITIAL_HEIGHT
second_cloud_height dw SECOND_CLOUD_INITIAL_HEIGHT
third_cloud_height dw THIRD_CLOUD_INITIAL_HEIGHT

;Dino:
dino_height  dw DINO_INITIAL_HEIGHT 
dino_x_pos dw 17        
dino_color db  MENU_DINO_COLOR   
hit_cactus db 1 ; acts as boolian flag
dino_life db 3
;REFRESH:
eye db BLINKING 
leg db 0

;Consts:
THIRD_CLOUD_INITIAL_HEIGHT equ 12099
SECOND_CLOUD_INITIAL_HEIGHT equ 5200
CLOUD_INITIAL_HEIGHT equ 20000
CLOUD_MAX_HEIGHT equ 3200
CLOUD_SKIPS equ 1
cloud_count db 1 ; counts when cloud's function was called but didn't move clouds, (clouds move slow 1/2)
JUMP equ 2880 ; Height increases per frame
DINO_INITIAL_HEIGHT equ 55080 
DINO_JUMP_SKIP equ 5 ; Jump's frames
DINO_EYE equ 644 ; offset from dino place  
DINO_RIGHT_LEG_UP equ 5758
DINO_RIGHT_LEG_DOWN equ 6075
DINO_LEFT_LEG_UP equ 5752
DINO_LEFT_LEG_DOWN equ 6069
BLINKING equ 5 


;cactus:     
cactus_color db DARK_GRAY    
cactus_skip dw INTIAL_CACTUS_SKIP  
cactus_height dw ? ; for draw functions 
cactus_object_type db ?
bird_in_air db 0 
cac_place dw CAC_DEFUALT_PLACE ; for move functions

cactus_move_per_jump dw 2 ; number of times to move a cactus while dino is in air
;Consts:
TWO_CAC_INITIAL_PLACE equ 55322
TWO_CAC_LAST_PLACE equ 55040

FOUR_CAC_INITIAL_PLACE equ 58540
FOUR_CAC_LAST_PLACE equ 58255

SB_CAC_INITIAL_PLACE equ 55340
SB_CAC_LAST_PLACE equ 55048

CAC_DEFUALT_PLACE equ 0 
BASIC_CAC_INITIAL_PLACE equ 55345
BASIC_CAC_LAST_PLACE equ 55040

BASIC_CAC_OFFSET equ 24
SMALL_CAC_OFFSET equ 14
FOUR_CAC_OFFSET equ 20
INTIAL_CACTUS_SKIP equ 9

MAX_CACTUS_SKIP equ  19

POINTS_PER_CAC EQU 5 ; Except for the points for every move. (add-on)
;Bird:
LOW_BIRD_PLACE equ 55330
LOW_BIRD_LAST_PLACE equ 55040
MID_BIRD_PLACE equ 52130
MID_BIRD_LAST_PLACE equ 51840
HIGH_BIRD_PLACE equ 47330
HIGH_BIRD_LAST_PLACE equ 47040
bird_height dw ? 
bird_place dw Bird_Initial_Place
Bird_Initial_Place equ 55320
bird_last_place dw ?
bird_drct dw 0 ; <3 = down >3 = up 
FLYING equ 3;7
CHANGE_FLYING equ 1;3
MAX_RUN_TIME EQU 65000





;Others:	
CLOCK equ es:6Ch	
NEXT_PIXELS_ROW equ 320
SCREEN_SIZE equ 64000
GRAPHICS equ 0a000h
FART_BONUS equ 15
;Colors:

BLACK equ 0 
WHITE equ 1111b
RED equ 100b
YELLOW equ 1110b
MAGNETA equ 101b
LIGHT_GREEN equ 1010b
GREEN equ 10b
BLUE equ 1b
LIGHT_BLUE equ 1001b
LIGHT_GRAY equ 111b
DARK_GRAY equ 1000b
MENU_DINO_COLOR equ 69
;Menu:
START_OF_ROW equ 1

ROW_SPACING equ 4

;background:

NIGHT_TIME equ 700
SPEED_UP_PER equ 3000 ; EVERY 3000 POINTS 
ONE_JUMP_CAC_SKIP_TIME equ 20000
ZERO_JUMP_CAC_SKIP_TIME equ 40000
include "Messages.asm"
;sounds:
DEATH_NOTE equ 2394h
FART1_NOTE equ 7777h
FART2_NOTE equ 6666h
JMP_NOTE equ 4143
CODESEG
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SCORE:
include "Pages.asm"
include "Record.asm"
include "Chara.asm"
include "Anim.asm"
include "Random.asm"
include "Tools.asm"
include "Tetris.asm"
include "TScreen.asm"
include "TRandom.asm"


proc mouse_status ; this proc checks the mouse status using this INT
	mov ax,3h
	int 33h
	ret
endp mouse_status

proc simple_print ; this proc prints messages to screen using this INT, just makes things more readable and convienient. 
	mov ah, 9
	int 21h
	ret
endp simple_print

proc reset_game ; resets games vars values(with initial ones), most of them are very essential to game's proper run 
	mov [dino_height], DINO_INITIAL_HEIGHT
	mov [dino_x_pos], 17
	mov [hit_cactus], 1

	mov [eye], BLINKING 
	mov [leg], 0

	mov [cactus_skip], INTIAL_CACTUS_SKIP  
	mov [cac_place], CAC_DEFUALT_PLACE
	
	mov [bird_in_air], 0
	ret
endp reset_game

proc reset_cac ; resets cactuses places to normal ones:
	mov [cac_place], CAC_DEFUALT_PLACE
	call random ;  also calls random => which may change obstacle to another cactus version
	cmp [cactus_object_type],5; creates a delay between cactuses apearrences:
	jna skip_increasing_for_delay
	mov al, [cactus_object_type]
	push ax
	call random
	pop ax
	add [cactus_object_type], al
	skip_increasing_for_delay:
	add [run_time_sum], POINTS_PER_CAC
	ret
endp reset_cac 

; This is perhaps the 'most' important part of code
; This function advances the on-screen cactus cactus_skip places
; It gets the cactus kind from cactus_object_type
; While doing that it also calls moving_ground function and redraw_cloud
; basically this function 'runs' the game forward
; There's also a delay created by the called functions
proc cactus_move
	add [run_time_sum], SCORE_PER_MOV ; at every movment of a cactus the score increases by Score_Per_Mov(e of a cactus)
	call moving_ground
	call redraw_cloud
	cmp [cactus_object_type],0
	je cactus_sit1 

	cmp [cactus_object_type],1
	je cactus_sit2

	cmp [cactus_object_type],2
	je cactus_sit3
	
	cmp [run_time_sum], 3000 
	jna no_birds
	cmp [cac_place],CAC_DEFUALT_PLACE
	je dont_check_if_bird
	cmp [bird_in_air], 1
	jne no_birds
	dont_check_if_bird:
	cmp [cactus_object_type],3 
	jne no_birds
	call mov_bird
	mov [bird_in_air],1
	jmp end_of_cactus_mov
	no_birds:
	
	cmp [cactus_object_type],5 ; creates a delay between cactuses apearrences:
	jna dont_create_delay_between
	dec [cactus_object_type]
	cmp [cactus_object_type], 5
	jne end_of_cactus_mov
	call random
	jmp end_of_cactus_mov
	dont_create_delay_between:
	;common_cac:
	call com_cac	

	jmp end_of_cactus_mov
	cactus_sit3: 
	call cac_1

	jmp end_of_cactus_mov
	cactus_sit2: 
	call cac_2	

	jmp end_of_cactus_mov
	cactus_sit1:
	call cac_3
	end_of_cactus_mov:
	call delay ; creates a delay 
	call hi    ; refresh hi display 
	ret
endp cactus_move
proc invert_colors
	mov al, 15
	sub al, [cactus_color]
	mov [cactus_color],al						;cactus, dino , cloud, ground 
	mov al, 15
	sub al, [dino_color]
	mov [dino_color],al
	mov al, 15
	sub al, [cloud_color]
	mov [cloud_color],al
	mov al, 15
	sub al, [ground_color]
	mov [ground_color],al
	mov al, 15
	sub al, [background_color]
	mov [background_color],al
	call set_background ; colores background
	call draw_ground_line ; draws 'ground line'
	call draw_dino ; draws dino at initial place 
	call draw_cloud ; draws initial cloud 
	call display_record; display_record 
	ret
endp invert_colors

; This function increases cactus_skip which results higher speeds by 1 every 3000 points
; Until reaching maximum value 
proc speed_up
	cmp [cactus_skip], MAX_CACTUS_SKIP 
	jae dont_increase_skip
	mov ax, [run_time_sum]
	xor dx,dx 
	mov bx, SPEED_UP_PER    
	div bx 
	xor ah,ah
	mov [cactus_skip], INTIAL_CACTUS_SKIP
	add [cactus_skip], ax
	dont_increase_skip:
	; Change Weather code: if the counter which works with [night] and dividing in 2 (checking if even or isn't, compares to last ones kind and if it's different, change weather)
	mov ax, [run_time_sum]
	xor dx,dx 
	mov bx, NIGHT_TIME ; every 700 points    
	div bx 
	mov bl, 2 
	div bl
	cmp ah,[night] 
	je end_of_speed_up
	mov [night], ah
	call invert_colors ; change weather 
	end_of_speed_up:
	cmp [run_time_sum], ONE_JUMP_CAC_SKIP_TIME  ; used for higher speeds
	jne skip_decreasing_cactus_mov_per_jump
	mov [cactus_move_per_jump], 1
	skip_decreasing_cactus_mov_per_jump:
	cmp [run_time_sum], ZERO_JUMP_CAC_SKIP_TIME
	jne skip_decreasing_cactus_mov_per_jump2
	mov [cactus_move_per_jump], 0  ; used for higher speeds
	skip_decreasing_cactus_mov_per_jump2:
	cmp [run_time_sum], MAX_RUN_TIME
	jb didnt_reach_end_of_dino_game
	pop cx
	mov cx, 8
	mov bl, [background_color]
	mov dl, 16
	mov dh,8
	lea bp, [beat_game_msg]
	call advanced_printing
	call death
	didnt_reach_end_of_dino_game:
	ret
endp speed_up 

; This function draws a line at GROUND_LINE
proc draw_ground_line
	push es
	mov ax, GRAPHICS
	mov es, ax
	mov bp, GROUND_LINE
	mov cx, 320
	call simple_draw_line
	pop es
	ret
endp draw_ground_line



; This is the game function which combines the different parts to a full game 
proc game
	; setup:
	call reset_game ; resets vars values for optimal running - resets after death (when player has more than one life)
	mov ax, 2 ; closes mouse 
	int 33h
	call reset_cac ; resets cac 
	call set_background ; colores background
	call hi	; displays score
	call draw_ground_line ; draws 'ground line'
	call draw_dino ; draws dino at initial place 
	call draw_cloud ; draws initial cloud 
	call display_record; display_record 
	; While game runs:
	play_game:
	mov sp, 1000 ; reset stack
	; functions does as they say...
	call stop_sound
	call cactus_move
	call refresh_eye
	call refresh_legs
	call speed_up 
	; Check if there's an input
	mov ah, 1 
	int 16h        
	jz play_game
	mov ah, 0 
	int 16h
	cmp al, 'd' ; Click d to die 
	jne dont_want_to_die
	call death
	dont_want_to_die:
	cmp al, 'r' ; This isn't a bug!!!!!!!!!!
	jne skip_easter_egg ; I love eastereggs and had an urge to create one, the first letter of my name (r oy) is 'r', so if you click on it while running 
	mov [dino_life], 100 ; You get a nice amount of extra life, I used mov instead of add because add could result an overflow or somethings. If it is bigger than var's max value
	skip_easter_egg:
	cmp al,'f' 
	jne skip_fart_egg ; Clicking f will result in a fart sound
	mov bx, FART1_NOTE
	call make_sound
	call cactus_move
	call cactus_move
	mov bx, FART2_NOTE
	call make_sound
	call cactus_move
	add [run_time_sum], FART_BONUS
	call stop_sound
	skip_fart_egg:
	cmp al, 20h ; If there's a space input => JUMP, continue to JUMP process
	jne play_game ; Else return to beginning of play games- while game runs... 
	call clear_refreshed; when jumping we don't run! cover it. 
	mov bx, JMP_NOTE ; make JUMP sound
	call make_sound 
	call dino_jump ; of course- call the JUMP function 
	
	;;;;;;;;;;;;;;;;(isnt part of JUMP) 
	mov ah, 0ch  ; flush buffer if space was preesed multiple times
	int 21h
	;;;;;;;;;;;;;;;;
	mov cx, [cactus_move_per_jump]; cactus move cactus_move_per_jump places when dino in air 
	play_game_cactus_moves_per_jump: 
	push cx
	call cactus_move 
	pop cx
	loop play_game_cactus_moves_per_jump
	
	call dino_land ; then complete the process with dino land 
	jmp play_game
endp game



start :
mov ax, @data
mov ds, ax
mov es, ax
;Graphics mode:
mov ax, 13h
int 10h
;	starts menu/ opening screen....
call menu  
quit :
mov ax, 4c00h
int 21h
END start