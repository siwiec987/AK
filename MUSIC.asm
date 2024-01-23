_code segment
   assume  cs:_code

start:   mov   ax, _data
   mov   ds, ax
   assume   ds:_data
   mov   ax, _stack
   mov   ss, ax
   assume   ss:_stack
   mov   sp, top_stack
   
   
GET_FILE:
	xor cx,cx
	mov cl,es:[80h]         ; POD ADRESEM es:[80h] ZNAJDUJE SIE BAJT ZAWIERAJACY DLUGOSC PARAMETROW
	cmp cl,0                ; SPRAWDZENIE CZY PODANO SCIEZKE DO PLIKU
	je NO_ARGUMENT
	dec cl                  ; POMIJAMY SPACJE PO .EXE
	lea di,file_name        ; USTALAMY WSKAZNIK SI NA MIEJSCE W PAMIECI W SEGMENCIE DANYCH DO KTOREGO BEDZIE ZAPISYWANA SCIEZKA PLIKU  
	mov si,82h              ; [80]- BYTE Z DLUGOSCIA, [81]-NIECHCIANA SPACJA, [82+]-PARAMETR
				
SAVE_FILE_NAME:	            ; ZAPISANIE NAZWY PLIKU
	mov al,es:[si]          ; KOPIOWANIE KAZDEGO ZNAKU PARAMETRU DO PRZEMIESZCZENIA FNAME W DATA SEGMENT 
	mov ds:[di],al
	inc	si                  ; INKREMENTUJ SI - TERAZ WSKAZUJE NA KOLEJNY BAJT DO KTOREGO MA BYC SKOPIOWANY ZNAK  
	inc	di                  ; INKREMENTUJ DI - TERAZ WSKAZUJE NA KOLEJNY ZNAK DO SKOPIOWANIA 
	loop SAVE_FILE_NAME          ; POWTARZA JESLI CX != 0, CX == 0 - PARAMETR PRZEPISANY 

INIT:
   xor si,si                ; WYZEROWANIE SI, DI i DX
   xor di,di
   xor dx,dx
   call INIT_CHIP           ; INICJALIZACJA UKLADU 8253
   call OPEN_FILE           ; OTWARCIE PLIKU
   call SPEAKER_ON          ; WLACZENIE GLOSNIKA

MAIN:
   call READ_LINE           ; WCZYTANIE LINII POD ADRES LINES, CZYLI 4 ZNAKOW: NUTA,OKTAWA,CZAS,ENTER 
   cmp ax, 'E'              ; KONIEC PLIKU JEST OZNACZONE JAKO 'E' W AX
   je CLOSE                 ; ZAKONCZ WYKONYWANIE PETLI
   mov dl, [chars+2]        ; PRZESLANIE CZASU 
   sub dl, '0'              ; ZAPISANY JEST KOD ASCII, WIEC TRZEBA ODJAC 48
   mov timeH, dx            ; PRZESLANIE WCZYTANEGO CZASU POD ADRES TIMEH, KTORY JEST WYKORZYSTANY W DELAY
   mov cl, [chars+1]        ; PRZESLANIE OKTAWY
   sub cl, '0'              ; ZAMIANA NA LICZBE
   mov dl, [chars]          ; PRZESLANIE POZYCJI NUTY
   sub dx, '0'              ; ZAMIANA NA LICZBE
   add dx,dx                ; ABY PRZESUWALO O SLOWO
   mov si,dx                
   mov bx, [notes + si]     ; CZESTOTLIWOSC NUTY W OKTAWIE 0
   shr bx,cl                ; POPRAWIENIE CZESTOTLIWOSCI O OKTAWE, ABY BYLA WIEKSZA CZESTOTLIWOSC
   call CH_FREQ             ; WYWOLANIE ZMIANY CZESTOTLIWOSCI
   call DELAY               ; ODCZEKAJ O WCZESNIEJ WCZYTANY CZAS
   jmp MAIN                 ; POWTARZANIE ODGRYWANIA TONU AZ NASTAPI KONIEC WCZYTYWANIA PLIKU
   
CLOSE:
   call CLOSE_FILE          ; ZAMKNIECIE PLIKU
   call SPEAKER_OFF         ; WYLACZENIE GLOSNIKA

KONIEC:
   mov ah, 4ch
   mov al, 0
   int 21h

NO_ARGUMENT:                ; WYSWIETLENIE INFORMACJI O BRAKU PODANIU NAZWY PLIKU 
   mov ah,09h         
   lea dx,empty_arg
   int 21h
   jmp KONIEC

ERROR:                      
   lea dx,error_msg
   mov ah,09h
   int 21h
   jmp KONIEC

SPEAKER_ON:
   in al, 61h               ; POBRANIE BAJTU Z UKLADU, ABY NIE ZMIENIAC BITOW ODPOWIEDZIALNYCH ZA INNE RZECZY
   or al, 00000011b         ; USTAWIENIE DWOCH NAJMLODSZYCH BITOW ODPOWIEDZIALNYCH ZA WLACZENIE GLOSNIKA(GATE2 I SPEAKER DATA), BEZ ZMIANY POZOSTALYCH
   out 61h, al              ; WYSLANIE ZMIENIONEGO BAJTU DO UKLADU, CO SPOWODUJE URUCHOMIENIE GLOSNIKA
   ret

SPEAKER_OFF:
   in al, 61h               ; POBRANIE BAJTU Z UKLADU
   and al, 11111100b        ; USTAWIENIE DWOCH NAJMLODSZYCH BITOW ODPOWIEDZIALNYCH ZA WLACZENIE GLOSNIKA, BEZ ZMIANY POZOSTALYCH
   out 61h, al              ; WYSLANIE BAJTU DO UKLADU, ABY WYLACZYC GLOSNIK 
   ret

DELAY:
   mov cx, timeH            ; OPOZNIENIE W MIKROSEKUNDACH CX:DX (np. 1000000 = 000f4240h, czyli 1s), MY ZMIENIAMY TYLKO CX O WIELOKROTNOSCI 65ms
   mov ah, 86h              ; FUNKCJA WYKONUJE PUSTA PETLE WYKONUJACA SIE CX:DX MIKROSEKUND 
   int 15h                  ; PRZERWANIE DODATKOWE AT
   ret

INIT_CHIP:
   mov al, 10110110b        ; ZAPISANIE BAJTU STERUJACEGO: B7-6 KANAL 2, B5-4 WCZYTANIE NAJMLODSZY NAJSTARSZY BAJT, B3-1 GENERATOR FALI PROSTOKATNEJ
   out 43h, al              ; PRZESLANIE BAJTU STERUJACEGO DO REJESTRU STERUJACEGO 8253
   ret

CH_FREQ:
   mov ax, bx               ; W BX JEST ZAPISANY DZIELNIK 
   out 42h, al              ; PRZESLANIE DZIELNIKA DO LICZNIKA CZESTOTLIWOSCI, NAJPIERW MLODSZY BAJT
   mov al, ah               ; NASTEPNIE STARSZY BAJT (OUT DZIALA Z REJESTREM AL LUB AX)
   out 42h, al             
   ret

;OBSLUGA PLIKU 
OPEN_FILE:
   lea dx, file_name        ; PRZESLANIE ADRESU NAZWY PLIKU
   mov ax, 3d00h            ; FUNKCJA OTWIERANIA PLIKU W TRYBIE READ (AL = 0)
   int 21h
   jc ERROR                   ; USTAWIONA FLAGA C OZNACZA BLAD OTWIERANIA
   mov handler, ax          ; PRZESLANIE NUMERU DOJSCIA DO PLIKU
   ret

CLOSE_FILE:
   mov bx, handler          ; PRZESLANIE NUMERU DOJSCIA DO PLIKU
   mov ah, 3eh              ; FUNKCJA ZAMKNIECIA PLIKU
   int 21h
   jc ERROR                   ; USTAWIONA FLAGA C OZNACZA BLAD ZAMKNIECIA
   ret

READ_LINE:
   mov cx, 4d               ; USTAWIENIE LICZBY BAJTOW DO PRZECZYTANIA
   lea dx, chars            ; PRZESLANIE ADRESU DO KTOREGO BEDA PRZESYLANE WCZYTANE ZNAKI
   mov bx, handler          ; USTAWIENIE ADRESU POD KTORYM ZAPISANY ZOSTANIE NUMER DOJSCIA DO PLIKU
   mov ah, 3fh              ; FUNKCJA WCZYTUJACA CX BAJTOW DO DS:DX
   int 21h
   jc ERROR                   ; USTAWIONA FLAGA C OZNACZA BLAD WCZYTANIA
   cmp ax,0d                ; NIE WCZYTANO ZADNYCH ZNAKOW, CZYLI KONIEC PLIKU
   je END_OF_FILE                     
   mov ax, 'N'              ; PRZESLANIE DO AX 'N', ABY WIEDZIEC CZY BYL KONIEC PLIKU
   ret
END_OF_FILE:
   mov ax, 'E'              ; PRZESLANIE DO AX 'E', ABY WIEDZIEC ZE NASTAPIL KONIEC PLIKU
   ret


_code ends

_data segment
   adr dw 1000h
   error_msg db 'BLAD',13,10,'$'
   timeH  dw 0001h
   notes  dw (1193180/33)      ; C
          dw (1193180/37)      ; D
          dw (1193180/39)      ; D#
          dw (1193180/41)      ; E
          dw (1193180/44)      ; F
          dw (1193180/46)      ; F#
          dw (1193180/49)      ; G 
          dw (1193180/52)      ; G#
          dw (1193180/55)      ; A
          dw (1193180/62)      ; B

   ;Dane zwiazane z obsluga pliku
   handler dw ?               ; ZAREZERWOWANIE SLOWA, BEZ INCIJALIZACJI 
   file_name db 80h dup(0),'$'    ; ZAINICJALIZOWANIE 128 BAJTOW ZERAMI
   chars db 4 dup(?)          ; ZAREZERWOWANIE 4 BAJTOW (DUP, CZYLI DUPLICATE, INACZEJ ? ? ? ?)
   empty_arg db 'Nie podano nazwy pliku',13,10,'$'
   
_data ends

_stack segment stack
   top_stack   equ 100h
_stack ends

end start