;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      OUTUBRO DE 2022                            *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David Jos� de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI��ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADR�O MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_ON & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

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

	CBLOCK	0x20	;ENDERE�O INICIAL DA MEM�RIA DE USU�RIO
		W_TEMP		;REGISTRADORES TEMPOR�RIOS PARA USO
		STATUS_TEMP	;JUNTO �S INTERRUP��ES

		;COLOQUE AQUI SUAS NOVAS VARI�VEIS
		CONT_WDT
		CONT_FIM_SYNC
		
	ENDC		;FIM DO BLOCO DE DEFINI��O DE VARI�VEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA
	
	#DEFINE ADDR_PORTS B'00101101' ; GP5 GP3 GP2 GP0
	#DEFINE MEU_ENDERECO B'00101101'
	#DEFINE VRCON_REF B'00100011' ; LOW RANGE, VR3:VR0 = 3, VREF DESLIGADO (MEDIR 0,654V)

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

	ORG	0x00		;ENDERE�O INICIAL DE PROCESSAMENTO
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

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00101111'
	MOVWF	TRISIO		;GP4 � A �NICA PORTA DE SA�DA
	MOVLW	B'00000010'
	MOVWF	ANSEL		;GP1 � A PORTA DE LEITURA ANAL�GICA DO VBAT
	MOVLW	B'00001111'
	MOVWF	OPTION_REG	;PRESCALER 1:128 PRO WDT
	CLRF	INTCON		;SEM INTERRUP��ES
	MOVLW	VRCON_REF
	MOVWF	VRCON		;CONFIGURANDO O VRCON (VER CONSTANTES L� EM CIMA)
	BANK0			;RETORNA PARA O BANCO
	BCF	ADCON0, ADON
	BCF	T1CON, TMR1ON

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	; VERIFICANDO 0000 NAS PORTAS (SINCRONISMO)
	ESPERAR_SYNC
	MOVFW GPIO
	ANDLW ADDR_PORTS ; OBTENDO OS VALORES NAS PORTAS DE ENDERE�AMENTO
	BTFSS STATUS, Z ; SE Z = 1, ENT�O AS PORTAS DE ENDERE�O T�O COM 0000
	GOTO ESPERAR_SYNC
	
	; ESPERA OCUPADA AT� O FIM DO SINCRONISMO
	MOVLW .17
	MOVWF CONT_FIM_SYNC
	ESPERAR_FIM_SYNC
	DECFSZ CONT_FIM_SYNC
	GOTO ESPERAR_FIM_SYNC
	
	; VERIFICANDO 1111 NAS PORTAS (MEU ENDERE�O)
	MOVFW GPIO
	ANDLW ADDR_PORTS ; OBTENDO OS VALORES NAS PORTAS DE ENDERE�AMENTO
	
	; COMPARANDO COM O MEU ENDERE�O, DE ACORDO COM A POSI��O DAS PORTAS NO BYTE
	SUBLW MEU_ENDERECO
	BTFSS STATUS, Z ; SE FOR IGUAL AO ENDERE�O, ENT�O N�O VOLTAR � LEITURA DE ENDERE�O
	GOTO MAIN
	
	; LIGANDO O COMPARADOR E VREF
	MOVLW	B'00010100' ; COM INVERS�O DO COUT
	MOVWF	CMCON ; SE COUT = 1, ENT�O VBAT EST� ACIMA DO LIMIAR
	BANK1
	BSF VRCON, VREN
	BANK0
	
	; MEDINDO A TENS�O VBAT COM O COMPARADOR
	BTFSS CMCON, COUT
	GOTO NAO_LIGAR_GP4
	BSF GPIO, GP4
	NAO_LIGAR_GP4
	
	; DESLIGANDO O COMPARADOR E VREF
	CLRF CMCON
	BANK1
	BCF VRCON, VREN
	BANK0
	
	; DORMIR 5S (APROXIMADAMENTE)
	; PRIMEIRA PARTE DO CICLO DE SLEEP (4.4 SEGUNDOS)
	MOVLW .2
	MOVWF CONT_WDT
	BANK1
	MOVLW B'00001111'
	MOVWF OPTION_REG ; RECONFIGURANDO O PRESCALER DO WDT PARA 4.4S
	BANK0
	DORMIR1
	CLRWDT
	SLEEP
	DECFSZ CONT_WDT
	GOTO DORMIR1
	
	; SEGUNDA PARTE DO CICLO DE SLEEP (POUCO MAIS DE 500MS)
	BANK1
	MOVLW B'00001101'
	MOVWF OPTION_REG ; RECONFIGURANDO O PRESCALER DO WDT PARA 500MS
	BANK0
	CLRWDT
	SLEEP
	
	BCF GPIO, GP4

	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
