;----------------------------------------------------------------����һ�����Ժ�����---------------------------------------------------------------

Debug_print_reg:    ;��ӡ�Ĵ���
  SAVE_REG
  CALL String_IntToHex
  CALL printf
  LI R0 20
  CALL print_char
  
  MOVE R0 R1
  CALL String_IntToHex
  CALL printf
  LI R0 20
  CALL print_char
  
  MOVE R0 R2
  CALL String_IntToHex
  CALL printf
  LI R0 20
  CALL print_char
  
  MOVE R0 R3
  CALL String_IntToHex
  CALL printf
  LI R0 20
  CALL print_char
  
  MOVE R0 R4
  CALL String_IntToHex
  CALL printf
  LI R0 20
  CALL print_char
  
  MOVE R0 R5
  CALL String_IntToHex
  CALL printf
  LI R0 20
  CALL print_char
  
  MOVE R0 R6
  CALL String_IntToHex
  CALL printf
  LI R0 20
  CALL print_char
  
  MOVE R0 R7
  CALL String_IntToHex
  CALL printf
  LI R0 20
  CALL print_char
  CALL next_cursor_line
  
  LOAD_REG
  RET