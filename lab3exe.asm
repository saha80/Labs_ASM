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

scan_matrix macro mtr, rows, cols, buf
    local L1, L2, correct_input
    lea di, mtr
	mov cx, rows
    L1:
        push cx
        mov cx, cols
        L2:    
			push si
			
			lea di, buf
            call scan_string
			
			lea si, buf
            call stoi
            cmp dx, 0
			jne correct_input
			pop dx 
			cmp dx, 0
			je reenter_num
			correct_input:
			mov [bx], dx  
			pop dx
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