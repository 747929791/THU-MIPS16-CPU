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