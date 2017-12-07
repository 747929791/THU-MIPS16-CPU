;����һ��Term�жϣ�֧��A,D,G,R,U����
GOTO Term_Main

DATA KeyBoard_Cache 500 ;���浱ǰδ��ɵ����������
DATA KeyBoard_Cache_P 1 ;��¼��������һ���ַ��ĵ�ַ

DATA Term_RegSave 8 ;����Gָ��ִ�к�ļĴ���
DATA Term_Program 200 ;ָ��洢��
DATA Term_Program_End 1 ;ָ��洢����β(��Ҫд��ĵ�ַ)
STRING Term_Input_SIG ">> "

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

Term_CharToHex:  ;��R0ת��Ϊ16�����ַ�ASCII��
  SAVE_REG
  LI R6 0F
  AND R0 R6  ;ֻ������4λ
  LI R6 0A
  SLT R0 R6
  BTNEZ Term_CharToHex_0_9
  NOP
  Term_CharToHex_A_F:
    ADDIU R0 37
    SW_SP R0 F8
    LOAD_REG
    RET
  Term_CharToHex_0_9:
    ADDIU R0 30
    SW_SP R0 F8
    LOAD_REG
    RET
    
Term_HexCharToInt:  ;���ַ�R0(0-9,A-F)ת��Ϊ����R0����
  SAVE_REG
  LI R6 30
  SUBU R0 R6 R0
  LI R6 0A
  SLT R0 R6
  BTNEZ Term_HexCharToInt_0_9
  NOP
  Term_HexCharToInt_A_F:
    ADDIU R0 F0
    ADDIU R0 09
    SW_SP R0 F8
    LOAD_REG
    RET
  Term_HexCharToInt_0_9:
    SW_SP R0 F8
    LOAD_REG
    RET

Term_IntToHex:   ;��R0ת��Ϊ4bit16�����ַ��������ַ����׵�ַͨ��R0����
  DATA Term_IntToHex_result 5
  SAVE_REG
  LI R5 0
  SAVE_DATA Term_IntToHex_result R5 4 ;ĩβ\0
  MOVE R5 R0
  ;�����0λ
  SRL R0 R5 0
  SRL R0 R0 4
  CALL Term_CharToHex
  SAVE_DATA Term_IntToHex_result R0 0
  ;�����1λ
  SRL R0 R5 0
  CALL Term_CharToHex
  SAVE_DATA Term_IntToHex_result R0 1
  ;�����2λ
  SRL R0 R5 4
  CALL Term_CharToHex
  SAVE_DATA Term_IntToHex_result R0 2
  ;�����3λ
  MOVE R0 R5
  CALL Term_CharToHex
  SAVE_DATA Term_IntToHex_result R0 3
  LOAD_ADDR Term_IntToHex_result R0
  SW_SP R0 F8
  LOAD_REG
  RET

Term_R_Command:   ;�鿴�Ĵ�����
  SAVE_REG
  
  STRING Term_R_Command_0 "R0="
  LOAD_ADDR Term_R_Command_0 R0
  CALL printf
  LOAD_DATA Term_RegSave R0 0
  CALL Term_IntToHex
  CALL printf
  
  STRING Term_R_Command_1 " R1="
  LOAD_ADDR Term_R_Command_1 R0
  CALL printf
  LOAD_DATA Term_RegSave R0 1
  CALL Term_IntToHex
  CALL printf
  
  STRING Term_R_Command_2 " R2="
  LOAD_ADDR Term_R_Command_2 R0
  CALL printf
  LOAD_DATA Term_RegSave R0 2
  CALL Term_IntToHex
  CALL printf
  
  CALL next_cursor_line
  
  STRING Term_R_Command_3 "R3="
  LOAD_ADDR Term_R_Command_3 R0
  CALL printf
  LOAD_DATA Term_RegSave R0 3
  CALL Term_IntToHex
  CALL printf
  
  STRING Term_R_Command_4 " R4="
  LOAD_ADDR Term_R_Command_4 R0
  CALL printf
  LOAD_DATA Term_RegSave R0 4
  CALL Term_IntToHex
  CALL printf
  
  STRING Term_R_Command_5 " R5="
  LOAD_ADDR Term_R_Command_5 R0
  CALL printf
  LOAD_DATA Term_RegSave R0 5
  CALL Term_IntToHex
  CALL printf
  
  LOAD_REG
  RET

Term_INIT:     ;��ʼ������Ļ�ַ���ʾ
  SAVE_REG
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
  CALL Term_HexCharToInt
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
    LI R1 10
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
MOVE R0 R4
CALL Term_IntToHex
CALL printf
CALL next_cursor_line
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
    CALL next_cursor_line
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
  CALL Term_IntToHex
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
  LOAD_REG
  RET
  
Term_D_Command:    ;
  RET
  
Term_G_Command:    ;
  SAVE_REG  
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
  
Term_U_Command:    ;
  RET