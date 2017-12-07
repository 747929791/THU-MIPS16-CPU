;这是一个文本计算器(输入"34*100"输出"3400")
GOTO Calculate_Main

;STRING CALC_TEST_S "123*41" ;测试表达式
STRING CALC_TEST_S "10/3E" ;测试表达式
DATA CALC_RESULT 10  ;存放计算结果
DATA CALC_RESULT_END 1 ;结果缓冲区的结尾
STRING Calculate_Input_SIG ">>> "

Calculate_Test:
  Load_addr CALC_TEST_S R0
  CALL Calculate_Calc
  RET

Calculate_Main:
  CALL VGA_MEM_INIT
  CALL Calculate_INIT
  CALL VGA_COM_PRINT
  LOAD_ADDR Calculate_Input_SIG R0   ;先输出">>> "
  CALL printf
  Calculate_Main_KeyBoard_Get_Loop:
    CALL KeyBoard_Get
    BEQZ R0 Calculate_Main_KeyBoard_Get_Loop
    NOP
    
    LI R6 08
    CMP R0 R6   ;判断是否为BackSpace
    BTNEZ Calculate_Main_NoBackSpace
    NOP
    CALL Print_Cache_BackSpace
    GOTO Calculate_Main_KeyBoard_Get_Loop
    Calculate_Main_NoBackSpace:
    
    LI R6 1B
    CMP R0 R6   ;判断是否为ESC
    BTEQZ Calculate_Main_RET ;是ESC
    NOP
    
    LI R6 0A
    CMP R0 R6   ;判断是否为回车
    BTEQZ Calculate_Main_KeyBoard_Get_Enter ;是回车
    NOP
    
    CALL print_char  ;否则输出该字符
    LOAD_DATA KeyBoard_Cache_P R1 0
    SW R1 R0 0
    ADDIU R1 1
    SAVE_DATA KeyBoard_Cache_P R1 0
    B Calculate_Main_KeyBoard_Get_Loop
    NOP
    Calculate_Main_KeyBoard_Get_Enter:
        CALL Calculate_Main_KeyBoard_Enter
    CALL VGA_COM_PRINT
    GOTO Calculate_Main_KeyBoard_Get_Loop
  Calculate_Main_RET:
  RET

Calculate_Main_KeyBoard_Enter:   ;当按下键盘回车时应当处理的逻辑
  SAVE_REG
  ;清空缓存区，补\0
  CALL next_cursor_line
  Load_Data KeyBoard_Cache_P R0 0
  LI R1 0
  SW R0 R1 0
  LOAD_ADDR KeyBoard_Cache R0
  SAVE_DATA KeyBoard_Cache_P R0 0
  ;计算输入表达式结果，并显示
  CALL Calculate_Calc
  CALL printf
  CALL next_cursor_line
  Load_Addr Calculate_Input_SIG R0
  CALL printf
  LOAD_REG
  RET

Calculate_Calc:     ;根据R0指向地址的字符串计算表达式的值，并将结果字符串首地址通过R0返回
  SAVE_REG
  ;将操作数放于堆栈上
  LI R3 0
  LI R4 0 ;R4记录当前正在计算的操作数，R3记录左操作数
  LI R5 FF ;R5运算符
  LW R0 R1 0   ;将字符读入R1
  Calculate_Calc_Loop:    
    ;如果当前值不为数字则默认为运算符
    LI R6 39
    SLT R6 R1
    BTNEZ Calculate_Calc_Find_Operator
    NOP
    LI R6 30
    SLT R1 R6
    BTNEZ Calculate_Calc_Find_Operator
    NOP
    ;否则为数字
    B Calculate_Calc_Find_Num
    NOP    
    Calculate_Calc_Find_Operator:
      LI R6 FF
      CMP R5 R6
      BTNEZ 3  ;跳过这一计算阶段
      NOP
      MOVE R3 R4
      LI R4 0
      MOVE R5 R1
      B Calculate_Calc_Loop_Final
      NOP
    Calculate_Calc_Find_Num:
      LI R6 30
      SUBU R1 R6 R1  ;R1 ASCII转整数
      SLL R6 R4 1
      SLL R4 R4 3
      ADDU R4 R1 R4
      ADDU R4 R6 R4 ;R4=10*R4+ord(R0)-48
      B Calculate_Calc_Loop_Final
      NOP
    Calculate_Calc_Loop_Final:
      ADDIU R0 1
      LW R0 R1 0   ;将字符读入R1
      BNEZ R1 Calculate_Calc_Loop
      NOP
  ;如果没有发现运算符则默认为加法
  LI R6 FF
  CMP R5 R6
  BTNEZ 2
  NOP
  LI R5 2B
  ;现在R3和R4位两个操作数的值，R5为操作符
  LI R6 2B
  CMP R5 R6
  BTEQZ Calculate_Calc_Plus
  LI R6 2D
  CMP R5 R6
  BTEQZ Calculate_Calc_Minus
  LI R6 2A
  CMP R5 R6
  BTEQZ Calculate_Calc_Multi
  LI R6 2F
  CMP R5 R6
  BTEQZ Calculate_Calc_Division
  LI R6 25
  CMP R5 R6
  BTEQZ Calculate_Calc_Mod
  LI R6 5E
  CMP R5 R6
  BTEQZ Calculate_Calc_Power
  NOP
;在此进行错误处理
    STRING Calculate_Calc_Syntax_Error "Syntax Error"
    LOAD_ADDR Calculate_Calc_Syntax_Error R0
    SW_SP R0 F8
    LOAD_REG
    RET
    
  Calculate_Calc_Plus:
    ADDU R3 R4 R0
    B Calculate_Calc_GetResult
    NOP
  Calculate_Calc_Minus:
    SUBU R3 R4 R0
    B Calculate_Calc_GetResult
    NOP
  Calculate_Calc_Multi:
    MOVE R0 R3
    MOVE R1 R4
    CALL MULTI
    B Calculate_Calc_GetResult
    NOP
  Calculate_Calc_Division:
    MOVE R0 R3
    MOVE R1 R4
    CALL DIVISION
    B Calculate_Calc_GetResult
    NOP
  Calculate_Calc_Mod:
    MOVE R0 R3
    MOVE R1 R4
    CALL DIVISION
    MOVE R0 R1
    B Calculate_Calc_GetResult
    NOP
  Calculate_Calc_POWER:
    MOVE R0 R3
    MOVE R1 R4
    CALL POWER
    B Calculate_Calc_GetResult
    NOP
  Calculate_Calc_GetResult:
  ;此时R0保存计算结果
  LOAD_ADDR CALC_RESULT_END R5 ;R5缓存写入字符的地址
  ADDIU R5 FF
  LI R4 0
  SW R5 R4 0  ;最后一位为\0
  Calculate_Calc_GetResult_L1:
   ADDIU R5 FF
   LI R1 0A
   CALL DIVISION
   ADDIU R1 30
   SW R5 R1 0
   BNEZ R0 Calculate_Calc_GetResult_L1
   NOP
  SW_SP R5 F8
  LOAD_REG
  RET

Calculate_INIT:     ;初始化的屏幕字符显示
  SAVE_REG
  LOAD_ADDR KeyBoard_Cache R0
  SAVE_DATA KeyBoard_Cache_P R0 0
  LI R0 0
  CALL set_cursor
  STRING Calculate_INIT_Info "Calculate Program. Support '+-*/%^'."
  LOAD_ADDR Calculate_INIT_Info R0
  CALL printf
  CALL next_cursor_line
  LOAD_REG
  RET