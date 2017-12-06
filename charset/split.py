from PIL import Image

im = Image.open("ascii.png")
for i in range(im.size[0]):
  for j in range(im.size[1]):
    r,g,b=im.getpixel((i,j))
    im.putpixel((i,j),(255-r,255-g,255-b))
for i in range(128):
  box = (i*22, 5, (i+1)*22, 49)
  region = im.crop(box)
  region=region.resize((8,16),Image.ANTIALIAS)
  region=region.convert("L")
  region=region.convert("RGB")
  region.save("charset/"+str(i)+".png")