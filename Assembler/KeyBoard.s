LOAD_ADDR KeyBoard_Test_IntProgram R0
MTIH R0;ָ���жϴ������
GOTO KeyBoard_Test_Int

KeyBoard_Test_NoInt:  ;������ѵ�ļ��̴���
  LI R5 BF
  SLL R5 R5 0
  KeyBoard_Test_NoInt_Loop:
    CALL KeyBoard_Get
    BEQZ R0 KeyBoard_Test_NoInt_Loop
   
    MOVE R1 R0
    MOVE R0 R5
    CALL COM_WRITE
    B KeyBoard_Test_NoInt_Loop
    NOP
  RET
  
KeyBoard_Test_Int:  ;���Դ��жϵļ��̴���
  LI R5 BF
  SLL R5 R5 0
  KeyBoard_Test_Int_Loop:
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    LI R0 30
	MOVE R1 R0
	LI R0 BF
	SLL R0 R0 0
	CALL COM_WRITE
    B KeyBoard_Test_Int_Loop
    NOP
  LI R1 F0
  RET

KeyBoard_Test_IntProgram:   ;���������жϴ������
  SW_SP R6 7E  ;Լ��SP+127����Ϊ����ȫ���򣬽�ֹʹ��
  ADDSP 7F
  SAVE_REG
  CALL KeyBoard_Get
  MOVE R1 R0
  LI R0 BF
  SLL R0 R0 0
  CALL COM_WRITE
  LOAD_REG
  ADDSP 81
  LW_SP R6 7E
  LI R5 FF
  INT F
  NOP

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