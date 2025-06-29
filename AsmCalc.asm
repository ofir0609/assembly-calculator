;Ofir Aviani Calculator
IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
	Ten dw 10
	Ten1 db 10
;	Two db 2
;	Minus? db 0
	TenThou dw 2710h
	Var1 dw ?
	Var2 dw ?
	Digit dw ?
	Num dw ?
	Exitt db ?
	Error? db ?
	Base dw ?
	Oper? db ?
	Ans db ?
	Sheerit dw ?
	BigAns1 dw ?
	BigAns2 dw ?
	Benaim dw ?
	DigitsCount dw ?
	WhichVar db ?
	StrtMsg db 'Press Esc to quit the program. The valid operands are: + - * / ^ !$'
	ClcMsg db 'Enter a digit, an operand and another digit (or a digit and ! for Factorial)$'
	NoOperErr db 'Error! The number needs an operand$'
	UnValidNumErr db ' Error! The number is not valid$'
	BigNumErr db ' Error! The number is too big$'
	BigAnswerErr db 'Error! The answer is to big (above 655,350,000) $'
	OpErr db 'Error! Enter a valid operand instead$'
	ZerDivErr db 'Error! dividing by zero is invalid... Try another number$'
CODESEG
proc PrintProc
	cmp [Error?], 0
	je NoError
	ret
NoError:
	cmp [BigAns1], 0
	ja therest
	cmp [BigAns2], 0
	ja therest
	mov dx, 30h ;if the answer equals to zero
	mov ah, 2h
	int 21h
	jmp SheeritPrint
therest:
	mov ax, [BigAns1]
	mov dx, [BigAns2]
	div [TenThou]
	mov [Benaim], ax ;		part1:
	mov ax, dx
	mov [DigitsCount], 0
part1:
	cmp ax, 0
	je partt2
	xor dx, dx
	div [Ten]
	push dx
	inc [DigitsCount]
	jmp part1 ;		part2:
partt2:
	cmp [DigitsCount], 4
	je part2
	cmp [Benaim], 0
	je print
	mov cx, 4
	sub cx, [DigitsCount]
ZerLoop:
	inc [DigitsCount]
	xor dx, dx
	push dx
	loop ZerLoop
part2:
	mov ax, [Benaim]
loopart2:
	cmp ax, 0
	je print
	xor dx, dx
	div [Ten]
	push dx
	inc [DigitsCount]
	jmp loopart2
print:
	mov cx, [DigitsCount]
looprint:
	pop dx
	add dx, 30h
	mov ah, 2h
	int 21h
	loop looprint
SheeritPrint:
	cmp [Sheerit], 0
	je EndPrint
	mov [DigitsCount], 0
	xor dx, dx
	mov ax, [Sheerit]
SheeritLoop:
	inc [DigitsCount]
	div [Ten]
	push dx
	xor dx, dx
	cmp ax, 0
	jne SheeritLoop
	mov dl, '('
	mov ah, 2h
	int 21h
	mov cx, [DigitsCount]
SheeritPrintLoop:
	pop dx
	add dx, 30h
	mov ah, 2h
	int 21h
	loop SheeritPrintLoop
	mov dl, ')'
	mov ah, 2h
	int 21h
EndPrint:
	ret
endp PrintProc
proc Addition
	mov ax, [Var1]
	add ax, [Var2]
	mov [BigAns1] ,ax
	cmp ax, [Var1]
	jb One
	mov [BigAns2], 0
	ret
One:
	mov [BigAns2], 1
	ret
endp Addition
proc Subtraction
	mov ax, [Var1]
	cmp ax, [Var2]
	jb Negati
	sub ax, [Var2]
	mov [BigAns1], ax
	mov [BigAns2], 0
	ret
Negati:
	sub ax, [Var2]
	not ax 
	inc ax
	mov [BigAns1], ax
	mov [BigAns2], 0
	mov dl, '-' ; Change to sign%2=0 or something
	mov ah, 2h
	int 21h
	ret
endp Subtraction
proc Multiplication
	mov ax, [Var1]
	mul [Var2]
	mov [BigAns1], ax
	mov [BigAns2], dx
	ret
endp Multiplication
proc Division
	xor dx, dx
	mov ax, [Var1]
	div [Var2]
	mov [BigAns1], ax
	mov [BigAns2], 0
	mov [Sheerit], dx
	ret
endp Division
proc Factory
	mov [BigAns1], 1
	mov [BigAns2], 0
	mov [Benaim], 0
	cmp [Var1], 1
	ja Factorr
	ret
Factorr:
	cmp [Var1], 12
	jbe NotToBig
	mov dx, offset BigAnswerErr
	mov ah, 9h
	int 21h
	inc [Error?]
	ret
NotToBig:
	mov ax, [Var1]
	mov [BigAns1], ax
	mov cx, [Var1]
	dec cx
FactorMu:
	mov ax, [BigAns2]
	mul cx
	mov [BigAns2], ax
	mov ax, [BigAns1]
	mul cx
	mov [BigAns1], ax
	add [BigAns2], dx
	xor dx, dx
	loop FactorMu
	ret
endp Factory
proc Exponent ;            Is answer too big? *~*
	mov [BigAns1], 1
	mov [BigAns2], 0
	cmp [Var2], 0
	je ending
	mov ax, [Var1]
	mov [Base], ax
	mov [BigAns1], ax
	mov cx, [Var2]
	dec cx
	cmp cx, 0
	je ending
ploop:
	xor dx, dx
	mov ax, [BigAns2]
	mul [Base]
	mov [BigAns2], ax
	mov ax, [BigAns1]
	mul [Base]
	mov [BigAns1], ax
	add [BigAns2], dx
	loop ploop
ending:
	ret
endp Exponent
;proc Negative
;	xor ah, ah
;	mov al, [Minus?]
;	div [Two]
;	cmp ah, 0
;	je ennd
;	mov dl, '-'
;	mov ah, 2h
;	int 21h
;ennd:
;	ret
;endp
proc AbsorbNum         ;We can start counting digits after the first digits which isn't 0
	mov [Num], 0
	mov [Exitt], 0
AbsorbLoop:
	mov ah, 1h 
	int 21h
	xor ah, ah
	mov [Digit], ax
	cmp [Digit], 27
	jne ContinueAbsorb
	inc [Exitt]
	ret
ContinueAbsorb:
	cmp [Digit], 39h
	ja NotDigit
	cmp [Digit], 30h
	jb NotDigit
	sub [Digit], 30h
	xor dx, dx
	mov ax, [Num]
	mul [Ten]
	add ax ,[Digit]
	mov [Num], ax
	cmp dx, 0
	je AbsorbLoop
	mov dx, offset BigNumErr
	mov ah, 9h
	int 21h
	inc [Error?]
	ret
NotDigit:
	cmp [Digit], 13
	je Enterr
	mov ax, [Digit]
	mov [Oper?], al
	jmp FinishAbsorb
Enterr:
	cmp [WhichVar], 1
	je FinishAbsorb
	inc [Error?]
	mov dx, offset NoOperErr
	mov ah, 9h
	int 21h
FinishAbsorb:
	cmp [Num], 0
	jne NumGood
	cmp [Digit], 0
	jne NumGood
	inc [Error?]
	mov dx, offset BigNumErr
	mov ah, 9h
	int 21h
	ret
NumGood:
	ret
endp AbsorbNum
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------
	mov ax, 0003h
	int 10h
	mov dx, offset StrtMsg
	mov ah, 9h
	int 21h
Clctr:
	mov dl, 0ah
	mov ah, 2h
	int 21h
	mov dx, offset ClcMsg
	mov ah, 9h
	int 21h
	mov dl, 0ah
	mov ah, 2h
	int 21h
	mov [Sheerit], 0
	mov [WhichVar], 0
	mov [Error?], 0
	call AbsorbNum
	cmp [Error?], 1
	je Clctr
	inc [WhichVar]
	cmp [Exitt], 0
	jne exiting
	mov ax, [Num]
	mov [Var1], ax
	cmp [Oper?], '!'
	je Factorial
	call AbsorbNum
	cmp [Exitt], 0
	jne exiting
	mov ax, [Num]
	mov [Var2], ax
	cmp [Oper?], '+' ;:בדיקת סוג הפעולה החשבונית
	je Plus
	cmp [Oper?], '-'
	je Minus
	cmp [Oper?], '*'
	je Multi
	cmp [Oper?], '/'
	je Divide
	cmp [Oper?], '^'
	je Power
	mov dx, offset OpErr ;אם זו לא אף אחת מהפעולות, הדפסת שגיאה
	mov ah, 9h
	int 21h
	mov dl, 0ah
	mov ah, 2h
	int 21h
	jmp Clctr
exiting:
	jmp exit
Plus:
	call Addition
	jmp Printing
Minus:
	call Subtraction
	jmp Printing
Multi:
	call Multiplication
	jmp Printing
Divide:
	call Division
	jmp Printing
Factorial:
	mov dl, 0ah
	mov ah, 2h
	int 21h
	call Factory
	jmp Printing
Power:
	call Exponent
	jmp Printing
Printing:
	call PrintProc
	jmp Clctr
exit:
	mov ax, 4c00h
	int 21h
END start