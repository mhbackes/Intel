         assume cs:codigo,ds:dados,es:dados,ss:pilha

CR        EQU    0DH ; caractere ASCII "Carriage Return" 
LF        EQU    0AH ; caractere ASCII "Line Feed"
BS		  EQU	 08H ; caractere ASCII "Backspace"

; SEGMENTO DE DADOS DO PROGRAMA
dados     segment
buffer		db 31  dup (?)
dicionario 	db 31000 dup (?)
Y			db 61 dup (?)
X			db 61 dup (?)
a			dw 1
b			dw 0
i			dw 0
j			dw 0
k			dw 0
nome_dic  	db 100 dup (?)
nome_cif	db 100 dup (?)


arquivo		db 'texto.txt',0
ptr_dic		dw ?
buffer_ptr	dw ?
handler   	dw ?
handler_dic	dw ?
handler_cif	dw ?
tam_arq_dic	dw ?
tam_arq_cif dw ?
erro	  	db 'ERRO: O arquivo nao foi encontrado',CR,LF,'$'
tamanho	  	dw 0
tamanho_cif dw 0
tamanho_dic dw 0
tabela		db 0,1,0,9,0,21,0,15,0,3,0,19,0,0,0,7,0,23,0,11,0,5,0,17,0,25
n_linhas  	dw 0
achou		dw 0
msg0	  	db 'Marcos Henrique Backes - 00228483',CR,LF,CR,LF,'$'
msg1	  	db 'Digite o nome do arquivo de dicionario:',CR,LF,'$'
msg2	  	db 'Arquivo aberto com sucesso.',CR,LF,'Numero de palavras validas: $'
msg3		db CR,LF,'Digite o nome do arquivo com texto cifrado:',CR,LF,'$'
msg4		db 'Arquivo aberto com sucesso',CR,LF,'Numero de frases validas: $'
decifrado_a	db 'a=$'
decifrado_b	db ' b=$'
espaco		db ' $'
barra_n		db CR,LF,'$'
nao_achou	db 'Nao encontrado: $'
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
		lea		dx,arquivo
		lea		di,dicionario
		call    le_arquivo
		call	printf4
		lea		ax,dicionario
		mov		ptr_dic,ax
		mov		si,ptr_dic
		lea		di,buffer
		call	prox_dic
		mov		ptr_dic,si
		call	printf4
		lea		dx,buffer
		call	puts
		mov		si,ptr_dic
		lea		di,buffer
		call	prox_dic
		call	printf4
		lea		dx,buffer
		call	puts
		fim:	 mov    ax,4c00h ; funcao retornar ao DOS no AH
                         ; codigo de retorno 0 no AL
         int    21h      ; chamada do DOS
		
; le_arquivo: le as linhas do arquivo que tem mais do que 5
; caracteres e as armazena em uma string, separando as linhas por
; um cifrao.
; - Chamada da função:
; lea dx,<nome_arq>
; lea di,<string>
; mov <n_linhas>,ax
le_arquivo proc
; abre arquivo para leitura 
        mov    ah,3dh
        mov    al,0
        int 	21h
        jnc    le_arquivo_abriu_ok
        lea    dx,erro
        mov    ah,9
        int    21h
		stc
        ret
le_arquivo_abriu_ok: 
		mov 	bx,ax
		mov 	n_linhas,0
le_arquivo_pre_laco:
		mov 	tamanho,0
le_arquivo_laco:   
		mov 	ah,3fh      ; le um caracter do arquivo
        mov 	cx,1
		mov 	dx,di
        int 	21h
		mov 	di,dx
        cmp 	ax,cx
        jne 	le_arquivo_EOF
le_arquivo_teste_enter:         
        mov 	dl,[di]
        cmp 	dl, CR
        je  	le_arquivo_laco
		cmp 	dl, LF
		je  	le_arquivo_enter
le_arquivo_teste_minuscula:
		cmp 	dl,'a'
		jl  	le_arquivo_incrementa
		cmp 	dl,'z'
		jg  	le_arquivo_incrementa
le_arquivo_minuscula:
		sub 	dl,32
		mov 	byte ptr [di],dl
le_arquivo_incrementa:
		add		tamanho,1
		inc		di
		jmp 	le_arquivo_laco
le_arquivo_enter:
		cmp		tamanho,5
		jge		le_arquivo_fim_linha
		sub		di,tamanho
		jmp		le_arquivo_pre_laco
le_arquivo_fim_linha:
		mov 	byte ptr [di],'$'
		inc		di
		add		n_linhas,1
		jmp		le_arquivo_pre_laco
le_arquivo_EOF:
		mov 	byte ptr [di],'$'
		cmp		tamanho,5
		jl		le_arquivo_fecha
		add		n_linhas,1
le_arquivo_fecha:
		mov ah,3eh	 ; fecha arquivo
        int 21h
		mov		ax,n_linhas
		ret
		clc
		ret
		endp
; prox_dic: armazena a proxima palavra do dicionario em uma string
; - Chamada da função
;	lea si,origem
;	lea di,destino
;	call prox_dic
;	mov	<tam_palavra>,ax
;	mov	<ptr_dic>,si
prox_dic proc
	xchg	di,si
	mov		cx,31
	mov		al,'$'
	cld
	repne scasb
	mov		ax,31
	sub		ax,cx
	mov		cx,ax
	sub		di,ax
	xchg	di,si
	rep	movsb
	dec		ax
	ret
	endp
; puts: função que imprime uma string na tela até encontrar '$'
; - Chamada da função:
; 	lea dx,<end_inic_string>
; 	call puts
puts	proc		 
		mov 	ah,9
		int 	21H
		ret
		endp
; printf4: Imprime um valor de 4 dígitos na tela
; -Chamada da função:
; mov ax,<número>
; call printf
printf4	proc
		mov 	dx,0
		mov 	bx,1000
		div 	bx
		push	dx
		mov 	dl,al
		add 	dl,'0'
		mov 	ah,2
		int 	21H
		pop 	ax
		mov		bl,100
		div		bl
		push 	ax
		mov 	dl,al
		add 	dl,'0'
		mov		ax,dx
		mov 	ah,2
		int 	21H
		pop 	ax
		mov		al,ah
		mov		ah,0
		mov		bl,10
		div 	bl
		add 	al,'0'
		mov 	dl,al
		push 	ax
		mov 	ah,2
		int 	21H
		pop 	ax
		add 	ah,'0'
		mov 	dl,ah
		mov 	ah,2
		int 	21H
		ret
		endp
codigo   ends
         end    inicio