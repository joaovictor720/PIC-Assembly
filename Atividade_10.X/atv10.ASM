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

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_ON & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

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

		;COLOQUE AQUI SUAS NOVAS VARIÁVEIS
		CONT_WDT
		CONT_FIM_SYNC
		
	ENDC		;FIM DO BLOCO DE DEFINIÇÃO DE VARIÁVEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA
	
	#DEFINE ADDR_PORTS B'00101101' ; GP5 GP3 GP2 GP0
	#DEFINE MEU_ENDERECO B'00101101'
	#DEFINE VRCON_REF B'00100011' ; LOW RANGE, VR3:VR0 = 3, VREF DESLIGADO (MEDIR 0,654V)

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

	ORG	0x00		;ENDEREÇO INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÍCIO DA INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDEREÇO DE DESVIO DAS INTERRUPÇÕES. A PRIMEIRA TAREFA É SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERAÇÃO FUTURA

	ORG	0x04		;ENDEREÇO INICIAL DA INTERRUPÇÃO
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
	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00101111'
	MOVWF	TRISIO		;GP4 É A ÚNICA PORTA DE SAÍDA
	MOVLW	B'00000010'
	MOVWF	ANSEL		;GP1 É A PORTA DE LEITURA ANALÓGICA DO VBAT
	MOVLW	B'00001111'
	MOVWF	OPTION_REG	;PRESCALER 1:128 PRO WDT
	CLRF	INTCON		;SEM INTERRUPÇÕES
	MOVLW	VRCON_REF
	MOVWF	VRCON		;CONFIGURANDO O VRCON (VER CONSTANTES LÁ EM CIMA)
	BANK0			;RETORNA PARA O BANCO
	BCF	ADCON0, ADON
	BCF	T1CON, TMR1ON

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	; VERIFICANDO 0000 NAS PORTAS (SINCRONISMO)
	ESPERAR_SYNC
	MOVFW GPIO
	ANDLW ADDR_PORTS ; OBTENDO OS VALORES NAS PORTAS DE ENDEREÇAMENTO
	BTFSS STATUS, Z ; SE Z = 1, ENTÃO AS PORTAS DE ENDEREÇO TÃO COM 0000
	GOTO ESPERAR_SYNC
	
	; ESPERA OCUPADA ATÉ O FIM DO SINCRONISMO
	MOVLW .17
	MOVWF CONT_FIM_SYNC
	ESPERAR_FIM_SYNC
	DECFSZ CONT_FIM_SYNC
	GOTO ESPERAR_FIM_SYNC
	
	; VERIFICANDO 1111 NAS PORTAS (MEU ENDEREÇO)
	MOVFW GPIO
	ANDLW ADDR_PORTS ; OBTENDO OS VALORES NAS PORTAS DE ENDEREÇAMENTO
	
	; COMPARANDO COM O MEU ENDEREÇO, DE ACORDO COM A POSIÇÃO DAS PORTAS NO BYTE
	SUBLW MEU_ENDERECO
	BTFSS STATUS, Z ; SE FOR IGUAL AO ENDEREÇO, ENTÃO NÃO VOLTAR À LEITURA DE ENDEREÇO
	GOTO MAIN
	
	; LIGANDO O COMPARADOR E VREF
	MOVLW	B'00010100' ; COM INVERSÃO DO COUT
	MOVWF	CMCON ; SE COUT = 1, ENTÃO VBAT ESTÁ ACIMA DO LIMIAR
	BANK1
	BSF VRCON, VREN
	BANK0
	
	; MEDINDO A TENSÃO VBAT COM O COMPARADOR
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
