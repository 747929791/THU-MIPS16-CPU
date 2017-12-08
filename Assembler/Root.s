;这是一个DOS命令行管理主程序
GOTO Root_Main

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
    LI R6 1B
    CMP R0 R6   ;判断是否为ESC
    BTEQZ Root_Main ;是ESC
    NOP
    LI R6 0A
    CMP R0 R6   ;判断是否为回车
    BTEQZ Root_Main_KeyBoard_Get_Enter ;是回车
    NOP
    LI R6 08
    CMP R0 R6   ;判断是否为退格
    BTEQZ Root_Main_KeyBoard_Get_BackSpace ;是退格
    NOP
    CALL print_char  ;否则输出该字符
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
  
Root_Main_KeyBoard_BackSpace:    ;按下退格应处理的逻辑
  SAVE_REG
  LOAD_DATA KeyBoard_Cache_P R0 0
  LOAD_ADDR KeyBoard_Cache R1
  CMP R0 R1
  BTEQZ Root_Main_KeyBoard_BackSpace_RET;若已经到达最左侧则无视这一操作
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
  Root_Main_KeyBoard_BackSpace_RET:
    LOAD_REG
    RET
    
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
GOTO_TERM:
  CALL Term_Main
  GOTO Root_Main

Root_Main_KeyBoard_Enter:   ;当按下键盘回车时应当处理的逻辑
  SAVE_REG
  LOAD_DATA KeyBoard_Cache_P R0 0
  LOAD_ADDR KeyBoard_Cache R1
  CMP R0 R1
  BTNEZ Root_Main_KeyBoard_Enter_NotEmpty
  NOP
  RET
  Root_Main_KeyBoard_Enter_NotEmpty:
  ;清空缓存区，补\0
  CALL next_cursor_line
  Load_Data KeyBoard_Cache_P R0 0
  LI R1 0
  SW R0 R1 0
  LOAD_ADDR KeyBoard_Cache R0
  SAVE_DATA KeyBoard_Cache_P R0 0
  ;进入LifeGame过程判定
  STRING Root_LifGame_AppName "LifeGame"
  LOAD_ADDR KeyBoard_Cache R0
  LOAD_ADDR Root_LifGame_AppName R1
  CALL STRING_CMP
  BEQZ R0 Dont_GOTO_LifeGame
  NOP
  GOTO GOTO_LifeGame
  Dont_GOTO_LifeGame:
  ;进入RetroSnake过程判定
  STRING Root_RetroSnake_AppName "RetroSnake"
  LOAD_ADDR KeyBoard_Cache R0
  LOAD_ADDR Root_RetroSnake_AppName R1
  CALL STRING_CMP
  BEQZ R0 Dont_GOTO_RetroSnake
  NOP
  GOTO GOTO_RetroSnake
  Dont_GOTO_RetroSnake:
  ;进入Calculate过程判定
  STRING Root_Calculate_AppName "Calculate"
  LOAD_ADDR KeyBoard_Cache R0
  LOAD_ADDR Root_Calculate_AppName R1
  CALL STRING_CMP
  BEQZ R0 Dont_GOTO_Calculate
  NOP
  GOTO GOTO_Calculate
  Dont_GOTO_Calculate:
  ;进入Chat过程判定
  STRING Root_Chat_AppName "Chat"
  LOAD_ADDR KeyBoard_Cache R0
  LOAD_ADDR Root_Chat_AppName R1
  CALL STRING_CMP
  BEQZ R0 Dont_GOTO_Chat
  NOP
  GOTO GOTO_Chat
  Dont_GOTO_Chat:
  ;进入Term过程判定
  STRING Root_Term_AppName "Term"
  LOAD_ADDR KeyBoard_Cache R0
  LOAD_ADDR Root_Term_AppName R1
  CALL STRING_CMP
  BEQZ R0 Dont_GOTO_Term
  NOP
  GOTO GOTO_Term
  Dont_GOTO_Term:
  ;进入ls过程判定
  STRING Root_ls_command "ls"
  LOAD_ADDR KeyBoard_Cache R0
  LOAD_ADDR Root_ls_command R1
  CALL STRING_CMP
  BEQZ R0 Dont_GOTO_LS
  NOP
  GOTO GOTO_LS
  Dont_GOTO_LS:
  ;进入HELP过程判定
  STRING Root_HELP_command "HELP"
  LOAD_ADDR KeyBoard_Cache R0
  LOAD_ADDR Root_HELP_command R1
  CALL STRING_CMP
  BEQZ R0 Dont_GOTO_HELP
  NOP
    ;HELP的实现
    STRING ROOT_HELP0 "Use 'ls' to see the installed applications"
    STRING ROOT_HELP1 "Use '<ProgramName> --help' to see the program's information"
    LOAD_ADDR ROOT_HELP0 R0
    CALL printf
    CALL next_cursor_line
    LOAD_ADDR ROOT_HELP1 R0
    CALL printf
    CALL next_cursor_line
    GOTO Root_Main_KeyBoard_Enter_RET
  Dont_GOTO_HELP:
  ;如果是空指令""，跳转至结束
  MOVE R0 R1
  ADDIU R0 0   ;R0-=0
  BNEZ R0 Dont_GOTO_Root_Main_KeyBoard_Enter_RET
  NOP
  GOTO Root_Main_KeyBoard_Enter_RET
  Dont_GOTO_Root_Main_KeyBoard_Enter_RET:
  ;均不为以上指令
  Load_Addr KeyBoard_Cache R0
  CALL printf
  Load_Addr sys_command_not_found R0
  CALL printf
  ;换行两行，输出"command not found.",并输出一个"A:\>"
  Root_Main_KeyBoard_Enter_RET:
  CALL next_cursor_line
  CALL next_cursor_line
  Load_Addr sys_root_path R0
  CALL printf
  LOAD_REG
  RET

GOTO_LS:
  STRING Applications "Calculate Chat LifeGame RetroSnake Term"
  CALL next_cursor_line
  LOAD_ADDR Applications R0
  CALL printf
  GOTO Root_Main_KeyBoard_Enter_RET

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

Root_INIT:     ;初始化的屏幕字符显示
  SAVE_REG
  ;设置滚屏高度为全屏
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