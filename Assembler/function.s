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
    ADDIU R2 FF
    BNEZ R2 DIVISION_LOOP
    NOP
  ADDSP FD
  LW_SP R2 0
  LW_SP R3 1
  LW_SP R4 2
  RET

RAND:  ;α���������������15λ����������Ĵ���R0
; x(n+1)=(3*x(n)+0x61B9)>>1
  DATA RANDOM_SEED 1
  SW_SP R1 0
  ADDSP 1
  LOAD_DATA RANDOM_SEED R0 0
  LI R1 62
  SLL R1 R1 0
  ADDIU R1 B9
  ADDU R0 R1 R1
  ADDU R0 R1 R1
  ADDU R0 R1 R0
  SRL R0 R0 1
  SAVE_DATA RANDOM_SEED R0 0
  ADDSP FF
  LW_SP R1 0
  RET