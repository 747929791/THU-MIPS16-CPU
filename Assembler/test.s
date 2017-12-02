MAIN:
  LI R0 BF ;R0记录串口地址
  SLL R0 R0 0
  LI R1 2E
  CALL COM_WRITE
  CALL COM_WRITE
  LI R1 0A
  CALL COM_WRITE
  LI R1 2E
  CALL COM_WRITE
  CALL COM_WRITE
  LI R1 0A
  CALL COM_WRITE
  CALL VGA_COM_PRINT
  LI R0 23
  SAVE_DATA VGA_MEM R0 3
  CALL VGA_COM_PRINT
  RET
  
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