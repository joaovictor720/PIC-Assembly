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
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAM�RIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARI�VEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DOS NOMES E ENDERE�OS DE TODAS AS VARI�VEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDERE�O INICIAL DA MEM�RIA DE
					;USU�RIO
		W_TEMP		;REGISTRADORES TEMPOR�RIOS PARA USO
		STATUS_TEMP	;JUNTO �S INTERRUP��ES

		;COLOQUE AQUI SUAS NOVAS VARI�VEIS
		DADO
		WORK
		DIVIDENDO
		DIVISOR
		ACUMULADOR
		CONTADOR
		
		;N�O ESQUE�A COMENT�RIOS ESCLARECEDORES

	ENDC			;FIM DO BLOCO DE DEFINI��O DE VARI�VEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

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

	ORG	0x04			;ENDERE�O INICIAL DA INTERRUP��O
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SER�O ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUP��ES

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
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRI��O DE FUNCIONAMENTO
; E UM NOME COERENTE �S SUAS FUN��ES.

; ENTRADA: -
; SA�DA: WREG <- CONTADOR-1
; DESCRI��O: CALCULA QUANTOS DIVISORES CABEM (N�O EXCEDEM) O DIVIDENDO, E RETORNA EM WREG
CONTAR_DIVISORES
	; PREPARANDO PARA A CONTAGEM
	MOVLW .0
	MOVWF ACUMULADOR
	MOVLW .0
	MOVWF CONTADOR
	
	; CONTANDO QUANTOS DIVISORES CABEM NO DIVIDENDO
	; ENQUANTO ACUMULADOR <= DIVIDENDO
	ENQUANTO
	    MOVFW ACUMULADOR
	    SUBWF DIVIDENDO, .0 ; DIVIDENDO - ACUMULADOR
	    BTFSS STATUS, C ; PULAR O CICLO SE ACUMULADOR > DIVIDENDO
	    GOTO FIM_ENQUANTO
	    
	    ; CORPO DO ENQUANTO
	    MOVFW DIVISOR
	    ADDWF ACUMULADOR ; ACUMULADOR <- ACUMULADOR + DIVISOR
	    INCF CONTADOR
	    
	    GOTO ENQUANTO
	FIM_ENQUANTO
	
	; SALVANDO O RESULTADO (PARTE INTEIRA EM DADO)
	DECF CONTADOR, .0 ; DEIXANDO O VALOR DECREMENTADO NO WREG
	
	RETURN

; ENTRADA: ACUMULADOR (RESTO)
; SA�DA: DIVIDENDO <- RESTO*10
; DESCRI��O: MULTIPLICA POR 10 O �LTIMO RESTO CALCULADO, E COLOCA NA VARI�VEL DIVIDENDO
ATUALIZAR_DIVIDENDO
	; ACUMULADOR*10 -> DIVIDENDO
	MOVLW .0
	MOVWF DIVIDENDO
	MOVLW .10
	MOVWF CONTADOR
	FOR_MULTIPLICAR_POR_10
	    ; CORPO DO FOR
	    MOVFW ACUMULADOR ; RESTO -> WREG
	    ADDWF DIVIDENDO ; DIVIDENDO + WREG -> DIVIDENDO
	    
	    DECFSZ CONTADOR ; SE CONTADOR != 0, ENT�O CONTADOR - 1 -> CONTADOR
	    GOTO FOR_MULTIPLICAR_POR_10
	
	RETURN
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000000' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN

	; CORPO DA ROTINA PRINCIPAL
	
	; SIMULANDO A LEITURA DA ENTRADA
	MOVLW .220 ; DIVIDENDO
	MOVWF DADO
	MOVLW .13 ; DIVISOR
	MOVWF WORK
	
	; SIMULANDO A PASSAGEM DA ENTRADA PARA O ALGORITMO PRINCIPAL
	MOVFW DADO
	MOVWF DIVIDENDO
	MOVFW WORK
	MOVWF DIVISOR
	
	;* * * * * * * * * * PARTE INTEIRA * * * * * * * * * * ;
	CALL CONTAR_DIVISORES
	MOVWF DADO ; SALVANDO A PARTE INTEIRA PARA DADO
	
	; CALCULANDO O RESTO
	MOVFW DIVISOR
	SUBWF ACUMULADOR, .0 ; ACUMULADOR - DIVISOR -> WREG
	SUBWF DIVIDENDO, .0 ; DIVIDENDO - (ACUMULADOR - DIVISOR) -> WREG
	MOVWF ACUMULADOR ; RESTO -> ACUMULADOR
	
	; MULTIPLICA O RESTO POR 10, E COLOCA NA VARI�VEL DIVIDENDO
	CALL ATUALIZAR_DIVIDENDO
	
	;* * * * * * * * * * PRIMEIRA DECIMAL * * * * * * * * * * ;
	CALL CONTAR_DIVISORES
	MOVWF WORK ; SALVANDO O D�GITO DA PRIMEIRA CASA DECIMAL
	
	; CALCULANDO O RESTO
	MOVFW DIVISOR
	SUBWF ACUMULADOR, .0 ; ACUMULADOR - DIVISOR -> WREG
	SUBWF DIVIDENDO, .0 ; DIVIDENDO - (ACUMULADOR - DIVISOR) -> WREG
	MOVWF ACUMULADOR ; RESTO -> ACUMULADOR
	
	CALL ATUALIZAR_DIVIDENDO
	
	;* * * * * * * * * * SEGUNDA DECIMAL * * * * * * * * * * ;
	CALL CONTAR_DIVISORES
	MOVWF CONTADOR
	
	; SE WREG >= 5, ENT�O WORK + 1 -> WORK
	MOVLW .5
	SUBWF CONTADOR ; CONTADOR - 5 -> CONTADO
	BTFSS STATUS, C ; SE WREG >= 5, ENT�O EXECUTAR O "SE", POIS C <- 1
	GOTO MAIN
	INCF WORK
	
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
