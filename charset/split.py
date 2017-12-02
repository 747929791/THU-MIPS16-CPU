import numpy as np
import cv2

img = cv2.imread("charset.png")

nX = 19
nY = 6
W = np.shape(img)[1] / nX
H = np.shape(img)[0] / nY
num = 0

for i in range(nX):
    for j in range(nY):
        temp = img[int(j * H) : int((j + 1) * H), int(i * W) : int((i + 1) * W), :]
        print(np.shape(temp))
        '''
        if((temp == 255 * np.ones([94, 69, 3])).all()):
            break;
        while((temp[:,0,:] == 255 * np.ones([94, 3])).all()):
            temp = temp[:, 1:, :]
        while((temp[:,-1,:] == 255 * np.ones([94, 3])).all()):
            temp = temp[:, : -1, :]    
        print(num , np.shape(temp))
        '''
        cv2.imwrite("charset/" + str(num) + ".jpg", temp[15:75, 20:50, :])
        num += 1