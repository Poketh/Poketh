from PIL import Image
import numpy as np

sizex = 5
sizey = 4

value = [16227374, 14554653, 0, 14554653, 0, 16707022, 0, 15032114, 16227374, 0, 15582605, 16707022, 16707022, 15032114, 0, 15582605, 0, 15582605, 0, 0]
vhex = ['{0:06X}'.format(v) for v in value]

npa = np.array(vhex)
npar = npa.reshape(sizey,sizex)

rgb = np.array([
                [ [int(v[i:i+2],base=16) for i in (0,2,4)] + [0 if v == '000000' else 255] for v in line ]
               for line in npar], dtype=np.uint8)

img = Image.fromarray(rgb, 'RGBA')
img.resize([200,200])
