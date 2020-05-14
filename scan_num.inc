del_last_two_entered_jmp_L1 macro
	int 21h
	putc 08h ; backspace
	putc 08h ; backspace
	putc 20h ; space
	putc 20h ; space
	putc 08h ; backspace
	putc 08h ; backspace
	jmp L1_scan_num
endm

del_if_not_sign_or_digit macro ; jumps to L1 in scan_num
	local delete_from_screen, show_entered, is_sign, set_sign_has_seen
	; if( al >= '0' && al <= '9' ) { show entered } 
	cmp al, '9'
	ja delete_from_screen
	cmp al, '0'
	jb is_sign
	jmp show_entered
	is_sign:	
	; if (al != '-') { delete_from_screen; } else { if(!is_has_sign) { dl = 1; show_entered; } } 
	cmp al, '-'
	jne delete_from_screen
	cmp dl, 0
	je set_sign_has_seen
	delete_from_screen:
	putc 08h ; backspace
	putc 20h ; space
	putc 08h ; backspace
	cmp cl, [si] ; cl == str_size
	je L1_scan_num ; jumps to L1 in scan_num
	dec di
	inc cl
	jmp L1_scan_num ; jumps to L1 in scan_num
	set_sign_has_seen:
	mov dl, 1 ; is_has_sign = true
	show_entered:
endm

scan_num macro str ; to test
	local skip_entering_space, skip_entering_newl
	mov si, di ; [si] = str_size
	xor ch, ch
	mov cl, [di] ; cl = str_size
	add di, 2 ; skip str_len
	xor dl, dl; is_has_sign = false
	L1_scan_num:
		mov ah, 01h ; read char with echo
		int 21h ; al = entered char
		; if pressed some functional buttons
		cmp al, 0h
		je del_last_two_entered_jmp_L1
		; if backspace was pressed
		cmp al, 08h 
		jne skip_entering_space
			putc 20h ; space
			putc 08h ; backspace
			cmp cl, [si] ; cl == str_size
			je L1_scan_num
			dec di
			inc cl
			jmp L1_scan_num
		skip_entering_space:
		del_if_not_sign_or_digit
		stosb
		cmp al, 0Dh ; if enter was pressed
	loopne L1_scan_num
	cmp cl, 0
	jne skip_entering_newl
	putc 0Ah
	skip_entering_newl:
	mov [di], '$'
	lodsb ; al = str_size; inc si
	dec al
	sub al, cl ; str_size -= 
	mov [si], al ; [si] = str_len	
endm