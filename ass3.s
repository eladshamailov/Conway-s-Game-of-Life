        global main
	global WorldLength 
	global WorldWidth
	global k
	global t 
	global state ,decLengthWidth,incY
        extern init_co, start_co, resume,atoi,cellAssemblyHelper
        extern scheduler,printer,cell

sys_exit:       equ   1

section .data

    WorldWidth:DD 10
    WorldLength:DD 10
    fileName:DD 10
    t:DD 10
    k:DD 10
    newL:DD 10
    fileDescriptor:DD 10
    debug:DD 10
    xnum:DD 0,10
    ynum:DD 0,10

section .bss

    state:
        resb 100000

section .text

%macro fileOpen 0
        mov eax, 5			;system call number (sys_open)
        mov ebx,[fileName]
        mov ecx, 0x002			;set file access bits
        mov edx, 00700q			;set file permissions
        int 0x80
        mov [fileDescriptor], eax			;move file handle to memory
%endmacro

%macro atoiFuncWorldLength 2
	push %1
	push %2
	call atoi
    	mov dword[WorldLength], %1
	call atoi
    	pop %2
    	pop %1
%endmacro

%macro atoiFuncWorldWidth 2
	push %1
	push %2
	call atoi
    	mov dword[WorldWidth], %1
	call atoi
    	pop %2
    	pop %1
%endmacro

%macro atoiFuncK 2
	push %1
	push %2
	call atoi
    	mov dword[k], %1
	call atoi
    	pop %2
    	pop %1
%endmacro

%macro atoiFuncT 2
	push %1
	push %2
	call atoi
    	mov dword[t], %1
	call atoi
    	pop %2
    	pop %1
%endmacro

%macro noDebugFunc 3
        add %1,1
	mov %3,0
	add %1,%3
        mov %3, cellAssembly
        call init_co
	times 4 inc %2
        sub %2,5
%endmacro

%macro cellFunc 2
	push ecx
	push %1
        push %2
        call cell
	pop ecx
%endmacro

%macro fileRead 0
        mov eax, 3			;system call number (sys_read)
        mov ebx, [fileDescriptor]			;file descriptor
        mov ecx, state			;buffer to keep the read data
        mov edx, 100000			;bytes to read
        int 0x80
%endmacro

%macro noDebugFunc 0
        mov ecx,dword[WorldWidth]
	push eax
	xor eax,eax
	mov eax,dword[WorldLength]
noDebugFuncLoop:
	cmp eax,0
	je endDebugFuncLoop
	add ecx,dword[WorldWidth]
	sub eax,1
	jmp noDebugFuncLoop
endDebugFuncLoop:
	pop eax
	sub ebx,1
%endmacro

%macro conIncMacro 3
    mov %3,%2
    cmp %3,%1 
    je incJustX
    inc %3
    mov %2,%3
%endmacro


%macro getargs 0
    mov ebx, dword[eax+20]
    atoiFuncK eax,ebx
    mov ebx, dword[eax+16]
    atoiFuncT eax,ebx
    mov ebx, dword[eax+12]
    atoiFuncWorldWidth eax,ebx
    mov ebx, dword[eax+8]
    atoiFuncWorldLength eax,ebx
%endmacro

%macro cellLoopHelper 2
        push %2
        mov byte[%1+state], al
	call decLengthWidth
        call incY
	pop %2
        mov %1,0
	cmp %1,0
	jne cellAssembly
	jmp continueCellLoop
continueCellLoop:
        call resume
	cellFunc dword[ynum],dword[xnum]
        jmp cellAssembly
%endmacro

%macro removeSpacesFunc 0
checkEnd1:
 	mov eax,[WorldLength]
        cmp [newL],eax
	je checkEnd2
	jne checkEnd3
checkEnd2:
	mov dword[newL],0
        mov byte[state+ecx],0
	jmp checkEnd4
checkEnd3:
	inc dword[newL]
checkEnd4:
        inc ecx
        cmp ecx, ebx
	je lookForDebug
        jmp removeSpaces
%endmacro

main:
        enter 0, 0
        mov ecx,[ebp+8]			;argc
        mov eax, dword[ebp+12]		;pointer to argv
        mov ebx, dword[eax+4]
        cmp ecx,6			;if no debug
	jg debugMode			;if more than 6 so -d is on
        mov dword[debug],0		;if there is no -d	
        je afterDebug1

debugMode:				;if debugMode on
        mov dword[debug], 0
        mov dword[debug], 1
        times 4 inc eax
        mov ebx, dword[eax+4]
        times 4 inc eax
        mov dword[fileName],eax
	sub eax,4

afterDebug1:
        mov [fileName], ebx
	getargs
	mov dword[ynum],0
	mov dword[xnum],0
	fileOpen
	fileRead
	add ecx,dword[xnum]
	add edx,dword[ynum]
	jmp afterDebug2
    
afterDebug2:

        mov ebx, eax
	xor ecx,ecx
	mov dword[newL],0
removeSpaces:
        cmp byte[state+ecx],10		;if its new line
        je checkEnd1
        cmp byte[state+ecx],'1'		;cell is alive
        je checkEnd
        mov byte[state+ecx], '0'	;cell is ' '

checkEnd:
        inc ecx
        cmp ecx, ebx
	je lookForDebug
        jmp removeSpaces
removeSpacesLoop:
	removeSpacesFunc
lookForDebug:
        cmp dword[debug], 1
        jne noDebugOrigin

noDebugOrigin:
        xor ebx, ebx            ; scheduler is co-routine 0
        mov edx, scheduler
        mov ecx, [ebp + 4]      ; ecx = argc
        call init_co            ; initialize scheduler state

        inc ebx                 ; printer i co-routine 1
        mov edx, printer
        call init_co            ; initialize printer state
	push ebx
	push edx
        push ecx
	mov ecx,0
	add ebx,1
	noDebugFunc


noDebugLoop:
	noDebugFunc ebx,ecx,edx
        cmp ecx,1
        jge noDebugLoop
        pop ecx
	pop edx
	pop ebx

continueNoDebugLoop:
        xor ebx, ebx            ; starting co-routine = scheduler
        call start_co           ; start co-routines
 	xor ebx, ebx            ; starting co-routine = scheduler
        call start_co           ; start co-routines
        ;; exit
        mov eax, sys_exit
        xor ebx, ebx
        int 80h

cellAssembly:
	cellFunc dword[ynum],dword[xnum]
	call cellAssemblyHelper
	mov ebx,0
        mov ebx, dword[xnum]
	push ecx
AddCellLoop:
	cmp ecx,1
	jl endAddCellLoop
	add ebx,dword[xnum]
	sub ecx,1
	jmp  AddCellLoop
endAddCellLoop:
	xor ebx,ebx
        mov ebx, dword[xnum]
	pop ecx
        imul ebx, ecx
        add ebx, dword[ynum]
        mov byte[ebx+state], al
	cmp al,1
	jl cellLoopHelper ebx,edx

incY:
    push eax
    mov eax,dword[WorldWidth]
    cmp eax,edx
    pop eax
    je endXY
    jne continueInc
continueInc:
    push ecx
    conIncMacro edx, dword[ynum] , ecx
    pop ecx
    jmp endXY
endXY:
	ret

decLengthWidth:
	mov edx,[WorldLength]
        dec edx
        mov edx,[WorldWidth]
        dec edx
	ret

incJustX:
    mov dword[ynum],0
    mov eax,[WorldLength]
    mov ecx,eax
    sub eax,1
    pop ecx
    push ecx
    mov ecx,dword[xnum]
    cmp ecx,eax
    pop ecx
    jne inX
    cmp dword[xnum],0
    je endXY
    mov dword[xnum],0 
    jmp endXY

inX:
    dec ecx
    inc dword[xnum]
    ret
