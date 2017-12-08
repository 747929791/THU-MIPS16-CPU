;---------------------------------------------------------------------------通用函数库---------------------------------------------------------------------------;
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
  ADDSP FC
  LW_SP R2 0
  LW_SP R3 1
  LW_SP R4 2
  LW_SP R5 3
  RET
  
DIVISION:  ;加减交替原码一位除法，R0/R1，商保存于R0，余数存于R1
  SW_SP R2 0
  SW_SP R3 1
  SW_SP R4 2
  ADDSP 3
  LI R2 0 ;R2计算除数有多少位
  MOVE R3 R1
  SRL R3 R3 1
  ADDIU R2 1
  BNEZ R3 FD
  NOP
  SUBU R3 R2 R2  ;R2=16-R2
  ADDIU R2 10
  MOVE R3 R1     ;R3保存移位的 除数
  SLLV R2 R3
  LI R4 1
  SLLV R2 R4      ;R4为1位
  MOVE R1 R0
  LI R0 0
  DIVISION_LOOP:
    ADDIU R3 FF
    SLTU R3 R1
    ADDIU R3 1
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

POWER:   ;计算R0^R1,返回R0(16位)
  SAVE_REG
  MOVE R3 R1
  MOVE R2 R0
  LI R0 1
  BEQZ R1 POWER_LOOP_RET
  NOP
  POWER_LOOP:
    MOVE R1 R2
    CALL MULTI
    ADDIU R3 FF
    BNEZ R3 POWER_LOOP
    NOP
  POWER_LOOP_RET:
  SW_SP R0 F8
  LOAD_REG
  RET
  
DATA RANDOM_SEED 1

FastRAND:  ;快速的伪随机数发生器，将15位结果返回至寄存器R0
; x(n+1)=(3*x(n)+59)%65536
  LOAD_DATA RANDOM_SEED R0 0
  ADDU R0 R0 R6
  ADDU R0 R6 R0
  LI R6 3B
  ADDU R0 R6 R0
  SAVE_DATA RANDOM_SEED R0 0
  RET

RAND:  ;伪随机数发生器，将15位结果返回至寄存器R0
; x(n+1)=(123*x(n)+59)%65536
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