		assume cs:codigo,ds:dados,es:dados,ss:pilha
		
		
dados    segment
a		 dw		57
dados    ends

pilha    segment stack ; permite inicializacao automatica de SS:SP
         dw     128 dup(?)
pilha    ends

codigo   segment
inicio:
        mov    ax,dados
        mov    ds,ax
		mov    es,ax
		
		mov 	ax,a
		call printf2
fim:
        mov    ax,4c00h
        int    21h
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
		
codigo   ends

         end    inicio 