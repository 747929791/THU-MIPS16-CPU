;----------------------------------------------------------------字符串处理函数集--------------------------------------------------------------
GOTO STRING_TEST

STRING_TEST:
  STRING STRING_TEST_A "1416297 1333"
  STRING STRING_TEST_B "14162937 133"
  LOAD_ADDR STRING_TEST_A R0
  LOAD_ADDR STRING_TEST_B R1
  CALL String_PrefixCMP
  RET

String_CMP:    ;比较R0和R1为起始地址的字符串是否相等
  SAVE_REG
  String_CMP_Loop:
    LW R0 R2 0
    LW R1 R3 0;R2 R3为两个字符
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

String_PrefixCMP:    ;比较R0和R1为起始地址的字符串前缀是否相等(匹配中遇到\0即认为相等)
  SAVE_REG
  String_PrefixCMP_Loop:
    LW R0 R2 0
    LW R1 R3 0;R2 R3为两个字符
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
    


String_CharToHex:  ;将R0转化为16进制字符ASCII码
  SAVE_REG
  LI R6 0F
  AND R0 R6  ;只保留后4位
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
    
String_HexCharToInt:  ;将字符R0(0-9,A-F)转化为整数R0返回
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

String_IntToHex:   ;将R0转换为4bit16进制字符串，将字符串首地址通过R0返回
  DATA String_IntToHex_result 5
  SAVE_REG
  LI R5 0
  SAVE_DATA String_IntToHex_result R5 4 ;末尾\0
  MOVE R5 R0
  ;计算第0位
  SRL R0 R5 0
  SRL R0 R0 4
  CALL String_CharToHex
  SAVE_DATA String_IntToHex_result R0 0
  ;计算第1位
  SRL R0 R5 0
  CALL String_CharToHex
  SAVE_DATA String_IntToHex_result R0 1
  ;计算第2位
  SRL R0 R5 4
  CALL String_CharToHex
  SAVE_DATA String_IntToHex_result R0 2
  ;计算第3位
  MOVE R0 R5
  CALL String_CharToHex
  SAVE_DATA String_IntToHex_result R0 3
  LOAD_ADDR String_IntToHex_result R0
  SW_SP R0 F8
  LOAD_REG
  RET
  
 String_8IntToHex:   ;将R0后8位转换为2bit16进制字符串，将字符串首地址通过R0返回
  CALL String_IntToHex
  ADDIU R0 2
  RET