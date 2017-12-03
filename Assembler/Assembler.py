#coding = utf-8
import re
import sys
"""
Moon汇编器，将扩展MIPS16语言转化为基本MIPS16语言
调用方式 "python Assembler.py input output"
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

statement_addr="4000"
bss_addr="C000" #DATA段起始地址
define=dict()
sig_addr=dict() #符号地址，0起始

#对于所有的HI LOW操作，由于LOW是符号扩展加法，故HI在计算时有时要加一
statement=dict()
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


#去除冗余字符，注释
def pretreatment(text):
  text="\n".join([i.split(';')[0] for i in text.split('\n')])
  text=text.replace("\t"," ")
  p = re.compile(r' +');text=p.sub(" ",text)
  p = re.compile(r'\n ');text=p.sub("\n",text)
  p = re.compile(r' \n');text=p.sub("\n",text)
  p = re.compile(r'\n+');text=p.sub("\n",text)
  if(text[0]=="\n"):
    text=text[1:]
  if(text[-1]=="\n"):
    text=text[:-1]
  return text.upper()

#处理宏定义
def parseDefine(text):
  for line in text.split('\n'):
    b=line.split(' ')
    if(b[0]=="DEFINE"):
      text=text.replace(b[1]+" ",b[2]+" ")
      text=text.replace(b[1]+"\n",b[2]+"\n")
  text="\n".join([i for i in text.split('\n') if i.split(' ')[0]!="DEFINE"])
  return text

#计算符号地址
def parseSigAddr(text):
  ret=[]
  addr=0
  bss_addr=0
  for line in text.split('\n'):
    b=line.split(':')
    if(len(b)>1):
      if(b[0] in sig_addr):
        print("ERROR! SIG_ADDR:"+b[0]+" already exist!")
      sig_addr[b[0]]=addr
    else:
      b=line.split(' ')
      if(b[0]=="DATA"):
        l=int(b[2])
        sig_addr[b[1]]=bss_addr
        bss_addr+=l
      else:
        if(b[0] in statement):
          addr+=len(statement[b[0]])
          ret+=statement[b[0]]
        else:
          addr+=1
          ret.append(line)

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
  for line in text.split('\n'):
    b=line.split(':')
    if(len(b)>1):
      pass
    else:
      b=line.split(' ')
      if(b[0]=="DATA"):
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
          ret+=("\n".join(statement[b[0]])).replace(" HI"," "+X[0:2]).replace(" LOW"," "+X[2:4]).replace(" REG"," "+REG).replace(" IMM"," "+IMM).replace(" OFFSET8"," "+OFFSET8).replace(" OFFSET11"," "+OFFSET11).split('\n')
        else:
          addr+=1
          ret.append(line)
  return "\n".join(ret)
  
if __name__ == '__main__':
    text=open(sys.argv[1]).read()
    text=pretreatment(text)
    text=parseDefine(text)
    parseSigAddr(text)
    text=parseFinal(text)
    print("\n\nresult:\nsig_addr:",sig_addr)
    output=open(sys.argv[2],"w")
    output.write(text)
    output.close()