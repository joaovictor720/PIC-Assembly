;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA√á√ïES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      OUTUBRO DE 2022                            *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David Jos√© de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI√á√ïES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADR√ÉO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINA√á√ÉO DE MEM√ìRIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINI√á√ÉO DE COMANDOS DE USU√ÅRIO PARA ALTERA√á√ÉO DA P√ÅGINA DE MEM√ìRIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEM√ìRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAM√ìRIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARI√ÅVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI√á√ÉO DOS NOMES E ENDERE√áOS DE TODAS AS VARI√ÅVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDERE√áO INICIAL DA MEM√ìRIA DE
					;USU√ÅRIO
		W_TEMP		;REGISTRADORES TEMPOR√ÅRIOS PARA USO
		STATUS_TEMP	;JUNTO √ÄS INTERRUP√á√ïES

		;COLOQUE AQUI SUAS NOVAS VARI√ÅVEIS

		;N√ÉO ESQUE√áA COMENT¡RIOS ESCLARECEDORES

	ENDC			;FIM DO BLOCO DE DEFINI«√O DE VARI¡VEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI√á√ÉO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI√á√ÉO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA
	
	; TMR1_500HZ = .63550 (COM TMR1 PRESCALE DE 1:1)
	#DEFINE TMR1_500HZ_LOW B'00111110'
	#DEFINE TMR1_500HZ_HIGH B'11111000'
	
	#DEFINE VRCON_500mv B'10100011' ; LOW RANGE, N = 3
	#DEFINE VRCON_1000mv B'10100101' ; LOW RANGE, N = 5
	#DEFINE VRCON_1500mv B'10100111' ; LOW RANGE, N = 7
	#DEFINE VRCON_2000mv B'10101010' ; LOW RANGE, N = 10
	#DEFINE VRCON_2500mv B'10101100' ; LOW RANGE, N = 12
	#DEFINE VRCON_3000mv B'10101110' ; LOW RANGE, N = 14
	#DEFINE VRCON_3500mv B'10001110' ; HIGH RANGE, N = 14
	
	; CONSIDERANDO UM PRESCALER DE 1:8
	#DEFINE MINIMAL_DUTY_CYCLE .255
	#DEFINE TMR0_100us .253
	#DEFINE TMR0_200us .234
	#DEFINE TMR0_400us .212
	#DEFINE TMR0_600us .186
	#DEFINE TMR0_800us .161
	#DEFINE TMR0_1600us .59

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI«√O DE TODOS OS PINOS QUE SER√O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB…M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SAÕDAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI«√O DE TODOS OS PINOS QUE SER√O UTILIZADOS COMO SA√çDA
; RECOMENDAMOS TAMB…M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)
	
	#DEFINE LED GP5

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDERE√áO INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    IN√çCIO DA INTERRUP√á√ÉO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDERE√áO DE DESVIO DAS INTERRUP√á√ïES. A PRIMEIRA TAREFA √â SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERA√á√ÉO FUTURA

	ORG	0x04			;ENDERE√áO INICIAL DA INTERRUP√á√ÉO
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP
	
	; VERIFICANDO SE INTERRUP«√O FOI PELO FIM DO PERÕODO
	BTFSS PIR1, TMR1IF
	GOTO FIM_DUTY_CYCLE
	
	BSF GPIO, LED ; LIGANDO O LED AO FINAL DO TMR1 (CONTADOR DO PERÕODO)
	; REINICIANDO CONTADOR DE PERÕODO
	MOVLW TMR1_500HZ_LOW
	MOVWF TMR1L
	MOVLW TMR1_500HZ_HIGH
	MOVWF TMR1H
	
	; COMPARAR COM 100%
	MOVLW VRCON_3500mv
	BANK1
	MOVWF VRCON
	BANK0
	BTFSC CMCON, COUT
	GOTO ATIVAR_DUTY_CYCLE
	
	; SE TENS√O FOR MAIOR QUE 3,5V (DUTY CYCLE 100%)
	BCF INTCON, T0IE ; DESLIGAR TMR0
	BCF PIR1, TMR1IF ; LIMPAR FLAG
	GOTO SAI_INT
	
	; CASO CONTR¡RIO, LIMPAR E LIGAR INTERRUP«’ES PELO TMR0
	ATIVAR_DUTY_CYCLE
	BSF INTCON, T0IE ; GARANTINDO ATIVA«√O DE INTERRUP«’ES PELO TMR0
	BCF PIR1, TMR1IF ; LIMPANDO FLAG DO TMR1
	
	; COMPARAR SE EST¡ ACIMA DE 5%
	MOVLW VRCON_500mv
	BANK1
	MOVWF VRCON
	BANK0
	BTFSS CMCON, COUT
	GOTO INTERVALO_NAO_MINIMO
	BCF GPIO, LED ; ADIANTANDO DESLIGAMENTO DO LED
	MOVLW MINIMAL_DUTY_CYCLE ; FAZENDO DUTY_CYCLE DURAR O MÕNIMO POSSÕVEL
	MOVWF TMR0
	GOTO SAI_INT
	
	; SETAR TMR0 PARA O INTERVALO CORRESPONDENTE
	INTERVALO_NAO_MINIMO
	MOVLW TMR0_1600us
	MOVWF TMR0
	
	; COMPARAR SE EST¡ ACIMA DE 80%
	MOVLW VRCON_3000mv
	BANK1
	MOVWF VRCON
	BANK0
	BTFSS CMCON, COUT
	GOTO SAI_INT
	MOVLW TMR0_800us
	MOVWF TMR0
	
	; COMPARAR SE EST¡ ACIMA DE 40%
	MOVLW VRCON_2500mv
	BANK1
	MOVWF VRCON
	BANK0
	BTFSS CMCON, COUT
	GOTO SAI_INT
	MOVLW TMR0_600us
	MOVWF TMR0
	
	; COMPARAR SE EST¡ ACIMA DE 30%
	MOVLW VRCON_2000mv
	BANK1
	MOVWF VRCON
	BANK0
	BTFSS CMCON, COUT
	GOTO SAI_INT
	MOVLW TMR0_400us
	MOVWF TMR0
	
	; COMPARAR SE EST¡ ACIMA DE 20%
	MOVLW VRCON_1500mv
	BANK1
	MOVWF VRCON
	BANK0
	BTFSS CMCON, COUT
	GOTO SAI_INT
	MOVLW TMR0_200us
	MOVWF TMR0
	
	; COMPARAR SE EST¡ ACIMA DE 10%
	MOVLW VRCON_1000mv
	BANK1
	MOVWF VRCON
	BANK0
	BTFSS CMCON, COUT
	GOTO SAI_INT
	MOVLW TMR0_100us
	MOVWF TMR0
	GOTO SAI_INT
	
	FIM_DUTY_CYCLE
	BCF GPIO, LED ; DESLIGANDO LED AO FINAL DO TMR0 (CONTADOR DO DUTY CYCLE)
	BCF INTCON, T0IF

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUP√á√ÉO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SER√ÉO ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUP√á√ïES

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SA√çDA DA INTERRUP√á√ÉO                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUP√á√ÉO

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRI√á√ÉO DE FUNCIONAMENTO
; E UM NOME COERENTE √ÄS SUAS FUN√á√ïES.

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	;APAGANDO TUDO DA SAÕDA NO RESET
	CLRF GPIO
	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00000010'
	MOVWF	TRISIO		;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVLW	B'00000010'
	MOVWF	ANSEL 		;LEITURAS DE NÕVEL DO DIMMER PELO GP1
	MOVLW	B'00000010'
	MOVWF	OPTION_REG	;DEFINE OP«’ES DE OPERA«√O
	MOVLW	B'11000000'
	MOVWF	INTCON		;HABILITANDO INTERRUP«’ES POR PERIF…RICOS
	MOVLW	B'00000001'
	MOVWF	PIE1		;HABILITANDO INTERRUP«’ES PELO TMR1
	BANK0			;RETORNA PARA O BANCO
	MOVLW	B'00000100'
	MOVWF	CMCON		;CIN- = GP1, CIN+ = CVREF, COUT SEPARADO
	MOVLW	B'00000101'
	MOVWF	T1CON		;HABILITANDO CONTAGEM DO TMR1

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA√á√ÉO DAS VARI√ÅVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
	; GARANTINDO QUE ESSA FEBRE DE LED FIQUE DESLIGADO NO RESET
	CLRF GPIO
	
	; INICIALIZANDO TMR1 PARA CONTAR 2ms
	MOVLW TMR1_500HZ_LOW
	MOVWF TMR1L
	MOVLW TMR1_500HZ_HIGH
	MOVWF TMR1H

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN

	;CORPO DA ROTINA PRINCIPAL

	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
