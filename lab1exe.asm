.model small
.stack 100h
.data
   msg db "hello$"
   msg2 db "second msg", 0dh, 0ah,'$'
.code

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
    mov dx, @data;
    mov ds, dx;
    
    println msg 
    println msg2
    
    mov ax, 4c00h;
    int 21h;    
end start                