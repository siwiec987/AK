_code segment
	assume  cs:_code

start:	mov	ax, _data
	mov	ds, ax
	assume	ds:_data
	mov	ax, _stack
	mov	ss, ax
	assume	ss:_stack
	mov	sp, top_stack
;-------------------------------------          
    
    lea dx, start_msg
    mov ah, 09h
    int 21h
    
    call wprowadzanie
            
    lea dx, bin_msg
    mov ah, 09h
    int 21h
    
    call binarna
    
    lea dx, hex_msg
    mov ah, 09h
    int 21h
    
    call heksadecymalna
    
koniec:
	mov	ah, 4ch
	mov	al, 0
	int	21h

;-----------------------------------------------------------------
	
wprowadzanie:
    mov cx, 7 
	mov ah, 01h
	int 21h
	inc ile_znakow
 
    cmp al, '-'
    jne pierwsza_cyfra
    mov czy_ujemna, 1
    
    ;mov ah, 01h
    ;int 21h
    ;inc ile_znakow
    
;pierwsza_cyfra:    
    ;cmp	al, '1'	
	;jb	powtorz
	;cmp	al, '9'
	;ja	powtorz
	;jmp dalej

petla:    
    mov ah, 01h
    int 21h
    inc ile_znakow
         
	cmp	al, 0dh	
	je enter
   
pierwsza_cyfra:
	cmp	al, '0'	
	jb	powtorz
	cmp	al, '9'
	ja	powtorz
	
dalej:
	sub al, '0'
	mov	dl, al
	mov	ax, bx

	shl	bx, 1
	jc powtorz		; mnozenie x10

	shl	ax, 1 
	jc powtorz
	shl	ax, 1 
	jc powtorz
	shl	ax, 1
	jc powtorz

	add	bx, ax
	jc powtorz		; koniec mnozenia, bx=bx*10

	add	bl, dl		; dodajemy cyfre
	adc	bh, 0
	jc powtorz

	loop petla

enter:
    cmp czy_ujemna, 1
    jne dodatnia
    cmp bx, 32768
    ja powtorz
    neg bx
    jmp wprowadzanie_koniec
    
dodatnia:
    cmp bx, 32767
    ja powtorz 

wprowadzanie_koniec:
    mov liczba, bx      
    ret
    
powtorz:
    mov ah, 02h
    mov bh, 0
    mov dh, 1
    mov dl, 0
    int 10h
         
    mov al, ile_znakow
    cbw
    mov cx, ax
    mov ah, 0ah
    mov al, ' '
    int 10h
    
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov czy_ujemna, 0
    mov ile_znakow, 0
    
    jmp wprowadzanie
    
;-----------------------------------------------------------------

binarna:
    mov cx, 16  
    
bin_petla:
    mov ax, 0         
    rcl bx, 1
    adc al, '0'
 
    mov dl, al
    mov ah, 02h
    int 21h
    
    loop bin_petla
    ret
    
;-----------------------------------------------------------------	  

heksadecymalna:
    mov ax, liczba
    mov bx, 10h
    mov dx, 0  
    
    cmp ax, 0
    jne hex_petla
    mov cx, 1
    jmp hex_print2
    
hex_petla:
    cmp ax, 0
    je hex_print
    div bx
    push dx
    inc cx
    mov dx, 0
    
    jmp hex_petla
    
hex_print:
    ;cmp cx, 0
    
    pop dx
    cmp dx, 9
    jle hex_print2
    add dx, 7
    
hex_print2:
    add dx, '0'
    mov ah, 02h
    int 21h
    
    loop hex_print
    
    ret

;-----------------------------------------------------------------	

_code ends

_data segment
	start_msg db 'Podaj liczbe:', 0dh, 0ah, '$'     
    bin_msg db 0dh, 0ah, 'Reprezentacja binarna:', 0dh, 0ah, '$'                 
    hex_msg db 0dh, 0ah, 'Reprezentacja heksadecymalna:', 0dh, 0ah, '$'
    liczba dw ?
    ile_znakow db 0
    czy_ujemna db 0
_data ends

_stack segment stack
	top_stack	equ 100h
_stack ends

end start