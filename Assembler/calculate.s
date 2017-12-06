;����һ���ı�������(����"34*100"���"3400")
GOTO Calculate_Main

;STRING CALC_TEST_S "123*41" ;���Ա��ʽ
STRING CALC_TEST_S "10/3E" ;���Ա��ʽ
DATA CALC_RESULT 10  ;��ż�����
DATA CALC_RESULT_END 1 ;����������Ľ�β
DATA KeyBoard_Cache 100 ;���浱ǰδ��ɵ����������
DATA KeyBoard_Cache_P 1 ;��¼��������һ���ַ��ĵ�ַ
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
LOAD_ADDR CALC_TEST_S R2
  Calculate_Main_KeyBoard_Get_Loop:
    CALL KeyBoard_Get
;LW R2 R0 0
;ADDIU R2 1
    BEQZ R0 Calculate_Main_KeyBoard_Get_Loop
    NOP
    LI R6 0A
    CMP R0 R6   ;�ж��Ƿ�Ϊ�س�
;LI R6 0
;CMP R0 R6
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
;RET
    B Calculate_Main_KeyBoard_Get_Loop
    NOP
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
  LOAD_REG
  RET

set_cursor:     ;��������������ΪR0(16)λ������ϵͳ�������
  DATA CURSOR_X 1
  DATA CURSOR_Y 1
  SW_SP R1 0
  ADDSP 1
  SRL R1 R0 0
  SAVE_DATA CURSOR_X R1 0
  SLL R0 R0 0
  SRL R0 R0 0
  SAVE_DATA CURSOR_Y R0 0
  ADDSP FF
  LW_SP R1 0
  RET

printf:       ;��R0ָ���ĵ�ַ��ʼ��cursor����ַ���ֱ��\0Ϊֹ
  MOVE R5 R0   ;R5ά���ַ���ַ
  LW R5 R4 0 ;R4�����¼����������ַ���ʲô
  printf_loop1:
    LOAD_DATA CURSOR_X R0 0
    LOAD_DATA CURSOR_Y R1 0
    SLL R0 R0 0
    ADDU R0 R1 R0
    MOVE R1 R4
    CALL VGA_Draw_Block
    CALL next_cursor
    ADDIU R5 1
    LW R5 R4 0
    BNEZ R4 printf_loop1
    NOP
  RET
  
print_char:       ;��cursor���R0��������cursor
  SAVE_REG
  MOVE R1 R0
  LOAD_DATA CURSOR_X R2 0
  LOAD_DATA CURSOR_Y R3 0
  SLL R2 R2 0
  ADDU R2 R3 R0
  CALL VGA_Draw_Block
  CALL next_cursor
  LOAD_REG
  RET

next_cursor:    ;�������һ��Խ��󵽴���һ������
  SAVE_REG
  LOAD_DATA CURSOR_X R0 0
  LOAD_DATA CURSOR_Y R1 0
  ADDIU R1 1
  LI R6 VGA_M
  CMP R1 R6
  BTNEZ next_cursor_ret
  NOP
    CALL next_cursor_line
    LOAD_REG
    RET
  next_cursor_ret:
    SAVE_DATA CURSOR_X R0 0
    SAVE_DATA CURSOR_Y R1 0
    LOAD_REG
    RET

next_cursor_line:    ;�������һ�У�Խ��󵽴���һ�����ף���������Ļ�����
  SW_SP R0 0
  SW_SP R1 1
  ADDSP 2
  LOAD_DATA CURSOR_X R0 0
  LOAD_DATA CURSOR_Y R1 0
  LI R1 0
  ADDIU R0 1
  LI R6 VGA_N
  CMP R1 R6
  BTNEZ next_cursor_line_ret
  NOP
  ADDIU R0 FF
  ;����һ��δ��ɵ�ʵ�֣���Ӧˢ����Ļ���¹�һ��
  next_cursor_line_ret:
  SAVE_DATA CURSOR_X R0 0
  SAVE_DATA CURSOR_Y R1 0
  ADDSP FE
  LW_SP R0 0
  LW_SP R1 1
  RET

;����������������������������������������������������������������������������������������������������������������������������VGAģ�顪������������������������������������������������������������������������������������������������������������������
;VGA��ʾ�������������Դ� 
DEFINE VGA_N 1E  ;30��
DEFINE VGA_M 50  ;80��
DATA VGA_MEM 2400

VGA_COM_PRINT:   ;��VGA_MEMͨ�����ڴ�ӡ���նˣ����ڲ���
  SAVE_REG
  LI R0 BF ;R0��¼���ڵ�ַ
  SLL R0 R0 0
  LOAD_ADDR VGA_MEM R5 ;R5ɨ��VGA_MEM��ַ
  LI R3 VGA_N ;R3����ѭ������
  VGA_COM_PRINT_L1:
    LI R4 VGA_M  ;R4����ѭ������
    VGA_COM_PRINT_L2:
      LW R5 R1 0
      BNEZ R1 2   ;����ַ���0�Ļ����'.'
      NOP
      LI R1 2E
      CALL COM_WRITE
      ADDIU R4 FF
      BNEZ R4 VGA_COM_PRINT_L2
      ADDIU R5 1
    LI R1 0A     ;���з�
    CALL COM_WRITE
    ADDIU R3 FF
    BNEZ R3 VGA_COM_PRINT_L1
    NOP
  LI R1 0A     ;���з�
  CALL COM_WRITE
  LOAD_REG
  RET
  
VGA_MEM_INIT:
  SAVE_REG
  LOAD_ADDR VGA_MEM R5 ;R5ɨ��VGA_MEM��ַ
  LI R2 0
  LI R3 VGA_N ;R3����ѭ������
  VGA_MEM_INIT_L1:
    LI R4 VGA_M  ;R4����ѭ������
    VGA_MEM_INIT_L2:
      SW R5 R2 0
      ADDIU R4 FF
      BNEZ R4 VGA_MEM_INIT_L2
      ADDIU R5 1
    ADDIU R3 FF
    BNEZ R3 VGA_MEM_INIT_L1
    NOP
  LOAD_REG
  RET

VGA_Multi80:    ;���ٵ�*80�����ټ���
  SLL R6 R0 6
  SLL R0 R0 4
  ADDU R0 R6 R0
  RET
  
VGA_Draw_Block:   ;��ͼһ�����ӣ�R0��16λ��ʾ���꣬R1��ʾ��ɫ�Ȳ���(Լ��ǰ7λ�������ͣ���RGB����λ)
  SAVE_REG
  MOVE R2 R0  ;R2=R0
  MOVE R3 R1  ;R3=R1
  ;�����������VGA��ʾ��ַ
  LI R6 BF
  SLL R6 R6 0
  ADDIU R6 4
  SW R6 R0 0
  ADDIU R6 1
  SW R6 R1 0
  ;��������������Դ�
  SRL R0 R0 0 ;R0=R0>>8
  LI R1 VGA_M
  CALL MULTI
  SLL R1 R2 0
  SRL R1 R1 0
  ADDU R0 R1 R0
  LOAD_ADDR VGA_MEM R1
  ADDU R0 R1 R0
  SW R0 R3 0   ;д��VGA�Դ�
  LOAD_REG
  RET
  
;����������������������������������������������������������������������������������������������������������������������������������������ͨ��ģ�顪��������������������������������������������������������������������������������������������������������������������������������
;���ڽӿں�����

WAIT_COM_W:  ;ѭ��ֱ������R0��д
  SW_SP R1 0
  LI R1 1
  LW R0 R6 0
  AND R6 R1
  BEQZ R6 WAIT_COM_W
  LW_SP R1 0
  RET

TEST_COM_R: ;���ش���R0�Ƿ�ɶ�
  LW R0 R0 0
  LI R6 2
  AND R0 R6
  SRL R0 R0 1
  RET

COM_WRITE:   ;�򴮿�R0д���ֽ�R1
  SW_SP R0 0
  ADDSP 1
  ADDIU R0 1
  CALL WAIT_COM_W
  ADDSP FF
  LW_SP R0 0
  SW R0 R1 0
  RET
  

COM_READ:  ;�Ӵ���R0�����ݣ������ݷ���0�����򷵻�����
  SW_SP R0 0
  ADDSP 1
  ADDIU R0 1
  CALL TEST_COM_R
  ADDSP FF
  BEQZ R0 COM_READ_RET
  NOP
  LW_SP R0 0
  LW R0 R0 0
  COM_READ_RET:
  RET
  
;---------------------------------------------------------------------------ͨ�ú�����---------------------------------------------------------------------------;
;ͨ�ú�����

MULTI:  ;��˹�㷨�����з���16λ�����˷�R0*R1,��LOW������R0��HIGH������R1
;R1(16bit)&R0(16bit)
;R0������16λ
;R1������16λ
;R2ΪR1���λ
;R3ΪR0���λ
;R4��Ϊ��˹�㷨�ĸ���λ
;R5��Ϊѭ������
;R6����R1����
  SW_SP R2 0
  SW_SP R3 1
  SW_SP R4 2
  SW_SP R5 3
  ADDSP 4
  MOVE R6 R1
  LI R1 0
  LI R5 0F
  LI R4 0 
  MULTI_LOOP:
    LI R3 1
    AND R3 R0
    SLT R3 R4
    BTNEZ MULTI_PLUS_X
    SLT R4 R3
    BTNEZ MULTI_SUB_X
    NOP
    B MULTI_SHIFT
    NOP
    MULTI_PLUS_X: ;10 ���ֻ�+X
      ADDU R1 R6 R1
      B MULTI_SHIFT
      NOP
    MULTI_SUB_X: ;10 ���ֻ�-X
      SUBU R1 R6 R1
    MULTI_SHIFT: ;��λ
      MOVE R4 R3
      LI R2 1
      AND R2 R1
      SRL R0 R0 1
      SRA R1 R1 1
      SLL R2 R2 0
      SLL R2 R2 7
      ADDU R0 R2 R0
    BNEZ R5 MULTI_LOOP
    ADDIU R5 FF
  ADDSP FC
  LW_SP R2 0
  LW_SP R3 1
  LW_SP R4 2
  LW_SP R5 3
  RET
  
DIVISION:  ;�Ӽ�����ԭ��һλ������R0/R1���̱�����R0����������R1
  SW_SP R2 0
  SW_SP R3 1
  SW_SP R4 2
  ADDSP 3
  LI R2 0 ;R2��������ж���λ
  MOVE R3 R1
  SRL R3 R3 1
  ADDIU R2 1
  BNEZ R3 FD
  NOP
  SUBU R3 R2 R2  ;R2=16-R2
  ADDIU R2 10
  MOVE R3 R1     ;R3������λ�� ����
  SLLV R2 R3
  LI R4 1
  SLLV R2 R4      ;R4Ϊ1λ
  MOVE R1 R0
  LI R0 0
  DIVISION_LOOP:
    SLTU R3 R1
    BTEQZ 3
    NOP
    ADDU R0 R4 R0
    SUBU R1 R3 R1
    SRL R4 R4 1
    SRL R3 R3 1
    BNEZ R2 DIVISION_LOOP
    ADDIU R2 FF
  ADDSP FD
  LW_SP R2 0
  LW_SP R3 1
  LW_SP R4 2
  RET

POWER:   ;����R0^R1,����R0(16λ)
  SAVE_REG
  MOVE R3 R1
  MOVE R2 R0
  LI R0 1
  BEQZ R1 POWER_LOOP_RET
  NOP
  POWER_LOOP:
    MOVE R1 R2
    CALL MULTI
    ADDIU R3 FF
    BNEZ R3 POWER_LOOP
    NOP
  POWER_LOOP_RET:
  SW_SP R0 F8
  LOAD_REG
  RET

FastRAND:  ;���ٵ�α���������������15λ����������Ĵ���R0
; x(n+1)=(3*x(n)+59)%65536
  DATA RANDOM_SEED 1
  LOAD_DATA RANDOM_SEED R0 0
  ADDU R0 R0 R6
  ADDU R0 R6 R0
  LI R6 3B
  ADDU R0 R6 R0
  SAVE_DATA RANDOM_SEED R0 0
  RET

RAND:  ;α���������������15λ����������Ĵ���R0
; x(n+1)=(123*x(n)+59)%65536
  DATA RANDOM_SEED 1
  SW_SP R1 0
  ADDSP 1
  LOAD_DATA RANDOM_SEED R0 0
  LI R1 7B
  CALL MULTI
  LI R1 3B
  ADDU R0 R1 R0
  SAVE_DATA RANDOM_SEED R0 0
  ADDSP FF
  LW_SP R1 0
  RET
  
;--------------------------------------------���̿��Ƴ���--------------------------------------------
KeyBoard_Get:   ;�Ӽ��̶�ȡ��ǰ���ݵ�R0
  DATA KeyBoard_Last 1
  LI R0 BF
  SLL R0 R0 0
  ADDIU R0 6
  LW R0 R0 0
  SW_SP R1 0
  ADDSP 1
  LOAD_DATA KeyBoard_Last R1 0
  SAVE_DATA KeyBoard_Last R0 0
  CMP R0 R1
  BTNEZ 2 
  NOP
  LI R0 0
  ADDSP FF
  LW_SP R1 0
  RET