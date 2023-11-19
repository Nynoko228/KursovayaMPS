.386
;≥ó≥-≥+≥-≥≥TÇ≥≥ ≥-≥-TäTë≥- ≥ü≥ó≥£ ≥- ≥-≥-≥≥TÇ≥-TÖ
RomSize    EQU   4096

SumPort = 0FDh ; 2
SumPowerPort = 0FEh ; 1
CntPort = 0FDh ; 2
CntPowerPort = 0FCh ; 3
KbdPort = 0F7h ; 0
IndPort = 0FBh ; 4
ControlPort = 0FEh ; 1

NMax = 120

IntTable   SEGMENT use16 AT 0
;≥ó≥+≥≥TÅTå TÄ≥-≥ø≥-≥≥Tâ≥-TéTÇTÅTè ≥-≥+TÄ≥≥TÅ≥- ≥-≥-TÄ≥-≥-≥-TÇTá≥ø≥≥≥-≥- ≥øTÄ≥≥TÄTã≥-≥-≥-≥ø≥≥
IntTable   ENDS

Data       SEGMENT use16 AT 40h
;≥ó≥+≥≥TÅTå TÄ≥-≥ø≥-≥≥Tâ≥-TéTÇTÅTè ≥-≥ø≥øTÅ≥-≥-≥øTè ≥ø≥≥TÄ≥≥≥-≥≥≥-≥-TãTÖ
	DataHexArr db 10 dup(?) 
	DataHexTabl db 10 dup(?)
	DataTable dd 7 dup(?)
	ErrTable db 5 dup (?)
	Res db 6 dup (?)
	SelectedNumber DD ?
	OldButton db    ?
	OldCntrl db    ?
	StopFlag db ?
	BrakFlag db ?
	OneHundredFlag db ?
	SumFlag db ?
	SbrosFlag db ?
	Buffer dw ?
	Cnt DD ?
	CntBrak DD ?
	Time DD ?
	TimeEndFlag DB ?
Data       ENDS


;≥ó≥-≥+≥-≥≥TÇ≥≥ ≥-≥≥≥-≥-TÖ≥-≥+≥ø≥-Tã≥≥ ≥-≥+TÄ≥≥TÅ TÅTÇ≥≥≥≥≥-
Stk        SEGMENT use16 AT 2000h
;≥ó≥-≥+≥-≥≥TÇ≥≥ ≥-≥≥≥-≥-TÖ≥-≥+≥ø≥-Tã≥≥ TÄ≥-≥ø≥-≥≥TÄ TÅTÇ≥≥≥≥≥-
           DW    16 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
InitDataStart:
;≥ó≥+≥≥TÅTå TÄ≥-≥ø≥-≥≥Tâ≥-TéTÇTÅTè ≥-≥ø≥øTÅ≥-≥-≥øTè ≥≥≥-≥-TÅTÇ≥-≥-TÇ



InitDataEnd:
InitData   ENDS

Code       SEGMENT use16
;≥ó≥+≥≥TÅTå TÄ≥-≥ø≥-≥≥Tâ≥-TéTÇTÅTè ≥-≥ø≥øTÅ≥-≥-≥øTè ≥≥≥-≥-TÅTÇ≥-≥-TÇ

           ASSUME cs:Code,ds:Data,es:Data
		   
	HexArr DB 00h,01h,02h,03h,04h,05h,06h,07h,08h,09h
	;HexTabl DB 3Fh,0Ch,76h,5Eh,4Dh,5Bh,7Bh,0Eh,7Fh,5Fh 
	HexTabl DB 0C0H, 0F3h, 89h, 0A1h, 0B2h, 0A4h, 84h, 0F1h, 80h, 0A0h 
	Table DD 0500h, 010000h, 020000h, 050000h, 01000000h, 02000000h, 05000000h 
	Err DB 27h, 3fh, 27h, 27h, 73h
	
Initialization PROC NEAR
			xor ax, ax
			mov StopFlag, 0FFh
			mov BrakFlag, 00h
			mov OneHundredFlag, 00h
			mov SumFlag, 00h
			mov SbrosFlag, 00h
			mov word ptr Cnt, ax
			mov word ptr Cnt+2, ax
			mov word ptr CntBrak, ax
			mov word ptr CntBrak+2, ax
			mov OldButton, al
			mov OldCntrl, al
	        mov word ptr Res, ax
			mov word ptr Res+2, ax
			mov word ptr Res+4, ax
			mov word ptr SelectedNumber, ax
			mov word ptr SelectedNumber+2, ax
			mov TimeEndFlag, 01h
			mov Buffer, 0100h
			mov ax, Buffer
			mov al, ah
			out IndPort, al
			xor ax, ax
			RET
Initialization ENDP

Simul PROC NEAR
			MOV CX, AX
			MOV AX, Buffer
			
			cmp StopFlag, 0FFh
			je Timer1
			cmp OneHundredFlag, 0FFh
			je Timer1
			jmp Timer2
		
Timer0:	; ≥¢≥-≥≥≥-≥≥TÄ
			SUB word ptr Time, 1
			SBB word ptr Time+2, 0
			MOV SI, word ptr Time
			OR SI, word ptr Time+2
			MOV TimeEndFlag, 0
			JNZ Timer1
			MOV TimeEndFlag, 01h
		
Timer2:		MOV AL,AH
			CMP TimeEndFlag, 01h
			JNZ Timer0
		
			Out IndPort, AL
			cmp AL, 80h
			jne Timer3
			mov SumFlag, 0FFh
Timer3:		ROL AH, 1
			
			MOV word ptr Time, 0007h
			MOV word ptr Time+2, 0000h
			JMP Timer0	
Timer1: 	MOV Buffer, AX
			MOV AX, CX
			ret
Simul ENDP 

ReadInput  	PROC  Near 
			xor ah, ah
			mov dx, ControlPort
			in al, dx		
			call VibrDestr
			xor ah, ah
			cmp al, OldCntrl
			jne m3 
			
m6:		   	cmp SbrosFlag, 0FFh
			je m1
			cmp OneHundredFlag, 0FFh
			je m1
			
			jmp m4

		   
m3:        	mov OldCntrl, al
			cmp al, 0ffh
			je m6
			
m5:		   	inc   ah
			shr   al, 1
			jc m5
			dec ah
			
			cmp ah, 03h
			jne NoSbros
			mov SbrosFlag, 0FFh
NoSbros:	cmp ah, 02h
			jb m11
			mov BrakFlag, 0FFh
			xor ah, ah
			jmp m6
		   
m11:	   	mov StopFlag, ah
			xor ah, ah
			jmp m6
		   
m4:		   	mov dx, KbdPort
			in al, dx		
			call VibrDestr
			xor ah, ah
			cmp al, OldButton
			je m1
			mov OldButton, al
			cmp   al, 0ffh
			je    m1   ;≥ïTÅ≥ø≥ø ≥-≥≥TÇ TÅ≥ø≥-≥-≥-≥ø≥-≥- ≥+≥øTè ≥+≥-≥-≥-≥-≥ø≥≥≥-≥øTè (≥-≥≥ ≥-≥-≥≥≥-TÇ≥- ≥-≥ø ≥-≥+≥-≥- ≥ø≥ø ≥≥≥-≥-≥ø≥-≥≥)
m2:       
			inc   ah
			shr   al, 1
			jc m2
			dec ah
           
			xor al, al
			lea BX, Table
			lea DI, SelectedNumber
			shl ah, 2
			MOV CX, 04h
ReadInput1:	add al, ah
			xlat
			mov byte ptr [DI], al 
			inc BX
			inc DI
			loop ReadInput1
 		   
m1:		   	RET           
ReadInput  	ENDP

AccumulationSumm PROC Near
			cmp SbrosFlag, 0FFh
			jne M12
			call Sbros
M12:		cmp OneHundredFlag, 0FFh
			je M7
		    cmp StopFlag, 0FFh
			je M7
			cmp SumFlag, 00h
			je M7
			
			xor ax,ax
			cmp BrakFlag, 0FFh
			je M10
			cmp word ptr SelectedNumber+2, 0
			JNZ M8
			cmp word ptr SelectedNumber, 0
			JZ M7

		
M8:			mov ax, word ptr Cnt
			inc ax
			AAA
			mov word ptr Cnt, ax
			
			 
M9:			mov SumFlag, 00h
			mov CX, 04h
			lea SI, Res
			lea BX, SelectedNumber
AccSum1:	mov ax, word ptr [SI]
			ADD al, byte ptr [BX]
			AAA
			mov word ptr [SI], ax
			inc SI
			inc BX
			loop AccSum1
			CMP Res+4, 09h
			JBE M7
			mov Res+4, 0h
			INC [Res+5]
			JMP M7
			
M10:		mov BrakFlag, 00h
			mov SumFlag, 00h
			mov ax, word ptr CntBrak
			inc ax
			AAA
			mov word ptr CntBrak, ax
M7:			
			mov bp, word ptr SelectedNumber
			and bp, 00FFh
			ret
AccumulationSumm ENDP

OneHundredProverka PROC NEAR
			CMP byte ptr Cnt+1, 09h
			JBE HundredRet 
			mov StopFlag, 0FFh
			mov OneHundredFlag, 0FFh
			mov byte ptr Cnt+1, 00h
			mov byte ptr Cnt+2, 01h
HundredRet:	ret
OneHundredProverka ENDP

OneHundredProverkaBrak PROC NEAR
			CMP byte ptr CntBrak+1, 09h
			JBE HundredBrakRet 
			mov StopFlag, 0FFh
			mov OneHundredFlag, 0FFh
			mov byte ptr CntBrak+1, 00h
			mov byte ptr CntBrak+2, 01h
HundredBrakRet:	ret
OneHundredProverkaBrak ENDP 

OverflowCheck PROC NEAR
			call OneHundredProverka
			call OneHundredProverkaBrak
			ret
OverflowCheck ENDP

SumOut     PROC NEAR  				;≥íTã≥-≥-≥+≥ø≥- TÅTÉ≥-≥-TÉ ≥-≥- ≥ø≥-≥+≥ø≥≥≥-TÇ≥-TÄTã
			xor cx, cx
			mov cl, 01h
            lea   bx, DataHexTabl 
			lea SI, Res
SumOut1:	mov ah, [SI]
			mov al, ah
			xlat
			;not al					;TÇ≥-≥-≥ø≥øTá≥-≥-≥≥ ≥øTÄ≥≥≥-≥-TÄ≥-≥ø≥-≥-≥-≥-≥ø≥≥
			out SumPort, al			;≥-Tã≥-≥-≥+≥ø≥- ≥-≥- ≥ø≥-≥+≥ø≥≥≥-TÇ≥-TÄ
			mov al, cl
			out SumPowerPort, al	;≥ø≥-≥≥≥ø≥≥≥-≥≥≥- ≥ø≥-≥+≥ø≥≥≥-TÇ≥-TÄ
			mov al,00h
			out SumPowerPort, al	;≥≥≥-TÅ≥ø≥- ≥ø≥-≥+≥ø≥≥≥-TÇ≥-TÄ
			shl cl, 1
			inc SI
			cmp cl, 20h
			jbe SumOut1
		    xor ah, ah
			xor cx, cx
SumOutRet:  ret
SumOut      ENDP

CntOut 	    PROC NEAR
			xor cx, cx
			mov cl, 01h
			lea   bx, DataHexTabl
			lea SI, byte ptr Cnt
CntOut1:	mov ah, [SI]
			mov al, ah
			xlat					;TÇ≥-≥-≥ø≥øTá≥-≥-≥≥ ≥øTÄ≥≥≥-≥-TÄ≥-≥ø≥-≥-≥-≥-≥ø≥≥
			out CntPort, al			;≥-Tã≥-≥-≥+≥ø≥- ≥-≥- ≥ø≥-≥+≥ø≥≥≥-TÇ≥-TÄ
			mov al, cl
			out CntPowerPort, al	;≥ø≥-≥≥≥ø≥≥≥-≥≥≥- ≥ø≥-≥+≥ø≥≥≥-TÇ≥-TÄ 
			mov al,00h
			out CntPowerPort, al	;≥≥≥-TÅ≥ø≥- ≥ø≥-≥+≥ø≥≥≥-TÇ≥-TÄ
			shl cl, 1
			inc SI
			cmp cl, 04h
			jbe CntOut1
			xor ah, ah
			xor cx, cx
			
			mov cl, 08h
			lea   bx, DataHexTabl
			lea SI, byte ptr CntBrak
CntOut2:	mov ah, [SI]
			mov al, ah
			xlat					;TÇ≥-≥-≥ø≥øTá≥-≥-≥≥ ≥øTÄ≥≥≥-≥-TÄ≥-≥ø≥-≥-≥-≥-≥ø≥≥				
			out CntPort, al			;≥-Tã≥-≥-≥+≥ø≥- ≥-≥- ≥ø≥-≥+≥ø≥≥≥-TÇ≥-TÄ
			mov al, cl
			out CntPowerPort, al	;≥ø≥-≥≥≥ø≥≥≥-≥≥≥- ≥ø≥-≥+≥ø≥≥≥-TÇ≥-TÄ 
			mov al,00h
			out CntPowerPort, al	;≥≥≥-TÅ≥ø≥- ≥ø≥-≥+≥ø≥≥≥-TÇ≥-TÄ
			shl cl, 1
			inc SI
			cmp cl, 20h
			jbe CntOut2
			xor ah, ah
			xor cx, cx
			ret
CntOut 	   ENDP

Sbros PROC NEAR
			call Initialization
			ret
Sbros ENDP

DisplayOutput PROC NEAR
			call SumOut
			call CntOut
			ret
DisplayOutput ENDP

VibrDestr  PROC  NEAR
VD1:       mov   ah,al       ;≥°≥-TÖTÄ≥-≥-≥≥≥-≥ø≥≥ ≥øTÅTÖ≥-≥+≥-≥-≥≥≥- TÅ≥-TÅTÇ≥-Tè≥-≥øTè
           mov   ch,0        ;≥°≥-TÄ≥-TÅ TÅTáTëTÇTá≥ø≥≥≥- ≥ø≥-≥-TÇ≥-TÄ≥≥≥-≥ø≥≥
VD2:       in    al,dx       ;≥í≥-≥-≥+ TÇ≥≥≥≥TÉTâ≥≥≥≥≥- TÅ≥-TÅTÇ≥-Tè≥-≥øTè
           cmp   ah,al       ;≥¢≥≥≥≥TÉTâ≥≥≥≥ TÅ≥-TÅTÇ≥-Tè≥-≥ø≥≥=≥øTÅTÖ≥-≥+≥-≥-≥-TÉ?
           jne   VD1         ;≥ü≥≥TÄ≥≥TÖ≥-≥+, ≥≥TÅ≥ø≥ø ≥-≥≥TÇ
           inc   ch          ;≥ò≥-≥≥TÄ≥≥≥-≥≥≥-TÇ TÅTáTëTÇTá≥ø≥≥≥- ≥ø≥-≥-TÇ≥-TÄ≥≥≥-≥ø≥≥
           cmp   ch,NMax     ;≥ö≥-≥-≥≥TÜ ≥+TÄ≥≥≥-≥≥≥ø≥≥≥-?
           jne   VD2         ;≥ü≥≥TÄ≥≥TÖ≥-≥+, ≥≥TÅ≥ø≥ø ≥-≥≥TÇ
           mov   al,ah       ;≥í≥-TÅTÅTÇ≥-≥-≥-≥-≥ø≥≥≥-≥ø≥≥ ≥-≥≥TÅTÇ≥-≥ø≥-≥ø≥-≥≥≥≥≥-≥øTè ≥+≥-≥-≥-TãTÖ
           ret
VibrDestr  ENDP

CopyArr PROC NEAR
			MOV CX, 10 ;≥ó≥-≥≥TÄTÉ≥ø≥≥≥- TÅTáTëTÇTá≥ø≥≥≥- TÜ≥ø≥≥≥ø≥-≥-
			LEA BX, HexArr ;≥ó≥-≥≥TÄTÉ≥ø≥≥≥- ≥-≥+TÄ≥≥TÅ≥- ≥-≥-TÅTÅ≥ø≥-≥- TÜ≥øTÑTÄ
			LEA BP, HexTabl ;≥ó≥-≥≥TÄTÉ≥ø≥≥≥- ≥-≥+TÄ≥≥TÅ≥- TÇ≥-≥-≥ø≥øTÜTã ≥øTÄ≥≥≥-≥-TÄ≥-≥ø≥-≥-≥-≥-≥øTè
			LEA DI, DataHexArr ;≥ó≥-≥≥TÄTÉ≥ø≥≥≥- ≥-≥+TÄ≥≥TÅ≥- ≥-≥-TÅTÅ≥ø≥-≥- TÜ≥øTÑTÄ ≥- TÅ≥≥≥≥≥-≥≥≥-TÇ≥≥ ≥+≥-≥-≥-TãTÖ
			LEA SI, DataHexTabl ;≥ó≥-≥≥TÄTÉ≥ø≥≥≥- ≥-≥+TÄ≥≥TÅ≥- TÇ≥-≥-≥ø≥øTÜTã ≥øTÄ≥≥≥-≥-TÄ≥-≥ø≥-≥-≥-≥-≥øTè ≥- TÅ≥≥≥≥≥-≥≥≥-TÇ≥≥ ≥+≥-≥-≥-TãTÖ
CopyArr0:
			MOV AL, CS:[BX] ;≥ßTÇ≥≥≥-≥ø≥≥ TÜ≥øTÑTÄTã ≥ø≥ø ≥-≥-TÅTÅ≥ø≥-≥- ≥- ≥-≥≥≥≥TÉ≥-TÉ≥øTèTÇ≥-TÄ
			MOV [DI], AL ;≥ó≥-≥ø≥øTÅTå TÜ≥øTÑTÄTã ≥- TÅ≥≥≥≥≥-≥≥≥-TÇ ≥+≥-≥-≥-TãTÖ/DataHexArr
			INC BX ;≥ú≥-≥+≥øTÑ≥ø≥≥≥-TÜ≥øTè ≥-≥+TÄ≥≥TÅ≥- HexArr
			INC DI ;≥ú≥-≥+≥øTÑ≥ø≥≥≥-TÜ≥øTè ≥-≥+TÄ≥≥TÅ≥- DataHexArr
			LOOP CopyArr0
			
			MOV CX, 10 ;≥ó≥-≥≥TÄTÉ≥ø≥≥≥- TÅTáTëTÇTá≥ø≥≥≥- TÜ≥ø≥≥≥ø≥-≥-
CopyArr1:
			MOV AH, CS:[BP] ;≥ßTÇ≥≥≥-≥ø≥≥ ≥≥TÄ≥-TÑ≥øTá≥≥TÅ≥≥≥-≥≥≥- ≥-≥-TÄ≥-≥ø≥- ≥ø≥ø TÇ≥-≥-≥ø≥øTÜTã ≥øTÄ≥≥≥-≥-TÄ≥-≥ø≥-≥-≥-≥-≥øTè
			MOV [SI], AH ;≥ó≥-≥ø≥øTÅTå ≥≥TÄ≥-TÑ≥øTá≥≥TÅ≥≥≥-≥≥≥- ≥-≥-TÄ≥-≥ø≥- ≥- TÅ≥≥≥≥≥-≥≥≥-TÇ ≥+≥-≥-≥-TãTÖ/DataHexTabl
			INC BP ;≥ú≥-≥+≥øTÑ≥ø≥≥≥-TÜ≥øTè ≥-≥+TÄ≥≥TÅ≥- HexTabl
			INC SI ;≥ú≥-≥+≥øTÑ≥ø≥≥≥-TÜ≥øTè ≥-≥+TÄ≥≥TÅ≥- DataHexTabl
			LOOP CopyArr1
			
			MOV CX, 14 ;≥ó≥-≥≥TÄTÉ≥ø≥≥≥- TÅTáTëTÇTá≥ø≥≥≥- TÜ≥ø≥≥≥ø≥-≥-
			LEA BP, Table ;≥ó≥-≥≥TÄTÉ≥ø≥≥≥- ≥-≥+TÄ≥≥TÅ≥- TÇ≥-≥-≥ø≥øTÜTã ≥øTÄ≥≥≥-≥-TÄ≥-≥ø≥-≥-≥-≥-≥øTè
			LEA SI, DataTable ;≥ó≥-≥≥TÄTÉ≥ø≥≥≥- ≥-≥+TÄ≥≥TÅ≥- TÇ≥-≥-≥ø≥øTÜTã ≥øTÄ≥≥≥-≥-TÄ≥-≥ø≥-≥-≥-≥-≥øTè ≥- TÅ≥≥≥≥≥-≥≥≥-TÇ≥≥ ≥+≥-≥-≥-TãTÖ
CopyArr2:
			MOV AH, CS:[BP] ;≥ßTÇ≥≥≥-≥ø≥≥ ≥≥TÄ≥-TÑ≥øTá≥≥TÅ≥≥≥-≥≥≥- ≥-≥-TÄ≥-≥ø≥- ≥ø≥ø TÇ≥-≥-≥ø≥øTÜTã ≥øTÄ≥≥≥-≥-TÄ≥-≥ø≥-≥-≥-≥-≥øTè
			MOV [SI], AH ;≥ó≥-≥ø≥øTÅTå ≥≥TÄ≥-TÑ≥øTá≥≥TÅ≥≥≥-≥≥≥- ≥-≥-TÄ≥-≥ø≥- ≥- TÅ≥≥≥≥≥-≥≥≥-TÇ ≥+≥-≥-≥-TãTÖ/DataTable
			MOV AL, CS:[BP+1] ;≥ßTÇ≥≥≥-≥ø≥≥ ≥≥TÄ≥-TÑ≥øTá≥≥TÅ≥≥≥-≥≥≥- ≥-≥-TÄ≥-≥ø≥- ≥ø≥ø TÇ≥-≥-≥ø≥øTÜTã ≥øTÄ≥≥≥-≥-TÄ≥-≥ø≥-≥-≥-≥-≥øTè
			MOV [SI+1], AL ;≥ó≥-≥ø≥øTÅTå ≥≥TÄ≥-TÑ≥øTá≥≥TÅ≥≥≥-≥≥≥- ≥-≥-TÄ≥-≥ø≥- ≥- TÅ≥≥≥≥≥-≥≥≥-TÇ ≥+≥-≥-≥-TãTÖ/DataTable
			INC BP ;≥ú≥-≥+≥øTÑ≥ø≥≥≥-TÜ≥øTè ≥-≥+TÄ≥≥TÅ≥- Table
			INC SI ;≥ú≥-≥+≥øTÑ≥ø≥≥≥-TÜ≥øTè ≥-≥+TÄ≥≥TÅ≥- DataTable
			INC BP ;≥ú≥-≥+≥øTÑ≥ø≥≥≥-TÜ≥øTè ≥-≥+TÄ≥≥TÅ≥- Table
			INC SI ;≥ú≥-≥+≥øTÑ≥ø≥≥≥-TÜ≥øTè ≥-≥+TÄ≥≥TÅ≥- DataTable
			LOOP CopyArr2
			
			MOV CX, 4 ;≥ó≥-≥≥TÄTÉ≥ø≥≥≥- TÅTáTëTÇTá≥ø≥≥≥- TÜ≥ø≥≥≥ø≥-≥-
			LEA BP, Err ;≥ó≥-≥≥TÄTÉ≥ø≥≥≥- ≥-≥+TÄ≥≥TÅ≥- TÇ≥-≥-≥ø≥øTÜTã ≥øTÄ≥≥≥-≥-TÄ≥-≥ø≥-≥-≥-≥-≥øTè
			LEA SI, ErrTable ;≥ó≥-≥≥TÄTÉ≥ø≥≥≥- ≥-≥+TÄ≥≥TÅ≥- TÇ≥-≥-≥ø≥øTÜTã ≥øTÄ≥≥≥-≥-TÄ≥-≥ø≥-≥-≥-≥-≥øTè ≥- TÅ≥≥≥≥≥-≥≥≥-TÇ≥≥ ≥+≥-≥-≥-TãTÖ
CopyArr3:
			MOV AH, CS:[BP] ;≥ßTÇ≥≥≥-≥ø≥≥ ≥≥TÄ≥-TÑ≥øTá≥≥TÅ≥≥≥-≥≥≥- ≥-≥-TÄ≥-≥ø≥- ≥ø≥ø TÇ≥-≥-≥ø≥øTÜTã ≥øTÄ≥≥≥-≥-TÄ≥-≥ø≥-≥-≥-≥-≥øTè
			MOV [SI], AH ;≥ó≥-≥ø≥øTÅTå ≥≥TÄ≥-TÑ≥øTá≥≥TÅ≥≥≥-≥≥≥- ≥-≥-TÄ≥-≥ø≥- ≥- TÅ≥≥≥≥≥-≥≥≥-TÇ ≥+≥-≥-≥-TãTÖ/DataTable
			MOV AL, CS:[BP+1] ;≥ßTÇ≥≥≥-≥ø≥≥ ≥≥TÄ≥-TÑ≥øTá≥≥TÅ≥≥≥-≥≥≥- ≥-≥-TÄ≥-≥ø≥- ≥ø≥ø TÇ≥-≥-≥ø≥øTÜTã ≥øTÄ≥≥≥-≥-TÄ≥-≥ø≥-≥-≥-≥-≥øTè
			MOV [SI+1], AL ;≥ó≥-≥ø≥øTÅTå ≥≥TÄ≥-TÑ≥øTá≥≥TÅ≥≥≥-≥≥≥- ≥-≥-TÄ≥-≥ø≥- ≥- TÅ≥≥≥≥≥-≥≥≥-TÇ ≥+≥-≥-≥-TãTÖ/DataTable
			INC BP ;≥ú≥-≥+≥øTÑ≥ø≥≥≥-TÜ≥øTè ≥-≥+TÄ≥≥TÅ≥- Err
			INC SI ;≥ú≥-≥+≥øTÑ≥ø≥≥≥-TÜ≥øTè ≥-≥+TÄ≥≥TÅ≥- ErrTable
			LOOP CopyArr3
			xor bp,bp
			xor cx, cx
			xor ax, ax
			ret
CopyArr ENDP

Start:
			mov   ax,Data
			mov   ds,ax
			mov   es,ax
			mov   ax,Stk
			mov   ss,ax
			lea   sp,StkTop
		   
			call Initialization
			call CopyArr
		   
MainLoop:	call ReadInput
			call Simul
			call OverflowCheck
			call AccumulationSumm
			call DisplayOutput
			jmp MainLoop
;≥ó≥+≥≥TÅTå TÄ≥-≥ø≥-≥≥Tâ≥-≥≥TÇTÅTè ≥≥≥-≥+ ≥øTÄ≥-≥≥TÄ≥-≥-≥-Tã


;≥í TÅ≥ø≥≥≥+TÉTéTâ≥≥≥≥ TÅTÇTÄ≥-≥≥≥≥ ≥-≥≥≥-≥-TÖ≥-≥+≥ø≥-≥- TÉ≥≥≥-≥ø≥-TÇTå TÅ≥-≥≥Tâ≥≥≥-≥ø≥≥ TÅTÇ≥-TÄTÇ≥-≥-≥-≥≥ TÇ≥-Tá≥≥≥ø
			org   RomSize-16-((InitDataEnd-InitDataStart+15) AND 0FFF0h)
			ASSUME cs:NOTHING
			jmp   Far Ptr Start
Code       	ENDS
END		Start
