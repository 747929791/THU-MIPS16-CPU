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