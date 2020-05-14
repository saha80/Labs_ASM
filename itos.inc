; integer to string
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
