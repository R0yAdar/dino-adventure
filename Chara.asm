proc draw_dino ; draws a dino according to: dino_height, dino_x_pos and dino_color. It draws it's pixels directly to video memory (GRAPHICS = 0A000h), I created it with a specail program so it's much more efficent to use it.
	push es     ; Go to graphics segment
	push bp
	mov ax, GRAPHICS
	mov es, ax  
	mov bp, [dino_height]
	add bp, [dino_x_pos]  
	mov al, [dino_color]
	; I tried to describe a little bit about what the program did:
	;HEAD:
	;LINE 1:
	mov cx,15    ; line length
	call draw_line ; draws it
	add bp, 305 ; next line = +320 -bp's current offset from starting line 
	;Line2:   
	dec bp   ; line starts one place before
	mov cx,17 ; length = 17 pixels
	call draw_line                ; draw
	add bp, 303
	;Line3:
	mov cx, 5    ; as above with place for an eye
	call draw_line 
	add bp, 2
	mov cx,11 
	call draw_line 
	add bp,302 
	;Line4:
	mov cx, 18
	call draw_line
	add bp, 302
	;Line5:
	sub bp,16 
	mov cx,1 
	call draw_line
	add bp, 15
	mov cx, 18
	call draw_line
	add bp, 286 
	
	mov cx,2 
	call draw_line
	add bp, 14
	mov cx, 17
	call draw_line
	add bp, 287
	
	mov cx,3 
	call draw_line
	add bp, 13
	mov cx,11 
	call draw_line
	add bp, 293
	
	mov cx,4 
	call draw_line
	add bp, 12
	mov cx,16 
	call draw_line
	add bp, 288 
	
	mov cx,25 
	call draw_line
	add bp, 295
	
	mov cx, 24
	call draw_line
	add bp, 296
   
	mov cx, 25
	call draw_line
	add bp, 295 
	
	inc bp
	mov cx, 21
	call draw_line
	inc bp
	mov cx, 2
	call draw_line
	add bp, 295 	
	
	add bp, 2
	mov cx, 20
	call draw_line
	inc bp
	mov cx, 2
	call draw_line
	add bp, 294
	
	add bp, 3
	mov cx, 19
	call draw_line
	add bp, 297
	
	add bp, 5
	mov cx, 17
	call draw_line
	add bp, 298   
	
	add bp, 6
	mov cx, 15
	call draw_line
	add bp, 299	
	
	add bp, 8
	mov cx, 12
	call draw_line
	add bp, 300
	
	add bp, 8
	mov cx, 3
	call draw_line 
	add bp, 3
	mov cx, 3
	call draw_line
	add bp, 303
   
	add bp, 8
	mov cx, 3
	call draw_line 
	add bp, 3
	mov cx, 3
	call draw_line
	add bp, 303 
	;line 20:
	add bp, 8
	mov cx, 4
	call draw_line 
	add bp, 2
	mov cx, 4
	call draw_line
	add bp, 303
			;                       XXXXXXXXXXXXXXX  -line 1
			;                      XXX,:--;,,,,,,,:X - line 2
			;                      XX,,;__;,,,,,,,,;X - line 3
			;                      XX,,,,,,,,,,,,,,;X - line 4
			;     'X               XX,,,,,,,,,,,,,,;X  -line 5
			;     'XX              XX,,,,,,,;XXXXXXX   - line 6
			;     'XXX             XX,,,,,,,XX         -line 7
			;     'X;XX            XX,,:,,,,;XXXXXX    - line 8 
			;     'X;XXXXXXXXXXXXXX,,,,,,,:X       - line 9
			;     'X;,,,,,,,,,,,,,,,,,,;XXX          - line 10
			;     'XX;,,,,,,,,,,,,,,,,,:XXXX         -line 11
			;     ' XX;,,,,,,,,,,,,,,,,;X XX         - line 12
			;     '  XX;,,,,,,,,,,,,,,,;X XX       -line 13
			;     '   XXX;,,,,,,,,,,,,;XX         - line 14
			;     '     XXXXX,,,,,,,,;XXX          -line 15
			;     '      XXXXX;;;;;;;;XX           -line 16
			;     '        XXXXXXXXXXXX            - line 17
			;     '        XXX   XXX               - line 18
			;     '        XXX   XXX               -line 19
			;     '        XXXX  XXXX             -line 20 - This is how dinoasur basically looks 
			  
	pop bp
	pop es
	ret
endp draw_dino 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Dino Cactus Desgins;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Small Cactus VER1:
; same as above, but this time the character is a small cactus (version 1), program draw it according to cactus_height and cactus_color.
proc small_cactus_1      ; bp height, al color   	
	push es      
	push bp
	mov ax, GRAPHICS
	mov es, ax  
	mov bp, [cactus_height]  
	mov al, [cactus_color]
    ;line 1:
    add bp, 5
    mov cx, 3
    call draw_line
    add bp, 316    
    ;line 2:
    mov cx, 5 
    call draw_line
    add bp, 311
    
    mov cx, 2
    call draw_line
    add bp, 2
    mov cx, 5 
    call draw_line
    add bp, 311    
    
    mov cx, 2
    call draw_line
    add bp, 2
    mov cx, 5 
    call draw_line
    inc bp
    mov cx,2 
    call draw_line
    add bp, 308
   
    mov cx, 2
    call draw_line
    add bp, 2
    mov cx, 5 
    call draw_line
    inc bp
    mov cx,2 
    call draw_line
    add bp, 308
   
    mov cx, 9 
    call draw_line
    inc bp
    mov cx,2 
    call draw_line
    add bp, 308
   
    add bp, 2 
    mov cx, 7
    call draw_line
    inc bp
    mov cx, 2
    call draw_line
    add bp,308
  
    add bp, 4 
    mov cx, 8
    call draw_line
    add bp, 312
    
    mov cx, 4
    call draw_line
    add bp, 316
    
    mov cx, 4
    call draw_line
    add bp,316
    
    mov cx, 4
    call draw_line
	pop bp
	pop es        
	ret
endp small_cactus_1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;Small Cactus VER2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; same as above, but this time the character is a small cactus (version 2), program draws it according to cactus_height and cactus_color.
proc small_cactus_2  
	push es      
	push bp
	mov ax, GRAPHICS
	mov es, ax  
	mov bp, [cactus_height]
	mov al, [cactus_color]
    ;line 1:
    add bp, 4
    mov cx, 3
    call draw_line
    add bp, 313    
    ;line 2:
    add bp, 4
    mov cx, 4 
    call draw_line
    add bp, 312 
    ;line 3:
    add bp, 4
    mov cx, 4 
    call draw_line
    add bp, 312
    ;line 4:
    mov cx, 1
    call draw_line
    add bp, 3
    mov cx, 4
    call draw_line
    add bp, 2
    mov cx, 2
    call draw_line
    add bp, 308  
    ;line 5:    
    mov cx, 2
    call draw_line
    add bp, 2
    mov cx, 4
    call draw_line
    add bp, 2
    mov cx, 2
    call draw_line
    add bp, 308    
    ;line 6:
    mov cx, 2
    call draw_line
    add bp, 2
    mov cx, 4
    call draw_line
    add bp, 2
    mov cx, 2
    call draw_line
    add bp, 308   
    ;line 7: 
    mov cx, 2
    call draw_line
    add bp, 2
    mov cx, 4
    call draw_line
    add bp, 2
    mov cx, 2
    call draw_line
    add bp, 308
    ;line 8:  
    mov cx, 10
    call draw_line
    add bp,310     
    ;line 9:     
    add bp, 4 
    mov cx, 4
    call draw_line
    add bp,312    
    ;line 10: 
    add bp, 4 
    mov cx, 4
    call draw_line
    add bp,312    
    ;line 11:
    add bp, 4 
    mov cx, 4
    call draw_line
	pop bp
	pop es
	ret
endp small_cactus_2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;Cactus
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; same as above, but this time the character is a 'basic' cactus, program draw it according to cactus_height and cactus_color.
proc basic_cactus		
	push es      
	push bp
	mov ax, GRAPHICS
	mov es, ax  
	mov bp, [cactus_height]
	mov al, [cactus_color]
	
	add bp, 9
	mov cx,4    
	call draw_line 
	add bp, 316
	
	mov cx,4    
	call draw_line                
	add bp, 315        
	
	mov cx, 6  
	call draw_line 
	add bp, 314   
	
	mov cx, 6    
	call draw_line 
	add bp, 314
	
	mov cx, 6   
	call draw_line 
	add bp, 314
	
	mov cx, 6    
	call draw_line 
	add bp, 314        
	      
	mov cx, 6   
	call draw_line 
	add bp, 314   
	
	mov cx, 6   
	call draw_line 
	add bp, 314         
	
	mov cx, 6    
	call draw_line 
	add bp, 314
	
	sub bp,7 
	mov cx, 4
	call draw_line 
	add bp,3
	mov cx, 6
	call draw_line
	add bp, 306 		
   
	mov cx, 6
	call draw_line
	add bp,2 
	mov cx, 6
	call draw_line
	add bp,3
	mov cx,3
	call draw_line       
	add bp, 300 
	
	mov cx, 6
	call draw_line
	add bp,2 
	mov cx, 6
	call draw_line
	add bp,3
	mov cx,3
	call draw_line
	add bp, 300 
	
	mov cx, 6
	call draw_line
	add bp,2 
	mov cx, 6
	call draw_line
	add bp,3
	mov cx,3
	call draw_line       
	add bp, 300 
	
	mov cx, 6
	call draw_line
	add bp,2 
	mov cx, 12
	call draw_line
	add bp, 300 
	
	mov cx, 6
	call draw_line
	add bp,2 
	mov cx, 12
	call draw_line       
	add bp, 300  
	
	mov cx, 14
	call draw_line
	add bp, 308
	
	mov cx, 12
	call draw_line
	add bp, 310        
	
	mov cx, 10
	call draw_line         
	add bp, 314        
   
	mov cx, 6
	call draw_line
	add bp, 314
	
	mov cx, 6
	call draw_line
	add bp, 314 
	
	mov cx, 6
	call draw_line
	;@@@@@@@@@((((@@@@@@@
	;@@@@@@@@@((((@@@@@@@
	;@@@@@@@@((((((@@@@@@
	;@@@@@@@@((((((@@@@@@
	;@@@@@@@@((((((@@@@@@
	;@@@@@@@@((((((@@@@@@
	;@@@@@@@@((((((@@@@@@               
	;@@@@@@@@((((((@@@@@@
	;@@@@@@@@((((((@@@@@@
	;@((((@@@((((((@@@@@@
	;((((((@@((((((@@@(((
	;((((((@@((((((@@@(((
	;((((((@@((((((@@@(((
	;((((((@@((((((((((((
	;((((((@@((((((((((((
	;((((((((((((((@@@@@@
	;@@((((((((((((@@@@@@
	;@@@@((((((((((@@@@@@
	;@@@@@@@@((((((@@@@@@
	;@@@@@@@@((((((@@@@@@
	;@@@@@@@@((((((@@@@@@
	pop bp
	pop es        
	ret
endp basic_cactus
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;cloud 
; same as above, but this time the character is a cloud, program draw it according to cloud_height and cloud_color.
proc draw_cloud
	push es	
	mov ax, GRAPHICS
	mov es, ax
	mov bp, [cloud_height] 
	mov al, [cloud_color]
	
	add bp, 19
	mov cx, 18
	call simple_draw_line
	add bp, 38
	add bp, 245
	
	add bp, 11
	mov cx, 11
	call simple_draw_line
	add bp,14 
	mov cx, 3
	call simple_draw_line     
	add bp, 8
	mov cx,8 
	call simple_draw_line

	add bp, 265           
	add bp,7
	mov cx,5 
	call simple_draw_line 
	add bp, 27     
	mov cx, 8
	call simple_draw_line
	add bp,8 
	mov cx,9 
	call simple_draw_line
	add bp, 256      
	
	add bp, 5
	mov cx, 2
	call simple_draw_line
	add bp, 52 
	mov cx,  7 
	call simple_draw_line
	add bp, 254
	
	add bp, 3     
	mov cx, 3
	call simple_draw_line 
	add bp, 58
	mov cx, 5
	call simple_draw_line
	add bp, 251
	                      
	add bp, 3     
	mov cx, 2
	call simple_draw_line 
	add bp, 62
	mov cx, 1
	call simple_draw_line
	add bp, 252
	
	add bp, 1     
	mov cx, 3
	call simple_draw_line 
	add bp, 63
	mov cx, 4
	call simple_draw_line
	add bp, 248   
	
	mov cx,2
	call simple_draw_line
	add bp,69
	mov cx, 4
	add bp,247
	
	inc bp
	mov cx, 1
	call simple_draw_line 
	add bp, 51
	mov cx,7
	call simple_draw_line
	add bp, 12
	mov cx, 3
	call simple_draw_line
	add bp, 245
	
	inc bp
	mov cx, 53
	call simple_draw_line
	add bp, 6
	mov cx, 15
	call simple_draw_line 
	pop es
	ret
endp draw_cloud       
	;					XXXXXXXXXXXXXXXXXX										      
	;			XXXXXXXXXXX				 XXX		XXXXXXXX                           
	;		XXXXX							XXXXXXXX    	XXXXXXXXX                  
	;     XX													XXXXXXX                
	;	XXX															XXXXX              
	;	XX																 X              
	; XXX    															          
	; X    																    XX         
	; X 												  XXXXXXX   	    XXXX       
	; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX      XXXXXXXXXXXXXXX
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc draw_bird_up
	push es      
	mov ax, GRAPHICS
	mov es, ax  
	mov bp, [cac_place]
	mov al, [cactus_color]

	add bp,013

	mov cx,002

	call draw_line

	add bp,317

	mov cx,005

	call draw_line

	add bp,315

	mov cx,007

	call draw_line


	add bp,308

	mov cx,004

	call draw_line

	add bp,002

	mov cx,009

	call draw_line

	add bp,018

	add bp,285

	mov cx,007

	call draw_line

	add bp,002

	mov cx,010

	call draw_line

	add bp,016

	add bp,283

	mov cx,010

	call draw_line

	add bp,001

	mov cx,012

	call draw_line

	add bp,014

	add bp,281

	mov cx,027

	call draw_line

	add bp,012

	add bp,280

	mov cx,028

	call draw_line

	add bp,012

	add bp,280

	mov cx,030

	call draw_line

	add bp,010

	add bp,292

	mov cx,028

	call draw_line

	add bp,294

	mov cx,026

	call draw_line

	add bp,296

	mov cx,023

	call draw_line
	;            ,'                         
	;            .;c,.                       
	;            .;llc,.                     
	;       .''.  .,cll:,'.                  
	;     .,cll:.  .:lllllc,.                
	;   .,:llllc;. .:lllllll:,.              
	; .,:llllllll;..:lllllllll:,.            
	;,:ccccccccclc;:clllllllllll'            
	;...........;cllllllllllllll:,.          
	;            .;cllllllllllllllc;;;;;,,,,,
	;              .;clllllllllllllllllc'....
	;                .;cllllllllllllllc:;,,' 
	;                 .'cllllllllllllc'.... 
	pop es 
	ret
endp draw_bird_up
proc draw_bird_down
	push es
	mov ax, GRAPHICS
	mov es, ax
	mov bp, [cac_place]
	mov al, [cactus_color]

	add bp, 9
	mov cx,004

	call draw_line

	add bp,027

	add bp,287

	mov cx,006

	call draw_line

	add bp,027

	add bp,285

	mov cx,010

	call draw_line

	add bp,025

	add bp,283

	mov cx,012

	call draw_line

	add bp,025

	add bp,281

	mov cx,028

	call draw_line

	add bp,011

	add bp,292

	mov cx,028

	call draw_line

	add bp,294

	mov cx,026

	call draw_line

	add bp,296

	mov cx,023

	call draw_line

	add bp,001

	add bp,296

	mov cx,023

	call draw_line

	add bp,001

	add bp,296

	mov cx,017

	call draw_line

	add bp,007

	add bp,296

	mov cx,008

	call draw_line

	add bp,016

	add bp,296

	mov cx,006

	call draw_line

	add bp,018

	add bp,296

	mov cx,004

	call draw_line
	pop es
	ret
endp draw_bird_down

proc three_cacs ; draws 3 small cactuses at small cactus height
	mov ax, [cac_place] ; SMALL_CAC_OFFSET is an constant used to put space between cacs
	sub ax, FOUR_CAC_OFFSET
	mov [cactus_height], ax
	call small_cactus_1
	add [cactus_height], SMALL_CAC_OFFSET
	call small_cactus_2
	add [cactus_height], SMALL_CAC_OFFSET
	call small_cactus_2
	ret
endp three_cacs

proc common_cac ; draws a basic cactus at basic_cac_height, this is the most common cactus in the game
	mov ax, [cac_place] 
	mov [cactus_height], ax
	call basic_cactus
	ret
endp common_cac

proc two_cac ; draws two basics cactuses at basic cac height 
	mov ax, [cac_place]
	mov [cactus_height], ax ; BASIC_CAC_OFFSET is an constant used to put space between them 
	call basic_cactus
	add [cactus_height], BASIC_CAC_OFFSET
	call basic_cactus
	ret
endp two_cac

proc small_basic_cacs ; draws a small cactus and then a basic cactus
	mov ax, [cac_place] ; according to basic_cac_height
	mov [cactus_height], ax
	call basic_cactus
	 ; converts basic_cac_height so it will be appropriate for small cac, theres a 10 pixels offset in it to
	add [cactus_height],3190 ; (Calculated 1 time appeard const)
	call small_cactus_1
	ret
endp small_basic_cacs



