;这是一个Term中断，支持A,D,G,R,U命令
GOTO Term_Main

DATA Term_RegSave 8 ;缓存G指令执行后的寄存器
DATA Term_Program 200 ;指令存储区
DATA Term_Program_End 1 ;指令存储区结尾(将要写入的地址)
STRING Term_Input_SIG "  >> "

Term_Main:
  CALL VGA_MEM_INIT
  CALL Term_INIT
  CALL VGA_COM_PRINT
  LOAD_ADDR Term_Input_SIG R0   ;先输出">>> "
  CALL printf
  Term_Main_KeyBoard_Get_Loop:
    CALL KeyBoard_Get
    BEQZ R0 Term_Main_KeyBoard_Get_Loop
    NOP
    
    LI R6 08
    CMP R0 R6   ;判断是否为退格
    BTNEZ Term_Main_KeyBoard_Get_NoBackSpace
    NOP
    CALL Print_Cache_BackSpace
    GOTO Term_Main_KeyBoard_Get_Loop
    Term_Main_KeyBoard_Get_NoBackSpace:
    
    LI R6 0A
    CMP R0 R6   ;判断是否为回车
    BTNEZ Term_Main_KeyBoard_Get_NoEnter
    NOP
    CALL Term_Main_KeyBoard_Enter
    GOTO Term_Main_KeyBoard_Get_Loop
    Term_Main_KeyBoard_Get_NoEnter:
    
    LI R6 1B
    CMP R0 R6   ;判断是否为ESC
    BTEQZ Term_Main_RET ;是ESC
    NOP
    CALL print_char  ;否则输出该字符
    LOAD_DATA KeyBoard_Cache_P R1 0
    SW R1 R0 0
    ADDIU R1 1
    SAVE_DATA KeyBoard_Cache_P R1 0
    GOTO Term_Main_KeyBoard_Get_Loop
    Term_Main_KeyBoard_Get_Enter:
        CALL Term_Main_KeyBoard_Enter
    CALL VGA_COM_PRINT
    GOTO Term_Main_KeyBoard_Get_Loop
  Term_Main_RET:
  RET

Term_Main_KeyBoard_Enter:   ;当按下键盘回车时应当处理的逻辑
  SAVE_REG
  ;清空缓存区，补\0
  CALL next_cursor_line
  Load_Data KeyBoard_Cache_P R0 0
  LI R1 0
  SW R0 R1 0
  LOAD_ADDR KeyBoard_Cache R0
  SAVE_DATA KeyBoard_Cache_P R0 0
  LW R0 R1 0 ;R1=缓冲区首字符
  ;判断是否为A指令
  LI R6 41
  CMP R6 R1
  BTNEZ Term_Main_KeyBoard_Enter_NotA
  NOP
    CALL Term_A_Command
  Term_Main_KeyBoard_Enter_NotA:
  ;判断是否为R指令
  LI R6 52
  CMP R6 R1
  BTNEZ Term_Main_KeyBoard_Enter_NotR
  NOP
    CALL Term_R_Command
  Term_Main_KeyBoard_Enter_NotR:
  ;判断是否为D指令
  LI R6 44
  CMP R6 R1
  BTNEZ Term_Main_KeyBoard_Enter_NotD
  NOP
    CALL Term_D_Command
  TERM_MAIN_KEYBOARD_ENTER_NOTD:
  ;判断是否为U指令
  LI R6 55
  CMP R6 R1
  BTNEZ Term_Main_KeyBoard_Enter_NotU
  NOP
    CALL Term_U_Command
  Term_Main_KeyBoard_Enter_NotU:
  ;判断是否为G指令
  LI R6 47
  CMP R6 R1
  BTNEZ Term_Main_KeyBoard_Enter_NotG
  NOP
    CALL Term_G_Command
  Term_Main_KeyBoard_Enter_NotG:
  CALL next_cursor_line
  Load_Addr Term_Input_SIG R0
  CALL printf
  LOAD_REG
  RET

Term_R_Command:   ;查看寄存器堆
  SAVE_REG
  
  STRING Term_R_Command_0 "R0="
  LOAD_ADDR Term_R_Command_0 R0
  CALL printf
  LOAD_DATA Term_RegSave R0 0
  CALL String_IntToHex
  CALL printf
  
  STRING Term_R_Command_1 "  R1="
  LOAD_ADDR Term_R_Command_1 R0
  CALL printf
  LOAD_DATA Term_RegSave R0 1
  CALL String_IntToHex
  CALL printf
  
  STRING Term_R_Command_2 "  R2="
  LOAD_ADDR Term_R_Command_2 R0
  CALL printf
  LOAD_DATA Term_RegSave R0 2
  CALL String_IntToHex
  CALL printf
  
  CALL next_cursor_line
  
  STRING Term_R_Command_3 "R3="
  LOAD_ADDR Term_R_Command_3 R0
  CALL printf
  LOAD_DATA Term_RegSave R0 3
  CALL String_IntToHex
  CALL printf
  
  STRING Term_R_Command_4 "  R4="
  LOAD_ADDR Term_R_Command_4 R0
  CALL printf
  LOAD_DATA Term_RegSave R0 4
  CALL String_IntToHex
  CALL printf
  
  STRING Term_R_Command_5 "  R5="
  LOAD_ADDR Term_R_Command_5 R0
  CALL printf
  LOAD_DATA Term_RegSave R0 5
  CALL String_IntToHex
  CALL printf
  
  LOAD_REG
  RET

Term_INIT:     ;初始化的屏幕字符显示
  SAVE_REG
  LI R0 VGA_N;初始化滚屏高度
  SAVE_DATA Print_Scroll_Bottom R0 0
  LI R0 0
  SAVE_DATA Term_RegSave R0 0
  SAVE_DATA Term_RegSave R0 1
  SAVE_DATA Term_RegSave R0 2
  SAVE_DATA Term_RegSave R0 3
  SAVE_DATA Term_RegSave R0 4
  SAVE_DATA Term_RegSave R0 5
  SAVE_DATA Term_RegSave R0 6
  SAVE_DATA Term_RegSave R0 7
  LOAD_ADDR KeyBoard_Cache R0
  SAVE_DATA KeyBoard_Cache_P R0 0
  LI R0 0
  CALL set_cursor
  LOAD_REG
  RET

Term_A_Command_Insert_Get1Bit:   ;从R0指向的字符串中取出R1下标的字符(0-9,A-Z)，并转换为整数返回R0
  ADDU R0 R1 R0
  LW R0 R0 0 ;现在R0是字符
  CALL String_HexCharToInt
  RET

Term_A_Command_Insert:   ;向指令表末尾插入一条指令，指令字符串首地址为R0
  SAVE_REG
  ;译码
  MOVE R5 R0
  Term_ASM:
  
  ;判断是否为ADDIU
  STRING TERM_PC_ADDIU "ADDIU"
  MOVE R0 R5  ;R5缓存指令字符串地址
  LOAD_ADDR TERM_PC_ADDIU R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotAddiu
  NOP
    ;处理ADDIU的逻辑
    LI R4 48;最终指令
    ;取出Rx
    MOVE R0 R5
    LI R1 7
    CALL Term_A_Command_Insert_Get1Bit
    ADDU R0 R4 R4
    SLL R4 R4 0
    ;取imm
    MOVE R0 R5
    ADDIU R0 9
    CALL String_ReadHex
	LI R2 FF
	SLL R2 R2 0
	SRL R2 R2 0		;R2为后8位mask
	AND R0 R2
    ADDU R0 R4 R4
    GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotAddiu:
  
  ;判断是否为ADDU
  STRING TERM_PC_ADDU "ADDU"
  MOVE R0 R5  ;R5缓存指令字符串地址
  LOAD_ADDR TERM_PC_ADDU R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotADDU
  NOP
    ;处理ADDU的逻辑
    LI R4 E0;最终指令
    ;取出Rx
    MOVE R0 R5
    LI R1 6
    CALL Term_A_Command_Insert_Get1Bit
    ADDU R0 R4 R4
    SLL R4 R4 0
	;取出Ry
    MOVE R0 R5
    LI R1 9
    CALL Term_A_Command_Insert_Get1Bit
	SLL R0 R0 5
    ADDU R0 R4 R4
	;取出Rz
    MOVE R0 R5
    LI R1 C
    CALL Term_A_Command_Insert_Get1Bit
	SLL R0 R0 2
    ADDU R0 R4 R4
    ;取imm
    LI R0 1
	ADDU R0 R4 R4
	GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotAddu:
  
  ;判断是否为AND
  STRING TERM_PC_AND "AND"
  MOVE R0 R5  ;R5缓存指令字符串地址
  LOAD_ADDR TERM_PC_AND R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotAND
  NOP
    ;处理AND的逻辑
    LI R4 E8;最终指令
    ;取出Rx
    MOVE R0 R5
    LI R1 5
    CALL Term_A_Command_Insert_Get1Bit
    ADDU R0 R4 R4
    SLL R4 R4 0
	;取出Ry
    MOVE R0 R5
    LI R1 8
    CALL Term_A_Command_Insert_Get1Bit
	SLL R0 R0 5
    ADDU R0 R4 R4
    ;取imm
    LI R0 C
	ADDU R0 R4 R4
	GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotAND:
  
  ;判断是否为B
  STRING TERM_PC_B "B"
  MOVE R0 R5
  LOAD_ADDR TERM_PC_B R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotB
  NOP
    ;处理B的逻辑
    LI R4 10;最终指令
	SLL R4 R4 0
    ;取imm
    MOVE R0 R5
    ADDIU R0 2
    CALL String_ReadHex
	LI R2 FF
	SLL R2 R2 5
	SRL R2 R2 5		;R2为后11位mask
	AND R0 R2
    ADDU R0 R4 R4
    GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotB:
  
  ;判断是否为BEQZ
  STRING TERM_PC_BEQZ "BEQZ"
  MOVE R0 R5
  LOAD_ADDR TERM_PC_BEQZ R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotBEQZ
  NOP
    ;处理BEQZ的逻辑
    LI R4 20;最终指令
    ;取出Rx
    MOVE R0 R5
    LI R1 6
    CALL Term_A_Command_Insert_Get1Bit
    ADDU R0 R4 R4
    SLL R4 R4 0
    GOTO Term_A_Command_Insert_Correct
	;取imm
    MOVE R0 R5
    ADDIU R0 8
    CALL String_ReadHex
	LI R2 FF
	SLL R2 R2 0
	SRL R2 R2 0		;R2为后8位mask
	AND R0 R2
    ADDU R0 R4 R4
    GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotBEQZ:
  
  ;判断是否为BNEZ
  STRING TERM_PC_BNEZ "BNEZ"
  MOVE R0 R5
  LOAD_ADDR TERM_PC_BNEZ R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotBNEZ
  NOP
    ;处理BNEZ的逻辑
    LI R4 28;最终指令
    ;取出Rx
    MOVE R0 R5
    LI R1 6
    CALL Term_A_Command_Insert_Get1Bit
    ADDU R0 R4 R4
    SLL R4 R4 0
    GOTO Term_A_Command_Insert_Correct
	;取imm
    MOVE R0 R5
    ADDIU R0 8
    CALL String_ReadHex
	LI R2 FF
	SLL R2 R2 0
	SRL R2 R2 0		;R2为后8位mask
	AND R0 R2
    ADDU R0 R4 R4
    GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotBNEZ:
  
  ;判断是否为BTEQZ
  STRING TERM_PC_BTEQZ "BTEQZ"
  MOVE R0 R5
  LOAD_ADDR TERM_PC_BTEQZ R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotBTEQZ
  NOP
    ;处理BTEQZ的逻辑
    LI R4 60;最终指令
	SLL R4 R4 0
	;取imm
    MOVE R0 R5
    ADDIU R0 6
    CALL String_ReadHex
	LI R2 FF
	SLL R2 R2 0
	SRL R2 R2 0		;R2为后8位mask
	AND R0 R2
    ADDU R0 R4 R4
    GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotBTEQZ:
  
  ;判断是否为BTNEZ
  STRING TERM_PC_BTNEZ "BTNEZ"
  MOVE R0 R5
  LOAD_ADDR TERM_PC_BTNEZ R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotBTNEZ
  NOP
    ;处理BTNEZ的逻辑
    LI R4 61;最终指令
	SLL R4 R4 0
	;取imm
    MOVE R0 R5
    ADDIU R0 6
    CALL String_ReadHex
	LI R2 FF
	SLL R2 R2 0
	SRL R2 R2 0		;R2为后8位mask
	AND R0 R2
    ADDU R0 R4 R4
    GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotBTNEZ:
  
  ;判断是否为CMP
  STRING TERM_PC_CMP "CMP"
  MOVE R0 R5  ;R5缓存指令字符串地址
  LOAD_ADDR TERM_PC_CMP R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotCMP
  NOP
    ;处理CMP的逻辑
    LI R4 E8;最终指令
    ;取出Rx
    MOVE R0 R5
    LI R1 5
    CALL Term_A_Command_Insert_Get1Bit
    ADDU R0 R4 R4
    SLL R4 R4 0
	;取出Ry
    MOVE R0 R5
    LI R1 8
    CALL Term_A_Command_Insert_Get1Bit
	SLL R0 R0 5
    ADDU R0 R4 R4
    ;取imm
    LI R0 A
	ADDU R0 R4 R4
	GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotCMP:
  
  ;判断是否为LI
  STRING TERM_PC_LI "LI"
  MOVE R0 R5
  LOAD_ADDR TERM_PC_LI R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotLI
  NOP
    ;处理LI的逻辑
    LI R4 68;最终指令
    ;取出Rx
    MOVE R0 R5
    LI R1 4
    CALL Term_A_Command_Insert_Get1Bit
    ADDU R0 R4 R4
    SLL R4 R4 0
    ;取imm
    MOVE R0 R5
    ADDIU R0 6
    CALL String_ReadHex
	LI R2 FF
	SLL R2 R2 0
	SRL R2 R2 0		;R2为后8位mask
	AND R0 R2
    ADDU R0 R4 R4
    GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotLI:
  
  ;判断是否为INT
  STRING TERM_PC_INT "INT"
  MOVE R0 R5
  LOAD_ADDR TERM_PC_INT R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotINT
  NOP
    ;处理INT的逻辑
    LI R4 F8;最终指令
	SLL R4 R4 0
    ;取imm
    MOVE R0 R5
    ADDIU R0 4
    CALL String_ReadHex
	LI R2 FF
	SLL R2 R2 0
	SLL R2 R2 4
	SRL R2 R2 0
	SRL R2 R2 4		;R2为后4位mask
	AND R0 R2
    ADDU R0 R4 R4
    GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotINT:
  
  ;判断是否为JR
  STRING TERM_PC_JR "JR"
  MOVE R0 R5
  LOAD_ADDR TERM_PC_JR R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotJR
  NOP
    ;处理JR的逻辑
    LI R4 E8;最终指令
    ;取出Rx
    MOVE R0 R5
    LI R1 4
    CALL Term_A_Command_Insert_Get1Bit
    ADDU R0 R4 R4
    SLL R4 R4 0
    GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotJR:
  
  ;判断是否为LW
  STRING TERM_PC_LW "LW"
  MOVE R0 R5  ;R5缓存指令字符串地址
  LOAD_ADDR TERM_PC_LW R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotLW
  NOP
    ;处理LW的逻辑
    LI R4 98;最终指令
    ;取出Rx
    MOVE R0 R5
    LI R1 4
    CALL Term_A_Command_Insert_Get1Bit
    ADDU R0 R4 R4
    SLL R4 R4 0
	;取出Ry
    MOVE R0 R5
    LI R1 7
    CALL Term_A_Command_Insert_Get1Bit
	SLL R0 R0 5
    ADDU R0 R4 R4
    ;取imm
    MOVE R0 R5
    ADDIU R0 9
    CALL String_ReadHex
	LI R2 FF
	SLL R2 R2 0
	SLL R2 R2 3
	SRL R2 R2 0
	SRL R2 R2 3		;R2为后5位mask
	AND R0 R2
    ADDU R0 R4 R4
    GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotLW:
  
  ;判断是否为LW_SP
  STRING TERM_PC_LW_SP "LW_SP"
  MOVE R0 R5  ;R5缓存指令字符串地址
  LOAD_ADDR TERM_PC_LW_SP R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotLW_SP
  NOP
    ;处理LW_SP的逻辑
    LI R4 90;最终指令
    ;取出Rx
    MOVE R0 R5
    LI R1 8
    CALL Term_A_Command_Insert_Get1Bit
    ADDU R0 R4 R4
    SLL R4 R4 0
    ;取imm
    MOVE R0 R5
    ADDIU R0 10
    CALL String_ReadHex
	LI R2 FF
	SLL R2 R2 0
	SRL R2 R2 0			;R2为后8位mask
	AND R0 R2
    ADDU R0 R4 R4
    GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotLW_SP:
  
  ;判断是否为MOVE
  STRING TERM_PC_MOVE "MOVE"
  MOVE R0 R5  ;R5缓存指令字符串地址
  LOAD_ADDR TERM_PC_MOVE R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotMOVE
  NOP
    ;处理MOVE的逻辑
    LI R4 78;最终指令
    ;取出Rx
    MOVE R0 R5
    LI R1 6
    CALL Term_A_Command_Insert_Get1Bit
    ADDU R0 R4 R4
    SLL R4 R4 0
	;取出Ry
    MOVE R0 R5
    LI R1 9
    CALL Term_A_Command_Insert_Get1Bit
	SLL R0 R0 5
    ADDU R0 R4 R4
    ;取imm
    LI R0 0
	ADDU R0 R4 R4
	GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotMOVE:
  
  ;判断是否为NOP
  STRING TERM_PC_NOP "NOP"
  MOVE R0 R5
  LOAD_ADDR TERM_PC_NOP R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotNOP
  NOP
    ;处理NOP的逻辑
    LI R4 08
    SLL R4 R4 0
    GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotNOP:
  
  ;判断是否为OR
  STRING TERM_PC_OR "OR"
  MOVE R0 R5  ;R5缓存指令字符串地址
  LOAD_ADDR TERM_PC_OR R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotOR
  NOP
    ;处理OR的逻辑
    LI R4 E8;最终指令
    ;取出Rx
    MOVE R0 R5
    LI R1 4
    CALL Term_A_Command_Insert_Get1Bit
    ADDU R0 R4 R4
    SLL R4 R4 0
	;取出Ry
    MOVE R0 R5
    LI R1 7
    CALL Term_A_Command_Insert_Get1Bit
	SLL R0 R0 5
    ADDU R0 R4 R4
    ;取imm
    LI R0 D
	ADDU R0 R4 R4
	GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotOR:
  
  ;判断是否为SLL
  STRING TERM_PC_SLL "SLL"
  MOVE R0 R5  ;R5缓存指令字符串地址
  LOAD_ADDR TERM_PC_SLL R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotSLL
  NOP
    ;处理SLL的逻辑
    LI R4 30;最终指令
    ;取出Rx
    MOVE R0 R5
    LI R1 5
    CALL Term_A_Command_Insert_Get1Bit
    ADDU R0 R4 R4
    SLL R4 R4 0
	;取出Ry
    MOVE R0 R5
    LI R1 8
    CALL Term_A_Command_Insert_Get1Bit
	SLL R0 R0 5
    ADDU R0 R4 R4
    ;取imm
    MOVE R0 R5
    ADDIU R0 10
    CALL String_ReadHex
	LI R2 FF
	SLL R2 R2 0
	SLL R2 R2 5
	SRL R2 R2 0		
	SRL R2 R2 5		;R2为后3位mask
	AND R0 R2
	SLL R0 R0 2
    ADDU R0 R4 R4
    GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotSLL:
  
  ;判断是否为SLT
  STRING TERM_PC_SLT "SLT"
  MOVE R0 R5  ;R5缓存指令字符串地址
  LOAD_ADDR TERM_PC_SLT R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotSLT
  NOP
    ;处理SLT的逻辑
    LI R4 E8;最终指令
    ;取出Rx
    MOVE R0 R5
    LI R1 5
    CALL Term_A_Command_Insert_Get1Bit
    ADDU R0 R4 R4
    SLL R4 R4 0
	;取出Ry
    MOVE R0 R5
    LI R1 8
    CALL Term_A_Command_Insert_Get1Bit
	SLL R0 R0 5
    ADDU R0 R4 R4
    ;取imm
    LI R0 2
    ADDU R0 R4 R4
    GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotSLT:
  
  ;判断是否为SRL
  STRING TERM_PC_SRL "SRL"
  MOVE R0 R5  ;R5缓存指令字符串地址
  LOAD_ADDR TERM_PC_SRL R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotSRL
  NOP
    ;处理SRL的逻辑
    LI R4 30;最终指令
    ;取出Rx
    MOVE R0 R5
    LI R1 5
    CALL Term_A_Command_Insert_Get1Bit
    ADDU R0 R4 R4
    SLL R4 R4 0
	;取出Ry
    MOVE R0 R5
    LI R1 8
    CALL Term_A_Command_Insert_Get1Bit
	SLL R0 R0 5
    ADDU R0 R4 R4
    ;取imm
    MOVE R0 R5
    ADDIU R0 10
    CALL String_ReadHex
	LI R2 FF
	SLL R2 R2 0
	SLL R2 R2 5
	SRL R2 R2 0		
	SRL R2 R2 5		;R2为后3位mask
	AND R0 R2
	SLL R0 R0 2
	ADDIU R0 2
    ADDU R0 R4 R4
    GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotSRL:
  
  ;判断是否为SUBU
  STRING TERM_PC_SUBU "SUBU"
  MOVE R0 R5  ;R5缓存指令字符串地址
  LOAD_ADDR TERM_PC_SUBU R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotSUBU
  NOP
    ;处理SUBU的逻辑
    LI R4 E0;最终指令
    ;取出Rx
    MOVE R0 R5
    LI R1 6
    CALL Term_A_Command_Insert_Get1Bit
    ADDU R0 R4 R4
    SLL R4 R4 0
	;取出Ry
    MOVE R0 R5
    LI R1 9
    CALL Term_A_Command_Insert_Get1Bit
	SLL R0 R0 5
    ADDU R0 R4 R4
	;取出Rz
    MOVE R0 R5
    LI R1 C
    CALL Term_A_Command_Insert_Get1Bit
	SLL R0 R0 2
    ADDU R0 R4 R4
    ;取imm
    LI R0 3
	ADDU R0 R4 R4
	GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotSUBU:
  
  ;判断是否为SW
  STRING TERM_PC_SW "SW"
  MOVE R0 R5  ;R5缓存指令字符串地址
  LOAD_ADDR TERM_PC_SW R1
  CALL STRING_PrefixCMP
  BEQZ R0 Term_Insert_NotSW
  NOP
    ;处理SW的逻辑
    LI R4 D8;最终指令
    ;取出Rx
    MOVE R0 R5
    LI R1 4
    CALL Term_A_Command_Insert_Get1Bit
    ADDU R0 R4 R4
    SLL R4 R4 0
	;取出Ry
    MOVE R0 R5
    LI R1 7
    CALL Term_A_Command_Insert_Get1Bit
	SLL R0 R0 5
    ADDU R0 R4 R4
    ;取imm
    MOVE R0 R5
    ADDIU R0 9
    CALL String_ReadHex
	LI R2 FF
	SLL R2 R2 0
	SLL R2 R2 3
	SRL R2 R2 0
	SRL R2 R2 3		;R2为后5位mask
	AND R0 R2
    ADDU R0 R4 R4
    GOTO Term_A_Command_Insert_Correct
  Term_Insert_NotSW:
  
  ;均不为以上指令，非法
  B Term_A_Command_Insert_Error
  NOP
  Term_A_Command_Insert_Correct:  ;接受正确的指令
    ;现在R4是正确的指令格式
    LOAD_DATA Term_Program_End R5 0 ;R5现在是下一个写指令的地址
    SW R5 R4 0
    ADDIU R5 1
    SAVE_DATA Term_Program_End R5 0 ;R5现在是下一个写指令的地址
    LOAD_REG
    RET
  Term_A_Command_Insert_Error:  ;拒绝错误的指令
    STRING Term_Program_Command_Error "Syntax Error"
    LOAD_ADDR Term_Program_Command_Error R0
    CALL printf
    LOAD_REG
    RET

Term_A_Command:    ;汇编程序
  SAVE_REG
  LOAD_ADDR Term_Program R0
  SAVE_DATA Term_Program_End R0 0
  Term_A_Command_InstLoop:
  ;先打印当前指令地址
  LI R0 5B;'['
  CALL print_char
  LOAD_ADDR Term_Program R0
  LOAD_DATA Term_Program_End R1 0
  SUBU R1 R0 R0
  CALL String_IntToHex
  CALL printf
  LI R0 5D;']'
  CALL print_char
  LI R0 20;' '
  CALL print_char
  LI R0 20;' '
  CALL print_char
  Term_A_Command_Get_Loop:
  CALL KeyBoard_Get
    BEQZ R0 Term_A_Command_Get_Loop
    NOP
    ;判断是否为退格
    LI R6 08
    CMP R0 R6
    BTNEZ Term_A_Command_NoBackSpace
    NOP
      LOAD_DATA KeyBoard_Cache_P R0 0
      LOAD_ADDR KeyBoard_Cache R1
      CMP R0 R1
      BTEQZ Term_A_Command_NoBackSpace;若已经到达最左侧则无视这一操作
      NOP
      CALL last_cursor ;回退一格
      LOAD_DATA CURSOR_X R6 0
      SLL R0 R6 0
      LOAD_DATA CURSOR_Y R6 0
      ADDU R0 R6 R0
      LI R1 20
      CALL VGA_Draw_Block ;清除显示
      LOAD_DATA KeyBoard_Cache_P R0 0
      ADDIU R0 FF
      SAVE_DATA KeyBoard_Cache_P R0 0
      B Term_A_Command_Get_Loop
      NOP
    Term_A_Command_NoBackSpace:
    ;判断是否为回车
    LI R6 0A
    CMP R0 R6
    BTNEZ Term_A_Command_NoEnter
    NOP
      ;是回车,处理回车逻辑
      CALL next_cursor_line
      LOAD_DATA KeyBoard_Cache_P R1 0
      LOAD_ADDR KeyBoard_Cache R2
      CMP R1 R2
      BTEQZ Term_A_Command_RET ;如果输入为空则表示输入结束
      NOP
      ;清空缓存区，补\0
      Load_Data KeyBoard_Cache_P R0 0
      LI R1 0
      SW R0 R1 0
      LOAD_ADDR KeyBoard_Cache R0
      SAVE_DATA KeyBoard_Cache_P R0 0
      CALL Term_A_Command_Insert
      B Term_A_Command_InstLoop
      NOP
    Term_A_Command_NoEnter:
    CALL print_char  ;否则输出该字符
    LOAD_DATA KeyBoard_Cache_P R1 0
    SW R1 R0 0
    ADDIU R1 1
    SAVE_DATA KeyBoard_Cache_P R1 0
    B Term_A_Command_Get_Loop
    NOP
  Term_A_Command_RET:
  LOAD_REG
  RET
  
Term_D_Command:    ;
  RET
  
Term_G_Command:    ;
  SAVE_REG  
  LOAD_DATA Term_RegSave R0 0
  LOAD_DATA Term_RegSave R1 1
  LOAD_DATA Term_RegSave R2 2
  LOAD_DATA Term_RegSave R3 3
  LOAD_DATA Term_RegSave R4 4
  LOAD_DATA Term_RegSave R5 5
  LOAD_ADDR Term_Program R6 0
  SW_SP R7 0
  ADDSP 1
  MFPC R7
  ADDIU R7 3
  JR R6
  NOP
  SAVE_DATA Term_RegSave R0 0
  SAVE_DATA Term_RegSave R1 1
  SAVE_DATA Term_RegSave R2 2
  SAVE_DATA Term_RegSave R3 3
  SAVE_DATA Term_RegSave R4 4
  SAVE_DATA Term_RegSave R5 5
  ADDSP FF
  LW_SP R7 0
  LOAD_REG
  RET  
  
Term_UASM:         ;反汇编R0指令，并输出一行
  SAVE_REG
  SRL R1 R0 0
  SRL R1 R1 3      ;R1为R0前5位
  SRL R4 R0 0      ;R4为R0前8位
  SLL R5 R0 0
  SLL R5 R5 3
  SRL R5 R5 0
  SRL R5 R5 3		;R5为R0后5位
  MOVE R3 R0
  
  LI R2 9	;ADDIU 
  XOR R2 R1
  BNEZ R2 Term_UASM_ADDIU_END
  NOP
  STRING Term_UASM_ADDIU_String "ADDIU "
  LOAD_ADDR Term_UASM_ADDIU_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rximm
  GOTO Term_UASM_RET
  Term_UASM_ADDIU_END:
  
  LI R2 0	;ADDSP3 
  XOR R2 R1
  BNEZ R2 Term_UASM_ADDSP3_END
  NOP
  STRING Term_UASM_ADDSP3_String "ADDSP3 "
  LOAD_ADDR Term_UASM_ADDSP3_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rximm
  GOTO Term_UASM_RET
  Term_UASM_ADDSP3_END:
  
  LI R2 63	;ADDSP
  XOR R2 R4
  BNEZ R2 Term_UASM_ADDSP_END
  NOP
  STRING Term_UASM_ADDSP_String "ADDSP "
  LOAD_ADDR Term_UASM_ADDSP_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_imm
  GOTO Term_UASM_RET
  Term_UASM_ADDSP_END:
  
  LI R2 1C	;ADDU
  XOR R2 R1
  BNEZ R2 Term_UASM_ADDU_END
  NOP
  LI R2 1
  MOVE R6 R3
  SLL R6 R6 0
  SLL R6 R6 6
  SRL R6 R6 0
  SRL R6 R6 6
  XOR R2 R6
  BNEZ R2 Term_UASM_ADDU_END
  NOP
  STRING Term_UASM_ADDU_String "ADDU "
  LOAD_ADDR Term_UASM_ADDU_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rxryrz
  GOTO Term_UASM_RET
  Term_UASM_ADDU_END:
  
  LI R2 1D	;AND
  XOR R2 R1
  BNEZ R2 Term_UASM_AND_END
  NOP
  STRING Term_UASM_AND_String "AND "
  LOAD_ADDR Term_UASM_AND_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rxry
  GOTO Term_UASM_RET
  Term_UASM_AND_END:
  
  LI R2 2	;B
  XOR R2 R1
  BNEZ R2 Term_UASM_B_END
  NOP
  STRING Term_UASM_B_String "B "
  LOAD_ADDR Term_UASM_B_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_imm
  GOTO Term_UASM_RET
  Term_UASM_B_END:
  
  LI R2 4	;BEQZ
  XOR R2 R1
  BNEZ R2 Term_UASM_BEQZ_END
  NOP
  STRING Term_UASM_BEQZ_String "BEQZ "
  LOAD_ADDR Term_UASM_BEQZ_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rximm
  GOTO Term_UASM_RET
  Term_UASM_BEQZ_END:
  
  LI R2 5	;BNEZ
  XOR R2 R1
  BNEZ R2 Term_UASM_BNEZ_END
  NOP
  STRING Term_UASM_BNEZ_String "BNEZ "
  LOAD_ADDR Term_UASM_BNEZ_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rximm
  GOTO Term_UASM_RET
  Term_UASM_BNEZ_END:
  
  LI R2 60	;BTEQZ
  XOR R2 R4
  BNEZ R2 Term_UASM_BTEQZ_END
  NOP
  STRING Term_UASM_BTEQZ_String "BTEQZ "
  LOAD_ADDR Term_UASM_BTEQZ_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_imm
  GOTO Term_UASM_RET
  Term_UASM_BTEQZ_END:
  
  LI R2 61	;BTNEZ
  XOR R2 R4
  BNEZ R2 Term_UASM_BTNEZ_END
  NOP
  STRING Term_UASM_BTNEZ_String "BTNEZ "
  LOAD_ADDR Term_UASM_BTNEZ_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_imm
  GOTO Term_UASM_RET
  Term_UASM_BTNEZ_END:
  
  LI R2 1D	;CMP
  XOR R2 R1
  BNEZ R2 Term_UASM_CMP_END
  NOP
  LI R2 A
  XOR R2 R5
  BNEZ R2 Term_UASM_CMP_END
  NOP
  STRING Term_UASM_CMP_String "CMP "
  LOAD_ADDR Term_UASM_CMP_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rxry
  GOTO Term_UASM_RET
  Term_UASM_CMP_END:
  
  LI R2 F8	;INT
  XOR R2 R4
  BNEZ R2 Term_UASM_INT_END
  NOP
  LI R2 0
  XOR R2 R5
  BNEZ R2 Term_UASM_INT_END
  NOP
  STRING Term_UASM_INT_String "INT "
  LOAD_ADDR Term_UASM_INT_String R0
  CALL printf
  MOVE R0 R3
  SLL R0 R0 0
  SLL R0 R0 4
  SRL R0 R0 4
  SRL R0 R0 0
  ADDIU R0 30
  CALL print_char
  GOTO Term_UASM_RET
  Term_UASM_INT_END:
  
  LI R2 1D	;JR
  XOR R2 R1
  BNEZ R2 Term_UASM_JR_END
  NOP
  LI R2 0
  XOR R2 R5
  BNEZ R2 Term_UASM_JR_END
  NOP
  STRING Term_UASM_JR_String "JR "
  LOAD_ADDR Term_UASM_JR_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rx
  GOTO Term_UASM_RET
  Term_UASM_JR_END:
  
  LI R2 D	;LI
  XOR R2 R1
  BNEZ R2 Term_UASM_LI_END
  NOP
  STRING Term_UASM_LI_String "LI "
  LOAD_ADDR Term_UASM_LI_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rximm
  GOTO Term_UASM_RET
  Term_UASM_LI_END:
  
  LI R2 13	;LW
  XOR R2 R1
  BNEZ R2 Term_UASM_LW_END
  NOP
  STRING Term_UASM_LW_String "LW "
  LOAD_ADDR Term_UASM_LW_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rximm
  GOTO Term_UASM_RET
  Term_UASM_LW_END:
  
  LI R2 12	;LW_SP
  XOR R2 R1
  BNEZ R2 Term_UASM_LW_SP_END
  NOP
  STRING Term_UASM_LW_SP_String "LW_SP "
  LOAD_ADDR Term_UASM_LW_SP_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rximm
  GOTO Term_UASM_RET
  Term_UASM_LW_SP_END:
  
  LI R2 F	;MOVE
  XOR R2 R1
  BNEZ R2 Term_UASM_MOVE_END
  NOP
  STRING Term_UASM_MOVE_String "MOVE "
  LOAD_ADDR Term_UASM_MOVE_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rxry
  GOTO Term_UASM_RET
  Term_UASM_MOVE_END:
  
  LI R2 08	;NOP
  SLL R2 R2 0
  XOR R2 R3
  BNEZ R2 Term_UASM_NOP_END
  NOP
  STRING Term_UASM_NOP_String "NOP "
  LOAD_ADDR Term_UASM_NOP_String R0
  CALL printf
  GOTO Term_UASM_RET
  Term_UASM_NOP_END:
  
  LI R2 6	;SLL
  XOR R2 R1
  BNEZ R2 Term_UASM_SLL_END
  NOP
  LI R2 0
  MOVE R6 R3
  SLL R6 R6 0
  SLL R6 R6 6
  SRL R6 R6 0
  SRL R6 R6 6
  XOR R2 R6
  BNEZ R2 Term_UASM_SLL_END
  NOP
  STRING Term_UASM_SLL_String "SLL "
  LOAD_ADDR Term_UASM_SLL_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rxryimm
  GOTO Term_UASM_RET
  Term_UASM_SLL_END:
  
  LI R2 1D	;SLT
  XOR R2 R1
  BNEZ R2 Term_UASM_SLT_END
  NOP
  LI R2 2
  XOR R2 R5
  BNEZ R2 Term_UASM_SLT_END
  NOP
  STRING Term_UASM_SLT_String "SLT "
  LOAD_ADDR Term_UASM_SLT_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rxry
  GOTO Term_UASM_RET
  Term_UASM_SLT_END:
  
  LI R2 6	;SRL
  XOR R2 R1
  BNEZ R2 Term_UASM_SRL_END
  NOP
  LI R2 2
  MOVE R6 R3
  SLL R6 R6 0
  SLL R6 R6 6
  SRL R6 R6 0
  SRL R6 R6 6
  XOR R2 R6
  BNEZ R2 Term_UASM_SRL_END
  NOP
  STRING Term_UASM_SRL_String "SRL "
  LOAD_ADDR Term_UASM_SRL_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rxryimm
  GOTO Term_UASM_RET
  Term_UASM_SRL_END:
  
  LI R2 1C	;SUBU
  XOR R2 R1
  BNEZ R2 Term_UASM_SUBU_END
  NOP
  LI R2 3
  MOVE R6 R3
  SLL R6 R6 0
  SLL R6 R6 6
  SRL R6 R6 0
  SRL R6 R6 6
  XOR R2 R6
  BNEZ R2 Term_UASM_SUBU_END
  NOP
  STRING Term_UASM_SUBU_String "SUBU "
  LOAD_ADDR Term_UASM_SUBU_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rxryrz
  GOTO Term_UASM_RET
  Term_UASM_SUBU_END:
  
  LI R2 1B	;SW
  XOR R2 R1
  BNEZ R2 Term_UASM_SW_END
  NOP
  STRING Term_UASM_SW_String "SW "
  LOAD_ADDR Term_UASM_SW_String R0
  CALL printf
  MOVE R0 R3
  CALL Term_UASM_Decode_rxryimm
  GOTO Term_UASM_RET
  Term_UASM_SW_END:
  
  STRING Term_UASM_Unknown "--- Unknown ---"
  LOAD_ADDR Term_UASM_Unknown R0
  CALL printf
  
  Term_UASM_RET:
	  LOAD_REG
	  RET

Term_U_Command:    ;
  SAVE_REG
  LOAD_ADDR Term_Program R4;R4是内存地址循环变量
  LOAD_DATA Term_Program_End R5 0 ;R5是目标地址
  Term_U_Command_Loop:
    ;如果已经到达指令列表末尾则return
    CMP R4 R5
    BTNEZ Term_U_Command_NotRET
    NOP
    GOTO Term_U_Command_RET
    Term_U_Command_NotRET:
    ;先打印当前指令地址
    LI R0 5B;'['
    CALL print_char
    LOAD_ADDR Term_Program R0
    SUBU R4 R0 R0
    CALL String_IntToHex
    CALL printf
    LI R0 5D;']'
    CALL print_char
    LW R4 R0 0 ;将指令写到R0
    STRING Term_U_Command_Left_String "      <"
    LOAD_ADDR Term_U_Command_Left_String R0
    CALL printf
    LW R4 R0 0 ;将指令写到R0
    CALL print_int
    STRING Term_U_Command_Right_String ">    "
    LOAD_ADDR Term_U_Command_Right_String R0
    CALL printf
    LW R4 R0 0 ;将指令写到R0
    CALL Term_UASM  ;反汇编
    CALL next_cursor_line
    ADDIU R4 1
    GOTO Term_U_Command_Loop
  Term_U_Command_RET:
  CALL next_cursor_line
  LOAD_REG
  RET
  
Term_UASM_Decode_rxryrz:		;解码op rx ry rz类指令后半，指令内容在R0
  SAVE_REG
  MOVE R1 R0
  
  LI R0 52	;R
  CALL print_char
  MOVE R0 R1
  SLL R0 R0 5
  SRL R0 R0 0
  SRL R0 R0 5
  ADDIU R0 30
  CALL print_char 
  LI R0 20
  CALL print_char
  MOVE R0 R1
  
  LI R0 52	;R
  CALL print_char
  MOVE R0 R1
  SLL R0 R0 0
  SRL R0 R0 0
  SRL R0 R0 5
  ADDIU R0 30
  CALL print_char 
  LI R0 20
  CALL print_char
  MOVE R0 R1
  
  LI R0 52	;R
  CALL print_char
  MOVE R0 R1
  SLL R0 R0 3
  SLL R0 R0 0
  SRL R0 R0 0
  SRL R0 R0 5
  ADDIU R0 30
  CALL print_char 
  
  LOAD_REG
  RET  
  
Term_UASM_Decode_rxry:		;解码op rx ry类指令后半，指令内容在R0
  SAVE_REG
  MOVE R1 R0
  
  LI R0 52	;R
  CALL print_char
  MOVE R0 R1
  SLL R0 R0 5
  SRL R0 R0 0
  SRL R0 R0 5
  ADDIU R0 30
  CALL print_char 
  LI R0 20
  CALL print_char
  MOVE R0 R1
  
  LI R0 52	;R
  CALL print_char
  MOVE R0 R1
  SLL R0 R0 0
  SRL R0 R0 0
  SRL R0 R0 5
  ADDIU R0 30
  CALL print_char 

  LOAD_REG
  RET  
  
Term_UASM_Decode_rxryimm:		;解码op rx ry imm类指令后半，指令内容在R0
  SAVE_REG
  MOVE R1 R0
  
  LI R0 52	;R
  CALL print_char
  MOVE R0 R1
  SLL R0 R0 5
  SRL R0 R0 0
  SRL R0 R0 5
  ADDIU R0 30
  CALL print_char 
  LI R0 20
  CALL print_char
  MOVE R0 R1
  
  LI R0 52	;R
  CALL print_char
  MOVE R0 R1
  SLL R0 R0 0
  SRL R0 R0 0
  SRL R0 R0 5
  ADDIU R0 30
  CALL print_char 
  LI R0 20
  CALL print_char
  MOVE R0 R1
  
  SRL R0 R0 2
  SLL R0 R0 0
  SLL R0 R0 5
  SRL R0 R0 0
  SRL R0 R0 5
  CALL String_8IntToHex
  CALL printf
  LOAD_REG
  RET    
  
Term_UASM_Decode_rx:		;解码op rx 类指令后半，指令内容在R0
  SAVE_REG
  MOVE R1 R0
  LI R0 52	;R
  CALL print_char
  MOVE R0 R1
  SLL R0 R0 5
  SRL R0 R0 0
  SRL R0 R0 5
  ADDIU R0 30
  CALL print_char 
  LOAD_REG
  RET  
  
Term_UASM_Decode_rximm:		;解码op rx imm类指令后半，指令内容在R0
  SAVE_REG
  MOVE R1 R0
  LI R0 52	;R
  CALL print_char
  MOVE R0 R1
  SLL R0 R0 5
  SRL R0 R0 0
  SRL R0 R0 5
  ADDIU R0 30
  CALL print_char 
  LI R0 20
  CALL print_char
  MOVE R0 R1
  CALL String_8IntToHex
  CALL printf
  LOAD_REG
  RET
  
Term_UASM_Decode_imm:		;解码rx imm类指令后半，指令内容在R0
  SAVE_REG
  CALL String_8IntToHex
  CALL printf
  LOAD_REG
  RET