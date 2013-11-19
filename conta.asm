         assume cs:codigo,ds:dados,es:dados,ss:pilha

CR        EQU    0DH ; caractere ASCII "Carriage Return" 
LF        EQU    0AH ; caractere ASCII "Line Feed"

; SEGMENTO DE DADOS DO PROGRAMA
dados     segment
nome      db 'texto.txt',0
buffer    db 128 dup (?)
buffer_ptr dw ?
handler   dw ?
erro	  db 'nao deu pra abrir$'
tamanho	  dw 0
n_linhas  dw 0
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
		 lea    dx,nome
		 call   conta_l
		 jc		fim
		 mov    ax,n_linhas
		 call   printf
fim:	 mov    ax,4c00h ; funcao retornar ao DOS no AH
                         ; codigo de retorno 0 no AL
         int    21h      ; chamada do DOS
; conta_l: abre o arquivo, conta quantas linhas tem mais que 5 caracteres e
; armazena em n_linhas, depois fecha o arquivo. Se não encontrar o arquivo
; imprime mensagem de erro na tela.
; - Chamada da função:
;	lea dx,<string_nome_arq>
;	call conta_l
conta_l 	proc
; abre arquivo para leitura 
        mov    ah,3dh
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
; printf: Imprime um valor de 2 dígitos na tela
; - Chamada da função:
;   mov ax,<número>
;   call printf
printf	proc
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
codigo   ends
         end    inicio
		 
		 