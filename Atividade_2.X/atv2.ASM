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
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAMÓRIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÁVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DOS NOMES E ENDEREÇOS DE TODAS AS VARIÁVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE
					;USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES

		;COLOQUE AQUI SUAS NOVAS VARIÁVEIS
		DADO
		WORK
		DIVIDENDO
		DIVISOR
		ACUMULADOR
		CONTADOR
		
		;NÃO ESQUEÇA COMENTÁRIOS ESCLARECEDORES

	ENDC			;FIM DO BLOCO DE DEFINIÇÃO DE VARIÁVEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

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

	ORG	0x04			;ENDEREÇO INICIAL DA INTERRUPÇÃO
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SERÃO ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÇÕES

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
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRIÇÃO DE FUNCIONAMENTO
; E UM NOME COERENTE ÀS SUAS FUNÇÕES.

; ENTRADA: -
; SAÍDA: WREG <- CONTADOR-1
; DESCRIÇÃO: CALCULA QUANTOS DIVISORES CABEM (NÃO EXCEDEM) O DIVIDENDO, E RETORNA EM WREG
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
; SAÍDA: DIVIDENDO <- RESTO*10
; DESCRIÇÃO: MULTIPLICA POR 10 O ÚLTIMO RESTO CALCULADO, E COLOCA NA VARIÁVEL DIVIDENDO
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
	    
	    DECFSZ CONTADOR ; SE CONTADOR != 0, ENTÃO CONTADOR - 1 -> CONTADOR
	    GOTO FOR_MULTIPLICAR_POR_10
	
	RETURN
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000000' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
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
	
	; MULTIPLICA O RESTO POR 10, E COLOCA NA VARIÁVEL DIVIDENDO
	CALL ATUALIZAR_DIVIDENDO
	
	;* * * * * * * * * * PRIMEIRA DECIMAL * * * * * * * * * * ;
	CALL CONTAR_DIVISORES
	MOVWF WORK ; SALVANDO O DÍGITO DA PRIMEIRA CASA DECIMAL
	
	; CALCULANDO O RESTO
	MOVFW DIVISOR
	SUBWF ACUMULADOR, .0 ; ACUMULADOR - DIVISOR -> WREG
	SUBWF DIVIDENDO, .0 ; DIVIDENDO - (ACUMULADOR - DIVISOR) -> WREG
	MOVWF ACUMULADOR ; RESTO -> ACUMULADOR
	
	CALL ATUALIZAR_DIVIDENDO
	
	;* * * * * * * * * * SEGUNDA DECIMAL * * * * * * * * * * ;
	CALL CONTAR_DIVISORES
	MOVWF CONTADOR
	
	; SE WREG >= 5, ENTÃO WORK + 1 -> WORK
	MOVLW .5
	SUBWF CONTADOR ; CONTADOR - 5 -> CONTADO
	BTFSS STATUS, C ; SE WREG >= 5, ENTÃO EXECUTAR O "SE", POIS C <- 1
	GOTO MAIN
	INCF WORK
	
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
