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
		CONT_BO ; CONTADOR DE BROWN-OUTS (QUEDAS DE TENS�O) EXTERNOS
		CONT_TMR1

	ENDC			;FIM DO BLOCO DE MEM�RIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA
	
	; INICIALIZANDO A EEPROM COM 0 NA GRAVA��O DO C�DIGO
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
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)
	
	#DEFINE LINHA_COM GP2 ; TAMB�M � SA�DA
	#DEFINE VIN GP1

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SA�DAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)
	
	#DEFINE LED_ALARME GP4
	#DEFINE LED_LOCK GP5

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
	
	; VERIFICANDO SE CHEGOU AQUI POR CAUSA DE UMA QUEDA DE TENS�O
	BANK0
	BCF PIR1, CMIF
	BTFSC CMCON, COUT
	GOTO TENSAO_ABAIXO
	    ; DESLIGANDO O ALARME, J� QUE A TENS�O EST� ACIMA DO LIMIAR DE 9V
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
	
; DESCRI��O: PREPARA O PIC PARA DORMIR E DORME. APENAS A INTERRUP��O PELA PORTA
; GP2 ACORDA O PIC. AP�S DORMIR, O PIC SEMPRE VOLTAR� PARA "TENTAR_LOCK",
; INDEPENDENTEMENTE DE ONDE FOI CHAMADA. PORTANTO, ISTO N�O � UMA FUN��O.
DORMIR
	; DESATIVANDO INTERRUP��ES GLOBAIS E PELO COMPARADOR
	BCF INTCON, GIE
	BCF INTCON, PEIE
	BANK1
	BCF PIE1, CMIE
	BANK0
	
	; DESLIGANDO O COMPARADOR
	CLRF CMCON
	
	BANK1
	BCF VRCON, VREN ; DESLIGANDO A TENS�O DE REFER�NCIA
	
	; TORNANDO A LINHA DE COMUNICA��O EM ENTRADA PULL-UP
	BSF TRISIO, LINHA_COM
	BSF WPU, LINHA_COM
	
	; HABILITANDO INTERRUP��ES POR MUDAN�A DE PORTA NA LINHA DE COMUNICA��O
	BCF INTCON, INTF
	BSF INTCON, INTE
	BANK0
	
	SLEEP
	
	; DESATIVAR INTERRUP��ES POR PORTA NA LINHA DE COMUNICA��O
	BCF INTCON, INTF
	BCF INTCON, INTE
	
	GOTO TENTAR_LOCK

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1			;ALTERA PARA O BANCO 1
	CLRF	PIE1		;DESATIVANDO TODAS AS INTERRUP��ES POR PERIF�RICOS
	BSF	TRISIO, VIN	;DEFININDO PINO DA TENS�O EXTERNA COMO ENTRADA
	BSF	TRISIO,LINHA_COM;DEFININDO PINO DE COMUNICA��O COMO ENTRADA
	BSF	WPU, LINHA_COM	;PINO DE COMUNICA��O EM PULL-UP
	CLRF	ANSEL
	BSF	ANSEL, VIN	;DEFININDO PINO DA TENS�O EXTERNA COMO ANAL�GICO
	MOVLW	B'01000111'
	MOVWF	OPTION_REG	;GLOBAL PULL-UP, INT DA GP2 NA SUBIDA
	MOVLW	VRCON_REF
	MOVWF	VRCON
	BANK0			;RETORNA PARA O BANCO 0C
	MOVLW	B'00110100'
	MOVWF	T1CON		;CONFIGURANDO O TMR1, MANTENDO DESLIGADO
	CLRF	CMCON		;COUT = 1 QUANDO A TENS�O EST� ABAIXO DO LIMIAR (N�O INVERTER COUT)
	BCF	ADCON0		;GARANTINDO QUE O CONVERSOR A/D ESTEJA DESLIGADO
	
MAIN
	TENTAR_LOCK
	    ; VERIFICANDO SE O LOCK EST� LIVRE
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
	
	; HABILITANDO A INTERRUP��O PELO COMPARADOR
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
