#!/usr/bin/python3
# -*- coding: utf-8 -*-

from sand import Sand
from numpy.random import random

BACK = [1,1,1,1]
LIGHT = [0,0,0,0.01]

GREEN = [0,1,0,0.1]
BLUE = [0,0,1,0.1]
RED = [1,0,0,0.1]

def random_dots():
  size = 1000
  num = 10000000

  s = Sand(size)

  s.set_bg(BACK)

  aa = random((num,2))
  aa[:,0]*=0.5

  bb = random((num,2))
  bb[:,1]*=0.5

  cc = random((num,2))*0.5
  cc[:,0] += 0.1

  s.set_rgba(GREEN)
  s.paint_dots(aa)
  s.set_rgba(RED)
  s.paint_dots(bb)
  s.set_rgba(BLUE)
  s.paint_dots(cc)
  s.write_to_png('./out_random.png')

def random_bw_array():
  size = 1000
  rnd = random((size,size))
  rnd[:,int(size/2):] = 0.0

  s = Sand(size)
  s.set_bg_from_bw_array(rnd)

  s.write_to_png('./out_random_bw_array.png')

def random_rgb_array():
  size = 1000
  rnd = random((size,size,3))
  rnd[:,int(size/2):,0] = 0.0
  rnd[int(size/2):,:,2] = 0.0

  s = Sand(size)
  s.set_bg_from_rgb_array(rnd)

  s.write_to_png('./out_random_rgb_array.png')


def main():
  from time import time

  t1 = time()
  random_dots()
  print('random_dots', time()-t1)

  t1 = time()
  random_bw_array()
  print('random_bw_array', time()-t1)

  t1 = time()
  random_rgb_array()
  print('random_rgb_array', time()-t1)


if __name__ == '__main__':
  main()

