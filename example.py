#!/usr/bin/python3
# -*- coding: utf-8 -*-


BACK = [1,1,1,1]

GREEN = [0,1,0,0.1]
BLUE = [0,0,1,0.1]
RED = [1,0,0,0.1]


def main():

  from sand import Sand
  from numpy.random import random

  size = 1000

  s = Sand(size)

  s.set_bg(BACK)

  aa = random((1000000,2))
  aa[:,0]*=0.5

  bb = random((1000000,2))
  bb[:,1]*=0.5

  cc = random((1000000,2))*0.5
  cc[:,0] += 0.1

  s.set_rgba(GREEN)
  s.paint_dots(aa)
  s.set_rgba(RED)
  s.paint_dots(bb)
  s.set_rgba(BLUE)
  s.paint_dots(cc)
  s.write_to_png('./out.png')


if __name__ == '__main__':
  main()
