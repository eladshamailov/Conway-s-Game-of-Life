all: ass3

ass3:  ass3.o cell.o scheduler.o coroutines.o printer.o
	gcc -g -m32 -Wall cell.o ass3.o scheduler.o coroutines.o printer.o -o ass3

ass3.o: ass3.s
	nasm -f elf ass3.s -o ass3.o

cell.o: cell.c
	gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector cell.c -o cell.o

scheduler.o: scheduler.s
	nasm -f elf scheduler.s -o scheduler.o
	
coroutines.o: coroutines.s
	nasm -f elf coroutines.s -o coroutines.o

printer.o: printer.s
	nasm -f elf printer.s -o printer.o
	

.PHONY: clean

clean: 
	rm -f *.o ass3
