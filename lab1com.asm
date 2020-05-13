.model tiny
.code 
org 100h

print macro msg 
    mov ah, 9;
    mov dx, offset msg;
    int 21h;        
endm

println macro msg
    print msg
    mov dl, 0dh; cret  
    mov ah, 06h
    int 21h
    mov dl, 0ah; newln
    mov ah, 06h
    int 21h  
endm
    
start:
    println msg;   
    println msg2;   
    ret
msg db "hello, world$"
msg2 db "second messege$"
end start