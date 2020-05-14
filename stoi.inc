 ; string to integer
stoi proc
    ;maxnum = 32767
    ;minnum = -32767
	xor dx, dx
    L1_stoi:
		
        stoi_goto_next_char:
        inc si
    loop L1_stoi              
    
    push 1
    ret
    stoi_invalid_string:
    push 0
    ret        
stoi endp 