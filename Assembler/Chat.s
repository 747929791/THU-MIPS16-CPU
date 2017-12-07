;这是一个聊天程序
GOTO Chat_Main

DATA KeyBoard_Cache 500 ;缓存当前未完成的输入的内容
DATA KeyBoard_Cache_P 1 ;记录缓存区下一个字符的地址

DATA CHAT_INPUT_START_X 1
;当前输入框坐标位置
DATA CHAT_INPUT_X 1
DATA CHAT_INPUT_Y 1
;当前文本框下次打印行位置
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
  ;保存输入框位置
  LOAD_DATA CURSOR_X R0 0
  SAVE_DATA CHAT_INPUT_START_X R0 0	

  Chat_Main_KeyBoard_Get_Loop:
    CALL KeyBoard_Get
    BEQZ R0 Chat_Main_KeyBoard_Get_Loop
    NOP
    LI R6 0A
    CMP R0 R6   ;判断是否为回车
    BTEQZ Chat_Main_KeyBoard_Get_Enter ;是回车
    NOP
    LI R6 08
    CMP R0 R6   ;判断是否为退格
    BTEQZ Chat_Main_KeyBoard_Get_BackSpace ;是回车
    NOP
    CALL print_char  ;否则输出该字符
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
  
Chat_Main_KeyBoard_BackSpace:    ;按下退格应处理的逻辑
  SAVE_REG
  LOAD_DATA KeyBoard_Cache_P R0 0
  LOAD_ADDR KeyBoard_Cache R1
  CMP R0 R1
  BTEQZ Chat_Main_KeyBoard_BackSpace_RET;若已经到达最左侧则无视这一操作
  NOP
  CALL last_cursor ;回退一格
  LOAD_DATA CURSOR_X R6 0
  SLL R0 R6 0
  LOAD_DATA CURSOR_Y R6 0
  ADDU R0 R6 R0
  LI R1 20
  CALL VGA_Draw_Block ;清除显示
  LOAD_DATA KeyBoard_Cache_P R0 0
  ADDIU R0 FF
  SAVE_DATA KeyBoard_Cache_P R0 0
  Chat_Main_KeyBoard_BackSpace_RET:
    LOAD_REG
    RET
  
Chat_Main_KeyBoard_Enter:   ;当按下键盘回车时应当处理的逻辑
  SAVE_REG
  ;补\0
  Load_Data KeyBoard_Cache_P R0 0
  ADDIU R0 1
  SAVE_DATA KeyBoard_Cache_P R0 0
  LI R1 0
  SW R0 R1 0
  
  ;清空当前行
  LOAD_DATA CHAT_INPUT_START_X R0 0
  SAVE_DATA CURSOR_X R0 0
  LI R1 0
  SAVE_DATA CURSOR_Y R1 0
  LOAD_DATA KeyBoard_Cache_P R1 0	;R1为循环变量
  LOAD_ADDR KeyBoard_Cache R2 0		
  ADDIU R2 FF						;R2为下界
  LI R0 20							;R0为空格的ASCII
  Chat_Clear_Current_Line_Loop:
	CALL print_char
	ADDIU R1 FF
	CMP R1 R2
	BTNEZ Chat_Clear_Current_Line_Loop
	NOP
  
  ;将输入内容输入到文本框
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
  
  ;清空缓存区
  LOAD_ADDR KeyBoard_Cache R0
  SAVE_DATA KeyBoard_Cache_P R0 0
  
  ;保存各处坐标信息
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

Chat_INIT:     ;初始化的屏幕字符显示
  SAVE_REG
  ;设置滚屏高度为全屏减去3行
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