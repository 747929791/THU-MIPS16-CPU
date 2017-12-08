#coding = utf-8
"""
打包二进制文件，使用方式python mergeBin.py input1.bin 0000 input2.bin 4000 -o output.bin
将会将input1从0地址写入，input2从'4000'地址写入(16进制，16位1个Word)，将目标文件产生于output
"""

import re
import sys

data=[] #(文件名,文件数据,目标地址)

if __name__ == '__main__':
    result=bytes()
    file_name="output.bin"
    i=1
    while(i<len(sys.argv)):
      if(sys.argv[i]=='-o'):
        file_name=sys.argv[i+1]
      else:
        text=open(sys.argv[i],"rb").read()
        print(sys.argv[i],sys.argv[i+1],"size="+str(len(text)//2))
        data.append((sys.argv[i],text,int(sys.argv[i+1],16)*2))
      i+=2
    data=sorted(data,key=lambda x:x[2])
    for block in data:
      if(len(result)>block[2]):
        print("Error! Block conflict.",block[0])
      for i in range(block[2]-len(result)):
        result=result+b'\x00'
      result=result+block[1]
    output=open(file_name,"wb")
    output.write(result)
    output.close()