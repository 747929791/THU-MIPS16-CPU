; 这是一个单人贪吃蛇游戏
GOTO RetroSnake_Main

DEFINE SNAKE_MAP_N 1E  ;30行
DEFINE SNAKE_MAP_M 50  ;80列
DATA SNAKE_BODY_QUEUE_FRONT 1 ;表头地址（指向下一位）
DATA SNAKE_BODY_QUEUE_END 1 ;链表尾地址
DATA SNAKE_BODY_QUEUE 2400  ;蛇身体的链表
DATA SNAKE_BODY_QUEUE_END_ADDR 1  ;蛇身体列表尾地址(存储数据为0，下标为链表末尾)
DATA SNAKE_BODY_QUEUE_SIZE 1  ;蛇身体列表大小

DATA SNAKE_FourConnected_Offset 4  ;16位四连通方向，16位表示坐标可以直接加法做偏移(其中(0,-1)加0会产生行混淆) (1,0)(0,1)(-1,0)(0,-1)
DATA SNAKE_Direction 1   ;当前蛇的方向(0~3)

RetroSnake_Main:
  CALL VGA_MEM_INIT
  CALL RetroSnake_INIT
  CALL VGA_COM_PRINT
  
  LI R0 0   ;走几步看看
  SAVE_DATA SNAKE_Direction R0 0
  CALL RetroSnake_OneStep
  CALL RetroSnake_OneStep
  CALL RetroSnake_OneStep
  LI R0 1   ;走几步看看
  SAVE_DATA SNAKE_Direction R0 0
  CALL RetroSnake_OneStep
  CALL RetroSnake_OneStep
  LI R0 2   ;走几步看看
  SAVE_DATA SNAKE_Direction R0 0
  CALL RetroSnake_OneStep
  CALL RetroSnake_OneStep
  LI R0 3   ;走几步看看
  SAVE_DATA SNAKE_Direction R0 0
  CALL RetroSnake_OneStep
  CALL RetroSnake_OneStep
  CALL RetroSnake_OneStep
  CALL RetroSnake_OneStep
  CALL RetroSnake_OneStep
  
  CALL VGA_COM_PRINT
  RET


RetroSnake_INIT:
  SAVE_REG
  LOAD_ADDR SNAKE_BODY_QUEUE R0
  SAVE_DATA SNAKE_BODY_QUEUE_END R0 0
  SAVE_DATA SNAKE_BODY_QUEUE_FRONT R0 0  ;初始化蛇身体数组
  CALL RetroSnake_Random_Point
  CALL RetroSnake_Push_Queue  ;产生第一个身体
  LI R0 SNAKE_MAP_N
  LI R1 SNAKE_MAP_M
  CALL MULTI
  SAVE_DATA SNAKE_BODY_QUEUE_SIZE R0 0
  ;计算逻辑参数
  LI R0 0
  SAVE_DATA SNAKE_Direction R0 0
    ;计算四连通方向
    LI R0 1
    SAVE_DATA SNAKE_FourConnected_Offset R0 1    ;0001
    SLL R0 R0 0
    SAVE_DATA SNAKE_FourConnected_Offset R0 0  ;0100
    LI R0 FF
    SLL R0 R0 0
    SAVE_DATA SNAKE_FourConnected_Offset R0 2  ;FF00
    LI R1 FF
    ADDU R0 R1 R0
    SAVE_DATA SNAKE_FourConnected_Offset R0 3  ;FFFF
    
  LOAD_REG
  RET

RetroSnake_OneStep:     ;驱动蛇前进一步，进行一步逻辑结算
  SAVE_REG
  LOAD_DATA SNAKE_BODY_QUEUE_FRONT R0 0
  CALL RetroSnake_Minus_One
  LW R0 R0 0    ;R0为头部坐标
  LOAD_DATA SNAKE_Direction R1 0   ;R1<=当前方向
  LOAD_ADDR SNAKE_FourConnected_Offset R2;R2<=四连通地址
  ADDU R1 R2 R2
  LW R2 R2 0  ;R2<=偏移16位数
  ADDU R0 R2 R2 ;R2<=下一步坐标
  SLL R1 R2 0
  SRL R1 R1 0
  SRL R0 R2 0
  CALL RetroSnake_Check_Point
  BEQZ R0 RetroSnake_OneStep_Loss  ;如果非法则输
  NOP
  MOVE R0 R2
  CALL RetroSnake_Push_Queue    ;如果没输则压入队列
  LOAD_REG
  RET
  RetroSnake_OneStep_Loss:    ;一步失败，输掉后的逻辑
    LOAD_REG
    LI R0 FF
    RET

RetroSnake_Push_Queue:  ;向队列内压入一个格子R0(16位表示),处理显示和数据维护
  SW_SP R1 0
  SW_SP R2 1
  ADDSP 2
  LOAD_DATA SNAKE_BODY_QUEUE_FRONT R2 0
  SW R2 R0 0
  LI R1 23    ;写什么？控制台写#
  CALL VGA_Draw_Block
  MOVE R0 R2
  CALL RetroSnake_Plus_One
  SAVE_DATA SNAKE_BODY_QUEUE_FRONT R0 0
  ADDSP FE
  LW_SP R1 0
  LW_SP R2 1
  RET


RetroSnake_Pop_Queue:  ;队列弹出一个格子,处理显示和数据维护
  SW_SP R0 0
  SW_SP R1 1
  ADDSP 2
  LOAD_DATA SNAKE_BODY_QUEUE_END R2 0
  LW R2 R0 0
  LI R1 0    ;写什么？控制台写空(0)
  CALL VGA_Draw_Block
  MOVE R0 R2
  CALL RetroSnake_Plus_One
  SAVE_DATA SNAKE_BODY_QUEUE_END R0 0
  ADDSP FE
  LW_SP R0 0
  LW_SP R1 1
  RET


RetroSnake_Random_Point:  ;获取一个未被占用的随机点,R0高八位为x，第八位为y
  SW_SP R1 1
  SW_SP R2 2
  SW_SP R3 3
  SW_SP R4 4
  SW_SP R5 5
  SW_SP R6 6
  ADDSP 8
  RetroSnake_Random_Point_1:
    CALL RAND
    MOVE R1 R0
    SLL R0 R0 0
    SRL R0 R0 0
    SRL R1 R1 0 ;R0,R1为两个8位随机数
    MOVE R3 R1
    MOVE R2 R0
    LI R1 SNAKE_MAP_N
    MOVE R0 R2
    CALL DIVISION
    MOVE R2 R1   ;计算R2=R0%行号
    LI R1 SNAKE_MAP_M
    MOVE R0 R3
    CALL DIVISION
    MOVE R3 R1   ;计算R3=R1%列号
    MOVE R0 R2
    MOVE R1 R3
    CALL RetroSnake_Check_Point       ;检测该点是否合法
    BEQZ R0 RetroSnake_Random_Point_1
    NOP
  SLL R0 R2 0
  ADDU R0 R1 R0
  ADDSP F8
  LW_SP R1 1
  LW_SP R2 2
  LW_SP R3 3
  LW_SP R4 4
  LW_SP R5 5
  LW_SP R6 6
  RET


RetroSnake_Check_Point:   ;检测(R0,R1)是否合法
  SAVE_REG
  LI R2 0    ;越界判定
  SLT R0 R2
  BTNEZ RetroSnake_Check_Point_FalseReturn
  SLT R1 R2
  BTNEZ RetroSnake_Check_Point_FalseReturn
  LI R2 SNAKE_MAP_N
  SLT R0 R2
  BTEQZ RetroSnake_Check_Point_FalseReturn
  LI R2 SNAKE_MAP_M
  SLT R1 R2
  BTEQZ RetroSnake_Check_Point_FalseReturn
  NOP        ;越界判定结束
  SLL R4 R0 0
  ADDU R1 R4 R4  ;R4现在是16位坐标
  ;检测是否和蛇身体相交
  LOAD_DATA SNAKE_BODY_QUEUE_END R0 0
  LOAD_DATA SNAKE_BODY_QUEUE_FRONT R1 0
  RetroSnake_Check_Point_L1:
    LW R0 R2 0
    CMP R2 R4
    BTEQZ RetroSnake_Check_Point_FalseReturn
    NOP
    CALL RetroSnake_Plus_One
    CMP R0 R1
    BTNEZ RetroSnake_Check_Point_L1
    NOP
  RetroSnake_Check_Point_TrueReturn:
    LOAD_REG
    LI R0 1
    RET
  RetroSnake_Check_Point_FalseReturn:
    LOAD_REG
    LI R0 0
    RET


RetroSnake_Plus_One:   ;R0++,如果大于等于SNAKE_BODY_QUEUE_SIZE则归零
  SW_SP R1 0
  ADDSP 1
  ADDIU R0 1
  LOAD_ADDR SNAKE_BODY_QUEUE_END_ADDR R1
  CMP R0 R1
  BTNEZ RetroSnake_Plus_One_RET
  NOP
  LOAD_ADDR SNAKE_BODY_QUEUE R0
  RetroSnake_Plus_One_RET:
    ADDSP FF
    LW_SP R1 0
    RET
    
    
RetroSnake_Minus_One:   ;R0--,如果小于等于SNAKE_BODY_QUEUE_SIZE则归零
  SW_SP R1 0
  ADDSP 1
  LOAD_ADDR SNAKE_BODY_QUEUE R1
  CMP R0 R1
  BTNEZ RetroSnake_Minus_One_RET
  NOP
  LOAD_ADDR SNAKE_BODY_QUEUE_END_ADDR R0
  RetroSnake_Minus_One_RET:
    ADDIU R0 FF
    ADDSP FF
    LW_SP R1 0
    RET


;---------------------------------------------------------------------------通用函数库---------------------------------------------------------------------------;
;通用函数库

MULTI:  ;布斯算法计算有符号16位整数乘法R0*R1,将LOW保存于R0，HIGH保存于R1
;R1(16bit)&R0(16bit)
;R0保留低16位
;R1保留高16位
;R2为R1最低位
;R3为R0最低位
;R4作为布斯算法的附加位
;R5作为循环变量
;R6保存R1副本
  SW_SP R2 0
  SW_SP R3 1
  SW_SP R4 2
  SW_SP R5 3
  ADDSP 4
  MOVE R6 R1
  LI R1 0
  LI R5 0F
  LI R4 0 
  MULTI_LOOP:
    LI R3 1
    AND R3 R0
    SLT R3 R4
    BTNEZ MULTI_PLUS_X
    SLT R4 R3
    BTNEZ MULTI_SUB_X
    NOP
    B MULTI_SHIFT
    NOP
    MULTI_PLUS_X: ;10 部分积+X
      ADDU R1 R6 R1
      B MULTI_SHIFT
      NOP
    MULTI_SUB_X: ;10 部分积-X
      SUBU R1 R6 R1
    MULTI_SHIFT: ;移位
      MOVE R4 R3
      LI R2 1
      AND R2 R1
      SRL R0 R0 1
      SRA R1 R1 1
      SLL R2 R2 0
      SLL R2 R2 7
      ADDU R0 R2 R0
    BNEZ R5 MULTI_LOOP
    ADDIU R5 FF
  ADDSP FC
  LW_SP R2 0
  LW_SP R3 1
  LW_SP R4 2
  LW_SP R5 3
  RET
  
DIVISION:  ;加减交替原码一位除法，R0/R1，商保存于R0，余数存于R1
  SW_SP R2 0
  SW_SP R3 1
  SW_SP R4 2
  ADDSP 3
  LI R2 0 ;R2计算除数有多少位
  MOVE R3 R1
  SRL R3 R3 1
  ADDIU R2 1
  BNEZ R3 FD
  NOP
  SUBU R3 R2 R2  ;R2=16-R2
  ADDIU R2 10
  MOVE R3 R1     ;R3保存移位的 除数
  SLLV R2 R3
  LI R4 1
  SLLV R2 R4      ;R4为1位
  MOVE R1 R0
  LI R0 0
  DIVISION_LOOP:
    SLTU R3 R1
    BTEQZ 3
    NOP
    ADDU R0 R4 R0
    SUBU R1 R3 R1
    SRL R4 R4 1
    SRL R3 R3 1
    BNEZ R2 DIVISION_LOOP
    ADDIU R2 FF
  ADDSP FD
  LW_SP R2 0
  LW_SP R3 1
  LW_SP R4 2
  RET

RAND:  ;伪随机数发生器，将15位结果返回至寄存器R0
; x(n+1)=(123*x(n)+59)%65536
  DATA RANDOM_SEED 1
  SW_SP R1 0
  ADDSP 1
  LOAD_DATA RANDOM_SEED R0 0
  LI R1 7B
  CALL MULTI
  LI R1 3B
  ADDU R0 R1 R0
  SAVE_DATA RANDOM_SEED R0 0
  ADDSP FF
  LW_SP R1 0
  RET
  
;---------------------------------------------------------------------------VGA控制模块---------------------------------------------------------------------------;

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
  
VGA_MEM_INIT:
  SAVE_REG
  LOAD_ADDR VGA_MEM R5 ;R5扫描VGA_MEM地址
  LI R2 0
  LI R3 VGA_N ;R3是行循环变量
  VGA_MEM_INIT_L1:
    LI R4 VGA_M  ;R4是列循环变量
    VGA_MEM_INIT_L2:
      SW R5 R2 0
      ADDIU R4 FF
      BNEZ R4 VGA_MEM_INIT_L2
      ADDIU R5 1
    ADDIU R3 FF
    BNEZ R3 VGA_MEM_INIT_L1
    NOP
  LOAD_REG
  RET
  
VGA_Draw_Block:   ;绘图一个格子，R0用16位表示坐标，R1表示颜色等参数(约定前7位描述类型，后RGB各三位)
  SAVE_REG
  MOVE R2 R0  ;R2=R0
  MOVE R3 R1  ;R3=R1
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
  
;---------------------------------------------------------------------------串口控制模块---------------------------------------------------------------------------;
  
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