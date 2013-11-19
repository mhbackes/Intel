         assume cs:codigo,ds:dados,es:dados,ss:pilha

CR        EQU    0DH ; caractere ASCII "Carriage Return" 
LF        EQU    0AH ; caractere ASCII "Line Feed"
BS		  EQU	 08H ; caractere ASCII "Backspace"

; SEGMENTO DE DADOS DO PROGRAMA
dados     segment
buffer    	db 128 dup (?)
Y			db 61 dup (?)
X			db 61 dup (?)
a			dw 1
b			dw 0
i			dw 0
j			dw 0
k			dw 0
nome_dic  	db 100 dup (?)
nome_cif	db 100 dup (?)
dicionario	db 31000 dup(?)

dic_ptr	dw ?
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
		lea		dx,msg0
		call 	puts				; imprime nome do aluno
		
		lea 	dx,msg1
		call 	puts				; pede que o usuario digite o nome do arquivo dicionario
		
		lea		di,nome_dic
		call	scanf				; "scanf" do nome do arquivo
		
		lea 	dx,nome_dic
		lea		di,dicionario
		call	le_arquivo			; armazena as palavras do dicionario em dicionario
		jnc		abriu_dic			; conta quantas palavras
		jmp		fim
abriu_dic:
		mov		tam_arq_dic,ax
		lea		dx,msg2
		call	puts
		mov		ax,tam_arq_dic
		call	printf4				; imprime o numero de linhas validas
		
		lea 	dx,msg3
		call 	puts				; pede que digite o nome do arquivo com texto cifrado
		
		lea		di,nome_cif
		call	scanf				; "scanf" do nome do arquivo
		
		lea 	dx,nome_cif
		call	conta_l				; conta numero de linhas validas
		jnc		abriu_cif			; se houve erro encerra o programa
		jmp		fim
abriu_cif:							
		lea		dx,msg4
		call	puts		
		mov		ax,n_linhas
		mov		tam_arq_cif,ax
		call	printf2				; imprime o numero de frases validas
		lea		dx,barra_n
		call	puts
		
		lea		dx,nome_cif			; abre o arquivo cifrado
		call	fopen
		mov		handler_cif,ax
		
		mov		ax,tam_arq_cif		; usa j como contador,
		mov		j,ax				; conta quantas linhas do arquivo serao lidas
laco1:
		cmp		j,0					; testa se o arquivo cifrado acabou
		jnz		arq_cif_nao_terminou
		jmp		fecha_cif
arq_cif_nao_terminou:		
		mov		bx,handler_cif		; le linha do arquivo cifrado
		lea		di,Y				; e armazena em Y
		call	fgets
		mov		tamanho_cif,ax
		
		sub		j,1					; decrementa j
		
		mov		a,1					;a=1,b=0
		mov		b,0
		mov		achou,0				; flag achou=0
laco2:
		call	decodifica			; decodifica Y e armazena em X

		mov		ax,tam_arq_dic		; usa k como contador.
		mov		k,ax				; conta quantas linhas do arquivo serao lidas
		
		lea		ax,dicionario		; ponteiro aponta para o inicio do dicionario
		mov		dic_ptr,ax
laco3:
		cmp		k,0					; se nao houver mais palavras
		jnz		arq_dic_nao_terminou
		jmp		incrementa_a_b		; vai para incrementa a b e testa nova decifragem
arq_dic_nao_terminou:
		mov		si,dic_ptr			; le linha do arquivo dicionario
		lea		di,buffer			; e armazena em buffer
		call	prox_dic
		mov		tamanho_dic,ax
		mov		dic_ptr,si
		
		sub		k,1					; decrementa k
		
		lea		ax,buffer			; testa se a palavra do dicionario
		lea		bx,X				; esta contida na frase cifrada
		mov		cx,tamanho_dic
		mov		dx,tamanho_cif
		call	contem?
		jnc		laco3
contem:
		lea		dx,decifrado_a		; Imprime na tela:
		call	puts				; a=xx b=xx <texto decifrado>
		mov		ax,a
		call	printf2
		lea		dx,decifrado_b
		call	puts
		mov		ax,b
		call	printf2
		lea		dx,espaco
		call 	puts
		lea		dx,X
		call	puts
		lea		dx,barra_n
		call	puts
		
		jmp		laco1
incrementa_a_b:
		inc		b					; incrementa a e b
		cmp		b,26				; para testar nova decifragem
		je		b_eh_vinte_seis
		jmp		laco2
b_eh_vinte_seis:
		mov		b,0
		add		a,2
		cmp		a,27
		je		achou?_nao
		cmp		a,13
		je		eh_treze
		jmp		laco2
eh_treze:
		add		a,2
		jmp		laco2

achou?_nao:
		lea		dx,nao_achou		; imprime nao encontrado: <texto decifrado>
		call	puts				; se o programa nao encontrou decifragem
		lea		dx,Y
		call	puts
		lea		dx,barra_n
		call	puts
		jmp		laco1
		
fecha_cif:
		mov		bx,handler_cif		; fecha arquivo cifrado
		call	fclose
fim:
		mov    	ax,4c00h ; funcao retornar ao DOS no AH
                         ; codigo de retorno 0 no AL
        int    	21h      ; chamada do DOS


; puts: função que imprime uma string na tela até encontrar '$'
; - Chamada da função:
; 	lea dx,<end_inic_string>
; 	call puts
puts	proc		 
		mov 	ah,9
		int 	21H
		ret
		endp
; scanf: lê caracteres do teclado e os imprime na tela, 
; scanf_backspace apaga o último caractere lido e enter armazena-os
; em uma string, retorna em bl o número de caracteres lido.
; - Chamada da função:
;		lea dx,<string>
;		call scanf	
scanf	proc
		mov bl,0 ;conta quantos caracteres foram lidos
scanf_entrada: mov    ah,1
        int    	21h	; le um caracter com eco
        cmp    	al,CR   ; compara com carriage return
        je     	scanf_continua
		cmp		al,BS
		je		scanf_backspace
        mov    	[di],al ; coloca no buffer
        inc    	di
		inc 	bl
        jmp    	scanf_entrada
scanf_backspace:
		cmp		bl,0
		je		scanf_entrada
		dec		bl
		dec		di
		mov		ah,2
		mov		dl,' '
		int 	21H
		mov		dl,BS
		int		21H
		jmp		scanf_entrada
scanf_continua: 
		mov   byte ptr [di],0
		ret
		endp
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
; conta_l: abre o arquivo, conta quantas linhas tem mais caracteres e
; armazena em n_linhas, depois fecha o arquivo. Se não encontrar o arquivo
; imprime mensagem de erro na tela.
; - Chamada da função:
;	lea dx,<string_nome_arq>
;	call conta_l
conta_l proc
        mov    ah,3dh ; abre arquivo para leitura 
        mov    al,0
        int 	21h
        jnc    conta_l_abriu_ok
        lea    dx,erro
        mov    ah,9
        int    21h
		stc
        ret
conta_l_abriu_ok: 
		mov 	handler,ax
		mov 	n_linhas,0
conta_l_pre_conta_l_laco:
		mov 	tamanho,0
conta_l_laco:    mov ah,3fh      ; le um caracter do arquivo
        mov 	bx,handler
        mov 	cx,1
		lea 	dx,buffer
        int 	21h
        cmp 	ax,cx
        jne 	conta_l_EOF
conta_l_teste_cslf:      
        mov 	dl,buffer
        cmp 	dl, CR
        je  	conta_l_laco
		cmp 	dl, LF
		je  	conta_l_cslf
conta_l_nao_eh_cslf:
		add 	tamanho,1
		jmp 	conta_l_laco
conta_l_cslf:
		cmp 	tamanho,5
		jl  	conta_l_pre_conta_l_laco
		add		n_linhas,1
		jmp 	conta_l_pre_conta_l_laco
conta_l_EOF:
		cmp 	tamanho,5
		jl  	conta_l_fim
		add 	n_linhas,1
conta_l_fim:
		mov ah,3eh	 ; fecha arquivo
		mov bx,handler
        int 21h
		clc
		ret
		endp
; printf2: Imprime um valor de 2 dígitos na tela
; - Chamada da função:
; 	mov ax,<número>
; 	call printf
printf2	proc
		mov bl,10
		div bl
		add al,'0'
		mov dl,al
		push ax
		mov ah,2
		int 21H
		pop ax
		add ah,'0'
		mov dl,ah
		mov ah,2
		int 21H
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
; fseek_ini: muda a posição do arquivo para o inicio
; - Chamada da função:
;	mov	bx,<handler>
;	call fseek_ini
fseek_ini proc
		mov		ah,42H
		mov		al,0
		mov		cx,0
		mov		dx,0
		int		21H
		ret
		endp
; fgets: lê uma linha válida do arquivo
; - Chamada da função:
;	mov bx,<handler>
;	lea di,<buffer>
;	call fgets
;	mov <var_tamanho>,ax
fgets 	proc
fgets_pre_laco:
		mov		tamanho,0
fgets_laco:   
		mov 	ah,3fh      ; le um caracter do arquivo
        mov 	cx,1
		mov 	dx,di
        int 	21h
		mov 	di,dx
        cmp 	ax,cx
        jne 	fgets_EOF
fgets_teste_enter:         
        mov 	dl,[di]
        cmp 	dl, CR
        je  	fgets_laco
		cmp 	dl, LF
		je  	fgets_enter
fgets_teste_minuscula:
		cmp 	dl,'a'
		jl  	fgets_incrementa
		cmp 	dl,'z'
		jg  	fgets_incrementa
fgets_minuscula:
		sub 	dl,32
		mov 	byte ptr [di],dl
fgets_incrementa:
		add		tamanho,1
		inc		di
		jmp 	fgets_laco
fgets_enter:
		cmp		tamanho,5
		jge		fim_enter
		sub		di,tamanho
		jmp		fgets_pre_laco
fim_enter:
		mov 	byte ptr [di],'$'
		mov 	ax,tamanho
		clc
		ret
fgets_EOF:
		mov 	byte ptr [di],'$'
		mov 	ax,tamanho
		stc
		ret
		endp
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
		cmp		al,'$'
		je		decodifica_fim
		sub		al,65
		sub		ax,b
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
; contem?: testa se uma string é substring de outra
; retorna cf=1 se sim ou cf=0 se não
; - Chamada da função:
;	lea ax,<substring>
;	lea bx,<string>
;	mov cx,<tam_substring>
;	mov dx,<tam_string>
;	call contem?
contem?	proc
contem?_laco:
		mov		si,ax
		mov		di,bx
		cmp		cx,dx
		jg		contem?_nao
		push	cx
		repe cmpsb
		cmp		cx,0
		je		contem?_talvez
		pop		cx
contem?_incrementa:
		inc		bx
		dec		dx
		jmp		contem?_laco
contem?_talvez:
		pop		cx
		dec		di
		dec		si
		cmpsb
		jne		contem?_incrementa
contem?_sim:
		stc
		ret
contem?_nao:
		clc
		ret
		endp
codigo  ends
        end    inicio