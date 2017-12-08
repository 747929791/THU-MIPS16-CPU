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
  
String_IsHexChar:    ;判断R0 ASCII码是否为16进制合法字符，将Bool通过R0返回
  LI R6 30
  SUBU R0 R6 R0
  LI R6 0A
  SLTU R0 R6
  BTNEZ String_IsHexChat_True;判断是否为0-9
  NOP
  LI R6 11
  SUBU R0 R6 R0
  LI R6 1A
  SLTU R0 R6
  BTNEZ String_IsHexChat_True;判断是否为A-Z
  NOP
  String_IsHexChat_False:
    LI R0 0
    RET  
  String_IsHexChat_True:
    LI R0 1
    RET  

String_ReadHex:      ;从R0内存地址开始读取一个十六进制数的字符串，将整数结果通过R0返回，末尾指针通过R1返回(功能同scanf)
  SAVE_REG
  MOVE R5 R0
  ;先将R0变为最近的一个数字(0-9,A-F)
  B String_ReadHex_FindFirst_Loop_Middle ;Jump to middle
  NOP
  String_ReadHex_FindFirst_Loop:
    ADDIU R5 1
    String_ReadHex_FindFirst_Loop_Middle:
    LW R5 R0 0
    ;如果遇到\0则返回0退出
      BNEZ R0 String_ReadHex_NotReturn0
      NOP
        LI R4 0
        B String_ReadHex_RET
        NOP
      String_ReadHex_NotReturn0:
    CALL String_IsHexChar
    BEQZ R0 String_ReadHex_FindFirst_Loop
    NOP
  ;现在R5指向第一个字符的地址
  LI R4 0;R4缓存结果数值
  String_ReadHex_FindLast_Loop:
    LW R5 R0 0
    CALL String_IsHexChar
    BEQZ R0 String_ReadHex_RET
    NOP
    LW R5 R0 0
    CALL String_HexCharToInt
    SLL R4 R4 4
    ADDU R0 R4 R4
    ADDIU R5 1
    B String_ReadHex_FindLast_Loop
    NOP
  String_ReadHex_RET:
    SW_SP R4 F8
    ;SW_SP R5 F9
    SW_SP R5 0
    LOAD_REG
    LW_SP R1 8
    RET