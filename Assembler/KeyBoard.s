GOTO KeyBoard_Test

KeyBoard_Test:
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
  
;--------------------------------------------键盘控制程序--------------------------------------------
KeyBoard_Get:   ;从键盘读取当前内容到R0
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