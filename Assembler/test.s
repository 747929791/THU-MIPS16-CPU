MAIN:
  LI R0 BF ;R0��¼���ڵ�ַ
  SLL R0 R0 0
  LI R1 2E
  CALL COM_WRITE
  CALL COM_WRITE
  LI R1 0A
  CALL COM_WRITE
  LI R1 2E
  CALL COM_WRITE
  CALL COM_WRITE
  LI R1 0A
  CALL COM_WRITE
  CALL VGA_COM_PRINT
  LI R0 23
  SAVE_DATA VGA_MEM R0 3
  CALL VGA_COM_PRINT
  RET
  
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