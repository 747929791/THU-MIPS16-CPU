;----------------------------------------------------------------�ַ�����������--------------------------------------------------------------
GOTO STRING_TEST

STRING_TEST:
  STRING STRING_TEST_A "1416297 1333"
  STRING STRING_TEST_B "14162937 133"
  LOAD_ADDR STRING_TEST_A R0
  LOAD_ADDR STRING_TEST_B R1
  CALL String_PrefixCMP
  RET

String_CMP:    ;�Ƚ�R0��R1Ϊ��ʼ��ַ���ַ����Ƿ����
  SAVE_REG
  String_CMP_Loop:
    LW R0 R2 0
    LW R1 R3 0;R2 R3Ϊ�����ַ�
    CMP R2 R3
    BTNEZ String_CMP_False
    NOP
    ADDIU R0 1
    ADDIU R1 1
    BNEZ R2 String_CMP_Loop
    NOP
  String_CMP_True:
    LI R0 1
    SW_SP R0 F8
    LOAD_REG
    RET
  String_CMP_False:
    LI R0 0
    SW_SP R0 F8
    LOAD_REG
    RET

String_PrefixCMP:    ;�Ƚ�R0��R1Ϊ��ʼ��ַ���ַ���ǰ׺�Ƿ����(ƥ��������\0����Ϊ���)
  SAVE_REG
  String_PrefixCMP_Loop:
    LW R0 R2 0
    LW R1 R3 0;R2 R3Ϊ�����ַ�
    LI R4 0
    CMP R2 R4
    BTEQZ String_PrefixCMP_True
    NOP
    CMP R3 R4
    BTEQZ String_PrefixCMP_True
    NOP
    CMP R2 R3
    BTNEZ String_PrefixCMP_False
    NOP
    ADDIU R0 1
    ADDIU R1 1
    BNEZ R2 String_PrefixCMP_Loop
    NOP
  String_PrefixCMP_True:
    LI R0 1
    SW_SP R0 F8
    LOAD_REG
    RET
  String_PrefixCMP_False:
    LI R0 0
    SW_SP R0 F8
    LOAD_REG
    RET
    


String_CharToHex:  ;��R0ת��Ϊ16�����ַ�ASCII��
  SAVE_REG
  LI R6 0F
  AND R0 R6  ;ֻ������4λ
  LI R6 0A
  SLT R0 R6
  BTNEZ String_CharToHex_0_9
  NOP
  String_CharToHex_A_F:
    ADDIU R0 37
    SW_SP R0 F8
    LOAD_REG
    RET
  String_CharToHex_0_9:
    ADDIU R0 30
    SW_SP R0 F8
    LOAD_REG
    RET
    
String_HexCharToInt:  ;���ַ�R0(0-9,A-F)ת��Ϊ����R0����
  SAVE_REG
  LI R6 30
  SUBU R0 R6 R0
  LI R6 0A
  SLT R0 R6
  BTNEZ String_HexCharToInt_0_9
  NOP
  String_HexCharToInt_A_F:
    ADDIU R0 F0
    ADDIU R0 09
    SW_SP R0 F8
    LOAD_REG
    RET
  String_HexCharToInt_0_9:
    SW_SP R0 F8
    LOAD_REG
    RET

String_IntToHex:   ;��R0ת��Ϊ4bit16�����ַ��������ַ����׵�ַͨ��R0����
  DATA String_IntToHex_result 5
  SAVE_REG
  LI R5 0
  SAVE_DATA String_IntToHex_result R5 4 ;ĩβ\0
  MOVE R5 R0
  ;�����0λ
  SRL R0 R5 0
  SRL R0 R0 4
  CALL String_CharToHex
  SAVE_DATA String_IntToHex_result R0 0
  ;�����1λ
  SRL R0 R5 0
  CALL String_CharToHex
  SAVE_DATA String_IntToHex_result R0 1
  ;�����2λ
  SRL R0 R5 4
  CALL String_CharToHex
  SAVE_DATA String_IntToHex_result R0 2
  ;�����3λ
  MOVE R0 R5
  CALL String_CharToHex
  SAVE_DATA String_IntToHex_result R0 3
  LOAD_ADDR String_IntToHex_result R0
  SW_SP R0 F8
  LOAD_REG
  RET
  
 String_8IntToHex:   ;��R0��8λת��Ϊ2bit16�����ַ��������ַ����׵�ַͨ��R0����
  CALL String_IntToHex
  ADDIU R0 2
  RET