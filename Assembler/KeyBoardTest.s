GOTO MAIN

MAIN:
  LI R5 BF
  SLL R5 R5 0
  Loop:
    CALL KeyBoard_Get
    BEQZ R0 Loop
    NOP
    MOVE R1 R0
    MOVE R0 R5
    CALL COM_WRITE
    B Loop
    NOP
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
  
  
  
  
;������������������������������������������������������������������������������������������������������������������������������������״̬��������������������������������������������������������������������������������������������������������������������������

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