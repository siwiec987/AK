_code segment
	assume  cs:_code	;assume code segment at cs:_code

start:	mov	ax, _data	;ax <- adr [_data]
	mov	ds, ax		;ds <- [ax]
	assume	ds:_data	;assume data segment at ds:_data
	mov	    ax, _stack	;ax <- adr [_stack]
	mov	    ss, ax		;ss <-[ax]
	assume	ss:_stack	;assume stack segment at ss:_stack
	mov	    sp, top_stack	;sp <- top_stack
;---------------------------------
;	clear screen
;---------------------------------
    	mov ax,0b800h		;extra segment
	mov	es,ax		;es = pamiec ekranu
	mov cx,2000		;loop counter (80x25)
	
	mov di,0		;offset
	mov al,' '		;znak
	mov ah,7		;atrybut
	
CSLOOP:	
    	mov es:[di],ax		;adr logiczny
	add	di,2		;next char
	
	dec cx		    	;next iteration
	jnz	CSLOOP		;jump

;---------------------------------
;	pyramid setup
;---------------------------------
;	info:
;	-width: 80
;	-height: 25
;	-cells: 2000
;---------------------------------
	mov	al,'A'		;starting letter
	mov	ah,2		;starting color
	mov	di,240		;starting offse
	mov	dx,156		;step
	mov	bl,24		;row counter
	mov	bh,1		;starting number of characters
;---------------------------------
;	pyramid print
;---------------------------------
PLOOP:
	mov	cl,bh		;set counter
	call PRINT		;call print
	add	di,dx		;step
	add	bh,2		;+2 chars in next line
	sub	dx,4		;-2 chars from step
	inc	al		    ;next char
	inc	ah		    ;next attr
	dec	bl		    ;decrease row counter
	jnz	PLOOP		;repeat if not 0
	jmp	FINISH		;end

PRINT:	
	mov	es:[di],ax	;print letter
	add	di,2		;next character position
	dec	cl		;decrease character counter
	jnz	PRINT		;repeat if not 0
	ret			;return

FINISH:
;=================================
		
	mov	ah, 4ch
	mov	al, 0
	int	21h
_code ends

_data segment
	; your data goes here
_data ends

_stack segment stack
	top_stack	equ 100h
_stack ends

end start
