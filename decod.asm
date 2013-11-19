         assume cs:codigo,ds:dados,es:dados,ss:pilha

CR        EQU    0DH ; caractere ASCII "Carriage Return" 
LF        EQU    0AH ; caractere ASCII "Line Feed"
BS		  EQU	 08H ; caractere ASCII "Backspace"

; SEGMENTO DE DADOS DO PROGRAMA
dados     segment
Y			db 'INFORMATICA',0
X			db 30 dup (?)
a			dw 9
b			db 5
i			dw 0
tabela		db 0,1,0,9,0,21,0,15,0,3,0,19,0,0,0,7,0,23,0,11,0,5,0,17,0,25
tabela_ptr	dw offset tabela
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
msg2	  	db 'Arquivo aberto com sucesso.',CR,LF,'Numero de palavras validas: $'
msg3		db CR,LF,'Digite o nome do arquivo com texto cifrado:',CR,LF,'$'
msg4		db 'Arquivo aberto com sucesso',CR,LF,'Numero de frases validas: $'
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
		call 	decodifica
		lea		dx,X
		call	puts
		mov    	ax,4c00h ; funcao retornar ao DOS no AH
                         ; codigo de retorno 0 no AL
        int    	21h      ; chamada do DOS



; decodifica: decodifica a string Y usando a cifra de affine, os valores das chaves
; a e b, tabela, e armazena em X
; - Chamada da função
;	call	decodifica
decodifica 	proc
		mov		i,0
		lea		di,X
decodifica_laco:	
		mov		ah,0
		lea		si,Y
		mov		bx,i
		mov		al,byte ptr [bx+si+0] ; al := Y[i]
		cmp		al,0
		je		decodifica_fim
		sub		al,65
		sub		al,b
		jns		decodifica_positivo
decodifica_negativo:
		add		al,26		; se Y[i] - b é negativo, adiciona 26 para facilitar a multiplicação
decodifica_positivo:
		lea     si,tabela
		mov		bx,a
		mov		bl,byte ptr [bx+si+0] ; bx := tabela[a], mesmo que bx := a^(-1)
		mul		bl
		mov		bl,26
		div		bl
		add		ah,65
		mov		bx,i
		mov		byte ptr [bx+di+0],ah ; X[i] := ah
		add		i,1
		jmp		decodifica_laco
decodifica_fim:
		mov		byte ptr [bx+di+0],'$' ; X[i] := '$'
		ret
		endp
; puts: função que imprime uma string na tela até encontrar '$'
; - Chamada da função:
; lea dx,<end_inic_string>
; call puts
puts	proc		 
		mov 	ah,9
		int 	21H
		ret
		endp		
codigo   ends
         end    inicio		
		
		
		
		
		
		