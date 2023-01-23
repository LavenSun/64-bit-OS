org 10000h
jmp Lable_Start

%include "fat12.inc"
BaseOfKernelFile equ 0x00
OffsetOfKernelFile equ 0x100000

BaseTmpOfKernalAddr equ 0x00

OffsetTmpOfKernelFile equ 0x7E00

MemoryStructBufferAddr equ 0x7E00

[SECTION .s16]
[BITS 16]

Lable_Start:
    mov bp, StartLoaderMessage
    int 10h

; open address A20
push ax
in al, 92h
or al, 00000010b
out 92h, al
pop ax

cli

db 0x66
lgdt [GdtPtr]

mov eax, cr0
or eax, 1
mov cr0, eax
mov ax, SelectorData32
mov fs, ax
mov eax, cr0
and al, 11111110b
mov cr0, eax

sti

; search kernel.bin
mov word [SectorNo],
SectorNumOfRootDirStart

jmp Lable_Search_In_Root_Dir_Begin

Label_No_LoaderBin:
    mov bp, NoLoaderMessage
    int 10h
    jmp $

Label_FileName_Found:
    mov ax, RootDirSectors
    and di, 0FFE0h
    add di, 01Ah
    mov cx, word [ex:di]
    push cx
    add cx, ax
    add cx, SectorBalance
    mov eax, BaseTmpOfKernalAddr
    mov es, eax
    mov bx, OffsetTmpOfKernelFile
    mov ax, cx

Label_Go_On_Loading_File:
    mov cl, 1
    call Func_ReadOneSector
    pop ax
    push cx
    push eax
    push fs
    push edi
    push ds
    push esi

    mov cx, 200h
    mov ax, BaseOfKernelFile
    mov fs, ax
    mov edi, dword [OffsetOfKernelFile]
    mov ax, BaseTmpOfKernalAddr
    mov ds, ax
    mov esi, OffsetTmpOfKernelFile

Label_Mov_Kernel:
    mov al, byte [ds:esi]
    mov byte [fs:edi], al
    inc esi
    inc edi

    loop Label_Mov_Kernel

    mov eax, 0x1000
    mov ds, eax

    mov dword [OffsetOfKernelFileCount], edi

    pop esi
    pop ds
    pop edi
    pop fs
    pop eax
    pop cx

    call Func_GetFATEntry
    jmp Label_Go_On_Loading_File

Label_File_Loaded:
    mov ax, 0B800h
    mov gs, ax
    mov ah, 0Fh
    mov [gs:((80 * 0 + 39) * 2)], ax

KillMotor:
    push dx
    mov dx, 03F2h
    mov al, 0
    out dx, al
    pop dx