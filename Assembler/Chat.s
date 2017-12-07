;����һ���������
GOTO Chat_Main

DATA KeyBoard_Cache 500 ;���浱ǰδ��ɵ����������
DATA KeyBoard_Cache_P 1 ;��¼��������һ���ַ��ĵ�ַ

DATA CHAT_INPUT_START_X 1
;��ǰ���������λ��
DATA CHAT_INPUT_X 1
DATA CHAT_INPUT_Y 1
;��ǰ�ı����´δ�ӡ��λ��
DATA CHAT_TEXT_X 1

Chat_Main:
  CALL VGA_MEM_INIT
  CALL Chat_INIT
  CALL VGA_COM_PRINT
  Chat_Main_Command_Input:
  LOAD_DATA CHAT_INPUT_X R0 0
  LI R1 0
  SAVE_DATA CURSOR_X R0 0
  SAVE_DATA CURSOR_Y R1 0
  LOAD_ADDR chat_hint R0
  CALL printf
  CALL next_cursor_line
  ;���������λ��
  LOAD_DATA CURSOR_X R0 0
  SAVE_DATA CHAT_INPUT_START_X R0 0	

  Chat_Main_KeyBoard_Get_Loop:
    CALL KeyBoard_Get
    BEQZ R0 Chat_Main_KeyBoard_Get_Loop
    NOP
    LI R6 0A
    CMP R0 R6   ;�ж��Ƿ�Ϊ�س�
    BTEQZ Chat_Main_KeyBoard_Get_Enter ;�ǻس�
    NOP
    LI R6 08
    CMP R0 R6   ;�ж��Ƿ�Ϊ�˸�
    BTEQZ Chat_Main_KeyBoard_Get_BackSpace ;�ǻس�
    NOP
    CALL print_char  ;����������ַ�
    LOAD_DATA KeyBoard_Cache_P R1 0
    SW R1 R0 0
    ADDIU R1 1
    SAVE_DATA KeyBoard_Cache_P R1 0
;LI R3 0A
;SW R5 R3 0
    B Chat_Main_KeyBoard_Get_Loop
    NOP
    Chat_Main_KeyBoard_Get_Enter:
      CALL Chat_Main_KeyBoard_Enter
      CALL VGA_COM_PRINT
;ADDIU R4 1
;SW R5 R4 0
      B Chat_Main_KeyBoard_Get_Loop
      NOP
    Chat_Main_KeyBoard_Get_BackSpace:
      CALL Chat_Main_KeyBoard_BackSpace
      CALL VGA_COM_PRINT
      B Chat_Main_KeyBoard_Get_Loop
      NOP
  RET
  
Chat_Main_KeyBoard_BackSpace:    ;�����˸�Ӧ������߼�
  SAVE_REG
  LOAD_DATA KeyBoard_Cache_P R0 0
  LOAD_ADDR KeyBoard_Cache R1
  CMP R0 R1
  BTEQZ Chat_Main_KeyBoard_BackSpace_RET;���Ѿ������������������һ����
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
  Chat_Main_KeyBoard_BackSpace_RET:
    LOAD_REG
    RET
  
Chat_Main_KeyBoard_Enter:   ;�����¼��̻س�ʱӦ��������߼�
  SAVE_REG
  ;��\0
  Load_Data KeyBoard_Cache_P R0 0
  ADDIU R0 1
  SAVE_DATA KeyBoard_Cache_P R0 0
  LI R1 0
  SW R0 R1 0
  
  ;��յ�ǰ��
  LOAD_DATA CHAT_INPUT_START_X R0 0
  SAVE_DATA CURSOR_X R0 0
  LI R1 0
  SAVE_DATA CURSOR_Y R1 0
  LOAD_DATA KeyBoard_Cache_P R1 0	;R1Ϊѭ������
  LOAD_ADDR KeyBoard_Cache R2 0		
  ADDIU R2 FF						;R2Ϊ�½�
  LI R0 20							;R0Ϊ�ո��ASCII
  Chat_Clear_Current_Line_Loop:
	CALL print_char
	ADDIU R1 FF
	CMP R1 R2
	BTNEZ Chat_Clear_Current_Line_Loop
	NOP
  
  ;�������������뵽�ı���
  LOAD_DATA CHAT_TEXT_X R0 0
  LI R1 0
  SAVE_DATA CURSOR_X R0 0
  SAVE_DATA CURSOR_Y R1 0
  LOAD_ADDR chat_you R0
  CALL printf
  CALL next_cursor_line
  LOAD_ADDR KeyBoard_Cache R0
  CALL printf
  CALL next_cursor_line
  
  ;��ջ�����
  LOAD_ADDR KeyBoard_Cache R0
  SAVE_DATA KeyBoard_Cache_P R0 0
  
  ;�������������Ϣ
  Chat_Main_KeyBoard_Enter_RET:
  LOAD_DATA CURSOR_X R0 0
  SAVE_DATA CHAT_TEXT_X R0 0
  LOAD_DATA CHAT_INPUT_START_X R0 0
  LI R1 0
  SAVE_DATA CURSOR_X R0 0
  SAVE_DATA CURSOR_Y R1 0
  SAVE_DATA CHAT_INPUT_X R0 0
  SAVE_DATA CHAT_INPUT_Y R1 0
  LOAD_REG
  RET

STRING chat_s1 "---Simple chat program---"
STRING chat_you "You: "
STRING chat_friend "Friend: "
STRING chat_hint "Enter your words here: "

Chat_INIT:     ;��ʼ������Ļ�ַ���ʾ
  SAVE_REG
  ;���ù����߶�Ϊȫ����ȥ3��
  LI R0 VGA_N
  ADDIU R0 FD
  SAVE_DATA Print_Scroll_Bottom R0 0
  SAVE_DATA CHAT_INPUT_X R0 0
  LOAD_ADDR KeyBoard_Cache R0
  SAVE_DATA KeyBoard_Cache_P R0 0
  LI R0 0
  SAVE_DATA CURSOR_X R0 0
  SAVE_DATA CURSOR_Y R0 0
  LOAD_ADDR chat_s1 R0
  CALL printf
  CALL next_cursor_line
  LOAD_DATA CURSOR_X R0 0
  SAVE_DATA CHAT_TEXT_X R0 0
  LOAD_REG
  RET