;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                     MAR�O DE 2024                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       NOME DO PROJETO                           *
;*                           CLIENTE                               *
;*         DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA      *
;*   VERS�O: 1.0                           DATA: 17/06/03          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRI��O DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;*                                                                 *
;*                                                                 *
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
		DADO		;ARMAZENA O DADO PARA A EEPROM

		;NOVAS VARI�VEIS
		CONTADOR
		CONTADOR_DIV
		SOMA_L
		SOMA_H
		DELTA_L
		DELTA_H
		T0_L
		T0_H
		T1_L
		T1_H
		AUX_L
		AUX_H

	ENDC			;FIM DO BLOCO DE MEM�RIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA
; INICIALIZA��O DA EEPROM, DE ACORDO COM A DESCRI��O NO ARQUIVO "Def_Rega_Formigas.inc"
	
	#DEFINE ARRAY .50
	#DEFINE TAM_ARRAY .32
	
	#DEFINE TH_0 .154
	#DEFINE TH_1 .57
	
	#DEFINE EEPTR_MEDIA H'2A'

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
	
	#DEFINE PULSO GP2

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
	
	BCF PIR1, TMR1IF
	BTFSS GPIO, PULSO ; TROCANDO VALOR DO PULSO DE CARGA
	GOTO CURVA_SUBIDA
	
	CURVA_DESCIDA
	    INCF CONTADOR ; INCREMENTANDO O CONTADOR DE MEDI��ES
	    BCF GPIO, PULSO ; GERANDO A CURVA DE RESPOSTA DESCENDENTE
	    CALL MEDIR_RC
	    INCF FSR
	    GOTO SAI_INT
	
	CURVA_SUBIDA
	    BSF GPIO, PULSO ; GERANDO A CURVA DE RESPOSTA ASCENDENTE
	    GOTO SAI_INT

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

; ESPERA A TENS�O CHEGAR EM 3V, E ENT�O EM 1,1036V, REGISTRA E SUBTRAI OS TEMPOS
; EM CADA UM DESSES DOIS EVENTOS, MEDINDO ASSIM A CONSTANTE DE TEMPO
MEDIR_RC
	BSF ADCON0, ADON ; ATIVANDO MEDI��ES DO CONVERSOR
	MEDIR_T0
	    BSF ADCON0, GO
	    ESPERAR_MEDIDA_T0
		BTFSC ADCON0, GO
		GOTO ESPERAR_MEDIDA_T0
	    MOVFW ADRESH ; PEGANDO VALOR MEDIDO PELO CONVERSOR A/D
	    SUBLW TH_0 ; THRESHOLD EQUIVALENTE A 3V
	    BTFSS STATUS, C ; CHECANDO SE A MEDIDA PASSOU PRA BAIXO DO THRESHOLD
	    GOTO MEDIR_T0
	MOVFW TMR1L
	MOVWF T0_L
	MOVFW TMR1H
	MOVWF T0_H
	MEDIR_T1
	    BSF ADCON0, GO
	    ESPERAR_MEDIDA_T1
		BTFSC ADCON0, GO
		GOTO ESPERAR_MEDIDA_T1
	    MOVFW ADRESH ; PEGANDO VALOR MEDIDO PELO CONVERSOR A/D
	    SUBLW TH_1 ; THRESHOLD EQUIVALENTE A 1,1036V
	    BTFSS STATUS, C ; CHECANDO SE A MEDIDA PASSOU PRA BAIXO DO THRESHOLD
	    GOTO MEDIR_T1
	MOVFW TMR1L
	MOVWF T1_L
	MOVFW TMR1H
	MOVWF T1_H
	BCF ADCON0, ADON ; DESATIVANDO CONVERSOR, PARA SALVAR ENERGIA
	
	; SUBTRA��O DE 2 BYTES
	MOVFW T0_L
	SUBWF T1_L, W
	MOVWF DELTA_L
	BTFSC STATUS, C
	GOTO NAO_HOUVE_BORROW
	    DECF T1_H
	NAO_HOUVE_BORROW
	MOVFW T0_H
	SUBWF T1_H, W
	MOVWF DELTA_H
	
	; DIVIDINDO A DIFEREN�A POR 125, PARA OBTER O TEMPO REAL EM MILISSEGUNDOS
	; PREPARANDO PARA A CONTAGEM
	CLRF SOMA_L
	CLRF SOMA_H
	CLRF CONTADOR_DIV
	
	; ENQUANTO ACUMULADOR (2 BYTES) <= DELTA (2 BYTES)
	ENQUANTO
	    ; SUBTRA��O DE 2 BYTES AUX (DELTA) - ACUMULADOR
	    MOVFW DELTA_L
	    MOVWF AUX_L
	    MOVFW DELTA_H
	    MOVWF AUX_H ; COPIANDO O DELTA PARA UMA VARI�VEL AUXILIAR
	    
	    MOVFW SOMA_L
	    SUBWF AUX_L, W
	    BTFSC STATUS, C
	    GOTO NAO_HOUVE_BORROW_DIV
		DECF AUX_H
	    NAO_HOUVE_BORROW_DIV
	    MOVFW SOMA_H
	    SUBWF AUX_H, W
	    BTFSS STATUS, C
	    GOTO FIM_ENQUANTO
	    
	    ; CORPO DO ENQUANTO
	    MOVLW .125
	    ADDWF SOMA_L ; ACUMULADOR <- ACUMULADOR + DIVISOR
	    BTFSS STATUS, C
	    GOTO SEM_CARRY_DIV
		INCF SOMA_H
	    SEM_CARRY_DIV
	    INCF CONTADOR_DIV
	    GOTO ENQUANTO
	FIM_ENQUANTO
	
	; CORRIGINDO O RESULTADO DA DIVIS�O
	DECF CONTADOR_DIV, W
	MOVWF INDF ; SALVANDO MEDI��O EM ms NO ARRAY
	RETURN
	
LE_EEPROM
;LER DADO DA EEPROM, CUJO ENDERE�O � INDICADO EM W
;O DADO LIDO RETORNA EM W
	ANDLW	.127		;LIMITA ENDERE�O MAX. 127
	BANK1				;ACESSO VIA BANK 1
	MOVWF	EEADR		;INDICA O END. DE LEITURA
	BSF		EECON1,RD	;INICIA O PROCESSO DE LEITURA
	MOVF	EEDATA,W	;COLOCA DADO LIDO EM W
	BANK0				;POSICIONA PARA BANK 0
	RETURN

GRAVA_EEPROM
;ESCREVE UM DADO NA EEPROM, CUJO ENDERE�O � INDICADO EM W
;O DADO A SER ESCRITO DEVE ESTAR ARMAZENADO NA VARI�VEL DADO
	ANDLW	.127		;LIMITA ENDERE�O MAX. 127
	BANK1				;ACESSO VIA BANK 1
	MOVWF	EEADR
	MOVF	DADO,W
	MOVWF	EEDATA
	BSF		EECON1,WREN ;HABILITA ESCRITA
	BCF		INTCON,GIE	;DESLIGA INTERRUP��ES
	MOVLW	B'01010101'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	MOVLW	B'10101010'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	BSF		EECON1,WR ;INICIA A ESCRITA
AGUARDA
	BTFSC	EECON1,WR ;TERMINOU?
	GOTO	AGUARDA
	BSF		INTCON,GIE ;HABILITA INTERRUP��ES
	BANK0				;POSICIONA PARA BANK 0
	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00000010'
	MOVWF	TRISIO		;GP2 SA�DA, GP1 ENTRADA
	MOVLW	B'00000000'
	MOVWF	ANSEL 		;GP1 ANAL�GICA
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'11000000'
	MOVWF	INTCON		;ATIVA INTERRUP��ES POR PERIF�RICOS
	MOVLW	B'00000001'
	MOVWF	PIE1		;ATIVA INTERRUP��ES DO TMR1
	BANK0			;RETORNA PARA O BANCO
	MOVLW	B'00000100'
	MOVWF	CMCON		;MODO 100 (VREF INTERNO E COUT ISOLADO)
	MOVLW	B'00110101'
	MOVWF	T1CON		;ATIVA TMR1, PRESCALER 1:8
	
	; LEFT JUSTIFIED, VDD COMO REF, LEITURA NA AN1, SEM LEITURA E CONVERSOR DESATIVADO
	MOVLW	B'00000100'
	MOVWF	ADCON0

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
	; ZERANDO O TMR1
	CLRF TMR1L
	CLRF TMR1H

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	MOVLW ARRAY
	MOVWF FSR ; APONTANDO PARA O IN�CIO DO ARRAY
	CLRF CONTADOR ; INICIANDO CONTADOR DA DURA��O DO CICLO DE ESCRITA
	
	; ESPERA TODAS AS MEDI��ES OCORREREM
	MEDINDO_RC
	    MOVLW TAM_ARRAY
	    SUBWF CONTADOR, W
	    BTFSS STATUS, Z
	    GOTO MEDINDO_RC
	
	; SOMANDO OS ELEMENTOS DO ARRAY
	CLRF SOMA_L
	CLRF SOMA_H
	MOVLW TAM_ARRAY
	MOVWF CONTADOR
	MOVLW ARRAY
	MOVWF FSR ; COME�ANDO A SOMA PELO PRIMEIRO ELEMENTO
	SOMAR
	    MOVFW INDF
	    ADDWF SOMA_L
	    BTFSS STATUS, C
	    GOTO SEM_CARRY
		INCF SOMA_H
	    SEM_CARRY
	    INCF FSR
	    DECFSZ CONTADOR
	    GOTO SOMAR
	
	; DIVIDE A SOMA POR 32
	BCF STATUS, C ; LIMPANDO O CARRY PARA N�O CORROMPER AS ROTA��ES
	; FAZENDO 5 ROTA��ES � DIREITA NA VARI�VEL SOMA DE 16 BITS
	; REAPROVEITANDO O CARRY DA ROTA��O DO HIGH PARA COLOCAR NO MSB DO LOW
	RRF SOMA_H
	RRF SOMA_L
	RRF SOMA_H
	RRF SOMA_L
	RRF SOMA_H
	RRF SOMA_L
	RRF SOMA_H
	RRF SOMA_L
	RRF SOMA_H
	RRF SOMA_L, W ; ESTA �LTIMA ROTA��O J� VAI CONTER O VALOR DA M�DIA FINAL
	
	; GRAVANDO A MEDIA EM 0X2A DA EEPROM
	MOVWF DADO ; O VALOR DA M�DIA J� EST� COLOCADO NO WREG
	MOVLW EEPTR_MEDIA
	CALL GRAVA_EEPROM
	
	GOTO MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
