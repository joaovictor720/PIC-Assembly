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

	; WDT LIGADO, POWER-UP TIMER DESLIGADO, OSCILADOR LP (LOW POWER) ESCOLHIDO
	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_OFF & _WDT_ON & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

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

	ENDC		;FIM DO BLOCO DE DEFINI��O DE VARI�VEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA
	
	#DEFINE TH_2V .102
	#DEFINE TH_3V .154
	#DEFINE TH_4V .204

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
	
	#DEFINE LED1 GP1
	#DEFINE LED2 GP2
	#DEFINE LED3 GP4
	#DEFINE LED4 GP5

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

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	; ******** CONFIGURA��O ********
	CLRF GPIO
	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'11111111'
	MOVWF	TRISIO		;TODOS OS PINOS INICIAM COM ALTA IMPED�NCIA
	MOVLW	B'00010001'
	MOVWF	ANSEL 		;FREQU�NCIA DE AMOSTRAGEM DO A/D = FOSC/8, GP0 ANAL�GICA
	MOVLW	B'00001111'
	MOVWF	OPTION_REG	;ATRIBUINDO PRESCALER M�XIMO AO WDT, PULL-UPS HABILITADOS
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	BCF	VRCON, VREN	;DESLIGANDO O CVREF
	BANK0			;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DESLIGANDO O COMPARADOR
	CLRF	ADCON0		;LEFT JUSTIFED, AN0, DESLIGADO POR ENQUANTO
	MOVLW	B'01000110'
	MOVWF	T1CON		;DEIXANDO O TMR1 BEM DESLIGADO

	; ******** L�GICA PRINCIPAL ********
	BSF ADCON0, ADON ; LIGANDO CONVERSOR A/D
	BSF ADCON0, GO
	ESPERAR_MEDIDA
	    BTFSC ADCON0, GO
	    GOTO ESPERAR_MEDIDA
	BCF ADCON0, ADON ; DESLIGANDO O CONVERSOR A/D
	
	; TESTANDO LIMITES DE TENS�O E LIGANDO OS LEDS CORRESPONDENTES
	BANK1
	BCF TRISIO, LED1 ; TIRANDO O LED1 DE ALTA IMPED�NCIA
	BANK0
	BSF GPIO, LED1
	MOVLW TH_2V
	SUBWF ADRESH, W
	BTFSS STATUS, C
	GOTO ADORMECER
	
	BANK1
	BSF TRISIO, LED1 ; RECOLOCANDO O LED1 EM ALTA IMPED�NCIA
	BCF TRISIO, LED2 ; TIRANDO O LED2 DE ALTA IMPED�NCIA
	BANK0
	BSF GPIO, LED2
	MOVLW TH_3V
	SUBWF ADRESH, W
	BTFSS STATUS, C
	GOTO ADORMECER
	
	BANK1
	BSF TRISIO, LED2 ; RECOLOCANDO O LED2 EM ALTA IMPED�NCIA
	BCF TRISIO, LED3 ; TIRANDO O LED2 DE ALTA IMPED�NCIA
	BANK0
	BSF GPIO, LED3
	MOVLW TH_4V
	SUBWF ADRESH, W
	BTFSS STATUS, C
	GOTO ADORMECER
	
	BANK1
	BSF TRISIO, LED3 ; RECOLOCANDO O LED3 EM ALTA IMPED�NCIA
	BCF TRISIO, LED4 ; TIRANDO O LED2 DE ALTA IMPED�NCIA
	BANK0
	BSF GPIO, LED4
	
	; DO MANUAL DO PIC:
	; "For lowest current consumption in this mode, all I/O
	; pins should be either at VDD, or VSS, with no external
	; circuitry drawing current from the I/O pin and the com-
	; parators and CVREF should be disabled. I/O pins that
	; are high-impedance inputs should be pulled high or low
	; externally to avoid switching currents caused by float-
	; ing inputs. The T0CKI input should also be at VDD or
	; VSS for lowest current consumption. The contribution
	; from on-chip pull-ups on GPIO should be considered."
	ADORMECER
	BANK1
	MOVLW 0XFF
	MOVWF WPU
	BANK0
	CLRWDT
	SLEEP
	
	; ******** MODO POWER-UP ********
	; TODO O GASTO DA REGI�O DE POWER-UP � DESPREZ�VEL, POIS 
	; 1 microssegundo = 2,77778e-10 hora
	; O MAIOR RALO DE POT�NCIA S�O OS LEDS, QUE FICAM ACESOS TEMPORARIAMENTE
	; ENQUANTO O PIC IDENTIFICA O N�VEL DE TENS�O CORRETO, O QUE TOTALIZA
	; 38us = 1.0555564e-8 hora DE PELO MENOS UM LED ACESO NO PIOR CASO DESSE C�DIGO.
	; CONSIDERANDO A CORRENTE M�XIMA DE UMA PORTA DE SA�DA DO PIC12F675 (25mA), A
	; POT�NCIA DISSIPADA NESSE PIOR CASO (LED4 ACESO) � 5V*25mA = 0.125W, OU SEJA,
	; 1.0555564e-8 hora * 0.125W = 1.3194455e-9 Wh = 1.3194455e-3 uWh. PORTANTO,
	; SE AT� OS LEDS S�O DESPREZ�VEIS NO PIOR CASO, ENT�O O MODO POWER-UP TEM
	; GASTO DESPREZ�VEL
	
	; ******* MODO POWER-DOWN *******
	; NOVAMENTE, CONSIDERANDO O PIOR CASO DOS LEDS, TEMOS QUE A POT�NCIA �
	; P_LED = 125mW. A POT�NCIA NO PIOR CASO DO WDT �:
	; P_WDT = 17uA * 5V = 85uW
	; � DITO QUE O PIC12F675 TEM UMA CORRENTE DE BASE DE 995nA NO M�XIMO,
	; ENT�O TEMOS:
	; P_PIC_PD = 995nA * 5V = 4.975uW
	; COMO APENAS UM LED FICA ACESO NO POWER-DOWN, E TODO O RESTO
	; AL�M DO WDT FICAM DESLIGADOS, TEMOS:
	; E_total = E_LED_PD + E_WDT_PD = 125mW*sleep + 85uW*sleep
	; E_total = 0.27517874439 J = 76.438540108333 uWh,
	; ONDE sleep = 2.199934s, MEDIDO PELO MPLAB-X
	
	; ******* CUSTO ENERG�TICO ESTIMADO DESTA APLICA��O ********
	; E_total ~ 76.441 uWh (DANDO 0.002uWh DE DESCONFIAN�A PARA O MODO POWER-UP)

	GOTO	INICIO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
