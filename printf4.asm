		assume cs:codigo,ds:dados,es:dados,ss:pilha
		
		
dados    segment
a		 dw		1957
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
		call printf4
fim:
        mov    ax,4c00h
        int    21h
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