.MODEL small
.STACK 100h  
.DATA
    request_for_input db "enter your string:",0Ah,0Dh,'$'                         
    your_string db "your string:",0Ah,0Dh,'$'    
    after_deleting db "after deleting:",0Ah,0Dh,'$'    
    max_size equ db 200    
	input max_size        ; str_size
          db ?            ; str_len  
          max_size dup(?) ; data     
.CODE

include mylib.inc

num_len proc 
    push si
    push cx
	mov dl, bl ; dl = remaining size form original string
	xor ch, ch
	xor al, al ; is_meet_dot = 0
    L2:
		; if (str[i] >= '0' && str[i] <= '9')
		mov ah, [si]
		cmp ah, '0'
		jb is_meet_dot
        cmp ah, '9'        
        ja is_meet_dot
        jmp goto_next
		is_meet_dot:
		; if (is_meet_dot)
		cmp al, 0
		jne finish
		; if (str[i] == '.' && i + 1 < size &&
			; str[i + 1] && str[i + 1] >= '0' &&
			; str[i + 1] <= '9')
		cmp ah, '.'
		jne finish
		mov ah, si[1]
		cmp ah, '0'
		jb finish
		cmp ah, '9'
		jb finish
		mov al, 1;
        goto_next:
		inc si
    loop L2
	finish:
	sub dl, cl
    pop cx
    pop si
    ret    
num_len endp 

shift_one macro
local L1
	rep mov [si], [si+1]
endm

shift proc
	push si
	push cx
	
	mov di, si
	add si, bx
	mov cl, dl ; cl = num_len	
	
	;rep shift_one
	rep movsb ; while(cx){mov [di], [si]; inc si; inc di}
	
	pop cx
	pop si
	ret
shift endp

delete_nums_in_str proc
	;push si
	xor dh, dh
	xor ch, ch
	xor bh, bh
	mov cl, si[1] ; cx = str_len
	mov bl, cl ; bx = str_len
	add si, 2 ; go to string data
    L1: 
		mov al, [si]
        cmp al, '9'
        ja next_char  
        cmp al, '0'
        jae calc_num_len_and_shift
		cmp al, '.'
        jne next_char
        calc_num_len_and_shift:  
			call num_len 
            cmp dl, 0
            je next_char
			call shift
			sub bl, dl ; bl -= dl
        next_char:
            inc si
		putc bl
		cmp bl, 0
    loopne L1  
	;pop si
	;mov si[1], bl
	ret
delete_nums_in_str endp

start:
    mov ax, @data
    mov ds, ax
    mov es, ax
	
    print request_for_input        
    scan_str_ input
    print your_string
    println_s input[2], input[1]        
    lea si, input
    call delete_nums_in_str
    print after_deleting         
    println_s input[2], input[1]     
    
    mov ax, 4c00h
    int 21h;
END start
