putc macro char
    local if_not_equ_newl 
    mov ah, 06h
    mov dl, char
    int 21h
    cmp dl, 0Ah; newl
    jne if_not_equ_newl
    mov dl, 0Dh; cret
    int 21h
if_not_equ_newl: 
; do nothing
endm

print macro str
    lea dx, str
    mov ah, 09h
    int 21h    
endm

println macro str
    print str
    putc 0Ah     
endm    

print_s macro str, len
    local L1, finish
    lea si, str
    xor ch, ch
    mov cl, len
	cmp len, 0
	je finish
    mov ah, 06h
    L1: 
        mov dl, [si]                        
        inc si
        int 21h
    loop L1
	finish:
endm    

println_s macro str, len
    print_s str, len
    putc 0Ah
endm

scan_str macro str
    mov ah, 0Ah
    lea dx, str
    int 21h    
    ; insert '$' to end of string       
    mov di, dx; si[0] = str_size                
    mov dx, di[1]; si[1] = str_len   
    add di, dx 
    mov [di+2], '$'
    putc 0Ah     
endm 

scan_str_ macro str
	local L1, skip_entering_space, skip_entering_newl, del_last_two_entered_jmp_L1, skip_label
	jmp skip_label
		del_last_two_entered_jmp_L1:
		int 21h
		putc 08h ; backspace
		putc 08h ; backspace
		putc 20h ; space
		putc 20h ; space
		putc 08h ; backspace
		putc 08h ; backspace
		jmp L1
	skip_label:
	lea di, str
	mov si, di ; [si] = str_size
	xor ch, ch
	mov cl, [di] ; cl = str_size
	add di, 2 ; skip str_len
	L1:
		mov ah, 01h ; read char with echo
		int 21h ; al = entered char
		cmp al, 0h
		je del_last_two_entered_jmp_L1
		cmp al, 08h ; if backspace was pressed
		jne skip_entering_space
			putc 20h ; space
			putc 08h ; backspace
			cmp cl, [si] ; cl == str_size
			je L1
			dec di
			inc cl
			jmp L1
		skip_entering_space:
		stosb
		cmp al, 0Dh ; if enter was pressed
	loopne L1
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

; string to integer
stoi proc
    ; cx, str_len 
    ;maxnum = 32767
    ;minnum = -32767
    stoi_L1:
        cmp [si], ' '
        je stoi_goto_next_char
        cmp [si], '0'
        jl stoi_invalid_char
        cmp [si], '9'
        ja stoi_invalid_char
         
        stoi_goto_next_char:
        inc si
    loop stoi_L1              
    
    stoi_L2:
        
    loop stoi_L2
    
    push 1
    ret
    stoi_invalid_char:
    push 0
    ret        
stoi endp  

itos proc
    ; dx = num
    ; di = string
    push dx
    cmp dx, -1
    jns not_signed
    mov [di], '-'
    not_signed:
    
    pop dx
itos endp	

