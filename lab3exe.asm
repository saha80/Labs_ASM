.MODEL small
.STACK 100h
.DATA      
    martix dw 5*6 dup(?)
    sums dw 6 dup(0)   
    min_sum dw 0
    max_input equ db 6
    input max_input
          db ?
          max_input dup(?)
    num_col_min_sum db "number of column with minimum sum:", 0Ah, 0Dh, '$'
.CODE
include mylib.inc

del_last_two_entered macro
	putc 08h ; backspace
	putc 08h ; backspace
	putc 20h ; space
	putc 20h ; space
	putc 08h ; backspace
	putc 08h ; backspace
endm

del_if_not_sign_or_digit macro
	local delete_from_screen, show_entered, is_sign
	; if( al >= '0' && al <= '9' || al == '-' || al == '+') { show entered }
	cmp al, '9'
	ja delete_from_screen
	cmp al, '0'
	jb is_sign
	jmp show_entered
	is_sign:
	cmp al, '-'
	jne delete_from_screen
	cmp al, '+'
	jne delete_from_screen
	delete_from_screen:
	putc 08h ; backspace
	putc 20h ; space
	putc 08h ; backspace
	show_entered:
endm

scan_num macro str
	local L1, skip_entering_space, skip_entering_newl, del_last_two_entered_jmp_L1, skip_label
	jmp skip_label
		del_last_two_entered_jmp_L1:
			int 21h
			del_last_two_entered
			jmp L1
	skip_label:
	lea di, str
	mov si, di ; [si] = str_size
	xor ch, ch
	mov cl, [di] ; cl = str_size
	add di, 2 ; skip str_len
	xor dl, dl; is_has_sign = false
	L1:
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
			je L1
			dec di
			inc cl
			jmp L1
		skip_entering_space:
		
		
		
		show_entered:
		cmp al, '-'
		je set_is_sign_to_true
		cmp al, '+'
		je set_is_sign_to_true
		jmp skip_setting_is_sign_to_true
		
		set_is_sign_to_true:
		mov dl, 1
		
		skip_setting_is_sign_to_true:
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

scan_matrix macro mtr, rows, cols, buf
    local L1, L2
    lea di, mtr
	mov cx, rows
    L1:
        push cx
        mov cx, cols
        L2:    
			push si
            lea si, buf
            call scan_string
            pop si
			lea si, buf
            call stoi
            mov [bx], dx           
        loop L2
        pop cx
    loop L1         
endm

print_matrix macro mtr, rows, cols, buf
    local L1, L2
	lea si, mtr
    mov cx, rows
    L1:    
        push cx
        mov cx, cols
        L2:    
            lea si, buf
            call scan_string
            lea si, buf
            call stoi
            mov [bx], dx           
        loop L2
        pop cx
    loop L1    
endm    

sums_in_columns macro sums, mtr, rows, cols; unchecked
    local L1, L2
	lea di, sums
	lea si, mtr
	mov cx, cols
    L1:    
		push si
		push cx
		
		mov cx, rows
		L2:
			add [di], [si]
			add si, rows
		loop L2
		
		pop cx
		pop si
		
		inc si
		inc di
    loop L1
endm

min macro min_sum, sums, sums_size ; done
    local L1, next, finish
    mov min_sum, sums[0]
	cmp sum_size, 1
	jna finish
    lea si, sums + 1
	mov cx, sums_size
    L1:                                     
        cmp min_sum, [si]
        jge next
        mov min_sum, [si]
        next:
        inc si                   
    loop L1
	finish:
endm

show_nums_of_cols_min_sum macro min_sum, sums, sums_size
    local L1, next
    print num_col_min_sum
    lea si, sums
	mov cx, sums_size
    L1:
        cmp min_sum, [si]
        jne next   
        ; println cx 
        next:
        inc si
        inc cx                    
    loop L1
endm

start:           
    mov ax, @data
    mov ds, ax
    
    scan_matrix matrix, 5, 6, buf
    print_matrix matrix, 5, 6, buf
    sums_in_columns sums, matrix
    min min_sum, sums, 6
    show_nums_of_cols_min_sum min_sum, sums, 6
    
    mov dx, 4C00h
    int 21h    
END start