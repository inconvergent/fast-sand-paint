#!/usr/bin/python3
# -*- coding: utf-8 -*-

from numpy.random import random
from time import time

BACK = [0,0,0,0]
FRONT = [1,1,1,1]

GREEN = [0,1,0,0.1]
BLUE = [0,0,1,0.1]
RED = [1,0,0,0.1]


def main():

  from sand import Sand

  size = 1000

  s = Sand(size)

  s.set_bg(FRONT)

  t = time()
  aa = random((1000000,2))
  aa[:,0]*=0.5

  bb = random((1000000,2))
  bb[:,1]*=0.5

  cc = random((1000000,2))*0.5
  cc[:,0] += 0.1

  s.paint_dots(aa, GREEN)
  s.paint_dots(bb, BLUE)
  s.paint_dots(cc, RED)
  s.write_to_png('./out.png')
  t1 = time()-t
  print('time', t1)

  from iutils.render import Render

  render = Render(size, BACK, FRONT)

  t = time()
  render.set_front(GREEN)
  for x,y in aa:
    render.dot(x,y)

  render.set_front(BLUE)
  for x,y in bb:
    render.dot(x,y)

  render.set_front(RED)
  for x,y in cc:
    render.dot(x,y)

  render.write_to_png('./out2.png')
  t2 = time()-t
  print('time2', t2)

  print('speedup', t2/t1)






if __name__ == '__main__':
  main()
