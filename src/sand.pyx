# -*- coding: utf-8 -*-
# cython: profile=True

from __future__ import division

cimport cython

from libc.math cimport floor

from helpers cimport _random
from helpers cimport _char_to_double
from helpers cimport _double_to_char


from cpython cimport array

import array
import cairocffi as cairo


cdef class Sand:
  def __init__(self, int s):
    self.w = s
    self.h = s

    self.one = 1.0/<double>(s)

    self.rA = 0.0
    self.gA = 0.0
    self.bA = 0.0
    self.aA = 1.0

    self.stride = cairo.ImageSurface.format_stride_for_width(
        cairo.FORMAT_ARGB32,
        self.w
        )
    self.size = self.h * self.stride
    self.pixels = array.array('B',(0, )*self.size)
    self.raw_pixels = array.array('d',(0, )*self.size)
    self.sur = cairo.ImageSurface.create_for_data(
        self.pixels,
        cairo.FORMAT_ARGB32,
        self.w,
        self.h
        )
    self.ctx = cairo.Context(self.sur)
    self.set_bg([1,1,1,1])

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

    cdef double r = <double>rgba[0]
    cdef double g = <double>rgba[1]
    cdef double b = <double>rgba[2]
    cdef double a = <double>rgba[3]

    for i in xrange(self.w*self.h):
      ii = 4*i
      self.raw_pixels[ii] = b*a
      self.raw_pixels[ii+1] = g*a
      self.raw_pixels[ii+2] = r*a
      self.raw_pixels[ii+3] = a
    return

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef void set_rgba(self, list rgba):
    cdef double rA = <double>rgba[0]
    cdef double gA = <double>rgba[1]
    cdef double bA = <double>rgba[2]
    cdef double aA = <double>rgba[3]

    self.rA = rA*aA
    self.gA = gA*aA
    self.bA = bA*aA
    self.aA = aA
    return

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef void _operator_over(self, int o):
    # https://www.cairographics.org/operators/
    # https://tomforsyth1000.github.io/blog.wiki.html#%5B%5BPremultiplied%20alpha%20part%202%5D%5D
    cdef double bB = self.raw_pixels[o]
    cdef double gB = self.raw_pixels[o+1]
    cdef double rB = self.raw_pixels[o+2]
    cdef double aB = self.raw_pixels[o+3]

    cdef double invaA = 1.0 - self.aA

    self.raw_pixels[o] = self.bA + bB*invaA
    self.raw_pixels[o+1] = self.gA + gB*invaA
    self.raw_pixels[o+2] = self.rA + rB*invaA
    self.raw_pixels[o+3] = self.aA + aB*invaA

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef void paint_dots(self, double[:,:] xya):

    cdef int w = self.w
    cdef int h = self.h
    cdef int n = len(xya)

    cdef double pa
    cdef double pb

    cdef int o = 0
    cdef int i = 0
    for i in xrange(n):
      pa = xya[i,0]
      pb = xya[i,1]
      if pa<0 or pa>=1.0 or pb<0 or pb>=1.0:
        continue
      o = <int>floor(pb*h)*self.stride+<int>floor(pa*w)*4
      self._operator_over(o)
      print(self.raw_pixels[o+3], _double_to_char(self.raw_pixels[o+3]))
      print('asdf')
    return

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef void paint_strokes(
      self,
      double[:,:] xya,
      double[:,:] xyb,
      int grains
      ):
    cdef int w = self.w
    cdef int h = self.h
    cdef int n = len(xya)

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
        o = <int>floor(pb*h)*self.stride+<int>floor(pa*w)*4
        self._operator_over(o)
    return

  cpdef write_to_png(self, str name):
    cdef int i
    cdef int ii
    for i in xrange(self.w*self.h):
      ii = 4*i
      # print(self.raw_pixels[ii], self.raw_pixels[ii+3])
      self.pixels[ii] = _double_to_char(self.raw_pixels[ii])
      self.pixels[ii+1] = _double_to_char(self.raw_pixels[ii+1])
      self.pixels[ii+2] = _double_to_char(self.raw_pixels[ii+2])
      self.pixels[ii+3] = _double_to_char(self.raw_pixels[ii+3])

    self.sur.write_to_png(name)

