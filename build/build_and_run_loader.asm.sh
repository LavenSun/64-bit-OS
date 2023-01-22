dir="../../bochs.2.6.8/"

nasm loader.asm -o .bin
cp loader.bin ${dir}
cd ../../bochs-2.6.8
bximage 1 fd 1.44M loader.img
dd if=loader.bin of=loader.img bs=512 count=1 conv=notrunc
rm -rf loader.bin

bochs -f .bochsrc