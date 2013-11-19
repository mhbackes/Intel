         assume cs:codigo,ds:dados,es:dados,ss:pilha

CR        EQU    0DH ; caractere ASCII "Carriage Return" 
LF        EQU    0AH ; caractere ASCII "Line Feed"

; SEGMENTO DE DADOS DO PROGRAMA
dados     segment
nome      db 'cifrados.txt',0
buffer    db 30 dup (?)
handler   dw ?
erro	  db 'nao deu pra abrir$'
tamanho	  dw 0
tam_str	  dw 0
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
		lea		di,buffer
		call 	fgets
		mov		tam_str,ax
		lea  	dx,buffer
		call 	puts
		
		mov		bx,handler
		lea		di,buffer
		call 	fgets
		mov		tam_str,ax
		lea  	dx,buffer
		call 	puts
		
		 mov    ax,4c00h ; funcao retornar ao DOS no AH
                         ; codigo de retorno 0 no AL
         int    21h      ; chamada do DOS
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
		
		
		
		
		
puts	proc		 
		mov 	ah,9
		int 	21H
		ret
		endp		

codigo   ends
         end    inicio
		 
		 