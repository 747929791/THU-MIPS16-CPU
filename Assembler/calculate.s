;����һ���ı�������(����"34*100"���"3400")
GOTO Calculate_Main

;STRING CALC_TEST_S "123*41" ;���Ա��ʽ
STRING CALC_TEST_S "10/3E" ;���Ա��ʽ
DATA CALC_RESULT 10  ;��ż�����
DATA CALC_RESULT_END 1 ;����������Ľ�β
STRING Calculate_Input_SIG ">>> "

Calculate_Test:
  Load_addr CALC_TEST_S R0
  CALL Calculate_Calc
  RET

Calculate_Main:
  CALL VGA_MEM_INIT
  CALL Calculate_INIT
  CALL VGA_COM_PRINT
  LOAD_ADDR Calculate_Input_SIG R0   ;�����">>> "
  CALL printf
  Calculate_Main_KeyBoard_Get_Loop:
    CALL KeyBoard_Get
    BEQZ R0 Calculate_Main_KeyBoard_Get_Loop
    NOP
    
    LI R6 08
    CMP R0 R6   ;�ж��Ƿ�ΪBackSpace
    BTNEZ Calculate_Main_NoBackSpace
    NOP
    CALL Print_Cache_BackSpace
    GOTO Calculate_Main_KeyBoard_Get_Loop
    Calculate_Main_NoBackSpace:
    
    LI R6 1B
    CMP R0 R6   ;�ж��Ƿ�ΪESC
    BTEQZ Calculate_Main_RET ;��ESC
    NOP
    
    LI R6 0A
    CMP R0 R6   ;�ж��Ƿ�Ϊ�س�
    BTEQZ Calculate_Main_KeyBoard_Get_Enter ;�ǻس�
    NOP
    
    CALL print_char  ;����������ַ�
    LOAD_DATA KeyBoard_Cache_P R1 0
    SW R1 R0 0
    ADDIU R1 1
    SAVE_DATA KeyBoard_Cache_P R1 0
    B Calculate_Main_KeyBoard_Get_Loop
    NOP
    Calculate_Main_KeyBoard_Get_Enter:
        CALL Calculate_Main_KeyBoard_Enter
    CALL VGA_COM_PRINT
    GOTO Calculate_Main_KeyBoard_Get_Loop
  Calculate_Main_RET:
  RET

Calculate_Main_KeyBoard_Enter:   ;�����¼��̻س�ʱӦ��������߼�
  SAVE_REG
  ;��ջ���������\0
  CALL next_cursor_line
  Load_Data KeyBoard_Cache_P R0 0
  LI R1 0
  SW R0 R1 0
  LOAD_ADDR KeyBoard_Cache R0
  SAVE_DATA KeyBoard_Cache_P R0 0
  ;����������ʽ���������ʾ
  CALL Calculate_Calc
  CALL printf
  CALL next_cursor_line
  Load_Addr Calculate_Input_SIG R0
  CALL printf
  LOAD_REG
  RET

Calculate_Calc:     ;����R0ָ���ַ���ַ���������ʽ��ֵ����������ַ����׵�ַͨ��R0����
  SAVE_REG
  ;�����������ڶ�ջ��
  LI R3 0
  LI R4 0 ;R4��¼��ǰ���ڼ���Ĳ�������R3��¼�������
  LI R5 FF ;R5�����
  LW R0 R1 0   ;���ַ�����R1
  Calculate_Calc_Loop:    
    ;�����ǰֵ��Ϊ������Ĭ��Ϊ�����
    LI R6 39
    SLT R6 R1
    BTNEZ Calculate_Calc_Find_Operator
    NOP
    LI R6 30
    SLT R1 R6
    BTNEZ Calculate_Calc_Find_Operator
    NOP
    ;����Ϊ����
    B Calculate_Calc_Find_Num
    NOP    
    Calculate_Calc_Find_Operator:
      LI R6 FF
      CMP R5 R6
      BTNEZ 3  ;������һ����׶�
      NOP
      MOVE R3 R4
      LI R4 0
      MOVE R5 R1
      B Calculate_Calc_Loop_Final
      NOP
    Calculate_Calc_Find_Num:
      LI R6 30
      SUBU R1 R6 R1  ;R1 ASCIIת����
      SLL R6 R4 1
      SLL R4 R4 3
      ADDU R4 R1 R4
      ADDU R4 R6 R4 ;R4=10*R4+ord(R0)-48
      B Calculate_Calc_Loop_Final
      NOP
    Calculate_Calc_Loop_Final:
      ADDIU R0 1
      LW R0 R1 0   ;���ַ�����R1
      BNEZ R1 Calculate_Calc_Loop
      NOP
  ;���û�з����������Ĭ��Ϊ�ӷ�
  LI R6 FF
  CMP R5 R6
  BTNEZ 2
  NOP
  LI R5 2B
  ;����R3��R4λ������������ֵ��R5Ϊ������
  LI R6 2B
  CMP R5 R6
  BTEQZ Calculate_Calc_Plus
  LI R6 2D
  CMP R5 R6
  BTEQZ Calculate_Calc_Minus
  LI R6 2A
  CMP R5 R6
  BTEQZ Calculate_Calc_Multi
  LI R6 2F
  CMP R5 R6
  BTEQZ Calculate_Calc_Division
  LI R6 25
  CMP R5 R6
  BTEQZ Calculate_Calc_Mod
  LI R6 5E
  CMP R5 R6
  BTEQZ Calculate_Calc_Power
  NOP
;�ڴ˽��д�����
    STRING Calculate_Calc_Syntax_Error "Syntax Error"
    LOAD_ADDR Calculate_Calc_Syntax_Error R0
    SW_SP R0 F8
    LOAD_REG
    RET
    
  Calculate_Calc_Plus:
    ADDU R3 R4 R0
    B Calculate_Calc_GetResult
    NOP
  Calculate_Calc_Minus:
    SUBU R3 R4 R0
    B Calculate_Calc_GetResult
    NOP
  Calculate_Calc_Multi:
    MOVE R0 R3
    MOVE R1 R4
    CALL MULTI
    B Calculate_Calc_GetResult
    NOP
  Calculate_Calc_Division:
    MOVE R0 R3
    MOVE R1 R4
    CALL DIVISION
    B Calculate_Calc_GetResult
    NOP
  Calculate_Calc_Mod:
    MOVE R0 R3
    MOVE R1 R4
    CALL DIVISION
    MOVE R0 R1
    B Calculate_Calc_GetResult
    NOP
  Calculate_Calc_POWER:
    MOVE R0 R3
    MOVE R1 R4
    CALL POWER
    B Calculate_Calc_GetResult
    NOP
  Calculate_Calc_GetResult:
  ;��ʱR0���������
  LOAD_ADDR CALC_RESULT_END R5 ;R5����д���ַ��ĵ�ַ
  ADDIU R5 FF
  LI R4 0
  SW R5 R4 0  ;���һλΪ\0
  Calculate_Calc_GetResult_L1:
   ADDIU R5 FF
   LI R1 0A
   CALL DIVISION
   ADDIU R1 30
   SW R5 R1 0
   BNEZ R0 Calculate_Calc_GetResult_L1
   NOP
  SW_SP R5 F8
  LOAD_REG
  RET

Calculate_INIT:     ;��ʼ������Ļ�ַ���ʾ
  SAVE_REG
  LOAD_ADDR KeyBoard_Cache R0
  SAVE_DATA KeyBoard_Cache_P R0 0
  LI R0 0
  CALL set_cursor
  STRING Calculate_INIT_Info "Calculate Program. Support '+-*/%^'."
  LOAD_ADDR Calculate_INIT_Info R0
  CALL printf
  CALL next_cursor_line
  LOAD_REG
  RET