;generate a 'random' number using CLOCK, and random memory byte
;random number is stored in cactus_object_type to the use of generating cactuses
proc random
	push es
	mov ax, 40h 
	mov es, ax
	mov ax, [CLOCK] ; CLOCK represents time memory
	mov ah, [byte cs:bx] ; a byte from memory
	xor al, ah ; xor memory and ah
	add bx, ax
	mov ah, [byte cs:bx]
	xor al,ah
	and al, 00000111b ; leave 8 options 
	mov [cactus_object_type], al
	pop es
	ret
endp random