;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      DEZEMBRO DE 2023                           *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David Jos� de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI��ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADR�O MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINA��O DE MEM�RIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINI��O DE COMANDOS DE USU�RIO PARA ALTERA��O DA P�GINA DE MEM�RIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEM�RIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MEM�RIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARI�VEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DOS NOMES E ENDERE�OS DE TODAS AS VARI�VEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDERE�O INICIAL DA MEM�RIA DE
					;USU�RIO
		W_TEMP		;REGISTRADORES TEMPOR�RIOS PARA USO
		STATUS_TEMP	;JUNTO �S INTERRUP��ES

		INT_SELECT ; SELECIONA A ROTINA DE INTERRUP��O CORRETA
		CONTADOR ; CONTADOR DE OVERFLOWS DO TMR0
		AUX ; AUXILIAR PARA TROCA DE VAL0RES

	ENDC			;FIM DO BLOCO DE DEFINI��O DE VARI�VEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA7
#DEFINE TMR0_25MS .61 ; CONSTANTE DE REINICIALIZA��O DO TMR0 PARA CONTAR 25ms COM PRESCALE 1:128
#DEFINE LIMITE0 .79 ; LIMITE DE CONTAGEM DE OVERFLOWS PARA A INTERRUP��O 0
#DEFINE LIMITE1 .19 ; LIMITE DE CONTAGEM DE OVERFLOWS PARA A INTERRUP��O 1

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SA�DAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

; AS PORTAS GP0 E GP1 DEVEM SER USADAS PARA MAIS DE UM LED
#DEFINE VERMELHO1 GP0
#DEFINE VERDE2 GP0
#DEFINE VERMELHO2 GP1
#DEFINE VERDE1 GP1
#DEFINE AMARELO1 GP2
#DEFINE AMARELO2 GP4

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDERE�O INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    IN�CIO DA INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDERE�O DE DESVIO DAS INTERRUP��ES. A PRIMEIRA TAREFA � SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERA��O FUTURA

	ORG	0x04		;ENDERE�O INICIAL DA INTERRUP��O
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP
	
	; INT_SELECT = 0 -> AMARELOS DESATIVADOS
	; INT_SELECT = 1 -> AMARELOS ATIVADOS
	MOVLW	.1
	SUBWF	INT_SELECT, W ; INT_SELECT - 1
	BTFSC	STATUS, Z ; SE Z=0, ENT�O INT_SELECT=0, OU SEJA, PULAR ESSE GOTO
	GOTO	AMARELOS_ATIVADOS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SER�O ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUP��ES
	
; INT_SELECT = 0
AMARELOS_DESATIVADOS
	; CONTA 25ms * 80 = 2s
	MOVLW LIMITE0 ; LIMITE DE OVERFLOWS PRO TMR0
	SUBWF CONTADOR, W ; CONTADOR - 80
	BTFSC STATUS, Z ; SE Z=0, CONTADOR != 80, ENT�O PULAR GOTO (EXECUTAR NORMALMENTE)
	GOTO ATIVAR_AMARELO

	; CONTAR OVERFLOW
	INCF CONTADOR, F ; INCREMENTANDO CONTADOR DE OVERFLOWS
	BCF INTCON, T0IF ; LIMPANDO FLAG DE OVERFLOW DO TMR0
	GOTO SAI_INT ; ENCERRANDO INTERRUP��O
	
	ATIVAR_AMARELO
	    MOVLW .1
	    MOVWF INT_SELECT ; MUDANDO PARA OUTRA INTERRUP��O
	    MOVLW .0
	    MOVWF CONTADOR
	    BCF INTCON, T0IF
	    BTFSC GPIO, GP0 ; SE VERDE2 ACESO, ACENDER AMARELO2
	    GOTO ATIVAR_AMAR2
	    
	    ;------ COLOCAR BREAKPOINT PARA TESTE AQUI ------
	    BSF GPIO, AMARELO1 ; ACENDENDO AMARELO1
	    GOTO SAI_INT
	    
	    ATIVAR_AMAR2
		;------ COLOCAR BREAKPOINT PARA TESTE AQUI ------
		BSF GPIO, AMARELO2 ; ACENDENDO AMARELO2
		GOTO SAI_INT

; INT_SELECT = 1
AMARELOS_ATIVADOS
	; CONTA 25ms * 20 = 0.5s
	MOVLW LIMITE1 ; LIMITE DE OVERFLOWS PRO TMR0
	SUBWF CONTADOR, W ; CONTADOR - 20
	BTFSC STATUS, Z ; SE Z=1, CONTADOR=20, ENT�O TROCAR VERDE E VERMELHO
	GOTO TROCAR_VERDE_VERMELHO
	
	; CONTAR OVERFLOW
	INCF CONTADOR, F ; INCREMENTANDO CONTADOR DE OVERFLOWS
	BCF INTCON, T0IF ; LIMPANDO FLAG DE OVERFLOW DO TMR0
	GOTO SAI_INT
	
	; TROCAR SINAIS ENTRE VERDES E VERMELHOS
	TROCAR_VERDE_VERMELHO
	    ;------ COLOCAR BREAKPOINT PARA TESTE AQUI ------
	    MOVLW .0
	    MOVWF INT_SELECT ; MUDANDO PARA OUTRA INTERRUP��O
	    MOVWF CONTADOR ; ZERANDO CONTADOR
	    BCF INTCON, T0IF ; LIMPANDO FLAG DE OVERFLOW

	    ; APAGANDO AMARELOS
	    BCF GPIO, GP2
	    BCF GPIO, GP4

	    ; TROCANDO OS SINAIS DE GP0 (VERMELHO1 E VERDE2) E GP1 (VERMELHO2 E VERDE1)
	    MOVFW GPIO
	    ANDLW B'00000001' ; OBTENDO GP0 (VERDE2)
	    MOVWF AUX ; AUX <- VERDE2
	    BCF STATUS, C ; LIMPANDO FLAG DO CARRY PRA N�O ALTERAR AS ROTA��ES A SEGUIR
	    RLF AUX ; INVERTENDO AS POSI��ES DOS BITS DE GP0 E GP1
	    RRF GPIO, W ; INVERTENDO AS POSI��ES DOS BITS DE GP0 E GP1
	    ANDLW B'00000001' ; OBTENDO GP1 (VERMELHO2)
	    MOVWF GPIO ; VERDE2 (GP0) <- VERMELHO2 (GP1)
	    MOVFW AUX
	    IORWF GPIO ; VERMELHO2 (GP1) <- AUX

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SA�DA DA INTERRUP��O                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUP��O

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	MOVLW	TMR0_25MS
	MOVWF	TMR0		; REINICIANDO TMR0 PARA CONTAR 25ms
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRI��O DE FUNCIONAMENTO
; E UM NOME COERENTE �S SUAS FUN��ES.
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	
	; VERMELHO1 <- VERDE2 <- GP0
	; VERMLEHO2 <- VERDE1 <- GP1
	; AMARELO1 <- GP2
	; AMARELO2 <- GP4
	MOVLW	B'00000000' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000110'	;PRESCALER 1:128
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'10100000'	;ATIVANDO INTERRUP��ES PELO TMR0
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	MOVLW TMR0_25MS
	MOVWF TMR0 ; SETANDO O TMR0 PARA CONTAR 25ms
	
	MOVLW .0
	MOVWF INT_SELECT ; SELECIONANDO INTERRUP��O DE AMARELO
	
	MOVWF CONTADOR ; ZERANDO O CONTADOR
	BSF GPIO, GP0 ; INICIANDO COM VERMELHO1 E VERDE2 ATIVADOS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN

	; TODAS AS ATIVA��ES DE LED S�O FEITAS POR INTERRUP��O,
	; PERMITINDO A EXECU��O DE OUTRAS TAREFAS NO MICROCONTROLADOR
	
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
