# -*- coding: utf-8 -*-
# cython: profile=True

from __future__ import division

cimport cython

from libc.math cimport cos
from libc.math cimport atan2
from libc.math cimport sin
from libc.math cimport sqrt
from libc.math cimport floor
from libc.math cimport fabs

from helpers cimport _random
from helpers cimport _char_to_float
from helpers cimport _float_to_char


from cpython cimport array

import array
import cairocffi as cairo


cdef class Sand:
  def __init__(self, int s):
    self.w = s
    self.h = s

    self.one = 1.0/<double>(s)

    self.stride = cairo.ImageSurface.format_stride_for_width(
        cairo.FORMAT_ARGB32,
        self.w
        )
    self.size = self.h * self.stride
    self.pixels = array.array('B',(0, )*self.size)
    self.sur = cairo.ImageSurface.create_for_data(
        self.pixels,
        cairo.FORMAT_ARGB32,
        self.w,
        self.h
        )
    self.ctx = cairo.Context(self.sur)

  def __cinit__(self, int s):
    return

  def __dealloc__(self):
    return

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef void set_bg(self, list rgba):
    cdef int i
    cdef int ii

    cdef float r = <float>rgba[0]
    cdef float g = <float>rgba[1]
    cdef float b = <float>rgba[2]
    cdef float a = <float>rgba[3]

    r = r*a
    g = g*a
    b = b*a

    cdef unsigned char _r = _float_to_char(r)
    cdef unsigned char _g = _float_to_char(g)
    cdef unsigned char _b = _float_to_char(b)
    cdef unsigned char _a = _float_to_char(a)

    for i in xrange(self.w*self.h):
      ii = 4*i
      self.pixels[ii] = _b
      self.pixels[ii+1] = _g
      self.pixels[ii+2] = _r
      self.pixels[ii+3] = _a
    return

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef void _operator_over(self, int o, float rA, float gA, float bA, float aA):
    # https://www.cairographics.org/operators/
    # https://tomforsyth1000.github.io/blog.wiki.html#%5B%5BPremultiplied%20alpha%20part%202%5D%5D
    cdef float bB = _char_to_float(self.pixels[o])
    cdef float gB = _char_to_float(self.pixels[o+1])
    cdef float rB = _char_to_float(self.pixels[o+2])
    cdef float aB = _char_to_float(self.pixels[o+3])

    self.pixels[o] = _float_to_char( bA + bB*(1.0-aA) )
    self.pixels[o+1] = _float_to_char( gA + gB*(1.0-aA) )
    self.pixels[o+2] = _float_to_char( rA + rB*(1.0-aA) )
    self.pixels[o+3] = _float_to_char( aA + aB*(1.0-aA) )

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef void paint_dots(self, double[:,:] xya, list rgba):

    cdef int w = self.w
    cdef int h = self.h
    cdef int n = len(xya)

    cdef float r = <float>rgba[0]
    cdef float g = <float>rgba[1]
    cdef float b = <float>rgba[2]
    cdef float a = <float>rgba[3]

    r = r*a
    g = g*a
    b = b*a

    cdef double pa
    cdef double pb

    cdef int o = 0
    cdef int i = 0
    for i in xrange(n):
      pa = xya[i,0]
      pb = xya[i,1]
      if pa<0 or pa>=1.0 or pb<0 or pb>=1.0:
        continue
      o = <int>floor((pb)*h)*self.stride+<int>floor((pa)*w)*4
      self._operator_over(o, r, g, b, a)
    return

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef void paint_strokes(
      self,
      double[:,:] xya,
      double[:,:] xyb,
      int grains,
      list rgba
      ):
    cdef int w = self.w
    cdef int h = self.h
    cdef int n = len(xya)

    cdef float r = <float>rgba[0]
    cdef float g = <float>rgba[1]
    cdef float b = <float>rgba[2]
    cdef float a = <float>rgba[3]

    r = r*a
    g = g*a
    b = b*a

    cdef double pa
    cdef double pb

    cdef int o = 0
    cdef int i = 0

    for i in xrange(n):
      dx = xyb[i,0]-xya[i,0]
      dy = xyb[i,1]-xya[i,1]

      for j in xrange(grains):
        rnd = _random()
        pa = xya[i,0]+rnd*dx
        pb = xya[i,1]+rnd*dy
        if pa<0 or pa>=1.0 or pb<0 or pb>=1.0:
          continue
        o = <int>floor((pb)*h)*self.stride+<int>floor((pa)*w)*4
        self._operator_over(o, r, g, b, a)
    return

  cpdef write_to_png(self, str name):
    self.sur.write_to_png(name)

