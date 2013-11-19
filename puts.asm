		assume cs:codigo,ds:dados,es:dados,ss:pilha
		
		
dados  	 segment

mensagem: db 'Hello world!','$'

dados    ends

pilha    segment stack ; permite inicializacao automatica de SS:SP
         dw     128 dup(?)
pilha    ends

codigo   segment
inicio:
        mov    ax,dados
        mov    ds,ax
		mov    es,ax
		
		lea		dx,mensagem
		call	puts

fim:
        mov    ax,4c00h
        int    21h
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
		 