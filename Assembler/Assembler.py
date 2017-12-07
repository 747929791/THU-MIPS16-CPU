#coding = utf-8
import re
import sys
"""
Moon汇编器，将扩展MIPS16语言转化为基本MIPS16语言
调用方式 "python Assembler.py input1.s input2.s -o build"，将从input1.s/input2.s中读入，联合编译输出汇编到build_o.s，输出二进制文件到build_o.bin
全部按大写字符处理，";"后的全是注释
R6被使用为临时寄存器，R7被使用为返回地址寄存器
新增语法特性：
DEFINE X Y  => 替换X为Y
DATA X LEN => 定义BSS数据段符号X，长度Len个Word，默认1个word
INT X A   => 定义数据段符号X，1字，初值为A
STRING X "S" =>定义数据段符号X，长度为|S|+1(\0结尾字符串)，初值为字符串S
X:        => 定义符号地址
GOTO X    =>   JR方法指令跳转
CALL X    =>    SW_RS
RET       =>    JR R7, NOP
LOAD_DATA X R offset(=0) => 从全局地址段读入寄存器
SAVE_DATA X R offset(=0) => 将寄存器存入全局地址段
LOAD_ADDR X R =>将全局地址段X地址写入寄存器R
SAVE_REG  =>  缓存所有寄存器到堆栈
LOAD_REG  =>  从堆栈读取所有寄存器(务必与SAVE_REG成对使用)
全部的B类指令支持符号地址跳转(慎用立即数)
"""

"""
算法流程：
1、替换DEFINE
2、展开语句计算符号地址，并展开中间代码(位置地址占位符为"SigAddr(X)")
3、展开语句
"""
EnhancedMode=True  #当该开关打开时将尽力优化由于硬件和官方软件的F9/FA错误，但会降低运行代码的时间

statement_addr="4000"
bss_addr="8000" #DATA段起始地址
define=dict()
sig_addr=dict() #符号地址，0起始
string_map=dict() #静态符号->字符串内容映射(用于支持STRING指令)

#对于所有的HI LOW操作，由于LOW是符号扩展加法，故HI在计算时有时要加一
statement=dict()
if(EnhancedMode==False):
    statement["GOTO"]=[
      "LI R6 HI",
      "SLL R6 R6 0",
      "ADDIU R6 LOW",
      "JR R6",
      "NOP"
    ]
    statement["CALL"]=[
      "SW_SP R7 0",
      "ADDSP 1",
      "LI R6 HI",
      "SLL R6 R6 0",
      "ADDIU R6 LOW",
      "MFPC R7",
      "ADDIU R7 3",
      "JR R6",
      "NOP",
      "ADDSP FF",
      "LW_SP R7 0"
    ]
    statement["RET"]=[
      "JR R7",
      "NOP"
    ]
    statement["LOAD_DATA"]=[
      "LI R6 HI",
      "SLL R6 R6 0",
      "ADDIU R6 LOW",
      "LW R6 REG IMM"
    ]
    statement["SAVE_DATA"]=[
      "LI R6 HI",
      "SLL R6 R6 0",
      "ADDIU R6 LOW",
      "SW R6 REG IMM"
    ]
    statement["LOAD_ADDR"]=[
      "LI REG HI",
      "SLL REG REG 0",
      "ADDIU REG LOW",
    ]
    statement["B"]=[
      "B OFFSET11"
    ]
    statement["BEQZ"]=[
      "BEQZ REG OFFSET8"
    ]
    statement["BNEZ"]=[
      "BNEZ REG OFFSET8"
    ]
    statement["BTEQZ"]=[
      "BTEQZ OFFSET8"
    ]
    statement["BTNEZ"]=[
      "BTNEZ OFFSET8"
    ]
    statement["SAVE_REG"]=[
      "SW_SP R0 0",
      "SW_SP R1 1",
      "SW_SP R2 2",
      "SW_SP R3 3",
      "SW_SP R4 4",
      "SW_SP R5 5",
      "SW_SP R6 6",
      "SW_SP R7 7",
      "ADDSP 8"
    ]
    statement["LOAD_REG"]=[
      "ADDSP F8",
      "LW_SP R0 0",
      "LW_SP R1 1",
      "LW_SP R2 2",
      "LW_SP R3 3",
      "LW_SP R4 4",
      "LW_SP R5 5",
      "LW_SP R6 6",
      "LW_SP R7 7"
    ]
else:
    statement["GOTO"]=[
      "LI R6 HI",
      "SLL R6 R6 0",
      "ADDIU R6 LOW1",
      "ADDIU R6 LOW2",
      "JR R6",
      "NOP"
    ]
    statement["CALL"]=[
      "SW_SP R7 0",
      "ADDSP 1",
      "LI R6 HI",
      "SLL R6 R6 0",
      "ADDIU R6 LOW1",
      "ADDIU R6 LOW2",
      "MFPC R7",
      "ADDIU R7 3",
      "JR R6",
      "NOP",
      "ADDSP FF",
      "LW_SP R7 0"
    ]
    statement["RET"]=[
      "JR R7",
      "NOP"
    ]
    statement["LOAD_DATA"]=[
      "LI R6 HI",
      "SLL R6 R6 0",
      "ADDIU R6 LOW1",
      "ADDIU R6 LOW2",
      "LW R6 REG IMM"
    ]
    statement["SAVE_DATA"]=[
      "LI R6 HI",
      "SLL R6 R6 0",
      "ADDIU R6 LOW1",
      "ADDIU R6 LOW2",
      "SW R6 REG IMM"
    ]
    statement["LOAD_ADDR"]=[
      "LI REG HI",
      "SLL REG REG 0",
      "ADDIU REG LOW1",
      "ADDIU REG LOW2",
    ]
    statement["B"]=[
      "B OFFSET11"
    ]
    statement["BEQZ"]=[
      "BEQZ REG OFFSET8"
    ]
    statement["BNEZ"]=[
      "BNEZ REG OFFSET8"
    ]
    statement["BTEQZ"]=[
      "BTEQZ OFFSET8"
    ]
    statement["BTNEZ"]=[
      "BTNEZ OFFSET8"
    ]
    statement["SAVE_REG"]=[
      "SW_SP R0 0",
      "SW_SP R1 1",
      "SW_SP R2 2",
      "SW_SP R3 3",
      "SW_SP R4 4",
      "SW_SP R5 5",
      "SW_SP R6 6",
      "SW_SP R7 7",
      "ADDSP 8"
    ]
    statement["LOAD_REG"]=[
      "ADDSP F8",
      "LW_SP R0 0",
      "LW_SP R1 1",
      "LW_SP R2 2",
      "LW_SP R3 3",
      "LW_SP R4 4",
      "LW_SP R5 5",
      "LW_SP R6 6",
      "LW_SP R7 7"
    ]


#去除冗余字符，注释
def pretreatment(text):
  text=text.replace("\t","    ")
  ret=[]
  for line in text.split('\n'):   #保护引号内的内容不被改变
    s1=line #引号前的内容
    s2="" #引号内的内容
    if(line.replace(" ","")[:6].upper()=="STRING"):
      b=line.split('\"')
      if(len(b)==1):
        #无引号
        s1=b[0]
      elif(len(b)==2):
        print("Error in pretreatment! Syntax Error.",line)
      else:
        s1=b[0]
        s2="\""+"\"".join(b[1:-1])+"\""
    s1=s1.split(";")[0]
    p = re.compile(r' +');s1=p.sub(" ",s1)
    ret.append(s1.upper()+s2)
  text="\n".join(ret)
  p = re.compile(r'\n ');text=p.sub("\n",text)
  p = re.compile(r' \n');text=p.sub("\n",text)
  p = re.compile(r'\n+');text=p.sub("\n",text)
  if(text[0]=="\n"):
    text=text[1:]
  if(text[-1]=="\n"):
    text=text[:-1]
  return text

#处理宏定义
def parseDefine(text):
  for line in text.split('\n'):
    b=line.split(' ')
    if(b[0]=="DEFINE"):
      text=text.replace(b[1]+" ",b[2]+" ")
      text=text.replace(b[1]+"\n",b[2]+"\n")
  text="\n".join([i for i in text.split('\n') if i.split(' ')[0]!="DEFINE"])
  return text

#计算符号地址，生成System_init程序(用于填充初始化数据，在全部程序段的最后)
def parseSigAddr(text):
  ret=[]
  addr=0
  bss_addr=0
  for line in text.split('\n'):
    b=line.split("\"")[0].split(':')
    if(len(b)>1):
      if(b[0] in sig_addr):
        print("ERROR! SIG_ADDR:"+b[0]+" already exist!")
      sig_addr[b[0]]=addr
    else:
      b=line.split(' ')
      if(b[0]=="DATA"):
        l=int(b[2])
        if(b[1] in sig_addr):
          print("WARNING! DATA_ADDR:"+b[1]+" already exist!")
        sig_addr[b[1]]=bss_addr
        bss_addr+=l
      elif(b[0]=="STRING"):
        sig=b[1]
        s=line.split("\"")[-2]+"\0"
        if(len(line.split("\""))!=3):
            print("ERROR! STRING is illegal : ",line)
        l=len(s)
        if(l==1):
            print("ERROR! STRING is empty : ",line)
        if(sig in sig_addr):
          print("WARNING! STRING_ADDR:"+sig+" already exist!")
        sig_addr[sig]=bss_addr
        bss_addr+=l
        string_map[sig]=s
      else:
        if(b[0] in statement):
          addr+=len(statement[b[0]])
          ret+=statement[b[0]]
        else:
          addr+=1
          ret.append(line)
  #生成system_init程序地址
  if("SYSTEM_INIT" in sig_addr):
    print("ERROR! SYSTEM_INIT already exist!")
  sig_addr["SYSTEM_INIT"]=addr

#16进制补码，产生n个二进制位，符号扩展
def ToHex(x,n):
  if(x<0):
    x=2**n+x
  b=bin(x)[2:]
  if(len(b)>n):
    print("ToHex ERROR x="+str(x)+" n="+str(n))
  return hex(x)[2:].upper()

#最终代码生成
def parseFinal(text):
  ret=[]
  addr=0
  #在程序末尾附加产生boot程序段
  ret.append("SAVE_REG")
  for sig,s in string_map.items():
    ret.append("LOAD_ADDR "+sig+" R0")
    for c in s:
        hex_c=hex(ord(c))[2:].upper()
        if(len(hex_c)>2):
            print("ERROR! String mapping :",sig,s,c)
        while(len(hex_c)<2):
            hex_c="0"+hex_c
        ret.append("LI R1 "+hex_c)
        ret.append("SW R0 R1 0")
        ret.append("ADDIU R0 1")
  ret.append("LOAD_REG")
  ret.append("RET")
  text=text+"\n"+"\n".join(ret)
  ret=[]
  for line in text.split('\n'):
    #print(line)
    b=line.split(':')
    if(len(b)>1):
      pass
    else:
      b=line.split(' ')
      if(b[0]=="DATA"):
        pass
      elif(b[0]=="STRING"):
        pass
      else:
        if(b[0] in statement):
          X="0000" #符号地址
          REG="R0" #寄存器 
          IMM="" #LOAD,SAVE16位立即数
          OFFSET=0 #B指令偏移
          OFFSET11=""
          OFFSET8=""
          if(b[0]=="GOTO" or b[0]=="CALL" or b[0]=="LOAD_DATA" or b[0]=="SAVE_DATA" or b[0]=="LOAD_ADDR"):
            if(b[0]=="GOTO" or b[0]=="CALL"):
              X=int(str(sig_addr[b[1]]),10)+int(statement_addr,16)
            elif(b[0]=="LOAD_DATA" or b[0]=="SAVE_DATA" or b[0]=="LOAD_ADDR"):
              X=int(str(sig_addr[b[1]]),10)+int(bss_addr,16)
            if((X//(2**7))%2==1):#对符号加法的扩展
              X+=2**8
            X=hex(X)[2:][-4:]
            while(len(X)<4):
              X="0"+X
          if(b[0]=="LOAD_DATA" or b[0]=="SAVE_DATA" or b[0]=="LOAD_ADDR"):
            REG=b[2]
          if(b[0]=="LOAD_DATA" or b[0]=="SAVE_DATA"):
            IMM=b[3]
          if(b[0]=="B" or b[0]=="BEQZ" or b[0]=="BNEZ" or b[0]=="BTEQZ" or b[0]=="BTNEZ"):
            REG=b[1]
            if(b[0]=="B" or b[0]=="BTEQZ" or b[0]=="BTNEZ"):
              IMM=b[1]
            else:
              IMM=b[2]
            if(IMM in sig_addr):
              OFFSET=sig_addr[IMM]-addr-1
            else:
              OFFSET=int(IMM,16)
            OFFSET11=ToHex(OFFSET,11)
            OFFSET8=ToHex(OFFSET,8)
          addr+=len(statement[b[0]])
          if(EnhancedMode):
            ret+=("\n".join(statement[b[0]])).replace(" HI"," "+X[0:2]).replace(" LOW1"," "+X[2:3]+"0").replace(" LOW2"," 0"+X[3:4]).replace(" REG"," "+REG).replace(" IMM"," "+IMM).replace(" OFFSET8"," "+OFFSET8).replace(" OFFSET11"," "+OFFSET11).split('\n')
          else:
            ret+=("\n".join(statement[b[0]])).replace(" HI"," "+X[0:2]).replace(" LOW"," "+X[2:4]).replace(" REG"," "+REG).replace(" IMM"," "+IMM).replace(" OFFSET8"," "+OFFSET8).replace(" OFFSET11"," "+OFFSET11).split('\n')
        else:
          addr+=1
          ret.append(line)
  return ("\n".join(ret)).upper()

def Assemble(text):   #由行隔开的标准MIPS16汇编语言汇编为二进制文件格式bytes
  binFormat=dict()   #产生的二进制代码格式
  mipsFormat=dict()  #语句对应格式
  s="ADDIU";binFormat[s]="01001rximm8";mipsFormat[s]=["rx","imm8"]
  s="ADDIU3";binFormat[s]="01000rxry0imm4";mipsFormat[s]=["rx",'ry',"imm4"]
  s="ADDSP3";binFormat[s]="00000rximm8";mipsFormat[s]=["rx","imm8"]
  s="ADDSP";binFormat[s]="01100011imm8";mipsFormat[s]=["imm8"]
  s="ADDU";binFormat[s]="11100rxryrz01";mipsFormat[s]=["rx","ry","rz"]
  s="AND";binFormat[s]="11101rxry01100";mipsFormat[s]=["rx","ry"]
  s="B";binFormat[s]="00010imm11";mipsFormat[s]=["imm11"]
  s="BEQZ";binFormat[s]="00100rximm8";mipsFormat[s]=["rx","imm8"]
  s="BNEZ";binFormat[s]="00101rximm8";mipsFormat[s]=["rx","imm8"]
  s="BTEQZ";binFormat[s]="01100000imm8";mipsFormat[s]=["imm8"]
  s="BTNEZ";binFormat[s]="01100001imm8";mipsFormat[s]=["imm8"]
  s="CMP";binFormat[s]="11101rxry01010";mipsFormat[s]=["rx","ry"]
  s="CMPI";binFormat[s]="01110rximm8";mipsFormat[s]=["rx","imm8"]
  s="INT";binFormat[s]="111110000000imm4";mipsFormat[s]=["imm4"]
  s="JR";binFormat[s]="11101rx00000000";mipsFormat[s]=["rx"]
  s="JRRA";binFormat[s]="1110100000100000";mipsFormat[s]=[]
  s="LI";binFormat[s]="01101rximm8";mipsFormat[s]=["rx","imm8"]
  s="LW";binFormat[s]="10011rxryimm5";mipsFormat[s]=["rx","ry","imm5"]
  s="LW_SP";binFormat[s]="10010rximm8";mipsFormat[s]=["rx","imm8"]
  s="MFIH";binFormat[s]="11110rx00000000";mipsFormat[s]=["rx"]
  s="MFPC";binFormat[s]="11101rx01000000";mipsFormat[s]=["rx"]
  s="MOVE";binFormat[s]="01111rxry00000";mipsFormat[s]=["rx","ry"]
  s="MTIH";binFormat[s]="11110rx00000001";mipsFormat[s]=["rx"]
  s="MTSP";binFormat[s]="01100100rx00000";mipsFormat[s]=["rx"]
  s="NEG";binFormat[s]="11101rxry01011";mipsFormat[s]=["rx","ry"]
  s="NOT";binFormat[s]="11101rxry01111";mipsFormat[s]=["rx","ry"]
  s="NOP";binFormat[s]="0000100000000000";mipsFormat[s]=[]
  s="OR";binFormat[s]="11101rxry01101";mipsFormat[s]=["rx","ry"]
  s="SLL";binFormat[s]="00110rxryimm300";mipsFormat[s]=["rx","ry","imm3"]
  s="SLLV";binFormat[s]="11101rxry00100";mipsFormat[s]=["rx","ry"]
  s="SLT";binFormat[s]="11101rxry00010";mipsFormat[s]=["rx","ry"]
  s="SLTI";binFormat[s]="01010rximm8";mipsFormat[s]=["rx","imm8"]
  s="SLTU";binFormat[s]="11101rxry00011";mipsFormat[s]=["rx","ry"]
  s="SLTUI";binFormat[s]="01011rximm8";mipsFormat[s]=["rx","imm8"]
  s="SRA";binFormat[s]="00110rxryimm311";mipsFormat[s]=["rx","ry","imm3"]
  s="SRAV";binFormat[s]="11101rxry00111";mipsFormat[s]=["rx","ry"]
  s="SRL";binFormat[s]="00110rxryimm310";mipsFormat[s]=["rx","ry","imm3"]
  s="SRLV";binFormat[s]="11101rxry00110";mipsFormat[s]=["rx","ry"]
  s="SUBU";binFormat[s]="11100rxryrz11";mipsFormat[s]=["rx","ry","rz"]
  s="SW";binFormat[s]="11011rxryimm5";mipsFormat[s]=["rx",'ry',"imm5"]
  s="SW_RS";binFormat[s]="01100010imm8";mipsFormat[s]=["imm8"]
  s="SW_SP";binFormat[s]="11010rximm8";mipsFormat[s]=["rx","imm8"]
  s="XOR";binFormat[s]="11101rxry01110";mipsFormat[s]=["rx","ry"]
  bit_init_array=[]
  sysError=False
  for line in text.split('\n'):
    #print(line)
    argv=line.split(' ')
    if(sysError==False and argv[0] not in binFormat):
      print("syn error, simbol not found! "+line)
      sysError=True
      break
    if(sysError==False and len(argv)!=len(mipsFormat[argv[0]])+1):
      print("syn error, arg number is wrong! "+line)
      sysError=True
    #转换为16位2进制字符串
    if(sysError==False):
      simbol_list=mipsFormat[argv[0]]
      bit_inst=binFormat[argv[0]]
      for i in range(len(simbol_list)):
        simbol=simbol_list[i]
        arg=argv[i+1]
        if(simbol.lower()[0]=='r'):    #寄存器操作数
          if(arg.lower()[0]!='r'):
            print("syn error, need R arg! "+line)
            sysError=True
            break
          arg=int(arg[1:])
          if(arg<0 or arg>7):
            print("syn error, R_addr wrong! "+line)
            sysError=True
            break
          arg=bin(arg)[2:]
          while(len(arg)<3):
            arg="0"+arg
          bit_inst=bit_inst.replace(simbol,arg)
        elif(simbol.lower()[0:3]=='imm'):
          bit_n=int(simbol[3:])
          arg=int(arg,16)
          if(arg<0 or arg>=2**bit_n):
            print("warning,imm is too large:",line,"imm="+str(arg))
          arg=bin(arg)[2:]
          while(len(arg)<bit_n):
            arg="0"+arg
          bit_inst=bit_inst.replace(simbol,arg)
        else:
          print("syn error, simbol error! "+line)
          sysError=True
          break
      if(len(bit_inst)!=16):
        print("syn error, binary lens Error! ",line,bit_inst)
        sysError=True
      for i in range(16):
        if(bit_inst[i]!='0' and bit_inst[i]!='1'):
          print("syn error, bit_inst Error! ",line,bit_inst)
          break
      if(bit_inst[8:16]=="11111001" or bit_inst[8:16]=="11111010"):
        print("Warning! Due to hardware and official software bugs, this directive may load errors.",line)
      bit_init_array.append(bit_inst)
  #print(bit_init_array)
  ret=bytes()
  for inst in bit_init_array:
    ret=ret+int(inst[8:]+inst[:8],2).to_bytes(2,byteorder='big')
  return ret

if __name__ == '__main__':
    file_name="build"
    text=""
    i=1
    while(i<len(sys.argv)):
      if(sys.argv[i]=='-o'):
        file_name=sys.argv[i+1]
        i+=1
      else:
        text=text+"\n"+open(sys.argv[i]).read()
      i+=1
    text="CALL SYSTEM_INIT\n"+text
    text=pretreatment(text)
    text=parseDefine(text)
    parseSigAddr(text)
    text=parseFinal(text)
    print("result:\nsig_addr:",sig_addr,"\n")
    output=open(file_name+"_o.s","w")
    output.write(text)
    output.close()
    binary=Assemble(text)
    output=open(file_name+"_o.bin","wb")
    output.write(binary)
    output.close()