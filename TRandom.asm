;Generates the next_block identifier
proc gen_random
	push es
	generate_another:
	mov ax, 40h 
	mov es, ax
	mov ax, [CLOCK] ; Clock represents time memory
	mov cx, 3
	randomize:
	mov ah, [byte cs:bx] ; a byte from memory
	xor al, ah ; xor memory and al - clock
	add bx, ax ; So in the next round bx will be even more randomized 
	loop randomize
	
	mov ah, [byte cs:bx]
	xor al,ah
	and al, 00000111b ; leave 7 options:
	xor ah,ah
	
	mov bl, 7
	div bl 
	mov al,ah 
	
	xor ah,ah
	mov si, ax			; Takes the chosen piece if it can:
	mov al, [bag_took+si] ; In tetris we use a bag --> every piece is in the bag 
	cmp al, 0			  ; Every time we take random piece from out of it. 
						  ; If the bag is empty we recreate it.
	jne generate_another
	
	mov ah, [bag+si]
	mov [bag_took+si],1 
	inc [taken] 
	
	cmp [taken], 7 ; If bag is empty --> refill it:
	jne no_need_to_fill_bag
	xor di,di
	mov cx, 7 
	refill_bag:
	mov [bag_took+di], 0 ; Change ones to zeros 
	inc di
	loop refill_bag
	mov [taken], 0		; reset [taken]
	no_need_to_fill_bag:	
	mov [next_block], ah
	pop es
	ret
endp gen_random

