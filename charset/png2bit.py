import os
from PIL import Image

dx=8
dy=16

print(os.listdir(os.getcwd() + "\charset"))

f_num = len(os.listdir(os.getcwd() + "/charset"))
print(f_num)

char_code=dict() #number->bytes

def toBit(x,n):
  x=bin(x)[2:][:n]
  while(len(x)<n):
    x="0"+x
  return x

for file in os.listdir(os.getcwd() + "/charset"):
    im = Image.open("charset/" + file)
    #im=im.convert("RGB")
    numId=int(file.split('.')[0])
    if(im.size!=(dx,dy)):
      print("Error! img.size!=(8,16) ",file)
      continue
    data=bytes()
    for j in range(im.size[1]):
      for i in range(im.size[0]):
            r,g,b = im.getpixel((i,j))
            r=r//32
            g=g//32
            b=b//32
            binary_code="0000000"+toBit(b,3)+toBit(g,3)+toBit(r,3)
            #if(r>100):
            #  binary_code="1111111111111111";
            #else:
            #  binary_code="0000000000000000";
            data=data+int(binary_code[8:16]+binary_code[:8],2).to_bytes(2,byteorder='big')
    char_code[numId]=data

bit_file = open("charset.bit", "wb")
for x in range(128):
  if(x in char_code):
    if(len(char_code[x])!=dx*dy*2):
      print("Code Size Error!",x,len(char_code[x]))
      continue
    bit_file.write(char_code[x])
  else:
    for i in range(dx):
      for j in range(dy):
        bit_file.write(int(0).to_bytes(2,byteorder='big'))
bit_file.close()