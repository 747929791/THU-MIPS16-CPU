GOTO Int_Management

DATA KeyBoard_Addr ;PS2���̴��ڵ�ַ

Int_Management: ;�жϴ������
  SW_SP R0 0
  ADDSP 1
  LI R0 KeyBoard_Addr
  CALL COM_READ
  MOVE R6 R0
  ADDSP FF
  LW_SP R0 0
  INT F
  RET
  
Int_Test: ;�����ж��뷵��
  LI R0 80
  SLL R0 R0 0
  LI R1 FF
  SW R0 R1 0
  INT F
  NOP
  LI R2 FF
	
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