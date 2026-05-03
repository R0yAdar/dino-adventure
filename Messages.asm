; rules page - rules/instructuions and header
;I used 0Ah and 0Dh which are like pressing enter(one brings you to a new line and the other to the beginning of it)
rules_header db '________       ______',0Ah,0Dh
             db '___  __ \___  ____  /____________',0Ah,0Dh 
             db '__  /_/ /  / / /_  /_  _ \_  ___/',0Ah,0Dh
             db '_  _, _// /_/ /_  / /  __/(__  )',0Ah,0Dh 
             db '/_/ |_| \__,_/ /_/  \___//____/',0Ah,0Ah,0Ah,0Dh

rules_info db 'DINO: [SPACE] => JUMP, AVOIDE CACTUSES',0Ah,0Ah,0Dh
           db 'NOTE: Lower levels => extra life',0Ah,0Ah,0Ah,0Dh
           db 'TETRIS: [A] = LEFT | [D] = RIGHT',0Ah,0Ah,0Dh
		   db '[S] = SKIP DOWN | [ENTER] = ALL THE WAY',0Ah,0Ah,0Dh
		   db '[SPACE] = SPIN',0Ah,,0Ah,0Dh
           db 'GAME ENDS AT LEVEL 15',0Ah,0AH,0dh
		   db 'Complete as many rows as you can!',0Ah,0AH,0AH,0dh
		   db 'Use [esc] to exit pages$'
; colors page - instructuions and header
colors_header db    '_________     ______',0Ah,0Dh                   
			  db	'__  ____/________  /__________________',0Ah,0Dh
			  db	'_  /    _  __ \_  /_  __ \_  ___/_  ___/',0Ah,0Dh
			  db	'/ /___  / /_/ /  / / /_/ /  /   _(__  )',0Ah,0Dh
			  db	'\____/  \____//_/  \____//_/    /____/ ',0Ah,0Ah,0Dh
                                                                          
colors_info db 'Choose Color Mode:',0Ah,0Ah, 0Dh
            db 'ORIGINAL[1] | RGB[2] | B&W[3]',0Ah,0Ah,0Dh
			db '   ALIEN[4] | NETHER[5]$' 

record_message db 'try to beat: ' 

congrats_mess db 'New Record - Congrats'
run_time_text db '000000'			
menu_header db 'Game Adventure by Roy Adar       Rules' 
colors_button db 'COLORS' ; click on 

rules_button db 'RULES' ;click on 

exit_button db 'EXIT[esc]' ; esc

lvl_1_but db 'Easy' 

lvl_2_but db 'Regular' 

lvl_3_but db 'PRO' 			

death_mess db 'CLICK ON [ESC] TO EXIT'

;Tetris:
beat_game_msg db 'YOU WON!'
score_msg db 'Score: 00000'
level_msg db 'Level: 00'
next_piece_msg db 'Next Piece:'