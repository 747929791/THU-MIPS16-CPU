;！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！决扮匂！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
Delay_10W:
  SAVE_REG
  LI R5 C3
  SLL R5 R5 0
  ADDIU R5 40   ;R5=49984
  Delay_L1:
    BNEZ R5 Delay_L1
    ADDIU R5 FF
  LOAD_REG
  RET
  
Delay_20W:
  CALL Delay_10W
  CALL Delay_10W
  RET
  
Delay_50W:
  CALL Delay_10W
  CALL Delay_10W
  CALL Delay_10W
  CALL Delay_10W
  CALL Delay_10W
  RET
  
Delay_100W:
  CALL Delay_50W
  CALL Delay_50W
  RET
  
Delay_200W:
  CALL Delay_100W
  CALL Delay_100W
  RET