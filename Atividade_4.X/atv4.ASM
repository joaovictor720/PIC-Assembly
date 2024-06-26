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

	CBLOCK 0x20 ;ENDERE�O INICIAL DA MEM�RIA DE USU�RIO
	
		W_TEMP		;REGISTRADORES TEMPOR�RIOS PARA USO
		STATUS_TEMP	;JUNTO �S INTERRUP��ES

		;COLOQUE AQUI SUAS NOVAS VARI�VEIS
		ENDERECO
		CONTADOR
		RW

	ENDC	;FIM DO BLOCO DE DEFINI��O DE VARI�VEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA
	#DEFINE MEU_ENDERECO 0x28 ; 39 = Endere�o de Jo�o Victor Silva Bezerra Nascimento
	#DEFINE TMR0_50ms .61
	#DEFINE QTD_ATRASO .18

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)
	#DEFINE SCL GP0
	#DEFINE SDA GP1
	#DEFINE	LED GP5

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SA�DAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

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
	
	; VERIFICANDO SE A INTERRUP��O FOI PELO TIMER0
	BTFSC INTCON, T0IF
	GOTO FIM_TMR0
	
	; LENDO O GPIO PARA PERMITIR A LIMPEZA DA FLAG GPIF
	MOVFW GPIO
	BCF INTCON, GPIF ; LIMPAR FLAG DE INTERRUP��O POR PORTA
	
	; VERIFICANDO SE A INTERRUP��O VEIO DE UM BIT DE CONTROLE
	BTFSS GPIO, SCL
	GOTO SAI_INT
	
	; VERIFICANDO SE � UM START BIT (SE SDA = 0, � UM START BIT)
	BTFSC GPIO, SDA
	GOTO SAI_INT
	GOTO START_BIT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SER�O ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUP��ES
	
START_BIT
	CLRF ENDERECO ; LIMPANDO O ENDERECO PARA RECEBER DE SDA
	CLRF RW	; LIMPANDO RW
	MOVLW .7
	MOVWF CONTADOR ; SETANDO CONTADOR DE BITS A SEREM LIDOS
	    
	LER_BIT
	    CALL ESPERAR_SCL_FALL ; ESPERANDO BORDA DE DESCIDA DO SCL (N�O LER SDA AINDA)
	    CALL ESPERAR_SCL_RISE ; ESPERANDO BORDA DE SUBIDA DO SCL

	    ; WREG <- SDA (EXTRAINDO SDA)
	    RRF GPIO, W
	    ANDLW B'00000001'

	    ; CONCATENANDO SDA NO ENDERE�O
	    IORWF ENDERECO
	    BCF STATUS, C ; LIMPANDO FLAG PARA ROTACIONAR COM 0 PARA A ESQUERDA
	    RLF ENDERECO, F

	    ; LER 7 BITS
	    DECFSZ CONTADOR
	    GOTO LER_BIT
	
	; CONSERTANDO BIT EXTRA QUE FOI ROTACIONADO PARA ESQUERDA
	RRF ENDERECO, F
	
	; ESPERANDO BORDA DE DESCIDA DO �LTIMO BIT DE ENDERE�O
	CALL ESPERAR_SCL_FALL
	
	; ESPERANDO BORDA DE SUBIDA DO BIT R/W
	CALL ESPERAR_SCL_RISE
	    
	; WREG <- SDA (EXTRAINDO R/W)
	RRF GPIO, W
	ANDLW B'00000001'
	
	; RW <- SDA
	IORWF RW
	
	; CHECANDO SE ENDERECO = MEU_ENDERECO
	MOVLW MEU_ENDERECO
	SUBWF ENDERECO
	BTFSS STATUS, Z
	GOTO ENDERECO_DIFERENTE
	
	; ESPERANDO CLOCK DESCER PARA MEXER NO ACK
	CALL ESPERAR_SCL_FALL
	CALL CONFIG_ACK ; CONFIGURANDO PIC PARA ENVIAR BIT DE ACKNOWLEDGE
	BCF GPIO, SDA ; CONFIRMANDO RECEBIMENTO DA MENSAGEM
	CALL ESPERAR_SCL_RISE ; ENVIANDO ACK
	CALL ESPERAR_SCL_FALL ; ACK ENVIADO
	
	; CONFIGURANDO TMR0 PARA CONTAR 50ms
	CALL CONFIG_TMR0
	
	BANK1
	BCF TRISIO, SCL ; SETANDO SCL PARA SA�DA
	BANK0
	BCF GPIO, SCL ; SEGURANDO O CLOCK EM LOW
	BSF GPIO, LED ; LIGANDO O LED DE ACKNOWLEDGE
	
	GOTO SAI_INT
	
	ENDERECO_DIFERENTE
	    CALL ESPERAR_SCL_FALL
	    CALL CONFIG_ACK ; CONFIGURANDO PIC PARA ENVIAR BIT DE ACKNOWLEDGE
	    BSF GPIO, SDA ; SETANDO ACK COMO NEGATIVO (N�O RECEBER MAIS DADOS DO I2C)
	    CALL ESPERAR_SCL_RISE
	    
	    ; ESPERANDO SCL DESCER PARA N�O PROVOCAR MUDAN�AS N�O PERMITIDAS NO SDA
	    CALL ESPERAR_SCL_FALL
	    CALL DECONFIG_ACK
	    
	    GOTO SAI_INT
	
FIM_TMR0
	; DESFAZENDO CONFIGURA��ES PARA TMR0
	CALL DECONFIG_TMR0
	CALL DECONFIG_ACK
	CALL ATRASAR ; FAZENDO O LED FICAR LIGADO POR EXATAMENTE 50ms
	BCF GPIO, LED ; DESLIGANDO O LED
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
	
ATRASAR
	MOVLW QTD_ATRASO
	MOVWF CONTADOR
	LOOP_ATRASO
	    DECFSZ CONTADOR
	    GOTO LOOP_ATRASO
	NOP
	RETURN
	
ESPERAR_SCL_RISE
	BTFSS GPIO, SCL
	GOTO ESPERAR_SCL_RISE
	RETURN
	
ESPERAR_SCL_FALL
	BTFSC GPIO, SCL
	GOTO ESPERAR_SCL_FALL
	RETURN
	
CONFIG_ACK
	BANK1
	BCF TRISIO, SDA ; CONFIGURANDO SDA COMO SA�DA PARA ENVIAR O ACK
	BANK0
	RETURN
	
DECONFIG_ACK
	BANK1
	MOVLW B'00000011'
	MOVWF TRISIO
	MOVWF WPU
	BANK0
	RETURN
	
CONFIG_TMR0
	MOVLW TMR0_50ms
	MOVWF TMR0
	BSF INTCON, T0IE ; HABILITANDO INTERRUP��ES PELO TMR0
	BCF INTCON, GPIE ; DESABILITANDO INTERRUP��ES POR PORTAS
	RETURN
	
DECONFIG_TMR0
	BCF INTCON, T0IE
	BSF INTCON, GPIE
	BCF INTCON, T0IF
	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1			;ALTERA PARA O BANCO 1
	
	;GP0 = SCL (ENTRADA PULL-UP)
	;GP1 = SDA (ENTRADA PULL-UP)
	;GP5 = LED (SA�DA)
	MOVLW	B'00000011'
	MOVWF	TRISIO
	MOVWF	WPU		;ATIVA PULL-UP DO SCL E SDA
	
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000111'
	MOVWF	OPTION_REG	;TMR0 PRESCALER 1:256, PULL-UPS HABILITADOS
	
	MOVLW	B'10001000'
	MOVWF	INTCON		;INTERRUP��ES POR PORTAS
	
	MOVLW	B'00000010'
	MOVWF	IOC		;INTERRUP��ES PELO SDA
	
	BANK0			;RETORNA PARA O BANCO 0
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
; ESPERANDO BORDA DE SUBIDA DO SCL (CLOCK DE BITS)