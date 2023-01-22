dir="../../bochs.2.6.8/"

nasm boot.asm -o boot.bin
cp boot.bin ${dir}
cd ../../bochs-2.6.8
bximage 1 fd 1.44M boot.img
dd if=boot.bin of=boot.img bs=512 count=1 conv=notrunc
rm -rf boot.bin

bochs -f .bochsrc