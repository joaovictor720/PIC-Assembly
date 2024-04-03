;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      DEZEMBRO DE 2023                           *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David José de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÇÃO DE MEMÓRIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINIÇÃO DE COMANDOS DE USUÁRIO PARA ALTERAÇÃO DA PÁGINA DE MEMÓRIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÓRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MEMÓRIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÁVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DOS NOMES E ENDEREÇOS DE TODAS AS VARIÁVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE
					;USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES

		INT_SELECT ; SELECIONA A ROTINA DE INTERRUPÇÃO CORRETA
		CONTADOR ; CONTADOR DE OVERFLOWS DO TMR0
		AUX ; AUXILIAR PARA TROCA DE VAL0RES

	ENDC			;FIM DO BLOCO DE DEFINIÇÃO DE VARIÁVEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA7
#DEFINE TMR0_25MS .61 ; CONSTANTE DE REINICIALIZAÇÃO DO TMR0 PARA CONTAR 25ms COM PRESCALE 1:128
#DEFINE LIMITE0 .79 ; LIMITE DE CONTAGEM DE OVERFLOWS PARA A INTERRUPÇÃO 0
#DEFINE LIMITE1 .19 ; LIMITE DE CONTAGEM DE OVERFLOWS PARA A INTERRUPÇÃO 1

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SAÍDAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO SAÍDA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

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

	ORG	0x00			;ENDEREÇO INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÍCIO DA INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDEREÇO DE DESVIO DAS INTERRUPÇÕES. A PRIMEIRA TAREFA É SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERAÇÃO FUTURA

	ORG	0x04		;ENDEREÇO INICIAL DA INTERRUPÇÃO
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP
	
	; INT_SELECT = 0 -> AMARELOS DESATIVADOS
	; INT_SELECT = 1 -> AMARELOS ATIVADOS
	MOVLW	.1
	SUBWF	INT_SELECT, W ; INT_SELECT - 1
	BTFSC	STATUS, Z ; SE Z=0, ENTÃO INT_SELECT=0, OU SEJA, PULAR ESSE GOTO
	GOTO	AMARELOS_ATIVADOS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SERÃO ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÇÕES
	
; INT_SELECT = 0
AMARELOS_DESATIVADOS
	; CONTA 25ms * 80 = 2s
	MOVLW LIMITE0 ; LIMITE DE OVERFLOWS PRO TMR0
	SUBWF CONTADOR, W ; CONTADOR - 80
	BTFSC STATUS, Z ; SE Z=0, CONTADOR != 80, ENTÃO PULAR GOTO (EXECUTAR NORMALMENTE)
	GOTO ATIVAR_AMARELO

	; CONTAR OVERFLOW
	INCF CONTADOR, F ; INCREMENTANDO CONTADOR DE OVERFLOWS
	BCF INTCON, T0IF ; LIMPANDO FLAG DE OVERFLOW DO TMR0
	GOTO SAI_INT ; ENCERRANDO INTERRUPÇÃO
	
	ATIVAR_AMARELO
	    MOVLW .1
	    MOVWF INT_SELECT ; MUDANDO PARA OUTRA INTERRUPÇÃO
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
	BTFSC STATUS, Z ; SE Z=1, CONTADOR=20, ENTÃO TROCAR VERDE E VERMELHO
	GOTO TROCAR_VERDE_VERMELHO
	
	; CONTAR OVERFLOW
	INCF CONTADOR, F ; INCREMENTANDO CONTADOR DE OVERFLOWS
	BCF INTCON, T0IF ; LIMPANDO FLAG DE OVERFLOW DO TMR0
	GOTO SAI_INT
	
	; TROCAR SINAIS ENTRE VERDES E VERMELHOS
	TROCAR_VERDE_VERMELHO
	    ;------ COLOCAR BREAKPOINT PARA TESTE AQUI ------
	    MOVLW .0
	    MOVWF INT_SELECT ; MUDANDO PARA OUTRA INTERRUPÇÃO
	    MOVWF CONTADOR ; ZERANDO CONTADOR
	    BCF INTCON, T0IF ; LIMPANDO FLAG DE OVERFLOW

	    ; APAGANDO AMARELOS
	    BCF GPIO, GP2
	    BCF GPIO, GP4

	    ; TROCANDO OS SINAIS DE GP0 (VERMELHO1 E VERDE2) E GP1 (VERMELHO2 E VERDE1)
	    MOVFW GPIO
	    ANDLW B'00000001' ; OBTENDO GP0 (VERDE2)
	    MOVWF AUX ; AUX <- VERDE2
	    BCF STATUS, C ; LIMPANDO FLAG DO CARRY PRA NÃO ALTERAR AS ROTAÇÕES A SEGUIR
	    RLF AUX ; INVERTENDO AS POSIÇÕES DOS BITS DE GP0 E GP1
	    RRF GPIO, W ; INVERTENDO AS POSIÇÕES DOS BITS DE GP0 E GP1
	    ANDLW B'00000001' ; OBTENDO GP1 (VERMELHO2)
	    MOVWF GPIO ; VERDE2 (GP0) <- VERMELHO2 (GP1)
	    MOVFW AUX
	    IORWF GPIO ; VERMELHO2 (GP1) <- AUX

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SAÍDA DA INTERRUPÇÃO                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUPÇÃO

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
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRIÇÃO DE FUNCIONAMENTO
; E UM NOME COERENTE ÀS SUAS FUNÇÕES.
	
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
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000110'	;PRESCALER 1:128
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'10100000'	;ATIVANDO INTERRUPÇÕES PELO TMR0
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	MOVLW TMR0_25MS
	MOVWF TMR0 ; SETANDO O TMR0 PARA CONTAR 25ms
	
	MOVLW .0
	MOVWF INT_SELECT ; SELECIONANDO INTERRUPÇÃO DE AMARELO
	
	MOVWF CONTADOR ; ZERANDO O CONTADOR
	BSF GPIO, GP0 ; INICIANDO COM VERMELHO1 E VERDE2 ATIVADOS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN

	; TODAS AS ATIVAÇÕES DE LED SÃO FEITAS POR INTERRUPÇÃO,
	; PERMITINDO A EXECUÇÃO DE OUTRAS TAREFAS NO MICROCONTROLADOR
	
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
