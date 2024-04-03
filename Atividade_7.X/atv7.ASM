;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                     MARÇO DE 2024                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       NOME DO PROJETO                           *
;*                           CLIENTE                               *
;*         DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA      *
;*   VERSÃO: 1.0                           DATA: 17/06/03          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRIÇÃO DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;*                                                                 *
;*                                                                 *
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
		DADO		;ARMAZENA O DADO PARA A EEPROM

		;NOVAS VARIÁVEIS
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

	ENDC			;FIM DO BLOCO DE MEMÓRIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA
; INICIALIZAÇÃO DA EEPROM, DE ACORDO COM A DESCRIÇÃO NO ARQUIVO "Def_Rega_Formigas.inc"
	
	#DEFINE ARRAY .50
	#DEFINE TAM_ARRAY .32
	
	#DEFINE TH_0 .154
	#DEFINE TH_1 .57
	
	#DEFINE EEPTR_MEDIA H'2A'

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
	
	#DEFINE PULSO GP2

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
	
	BCF PIR1, TMR1IF
	BTFSS GPIO, PULSO ; TROCANDO VALOR DO PULSO DE CARGA
	GOTO CURVA_SUBIDA
	
	CURVA_DESCIDA
	    INCF CONTADOR ; INCREMENTANDO O CONTADOR DE MEDIÇÕES
	    BCF GPIO, PULSO ; GERANDO A CURVA DE RESPOSTA DESCENDENTE
	    CALL MEDIR_RC
	    INCF FSR
	    GOTO SAI_INT
	
	CURVA_SUBIDA
	    BSF GPIO, PULSO ; GERANDO A CURVA DE RESPOSTA ASCENDENTE
	    GOTO SAI_INT

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

; ESPERA A TENSÃO CHEGAR EM 3V, E ENTÃO EM 1,1036V, REGISTRA E SUBTRAI OS TEMPOS
; EM CADA UM DESSES DOIS EVENTOS, MEDINDO ASSIM A CONSTANTE DE TEMPO
MEDIR_RC
	BSF ADCON0, ADON ; ATIVANDO MEDIÇÕES DO CONVERSOR
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
	
	; SUBTRAÇÃO DE 2 BYTES
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
	
	; DIVIDINDO A DIFERENÇA POR 125, PARA OBTER O TEMPO REAL EM MILISSEGUNDOS
	; PREPARANDO PARA A CONTAGEM
	CLRF SOMA_L
	CLRF SOMA_H
	CLRF CONTADOR_DIV
	
	; ENQUANTO ACUMULADOR (2 BYTES) <= DELTA (2 BYTES)
	ENQUANTO
	    ; SUBTRAÇÃO DE 2 BYTES AUX (DELTA) - ACUMULADOR
	    MOVFW DELTA_L
	    MOVWF AUX_L
	    MOVFW DELTA_H
	    MOVWF AUX_H ; COPIANDO O DELTA PARA UMA VARIÁVEL AUXILIAR
	    
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
	
	; CORRIGINDO O RESULTADO DA DIVISÃO
	DECF CONTADOR_DIV, W
	MOVWF INDF ; SALVANDO MEDIÇÃO EM ms NO ARRAY
	RETURN
	
LE_EEPROM
;LER DADO DA EEPROM, CUJO ENDEREÇO É INDICADO EM W
;O DADO LIDO RETORNA EM W
	ANDLW	.127		;LIMITA ENDEREÇO MAX. 127
	BANK1				;ACESSO VIA BANK 1
	MOVWF	EEADR		;INDICA O END. DE LEITURA
	BSF		EECON1,RD	;INICIA O PROCESSO DE LEITURA
	MOVF	EEDATA,W	;COLOCA DADO LIDO EM W
	BANK0				;POSICIONA PARA BANK 0
	RETURN

GRAVA_EEPROM
;ESCREVE UM DADO NA EEPROM, CUJO ENDEREÇO É INDICADO EM W
;O DADO A SER ESCRITO DEVE ESTAR ARMAZENADO NA VARIÁVEL DADO
	ANDLW	.127		;LIMITA ENDEREÇO MAX. 127
	BANK1				;ACESSO VIA BANK 1
	MOVWF	EEADR
	MOVF	DADO,W
	MOVWF	EEDATA
	BSF		EECON1,WREN ;HABILITA ESCRITA
	BCF		INTCON,GIE	;DESLIGA INTERRUPÇÕES
	MOVLW	B'01010101'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	MOVLW	B'10101010'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	BSF		EECON1,WR ;INICIA A ESCRITA
AGUARDA
	BTFSC	EECON1,WR ;TERMINOU?
	GOTO	AGUARDA
	BSF		INTCON,GIE ;HABILITA INTERRUPÇÕES
	BANK0				;POSICIONA PARA BANK 0
	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00000010'
	MOVWF	TRISIO		;GP2 SAÍDA, GP1 ENTRADA
	MOVLW	B'00000000'
	MOVWF	ANSEL 		;GP1 ANALÓGICA
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'11000000'
	MOVWF	INTCON		;ATIVA INTERRUPÇÕES POR PERIFÉRICOS
	MOVLW	B'00000001'
	MOVWF	PIE1		;ATIVA INTERRUPÇÕES DO TMR1
	BANK0			;RETORNA PARA O BANCO
	MOVLW	B'00000100'
	MOVWF	CMCON		;MODO 100 (VREF INTERNO E COUT ISOLADO)
	MOVLW	B'00110101'
	MOVWF	T1CON		;ATIVA TMR1, PRESCALER 1:8
	
	; LEFT JUSTIFIED, VDD COMO REF, LEITURA NA AN1, SEM LEITURA E CONVERSOR DESATIVADO
	MOVLW	B'00000100'
	MOVWF	ADCON0

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
	; ZERANDO O TMR1
	CLRF TMR1L
	CLRF TMR1H

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	MOVLW ARRAY
	MOVWF FSR ; APONTANDO PARA O INÍCIO DO ARRAY
	CLRF CONTADOR ; INICIANDO CONTADOR DA DURAÇÃO DO CICLO DE ESCRITA
	
	; ESPERA TODAS AS MEDIÇÕES OCORREREM
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
	MOVWF FSR ; COMEÇANDO A SOMA PELO PRIMEIRO ELEMENTO
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
	BCF STATUS, C ; LIMPANDO O CARRY PARA NÃO CORROMPER AS ROTAÇÕES
	; FAZENDO 5 ROTAÇÕES À DIREITA NA VARIÁVEL SOMA DE 16 BITS
	; REAPROVEITANDO O CARRY DA ROTAÇÃO DO HIGH PARA COLOCAR NO MSB DO LOW
	RRF SOMA_H
	RRF SOMA_L
	RRF SOMA_H
	RRF SOMA_L
	RRF SOMA_H
	RRF SOMA_L
	RRF SOMA_H
	RRF SOMA_L
	RRF SOMA_H
	RRF SOMA_L, W ; ESTA ÚLTIMA ROTAÇÃO JÁ VAI CONTER O VALOR DA MÉDIA FINAL
	
	; GRAVANDO A MEDIA EM 0X2A DA EEPROM
	MOVWF DADO ; O VALOR DA MÉDIA JÁ ESTÁ COLOCADO NO WREG
	MOVLW EEPTR_MEDIA
	CALL GRAVA_EEPROM
	
	GOTO MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
