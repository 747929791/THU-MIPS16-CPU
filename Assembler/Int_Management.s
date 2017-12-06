GOTO Int_Management

DATA KeyBoard_Addr ;PS2键盘串口地址

Int_Management: ;中断处理程序
  SW_SP R0 0
  ADDSP 1
  LI R0 KeyBoard_Addr
  CALL COM_READ
  MOVE R6 R0
  ADDSP FF
  LW_SP R0 0
  INT F
  RET
  
Int_Test: ;测试中断与返回
  LI R0 80
  SLL R0 R0 0
  LI R1 FF
  SW R0 R1 0
  INT F
  NOP
  LI R2 FF
	
;——————————————————————————————————————————————————————————————————串口通信模块—————————————————————————————————————————————————————————————————
;串口接口函数集

WAIT_COM_W:  ;循环直至串口R0可写
  SW_SP R1 0
  LI R1 1
  LW R0 R6 0
  AND R6 R1
  BEQZ R6 WAIT_COM_W
  LW_SP R1 0
  RET

TEST_COM_R: ;返回串口R0是否可读
  LW R0 R0 0
  LI R6 2
  AND R0 R6
  SRL R0 R0 1
  RET

COM_WRITE:   ;向串口R0写入字节R1
  SW_SP R0 0
  ADDSP 1
  ADDIU R0 1
  CALL WAIT_COM_W
  ADDSP FF
  LW_SP R0 0
  SW R0 R1 0
  RET
  

COM_READ:  ;从串口R0读数据，无数据返回0，否则返回数据
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