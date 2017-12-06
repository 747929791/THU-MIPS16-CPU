;----------------------------------------------------------------屏幕输出控制------------------------------------------------------------

DATA Print_Scroll_Bottom 1 ;描述滚屏底部的行号(为VGA_N表示全屏滚动)，所有函数发现需要移至下一行时，发现到达底部则滚屏一次

set_cursor:     ;设置输入光标坐标为R0(16)位，用于系统文字输出
  DATA CURSOR_X 1
  DATA CURSOR_Y 1
  SW_SP R1 0
  ADDSP 1
  SRL R1 R0 0
  SAVE_DATA CURSOR_X R1 0
  SLL R0 R0 0
  SRL R0 R0 0
  SAVE_DATA CURSOR_Y R0 0
  ADDSP FF
  LW_SP R1 0
  RET

printf:       ;从R0指定的地址开始沿cursor输出字符，直到\0为止
  MOVE R5 R0   ;R5维持字符地址
  LW R5 R4 0 ;R4负责记录现在输出的字符是什么
  printf_loop1:
    LOAD_DATA CURSOR_X R0 0
    LOAD_DATA CURSOR_Y R1 0
    SLL R0 R0 0
    ADDU R0 R1 R0
    MOVE R1 R4
    CALL VGA_Draw_Block
    CALL next_cursor
    ADDIU R5 1
    LW R5 R4 0
    BNEZ R4 printf_loop1
    NOP
  RET
  
print_char:       ;向cursor输出R0，并右移cursor
  SAVE_REG
  MOVE R1 R0
  LOAD_DATA CURSOR_X R2 0
  LOAD_DATA CURSOR_Y R3 0
  SLL R2 R2 0
  ADDU R2 R3 R0
  CALL VGA_Draw_Block
  CALL next_cursor
  LOAD_REG
  RET

next_cursor:    ;光标右移一格，越界后到达下一行行首
  SAVE_REG
  LOAD_DATA CURSOR_X R0 0
  LOAD_DATA CURSOR_Y R1 0
  ADDIU R1 1
  LI R6 VGA_M
  CMP R1 R6
  BTNEZ next_cursor_ret
  NOP
    CALL next_cursor_line
    LOAD_REG
    RET
  next_cursor_ret:
    SAVE_DATA CURSOR_X R0 0
    SAVE_DATA CURSOR_Y R1 0
    LOAD_REG
    RET

next_cursor_line:    ;光标下移一行，越界后到达下一行行首，若超出屏幕则滚屏
  SW_SP R0 0
  SW_SP R1 1
  ADDSP 2
  LOAD_DATA CURSOR_X R0 0
  LOAD_DATA CURSOR_Y R1 0
  LI R1 0
  ADDIU R0 1
  LOAD_DATA Print_Scroll_Bottom R6 0
  CMP R0 R6
  BTNEZ next_cursor_line_ret
  NOP
  CALL VGA_Scroll
  ADDIU R0 FF
  next_cursor_line_ret:
  SAVE_DATA CURSOR_X R0 0
  SAVE_DATA CURSOR_Y R1 0
  ADDSP FE
  LW_SP R0 0
  LW_SP R1 1
  RET
