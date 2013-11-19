         assume cs:codigo,ds:dados,es:dados,ss:pilha

CR        EQU    0DH ; caractere ASCII "Carriage Return" 
LF        EQU    0AH ; caractere ASCII "Line Feed"
BS		  EQU	 08H ; caractere ASCII "Backspace"

; SEGMENTO DE DADOS DO PROGRAMA
dados     segment
nome_dic  	db 30 dup (?)
nome_cif	db 30 dup (?)
buffer    	db 128 dup (?)
buffer_ptr	dw ?
handler   	dw ?
erro	  	db 'ERRO: O arquivo nao foi encontrado',CR,LF,'$'
tamanho	  	dw 0
n_linhas  	dw 0
msg0	  	db 'Marcos Henrique Backes - 00228483',CR,LF,CR,LF,'$'
msg1	  	db 'Digite o nome do arquivo de dicionario:',CR,LF,'$'
msg2	  	db 'Numero de palavras validas: $'
msg3		db CR,LF,'Digite o nome do arquivo com texto cifrado:',CR,LF,'$'
msg4		db 'Numero de frases validas: $'
dados     ends

; SEGMENTO DE PILHA DO PROGRAMA
pilha    segment stack ; permite inicializacao automatica de SS:SP
         dw     128 dup(?)
pilha    ends
         
; SEGMENTO DE CÓDIGO DO PROGRAMA
codigo   segment
inicio:         ; CS e IP sao inicializados com este endereco
        mov	    ax,dados           ; inicializa DS
        mov 	ds,ax              ; com endereco do segmento DADOS
        mov    	es,ax              ; idem em ES
; fim da carga inicial dos registradores de segmento

; fopen: abre um arquivo, nao retorna mensagem de erro,
; o nome do arquivo deve estar correto.
; - Chamada da função:
; 	lea dx,<str_nome_arq>
; 	call fopen
;	mov <handler>,ax
fopen	proc
        mov    ah,3dh
        mov    al,0
        int 	21h
        ret
		endp
; fclose: fecha um arquivo previamente aberto
; - Chamada da função:
;	mov bx,<handler>
;	call fclose
fclose	proc
		mov ah,3eh	 ; fecha arquivo
        int 21h
		ret
		endp
		
codigo  ends
        end    inicio