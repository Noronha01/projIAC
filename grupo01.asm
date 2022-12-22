;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Projeto IAC - 2ª versão 												
; Alunos: Bárbara Reis Silva - 1102545									
;         Pedro Guilherme de Noronha Guimarães - 1102543    			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Definição de constantes 												
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PIN 			   EQU 0E000H; endereço periférico de entrada de 8 bits
DISPLAYS           EQU 0A000H; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN  		   EQU 0C000H; endereço das linhas do teclado (periférico POUT-2)
TEC_COL  		   EQU 0E000H; endereço das colunas do teclado (periférico PIN)
LINHA    		   EQU 8     ; linha inicial (4ª linha, 1000b)
MASCARA  		   EQU 0FH   ; máscara para isolar 4 bits de menor peso ao ler colunas do teclado

NULL     		   EQU 0000H ; nulo

RESET_TECLA        EQU 0010H ; começa-se a variável TECLA_PREMIDA com o valor 17

APAGA_ECRÃ_X       EQU 6000H ; endereço do comando para apagar todos os pixels de um ecrã específico
APAGA_ECRÃ	 	   EQU 6002H ; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_ECRÃ     EQU 6004H ; endereço do comando para selecionar um ecrã específico
APAGA_AVISO        EQU 6040H ; endereço d comando para apagar o aviso de nenhum cenário selecionado
SELECIONA_CENARIO  EQU 6042H ; endereço do comando para selecionar uma imagem de fundo

DEFINE_LINHA       EQU 600AH ; define a linha pixel screen 
DEFINE_COLUNA      EQU 600CH ; define a coluna pixel screen
DEFINE_PIXEL       EQU 6012H ; endereço dos pixeis 

LIMITE_DIREITO     EQU 003CH ; limite direito do ecrã
LIMITE_ESQUERDO    EQU 0000H ; limite esquerdo do ecrã
MASCARA_COLUNA     EQU 00FFH ; máscara para isolar os dois bits de menor peso (coordenada coluna)

COR_ROVER          EQU 0ECDDH; endereço cor do rover
COR_ROVER1         EQU 0FFFFH; endereço de outra cor do rover

COR_METEOR_INICIAL EQU 6EF4H ; cor dos dois meteoros iniciais de cada meteoro bom ou mau

COR_METEOR_MAU     EQU 0EFF6H; cor do meteoro inimigo

COR_EXPLOSAO       EQU 0EF46H; cor da imagem da explosão

COR_METEOR_BOM     EQU 0EB5FH; cor do meteoro bom
COR_METEOR_BOM1    EQU 0FB6FH; outra cor do meteoro bom 
COR_METEOR_BOM2    EQU 0DB5FH; outra cor do meteoro bom

COR_LETRAS         EQU 0F8ECH; cor das letras desenhadas
COR_LETRAS1        EQU 0F6F8H; outra cor para letras desenhadas

COR_MISSIL         EQU 0F7E7H; cor do míssil

HEXTODEC           EQU 000AH ; variável auxiliar na conversão de hexadecimal para decimal

SELECIONA_SOM      EQU 6048H ; endereço dos sons guardados no media center
REPRODUZ_SOM       EQU 605AH ; endereço para reproduzir som 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inicialização do Stack pointer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PLACE 1000H

	STACK 500H               ; endereço do stack pointer (2000H)
SP_inicial:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Declaração de variáveis												
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LINHA_TECLA:       WORD NULL ; guarda a linha da tecla premida
COLUNA_TECLA:      WORD NULL ; guarda a coluna da tecla premida
TECLA_PREMIDA:     WORD RESET_TECLA     ; guarda a tecla premida após conversão
ULTIMA_TECLA:      WORD RESET_TECLA     ; guarda última tecla premida

ENERGIA_ROVER:     BYTE NULL ; guarda a energia do rover representada nos displays

POSICAO_ROVER:     WORD 1F1EH; guarda a posição inicial do rover

interrupcoes:
	WORD rotina_0            ; rotina de interrupção para os meteoros avançarem
	WORD rotina_1            ; rotina de interrupção para o míssil avançar
	WORD rotina_2            ; rotina de interrupção para a energia do rover diminuir

eventos_int:
	WORD 0                   ; se 1 indica que os meteoros podem avançar
	WORD 0                   ; se 1 indica que o míssil pode avançar
	WORD 0                   ; se 1 indica que a energia do rover pode dimuir

METEOROS_MAUS_LISTA:         ; lista com a posição dos três meteoros maus
	WORD NULL, NULL, NULL

METEORO_BOM:       WORD NULL ; posição do meteoro bom

AVANÇA_ROVER:      WORD NULL ; contador para saber se o rover pode avançar ou não


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Tabelas de imagens 
; - Primeira WORD -> coordenadas X e Y da imagem em hexa (linha x coluna)
; - Segunda WORD  -> altura e largura da imagem
; - Restantes     -> pixeis a pintar com as respetivas cores
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ROVER:
	WORD POSICAO_ROVER       ; linha x coluna
	WORD 0405H               ; altura x largura
	WORD             0, COR_ROVER, 0, COR_ROVER, 0  
	WORD COR_ROVER, COR_ROVER1, COR_ROVER, COR_ROVER1, COR_ROVER
	WORD        COR_ROVER1, 0, COR_ROVER1, 0, COR_ROVER1
	WORD                 0, 0, COR_ROVER1, 0, 0

METEORO_INICIAL_P:
	WORD NULL
	WORD 0101H
	WORD COR_METEOR_INICIAL

METEORO_INICIAL_G:
	WORD NULL
	WORD 0202H
	WORD COR_METEOR_INICIAL, COR_METEOR_INICIAL
	WORD COR_METEOR_INICIAL, COR_METEOR_INICIAL

METEORO_BOM_P:
	WORD NULL
	WORD 0303H
	WORD              0, COR_METEOR_BOM, 0
	WORD COR_METEOR_BOM, COR_METEOR_BOM, COR_METEOR_BOM
	WORD              0, COR_METEOR_BOM, 0

METEORO_BOM_M:
	WORD NULL
	WORD 0404H
	WORD              0, COR_METEOR_BOM, COR_METEOR_BOM, 0
	WORD COR_METEOR_BOM, COR_METEOR_BOM, COR_METEOR_BOM, COR_METEOR_BOM
	WORD COR_METEOR_BOM, COR_METEOR_BOM, COR_METEOR_BOM, COR_METEOR_BOM
	WORD              0, COR_METEOR_BOM, COR_METEOR_BOM, 0

METEORO_BOM_G:
	WORD NULL                
	WORD 0505H			
	WORD              0, COR_METEOR_BOM1, COR_METEOR_BOM1, COR_METEOR_BOM, 0
	WORD COR_METEOR_BOM2, COR_METEOR_BOM, COR_METEOR_BOM2, COR_METEOR_BOM2, COR_METEOR_BOM
	WORD COR_METEOR_BOM2, COR_METEOR_BOM, COR_METEOR_BOM, COR_METEOR_BOM2, COR_METEOR_BOM1
	WORD COR_METEOR_BOM, COR_METEOR_BOM1, COR_METEOR_BOM1, COR_METEOR_BOM1, COR_METEOR_BOM
	WORD              0, COR_METEOR_BOM, COR_METEOR_BOM1, COR_METEOR_BOM, 0

METEORO_MAU_P:
	WORD NULL
	WORD 0303H
	WORD COR_METEOR_MAU, 0, COR_METEOR_MAU
	WORD 	   0, COR_METEOR_MAU, 0
	WORD COR_METEOR_MAU, 0, COR_METEOR_MAU

METEORO_MAU_M:
	WORD NULL
	WORD 0404H
	WORD COR_METEOR_MAU, 0, 0, COR_METEOR_MAU
	WORD COR_METEOR_MAU, 0, 0, COR_METEOR_MAU
	WORD 0, COR_METEOR_MAU, COR_METEOR_MAU, 0
	WORD COR_METEOR_MAU, 0, 0, COR_METEOR_MAU

METEORO_MAU_G:
	WORD NULL                
	WORD 0505H				 
	WORD       COR_METEOR_MAU, 0, 0, 0, COR_METEOR_MAU
	WORD COR_METEOR_MAU, 0, COR_METEOR_MAU, 0, COR_METEOR_MAU
	WORD 0, COR_METEOR_MAU, COR_METEOR_MAU, COR_METEOR_MAU, 0
	WORD COR_METEOR_MAU, 0, COR_METEOR_MAU, 0, COR_METEOR_MAU
	WORD       COR_METEOR_MAU, 0, 0, 0, COR_METEOR_MAU

MISSIL:
	WORD NULL
	WORD 0101H
	WORD 0F7E7H

EXPLOSAO:
	WORD NULL
	WORD 0505H
	WORD       0, COR_EXPLOSAO, 0, COR_EXPLOSAO, 0
	WORD COR_EXPLOSAO, 0, COR_EXPLOSAO, 0, COR_EXPLOSAO
	WORD       0, COR_EXPLOSAO, 0, COR_EXPLOSAO, 0
	WORD COR_EXPLOSAO, 0, COR_EXPLOSAO, 0, COR_EXPLOSAO
	WORD       0, COR_EXPLOSAO, 0, COR_EXPLOSAO, 0 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Tabelas de imagens por coordenads de pixeis 
; - Primeira WORD -> cor do pixel
; - Restantes     -> coordenadas dos pixeis a pintar 											
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MENU_INICIAL_LETRAS:
	WORD COR_ROVER
	WORD 0403H, 0404H, 0405H, 0407H, 0409H, 040BH, 040DH, 040FH, 0413H, 0415H, 0416H, 0417H
	WORD 0503H, 0507H, 0509H, 050BH, 050DH, 0510H, 0512H, 0515H, 0517H
	WORD 0603H, 0607H, 0608H, 0609H, 060BH, 060DH, 0610H, 0612H, 0615H, 0616H, 0617H
	WORD 0703H, 0707H, 0709H, 070BH, 070DH, 0711H, 0715H, 0717H
	WORD 0803H, 0804H, 0805H, 0807H, 0809H, 080BH, 080CH, 080DH, 0811H, 0815H, 0817H
	WORD 0C17H, 0C18H, 0C1BH, 0C1CH, 0C1DH
	WORD 0D17H, 0D19H, 0D1BH
	WORD 0E17H, 0E19H, 0E1BH, 0E1CH
	WORD 0F17H, 0F19H, 0F1BH
	WORD 1017H, 1018H, 101BH, 101CH, 101DH
	WORD 131DH, 1321H, 1323H, 1324H, 1325H, 1327H, 1328H, 1329H, 132BH, 132CH, 132DH, 132FH
	WORD 1330H, 1331H, 1333H, 1334H, 1335H, 1337H, 1338H, 1339H, 133CH, 133DH
	WORD 141DH, 141EH, 1420H, 1421H, 1423H, 1428H, 142BH, 142FH, 1431H, 1433H, 1435H
	WORD 1437H, 1439H, 143BH
	WORD 151DH, 151FH, 1521H, 1523H, 1524H, 1528H, 152BH, 152CH, 152FH, 1531H, 1533H, 1534H
	WORD 1537H, 1539H, 153BH, 153CH
	WORD 161DH, 1621H, 1623H, 1628H, 162BH, 162FH, 1631H, 1633H, 1635H, 1637H, 1639H, 163DH
	WORD 171DH, 1721H, 1723H, 1724H, 1725H, 1728H, 172BH, 172CH, 172DH, 172FH, 1730H, 1731H
	WORD 1733H, 1735H, 1737H, 1738H, 1739H, 173BH, 173CH, 0000H


MENU_PAUSA_LETRAS:
	WORD COR_LETRAS
	WORD 0B16H, 0B17H, 0B18H, 0B1AH, 0B1BH, 0B1CH, 0B1EH, 0B20H,0B22H, 0B23H, 0B24H, 0B26H, 0B27H, 0B28H
	WORD 0C16H, 0C18H, 0C1AH, 0C1CH, 0C1EH, 0C20H, 0C22H, 0C26H, 0C28H
	WORD 0D16H, 0D17H, 0D18H, 0D1AH, 0D1BH, 0D1CH, 0D1EH, 0D20H, 0D22H, 0D23H, 0D24H, 0D26H, 0D27H, 0D28H 
	WORD 0E16H, 0E1AH, 0E1CH, 0E1EH, 0E20H, 0E24H, 0E26H, 0E28H
	WORD 0F16H, 0F1AH, 0F1CH, 0F1EH, 0F1FH, 0F20H, 0F22H, 0F23H, 0F24H, 0F26H, 0F28H
	WORD 1128H, 1129H
	WORD 1214H, 1215H, 1216H, 1218H, 121CH, 121EH, 121FH, 1220H, 1222H, 1223H, 1224H, 1228H, 122AH
	WORD 1314H, 1318H, 131CH, 131EH, 1322H, 1324H, 1328H, 132AH
	WORD 1414H, 1415H, 1416H, 1418H, 1419H, 141AH, 141CH, 141EH, 141FH, 1420H, 1422H, 1423H, 1424H, 1425H 
	WORD 1428H, 1429H, 0000H


MENU_GAME_OVER:
	WORD COR_LETRAS1
	WORD 0916H, 0917H, 0918H, 0919H, 091BH, 091CH, 091DH, 091EH, 0920H, 0921H, 0923H, 0924H, 0926H
	WORD 0927H, 0928H, 0929H
	WORD 0A16H, 0A1BH, 0A1EH, 0A20H, 0A22H, 0A24H, 0A26H
	WORD 0B16H, 0B18H, 0B19H, 0B1BH, 0B1CH, 0B1DH, 0B1EH, 0B20H, 0B24H, 0B26H, 0B27H, 0B28H
	WORD 0C16H, 0C19H, 0C1BH, 0C1EH, 0C20H, 0C24H, 0C26H
	WORD 0D16H, 0D17H, 0D18H, 0D19H, 0D1BH, 0D1EH, 0D20H, 0D24H, 0D26H, 0D27H, 0D28H, 0D29H
	WORD 1016H, 1017H, 1018H, 1019H, 101BH, 101FH, 1021H, 1022H, 1023H, 1024H, 1026H, 1027H, 1028H, 1029H
	WORD 1116H, 1119H, 111BH, 111FH, 1121H, 1126H, 1129H
	WORD 1216H, 1219H, 121CH, 121EH, 1221H, 1222H, 1223H, 1226H, 1227H, 1228H
	WORD 1316H, 1319H, 131CH, 131EH, 1321H, 1326H, 1329H
	WORD 1416H, 1417H, 1418H, 1419H, 141DH, 1421H, 1422H, 1423H, 1424H, 1426H, 1429H, 0000H


CLICA_E_LETRAS:
	WORD COR_LETRAS
	WORD 1729H, 172AH, 172BH
	WORD 1815H, 1816H, 1817H, 1819H, 181DH, 181FH, 1820H, 1821H, 1823H, 1824H, 1825H, 1829H 
	WORD 1915H, 1919H, 191DH, 191FH, 1923H, 1925H, 1929H, 192AH
	WORD 1A15H, 1A16H, 1A17H, 1A19H, 1A1AH, 1A1BH, 1A1DH, 1A1FH, 1A20H, 1A21H, 1A23H, 1A24H 
	WORD 1A25H, 1A26H, 1A29H
	WORD 1B29H, 1B2AH, 1B2BH, 0000H


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Código												          		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PLACE 0

;************************************************************************************
; Inicialização programa
; PROGRAMA_INIT - inicializa o programa 
; MENU_INIT - inicializa o menu do jogo com o seu cenário de fundo, desenha o nome
;			  do jogo e espera que a tecla 'C' seja premida para iniciar o jogo
; JOGO_INIT - inicializa o jogo após a tecla 'C' ser premida, colocando o novo 
;			  cenário de fundo e desenhando o rover
;************************************************************************************

programa_init:               ; inicializa programa
	MOV  SP, SP_inicial      ; inicializa o stack pointer

	MOV  BTE, interrupcoes   ; inicializa o registo de Base de Tabela de Exceções

	MOV  [APAGA_AVISO], R0	 ; apaga o aviso de nenhum cenário selecionado
	MOV  [APAGA_ECRÃ], R0	 ; apaga todos os pixels já desenhados
    MOV  R1, DISPLAYS        ; coloca o endereço dos displays em R1
    MOV  R0, 0
    MOV  [R1], R0            ; inicializa os displays a zero
    MOV  [ENERGIA_ROVER], R0 ; inicializa a energia do rover a zero

    EI0						 ; permite interrupções 0
    EI1                      ; permite interrupções 1
    EI2                      ; permite interrupções 2
    EI                       ; permite interrupções (geral)


menu_init:                   ; inicializa o menu do jogo
    MOV  [SELECIONA_CENARIO], R0	; seleciona o cenário de fundo 0 do menu

    MOV  R0, MENU_INICIAL_LETRAS    ; coloca a tabela das letras iniciais em R0
    CALL desenha_pixeis

    CALL espera_c            ; esperar até a tecla 'C' ser pressionada para começar o jogo

    MOV  R0, 5
	MOV  [SELECIONA_SOM], R0
	MOV  [REPRODUZ_SOM], R0  ; reproduz som de início de jogo

    MOV  R0, 256             ; 256 é 100 em hexadecimal
    MOV  [R1], R0            ; coloca 100 nos displays
    MOV  R0, 100
    MOV  [ENERGIA_ROVER], R0 ; inicializa a energia do rover a 100


jogo_init:                   ; inicializa o jogo após se premir a tecla para iniciar o jogo
	MOV  [APAGA_ECRÃ], R0    ; apaga as imagems de fundo anteriores
	MOV  R0, 1
	MOV  [SELECIONA_CENARIO], R0 ; seleciona o cenário de fundo 1

	CALL rover_init          ; inicializa o rover
	CALL avanca_rover_init   ; inicializa contador para rover andar a 0 
	CALL tabela_meteoros_init ; inicializa tabela de posições de meteoros maus a zeros
	CALL meteoro_bom_init    ; inicializa a posição do meteoro bom na 2ª coluna
	CALL missil_init         ; inicializa a posição do míssil a 0
	CALL teclas_init         ; inicializa as variáveis TECLA_PREMIDA e ULTIMA_TECLA 
	CALL eventos_int_init    ; inicializa as 'autorizações' dos relógios a 0

	JMP  main


rover_init:                  ; inicializa e desenha o rover no ecrã 6 na posição inicial
	PUSH R2
	PUSH R3

	MOV  R2, [ROVER]			 
    MOV  R2, [POSICAO_ROVER]
    MOV  [ROVER], R2
    MOV  R3, 6
    MOV  [SELECIONA_ECRÃ], R3 
    MOV  R2, ROVER            
    CALL desenha_imagem      ; desenha o rover

    POP  R3
    POP  R2
    RET

avanca_rover_init:           ; inicializa contador para rover andar a 0
	PUSH R0
	PUSH R1

	MOV  R0, AVANÇA_ROVER
	MOV  R1, 0
	MOV  [R0], R1 

	POP  R1
	POP  R0
    RET

tabela_meteoros_init:		 ; inicializa tabela de posições de meteoros maus na 2ª colunna
	PUSH R0
	PUSH R1

	MOV  R0, METEOROS_MAUS_LISTA
	MOV  R1, 0002H
	MOV  [R0], R1
	MOV  [R0+2], R1
	MOV  [R0+4], R1

	POP  R1
	POP  R0
	RET

meteoro_bom_init:            ; inicializa a posição do meteoro bom na 2ª coluna
	PUSH R0

	MOV  R0, 0002H
	MOV  [METEORO_BOM], R0

	POP  R0
	RET

missil_init:                 ; inicializa a posição do míssil a 0
	PUSH R0
	PUSH R1

	MOV  R0, MISSIL 
	MOV  R1, 0
	MOV  [R0], R1

	POP  R1
	POP  R0
	RET

teclas_init:                 ; inicializa as variáveis TECLA_PREMIDA E ÚLTIMA TECLA a 17
	PUSH R0

	MOV  R0, 17
	MOV  [TECLA_PREMIDA], R0
	MOV  [ULTIMA_TECLA], R0

	POP  R0
	RET

eventos_int_init:            ; inicializa as 'autorizações' dos relógios a 0
	PUSH R0
	PUSH R1

	MOV  R0, eventos_int
	MOV  R1, 0
	MOV  [R0], R1
	MOV  [R0+2], R1
	MOV  [R0+4], R1

	POP  R1
	POP  R0
	RET


;************************************************************************************
; Ciclo principal do programa
; MAIN - chama todas as rotinas necessárias para o funcionamento do jogo (rotinas 
;        cooperativas)
;************************************************************************************

main:                        
	CALL teclado             ; percorre o teclado à procura de uma tecla premida
	CALL acao_tecla          ; realiza as ações correspondentes à última tecla premida
	CALL cria_ou_desce_meteoros_maus ; cria ou desce meteoros maus
	CALL cria_ou_desce_meteoro_bom ; cria ou desce meteoros bons
	CALL ha_colisao_missil   ; verifica se o míssel colidiu com algum meteoro
	CALL sobe_missil         ; sobe o míssil se existir algum no ecrã
	CALL desce_energia       ; desce a energia do rover de 3 em 3 seg em 5 pontos 
	

	JMP  main                ; repete o ciclo


;************************************************************************************
; TECLADO - percorre o teclado à procura de uma tecla premida; se uma tecla for 
;			premida guarda-a numa variável para uso futuro; se nenhuma tecla for 
;			premida sai do ciclo para dar oportunidade a outras ações de acontecerem
;************************************************************************************

teclado:                     ; lê teclado e reconhece a tecla premida
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4

	MOV  R0, TEC_LIN         ; endereço das linhas
	MOV  R1, TEC_COL         ; endereço das colunas
	MOV  R2, MASCARA         ; máscara das linhas
	MOV  R3, LINHA           ; última linha do teclado
	MOV  R4, NULL

	CALL varre_teclado       ; varre as 4 linhas do teclado em busca de tecla premida

	POP  R4
	POP  R3
	POP  R2
	POP  R1
	POP  R0

	RET

varre_teclado:               ; percorre o teclado em busca de tecla premida
	MOVB [R0], R3            ; escreve no periférico de saída (linhas)
    MOVB R4, [R1]            ; lê do periférico de entrada (colunas)
    AND  R4, R2              ; elimina bits para além dos bits 0-3
    CMP  R4, 0               ; há tecla premida?
    JNZ  return_tecla        ; verifica enquanto a tecla está premida
    SHR  R3, 1               ; passa para a linha anterior
    CMP  R3, 0               ; se chegar à primeira linha sem nenhuma tecla premida
    JNZ  varre_teclado       ; corre colunas da linha anterior se nenhuma tecla premida
    CALL reset_tecla_premida ; caso nenhuma tecla tenha sido premida após teclado percorrido, faz reset da variável TECLA_PREMIDA
    RET

reset_tecla_premida:         ; faz reset da variável TECLA_PREMIDA
	PUSH R0
	MOV  R0, 17
	MOV  [TECLA_PREMIDA], R0 ; coloca a variável TECLA_PREMIDA com o seu valor de origem
	POP  R0
	RET

return_tecla:                ; guarda a linha e coluna da tecla premida em variáveis em memória para uso futuro
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4

	MOV  R1, LINHA_TECLA  
	MOV  [R1], R3	         ; guarda a linha da tecla premida na variável LINHA_TECLA
	MOV  R0, COLUNA_TECLA 
	MOV  [R0], R4            ; guarda a coluna da tecla premida na variável COLUNA_TECLA

 	CALL converte_tecla      ; calcula qual é a tecla premida a partir das suas linha e coluna

 	POP  R4
 	POP  R3
	POP  R2
	POP  R1
	POP  R0

	RET

converte_tecla:              ; calcula qual é a tecla premida a partir das suas linha e coluna

	MOV  R0, [LINHA_TECLA]   ; coloca linha da tecla premida em R0
	MOV  R1, [COLUNA_TECLA]  ; coloca coluna da tecla premida em R1
	MOV  R2, 0               ; linha da tecla premida
	MOV  R3, 0               ; coluna da tecla premida
	MOV  R4, 4               ; número de colunas de uma linha

	CALL converte_linha		 ; converte a linha de 1, 2, 4, 8 para 0, 1, 2, 3, respetivamente 
	CALL converte_coluna     ; converte colunas de 1, 2, 4, 8 para 0, 1, 2, 3, respetivamente

	MUL  R2, R4
	ADD  R2, R3				 ; R2 é a tecla premida convertida

	MOV  R0, TECLA_PREMIDA 	
	MOV  [R0], R2            ; guarda a tecla premida convertida na variável TECLA_PREMIDA
	
	RET

converte_linha:              ; converte a linha de 1, 2, 4, 8 para 0, 1, 2, 3, respetivamente
	ADD  R2, 1
	SHR  R0, 1
	JNZ  converte_linha
	SUB  R2, 1
	RET

converte_coluna:             ; converte colunas de 1, 2, 4, 8 para 0, 1, 2, 3, respetivamente
	ADD  R3, 1
	SHR  R1, 1
	JNZ  converte_coluna
	SUB  R3, 1
	RET	


;************************************************************************************
; ACAO_TECLA - realiza a ação correspondente à tecla que foi premida, tanto ações
;			   contínuas (rover a andar) como não contínuas (lançar míssil, pausar, 
;			   continuar a jogar, terminar, recomeçar jogo)
;************************************************************************************

acao_tecla:
	PUSH R0
	PUSH R1

	MOV  R0, [TECLA_PREMIDA]
	MOV  R1, [ULTIMA_TECLA]
	
	CMP  R0, 2
	JZ   mover_rover         ; tecla '2' move o rover para a direita
	CMP  R0, 0
	JZ   mover_rover         ; tecla '0' move o rover para a esquerda 

	CMP  R1, R0              ; a última tecla é igual à que foi premida agora?
	JNZ  acao_nao_continua   ; se não é igual realiza a ação

	JMP  return_acao

acao_nao_continua:           ; realiza ações não contínuas 
	CMP  R0, 1
	JZ   dispara_missil      ; tecla '1' dispara o míssil
	
	MOV  R1, 13              ; 13 corresponde à tecla 'D'
	CMP  R0, R1         
	JZ   pausa               ; tecla 'D' coloca o jogo em pausa

	MOV  R1, 14              ; 14 corresponde à tecla 'E'
	CMP  R0, R1
	JZ   game_over_opcional  ; tecla 'E' termina o jogo

return_acao:   
	MOV  R1, ULTIMA_TECLA
	MOV  [R1], R0            ; coloca a tecla premida na ULTIMA_TECLA para comparação no próximo ciclo

	POP  R1
	POP  R0

	RET


;************************************************************************************
; MOVER_ROVER - move o rover para a direita ou para a esquerda (apaga-o na sua 
;				posição atual e desenha-o na nova posição um pixel para a direita 
;				ou para a esquerda) 
;************************************************************************************

mover_rover:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5

	MOV  R1, [AVANÇA_ROVER]  ; variável contador para atrasar o rover
	CMP  R1, 7               ; o rover pode andar?
	JNZ  return_move_rover   ; se não poder sai da rotina

	CALL avanca_rover_init  ; se puder andar volta a inicializar o contador para atrasar a zero

	MOV  R2, [ROVER]          ; coordenadas do rover em R2

	CMP  R0, 2                ; verifica se a tecla premida corresponde para a direita ou para a esquerda
	JZ   move_rover_direita
	JMP  move_rover_esquerda

move_rover_direita:          ; move rover para a direita
	ADD  R2, 1                ; adiciona uma coluna à coordenada do pixel inferior esquerdo do rover 
	MOV  R3, LIMITE_DIREITO   ; limite direito do ecrã em R3
	MOV  R4, MASCARA_COLUNA   ; máscara para isolar a coordenada da coluna em R4
	MOV  R5, R2               ; backup coordenada do rover para R5
	AND  R5, R4               ; isola coordenada da coluna
	CMP  R5, R3               ; verifica se o movimento não coloca rover fora dos limites do ecrã
	JGE  return_move_rover    ; se movimento for inválido sai da rotina
	JMP  mexe_rover      

move_rover_esquerda:          ; move rover para a esquerda
	SUB  R2, 1                ; subtrai uma coluna à coordenada do pixel inferior esquerdo do rover 
	MOV  R3, LIMITE_ESQUERDO  ; limite direito do ecrã em R3
	MOV  R4, MASCARA_COLUNA   ; máscara para isolar a coordenada da coluna em R4
	MOV  R5, R2               ; backup coordenada do rover para R5
	ADD  R5, 1                ; adiciona 1 às coordenadas em R5 para fazer JLE e só parar no zero
	AND  R5, R4               ; isola coordenada da coluna
	CMP  R5, R3               ; verifica se o movimento não coloca rover fora dos limites do ecrã
	JLE  return_move_rover    ; se o movimento for inválido sai da rotina
	JMP  mexe_rover 

mexe_rover:
	MOV  R0, 6
	MOV  [APAGA_ECRÃ_X], R0  ; apaga todos os pixels do ecrâ 1
	MOV  [ROVER], R2         ; atualiza novas coordenadas do rover
	MOV  [SELECIONA_ECRÃ], R0
	MOV  R2, ROVER           ; coloca rover em R2 para imprimir
	CALL desenha_imagem      ; desenha rover

	JMP  return_move_rover        

return_move_rover:
	MOV  R0, [AVANÇA_ROVER]
	ADD  R0, 1               ; incrementa o contador para avançar o rover
	MOV  [AVANÇA_ROVER], R0

	POP  R5
	POP  R4
 	POP  R3
	POP  R2
	POP  R1
	POP  R0

	JMP  return_acao


;************************************************************************************
; GAME_OVER_OPCIONAL - ação que termina o jogo de forma voluntária se for premida a 
;                      tecla 'E'
;************************************************************************************

game_over_opcional:
	MOV  R0, 4
	MOV  [SELECIONA_CENARIO], R0        ; dispõe cenário 4
	MOV  R0, 5
	MOV  [SELECIONA_SOM], R0            ; reproduz o som 5
	MOV  [REPRODUZ_SOM], R0
	JMP  game_over_ecra                 ; apaga os pixeis do jogo e desenha as letras 'GAME OVER'


;************************************************************************************
; DISPARA_MISSIL - desenha míssil na posição correta relativamente ao rover apenas se
;                  não houver um míssil no ecrã
;************************************************************************************

dispara_missil:
	PUSH R0
	PUSH R2

	MOV  R0, [MISSIL]
	CMP  R0, 0000H           ; há algum míssil ativo no ecrã?
	JZ   pinta_missil        ; se não houver pode ser disparado um míssil

	POP  R2
	POP  R0

	JMP  return_acao         ; se houver não dispara míssil e sai da rotina

pinta_missil:
	MOV  R2, -5
	CALL atualiza_energia    ; baixa a energia do rover em 5 pontos

	CALL pos_missil          ; descobre qual a posição do míssil relativamente ao rover

	MOV  R0, 7               ; míssil desenhado no ecrã 7
	MOV  [SELECIONA_ECRÃ], R0
	MOV  R2, MISSIL
	CALL desenha_imagem      ; desenha míssil

	MOV  R0, 0              
	MOV  [SELECIONA_SOM], R0
	MOV  [REPRODUZ_SOM], R0  ; reproduz som de disparo do míssil

	POP  R2
	POP  R0

	JMP  return_acao     

pos_missil:                  ; encontra a posição em que um míssil tem de ser 
					 	  	 ; disparado relativamente ao rover
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3

	MOV  R3, MISSIL          ; míssil em R3
	MOV  R0, [ROVER]         ; posição do rover em R0
	MOV  R1, 0002H           ; número de colunas a somar à coordenada inferior esquerda do rover
	MOV  R2, 0400H           ; número de linhas a subtrair à coordenada inferior esquerda do rover
	ADD  R0, R1 
	SUB  R0, R2
	MOV  [R3], R0            ; guarda a posição do míssil a ser disparada na variável MISSIL

	POP  R3
	POP  R2
	POP  R1
	POP  R0

	RET


;************************************************************************************
; PAUSA - pára o jogo, desenha as letras do menu de pausa, mantendo no fundo o 
;         estado atual do jogo e espera que a tecla 'D' seja premida para voltar 
;		  ao jogo
;************************************************************************************

pausa:
	PUSH R0
	PUSH R1
	PUSH R2

	CALL som_pausa           ; reproduz um som ao entrar da pausa

	MOV  R0, 1
	MOV  [SELECIONA_ECRÃ], R0
	MOV  R0, MENU_PAUSA_LETRAS
	CALL desenha_pixeis      ; desenha menu de pausa no ecrã 1

	MOV  R0, 0
	CALL espera_sair_pausa   ; espera que a tecla 'D' seja novamente premida

	POP  R2
	POP  R1
	POP  R0
	JMP  return_acao

espera_sair_pausa:
	MOV  R2, [TECLA_PREMIDA] ; tecla que acabou de ser premida em R2 (tecla 'D') 
	MOV  [ULTIMA_TECLA], R2  ; guarda essa tecla na variável ULTIMA_TECLA

	CALL teclado 			 ; espera que uma tecla seja premida

	MOV  R0, [TECLA_PREMIDA]
	MOV  R1, [ULTIMA_TECLA]
	MOV  R2, 13
	CMP  R0, R2 			 ; verifica se a tecla premida foi a tecla 'D'
	JZ   espera_sair_verifica ; se foi sai

	MOV  R2, 14
	CMP  R0, R2 			 ; verifica se a tecla premida foi a tecla 'E'
	JZ   game_over_opcional  ; se foi termina o jogo de forma voluntária
	JMP  espera_sair_pausa   ; se não foi nenhuma das teclas contínua à espera que uma delas seja premida

espera_sair_verifica:  
	CMP  R0, R1              ; verifica se a tecla já deixou de ser premida
	JNZ  sair_pausa          ; se sim sai da pausa
	JMP  espera_sair_pausa   ; se não continua à espera

sair_pausa:
	CALL som_pausa           ; reproduz um som ao sair da pausa
	MOV  R0, 1
	MOV  [APAGA_ECRÃ_X], R0  ; apaga as letras do menu de pausa
	RET
	
som_pausa:
	MOV  R0, 5
	MOV  [SELECIONA_SOM], R0
	MOV  [REPRODUZ_SOM], R0   ; reproduz o som 5
	RET


;************************************************************************************
; CRIA_OU_DESCE_METEOROS_MAUS - verifica os meteoros maus e dependendo da sua posição 
; 								cria um novo no topo do ecrã ou desce o mesmo um 
;								pixel para baixo com um intervalo de 0.3 segundos
;************************************************************************************

cria_ou_desce_meteoros_maus:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3

	MOV  R0, METEOROS_MAUS_LISTA ; coloca a lista das posições dos meteoros em R0
	MOV  R3, 1               ; inicializa contador dos meteoros para percorrer a lista

cria_ou_desce_meteoros_ciclo: ; ciclo principal da rotina 
	CMP  R3, 4               ; verifica se já percorremos os 4 meteoros
	JZ   return_cria_ou_desce_meteoros ; se sim chama a função return da rotina
	
verifica_meteoro:            ; verifica se tem de criar novo meteoro no topo ou descer a sua posição no ecrã
    MOV  R1, [R0]            ; coloca a posição do meteoro em R1
	CMP  R1, 0002H           ; verifica se é necessário criar novo meteoro no topo do ecrã numa coluna random
	JZ   novo_meteoro        ; se sim chama rotina novo_meteoro
	MOV  R2, [eventos_int] ; se não verifica o relógio dos meteoros para saber se pode descer o meteoro
	CMP  R2, 0                          
	JNZ  desce_meteoro       ; se a interrupção permitir desce o meteoro

	JMP  volta_ciclo

novo_meteoro:                ; função que cria novo meteoro em coluna random
	CALL random_posicao      ; encontra uma coluna pseudo-random e coloca a nova posição na tabela dos meteoros e na tabela da imagem do meteoro
	MOV  [R0], R1		     ; coloca a posição nova na tabela das posições dos meteoros
	JMP  desenha_meteoro     ; desenha a imagem no registo guardado em R2

desce_meteoro:               ; desce a posição do meteoro 1 pixel e desenha o meteoro na nova posição
	PUSH R3
	PUSH R4

	MOV  R4, R1              ; coloca posição atual em R1
	SHR  R4, 8               ; shift right da posição atual para isolar a linha
	MOV  R3, 31              ; coloca o limite do ecrã em R3
	CMP  R4, R3              ; verifica se posição se encontra dentro do limite do ecrã
	JZ   reset_meteoro       ; se sim dá reset ao meteoro

	CALL desce_posicao       ; se não encontra a próxima posição

	POP  R4
	POP  R3

	JMP  desenha_meteoro     ; desenha o meteoro na nova posição

random_posicao:              ; encontra posicao random e coloca em R1
	PUSH R4
	PUSH R5

	MOV  R4, [PIN]
	MOV  R5, 8
	SHR  R4, 13
	MUL  R4, R5			     ; coluna aleatória onde 'nascerá' um novo meteoro
	ADD  R4, 2
	

	MOV  R1, R4              ; coloca nova posicao na tabela do meteoro inicial

	POP  R5
	POP  R4
	RET

desenha_meteoro:
	PUSH R4
	PUSH R5
	PUSH R6

	ADD  R3, 1
	MOV  [APAGA_ECRÃ_X], R3  ; apaga ecrã do meteoro
	MOV  [SELECIONA_ECRÃ], R3 ; seleciona o ecrã do meteoro para desenhar na nova posição
	SUB  R3, 1

	MOV  R4, 9
	MOV  R5, 12
	MOV  R6, R1
	SHR  R6, 8 				 ; linha para onde o meteoro vai em R6

	CMP  R6, 3
	JLE  pinta_inicial_pequeno ; se estiver entre as linhas 0 e 3 desenha o meteoro inicial pequeno
	CMP  R6, 6
	JLE  pinta_inicial_grande ; se estiver entre as linhas 4 e 6 desenha o meteoro inicial grande
	CMP  R6, R4
	JLE  pinta_mau_pequeno   ; se estiver entre as linhas 7 e 9 desenha o meteoro mau pequeno
	CMP  R6, R5
	JLE  pinta_mau_medio     ; se estiver entre as linhas 10 e 12 desenha o meteoro mau médio

	JMP  pinta_mau_grande    ; se não desenha o meteoro mau grande

pinta_inicial_pequeno:
	MOV  [METEORO_INICIAL_P], R1
	MOV  R2, METEORO_INICIAL_P ; colocar em R2 a tabela do meteoro (já com a posição atualizada)
	CALL desenha_imagem      ; desenha o meteoro inicial pequeno

	JMP  return_desenha_meteoro

pinta_inicial_grande:
	MOV  [METEORO_INICIAL_G], R1
	MOV  R2, METEORO_INICIAL_G ; colocar em R2 a tabela do meteoro (já com a posição atualizada)
	CALL desenha_imagem      ; desenha o meteoro inicial grande

	JMP  return_desenha_meteoro

pinta_mau_pequeno:
	MOV  [METEORO_MAU_P], R1
	MOV  R2, METEORO_MAU_P   ; colocar em R2 a tabela do meteoro (já com a posição atualizada)
	CALL desenha_imagem      ; desenha o meteoro mau pequeno

	JMP  return_desenha_meteoro

pinta_mau_medio:
	MOV  [METEORO_MAU_M], R1
	MOV  R2, METEORO_MAU_M   ; colocar em R2 a tabela do meteoro (já com a posição atualizada)
	CALL desenha_imagem      ; desenha o meteoro mau médio

	JMP  return_desenha_meteoro

pinta_mau_grande:
	MOV  [METEORO_MAU_G], R1
	MOV  R2, METEORO_MAU_G   ; colocar em R2 a tabela do meteoro (já com a posição atualizada)
	CALL desenha_imagem      ; desenha o meteoro mau grande
	CALL ha_colisao_rover    ; verifica se esse meteoro colide com o rover

	JMP  return_desenha_meteoro

return_desenha_meteoro:
	POP  R6
	POP  R5
	POP  R4
	JMP  volta_ciclo

reset_meteoro:               ; reset ao meteoro se este se encontrar fora do limite do ecrã (posição volta a 0)
	MOV  R1, 0002H
	MOV  [R0], R1            ; coloca a posição na tabela a 0 (para conseguir identificar que será preciso criar um novo em coluna random)            

	POP  R4
	POP  R3
	JMP  volta_ciclo

desce_posicao:               ; atualiza posição para 1 pixel a baixo 
	PUSH R2

	MOV  R2, 100H               
	ADD  R1, R2              ; adiciona 1 linha à posição atual do meteoro

	MOV  [METEORO_INICIAL_P], R1 ; coloca nova posicao na tabela do meteoro inicial
	MOV  [R0], R1			 ; coloca a posição nova na tabela das posições dos meteoros

	POP  R2
	RET

volta_ciclo:
	ADD  R3, 1               ; avança a contagem dos meteoros
	ADD  R0, 2               ; avança o enderenço da tabela das posições para a próxima posição

	JMP  cria_ou_desce_meteoros_ciclo ; volta ao ciclo principal da rotina

return_cria_ou_desce_meteoros:
	POP  R3
	POP  R2
	POP  R1
	POP  R0
	RET


;************************************************************************************
; CRIA_OU_DESCE_METEOROS_BOM - verifica o meteoro bom e dependendo da sua posição 
; 								cria um novo no topo do ecrã ou desce o mesmo um 
;								pixel para baixo com um intervalo de 0.3 segundos
;************************************************************************************

cria_ou_desce_meteoro_bom:
 	PUSH R0
	PUSH R1
	PUSH R2

	MOV  R0, [METEORO_BOM]   ; posição do meteoro bom em R0
	CMP  R0, 0002H 			 ; verifica se é necessário criar novo meteoro no topo do ecrã numa coluna random
	JZ   cria_novo_meteoro   ; se sim chama rotina cria_novo_meteoro

	MOV  R2, 31
	SHR  R0, 8
	CMP  R0, R2              ; verifica se o meteoro já chegou à última linha do ecrã
	JZ   reset_meteoro_bom   ; se sim dá reset ao meteoro

	JMP  desce_meteoro_bom   ; se não contínua a descer

cria_novo_meteoro:
	CALL random_posicao      ; coloca uma coluna random em R1
	MOV  [METEORO_BOM], R1   ; atualiza a posição do meteoro
	JMP  desenha_meteoro_bom 

reset_meteoro_bom:
	MOV  R2, 0002H
	MOV  [METEORO_BOM], R2   ; coloca a posição do meteoro bom nas coordenadas 0000H
	JMP  return_cria_ou_desce_meteoro_bom

desce_meteoro_bom:
	MOV  R2, [eventos_int]
	CMP  R2, 0 				 ; o meteoro tem 'autorização' para descer?
	JZ   return_cria_ou_desce_meteoro_bom ; se não tiver sai da rontina	

	MOV  R2, 0
	MOV  [eventos_int], R2   ; se tiver coloca a 'autorização' a 0 para a próxima vez

	MOV  R1, [METEORO_BOM]   ; posição do meteoro bom em R1
	MOV  R2, 100H
	ADD  R1, R2   			 ; posição do meteoro bom para para a linha de baixo
	MOV  [METEORO_BOM], R1   ; atualiza a posição do meteoro bom
	JMP  desenha_meteoro_bom ; desenha o meteoro na nova posição

desenha_meteoro_bom:
	PUSH R3
	PUSH R4
	PUSH R5

	MOV  R3, 5
	MOV  R4, 9
	MOV  R5, 12

	MOV  [APAGA_ECRÃ_X], R3  ; apaga o meteoro na posição antiga
	MOV  [SELECIONA_ECRÃ], R3

	MOV  R3, R1 			 ; posição atualizada do meteoro em R3
	SHR  R3, 8 				 ; linha da posição do meteoro em R3

	CMP  R3, 3
	JLE  pinta_inicial_bom_p ; se estiver entre as linhas 0 e 3 desenha o meteoro inicial pequeno
	CMP  R3, 6
	JLE  pinta_inicial_bom_g ; se estiver entre as linhas 4 e 6 desenha o meteoro inicial grande
	CMP  R3, R4
	JLE  pinta_bom_p 		 ; se estiver entre as linhas 7 e 9 desenha o meteoro bom pequeno
	CMP  R3, R5
	JLE  pinta_bom_m 		 ; se estiver entre as linhas 10 e 12 desenha o meteoro bom médio

	JMP  pinta_bom_g 		 ; se não desenha o meteoro bom grande

pinta_inicial_bom_p:
	MOV  [METEORO_INICIAL_P], R1
	MOV  R2, METEORO_INICIAL_P ; colocar em R2 a tabela do meteoro (já com a posição atualizada)
	CALL desenha_imagem 	 ; desenha o meteoro inicial pequeno

	JMP  return_desenha_meteoro_bom

pinta_inicial_bom_g:
	MOV  [METEORO_INICIAL_G], R1
	MOV  R2, METEORO_INICIAL_G ; colocar em R2 a tabela do meteoro (já com a posição atualizada)
	CALL desenha_imagem 	 ; desenha o meteoro inicial grande

	JMP  return_desenha_meteoro_bom

pinta_bom_p:
	MOV  [METEORO_BOM_P], R1
	MOV  R2, METEORO_BOM_P   ; colocar em R2 a tabela do meteoro (já com a posição atualizada)
	CALL desenha_imagem 	 ; desenha o meteoro bom pequeno

	JMP  return_desenha_meteoro_bom

pinta_bom_m:
	MOV  [METEORO_BOM_M], R1
	MOV  R2, METEORO_BOM_M   ; colocar em R2 a tabela do meteoro (já com a posição atualizada)
	CALL desenha_imagem 	 ; desenha o meteoro mau médio

	JMP  return_desenha_meteoro_bom

pinta_bom_g:
	MOV  [METEORO_BOM_G], R1
	MOV  R2, METEORO_BOM_G   ; colocar em R2 a tabela do meteoro (já com a posição atualizada)
	CALL desenha_imagem 	 ; desenha o meteoro mau grande
	CALL ha_colisao_rover    ; verifica se esse meteoro colide com o rover

	JMP  return_desenha_meteoro_bom

return_desenha_meteoro_bom:
	POP  R5
	POP  R4
	POP  R3
	JMP  return_cria_ou_desce_meteoro_bom

return_cria_ou_desce_meteoro_bom:
	POP  R2
	POP  R1
	POP  R0  
	RET


;************************************************************************************
; HA_COLISAO_ROVER - verifica se os meteoros bons ou maus colidem com o rover ao 
;					 descer; se houver colisão com mau o jogo acaba; se houver 
;					 colisão com bom aumenta a energia do rover em 10 pontos 
;************************************************************************************

ha_colisao_rover:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7

	MOV  R0, METEOROS_MAUS_LISTA ; lista de posições dos meteoros maus em R0
	MOV  R1, 1 					 ; contador para percorrer a lista de posições em R1

ha_colisao_rover_ciclo:
	CMP  R1, 4 				 ; já percorreu a lista das posções dos meteoros maus?
	JZ   ha_colisao_bom 	 ; se sim vai verificar o meteoro bom
	JMP  ha_colisao_mau 	 ; se não continua a verificar os maus

ha_colisao_bom:
	MOV  R2, [METEORO_BOM]   ; posição do meteoro bom em R2
	MOV  R3, [ROVER] 		 ; posição do rover em R3
	MOV  R6, 1 				 ; se R6 é 1 verifica colisão boa
	JMP  ha_colisao_rover_meteoro

ha_colisao_mau:
	MOV  R2, [R0] 			 ; posição do meteoro mau a verificar em R2
	MOV  R3, [ROVER] 		 ; posição do rover em R3
	MOV  R6, 0 				 ; se R6 é 0 verifica colisão mau
	JMP  ha_colisao_rover_meteoro

volta_ciclo_colisao_rover:   ; ciclo para avançar pelas posições dos meteoros maus
	ADD  R0, 2
	ADD  R1, 1
	JMP  ha_colisao_rover_ciclo

ha_colisao_rover_meteoro:    ; verifica se o rover (em R3) colide com o meteoro (em R2), se R6 estiver a 0 meteoro é mau senão é bom
	MOV  R4, R2
	SHR  R4, 8               ; coloca a linha do meteoro em R4 
	MOV  R5, R3
	SHR  R5, 8               ; coloca a linha do rover em R5
	SUB  R5, 4
	MOV  R7, MASCARA_COLUNA

	AND  R2, R7              ; coloca a coluna do meteoro em R2
	AND  R3, R7              ; coloca a coluna do rover em R3
	
	ADD  R5, 1 				 ; limite da linha para as colisões dos meteoros com o rover
	CMP  R4, R5 				 ; verifica se a linha do meteoro é maior ou igual à linha limite para a sua colisão com o rover
	JGE  verifica_colisao 	 ; se se verificar vai confirmar se alguma das colunas do meteoro coindice com as do rover

	CMP  R6, 1 				 ; neste ponto sabe-se que não há colisão com este meteoro
	JZ   return_colisao_rover ; se for um meteoro bom como este é o último a ser testado, dá return à rotina
	JMP  volta_ciclo_colisao_rover ; se for um meteoro mau volta ao ciclo para testar o próximo meteoro

verifica_colisao:            ; sabemos que se houver uma colisão entre o rover e um meteoro (ambos de largura 5), o módulo da diferença entre a coordenada esquerda de cada é menor ou igual a 5
	CMP  R2, R3 	 		 ; compara a coluna do meteoro com a coluna do rover
	JGE  testa_esquerda 	 ; se a coluna do meteoro for superior à do rover, a diferença entre a coluna do meteoro e a do rover é um número positivo e menor ou igual que 5 se houver colisão
	JMP  testa_direita       ; se a coluna do rover for superior à do meteoro, a diferença entre a coluna do rover e a do meteoro é um número positivo e menor ou igual que 5 se houver colisão

testa_esquerda:
	SUB  R2, R3 			 ; faz a diferença entre a coluna do meteoro e a do rover
	CMP  R2, 5 				 ; compara essa diferença com 5
	JLE  ha_colisao 		 ; se for menor ou igual a 5 quer dizer que houve colisão
	CMP  R6, 1 				 ; se for maior do que 5 quer dizer que não houve colisão e então verifica se todos os meteoros já foram verificados
	JZ   return_colisao_rover ; se sim sai da rotina
	JMP  volta_ciclo_colisao_rover ; se não volta ao ciclo para verificar os meteoros restantes

testa_direita:
	SUB  R3, R2 			 ; faz a diferença entre a coluna do rover e a do meteoro
	CMP  R3, 5 				 ; compara essa diferença com 5
	JLE  ha_colisao 		 ; se for menor ou igual a 5 quer dizer que houve colisão
	CMP  R6, 1 				 ; se for maior do que 5 quer dizer que não houve colisão e então verifica se todos os meteoros já foram verificados
	JZ   return_colisao_rover ; se sim sai da rotina
	JMP  volta_ciclo_colisao_rover ; se não volta ao ciclo para verificar os meteoros restantes

ha_colisao:   				 ; quando há colisão esta é boa se R6 = 1 e má se R6 = 0
	CMP  R6, 0
	JZ   ha_colisao_ma
	JMP  ha_colisao_boa

ha_colisao_boa:
	MOV  R6, 5
	MOV  [APAGA_ECRÃ_X], R6  ; apaga o meteoro bom

	MOV  R6, 0002H
	MOV  R2, METEORO_BOM
	MOV  [R2], R6			 ; volta a inicializar a coordenada do meteoro

	MOV  R2, 10
	CALL atualiza_energia	 ; aumenta a energia do rover em 10 pontos

	MOV  R4, 3
	MOV  [SELECIONA_SOM], R4
	MOV  [REPRODUZ_SOM], R4  ; reproduz som de colisão do rover com meteoro bom

	JMP  return_colisao_rover

ha_colisao_ma:
	MOV  R4, 4
	MOV  [SELECIONA_SOM], R4
	MOV  [REPRODUZ_SOM], R4  ; reproduz som de colisão do rover com meteoro mau
	JMP  game_over 			 ; acaba o jogo pois o rover acabou de perder

return_colisao_rover:
    POP  R7
	POP  R6
	POP  R5
	POP  R4
	POP  R3
	POP  R2
	POP  R1
	POP  R0
	RET

	
;************************************************************************************
; HA_COLISAO_MISSIL - verifica se os meteoros bons ou maus colidem com o míssil;
; 					  se houver colisão com mau a energia do rover aumenta 5 pontos; 
;					  se houver colisão com bom nada acontece 
;************************************************************************************

ha_colisao_missil:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3

	MOV  R0, 1 				 ; contador para percorrer a lista de posições em R0
	MOV  R1, METEOROS_MAUS_LISTA ; lista de posições dos meteoros maus em R1

verifica_colisoes_ciclo:
	CMP  R0, 4 				 ; já todos os meteoros maus foram verificados?
	JZ   verifica_colisao_bom ; se sim então verifica-se com o meteoro bom

	MOV  R2, [R1] 			 ; se não posição do meteoro mau em R2
	CALL missil_colide_linha ; verifica se o míssil está na mesma linha e numa das colunas da base do meteoro

	CMP  R3, 1 				 ; se colidir R3 = 1
	JZ   explode_meteoro_mau ; se R3 = 1 explode o meteoro mau

	ADD  R0, 1 				
	ADD  R1, 2
	JMP  verifica_colisoes_ciclo ; se não houver colisão continua para o próximo meteoro

verifica_colisao_bom:
	MOV  R2, [METEORO_BOM] 	 ; posição de meteoro bom em R2
	CALL missil_colide_linha ; verifica se o míssil está na mesma linha e numa das colunas da base do meteoro

	CMP  R3, 1 				 ; se colidir R3 = 1
	JZ   explode_meteoro_bom ; se R3 = 1 explode o meteoro bom
	JMP  return_ha_colisao_missil ; se não houver colisão sai da rotina

 missil_colide_linha:        ; verifica se o míssil se encontra na linha inferior do meteoro, se sim verifica se a coluna está dentro dos limites do meteoro
 	PUSH R0
 	PUSH R1
 	PUSH R3
 	PUSH R4

 	MOV  R0, [MISSIL] 		 ; posição do míssil em R0
 	MOV  R1, R0 			 ; backup da posição do míssil em R1
 	MOV  R3, R2 			 ; backup da posição do meteoro em R3
 	SHR  R1, 8 				 ; linha do míssil em R1
 	SHR  R3, 8 				 ; linha do meteoro em R3
 	CMP  R1, R3				 ; o meteoro e o míssil estão na mesma linha?
 	JZ   missil_colide_coluna ; se sim verifica se estão na mesma coluna
 	JMP  return_nao_colide 	 ; se não quer dizer que não há colisão e avança para o próximo meteoro 

missil_colide_coluna:
	MOV  R1, R0 			 ; backup da posição do míssil em R1
	MOV  R3, R2 			 ; backup da posição do meteoro em R3
	MOV  R4, MASCARA_COLUNA
	AND  R1, R4 			 ; coluna do míssil em R1
	AND  R2, R4 			 ; coluna mais à esquerda do meteoro em R2
	AND  R3, R4 			 ; backup da coluna mais à esquerda do meteoro em R3
	ADD  R3, 4 				 ; coluna mais à direita do meteoro
	CMP  R1, R2 			 ; compara a coluna do míssil com a coluna mais à esquerda do meteoro
	JGE  verifica_lim_dir    ; se a coluna do míssil é maior ou igual à coluna mais à esquerda do meteoro verifica o limite direito
	JMP  return_nao_colide	 ; se não for quer dizer que não houve colisão e avança para o próximo meteoro

verifica_lim_dir:
	CMP  R1, R3 			 ; compara a coluna do míssil com a coluna mais à direita do meteoro
	JLE  return_colide       ; se a coluna do míssil é menor ou igual à coluna mais à direita do meteoro houve colisão
	JMP  return_nao_colide 	 ; se não for quer dizer que não houve colisão e avança para o próximo meteoro

return_colide:
	POP  R4
	POP  R3
	POP  R1
	POP  R0
	MOV  R3, 1 				 ; se houve colisão coloca R3 a 1
	RET

return_nao_colide:
	POP  R4
	POP  R3
	POP  R1
	POP  R0 
	MOV  R3, 0 				 ; se não houve colisão coloca R3 a 0
	RET

explode_meteoro_mau:
	PUSH R2
	PUSH R4

	MOV  R2, 5
	CALL atualiza_energia    ; aumenta a energia do rover em 10 pontos

	MOV  R4, 1
	MOV  [SELECIONA_SOM], R4
	MOV  [REPRODUZ_SOM], R4  ; reproduz som de explosão de meteoro

	MOV  R4, R0
	ADD  R4, 1
	MOV  [APAGA_ECRÃ_X], R4  ; apaga o meteoro mau

	MOV  R4, 7
	MOV  [APAGA_ECRÃ_X], R4  ; apaga o míssil

	MOV  R4, 8
	MOV  [SELECIONA_ECRÃ], R4
	MOV  R4, [R1] 
	MOV  [EXPLOSAO], R4 	 ; coloca posição da explosão igual à posição do meteoro mau
	MOV  R2, EXPLOSAO
	CALL desenha_imagem 	 ; desenha a explosão no ecrã 8

	MOV  R4, 0002H
	MOV  [R1], R4		     ; volta a inicializar a posição do meteoro
	MOV  R4, 0
	MOV  [MISSIL], R4		 ; volta a inicializar a posição do míssil

	POP  R2
	POP  R4

	ADD  R0, 1
	ADD  R1, 2
	JMP  verifica_colisoes_ciclo

explode_meteoro_bom:
    PUSH R2
	PUSH R4

	MOV  R4, 1
	MOV  [SELECIONA_SOM], R4
	MOV  [REPRODUZ_SOM], R4  ; reproduz som de explosão de meteoro

	MOV  R4, 5
	MOV  [APAGA_ECRÃ_X], R4  ; apaga o meteoro bom

	MOV  R4, 7
	MOV  [APAGA_ECRÃ_X], R4  ; apaga o míssil

	MOV  R4, 8
	MOV  [SELECIONA_ECRÃ], R4
	MOV  R4, [METEORO_BOM]
	MOV  [EXPLOSAO], R4 	 ; coloca posição da explosão igual à posição do meteoro bom 
	MOV  R2, EXPLOSAO
	CALL desenha_imagem 	 ; desenha a explosão no ecrã 8

	MOV  R4, 0002H
	MOV  [METEORO_BOM], R4	 ; volta a inicializar a posição do meteoro bom
	MOV  R4, 0
	MOV  [MISSIL], R4		 ; volta a inicializar a posição do míssil

	POP  R4
	POP  R2

	JMP  return_ha_colisao_missil 

return_ha_colisao_missil:
	POP  R3
	POP  R2
	POP  R1
	POP  R0
	RET

apaga_explosao:
	PUSH R0

	MOV  R0, 8
	MOV  [APAGA_ECRÃ_X], R0  ; apaga a explosão

	POP  R0
	RET


;************************************************************************************
; GAME_OVER - rotina que termina o jogo por colisão do rover com meteoro mau, por
;			  a energia do rover chegar a 0 ou opr opção do jogador
;************************************************************************************

game_over:
	MOV  R0, [ENERGIA_ROVER]
	CMP  R0, 0 	 			 ; verifica se é game over por a energia do rover ter chegado a 0
	JZ   game_over_energia   ; se chegou a 0 trata do game over para energia do rover que chegou a 0

game_over_colisao: 			 ; se não chegou a zero trata do game over para colisões de rover com meteoro mau
	MOV  R0, 2
	MOV  [SELECIONA_CENARIO], R0 ; seleciona o cenário de fundo 2
	JMP  game_over_ecra

game_over_energia:
	MOV  R0, 3
	MOV  [SELECIONA_CENARIO], R0 ; seleciona o cenário de fundo 3

	MOV  R0, 2
	MOV  [SELECIONA_SOM], R0
	MOV  [REPRODUZ_SOM], R0  ; reproduz som de fim de jogo por energia do rover chegar a 0
	JMP  game_over_ecra

game_over_ecra:
	MOV  [APAGA_ECRÃ], R0    ; apaga todo o ecrã

	MOV  R0, MENU_GAME_OVER
	CALL desenha_pixeis 	 ; desenha o menu de game over 

	MOV  R0, CLICA_E_LETRAS
	CALL desenha_pixeis 	 ; desenha segunda parte do menu de game over ('clica E')

espera_reiniciar_jogo:
	MOV  R2, [TECLA_PREMIDA] ; tecla que acabou de ser premida em R2 (tecla 'E')
	MOV  [ULTIMA_TECLA], R2  ; guarda essa tecla na variável ULTIMA_TECLA

	CALL teclado 	 		 ; espera que uma tecla seja premida

	MOV  R0, [TECLA_PREMIDA]
	MOV  R1, [ULTIMA_TECLA]
	MOV  R2, 14
	CMP  R0, R2 			 ; verifica se a tecla premida foi a tecla 'E'
	JZ   espera_reiniciar_verifica ; se foi sai
	JMP  espera_reiniciar_jogo ; se não foi continua à espera

espera_reiniciar_verifica:
	CMP  R0, R1 	 	 	 ; verifica se a tecla já deixou de ser premida
	JNZ  reiniciar_jogo 	 ; se sim sai
	JMP  espera_reiniciar_jogo ; se não continua à espera

reiniciar_jogo:
	MOV  R0, 5
	MOV  [SELECIONA_SOM], R0
	MOV  [REPRODUZ_SOM], R0  ; reproduz som de fim de jogo
	JMP  programa_init 		 ; volta a iniciar o jogo


;************************************************************************************
; Subir o míssil de 0.2 em 0.2 segundos
; SOBE_MISSIL - de 0.2 em 0.2 segundos apaga o míssil na posição atual e volta a 
;			    desenhá-lo um pixel acima, guardando a nova posição e verificando 
; 			    se este ainda não atingiu o limite 
;************************************************************************************

sobe_missil:
	PUSH R0
	PUSH R1
	PUSH R2

	MOV  R1, [eventos_int+2]
	CMP  R1, 0 				 ; o míssil tem 'autorização' para subir?
	JZ   return_sobe_missil  ; se não tem sai
	MOV  R1, 0
	MOV  [eventos_int+2], R1 ; se tiver volta a colocar a 'autorização' a 0

	MOV  R1, [MISSIL]
	CMP  R1, 0000H 			 ; verifica se a posição do míssil está a 0
	JZ   return_sobe_missil  ; se estiver sai, pois não há míssil para subir

	MOV  R0, 7
	MOV  [APAGA_ECRÃ_X], R0  ; apaga o míssil

	MOV  R0, 0100H
	SUB  R1, R0 			 ; sobe a posição do míssil em um pixel
	MOV  R0, 0F00H			 ; alcance máximo do míssil
	CMP  R1, R0 			 ; verifica se o míssil ainda não subiu 12 vezes
	JLE  missil_fora	     ; se já subiu então a posição do míssil volta a 0
	MOV  [MISSIL], R1 		 ; atualiza posição do míssil
	MOV  R0, 7
	MOV  [SELECIONA_ECRÃ], R0
	MOV  R2, MISSIL
	CALL desenha_imagem		 ; desenha o míssil no ecrã 7

	JMP  return_sobe_missil

missil_fora:
	MOV  R0, 0
	MOV  [MISSIL], R0 	  	 ; posição do míssil volta a 0

return_sobe_missil:
	POP  R2
	POP  R1
	POP  R0
	RET


;************************************************************************************
; DESCE_ENERGIA - de 3 em 3 segundos a energia do rover desce em 5 pontos
;************************************************************************************

desce_energia:
	PUSH R0
	PUSH R1
	PUSH R2

	MOV  R0, eventos_int      
	MOV  R1, [R0+4]          ; 'autorização' para a energia do rover descer em R1    
	CMP  R1, 0               ; tem autorização?
	JZ   return_desce_energia; se não tiver sai

	MOV  R1, 0               ; se tiver, volta a colocar a autorização a zero para a próxima vez
	MOV  [R0+4], R1
	
	MOV  R2, -5
	CALL atualiza_energia    ; desce a energia do rover em 5%
	CALL apaga_explosao

return_desce_energia:
	POP  R2
	POP  R1
	POP  R0
	RET


;************************************************************************************
; Descer ou sobe o valor da energia do rover em R2%
; ATUALIZA_ENERGIA - desce ou sobe o valor da energia do rover em R2%, 
;      				  guarda a energia atualizada na variável ENERGIA_ROVER e 
;				      coloca-a nos displays 
;************************************************************************************

atualiza_energia:
	PUSH R0
	PUSH R1

	MOV  R0, ENERGIA_ROVER   ; endereço do valor que estava nos displays guardado em R0
	MOV  R1, [R0]			 ; R1 é inicializado com o valor que estava nos displays
	ADD  R1, R2

	CALL energia_dentro_limites ; verifica se o valor a ser colocado nos displays não é menor que 0

	MOV  [R0], R1            ; guarda o valor que estava nos displays, mas agora decrementado em 5 unidades
	MOV  R1, [R0]

	CALL altera_energia      ; coloca o valor da energia do rover nos displays

	MOV  R0, [ENERGIA_ROVER]
	CMP  R0, 0 	 	 		 ; verifica se energia do jogo está a 0
	JZ   game_over 			 ; se estiver o jogo acaba pois o rover perdeu toda a energia

	POP  R1
	POP  R0
	RET


;************************************************************************************
; Rotinas que tratam da energia do rover
; ENERGIA_DENTRO_LIMITES - verifica que a energia atualizada do rover está entre 0 e 
;						   100; se for menor que 0 coloca-a a 0, se for maior que
;						   100 coloca-a a 100
; ALTERA_ENERGIA - armazena a energia atualizada do rover na variável ENERGIA_ROVER
;				   e coloca o valor da sua energia convertido para decimal nos 
;				   displays
;************************************************************************************

energia_dentro_limites:      ; verifica se o valor a ser colocado nos displays não é menor que 0
	PUSH R0

	MOV  R0, 101
	CMP  R1, -1
	JLE  reset_energia_rover ; se o valor for menor que 0, volta a colocá-lo a 0
	CMP  R1, R0
	JGE  max_energia_rover   ; se o valor for maior que 100, volta a colocá-lo a 100

	JMP  return_energia_dentro_limites

reset_energia_rover:         ; faz o reset do valor a ser colocado nos displays
	MOV  R1, 0
	JMP  return_energia_dentro_limites

max_energia_rover:           ; põe o valor a ser colocado nos displays no máximo
	MOV  R1, 100
	JMP  return_energia_dentro_limites

return_energia_dentro_limites:
	POP  R0
	RET

altera_energia:              ; coloca o valor da energia do rover nos displays
	PUSH R0
	PUSH R1
	PUSH R2

	MOV  R0, ENERGIA_ROVER   ; inicializa R0 com o endereço do valor da energia do rover a colocar nos displays
	MOV  R1, DISPLAYS	     ; inicializa R1 com o endereço dos displays
	MOV  R2, [R0]			 ; inicializa R2 com o valor da energia do rover

	CALL converte_hexa_decimal ; converte números hexadecimais (até 63H) para decimal

	MOV  [R1], R2			 ; coloca a energia do rover nos displays

	POP  R2
	POP  R1
	POP  R0
	RET

converte_hexa_decimal:	     ; converte números hexadecimais (até 63H) para decimal
	PUSH R0 				 ; converte o numero em R2, e deixa-o em R2
	PUSH R1
	PUSH R3

	MOV  R1, HEXTODEC
	MOV  R0, R2
	DIV  R2, R1 			 ; coloca o algarismo das dezenas em decimal em R2
	MOD  R0, R1 			 ; coloca o algarismo das unidades em decimal em R0
	MOV  R3, 0A0H 

	SHL  R2, 4
	OR   R2, R0				 ; coloca o número em decimal em R2

	CMP  R2, R3
	JZ   converte_max_100

	JMP  return_converte_hexa_decimal

converte_max_100:            ; caso a energia do rover esteja a 100 volta-se a converter para hexadecimal, 
                             ; pois a função para converter apenas converte até 99
	MOV  R2, 256

	JMP  return_converte_hexa_decimal

return_converte_hexa_decimal:
	POP  R3
	POP  R1
	POP  R0
	RET


;************************************************************************************
; Desenhar figuras em tabelas com posições dos pixéis
; DESENHA_PIXEIS - percorre a tabela com as posições dos pixéis a desenhar e pinta-os
; Argumentos:  R0 - tabela de imagem a desenhar
;************************************************************************************

desenha_pixeis:              ; desenha pixeis da tabela de imagem em R0
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4

	MOV  R1, [R0]            ; cor dos pixéis a pintar em R1
	ADD  R0, 2
	JMP  corre_tabela

corre_tabela:                ; percorre a tabela com as posições dos pixéis e pinta-os
	MOV  R2, [R0]
	CMP  R2, 0               ; ainda há posições a pintar?
	JZ   return_desenha_pixeis ; se não houver mais posições sai
	MOVB R3, [R0]            ; linha do píxel a pintar em R3
	ADD  R0, 1
	MOVB R4, [R0]            ; coluna do píxel a pintar em R4
	CALL pinta_pixel
	ADD  R0, 1               ; passa para a próxima posição a pintar
	JMP  corre_tabela

pinta_pixel:                 ; pinta pixel na linha guardada em R3, coluna em R4 e cor em R1
	MOV  [DEFINE_LINHA], R3  ; seleciona a linha
	MOV  [DEFINE_COLUNA], R4 ; seleciona a coluna
	MOV  [DEFINE_PIXEL], R1  ; pinta o pixel na liha e coluna selecionadas

	RET

return_desenha_pixeis:
	POP  R4
	POP  R3
	POP  R2
	POP  R1
	POP  R0

	RET


;************************************************************************************
; Desenhar figuras em tabelas de cores
; DESENHA_IMAGEM - percorre a tabela com as cores dos pixéis a pintar e pinta-os
; Argumentos:  R2 - tabela de imagem a desenhar
;************************************************************************************

desenha_imagem:              ; desenha a imagem guardada em R2
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7

	MOVB R0, [R2]            ; colocar linha da posição da imagem em R0
	ADD  R2, 1               
	MOVB R1, [R2]		  	 ; colocar coluna da posição da imagem em R1
	MOV  R7, R1              ; backup da coluna da imagem
	ADD  R2, 1
	MOVB R3, [R2]            ; colocar altura da imagem em R3
	ADD  R2, 1
	MOVB R4, [R2]            ; colocar largura da imagem em R4
	MOV  R6, R4              ; backup da largura da imagem em R6
	ADD  R2, 1

desenha_linha:
	MOV  [DEFINE_LINHA], R0  ; selecionar linha
	MOV  [DEFINE_COLUNA], R1 ; selecionar coluna
	MOV  R5, [R2]            ; cor do pixel
	ADD  R2, 2               ; avança para o próximo pixel
	MOV  [DEFINE_PIXEL], R5  ; altera a cor do pixel nas coordenadas selecionadas
	ADD  R1, 1               ; avança coluna
	SUB  R4, 1               ; menos uma coluna para pintar
	JNZ  desenha_linha       ; percorre a linha toda
	MOV  R4, R6              ; restaura a largura do objeto
	MOV  R1, R7              ; restaura a coluna inicial da linha
	SUB  R0, 1               ; pintar linha anterior
	SUB  R3, 1               ; menos uma linha para pintar
	JNZ  desenha_linha       ; se aida há linhas a pintar pinta a próxima

	POP  R7
	POP  R6
	POP  R5
	POP  R4
	POP  R3
	POP  R2
	POP  R1
	POP  R0

	RET


;************************************************************************************
; Esperar a tecla ser carregada
; ESPERA_TECLA - percorre a linha 4 do teclado até uma das teclas 'C' ou 'D' ser
;				premida
;************************************************************************************
espera_c:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4

espera_c_ciclo:
	CALL espera_tecla_unica_init ; vai esperar uma tecla
	CMP  R4, 1               ; verifica se a tecla pressionada foi a 'C'
	JNZ  espera_c_ciclo      ; se não for a tecla 'C', repete o ciclo
	JMP  return_espera_c

return_espera_c:
	POP  R4
	POP  R3
	POP  R2
	POP  R1
	POP  R0
	RET

espera_tecla_unica_init:
	MOV  R0, 8               ; linha a verificar se tecla foi pressionada em R0
	MOV  R1, TEC_LIN         ; endereço do periférico das linhas
	MOV  R2, TEC_COL         ; endereço do periférico das colunas
	MOV  R3, MASCARA         ; para isolar os 4 bits de menor peso ao ler as colunas do teclado

espera_tecla_unica:
	MOVB [R1], R0            ; escrever no periférico de saída (linhas)
	MOVB R4, [R2]            ; ler do periférico de entrada (colunas)
	AND  R4, R3              ; elimina bits para além dos bits 0 a 3
	CMP  R4, 0               ; alguma tecla foi premida?
	JZ   espera_tecla_unica  ; se não, repete o ciclo

	RET


;************************************************************************************
; Rotinas de interrupção
; ROTINA_X - rotina de atendimento da interrupção X; assinala o evento na componente
;			 X da variável evento_int
;************************************************************************************

rotina_0:                    ; rotina de interrupção para os meteoros avançarem
	PUSH R0
	PUSH R1

	MOV  R0, eventos_int
	MOV  R1, 1
	MOV  [R0], R1

	POP  R1
	POP  R0
	RFE

rotina_1:                    ; rotina de interrupção para o míssil avançar
	PUSH R0
	PUSH R1

	MOV  R0, eventos_int
	MOV  R1, 1
	MOV  [R0+2], R1

	POP  R1
	POP  R0
	RFE

rotina_2:                    ; rotina de interrupção para a energia do rover diminuir
	PUSH R0
	PUSH R1

	MOV  R0, eventos_int
	MOV  R1, 1
	MOV  [R0+4], R1

	POP  R1
	POP  R0
	RFE

