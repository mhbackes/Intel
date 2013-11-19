		assume cs:codigo,ds:dados,es:dados,ss:pilha
CR        EQU    0DH ; caractere ASCII "Carriage Return" 
LF        EQU    0AH ; caractere ASCII "Line Feed"
BS		  EQU	 08H ; caractere ASCII "Backspace"
		
dados    segment

nome	db ?
dados    ends

pilha    segment stack
         dw     128 dup(?)
pilha    ends

codigo   segment
inicio:
        mov    ax,dados
        mov    ds,ax
		mov    es,ax
		
		lea    di, nome
		call 	scanf
		lea    dx, nome
		call 	puts
		mov    ax,4c00h
        int    21h
		
; scanf: lê caracteres do teclado e os imprime na tela, 
; scanf_backspace apaga o último caractere lido e enter armazena-os
; em uma string, retorna em bl o número de caracteres lido.
; - Chamada da função:
;		lea di,<string>
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
		mov   byte ptr [di],'$'  ; '$' ou 0
		ret
		endp
puts	proc		 
		mov 	ah,9
		int 	21H
		ret
		endp
		
		
		
		
		
		
		
codigo   ends

         end    inicio 