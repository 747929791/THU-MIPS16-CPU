;����һ��DOS�����й���������
GOTO Root_Main

DATA KeyBoard_Cache 500 ;���浱ǰδ��ɵ����������
DATA KeyBoard_Cache_P 1 ;��¼��������һ���ַ��ĵ�ַ

Root_Main:
  CALL VGA_MEM_INIT
  CALL Root_INIT
  CALL VGA_COM_PRINT
  Root_Main_Command_Input:
  LOAD_ADDR sys_root_path R0
  CALL printf
;LI R5 BF
;SLL R5 R5 0
;ADDIU R5 6
;LI R4 32
;SW R5 R4 0
  Root_Main_KeyBoard_Get_Loop:
    CALL KeyBoard_Get
    BEQZ R0 Root_Main_KeyBoard_Get_Loop
    NOP
    LI R6 0A
    CMP R0 R6   ;�ж��Ƿ�Ϊ�س�
    BTEQZ Root_Main_KeyBoard_Get_Enter ;�ǻس�
    NOP
    LI R6 08
    CMP R0 R6   ;�ж��Ƿ�Ϊ�˸�
    BTEQZ Root_Main_KeyBoard_Get_BackSpace ;�ǻس�
    NOP
    CALL print_char  ;����������ַ�
    LOAD_DATA KeyBoard_Cache_P R1 0
    SW R1 R0 0
    ADDIU R1 1
    SAVE_DATA KeyBoard_Cache_P R1 0
;LI R3 0A
;SW R5 R3 0
    B Root_Main_KeyBoard_Get_Loop
    NOP
    Root_Main_KeyBoard_Get_Enter:
      CALL Root_Main_KeyBoard_Enter
      CALL VGA_COM_PRINT
;ADDIU R4 1
;SW R5 R4 0
      B Root_Main_KeyBoard_Get_Loop
      NOP
    Root_Main_KeyBoard_Get_BackSpace:
      CALL Root_Main_KeyBoard_BackSpace
      CALL VGA_COM_PRINT
      B Root_Main_KeyBoard_Get_Loop
      NOP
  RET
  
Root_Main_KeyBoard_BackSpace:    ;�����˸�Ӧ������߼�
  SAVE_REG
  LOAD_DATA KeyBoard_Cache_P R0 0
  LOAD_ADDR KeyBoard_Cache R1
  CMP R0 R1
  BTEQZ Root_Main_KeyBoard_BackSpace_RET;���Ѿ������������������һ����
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
  Root_Main_KeyBoard_BackSpace_RET:
    LOAD_REG
    RET

GOTO_LS:
  STRING Applications "LifeGame RetroSnake"
  CALL next_cursor_line
  LOAD_ADDR Applications R0
  CALL printf
  GOTO Root_Main_KeyBoard_Enter_RET
GOTO_NotePad:
  ;CALL NotePad
  GOTO Root_Main
GOTO_LifeGame:
  CALL LifeGame_Main
  GOTO Root_Main
GOTO_RetroSnake:
  CALL RetroSnake_Main
  GOTO Root_Main
GOTO_Calculate:
  CALL Calculate_Main
  GOTO Root_Main
GOTO_CHAT:
  CALL Chat_Main
  GOTO Root_Main

Root_Main_KeyBoard_Enter:   ;�����¼��̻س�ʱӦ��������߼�
  SAVE_REG
  ;��ջ���������\0
  CALL next_cursor_line
  Load_Data KeyBoard_Cache_P R0 0
  LI R1 0
  SW R0 R1 0
  LOAD_ADDR KeyBoard_Cache R0
  SAVE_DATA KeyBoard_Cache_P R0 0
  ;����LifeGame�����ж�
  STRING Root_LifGame_AppName "LifeGame"
  LOAD_ADDR KeyBoard_Cache R0
  LOAD_ADDR Root_LifGame_AppName R1
  CALL STRING_CMP
  BNEZ R0 GOTO_LifeGame
  NOP
  ;����RetroSnake�����ж�
  STRING Root_RetroSnake_AppName "RetroSnake"
  LOAD_ADDR KeyBoard_Cache R0
  LOAD_ADDR Root_RetroSnake_AppName R1
  CALL STRING_CMP
  BNEZ R0 GOTO_RetroSnake
  NOP
  ;����Calculate�����ж�
  STRING Root_Calculate_AppName "Calculate"
  LOAD_ADDR KeyBoard_Cache R0
  LOAD_ADDR Root_Calculate_AppName R1
  CALL STRING_CMP
  BNEZ R0 GOTO_Calculate
  NOP
  ;����Chat�����ж�
  STRING Root_Chat_AppName "Chat"
  LOAD_ADDR KeyBoard_Cache R0
  LOAD_ADDR Root_Chat_AppName R1
  CALL STRING_CMP
  BNEZ R0 GOTO_Chat
  NOP
  ;�������l��������е�Ӧ�ó���(ls)
  MOVE R0 R1
  ADDIU R0 94   ;R0-=ord(l)
  BEQZ R0 GOTO_LS
  NOP
  ;����ǿ�ָ��""����ת������
  MOVE R0 R1
  ADDIU R0 0   ;R0-=0
  BEQZ R0 Root_Main_KeyBoard_Enter_RET
  NOP
  ;����Ϊ����ָ��
  Load_Addr KeyBoard_Cache R0
  CALL printf
  Load_Addr sys_command_not_found R0
  CALL printf
  ;�������У����"command not found.",�����һ��"A:\>"
  Root_Main_KeyBoard_Enter_RET:
  CALL next_cursor_line
  CALL next_cursor_line
  Load_Addr sys_root_path R0
  CALL printf
  LOAD_REG
  RET

STRING sys_s1 "Preparing to start your computer."
STRING sys_s2 "This may take a few minuts. Please wait..."
STRING sys_s3 " "
STRING sys_s4 "The diagnostic tools were successfully loaded to drive G."
STRING sys_s5 " "
STRING sys_s6 "MSCDEX Version 2.25."
STRING sys_s7 "Copyright (C) Tsinghua University. 2017. All rights reserved."
STRING sys_s8 "       Drive H: = Driver MSCD001 unit 0"
STRING sys_s9 " "
STRING sys_s10 "To get help, type HELP and press ENTER."
STRING sys_root_path "A:\> "
STRING sys_command_not_found " command not found."

Root_INIT:     ;��ʼ������Ļ�ַ���ʾ
  SAVE_REG
  ;���ù����߶�Ϊȫ��
  LI R0 VGA_N
  SAVE_DATA Print_Scroll_Bottom R0 0
  LOAD_ADDR KeyBoard_Cache R0
  SAVE_DATA KeyBoard_Cache_P R0 0
  LI R0 0
  SAVE_DATA CURSOR_X R0 0
  SAVE_DATA CURSOR_Y R0 0
  LOAD_ADDR sys_s1 r0
  CALL printf
  CALL next_cursor_line
  LOAD_ADDR sys_s2 r0
  CALL printf
  CALL next_cursor_line
  LOAD_ADDR sys_s3 r0
  CALL printf
  CALL next_cursor_line
  LOAD_ADDR sys_s4 r0
  CALL printf
  CALL next_cursor_line
  LOAD_ADDR sys_s5 r0
  CALL printf
  CALL next_cursor_line
  LOAD_ADDR sys_s6 r0
  CALL printf
  CALL next_cursor_line
  LOAD_ADDR sys_s7 r0
  CALL printf
  CALL next_cursor_line
  LOAD_ADDR sys_s8 r0
  CALL printf
  CALL next_cursor_line
  LOAD_ADDR sys_s9 r0
  CALL printf
  CALL next_cursor_line
  LOAD_ADDR sys_s10 r0
  CALL printf
  CALL next_cursor_line
  CALL next_cursor_line
  LOAD_REG
  RET