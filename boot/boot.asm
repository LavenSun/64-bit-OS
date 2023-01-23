org 0x7c00

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

BaseOfStack equ 0x7c00
BaseOfLoader equ 0x1000
OffsetOfLoader equ 0x00

RootDirSectors equ 14
SectorNumOfRootDirStart equ 19
SectorNumOfFAT1Start equ 1
SectorBalance equ 17

jmp short Lable_Start
nop
BS_OEMName db 'MINEboot'
BPB_BytesPerSec dw 512
BPB_SecPerClus db 1
BPB_RsvdSecCnt dw 1
BPB_NumFATs db 2
BPB_RootEntCnt dw 224
BPB_TotSec16 dw 2880

BPB_Media db 0xf0

BPB_FATSz16 dw 9
BPB_SecPerTrk dw 18
BPB_NumHeads dw 2
BPB_hiddSec dd 0
BPB_TotSec32 dd 0
BS_DrvNum db 0
BS_Reserved1 db 0
BS_BootSig db 29h
BS_VolID dd 0
BS_VolLab db 'boot loader'
BS_FileSysType db 'FAT12    '

; read one sector from floppy
Func_ReadOneSector:
    push bp
    mov bp, sp
    sub esp, 2
    mov byte [bp - 2], cl

    push bx
    mov bl, [BPB_SecPerTrk]

    div bl
    inc ah
    mov cl, ah
    mov dh, al
    shr al, 1
    mov ch, al
    and dh, 1
    pop bx
    mov dl, [BS_DrvNum]

Label_Go_On_Reading:
    mov ah, 2
    mov al, byte [bp - 2]
    int 13h
    jc Label_Go_On_Reading
    add esp, 2
    pop bp
    ret

; search loader.bin
mov word [SectorNo], SectorNumOfRootDirStart

Lable_Search_In_Root_Dir_Begin:
    cmp word [RootDirSizeForLoop], 0
    jz Label_No_LoaderBin
    dec word [RootDirSizeForLoop]
    mov ax, 00h
    mov es, ax
    mov bx, 8000h
    mov ax, [SectorNo]
    mov cl, 1
    call Func_ReadOneSector
    mov si, LoaderFileName
    mov di, 8000h
    cld
    mov dx, 10h

Label_Search_For_LoaderBin:
    cmp dx, 0
    jz Label_Goto_Next_Sector_In_Root_Dir
    dec dx
    mov cx, 11

Label_Cmp_FileName:
    cmp cx, 0
    jz Label_FileName_Found
    dec cx
    lodsb
    cmp al, byte [es:di]
    jz Label_Go_On
    jmp Label_Different

Label_Go_On:
    inc di
    jmp Label_Cmp_FileName

Label_Different:
    and di, 0FFE0h
    add di, 20h
    mov si, LoaderFileName
    jmp Label_Search_For_LoaderBin

Label_Goto_Next_Sector_In_Root_Dir:
    add word [SectorNo], 1
    jmp Lable_Search_In_Root_Dir_Begin

Label_No_LoaderBin:
    mov ax, 1301h
    mov bx, 008ch
    mov dx, 0100h
    mov cx, 21
    push ax
    mov ax, ds
    mov es, ax
    pop ax
    mov bp, NoLoaderMessage
    int 10h
    jmp $

Func_GetFATEntry:
    push es
    push bx
    push ax
    mov ax, 00
    mov es, ax
    pop ax
    mov byte [0dd], 0
    mov bx, 3
    mul bx
    mov bx, 2
    div bx
    cmp dx, 0
    jz Label_Even
    mov byte [0dd], 1

Label_Even:
    xor dx, dx
    mov bx, [BPB_BytesPerSec]
    div bx
    push dx
    mov bx, 8000h
    add ax, SectorNumOfFAT1Start
    mov cl, 2
    call Func_ReadOneSector

    pop dx
    add bx, dx
    mov ax, [es:bx]
    cmp byte [0dd], 1
    jnz Label_Even_2
    shr ax, 4

Label_Even_2:
    and ax, 0fffh
    pop bx
    pop es
    ret

Label_FileName_Found:
    mov ax, RootDirSectors
    and di, 0FFE0h
    add di, 01Ah
    mov cx, word [es:di]
    push cx
    add cx, ax
    add cx, SectorBalance
    mov ax, BaseOfLoader