; ����һ������̰������Ϸ
GOTO RetroSnake_Main

DEFINE SNAKE_EmptyPic_Left 16
DEFINE SNAKE_EmptyPic_Right 17
DEFINE SNAKE_ApplePic_Left 18
DEFINE SNAKE_ApplePic_Right 19
DEFINE SNAKE_BodyPic_Left 1A
DEFINE SNAKE_BodyPic_Right 1B

DEFINE SNAKE_MAP_N 1E  ;30��
DEFINE SNAKE_MAP_M 28  ;40��
DATA SNAKE_BODY_QUEUE_FRONT 1 ;��ͷ��ַ��ָ����һλ��
DATA SNAKE_BODY_QUEUE_END 1 ;����β��ַ
DATA SNAKE_BODY_QUEUE 1200  ;�����������
DATA SNAKE_BODY_QUEUE_END_ADDR 1  ;�������б�β��ַ(�洢����Ϊ0���±�Ϊ����ĩβ)
DATA SNAKE_BODY_QUEUE_SIZE 1  ;�������б��С

DATA SNAKE_FourConnected_Offset 4  ;16λ����ͨ����16λ��ʾ�������ֱ�Ӽӷ���ƫ��(����(0,-1)��0������л���) (1,0)(0,1)(-1,0)(0,-1)
DATA SNAKE_Direction 1   ;��ǰ�ߵķ���(0~3)
DATA SNAKE_APPLE_POS 1   ;ƻ�����ڵ�����

RetroSnake_Main:
  CALL VGA_MEM_INIT
  CALL RetroSnake_INIT
  CALL VGA_COM_PRINT
  LI R5 1  ;R5��¼�Ƿ�Auto����
  RetroSnake_Main_Loop:
    CALL KeyBoard_Get
    CALL Delay_200W
    BNEZ R5 2
    NOP
    BEQZ R0 RetroSnake_Main_Loop
    NOP
    MOVE R1 R0
    ADDIU R1 8F
    BEQZ R1 RetroSnake_Main_RET ;�������Q����Ϸ����
    NOP
    MOVE R1 R0
    ADDIU R1 8E
    BEQZ R1 RetroSnake_Main ;�������R�����¿�ʼ
    NOP
    MOVE R1 R0
    ADDIU R1 9F
    BEQZ R1 RetroSnake_Main_Left ;�������A������߷���ΪLeft
    NOP
    MOVE R1 R0
    ADDIU R1 8D
    BEQZ R1 RetroSnake_Main_Down ;�������S������߷���ΪLeft
    NOP
    MOVE R1 R0
    ADDIU R1 9C
    BEQZ R1 RetroSnake_Main_Right ;�������D������߷���ΪRight
    NOP
    MOVE R1 R0
    ADDIU R1 89
    BEQZ R1 RetroSnake_Main_Up ;�������W������߷���ΪUp
    NOP
    MOVE R1 R0
    ADDIU R1 9B
    BEQZ R1 RetroSnake_Main_ChangeAuto ;�������E������Զ���
    NOP
    ;һ�ֽ���
    RetroSnake_Main_OneStepLogic:  ;�غ�ĩһ������
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
  LI R0 F0 ;��ǳ������н���
  RET

RetroSnake_TEST:

;LI R0 0   ;�߼�������
;SAVE_DATA SNAKE_Direction R0 0
;CALL RetroSnake_OneStep
;CALL VGA_COM_PRINT
;RET
  CALL VGA_MEM_INIT
  CALL RetroSnake_INIT
  CALL VGA_COM_PRINT
  
  LI R0 0   ;�߼�������
  SAVE_DATA SNAKE_Direction R0 0
  CALL RetroSnake_OneStep
  CALL RetroSnake_OneStep
  CALL RetroSnake_OneStep
  LI R0 1   ;�߼�������
  SAVE_DATA SNAKE_Direction R0 0
  CALL RetroSnake_OneStep
  CALL RetroSnake_OneStep
  LI R0 2   ;�߼�������
  SAVE_DATA SNAKE_Direction R0 0
  CALL RetroSnake_OneStep
  CALL RetroSnake_OneStep
  LI R0 3   ;�߼�������
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
  ;����ԭʼ��ͼ����
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
  ;��ʼ������
  LOAD_ADDR SNAKE_BODY_QUEUE R0
  SAVE_DATA SNAKE_BODY_QUEUE_END R0 0
  SAVE_DATA SNAKE_BODY_QUEUE_FRONT R0 0  ;��ʼ������������
  CALL RetroSnake_Random_Point
  CALL RetroSnake_Push_Queue  ;������һ������
  LI R0 SNAKE_MAP_N
  LI R1 SNAKE_MAP_M
  CALL MULTI
  SAVE_DATA SNAKE_BODY_QUEUE_SIZE R0 0
  CALL RetroSnake_GenerateApple ;������һ��ƻ��
  ;�����߼�����
  LI R0 0
  SAVE_DATA SNAKE_Direction R0 0
    ;��������ͨ����
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

RetroSnake_OneStep:     ;������ǰ��һ��������һ���߼�����
  SAVE_REG
  LOAD_DATA SNAKE_BODY_QUEUE_FRONT R0 0
  CALL RetroSnake_Minus_One
  LW R0 R0 0    ;R0Ϊͷ������
  LOAD_DATA SNAKE_Direction R1 0   ;R1<=��ǰ����
  LOAD_ADDR SNAKE_FourConnected_Offset R2;R2<=����ͨ��ַ
  ADDU R1 R2 R2
  LW R2 R2 0  ;R2<=ƫ��16λ��
  ADDU R0 R2 R2 ;R2<=��һ������
  SLL R1 R2 0
  SRL R1 R1 0
  SRL R0 R2 0
  CALL RetroSnake_Check_Point
  BEQZ R0 RetroSnake_OneStep_Loss  ;����Ƿ�����
  NOP
  MOVE R0 R2
  CALL RetroSnake_Push_Queue    ;���û��������һ��ѹ�����
  LOAD_DATA SNAKE_APPLE_POS R3 0   ;R3<=ƻ������  ��ƻ���߼��ж�
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
  RetroSnake_OneStep_Loss:    ;һ��ʧ�ܣ��������߼�
    LOAD_REG
    LI R0 FF
    RET

RetroSnake_GenerateApple:      ;����һ���µ�ƻ��(�ᶪʧԭ��ƻ��������)
  SAVE_REG
  CALL RetroSnake_Random_Point
  SAVE_DATA SNAKE_APPLE_POS R0 0
  LI R1 2   ;��ƻ��
  CALL RetroSnake_Print
  LOAD_REG
  RET

RetroSnake_Push_Queue:  ;�������ѹ��һ������R0(16λ��ʾ),������ʾ������ά��
  SW_SP R1 0
  SW_SP R2 1
  ADDSP 2
  LOAD_DATA SNAKE_BODY_QUEUE_FRONT R2 0
  SW R2 R0 0
  LI R1 1    ;������
  CALL RetroSnake_Print
  MOVE R0 R2
  CALL RetroSnake_Plus_One
  SAVE_DATA SNAKE_BODY_QUEUE_FRONT R0 0
  ADDSP FE
  LW_SP R1 0
  LW_SP R2 1
  RET


RetroSnake_Pop_Queue:  ;���е���һ������,������ʾ������ά��
  SW_SP R0 0
  SW_SP R1 1
  ADDSP 2
  LOAD_DATA SNAKE_BODY_QUEUE_END R2 0
  LW R2 R0 0
  LI R1 0    ;���ݵ�
  CALL RetroSnake_Print
  MOVE R0 R2
  CALL RetroSnake_Plus_One
  SAVE_DATA SNAKE_BODY_QUEUE_END R0 0
  ADDSP FE
  LW_SP R0 0
  LW_SP R1 1
  RET


RetroSnake_Random_Point:  ;��ȡһ��δ��ռ�õ������,R0�߰�λΪx���ڰ�λΪy
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
    SRL R1 R1 0 ;R0,R1Ϊ����8λ�����
    MOVE R3 R1
    MOVE R2 R0
    LI R1 SNAKE_MAP_N
    MOVE R0 R2
    CALL DIVISION
    MOVE R2 R1   ;����R2=R0%�к�
    LI R1 SNAKE_MAP_M
    MOVE R0 R3
    CALL DIVISION
    MOVE R3 R1   ;����R3=R1%�к�
    MOVE R0 R2
    MOVE R1 R3
    CALL RetroSnake_Check_Point       ;���õ��Ƿ�Ϸ�
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


RetroSnake_Check_Point:   ;���(R0,R1)�Ƿ�Ϸ�
  SAVE_REG
  LI R2 0    ;Խ���ж�
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
  NOP        ;Խ���ж�����
  SLL R4 R0 0
  ADDU R1 R4 R4  ;R4������16λ����
  ;����Ƿ���������ཻ
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


RetroSnake_Plus_One:   ;R0++,������ڵ���SNAKE_BODY_QUEUE_SIZE�����
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
    
    
RetroSnake_Minus_One:   ;R0--,���С�ڵ���SNAKE_BODY_QUEUE_SIZE�����
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
    
RetroSnake_Print:    ;��R0���껭R1(0:�յ�,1:����,2:ƻ��)
  SAVE_REG
  SLL R5 R0 0
  SRL R5 R5 0
  ADDU R0 R5 R0      ;R0��y����*2
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