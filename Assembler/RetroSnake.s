; ����һ������̰������Ϸ
GOTO RetroSnake_Main

DEFINE SNAKE_MAP_N 1E  ;30��
DEFINE SNAKE_MAP_M 50  ;80��
DATA SNAKE_BODY_QUEUE_FRONT 1 ;��ͷ��ַ��ָ����һλ��
DATA SNAKE_BODY_QUEUE_END 1 ;����β��ַ
DATA SNAKE_BODY_QUEUE 2400  ;�����������
DATA SNAKE_BODY_QUEUE_END_ADDR 1  ;�������б�β��ַ(�洢����Ϊ0���±�Ϊ����ĩβ)
DATA SNAKE_BODY_QUEUE_SIZE 1  ;�������б��С

DATA SNAKE_FourConnected_Offset 4  ;16λ����ͨ����16λ��ʾ�������ֱ�Ӽӷ���ƫ��(����(0,-1)��0������л���) (1,0)(0,1)(-1,0)(0,-1)
DATA SNAKE_Direction 1   ;��ǰ�ߵķ���(0~3)

RetroSnake_Main:
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
  LOAD_ADDR SNAKE_BODY_QUEUE R0
  SAVE_DATA SNAKE_BODY_QUEUE_END R0 0
  SAVE_DATA SNAKE_BODY_QUEUE_FRONT R0 0  ;��ʼ������������
  CALL RetroSnake_Random_Point
  CALL RetroSnake_Push_Queue  ;������һ������
  LI R0 SNAKE_MAP_N
  LI R1 SNAKE_MAP_M
  CALL MULTI
  SAVE_DATA SNAKE_BODY_QUEUE_SIZE R0 0
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
  CALL RetroSnake_Push_Queue    ;���û����ѹ�����
  LOAD_REG
  RET
  RetroSnake_OneStep_Loss:    ;һ��ʧ�ܣ��������߼�
    LOAD_REG
    LI R0 FF
    RET

RetroSnake_Push_Queue:  ;�������ѹ��һ������R0(16λ��ʾ),������ʾ������ά��
  SW_SP R1 0
  SW_SP R2 1
  ADDSP 2
  LOAD_DATA SNAKE_BODY_QUEUE_FRONT R2 0
  SW R2 R0 0
  LI R1 23    ;дʲô������̨д#
  CALL VGA_Draw_Block
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
  LI R1 0    ;дʲô������̨д��(0)
  CALL VGA_Draw_Block
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


;---------------------------------------------------------------------------ͨ�ú�����---------------------------------------------------------------------------;
;ͨ�ú�����

MULTI:  ;��˹�㷨�����з���16λ�����˷�R0*R1,��LOW������R0��HIGH������R1
;R1(16bit)&R0(16bit)
;R0������16λ
;R1������16λ
;R2ΪR1���λ
;R3ΪR0���λ
;R4��Ϊ��˹�㷨�ĸ���λ
;R5��Ϊѭ������
;R6����R1����
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
    MULTI_PLUS_X: ;10 ���ֻ�+X
      ADDU R1 R6 R1
      B MULTI_SHIFT
      NOP
    MULTI_SUB_X: ;10 ���ֻ�-X
      SUBU R1 R6 R1
    MULTI_SHIFT: ;��λ
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
  
DIVISION:  ;�Ӽ�����ԭ��һλ������R0/R1���̱�����R0����������R1
  SW_SP R2 0
  SW_SP R3 1
  SW_SP R4 2
  ADDSP 3
  LI R2 0 ;R2��������ж���λ
  MOVE R3 R1
  SRL R3 R3 1
  ADDIU R2 1
  BNEZ R3 FD
  NOP
  SUBU R3 R2 R2  ;R2=16-R2
  ADDIU R2 10
  MOVE R3 R1     ;R3������λ�� ����
  SLLV R2 R3
  LI R4 1
  SLLV R2 R4      ;R4Ϊ1λ
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

RAND:  ;α���������������15λ����������Ĵ���R0
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
  
;---------------------------------------------------------------------------VGA����ģ��---------------------------------------------------------------------------;

;VGA��ʾ�������������Դ� 
DEFINE VGA_N 1E  ;30��
DEFINE VGA_M 50  ;80��
DATA VGA_MEM 2400

VGA_COM_PRINT:   ;��VGA_MEMͨ�����ڴ�ӡ���նˣ����ڲ���
  SAVE_REG
  LI R0 BF ;R0��¼���ڵ�ַ
  SLL R0 R0 0
  LOAD_ADDR VGA_MEM R5 ;R5ɨ��VGA_MEM��ַ
  LI R3 VGA_N ;R3����ѭ������
  VGA_COM_PRINT_L1:
    LI R4 VGA_M  ;R4����ѭ������
    VGA_COM_PRINT_L2:
      LW R5 R1 0
      BNEZ R1 2   ;����ַ���0�Ļ����'.'
      NOP
      LI R1 2E
      CALL COM_WRITE
      ADDIU R4 FF
      BNEZ R4 VGA_COM_PRINT_L2
      ADDIU R5 1
    LI R1 0A     ;���з�
    CALL COM_WRITE
    ADDIU R3 FF
    BNEZ R3 VGA_COM_PRINT_L1
    NOP
  LI R1 0A     ;���з�
  CALL COM_WRITE
  LOAD_REG
  RET
  
VGA_MEM_INIT:
  SAVE_REG
  LOAD_ADDR VGA_MEM R5 ;R5ɨ��VGA_MEM��ַ
  LI R2 0
  LI R3 VGA_N ;R3����ѭ������
  VGA_MEM_INIT_L1:
    LI R4 VGA_M  ;R4����ѭ������
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
  
VGA_Draw_Block:   ;��ͼһ�����ӣ�R0��16λ��ʾ���꣬R1��ʾ��ɫ�Ȳ���(Լ��ǰ7λ�������ͣ���RGB����λ)
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
  SW R0 R3 0   ;д��VGA�Դ�
  LOAD_REG
  RET
  
;---------------------------------------------------------------------------���ڿ���ģ��---------------------------------------------------------------------------;
  
;���ڽӿں�����

WAIT_COM_W:  ;ѭ��ֱ������R0��д
  SW_SP R1 0
  LI R1 1
  LW R0 R6 0
  AND R6 R1
  BEQZ R6 WAIT_COM_W
  LW_SP R1 0
  RET

TEST_COM_R: ;���ش���R0�Ƿ�ɶ�
  LW R0 R0 0
  LI R6 2
  AND R0 R6
  SRL R0 R0 1
  RET

COM_WRITE:   ;�򴮿�R0д���ֽ�R1
  SW_SP R0 0
  ADDSP 1
  ADDIU R0 1
  CALL WAIT_COM_W
  ADDSP FF
  LW_SP R0 0
  SW R0 R1 0
  RET
  

COM_READ:  ;�Ӵ���R0�����ݣ������ݷ���0�����򷵻�����
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