#!/usr/bin/python3
# -*- coding: utf-8 -*-

from numpy.random import random
from time import time

BACK = [0,0,0,0]
FRONT = [1,1,1,1]

GREEN = [0,1,0,0.1]
BLUE = [0,0,1,0.1]
RED = [1,0,0,0.1]

GRAINS = 10


def main():

  from sand import Sand

  size = 1000

  s = Sand(size)

  t = time()
  xya = random((1000000,2))
  xyb = random((1000000,2))
  s.paint_strokes(xya, xyb, GRAINS, RED)
  s.write_to_png('./out.png')
  t1 = time()-t
  print('time', t1)

  # from iutils.render import Render
  #
  # render = Render(size, BACK, FRONT)
  #
  # t = time()
  # for x,y in points:
  #   render.dot(x,y)
  # render.write_to_png('./out2.png')
  # t2 = time()-t
  # print('time2', t2)

  # print('speedup', t2/t1)






if __name__ == '__main__':
  main()
