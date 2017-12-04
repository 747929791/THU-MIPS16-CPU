; ����һ��������Ϸ
GOTO LifeGame_Main

DEFINE LifeGame_MAP_N 1E  ;30��
DEFINE LifeGame_MAP_M 28  ;40��(����Ϊ1��)
DEFINE LifeGame_Alive_PictureL 28   ;���ŵ�״̬ͼƬID Left
DEFINE LifeGame_Alive_PictureR 29   ;���ŵ�״̬ͼƬID Left
DEFINE LifeGame_Dead_PictureL 20   ;���ŵ�״̬ͼƬID Left
DEFINE LifeGame_Dead_PictureR 20   ;���ŵ�״̬ͼƬID Right
DATA LifeGame_Map 1200  ;������Ϸ�ĵ�ͼ0/1��ʾ����
DATA LifeGame_Map_EndAddr 1 ;����λ����ʾMAP��β��ַ
DATA LifeGame_Offset 8  ;16λ����ͨ����16λ��ʾ�������ֱ�Ӽӷ���ƫ��(���зǷ��������л���) (1,0)(0,1)(-1,0)(0,-1)(1,1)(-1,1)(-1,-1)(1,-1)

LifeGame_Main:
  CALL VGA_MEM_INIT
  CALL LifeGame_INIT
  CALL VGA_COM_PRINT
  RET


LifeGame_INIT:
  SAVE_REG
  ;�����߼�����
  LI R0 0
    ;�������ͨ����
    LI R0 1
    SAVE_DATA LifeGame_Offset R0 1    ;0001
    SLL R0 R0 0
    SAVE_DATA LifeGame_Offset R0 0  ;0100
    ADDIU R0 1
    SAVE_DATA LifeGame_Offset R0 4  ;0101
    LI R0 FF
    SLL R0 R0 0
    SAVE_DATA LifeGame_Offset R0 2  ;FF00
    ADDIU R0 1
    SAVE_DATA LifeGame_Offset R0 5  ;FF01
    LI R1 2
    SUBU R0 R1 R1
    SAVE_DATA LifeGame_Offset R1 6  ;FEFF
    LI R1 FE
    ADDU R0 R1 R0
    SAVE_DATA LifeGame_Offset R0 3  ;FFFF
    LI R0 FF
    SAVE_DATA LifeGame_Offset R0 7  ;00FF
  CALL LifeGame_RandomMapAndPring
  LOAD_REG
  RET

LifeGame_RandomMapAndPring:   ;���������ʼ��ͼ����ʾ
  SAVE_REG
  LI R4 LifeGame_MAP_N ;R4����ѭ������
  ADDIU R4 FF
  LifeGame_RandomMapAndPring_L1:
    LI R5 LifeGame_MAP_M  ;R5����ѭ������
    ADDIU R5 FF
    LifeGame_RandomMapAndPring_L2:
      ;��ѭ����
;��ʵ�֣�������������������������������������������������������������
      CALL FastRAND
      SRL R1 R0 0
      SRL R1 R1 7  ;R1��¼1/2��������
      SLL R0 R4 0
      ADDU R0 R5 R0
      CALL LifeGame_Change
      BNEZ R5 LifeGame_RandomMapAndPring_L2
      ADDIU R5 FF
    BNEZ R4 LifeGame_RandomMapAndPring_L1
    ADDIU R4 FF
  LOAD_REG
  RET

LifeGame_Check_Point:   ;���(R0,R1)�Ƿ�Ϸ�
  SAVE_REG
  LI R2 0    ;Խ���ж�
  SLT R0 R2
  BTNEZ LifeGame_Check_Point_FalseReturn
  SLT R1 R2
  BTNEZ LifeGame_Check_Point_FalseReturn
  LI R2 LifeGame_MAP_N
  SLT R0 R2
  BTEQZ LifeGame_Check_Point_FalseReturn
  LI R2 LifeGame_MAP_M
  SLT R1 R2
  BTEQZ LifeGame_Check_Point_FalseReturn
  NOP        ;Խ���ж�����
  LifeGame_Check_Point_TrueReturn:
    LOAD_REG
    LI R0 1
    RET
  LifeGame_Check_Point_FalseReturn:
    LOAD_REG
    LI R0 0
    RET

LifeGame_Multi40: ;��R0�����ֿ���*40����Ϊ��ͼ��СӲ�����п�40
  MOVE R6 R0
  SLL R0 R0 5
  SLL R6 R6 3
  ADDU R0 R6 R0
  RET

LifeGame_Change:  ;��R0(16λ��ַ)���������ΪR1,��ά����ʾ
  SAVE_REG
  CALL LifeGame_Print
  Load_Addr LifeGame_Map R2
  SLL R6 R0 0
  SRL R6 R6 0
  ADDU R2 R6 R2
  SRL R0 R0 0
  CALL LifeGame_Multi40
  ADDU R0 R2 R2   ;R2������MAP�ж�Ӧ���ڴ��ַ
  SW R2 R1 0
  LOAD_REG
  RET

LifeGame_Print:   ;R0Ϊ16λ����,R1Ϊ0/1������/��,�ú�������д������ݲ�����VGA��ʾ����
  SAVE_REG
  SRL R3 R0 0 ;R3�����к�
  SLL R4 R0 0
  SRL R4 R4 7 ;R4�����к�*2��˫ͼģʽ��
  SLL R3 R3 0
  ADDU R3 R4 R0 ;����R0λ16λ��ַ(��벿��)
  BNEZ R1 LifeGame_Print_1
  NOP
  LifeGame_Print_0:
    LI R1 LifeGame_Dead_PictureL
    CALL VGA_Draw_Block
    ADDIU R0 1
    LI R1 LifeGame_Dead_PictureR
    CALL VGA_Draw_Block
    B LifeGame_Print_RET
  LifeGame_Print_1:
    LI R1 LifeGame_Alive_PictureL
    CALL VGA_Draw_Block
    ADDIU R0 1
    LI R1 LifeGame_Alive_PictureR
    CALL VGA_Draw_Block
    ;B LifeGame_Print_RET
  LifeGame_Print_RET:
    LOAD_REG
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

FastRAND:  ;���ٵ�α���������������15λ����������Ĵ���R0
; x(n+1)=(3*x(n)+59)%65536
  DATA RANDOM_SEED 1
  LOAD_DATA RANDOM_SEED R0 0
  ADDU R0 R0 R6
  ADDU R0 R6 R0
  LI R6 3B
  ADDU R0 R6 R0
  SAVE_DATA RANDOM_SEED R0 0
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

VGA_Multi80:    ;���ٵ�*80�����ټ���
  SLL R6 R0 6
  SLL R0 R0 4
  ADDU R0 R6 R0
  RET

VGA_Draw_Block:   ;��ͼһ�����ӣ�R0��16λ��ʾ���꣬R1��ʾ��ɫ�Ȳ���(Լ����7λ�������ͣ�ǰRGB����λ)
  SAVE_REG
  MOVE R2 R0  ;R2=R0
  MOVE R3 R1  ;R3=R1
  SRL R0 R0 0 ;R0=R0>>8
  CALL VGA_Multi80
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