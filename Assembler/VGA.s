;——————————————————————————————————————————————————————————————VGA模块——————————————————————————————————————————————————————————
;VGA显示控制器，内置显存 
DEFINE VGA_N 1E  ;30行
DEFINE VGA_M 50  ;80列
DATA VGA_MEM 2400

VGA_COM_PRINT:   ;将VGA_MEM通过串口打印到终端，用于测试
;RET ;在连接真机的时候不输出串口
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
  
VGA_MEM_INIT:
  SAVE_REG
  LOAD_ADDR VGA_MEM R5 ;R5扫描VGA_MEM地址
  LI R2 0
  LI R3 VGA_N ;R3是行循环变量
  ADDIU R3 FF
  VGA_MEM_INIT_L1:
    LI R4 VGA_M  ;R4是列循环变量
    ADDIU R4 FF
    VGA_MEM_INIT_L2:
      ;SW R5 R2 0
      SLL R0 R3 0
      ADDU R0 R4 R0
      LI R1 20 ;打印空格
      CALL VGA_Draw_Block
      ADDIU R5 1
      BNEZ R4 VGA_MEM_INIT_L2
      ADDIU R4 FF
    BNEZ R3 VGA_MEM_INIT_L1
    ADDIU R3 FF
  LOAD_REG
  RET

VGA_Multi80:    ;快速的*80，加速计算
  SLL R6 R0 6
  SLL R0 R0 4
  ADDU R0 R6 R0
  RET
  
VGA_Draw_Block:   ;绘图一个格子，R0用16位表示坐标，R1表示颜色等参数(约定前7位描述类型，后RGB各三位)
  SAVE_REG
  MOVE R2 R0  ;R2=R0
  MOVE R3 R1  ;R3=R1
  ;输出到真正的VGA显示地址
  LI R6 BF
  SLL R6 R6 0
  ADDIU R6 4
  SW R6 R0 0
  ADDIU R6 1
  SW R6 R1 0
  ;输出到本地虚拟显存
  SRL R0 R0 0 ;R0=R0>>8
  LI R1 VGA_M
  CALL MULTI
  SLL R1 R2 0
  SRL R1 R1 0
  ADDU R0 R1 R0
  LOAD_ADDR VGA_MEM R1
  ADDU R0 R1 R0
  SW R0 R3 0   ;写入VGA显存
  LOAD_REG
  RET
  
VGA_Scroll:    ;将VGA显示中的前R0行向上滚一格，空出来的一行填充空格
  SAVE_REG
  ADDIU R0 FF
  MOVE R5 R0
  LI R3 0 ;R3是行循环变量
  VGA_Scroll_L1:
    LI R4 VGA_M  ;R4是列循环变量
    ADDIU R4 FF
    VGA_Scroll_L2:
      MOVE R0 R3
      CALL VGA_Multi80
      ADDU R0 R4 R0
      LI R1 VGA_M
      ADDU R0 R1 R0
      LOAD_ADDR  VGA_MEM R1
      ADDU R0 R1 R0
      LW R0 R1 0 ;现在r1是下一行的内容
      SLL R0 R3 0
      ADDU R0 R4 R0
      CALL VGA_Draw_Block
      BNEZ R4 VGA_Scroll_L2
      ADDIU R4 FF
    ADDIU R3 1
    CMP R3 R5
    BTNEZ VGA_Scroll_L1
    NOP
  ;将最后一行填充空格
  LI R4 VGA_M  ;R4是列循环变量
  ADDIU R4 FF
  VGA_Scroll_L3:
    MOVE R0 R5
    SLL R0 R0 0
    ADDU R0 R4 R0
    LI R1 20;空格
    CALL VGA_Draw_Block
    BNEZ R4 VGA_Scroll_L3
    ADDIU R4 FF
  LOAD_REG
  RET