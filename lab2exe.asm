.MODEL small
.STACK 100h  
.DATA
    request_for_input db "enter your string:",0Ah,0Dh,'$'                         
    your_string db "your string:",0Ah,0Dh,'$'    
    after_deleting db "after deleting:",0Ah,0Dh,'$'    
    err_msg db "error",0Ah,0Dh,'$'    
    max_size equ db 200    
	input max_size        ; str_size
          db ?            ; str_len  
          max_size dup(?) ; data     
.CODE
include mylib.inc

num_len proc 
    push si
    push cx
	; dl = remaining size form original string
	xor ch, ch
	mov cl, dl ; cl = remaining size form original string
	;dec cl
    xor bl, bl ; num_len = 0
	xor al, al ; is_meet_dot = 0
    L2:
		; if (str[i] >= '0' && str[i] <= '9')
		cmp [si], '0'
		jb is_meet_dot
        cmp [si], '9'        
        ja is_meet_dot
        jmp goto_next
		is_meet_dot:
		; if (is_meet_dot)
		cmp al, 0
		jne finish
		; if (str[i] == '.' && i + 1 < size &&
			; str[i + 1] && str[i + 1] >= '0' &&
			; str[i + 1] <= '9')
		cmp [si], '.'
		jne finish
		cmp [si+1], '0'
		jb finish
		cmp [si+1], '9'
		jb finish
		mov al, 1;
        goto_next:
		inc bl
		inc si
    loop L2
	finish:
    pop cx
    pop si
    ret    
num_len endp 

shift proc
	push di
	push si
	push cx
	
	mov di, si
	add si, bx 
	mov cl, bl ; cl = num_len	
	rep movsb;while(cx){mov [di], [si]; inc si; inc di}
    
	pop cx
	pop si
	pop di
	ret
shift endp

delete_nums_in_str proc
	push si
	xor dh, dh
	xor ch, ch
	mov cl, si[1]; cx = str_len
	add si, 2
    L1: 
        cmp [si], '9'
        ja next_char  
        cmp [si], '0'
        jae calc_num_len_and_shift
        cmp [si], '.'
        jne next_char
        calc_num_len_and_shift:    
			;todo: check str_len 
            call num_len 
            cmp bl, 0
            je next_char
            call shift
        next_char:
            inc si
		cmp dl, 0
    loopne L1  
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