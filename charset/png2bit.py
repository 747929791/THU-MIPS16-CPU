import os
from PIL import Image

print(os.listdir(os.getcwd() + "\charset"))

bit_file = open("charset.bit", "wb")

f_num = len(os.listdir(os.getcwd() + "/charset"))
print(f_num)

binary=dict() #每个数字对应一个bytes

for file in os.listdir(os.getcwd() + "/charset"):
    im = Image.open("charset/" + file)
    numId=int(file.split('.')[0])
    if(im.size!=(8,16)):
      print("Error! img.size!=(8,16) ",file)
      continue
    for i in range(im.size[0]):
        for j in range(im.size[1]):
            r,g,b = im.getpixel((i,j))
            if(img[i][j][0] > 200):
                bit_file.write(struct.pack("H", 0x0000))
            else:
                bit_file.write(struct.pack("H", 0xFFFF))
    
bit_file.close()
    #print(np.shape(img))
