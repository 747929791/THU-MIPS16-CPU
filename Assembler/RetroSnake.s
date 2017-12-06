; 这是一个单人贪吃蛇游戏
GOTO RetroSnake_Main

DEFINE SNAKE_EmptyPic_Left 16
DEFINE SNAKE_EmptyPic_Right 17
DEFINE SNAKE_ApplePic_Left 18
DEFINE SNAKE_ApplePic_Right 19
DEFINE SNAKE_BodyPic_Left 1A
DEFINE SNAKE_BodyPic_Right 1B

DEFINE SNAKE_MAP_N 1E  ;30行
DEFINE SNAKE_MAP_M 28  ;40列
DATA SNAKE_BODY_QUEUE_FRONT 1 ;表头地址（指向下一位）
DATA SNAKE_BODY_QUEUE_END 1 ;链表尾地址
DATA SNAKE_BODY_QUEUE 1200  ;蛇身体的链表
DATA SNAKE_BODY_QUEUE_END_ADDR 1  ;蛇身体列表尾地址(存储数据为0，下标为链表末尾)
DATA SNAKE_BODY_QUEUE_SIZE 1  ;蛇身体列表大小

DATA SNAKE_FourConnected_Offset 4  ;16位四连通方向，16位表示坐标可以直接加法做偏移(其中(0,-1)加0会产生行混淆) (1,0)(0,1)(-1,0)(0,-1)
DATA SNAKE_Direction 1   ;当前蛇的方向(0~3)
DATA SNAKE_APPLE_POS 1   ;苹果所在的坐标

RetroSnake_Main:
  CALL VGA_MEM_INIT
  CALL RetroSnake_INIT
  CALL VGA_COM_PRINT
  LI R5 1  ;R5记录是否Auto进行
  RetroSnake_Main_Loop:
    CALL KeyBoard_Get
    CALL Delay_200W
    BNEZ R5 2
    NOP
    BEQZ R0 RetroSnake_Main_Loop
    NOP
    MOVE R1 R0
    ADDIU R1 8F
    BEQZ R1 RetroSnake_Main_RET ;如果按下Q则游戏结束
    NOP
    MOVE R1 R0
    ADDIU R1 8E
    BEQZ R1 RetroSnake_Main ;如果按下R则重新开始
    NOP
    MOVE R1 R0
    ADDIU R1 9F
    BEQZ R1 RetroSnake_Main_Left ;如果按下A则更改蛇方向为Left
    NOP
    MOVE R1 R0
    ADDIU R1 8D
    BEQZ R1 RetroSnake_Main_Down ;如果按下S则更改蛇方向为Left
    NOP
    MOVE R1 R0
    ADDIU R1 9C
    BEQZ R1 RetroSnake_Main_Right ;如果按下D则更改蛇方向为Right
    NOP
    MOVE R1 R0
    ADDIU R1 89
    BEQZ R1 RetroSnake_Main_Up ;如果按下W则更改蛇方向为Up
    NOP
    MOVE R1 R0
    ADDIU R1 9B
    BEQZ R1 RetroSnake_Main_ChangeAuto ;如果按下E则更改自动性
    NOP
    ;一轮结算
    RetroSnake_Main_OneStepLogic:  ;回合末一步结算
    CALL RetroSnake_OneStep
    CALL VGA_COM_PRINT
    B RetroSnake_Main_Loop
    NOP
    RetroSnake_Main_Left:
      LI R4 3
      SAVE_DATA SNAKE_Direction R4 0
      GOTO RetroSnake_Main_OneStepLogic
    RetroSnake_Main_DOWN:
      LI R4 0
      SAVE_DATA SNAKE_Direction R4 0
      GOTO RetroSnake_Main_OneStepLogic
    RetroSnake_Main_RIGHT:
      LI R4 1
      SAVE_DATA SNAKE_Direction R4 0
      GOTO RetroSnake_Main_OneStepLogic
    RetroSnake_Main_UP:
      LI R4 2
      SAVE_DATA SNAKE_Direction R4 0
      GOTO RetroSnake_Main_OneStepLogic
    RetroSnake_Main_ChangeAuto:
      LI R6 1
      XOR R5 R6
      GOTO RetroSnake_Main_Loop
  RetroSnake_Main_RET:
  LI R0 F0 ;标记程序运行结束
  RET

RetroSnake_TEST:

;LI R0 0   ;走几步看看
;SAVE_DATA SNAKE_Direction R0 0
;CALL RetroSnake_OneStep
;CALL VGA_COM_PRINT
;RET
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
  ;绘制原始地图背景
  LI R1 0
  LI R4 SNAKE_MAP_N
  ADDIU R4 FF
  RetroSnake_INIT_L1:
    LI R5 SNAKE_MAP_M
    ADDIU R5 FF
    RetroSnake_INIT_L2:
      SLL R0 R4 0
      ADDU R0 R5 R0
      CALL RetroSnake_Print
    BNEZ R5 RetroSnake_INIT_L2
    ADDIU R5 FF
  BNEZ R4 RetroSnake_INIT_L1
  ADDIU R4 FF
  CALL RetroSnake_Print
  ;初始化数据
  LOAD_ADDR SNAKE_BODY_QUEUE R0
  SAVE_DATA SNAKE_BODY_QUEUE_END R0 0
  SAVE_DATA SNAKE_BODY_QUEUE_FRONT R0 0  ;初始化蛇身体数组
  CALL RetroSnake_Random_Point
  CALL RetroSnake_Push_Queue  ;产生第一个身体
  LI R0 SNAKE_MAP_N
  LI R1 SNAKE_MAP_M
  CALL MULTI
  SAVE_DATA SNAKE_BODY_QUEUE_SIZE R0 0
  CALL RetroSnake_GenerateApple ;产生第一个苹果
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
  CALL RetroSnake_Push_Queue    ;如果没输则新增一格压入队列
  LOAD_DATA SNAKE_APPLE_POS R3 0   ;R3<=苹果坐标  吃苹果逻辑判定
    CMP R2 R3
    BTNEZ RetroSnake_OneStep_EatApple_False
    NOP
        CALL RetroSnake_GenerateApple
        B RetroSnake_OneStep_EatApple_End
        NOP
      RetroSnake_OneStep_EatApple_False:
        CALL RetroSnake_Pop_Queue
    RetroSnake_OneStep_EatApple_End:
  LOAD_REG
  RET
  RetroSnake_OneStep_Loss:    ;一步失败，输掉后的逻辑
    LOAD_REG
    LI R0 FF
    RET

RetroSnake_GenerateApple:      ;产生一个新的苹果(会丢失原有苹果的引用)
  SAVE_REG
  CALL RetroSnake_Random_Point
  SAVE_DATA SNAKE_APPLE_POS R0 0
  LI R1 2   ;画苹果
  CALL RetroSnake_Print
  LOAD_REG
  RET

RetroSnake_Push_Queue:  ;向队列内压入一个格子R0(16位表示),处理显示和数据维护
  SW_SP R1 0
  SW_SP R2 1
  ADDSP 2
  LOAD_DATA SNAKE_BODY_QUEUE_FRONT R2 0
  SW R2 R0 0
  LI R1 1    ;画身体
  CALL RetroSnake_Print
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
  LI R1 0    ;画草地
  CALL RetroSnake_Print
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
    
RetroSnake_Print:    ;向R0坐标画R1(0:空地,1:蛇身,2:苹果)
  SAVE_REG
  SLL R5 R0 0
  SRL R5 R5 0
  ADDU R0 R5 R0      ;R0的y坐标*2
  BEQZ R1 RetroSnake_PrintEmpty
  ADDIU R1 FF
  BEQZ R1 RetroSnake_PrintBody
  ADDIU R1 FF
  BEQZ R1 RetroSnake_PrintApple
  NOP
  RetroSnake_PrintEmpty:
    LI R1 SNAKE_EmptyPic_Left
    CALL VGA_Draw_Block
    ADDIU R0 1
    LI R1 SNAKE_EmptyPic_Right
    CALL VGA_Draw_Block
    B RetroSnake_Print_RET
    NOP
  RetroSnake_PrintBody:
    LI R1 SNAKE_BodyPic_Left
    CALL VGA_Draw_Block
    ADDIU R0 1
    LI R1 SNAKE_BodyPic_Right
    CALL VGA_Draw_Block
    B RetroSnake_Print_RET
    NOP
  RetroSnake_PrintApple:
    LI R1 SNAKE_ApplePic_Left
    CALL VGA_Draw_Block
    ADDIU R0 1
    LI R1 SNAKE_ApplePic_Right
    CALL VGA_Draw_Block
    B RetroSnake_Print_RET
    NOP
  RetroSnake_Print_RET:
  LOAD_REG
  RET