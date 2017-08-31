        global printer,atoi
        extern resume, state, WorldWidth, WorldLength,t,k

        ;; /usr/include/asm/unistd_32.h
sys_write:      equ   4
stdout:         equ   1
iterfun:        equ  100000


section .data
    ten: DD 10
    test: DB 0,10,0


section .text

%macro printi 4
mov eax, %4
mov ebx, %3
mov ecx, %1
mov edx, %2
int 80h

%endmacro

printer:
        printi state, iterfun, stdout, sys_write

        xor ebx, ebx
        call resume             ; resume scheduler

        jmp printer

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;atoi from bgu site
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
atoi:
        push ebp
        mov ebp, esp
        mov ecx, dword [ebp+8]
        xor eax,eax
        xor ebx,ebx
.loop:
        xor edx,edx
        cmp byte[ecx],0
        jz  .end
        imul dword[ten]
        mov bl,byte[ecx]
        sub bl,'0'
        add eax,ebx
        inc ecx
        jmp .loop
.end:
        mov esp, ebp
        pop ebp
        ret
