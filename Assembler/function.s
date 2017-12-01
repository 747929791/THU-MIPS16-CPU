;通用函数库

MULTI:  ;布斯算法计算有符号16位整数乘法R0*R1,将LOW保存于R0，HIGH保存于R1
;R1(16bit)&R0(16bit)
;R0保留低16位
;R1保留高16位
;R2为R1最低位
;R3为R0最低位
;R4作为布斯算法的附加位
;R5作为循环变量
;R6保存R1副本
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
    MULTI_PLUS_X: ;10 部分积+X
      ADDU R1 R6 R1
      B MULTI_SHIFT
      NOP
    MULTI_SUB_X: ;10 部分积-X
      SUBU R1 R6 R1
    MULTI_SHIFT: ;移位
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
  RET