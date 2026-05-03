proc num_to_text ;  num address => si, string address => di(last place in string)
	mov ax, [si] ;  program divides num in 10 until there's nothing left to divide. 
	mov bx, 10	 ;	every time it takes the digit, and places it in a string, and converts it to ascii (+30h)
	xor dx,dx
	ntt_divide: ;(ntt = num to text)
	div bx
	add dl, 30h
	mov [di], dl
	xor dx,dx
	dec di
	cmp ax, 0
	jne ntt_divide
	ret
endp num_to_text

proc advanced_printing ;	PRINTS STRING BP AT DL, DH, WITH COLOR AT BL
	mov ax, @data	   ;	BP has to conatin string's offset and cx has to conatin the length  
	mov es, ax
	xor ax,ax
	xor bh,bh 
	mov ah, 13h
	int 10h
	ret
endp advanced_printing

;	Function orginaizes things
;	loads adresses 
;	then uses num_to_text function
;	then uses advanced_printing to print the score. 
proc hi
	lea si, [run_time_sum] 
	lea di, [run_time_text]
	add di, HI_LENGTH
	call num_to_text
	xor dh,dh
	mov dl, 34
	lea bp,[run_time_text]
	mov bl, HI_COLOR 
	mov cx, 6
	call advanced_printing 
	ret
endp hi

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Files (Because I use this functions only for the record part, they aren't modular but adjusted to this specific action
;;;;;;;;;;;;;;;;;;;;;;;;;;
proc open_file
	; Open file for reading and writing
	mov ah, 3Dh
	mov al, 2
	mov dx, offset filename
	int 21h
	mov [filehandle], ax
	ret
endp open_file
proc write_to_file 
	; Write message to file
	mov ah,40h
	mov bx, [filehandle]
	mov dx,offset run_time_text 
	int 21h 
	ret
endp write_to_file
proc close_file
	; Close file 
	mov ah,3Eh
	mov bx, [filehandle]
	int 21h 
	ret
endp close_file
proc read_file
	;reads cx bytes from a file 
	mov ah,3Fh
	mov bx, [filehandle]
	mov cx,6
	mov dx,offset data_from_file
	int 21h 
	ret
endp read_file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


proc display_record
	call open_file ; using these commands I open rcrd.txt file (record), copy the record's score to data_from_file and closes it
	call read_file
	call close_file
	mov bl, WHITE ; I then write it on the screen with a short message before it (in WHITE color)
	xor dx,dx
	mov cx, 13
	lea bp, [record_message]
	call advanced_printing
	add dl, 13
	lea bp, [data_from_file]
	mov cx, 6
	call advanced_printing
	ret
endp display_record

;	At the end of the game this function is used to compare the final score to the current record
;	If it's higher than the record in the file it switches it with the brand new record (opens file, writes to him, closes it)
;	I didn't do the comparing with nums but with ascii values because it works basically the same
;	(I compared chars starting from the more important ones...)
;	Also if its a new record celbrate function comes in 
proc compare_run_times
	call open_file
	call read_file
	xor si,si
	mov cx, 5
	compare_digits:
	mov al, [data_from_file+si+1]
	cmp [run_time_text+si+1], al
	ja new_record
	jb no_new_record
	inc si
	loop compare_digits
	new_record:
	call close_file
	call open_file
	mov cx, 0
	call write_to_file ; clear file
	mov cx, 6
	call write_to_file
	call close_file
	call celebrate 
	no_new_record:
	ret 
endp compare_run_times

proc celebrate ; celebrate function prints a message to the screen to 'celbrate' the new record. yey
	mov dh, 12
	mov dl, 9
	mov bl,WHITE 
	lea bp, [congrats_mess]
	mov cx, 21
	call advanced_printing
	ret
endp celebrate





