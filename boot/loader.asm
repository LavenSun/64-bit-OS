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

jmp
Lable_Search_In_Root_Dir_Begin