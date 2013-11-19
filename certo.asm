;
; Exerc�cio 2:
; Este programa e' formado por duas partes distintas. A primeira delas contem
; instrucoes isoladas, que nunca sao executadas, mas estao com erros de sintaxe.
; A segunda parte pode ser executada quando o programa for montado sem erros, 
; mas tem erro(s) de logica.
; Sua missao e' eliminar todos os erros de sintaxe e depois ligar e executar o
; programa. Quando executado corretamente, ele devera' escrever na tela as
; mensagens mostradas abaixo, na mesma ordem em que aparecem aqui. Se produzir
; um resultado diferente, procure e corrija o(s) erro(s) de logica. 
; Boa diversao !!!
;
; Saida esperada (apenas duas linhas):
; Um, dois, tres, quatro, cinco, seis, sete, oito, nove e dez.
; O programa terminou corretamente !
;
         assume cs:codigo,ds:dados,es:dados,ss:pilha

CR       EQU    0DH ; constante - codigo ASCII do caractere "carriage return"
LF       EQU    0AH ; constante - codigo ASCII do caractere "line feed"

; definicao do segmento de dados do programa
dados    segment
um       db     'Um, ','$'
dois     db     'dois, ','$'
tres     db     'tres, ','$'
quatro   db     'quatro, ','$'
cinco    db     'cinco, ','$'
seis     db     'seis, ','$'
seven    db     'sete, ','$'
oito     db     'oito, ','$'
nove     db     'nove e ','$'
dez      db     'dez. ',CR,LF,'$'
mensafim db     'O programa terminou corretamente !',CR,LF,'$'
vetptrs  dw     offset um
         dw     offset dois
         dw     offset tres
         dw     offset quatro
         dw     offset cinco
         dw     offset seis
         dw     offset seven
         dw     offset oito
         dw     offset nove
         dw     offset dez
baite    db     0
palavra  dw     0
pdupla   dd     0
pquadr   dq     0
dados    ends

; definicao do segmento de pilha do programa
pilha    segment stack ; permite inicializacao automatica de SS:SP
         dw     128 dup(?)
pilha    ends
         
; definicao do segmento de codigo do programa
codigo   segment
inicio:  ; CS e IP sao inicializados com este endereco
         mov    ax,dados ; inicializa DS
         mov    ds,ax    ; com endereco do segmento DADOS
         mov    es,ax    ; idem em ES
; fim da carga inicial dos registradores de segmento

; a partir daqui, as instrucoes especificas para cada programa
         jmp    logica   ; evita executar as instrucoes usadas
                         ; apenas para provocar erros de sintaxe
sintaxe:
; Para analisar os erros, analise o arquivo ERRADO.LST gerado pelo TASM.
; Para eliminar os erros, MUDE apenas UM dos operandos de cada instrucao.
; Nao se preocupe com a operacao que a instrucao executara, pois estas
; instrucoes nunca sao executadas neste programa.
; Se uma instrucao n�o for compativel com 8086, transforme-a em comentario.
;
         lea    dx,logica
         mov    dx,offset logica
;
         mov    ah,baite
         mov    ax,palavra
         push   word ptr baite
         pop    ax
         ;add    palavra,palavra
		 mov	ax, palavra
		 add	palavra,ax
		 
         ;xor    ds,ds
		 mov	ax, ds
		 xor	ax,ax
		 mov	ds,ax
		 
         ;mov    ip,0FFF0H
		 mov	bp, 0fff0h
		 jmp	[bp]
		 
         and    si,0ABCDH
         jnae   continua
         add    cl,30
         xlat   ; al
continua:
         add    cl,30
         sub    dl,30
.386
         mul    pdupla
         ;idiv   pquadr   
.8086		 
         loop continua
         ;in     al,300
		 mov 	dx, 300
		 in		al, dx
         ;out    2,bx
		 mov	ax,bx
		 out	2,ax
.386		 
         rcr    ax,10
.8086
         rcr    ax,1
;         shl    es,1
		 mov ax, es
		 shl ax,1
		 mov es,ax
		 
         sar    ax,cl
         rcl    ax,15
         test    baite,0AAH
.386
         movsx  ax,baite
         movzx  dx,baite
.8086
         cbw    ; bl
         xchg   ax,cx
.386
         pusha
         popa
.8086
         nop
         hlt
;
logica:
         mov    cx,10
         lea    si,vetptrs
repetir:
         mov    dx,[si]
         inc    si
		 inc    si
         call   escreve
         loop   repetir

         call   terminar

; retorno ao DOS com codigo de retorno 0 no AL (fim normal)
         mov    ax,4c00h           ; funcao retornar ao DOS no AH
         int    21h                ; chamada do DOS

escreve  proc
         mov    ah,9               ; funcao exibir mensagem no AH
         int    21h                ; chamada do DOS
		 ret
escreve  endp

terminar proc
         lea    dx,mensafim        ; endereco da mensagem em DX
         mov    ah,9               ; funcao exibir mensagem no AH
         int    21h                ; chamada do DOS
         ret
terminar endp

codigo   ends

; a diretiva a seguir indica o fim do codigo fonte (ultima linha do arquivo)
; e informa que o programa deve come�ar a execucao no rotulo "inicio"
         end    inicio 

