;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      OUTUBRO DE 2022                            *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David José de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 12F675

	; WDT LIGADO, POWER-UP TIMER DESLIGADO, OSCILADOR LP (LOW POWER) ESCOLHIDO
	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_OFF & _WDT_ON & _MCLRE_ON & _INTRC_OSC_NOCLKOUT & _FOSC_LP

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

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE USUÁRIO
	
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES

	ENDC		;FIM DO BLOCO DE DEFINIÇÃO DE VARIÁVEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA
	
	#DEFINE TH_2V .102
	#DEFINE TH_3V .154
	#DEFINE TH_4V .204

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
	
	#DEFINE LED1 GP1
	#DEFINE LED2 GP2
	#DEFINE LED3 GP4
	#DEFINE LED4 GP5

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

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	; ******** CONFIGURAÇÃO ********
	CLRF GPIO
	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'11111111'
	MOVWF	TRISIO		;TODOS OS PINOS INICIAM COM ALTA IMPEDÂNCIA
	MOVLW	B'00010001'
	MOVWF	ANSEL 		;FREQUÊNCIA DE AMOSTRAGEM DO A/D = FOSC/8, GP0 ANALÓGICA
	MOVLW	B'00001111'
	MOVWF	OPTION_REG	;ATRIBUINDO PRESCALER MÁXIMO AO WDT
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BCF	VRCON, VREN	;DESLIGANDO O CVREF
	BANK0			;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DESLIGANDO O COMPARADOR
	CLRF	ADCON0		;LEFT JUSTIFED, AN0, DESLIGADO POR ENQUANTO
	MOVLW	B'01000110'
	MOVWF	T1CON		;DEIXANDO O TMR1 BEM DESLIGADO

	; ******** LÓGICA PRINCIPAL ********
	BSF ADCON0, ADON ; LIGANDO CONVERSOR A/D
	BSF ADCON0, GO
	ESPERAR_MEDIDA
	    BTFSC ADCON0, GO
	    GOTO ESPERAR_MEDIDA
	BCF ADCON0, ADON ; DESLIGANDO O CONVERSOR A/D
	
	; TESTANDO LIMITES DE TENSÃO E LIGANDO OS LEDS CORRESPONDENTES
	BANK1
	BCF TRISIO, LED1 ; TIRANDO O LED1 DE ALTA IMPEDÂNCIA
	BANK0
	BSF GPIO, LED1
	MOVLW TH_2V
	SUBWF ADRESH, W
	BTFSS STATUS, C
	GOTO ADORMECER
	
	BANK1
	BSF TRISIO, LED1 ; RECOLOCANDO O LED1 EM ALTA IMPEDÂNCIA
	BCF TRISIO, LED2 ; TIRANDO O LED2 DE ALTA IMPEDÂNCIA
	BANK0
	BSF GPIO, LED2
	MOVLW TH_3V
	SUBWF ADRESH, W
	BTFSS STATUS, C
	GOTO ADORMECER
	
	BANK1
	BSF TRISIO, LED2 ; RECOLOCANDO O LED2 EM ALTA IMPEDÂNCIA
	BCF TRISIO, LED3 ; TIRANDO O LED2 DE ALTA IMPEDÂNCIA
	BANK0
	BSF GPIO, LED3
	MOVLW TH_4V
	SUBWF ADRESH, W
	BTFSS STATUS, C
	GOTO ADORMECER
	
	BANK1
	BSF TRISIO, LED3 ; RECOLOCANDO O LED3 EM ALTA IMPEDÂNCIA
	BCF TRISIO, LED4 ; TIRANDO O LED2 DE ALTA IMPEDÂNCIA
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

	GOTO	INICIO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
