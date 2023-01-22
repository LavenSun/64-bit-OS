mov ax, 0600h
mov bx, 0700h
mov cx, 0
mov dx, 0184fh
int 10h

mov ax, 0200h
mov bx, 0000h
mov dx, 0000h
int 10h

mov ax, 1301h
mov bx, 000fh
mov dx, 0000h
mov cx, 10
push ax
mov ax, ds
mov es, ax
pop ax
mov bp, StartBootMessage
int 10h

xor ah, ah
xor dl, dl
int 13h
jmp $

StartBootMessage: db "Start LavenOS Boot"
times 510- ($ - $$) db 0
dw 0xaa55