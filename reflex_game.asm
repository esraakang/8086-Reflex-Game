; =====================================================
; REFLEKS OYUNU - FINAL (AKADEMIK SURUM)
; - Hoca Kriteri: Giderek kisalan sure mekanizmasi eklendi!
; - Ekstra: Combo sistemi (Oynanisi iyilestirmek icin)
; =====================================================

TUR_ARASI_SURE  EQU 0010h   
GERI_BILDIRIM   EQU 0050h   

.MODEL SMALL
.STACK 200h

.DATA
    msg_title       DB '================================', 0Dh, 0Ah
                    DB '        REFLEKS OYUNU           ', 0Dh, 0Ah
                    DB '================================', 0Dh, 0Ah, '$'
    msg_ready       DB 'Hazir misin? Basmak icin ENTER...', 0Dh, 0Ah, '$'
    msg_press       DB 'Tusa bas: ', '$'
    msg_correct     DB '  DOGRU!', 0Dh, 0Ah, '$'
    msg_combo       DB '  *** COMBO! ***', 0Dh, 0Ah, '$'
    msg_wrong       DB '  YANLIS! Hata: ', '$'
    msg_timeout     DB '  SURE DOLDU! Hata: ', '$'
    msg_reaction    DB '  Tepki: ', '$'
    msg_reaction2   DB ' birim', 0Dh, 0Ah, '$'
    msg_gameover    DB 0Dh, 0Ah, '*** OYUN BITTI - 3 HATA ***', 0Dh, 0Ah, '$'
    msg_win         DB 0Dh, 0Ah, '*** TEBRIKLER! 20 TUR TAMAMLANDI! ***', 0Dh, 0Ah, '$'
    msg_score       DB 'Toplam dogru: ', '$'
    msg_avg         DB 'Ort. tepki   : ', '$'
    msg_newline     DB 0Dh, 0Ah, '$'
    msg_slash3      DB ' / 3', 0Dh, 0Ah, '$'
    msg_goodbye     DB 'Tekrar oynamak icin yeniden calistirin.', 0Dh, 0Ah, '$'
    msg_round       DB 'Tur: ', '$'
    msg_of20        DB ' / 20  |  Hata: ', '$'

    letters         DB 'A', 'S', 'D', 'F', 'J', 'K'

    current_letter  DB 0
    prev_letter     DB 0
    rand_seed       DW 1234h    
    error_count     DB 0
    correct_count   DB 0
    round_num       DB 0
    combo_count     DB 0

    start_tick_lo   DW 0
    total_time      DW 0
    reaction_time   DW 0
    
    current_timeout DW 0A000h  ; Baslangic bekleme suresi (Giderek azalacak)

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    CALL CLEAR_SCREEN
    LEA DX, msg_title
    CALL PRINT_STR
    LEA DX, msg_ready
    CALL PRINT_STR

    MOV AH, 00h
    INT 16h

GAME_LOOP:
    INC round_num
    CALL CLEAR_SCREEN
    CALL SHOW_STATUS
    
    CALL WAIT_DELAY
    
    CALL PICK_LETTER
    CALL SHOW_PROMPT
    CALL START_TIMER
    CALL WAIT_KEY

    CMP error_count, 3
    JGE GAME_OVER

    MOV AL, round_num
    CMP AL, 20
    JGE GAME_WIN

    JMP GAME_LOOP

GAME_WIN:
    CALL CLEAR_SCREEN
    LEA DX, msg_win
    CALL PRINT_STR
    JMP SHOW_RESULT

GAME_OVER:
    CALL CLEAR_SCREEN
    LEA DX, msg_gameover
    CALL PRINT_STR

SHOW_RESULT:
    LEA DX, msg_score
    CALL PRINT_STR
    XOR AH, AH
    MOV AL, correct_count
    CALL PRINT_NUM
    LEA DX, msg_newline
    CALL PRINT_STR

    LEA DX, msg_avg
    CALL PRINT_STR
    CMP correct_count, 0
    JE SKIP_AVG
    MOV AX, total_time
    XOR BH, BH
    MOV BL, correct_count
    XOR DX, DX
    DIV BX
    CALL PRINT_NUM
    JMP AVG_DONE
SKIP_AVG:
    MOV AX, 0
    CALL PRINT_NUM
AVG_DONE:
    LEA DX, msg_newline
    CALL PRINT_STR
    LEA DX, msg_goodbye
    CALL PRINT_STR

    MOV AH, 4Ch
    INT 21h
MAIN ENDP

WAIT_DELAY PROC
    PUSH CX
    MOV CX, TUR_ARASI_SURE
WD_L: 
    NOP
    LOOP WD_L
    POP CX
    RET
WAIT_DELAY ENDP

SMALL_PAUSE PROC
    PUSH CX
    MOV CX, GERI_BILDIRIM
SP_L: 
    NOP
    LOOP SP_L
    POP CX
    RET
SMALL_PAUSE ENDP

PICK_LETTER PROC
    PUSH AX
    PUSH BX
    PUSH DX
PL_RETRY:
    MOV AX, rand_seed
    MOV BX, 25173
    MUL BX
    ADD AX, 13849
    MOV rand_seed, AX
    XOR DX, DX
    MOV BX, 6
    DIV BX
    MOV BX, DX
    MOV AL, letters[BX]
    CMP AL, prev_letter
    JE PL_RETRY
    MOV current_letter, AL
    MOV prev_letter, AL
    POP DX
    POP BX
    POP AX
    RET
PICK_LETTER ENDP

SHOW_STATUS PROC
    LEA DX, msg_round
    CALL PRINT_STR
    XOR AH, AH
    MOV AL, round_num
    CALL PRINT_NUM
    LEA DX, msg_of20
    CALL PRINT_STR
    XOR AH, AH
    MOV AL, error_count
    CALL PRINT_NUM
    LEA DX, msg_slash3
    CALL PRINT_STR
    RET
SHOW_STATUS ENDP

SHOW_PROMPT PROC
    LEA DX, msg_press
    CALL PRINT_STR
    MOV AL, '['
    CALL PRINT_CHAR
    MOV AL, current_letter
    CALL PRINT_CHAR
    MOV AL, ']'
    CALL PRINT_CHAR
    LEA DX, msg_newline
    CALL PRINT_STR
    RET
SHOW_PROMPT ENDP

START_TIMER PROC
    MOV AH, 00h
    INT 1Ah
    MOV start_tick_lo, DX
    RET
START_TIMER ENDP

WAIT_KEY PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
WK_CLEAR:
    MOV AH, 01h
    INT 16h
    JZ WK_START
    MOV AH, 00h
    INT 16h
    JMP WK_CLEAR
    
WK_START:
    MOV CX, current_timeout    ; Degisken sureden oku
WK_LOOP:
    MOV AH, 01h
    INT 16h
    JNZ WK_GOT_KEY
    LOOP WK_LOOP
    JMP WK_TIMEOUT
    
WK_GOT_KEY:
    MOV AH, 00h
    INT 16h
    MOV BL, AL

    MOV AH, 00h
    INT 1Ah
    SUB DX, start_tick_lo
    MOV reaction_time, DX
    ADD total_time, DX

    MOV AL, BL
    CMP AL, 'a'
    JB WK_CHECK
    CMP AL, 'z'
    JA WK_CHECK
    AND AL, 0DFh

WK_CHECK:
    CMP AL, current_letter
    JE WK_CORRECT

    MOV combo_count, 0
    INC error_count
    LEA DX, msg_wrong
    CALL PRINT_STR
    XOR AH, AH
    MOV AL, error_count
    CALL PRINT_NUM
    LEA DX, msg_newline
    CALL PRINT_STR
    JMP WK_DONE

WK_CORRECT:
    INC correct_count
    INC combo_count
    LEA DX, msg_correct
    CALL PRINT_STR
    LEA DX, msg_reaction
    CALL PRINT_STR
    MOV AX, reaction_time
    CALL PRINT_NUM
    LEA DX, msg_reaction2
    CALL PRINT_STR
    
    ; --- ZORLUK ARTISI (HOCA KRITERI) ---
    ; Her dogru cevapta sureyi biraz kisalt (Oyun hizlanir)
    MOV AX, current_timeout
    SUB AX, 0800h            ; Sureyi azalt
    CMP AX, 1000h            ; Minimum sure siniri (Cok imkansiz olmasin)
    JGE UPDATE_TIMEOUT
    MOV AX, 1000h
UPDATE_TIMEOUT:
    MOV current_timeout, AX
    
    MOV AL, combo_count
    CMP AL, 3
    JL WK_DONE
    LEA DX, msg_combo
    CALL PRINT_STR
    
WK_DONE:
    CALL SMALL_PAUSE
    POP DX
    POP CX
    POP BX
    POP AX
    RET
    
WK_TIMEOUT:
    INC error_count
    MOV combo_count, 0
    LEA DX, msg_timeout
    CALL PRINT_STR
    XOR AH, AH
    MOV AL, error_count
    CALL PRINT_NUM
    LEA DX, msg_newline
    CALL PRINT_STR
    JMP WK_DONE
WAIT_KEY ENDP

CLEAR_SCREEN PROC
    MOV AH, 06h
    MOV AL, 0
    MOV BH, 07h
    MOV CX, 0
    MOV DX, 184Fh
    INT 10h
    MOV AH, 02h
    MOV BH, 0
    MOV DX, 0
    INT 10h
    RET
CLEAR_SCREEN ENDP

PRINT_STR PROC
    MOV AH, 09h
    INT 21h
    RET
PRINT_STR ENDP

PRINT_CHAR PROC
    PUSH DX
    MOV DL, AL
    MOV AH, 02h
    INT 21h
    POP DX
    RET
PRINT_CHAR ENDP

PRINT_NUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    CMP AX, 0
    JNE PN_NZ
    MOV DL, '0'
    MOV AH, 02h
    INT 21h
    JMP PN_D
PN_NZ:
    MOV BX, 10
    MOV CX, 0
PN_L1:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    OR AX, AX
    JNZ PN_L1
PN_L2:
    POP DX
    ADD DL, '0'
    MOV AH, 02h
    INT 21h
    LOOP PN_L2
PN_D:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUM ENDP

END MAIN