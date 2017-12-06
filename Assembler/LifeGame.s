; ����һ��������Ϸ
GOTO LifeGame_Main


DEFINE LifeGame_MAP_N 1E  ;30��
DEFINE LifeGame_MAP_M 28  ;40��(����Ϊ1��)
;DEFINE LifeGame_MAP_N 10  ;16��
;DEFINE LifeGame_MAP_M 10  ;16��(����Ϊ1��)
DEFINE LifeGame_Alive_PictureL 1C   ;���ŵ�״̬ͼƬID Left
DEFINE LifeGame_Alive_PictureR 1D   ;���ŵ�״̬ͼƬID Left
DEFINE LifeGame_Dead_PictureL 20   ;���ŵ�״̬ͼƬID Left
DEFINE LifeGame_Dead_PictureR 20   ;���ŵ�״̬ͼƬID Right
DATA LifeGame_Map 1200  ;������Ϸ�ĵ�ͼ0/1��ʾ����
DATA LifeGame_Map_EndAddr 1 ;����λ����ʾMAP��β��ַ
DATA LifeGame_Offset 8  ;16λ����ͨ����16λ��ʾ�������ֱ�Ӽӷ���ƫ��(���зǷ��������л���) (1,0)(0,1)(-1,0)(0,-1)(1,1)(-1,1)(-1,-1)(1,-1)

LifeGame_Main:
  CALL VGA_MEM_INIT
  CALL LifeGame_INIT
  CALL VGA_COM_PRINT
  LI R5 0  ;R5��¼�Ƿ�Auto����
  LifeGame_Main_Loop:
    CALL KeyBoard_Get
    BNEZ R5 2
    NOP
    BEQZ R0 LifeGame_Main_Loop
    NOP
    CALL LifeGame_OneStep
    CALL VGA_COM_PRINT
    MOVE R1 R0
    ADDIU R1 8F
    BEQZ R1 LifeGame_Main_RET ;�������Q����Ϸ����
    NOP
    MOVE R1 R0
    ADDIU R1 8E
    BEQZ R1 LifeGame_Main ;�������R�����¿�ʼ
    NOP
    MOVE R1 R0
    ADDIU R1 9F
    BEQZ R1 LifeGame_Main_BeginAuto ;�������A���Զ�������Ϸ
    NOP
    MOVE R1 R0
    ADDIU R1 8D
    BEQZ R1 LifeGame_Main_StopAuto ;�������S��ֹͣ�Զ�����
    NOP
    B LifeGame_Main_Loop
    NOP
    LifeGame_Main_BeginAuto:
      LI R5 1
      GOTO LifeGame_Main_Loop
    LifeGame_Main_StopAuto:
      LI R5 0
      GOTO LifeGame_Main_Loop
  LifeGame_Main_RET:
  LI R0 F0 ;��ǳ������н���
  RET

LifeGame_UnitTest:    ;��Ԫ�����߼���ÿ���ն�G��ʱ��ִ��һ��
  DATA LifeGame_isInit 1;�Ƿ��ʼ����Ϊ����ֵ��ʾ�Ѿ���ʼ����
  SAVE_REG
  LOAD_DATA LifeGame_isInit R0 0
  ADDIU R0 FF;����ֵ
  BEQZ R0 LifeGame_UnitTest_OneStep
  NOP
  CALL VGA_MEM_INIT
  CALL LifeGame_INIT
  LifeGame_UnitTest_OneStep:
  CALL LifeGame_OneStep
  CALL VGA_COM_PRINT
  LOAD_REG
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

LifeGame_MapAddr:  ;��R0��16λ��ʾ����ת��ΪMAP�±�
  SW_SP R1 0
  ADDSP 1
  SLL R1 R0 0
  SRL R1 R1 0
  SRL R0 R0 0
  MOVE R6 R0
  SLL R0 R0 5
  SLL R6 R6 3
  ADDU R0 R6 R0 ;R0=x*40,R1=y
  ADDU R0 R1 R1
  LOAD_ADDR LifeGame_Map R0
  ADDU R0 R1 R0
  ADDSP FF
  LW_SP R1 0
  RET

LifeGame_OneStep:   ;����һ�����㣬����ʾ�����Լ����8λ��¼��һ�غϵĽ������8λΪ��һ�غϵĽ��
  SAVE_REG
  ;��һ��ѭ��ˢ��״̬
  LI R4 LifeGame_MAP_N ;R4����ѭ������
  ADDIU R4 FF
  LifeGame_OneStep_L1:
    LI R5 LifeGame_MAP_M  ;R5����ѭ������
    ADDIU R5 FF
    LifeGame_OneStep_L2:
      ;��ѭ����
      SLL R3 R4 0
      ADDU R3 R5 R3 ;����R3�����ĵ�16λ����
      LI R1 0   ;ö��8��������������R1
      ;R0�ǵ�ǰö�ٵ�Addr
      
      LifeGame_OneStep_CASE0:    ;--ö��0����
          MOVE R2 R1
          LOAD_DATA LifeGame_Offset R0 0 ;�ȼ���Ƿ���Խ��
          ADDU R0 R3 R0
          SLL R1 R0 0
          SRL R1 R1 0
          SRL R0 R0 0
          CALL LifeGame_Check_Point
          BEQZ R0 LifeGame_OneStep_CASE1
          MOVE R1 R2
          LOAD_DATA LifeGame_Offset R0 0
          ADDU R0 R3 R0
          CALL LifeGame_MapAddr
          LW R0 R2 0
          SLL R2 R2 0
          SRL R2 R2 0 ;����R2��Ŀ����ӵ�����״̬
          ADDU R1 R2 R1
      
      LifeGame_OneStep_CASE1:    ;--ö��1����
          MOVE R2 R1
          LOAD_DATA LifeGame_Offset R0 1 ;�ȼ���Ƿ���Խ��
          ADDU R0 R3 R0
          SLL R1 R0 0
          SRL R1 R1 0
          SRL R0 R0 0
          CALL LifeGame_Check_Point
          BEQZ R0 LifeGame_OneStep_CASE2
          MOVE R1 R2
          LOAD_DATA LifeGame_Offset R0 1
          ADDU R0 R3 R0
          CALL LifeGame_MapAddr
          LW R0 R2 0
          SLL R2 R2 0
          SRL R2 R2 0 ;����R2��Ŀ����ӵ�����״̬
          ADDU R1 R2 R1
      
      LifeGame_OneStep_CASE2:    ;--ö��2����
          MOVE R2 R1
          LOAD_DATA LifeGame_Offset R0 2 ;�ȼ���Ƿ���Խ��
          ADDU R0 R3 R0
          SLL R1 R0 0
          SRL R1 R1 0
          SRL R0 R0 0
          CALL LifeGame_Check_Point
          BEQZ R0 LifeGame_OneStep_CASE3
          MOVE R1 R2
          LOAD_DATA LifeGame_Offset R0 2
          ADDU R0 R3 R0
          CALL LifeGame_MapAddr
          LW R0 R2 0
          SLL R2 R2 0
          SRL R2 R2 0 ;����R2��Ŀ����ӵ�����״̬
          ADDU R1 R2 R1
      
      LifeGame_OneStep_CASE3:    ;--ö��3����
          MOVE R2 R1
          LOAD_DATA LifeGame_Offset R0 3 ;�ȼ���Ƿ���Խ��
          ADDU R0 R3 R0
          SLL R1 R0 0
          SRL R1 R1 0
          SRL R0 R0 0
          CALL LifeGame_Check_Point
          BEQZ R0 LifeGame_OneStep_CASE4
          MOVE R1 R2
          LOAD_DATA LifeGame_Offset R0 3
          ADDU R0 R3 R0
          CALL LifeGame_MapAddr
          LW R0 R2 0
          SLL R2 R2 0
          SRL R2 R2 0 ;����R2��Ŀ����ӵ�����״̬
          ADDU R1 R2 R1
      
      LifeGame_OneStep_CASE4:    ;--ö��4����
          MOVE R2 R1
          LOAD_DATA LifeGame_Offset R0 4 ;�ȼ���Ƿ���Խ��
          ADDU R0 R3 R0
          SLL R1 R0 0
          SRL R1 R1 0
          SRL R0 R0 0
          CALL LifeGame_Check_Point
          BEQZ R0 LifeGame_OneStep_CASE5
          MOVE R1 R2
          LOAD_DATA LifeGame_Offset R0 4
          ADDU R0 R3 R0
          CALL LifeGame_MapAddr
          LW R0 R2 0
          SLL R2 R2 0
          SRL R2 R2 0 ;����R2��Ŀ����ӵ�����״̬
          ADDU R1 R2 R1
      
      LifeGame_OneStep_CASE5:    ;--ö��5����
          MOVE R2 R1
          LOAD_DATA LifeGame_Offset R0 5 ;�ȼ���Ƿ���Խ��
          ADDU R0 R3 R0
          SLL R1 R0 0
          SRL R1 R1 0
          SRL R0 R0 0
          CALL LifeGame_Check_Point
          BEQZ R0 LifeGame_OneStep_CASE6
          MOVE R1 R2
          LOAD_DATA LifeGame_Offset R0 5
          ADDU R0 R3 R0
          CALL LifeGame_MapAddr
          LW R0 R2 0
          SLL R2 R2 0
          SRL R2 R2 0 ;����R2��Ŀ����ӵ�����״̬
          ADDU R1 R2 R1
      
      LifeGame_OneStep_CASE6:    ;--ö��6����
          MOVE R2 R1
          LOAD_DATA LifeGame_Offset R0 6 ;�ȼ���Ƿ���Խ��
          ADDU R0 R3 R0
          SLL R1 R0 0
          SRL R1 R1 0
          SRL R0 R0 0
          CALL LifeGame_Check_Point
          BEQZ R0 LifeGame_OneStep_CASE7
          MOVE R1 R2
          LOAD_DATA LifeGame_Offset R0 6
          ADDU R0 R3 R0
          CALL LifeGame_MapAddr
          LW R0 R2 0
          SLL R2 R2 0
          SRL R2 R2 0 ;����R2��Ŀ����ӵ�����״̬
          ADDU R1 R2 R1
      
      LifeGame_OneStep_CASE7:    ;--ö��7����
          MOVE R2 R1
          LOAD_DATA LifeGame_Offset R0 7 ;�ȼ���Ƿ���Խ��
          ADDU R0 R3 R0
          SLL R1 R0 0
          SRL R1 R1 0
          SRL R0 R0 0
          CALL LifeGame_Check_Point
          BEQZ R0 LifeGame_OneStep_CASE8
          MOVE R1 R2
          LOAD_DATA LifeGame_Offset R0 7
          ADDU R0 R3 R0
          CALL LifeGame_MapAddr
          LW R0 R2 0
          SLL R2 R2 0
          SRL R2 R2 0 ;����R2��Ŀ����ӵ�����״̬
          ADDU R1 R2 R1
          
      LifeGame_OneStep_CASE8:
      
      ;�����汾���Լ�������̬��Ϊ�·�������̬
      MOVE R0 R3
      CALL LifeGame_MapAddr
      LW R0 R3 0  ;R3���������ĵ�����
      SLL R1 R1 0
      ADDU R1 R3 R1
      SW R0 R1 0
      
      BEQZ R5 LifeGame_OneStep_NoJumpL2
      ADDIU R5 FF
      GOTO LifeGame_OneStep_L2
      LifeGame_OneStep_NoJumpL2:
    BEQZ R4 LifeGame_OneStep_NoJumpL1
    ADDIU R4 FF
    GOTO LifeGame_OneStep_L1
    LifeGame_OneStep_NoJumpL1:
    
  ;�ڶ���ѭ��д��
  LI R4 LifeGame_MAP_N ;R4����ѭ������
  ADDIU R4 FF
  LifeGame_OneStep_L3:
    LI R5 LifeGame_MAP_M  ;R5����ѭ������
    ADDIU R5 FF
    LifeGame_OneStep_L4:
      ;��ѭ����
      SLL R3 R4 0
      ADDU R3 R5 R3 ;����R3��16λ����
      MOVE R0 R3
      CALL LifeGame_MapAddr ;R0���������ĵ��ڴ��ַ
      LW R0 R1 0
      SLL R2 R1 0
      SRL R2 R2 0  ;R2������ԭ��������״̬
      SRL R1 R1 0 ;����R1�����ĸ��ӵ��ھ�����
      ;������һ�غϵ�״̬
      LI R6 2
      CMP R1 R6
      BTEQZ LifeGame_OneStep_Keep  ;��Ϊ2�򱣳�
      LI R6 3
      CMP R1 R6
      BTEQZ LifeGame_OneStep_Appear  ;��Ϊ3������
      NOP
      LifeGame_OneStep_Dead:
          LI R1 0 ;�������Ϊ����
          B LifeGame_OneStep_Change
          NOP
      LifeGame_OneStep_Keep:
          MOVE R1 R2 ;����֮ǰ״̬
          B LifeGame_OneStep_Change
          NOP
      LifeGame_OneStep_Appear:
          LI R1 1 ;����
          B LifeGame_OneStep_Change
          NOP
      LifeGame_OneStep_Change:
          MOVE R0 R3
          CALL LifeGame_Change
      BNEZ R5 LifeGame_OneStep_L4
      ADDIU R5 FF
    BNEZ R4 LifeGame_OneStep_L3
    ADDIU R4 FF
  LOAD_REG
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