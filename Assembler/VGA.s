;VGA显示控制器，内置显存 
DEFINE VGA_N 1E  ;30行
DEFINE VGA_M 50  ;80列
DATA VGA_MEM 2400

VGA_COM_PRINT:   ;将VGA_MEM通过串口打印到终端，用于测试
  SAVE_REG
  LI R0 BF ;R0记录串口地址
  SLL R0 R0 0
  LOAD_ADDR VGA_MEM R5 ;R5扫描VGA_MEM地址
  LI R3 VGA_N ;R3是行循环变量
  VGA_COM_PRINT_L1:
    LI R4 VGA_M  ;R4是列循环变量
    VGA_COM_PRINT_L2:
      LW R5 R1 0
      BNEZ R1 2   ;如果字符是0的话输出'.'
      NOP
      LI R1 2E
      CALL COM_WRITE
      ADDIU R4 FF
      BNEZ R4 VGA_COM_PRINT_L2
      ADDIU R5 1
    LI R1 0A     ;换行符
    CALL COM_WRITE
    ADDIU R3 FF
    BNEZ R3 VGA_COM_PRINT_L1
    NOP
  LI R1 0A     ;换行符
  CALL COM_WRITE
  LOAD_REG
  RET