;����������������������������������������������������������������������������������������������������������������������������VGAģ�顪������������������������������������������������������������������������������������������������������������������
;VGA��ʾ�������������Դ� 
DEFINE VGA_N 1E  ;30��
DEFINE VGA_M 50  ;80��
DATA VGA_MEM 2400

VGA_COM_PRINT:   ;��VGA_MEMͨ�����ڴ�ӡ���նˣ����ڲ���
RET ;�����������ʱ���������
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
  ADDIU R3 FF
  VGA_MEM_INIT_L1:
    LI R4 VGA_M  ;R4����ѭ������
    ADDIU R4 FF
    VGA_MEM_INIT_L2:
      ;SW R5 R2 0
      SLL R0 R3 0
      ADDU R0 R4 R0
      LI R1 20 ;��ӡ�ո�
      CALL VGA_Draw_Block
      ADDIU R5 1
      BNEZ R4 VGA_MEM_INIT_L2
      ADDIU R4 FF
    BNEZ R3 VGA_MEM_INIT_L1
    ADDIU R3 FF
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