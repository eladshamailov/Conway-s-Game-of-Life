       	global scheduler
        extern resume, end_co, WorldLength, WorldWidth

section .data

    sum:DD 0,10
    resumeN: DD 0,10
    gen:DD 0,10
    kNum:DD 0,10
    tNum:DD 0,10
section .bss

section .text

%macro tAndkStart 4
	xor esi,esi
 	mov esi, [esp+8+%1]
    	mov %3, esi
	mov esi,0
    	mov esi, [esp+8+%2]
    	mov %4, esi
%endmacro

%macro lengthAndWidthStart 2
	xor esi,esi
        mov esi,%1
        imul esi, %2
	mov dword[sum],esi
	add dword[sum],1
%endmacro

%macro callResumeHelper 0
	xor eax,eax
	mov eax,dword[kNum]
	pushad
        call resume
        popad
%endmacro

%macro startargs 0
 	pushad
	tAndkStart 24,28,dword[tNum],dword[kNum]
	lengthAndWidthStart dword[WorldLength],dword[WorldWidth]
        mov ebx,2
%endmacro

%macro addToGeneration 0
	mov ebx, 2
	add dword dword[gen],1
%endmacro

%macro addToSumAndResume 2
        add dword[resumeN],%1
        add ebx,%2        
        cmp ebx, dword[sum]
        jle next
%endmacro


scheduler:
	startargs
next: 
	mov esi,dword[tNum]
	push eax
	mov eax,dword[gen]
	cmp esi,eax
	je con1Helper
	jne con1

con1Helper:
	pop eax
	push eax
	mov eax,dword[gen]
	call checkMaxGen
	pop eax
	cmp dword[gen],esi
	jne next
	add esi,dword[tNum]
	jmp con2	
con2:
	mov eax,0
	mov eax,dword[resumeN]
	cmp eax,dword[kNum]
	jne resumeAndDontPrint
	mov eax,0
	mov eax,dword[kNum]
	jmp con3
con3:
	push ebx
	xor ebx,ebx
	mov dword[resumeN],ebx
	cmp ebx,1
	jl con4
	jge con5

con4:
	mov ebx,1
	jmp resumeAndPrint
con5:
	addToSumAndResume 1,1
	addToGeneration
	jmp next

resumeAndDontPrint:
	callResumeHelper
	addToSumAndResume 1,1
	addToGeneration
	jmp next

resumeAndPrint:
	callResumeHelper
	pop ebx
        jmp next

con1:
	pop eax
	mov esi,dword[tNum]
	call conHelper
        call end_co
	addToSumAndResume 1,1
	addToGeneration
	jmp next
conHelper:
	add esi,dword[tNum]
	push eax
	mov eax,dword[gen]
	call checkMaxGen
	pop eax
	cmp dword[gen],esi
	jne con2
conResume:
	mov ebx, 1
	call resume
	ret
checkMaxGen:
	cmp dword[gen],9
	jg goToMaxGen1
	jle notMaxGen
goToMaxGen1:
	mov dword[gen],eax
notMaxGen:
	ret
