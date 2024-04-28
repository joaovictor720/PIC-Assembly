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
		CONT_BO ; CONTADOR DE BROWN-OUTS (QUEDAS DE TENSÃO) EXTERNOS
		CONT_TMR1

	ENDC			;FIM DO BLOCO DE MEMÓRIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA
	
	; INICIALIZANDO A EEPROM COM 0 NA GRAVAÇÃO DO CÓDIGO
	ORG 0x2100
	DE	0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00
	DE	0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00
	DE	0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00
	DE	0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00
	DE	0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00
	DE	0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00
	DE	0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00
	DE	0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00,0X00
	
	#DEFINE CONT_EEPROM_PTR 0X1F
	#DEFINE TMR1_500MS_L B'11011100' ;0XDC
	#DEFINE TMR1_500MS_H B'00001011' ;0XB
	#DEFINE VRCON_REF B'00001011' ; HIGH RANGE, VR3:VR0 = 11, VREF DESLIGADO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)
	
	#DEFINE LINHA_COM GP2 ; TAMBÉM É SAÍDA
	#DEFINE VIN GP1

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SAÍDAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO SAÍDA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)
	
	#DEFINE LED_ALARME GP4
	#DEFINE LED_LOCK GP5

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
	
	; VERIFICANDO SE CHEGOU AQUI POR CAUSA DE UMA QUEDA DE TENSÃO
	BANK0
	BCF PIR1, CMIF
	BTFSC CMCON, COUT
	GOTO TENSAO_ABAIXO
	    ; DESLIGANDO O ALARME, JÁ QUE A TENSÃO ESTÁ ACIMA DO LIMIAR DE 9V
	    BCF GPIO, LED_ALARME
	    GOTO SAI_INT
	TENSAO_ABAIXO
	    ; LIGANDO O ALARME
	    BSF GPIO, LED_ALARME
	    
	    ; LENDO E INCREMENTANDO O CONTADOR DE BROWN-OUTS DA EEPROM
	    MOVLW CONT_EEPROM_PTR
	    CALL LE_EEPROM
	    MOVWF CONT_BO
	    INCF CONT_BO
	    MOVFW CONT_BO
	    
	    ; SALVANDO O CONTADOR INCREMENTADO NA EEPROM
	    MOVWF DADO
	    MOVLW CONT_EEPROM_PTR
	    CALL GRAVA_EEPROM
	    
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
	
; DESCRIÇÃO: PREPARA O PIC PARA DORMIR E DORME. APENAS A INTERRUPÇÃO PELA PORTA
; GP2 ACORDA O PIC. APÓS DORMIR, O PIC SEMPRE VOLTARÁ PARA "TENTAR_LOCK",
; INDEPENDENTEMENTE DE ONDE FOI CHAMADA. PORTANTO, ISTO NÃO É UMA FUNÇÃO.
DORMIR
	; DESATIVANDO INTERRUPÇÕES GLOBAIS E PELO COMPARADOR
	BCF INTCON, GIE
	BCF INTCON, PEIE
	BANK1
	BCF PIE1, CMIE
	BANK0
	
	; DESLIGANDO O COMPARADOR
	CLRF CMCON
	
	BANK1
	BCF VRCON, VREN ; DESLIGANDO A TENSÃO DE REFERÊNCIA
	
	; TORNANDO A LINHA DE COMUNICAÇÃO EM ENTRADA PULL-UP
	BSF TRISIO, LINHA_COM
	BSF WPU, LINHA_COM
	
	; HABILITANDO INTERRUPÇÕES POR MUDANÇA DE PORTA NA LINHA DE COMUNICAÇÃO
	BCF INTCON, INTF
	BSF INTCON, INTE
	BANK0
	
	SLEEP
	
	; DESATIVAR INTERRUPÇÕES POR PORTA NA LINHA DE COMUNICAÇÃO
	BCF INTCON, INTF
	BCF INTCON, INTE
	
	GOTO TENTAR_LOCK

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1			;ALTERA PARA O BANCO 1
	CLRF	PIE1		;DESATIVANDO TODAS AS INTERRUPÇÕES POR PERIFÉRICOS
	BSF	TRISIO, VIN	;DEFININDO PINO DA TENSÃO EXTERNA COMO ENTRADA
	BSF	TRISIO,LINHA_COM;DEFININDO PINO DE COMUNICAÇÃO COMO ENTRADA
	BSF	WPU, LINHA_COM	;PINO DE COMUNICAÇÃO EM PULL-UP
	CLRF	ANSEL
	BSF	ANSEL, VIN	;DEFININDO PINO DA TENSÃO EXTERNA COMO ANALÓGICO
	MOVLW	B'01000111'
	MOVWF	OPTION_REG	;GLOBAL PULL-UP, INT DA GP2 NA SUBIDA
	MOVLW	VRCON_REF
	MOVWF	VRCON
	BANK0			;RETORNA PARA O BANCO 0C
	MOVLW	B'00110100'
	MOVWF	T1CON		;CONFIGURANDO O TMR1, MANTENDO DESLIGADO
	CLRF	CMCON		;COUT = 1 QUANDO A TENSÃO ESTÁ ABAIXO DO LIMIAR (NÃO INVERTER COUT)
	BCF	ADCON0		;GARANTINDO QUE O CONVERSOR A/D ESTEJA DESLIGADO
	
MAIN
	TENTAR_LOCK
	    ; VERIFICANDO SE O LOCK ESTÁ LIVRE
	    BTFSS GPIO, LINHA_COM
	    GOTO DORMIR

	    ; OBTENDO O LOCK
	    BANK1
	    BCF TRISIO, LINHA_COM
	    BANK0
	    BCF GPIO, LINHA_COM
	
	; ATIVANDO COMPARADOR E VREF PRA FICAR MEDINDO BROWN-OUTS DE 3V
	BSF CMCON, CM2
	BANK1
	BSF VRCON, VREN
	BANK0
	
	; HABILITANDO A INTERRUPÇÃO PELO COMPARADOR
	BCF PIR1, CMIF
	BSF INTCON, GIE
	BSF INTCON, PEIE
	BANK1
	BSF PIE1, CMIE
	BANK0
	
	; ESPERA OCUPADA DE 5S COM O TMR1
	MOVLW .10
	MOVWF CONT_TMR1
	BSF T1CON, TMR1ON ; ATIVANDO O TMR1
	ESPERAR_5S
	    MOVLW TMR1_500MS_H
	    MOVWF TMR1H
	    MOVLW TMR1_500MS_L
	    MOVWF TMR1L
	    ESPERAR_TMR1
	    BTFSS PIR1, TMR1IF
	    GOTO ESPERAR_TMR1
	BCF PIR1, TMR1IF
	DECFSZ CONT_TMR1
	GOTO ESPERAR_5S
	BCF T1CON, TMR1ON ; DESATIVANDO O TMR1
	
	; SOLTANDO O LOCK
	BANK1
	BSF TRISIO, LINHA_COM
	BSF WPU, LINHA_COM
	BANK0
	
	; ESPERAR O OUTRO PEGAR O LOCK (QUANDO LINHA_COM FOR PARA LOW)
	ESPERAR_HOMOLOGO
	BTFSC GPIO, LINHA_COM
	GOTO ESPERAR_HOMOLOGO
	GOTO DORMIR

	GOTO MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
