;����һ��Term�жϣ�֧��A,D,G,R,U����
GOTO Term_Main

DATA KeyBoard_Cache 500 ;���浱ǰδ��ɵ����������
DATA KeyBoard_Cache_P 1 ;��¼��������һ���ַ��ĵ�ַ

DATA Term_RegSave 8 ;����Gָ��ִ�к�ļĴ���
DATA Term_Program 200 ;ָ��洢��
DATA Term_Program_End 1 ;ָ��洢����β(��Ҫд��ĵ�ַ)
STRING Term_Input_SIG "  >> "

Term_Main:
  CALL VGA_MEM_INIT
  CALL Term_INIT
  CALL VGA_COM_PRINT
  LOAD_ADDR Term_Input_SIG R0   ;�����">>> "
  CALL printf
;LOAD_ADDR CALC_TEST_S R2
  Term_Main_KeyBoard_Get_Loop:
    CALL KeyBoard_Get
;LW R2 R0 0
;ADDIU R2 1
;BEQZ R0 Term_Main_KeyBoard_Get_Enter
;NOP
    BEQZ R0 Term_Main_KeyBoard_Get_Loop
    NOP
    LI R6 1B
    CMP R0 R6   ;�ж��Ƿ�ΪESC
    BTEQZ Term_Main_RET ;��ESC
    NOP
    LI R6 0A
    CMP R0 R6   ;�ж��Ƿ�Ϊ�س�
    BTEQZ Term_Main_KeyBoard_Get_Enter ;�ǻس�
    NOP
    CALL print_char  ;����������ַ�
    LOAD_DATA KeyBoard_Cache_P R1 0
    SW R1 R0 0
    ADDIU R1 1
    SAVE_DATA KeyBoard_Cache_P R1 0
    B Term_Main_KeyBoard_Get_Loop
    NOP
    Term_Main_KeyBoard_Get_Enter:
        CALL Term_Main_KeyBoard_Enter
    CALL VGA_COM_PRINT
    B Term_Main_KeyBoard_Get_Loop
    NOP
  Term_Main_RET:
  RET

Term_Main_KeyBoard_Enter:   ;�����¼��̻س�ʱӦ��������߼�
  SAVE_REG
  ;��ջ���������\0
  CALL next_cursor_line
  Load_Data KeyBoard_Cache_P R0 0
  LI R1 0
  SW R0 R1 0
  LOAD_ADDR KeyBoard_Cache R0
  SAVE_DATA KeyBoard_Cache_P R0 0
  LW R0 R1 0 ;R1=���������ַ�
  ;�ж��Ƿ�ΪAָ��
  LI R6 41
  CMP R6 R1
  BTNEZ Term_Main_KeyBoard_Enter_NotA
  NOP
    CALL Term_A_Command
  Term_Main_KeyBoard_Enter_NotA:
  ;�ж��Ƿ�ΪRָ��
  LI R6 52
  CMP R6 R1
  BTNEZ Term_Main_KeyBoard_Enter_NotR
  NOP
    CALL Term_R_Command
  Term_Main_KeyBoard_Enter_NotR:
  ;�ж��Ƿ�ΪDָ��
  LI R6 44
  CMP R6 R1
  BTNEZ Term_Main_KeyBoard_Enter_NotD
  NOP
    CALL Term_D_Command
  TERM_MAIN_KEYBOARD_ENTER_NOTD:
  ;�ж��Ƿ�ΪUָ��
  LI R6 55
  CMP R6 R1
  BTNEZ Term_Main_KeyBoard_Enter_NotU
  NOP
    CALL Term_U_Command
  Term_Main_KeyBoard_Enter_NotU:
  ;�ж��Ƿ�ΪGָ��
  LI R6 47
  CMP R6 R1
  BTNEZ Term_Main_KeyBoard_Enter_NotG
  NOP
    CALL Term_G_Command
  Term_Main_KeyBoard_Enter_NotG:
  CALL next_cursor_line
  Load_Addr Term_Input_SIG R0
  CALL printf
  LOAD_REG
  RET

Term_R_Command:   ;�鿴�Ĵ�����
  SAVE_REG
  
  STRING Term_R_Command_0 "R0="
  LOAD_ADDR Term_R_Command_0 R0
  CALL printf
  LOAD_DATA Term_RegSave R0 0
  CALL String_IntToHex
  CALL printf
  
  STRING Term_R_Command_1 "  R1="
  LOAD_ADDR Term_R_Command_1 R0
  CALL printf
  LOAD_DATA Term_RegSave R0 1
  CALL String_IntToHex
  CALL printf
  
  STRING Term_R_Command_2 "  R2="
  LOAD_ADDR Term_R_Command_2 R0
  CALL printf
  LOAD_DATA Term_RegSave R0 2
  CALL String_IntToHex
  CALL printf
  
  CALL next_cursor_line
  
  STRING Term_R_Command_3 "R3="
  LOAD_ADDR Term_R_Command_3 R0
  CALL printf
  LOAD_DATA Term_RegSave R0 3
  CALL String_IntToHex
  CALL printf
  
  STRING Term_R_Command_4 "  R4="
  LOAD_ADDR Term_R_Command_4 R0
  CALL printf
  LOAD_DATA Term_RegSave R0 4
  CALL String_IntToHex
  CALL printf
  
  STRING Term_R_Command_5 "  R5="
  LOAD_ADDR Term_R_Command_5 R0
  CALL printf
  LOAD_DATA Term_RegSave R0 5
  CALL String_IntToHex
  CALL printf
  
  LOAD_REG
  RET

Term_INIT:     ;��ʼ������Ļ�ַ���ʾ
  SAVE_REG
  LI R0 VGA_N;��ʼ�������߶�
  SAVE_DATA Print_Scroll_Bottom R0 0
  LI R0 0
  SAVE_DATA Term_RegSave R0 0
  SAVE_DATA Term_RegSave R0 1
  SAVE_DATA Term_RegSave R0 2
  SAVE_DATA Term_RegSave R0 3
  SAVE_DATA Term_RegSave R0 4
  SAVE_DATA Term_RegSave R0 5
  SAVE_DATA Term_RegSave R0 6
  SAVE_DATA Term_RegSave R0 7
  LOAD_ADDR KeyBoard_Cache R0
  SAVE_DATA KeyBoard_Cache_P R0 0
  LI R0 0
  CALL set_cursor
  LOAD_REG
  RET

Term_A_Command_Insert_Get1Bit:   ;��R0ָ����ַ�����ȡ��R1�±���ַ�(0-9,A-Z)����ת��Ϊ��������R0
  ADDU R0 R1 R0
  LW R0 R0 0 ;����R0���ַ�
  CALL String_HexCharToInt
  RET

Term_A_Command_Insert:   ;��ָ���ĩβ����һ��ָ�ָ���ַ����׵�ַΪR0
  SAVE_REG
  ;����
  MOVE R5 R0
  ;�ж��Ƿ�ΪADDIU
  STRING TERM_PC_ADDIU "ADDIU"
  MOVE R0 R5  ;R5����ָ���ַ�����ַ
  LOAD_ADDR TERM_PC_ADDIU R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotAddiu
  NOP
    ;����ADDIU���߼�
    LI R4 48;����ָ��
    ;ȡ��Rx
    MOVE R0 R5
    LI R1 7
    CALL Term_A_Command_Insert_Get1Bit
    ADDU R0 R4 R4
    SLL R4 R4 0
    ;ȡ��imm��λ
    MOVE R0 R5
    LI R1 9
    CALL Term_A_Command_Insert_Get1Bit
    SLL R0 R0 4
    ADDU R0 R4 R4
    ;ȡ��imm��λ
    MOVE R0 R5
    LI R1 A
    CALL Term_A_Command_Insert_Get1Bit
    ADDU R0 R4 R4
    GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotAddiu:
  ;�ж��Ƿ�ΪLI
  STRING TERM_PC_LI "LI"
  MOVE R0 R5
  LOAD_ADDR TERM_PC_LI R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotLI
  NOP
    ;����LI���߼�
    LI R4 68;����ָ��
    ;ȡ��Rx
    MOVE R0 R5
    LI R1 4
    CALL Term_A_Command_Insert_Get1Bit
    ADDU R0 R4 R4
    SLL R4 R4 0
    ;ȡ��imm��λ
    MOVE R0 R5
    LI R1 6
    CALL Term_A_Command_Insert_Get1Bit
    SLL R0 R0 4
    ADDU R0 R4 R4
    ;ȡ��imm��λ
    MOVE R0 R5
    LI R1 7
    CALL Term_A_Command_Insert_Get1Bit
    ADDU R0 R4 R4
    GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotLI:
  ;�ж��Ƿ�ΪJR
  STRING TERM_PC_JR "JR"
  MOVE R0 R5
  LOAD_ADDR TERM_PC_JR R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotJR
  NOP
    ;����JR���߼�
    LI R4 E8;����ָ��
    ;ȡ��Rx
    MOVE R0 R5
    LI R1 4
    CALL Term_A_Command_Insert_Get1Bit
    ADDU R0 R4 R4
    SLL R4 R4 0
    GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotJR:
  ;�ж��Ƿ�ΪNOP
  STRING TERM_PC_NOP "NOP"
  MOVE R0 R5
  LOAD_ADDR TERM_PC_NOP R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotNOP
  NOP
    ;����NOP���߼�
    LI R4 08
    SLL R4 R4 0
    GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotNOP:
  ;����Ϊ����ָ��Ƿ�
  B Term_A_Command_Insert_Error
  NOP
  Term_A_Command_Insert_Correct:  ;������ȷ��ָ��
    ;����R4����ȷ��ָ���ʽ
    LOAD_DATA Term_Program_End R5 0 ;R5��������һ��дָ��ĵ�ַ
    SW R5 R4 0
    ADDIU R5 1
    SAVE_DATA Term_Program_End R5 0 ;R5��������һ��дָ��ĵ�ַ
    LOAD_REG
    RET
  Term_A_Command_Insert_Error:  ;�ܾ������ָ��
    STRING Term_Program_Command_Error "Syntax Error"
    LOAD_ADDR Term_Program_Command_Error R0
    CALL printf
    LOAD_REG
    RET

Term_A_Command:    ;������
  SAVE_REG
  LOAD_ADDR Term_Program R0
  SAVE_DATA Term_Program_End R0 0
  Term_A_Command_InstLoop:
  ;�ȴ�ӡ��ǰָ���ַ
  LI R0 5B;'['
  CALL print_char
  LOAD_ADDR Term_Program R0
  LOAD_DATA Term_Program_End R1 0
  SUBU R1 R0 R0
  CALL String_IntToHex
  CALL printf
  LI R0 5D;']'
  CALL print_char
  LI R0 20;' '
  CALL print_char
  LI R0 20;' '
  CALL print_char
  Term_A_Command_Get_Loop:
  CALL KeyBoard_Get
    BEQZ R0 Term_A_Command_Get_Loop
    NOP
    ;�ж��Ƿ�Ϊ�˸�
    LI R6 08
    CMP R0 R6
    BTNEZ Term_A_Command_NoBackSpace
    NOP
      LOAD_DATA KeyBoard_Cache_P R0 0
      LOAD_ADDR KeyBoard_Cache R1
      CMP R0 R1
      BTEQZ Term_A_Command_NoBackSpace;���Ѿ������������������һ����
      NOP
      CALL last_cursor ;����һ��
      LOAD_DATA CURSOR_X R6 0
      SLL R0 R6 0
      LOAD_DATA CURSOR_Y R6 0
      ADDU R0 R6 R0
      LI R1 20
      CALL VGA_Draw_Block ;�����ʾ
      LOAD_DATA KeyBoard_Cache_P R0 0
      ADDIU R0 FF
      SAVE_DATA KeyBoard_Cache_P R0 0
      B Term_A_Command_Get_Loop
      NOP
    Term_A_Command_NoBackSpace:
    ;�ж��Ƿ�Ϊ�س�
    LI R6 0A
    CMP R0 R6
    BTNEZ Term_A_Command_NoEnter
    NOP
      ;�ǻس�,����س��߼�
      CALL next_cursor_line
      LOAD_DATA KeyBoard_Cache_P R1 0
      LOAD_ADDR KeyBoard_Cache R2
      CMP R1 R2
      BTEQZ Term_A_Command_RET ;�������Ϊ�����ʾ�������
      NOP
      ;��ջ���������\0
      Load_Data KeyBoard_Cache_P R0 0
      LI R1 0
      SW R0 R1 0
      LOAD_ADDR KeyBoard_Cache R0
      SAVE_DATA KeyBoard_Cache_P R0 0
      CALL Term_A_Command_Insert
      B Term_A_Command_InstLoop
      NOP
    Term_A_Command_NoEnter:
    CALL print_char  ;����������ַ�
    LOAD_DATA KeyBoard_Cache_P R1 0
    SW R1 R0 0
    ADDIU R1 1
    SAVE_DATA KeyBoard_Cache_P R1 0
    B Term_A_Command_Get_Loop
    NOP
  Term_A_Command_RET:
  CALL next_cursor_line
  LOAD_REG
  RET
  
Term_D_Command:    ;
  RET
  
Term_G_Command:    ;
  SAVE_REG  
  LOAD_DATA Term_RegSave R0 0
  LOAD_DATA Term_RegSave R1 1
  LOAD_DATA Term_RegSave R2 2
  LOAD_DATA Term_RegSave R3 3
  LOAD_DATA Term_RegSave R4 4
  LOAD_DATA Term_RegSave R5 5
  LOAD_ADDR Term_Program R6 0
  SW_SP R7 0
  ADDSP 1
  MFPC R7
  ADDIU R7 3
  JR R6
  NOP
  SAVE_DATA Term_RegSave R0 0
  SAVE_DATA Term_RegSave R1 1
  SAVE_DATA Term_RegSave R2 2
  SAVE_DATA Term_RegSave R3 3
  SAVE_DATA Term_RegSave R4 4
  SAVE_DATA Term_RegSave R5 5
  ADDSP FF
  LW_SP R7 0
  LOAD_REG
  RET  
  
Term_UASM:         ;�����R0ָ������һ��
  SAVE_REG
  SRL R1 R0 0
  SRL R1 R1 3      ;R1ΪR0ǰ5λ
  SRL R4 R0 0      ;R4ΪR0ǰ8λ
  SLL R5 R0 0
  SLL R5 R5 3
  SRL R5 R5 0
  SRL R5 R5 3		;R5ΪR0��5λ
  MOVE R3 R0
  
  LI R2 9	;ADDIU 
  XOR R2 R1
  BNEZ R2 Term_UASM_ADDIU_END
  NOP
  STRING Term_UASM_ADDIU_String "ADDIU "
  LOAD_ADDR Term_UASM_ADDIU_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rximm
  GOTO Term_UASM_RET
  Term_UASM_ADDIU_END:
  
  LI R2 0	;ADDSP3 
  XOR R2 R1
  BNEZ R2 Term_UASM_ADDSP3_END
  NOP
  STRING Term_UASM_ADDSP3_String "ADDSP3 "
  LOAD_ADDR Term_UASM_ADDSP3_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rximm
  GOTO Term_UASM_RET
  Term_UASM_ADDSP3_END:
  
  LI R2 63	;ADDSP
  XOR R2 R4
  BNEZ R2 Term_UASM_ADDSP_END
  NOP
  STRING Term_UASM_ADDSP_String "ADDSP "
  LOAD_ADDR Term_UASM_ADDSP_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_imm
  GOTO Term_UASM_RET
  Term_UASM_ADDSP_END:
  
  LI R2 1C	;ADDU
  XOR R2 R1
  BNEZ R2 Term_UASM_ADDU_END
  NOP
  LI R2 1
  MOVE R6 R3
  SLL R6 0
  SLL R6 6
  SRL R6 0
  SRL R6 6
  XOR R2 R6
  BNEZ R2 Term_UASM_ADDU_END
  NOP
  STRING Term_UASM_ADDU_String "ADDU "
  LOAD_ADDR Term_UASM_ADDU_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rxryrz
  GOTO Term_UASM_RET
  Term_UASM_ADDU_END:
  
  LI R2 1C	;AND
  XOR R2 R1
  BNEZ R2 Term_UASM_AND_END
  NOP
  STRING Term_UASM_AND_String "AND "
  LOAD_ADDR Term_UASM_AND_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rxry
  GOTO Term_UASM_RET
  Term_UASM_AND_END:
  
  LI R2 2	;B
  XOR R2 R1
  BNEZ R2 Term_UASM_B_END
  NOP
  STRING Term_UASM_B_String "B "
  LOAD_ADDR Term_UASM_B_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_imm
  GOTO Term_UASM_RET
  Term_UASM_B_END:
  
  LI R2 4	;BEQZ
  XOR R2 R1
  BNEZ R2 Term_UASM_BEQZ_END
  NOP
  STRING Term_UASM_BEQZ_String "BEQZ "
  LOAD_ADDR Term_UASM_BEQZ_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rximm
  GOTO Term_UASM_RET
  Term_UASM_BEQZ_END:
  
  LI R2 5	;BNEZ
  XOR R2 R1
  BNEZ R2 Term_UASM_BNEZ_END
  NOP
  STRING Term_UASM_BNEZ_String "BNEZ "
  LOAD_ADDR Term_UASM_BNEZ_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rximm
  GOTO Term_UASM_RET
  Term_UASM_BNEZ_END:
  
  LI R2 60	;BTEQZ
  XOR R2 R4
  BNEZ R2 Term_UASM_BTEQZ_END
  NOP
  STRING Term_UASM_BTEQZ_String "BTEQZ "
  LOAD_ADDR Term_UASM_BTEQZ_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_imm
  GOTO Term_UASM_RET
  Term_UASM_BTEQZ_END:
  
  LI R2 61	;BTNEZ
  XOR R2 R4
  BNEZ R2 Term_UASM_BTNEZ_END
  NOP
  STRING Term_UASM_BTNEZ_String "BTNEZ "
  LOAD_ADDR Term_UASM_BTNEZ_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_imm
  GOTO Term_UASM_RET
  Term_UASM_BTNEZ_END:
  
  LI R2 1D	;CMP
  XOR R2 R1
  BNEZ R2 Term_UASM_CMP_END
  NOP
  LI R2 A
  XOR R2 R5
  BNEZ R2 Term_UASM_CMP_END
  NOP
  STRING Term_UASM_CMP_String "CMP "
  LOAD_ADDR Term_UASM_CMP_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rxry
  GOTO Term_UASM_RET
  Term_UASM_CMP_END:
  
  LI R2 1D	;JR
  XOR R2 R1
  BNEZ R2 Term_UASM_JR_END
  NOP
  LI R2 0
  XOR R2 R5
  BNEZ R2 Term_UASM_JR_END
  NOP
  STRING Term_UASM_JR_String "JR "
  LOAD_ADDR Term_UASM_JR_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rximm
  GOTO Term_UASM_RET
  Term_UASM_JR_END:
  
  LI R2 D	;LI
  XOR R2 R1
  BNEZ R2 Term_UASM_LI_END
  NOP
  STRING Term_UASM_LI_String "LI "
  LOAD_ADDR Term_UASM_LI_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rximm
  GOTO Term_UASM_RET
  Term_UASM_LI_END:
  
  LI R2 13	;LW
  XOR R2 R1
  BNEZ R2 Term_UASM_LW_END
  NOP
  STRING Term_UASM_LW_String "LW "
  LOAD_ADDR Term_UASM_LW_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rximm
  GOTO Term_UASM_RET
  Term_UASM_LW_END:
  
  LI R2 12	;LW_SP
  XOR R2 R1
  BNEZ R2 Term_UASM_LW_SP_END
  NOP
  STRING Term_UASM_LW_SP_String "LW_SP "
  LOAD_ADDR Term_UASM_LW_SP_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rximm
  GOTO Term_UASM_RET
  Term_UASM_LW_SP_END:
  
  LI R2 F	;MOVE
  XOR R2 R1
  BNEZ R2 Term_UASM_MOVE_END
  NOP
  STRING Term_UASM_MOVE_String "MOVE "
  LOAD_ADDR Term_UASM_MOVE_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rxry
  GOTO Term_UASM_RET
  Term_UASM_MOVE_END:
  
  LI R2 08	;NOP
  SLL R2 R2 0
  XOR R2 R3
  BNEZ R2 Term_UASM_NOP_END
  NOP
  STRING Term_UASM_NOP_String "NOP "
  LOAD_ADDR Term_UASM_NOP_String R0
  CALL printf
  GOTO Term_UASM_RET
  Term_UASM_NOP_END:
  
  LI R2 6	;SLL
  XOR R2 R1
  BNEZ R2 Term_UASM_SLL_END
  NOP
  LI R2 0
  MOVE R6 R3
  SLL R6 0
  SLL R6 6
  SRL R6 0
  SRL R6 6
  XOR R2 R6
  BNEZ R2 Term_UASM_SLL_END
  NOP
  STRING Term_UASM_SLL_String "SLL "
  LOAD_ADDR Term_UASM_SLL_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rxryimm
  GOTO Term_UASM_RET
  Term_UASM_SLL_END:
  
  LI R2 1D	;SLT
  XOR R2 R1
  BNEZ R2 Term_UASM_SLT_END
  NOP
  LI R2 2
  XOR R2 R5
  BNEZ R2 Term_UASM_SLT_END
  NOP
  STRING Term_UASM_SLT_String "SLT "
  LOAD_ADDR Term_UASM_SLT_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rxry
  GOTO Term_UASM_RET
  Term_UASM_SLT_END:
  
  LI R2 6	;SRL
  XOR R2 R1
  BNEZ R2 Term_UASM_SRL_END
  NOP
  LI R2 2
  MOVE R6 R3
  SLL R6 0
  SLL R6 6
  SRL R6 0
  SRL R6 6
  XOR R2 R6
  BNEZ R2 Term_UASM_SRL_END
  NOP
  STRING Term_UASM_SRL_String "SRL "
  LOAD_ADDR Term_UASM_SRL_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rxryimm
  GOTO Term_UASM_RET
  Term_UASM_SRL_END:
  
  LI R2 1C	;SUBU
  XOR R2 R1
  BNEZ R2 Term_UASM_SUBU_END
  NOP
  LI R2 3
  MOVE R6 R3
  SLL R6 0
  SLL R6 6
  SRL R6 0
  SRL R6 6
  XOR R2 R6
  BNEZ R2 Term_UASM_SUBU_END
  NOP
  STRING Term_UASM_SUBU_String "SUBU "
  LOAD_ADDR Term_UASM_SUBU_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rxryrz
  GOTO Term_UASM_RET
  Term_UASM_SUBU_END:
  
  LI R2 1B	;SW
  XOR R2 R1
  BNEZ R2 Term_UASM_SW_END
  NOP
  STRING Term_UASM_SW_String "SW "
  LOAD_ADDR Term_UASM_SW_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rxryimm
  GOTO Term_UASM_RET
  Term_UASM_SW_END:
  
  STRING Term_UASM_Unknown "--- Unknown ---"
  LOAD_ADDR Term_UASM_Unknown R0
  CALL printf
  
  Term_UASM_RET:
	  LOAD_REG
	  RET

Term_U_Command:    ;
  SAVE_REG
  LOAD_ADDR Term_Program R4;R4���ڴ��ַѭ������
  LOAD_DATA Term_Program_End R5 0 ;R5��Ŀ���ַ
  Term_U_Command_Loop:
    LW R4 R0 0 ;��ָ��д��R0
    ;����Ѿ�����ָ���б�ĩβ��return
    CMP R4 R5
    BTEQZ Term_U_Command_RET
    NOP
    ;�ȴ�ӡ��ǰָ���ַ
    LI R0 5B;'['
    CALL print_char
    LOAD_ADDR Term_Program R0
    SUBU R4 R0 R0
    CALL String_IntToHex
    CALL printf
    LI R0 5D;']'
    CALL print_char
    LW R4 R0 0 ;��ָ��д��R0
    STRING Term_U_Command_Left_String "      <"
    LOAD_ADDR Term_U_Command_Left_String R0
    CALL printf
    LW R4 R0 0 ;��ָ��д��R0
    CALL print_int
    STRING Term_U_Command_Right_String ">    "
    LOAD_ADDR Term_U_Command_Right_String R0
    CALL printf
    LW R4 R0 0 ;��ָ��д��R0
    CALL Term_UASM  ;�����
    CALL next_cursor_line
    ADDIU R4 1
    B Term_U_Command_Loop
    NOP
  Term_U_Command_RET:
  CALL next_cursor_line
  LOAD_REG
  RET
  
Term_UASM_Decode_rxryrz:		;����op rx ry rz��ָ���룬ָ��������R0
  SAVE_REG
  MOVE R1 R0
  
  LI R0 52	;R
  CALL print_char
  MOVE R0 R1
  SLL R0 R0 5
  SRL R0 R0 0
  SRL R0 R0 5
  ADDIU R0 30
  CALL print_char 
  LI R0 20
  CALL print_char
  MOVE R0 R1
  
  LI R0 52	;R
  CALL print_char
  MOVE R0 R1
  SLL R0 R0 0
  SRL R0 R0 0
  SRL R0 R0 5
  ADDIU R0 30
  CALL print_char 
  LI R0 20
  CALL print_char
  MOVE R0 R1
  
  LI R0 52	;R
  CALL print_char
  MOVE R0 R1
  SLL R0 R0 3
  SLL R0 R0 0
  SRL R0 R0 0
  SRL R0 R0 5
  ADDIU R0 30
  CALL print_char 
  
  LOAD_REG
  RET  
  
Term_UASM_Decode_rxry:		;����op rx ry��ָ���룬ָ��������R0
  SAVE_REG
  MOVE R1 R0
  
  LI R0 52	;R
  CALL print_char
  MOVE R0 R1
  SLL R0 R0 5
  SRL R0 R0 0
  SRL R0 R0 5
  ADDIU R0 30
  CALL print_char 
  LI R0 20
  CALL print_char
  MOVE R0 R1
  
  LI R0 52	;R
  CALL print_char
  MOVE R0 R1
  SLL R0 R0 0
  SRL R0 R0 0
  SRL R0 R0 5
  ADDIU R0 30
  CALL print_char 

  LOAD_REG
  RET  
  
Term_UASM_Decode_rxryimm:		;����op rx ry imm��ָ���룬ָ��������R0
  SAVE_REG
  MOVE R1 R0
  
  LI R0 52	;R
  CALL print_char
  MOVE R0 R1
  SLL R0 R0 5
  SRL R0 R0 0
  SRL R0 R0 5
  ADDIU R0 30
  CALL print_char 
  LI R0 20
  CALL print_char
  MOVE R0 R1
  
  LI R0 52	;R
  CALL print_char
  MOVE R0 R1
  SLL R0 R0 0
  SRL R0 R0 0
  SRL R0 R0 5
  ADDIU R0 30
  CALL print_char 
  LI R0 20
  CALL print_char
  MOVE R0 R1
  
  SRL R0 R0 2
  SLL R0 R0 0
  SLL R0 R0 5
  SRL R0 R0 0
  SRL R0 R0 5
  CALL String_8IntToHex
  CALL printf
  LOAD_REG
  RET    
  
Term_UASM_Decode_rx:		;����op rx ��ָ���룬ָ��������R0
  SAVE_REG
  MOVE R1 R0
  LI R0 52	;R
  CALL print_char
  MOVE R0 R1
  SLL R0 R0 5
  SRL R0 R0 0
  SRL R0 R0 5
  ADDIU R0 30
  CALL print_char 
  LOAD_REG
  RET  
  
Term_UASM_Decode_rximm:		;����op rx imm��ָ���룬ָ��������R0
  SAVE_REG
  MOVE R1 R0
  LI R0 52	;R
  CALL print_char
  MOVE R0 R1
  SLL R0 R0 5
  SRL R0 R0 0
  SRL R0 R0 5
  ADDIU R0 30
  CALL print_char 
  LI R0 20
  CALL print_char
  MOVE R0 R1
  CALL String_8IntToHex
  CALL printf
  LOAD_REG
  RET
  
Term_UASM_Decode_imm:		;����rx imm��ָ���룬ָ��������R0
  SAVE_REG
  CALL String_8IntToHex
  CALL printf
  LOAD_REG
  RET