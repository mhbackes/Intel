         assume cs:codigo,ds:dados,es:dados,ss:pilha

CR        EQU    0DH ; caractere ASCII "Carriage Return" 
LF        EQU    0AH ; caractere ASCII "Line Feed"

; SEGMENTO DE DADOS DO PROGRAMA
dados     segment
buffer1   db 100 dup (?)
buffer2	  db 100 dup (?)
tam_str1  dw 0
tam_str2  dw 0
nome      db 'texto.txt',0

handler   dw ?
erro	  db 'nao deu pra abrir$'
tamanho	  dw 0

sim		  db 'sim$'
nao		  db 'nao$'
dados     ends

; SEGMENTO DE PILHA DO PROGRAMA
pilha    segment stack ; permite inicializacao automatica de SS:SP
         dw     128 dup(?)
pilha    ends
         
; SEGMENTO DE CÓDIGO DO PROGRAMA
codigo   segment
inicio:         ; CS e IP sao inicializados com este endereco
         mov    ax,dados           ; inicializa DS
         mov    ds,ax              ; com endereco do segmento DADOS
         mov    es,ax              ; idem em ES
; fim da carga inicial dos registradores de segmento
		lea		dx,nome
		call	fopen
		mov		handler,ax
		
		mov		bx,handler
		lea		di,buffer1
		call 	fgets
		mov		tam_str1,ax
		
		mov		bx,handler
		lea		di,buffer2
		call 	fgets
		mov		tam_str2,ax
		
		lea		ax,buffer1
		lea		bx,buffer2
		mov		cx,tam_str1
		mov		dx,tam_str2
		call	contem?
		jnc		n
s:
		lea		dx,sim
		call	puts
		mov    ax,4c00h ; funcao retornar ao DOS no AH
                         ; codigo de retorno 0 no AL
         int    21h      ; chamada do DOS
n:		lea		dx,nao
		call	puts
		 mov    ax,4c00h ; funcao retornar ao DOS no AH
                         ; codigo de retorno 0 no AL
         int    21h      ; chamada do DOS
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
; fgets: lê uma linha válida do arquivo
; - Chamada da função:
;	mov bx,<handler>
;	lea di,<buffer>
;	call fgets
;	mov <var_tamanho>,ax
fgets 	proc
fgets_pre_laco:
		mov		tamanho,0
fgets_laco:   mov 	ah,3fh      ; le um caracter do arquivo
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
		mov 	byte ptr [di],0
		mov 	ax,tamanho
		clc
		ret
fgets_EOF:
		mov 	byte ptr [di],0
		mov 	ax,tamanho
		stc
		ret
		endp
; printf2: Imprime um valor de 2 dígitos na tela
; -Chamada da função:
; mov ax,<número>
; call printf
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