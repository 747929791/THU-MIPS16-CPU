;----------------------------------------------------------------��Ļ�������------------------------------------------------------------

DATA Print_Scroll_Bottom 1 ;���������ײ����к�(ΪVGA_N��ʾȫ������)�����к���������Ҫ������һ��ʱ�����ֵ���ײ������һ��

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
  LOAD_DATA Print_Scroll_Bottom R6 0
  CMP R0 R6
  BTNEZ next_cursor_line_ret
  NOP
  CALL VGA_Scroll
  ADDIU R0 FF
  next_cursor_line_ret:
  SAVE_DATA CURSOR_X R0 0
  SAVE_DATA CURSOR_Y R1 0
  ADDSP FE
  LW_SP R0 0
  LW_SP R1 1
  RET