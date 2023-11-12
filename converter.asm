 ORG 800H  
	 LXI H,START_TEKST  
	 RST 7  
	 CALL WPROWADZANIE   
	 LXI H,BIN_TEKST  
	 RST 7  
	 CALL BINARNA  
	 LXI H,HEX_TEKST  
	 RST 7  
	 MOV A,D  
	 RST 4  
	 HLT  
;---------------------------------                                                                     
WPROWADZANIE  
CYFRA_1  
	 MVI E,1  
	 STC  
	 CMC  
	 RST 2  
	 CPI '0'  
	 JC POWTORZ  
	 CPI ':'  
	 JNC POWTORZ  
	 SUI 48  
	 MOV D,A  
CYFRA_2  
	 INR E  
	 STC  
	 CMC  
	 RST 2  
	 CPI 0DH  
	 JZ JEDNA_CYFRA  
	 CPI '0'  
	 JC POWTORZ  
	 CPI ':'  
	 JNC POWTORZ  
	 SUI 48  
	 MOV C,D  
	 MOV D,A  
CYFRA_3  
	 INR E  
	 STC  
	 CMC  
	 RST 2  
	 CPI 0DH  
	 JZ DWIE_CYFRY  
	 CPI '0'  
	 JC POWTORZ  
	 CPI ':'  
	 JNC POWTORZ  
	 SUI 48  
	 MOV B,C  
	 MOV C,D  
	 MOV D,A  
CZY_BAJT  
	 MVI A,2  
	 SUB B  
	 JM POWTORZ  
	 JNZ ZAPIS_LICZBY  
	 MVI A,5  
	 SUB C  
	 JM POWTORZ  
	 JNZ ZAPIS_LICZBY  
	 MVI A,5  
	 SUB D  
	 JM POWTORZ  
ZAPIS_LICZBY  
	 MVI E,100  
	 MVI A,0
MN_B  
	 ADD B  
	 DCR E  
	 JNZ MN_B  
	 MOV B,A  
DWIE_CYFRY  
	 MVI E,10  
	 MVI A,0  
MN_C  
	 ADD C  
	 DCR E  
	 JNZ MN_C  
	 MOV C,A  
	 MVI A,0  
	 ADD B  
	 ADD C  
	 ADD D  
	 MOV D,A     
JEDNA_CYFRA     
	 RET  
POWTORZ  
	 MVI A,8  
	 RST 1  
	 DCR E  
	 JNZ POWTORZ  
	 JMP CYFRA_1  
;---------------------------------------                                                                                                                   
BINARNA  
	 MVI C,8  
	 MOV A,D  
BIN_START  
	 RAL  
	 MOV B,A  
	 MVI A,0  
	 ACI 48  
	 RST 1  
	 MOV A,B  
	 DCR C  
	 JNZ BIN_START  
	 RET  
;---------------------------------------                                                                                                                                                                                                                   
START_TEKST  
	 DB 'Podaj liczbe:@'                   
BIN_TEKST  
	 DB 'Reprezentacja binarna:@'                   
HEX_TEKST  
	 DB 'Reprezentacja heksadecymalna:@'                   
;---------------------------------------                                                                                                                                                             
	 ORG 0B00H ;RST 7  
	 CALL NOWA_LINIA  
START  
	 MOV A,M  
	 CPI '@'  
	 JZ KONIEC  
	 RST 1  
	 INX H  
	 JMP START  
KONIEC  
	 CALL NOWA_LINIA  
	 RET  
;---------------------------------------                                                                                                                                              
NOWA_LINIA  
	 MVI A,0AH  
	 RST 1  
	 MVI A,0DH  
	 RST 1  
	 RET  
