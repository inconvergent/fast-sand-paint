# -*- coding: utf-8 -*-
# cython: profile=True

from __future__ import division

cimport cython

# from libc.stdlib cimport malloc
# from libc.stdlib cimport free

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
    cdef char[:] pix = self.pixels
    cdef int i
    cdef int ii

    cdef char r = _float_to_char(<float>rgba[2])
    cdef char g = _float_to_char(<float>rgba[1])
    cdef char b = _float_to_char(<float>rgba[0])
    cdef char a = _float_to_char(<float>rgba[3])

    for i in xrange(self.w*self.h):
      ii = 4*i
      pix[ii+2] = r
      pix[ii+1] = g
      pix[ii] = b
      pix[ii+3] = a
    return

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef void _operator_over(self, int o, char[:] A, float rB, float gB, float bB, float aB):
    # https://www.cairographics.org/operators/
    cdef float rA = _char_to_float(A[o+2])
    cdef float gA = _char_to_float(A[o+1])
    cdef float bA = _char_to_float(A[o])
    cdef float aA = _char_to_float(A[o+3])

    cdef float iA = 1.0-aA
    cdef float aR = aA + aB*iA

    A[o+2] = _float_to_char((aA*rA + aB*rB*iA)/aR)
    A[o+1] = _float_to_char((aA*gA + aB*gB*iA)/aR)
    A[o] = _float_to_char((aA*bA + aB*bB*iA)/aR)
    A[o+3] = _float_to_char(aR)

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef void paint_dots(self, double[:,:] xya, list rgba):
    cdef char[:] pix = self.pixels
    cdef int o = 0
    cdef int i = 0

    cdef float rB = <float>rgba[0]
    cdef float gB = <float>rgba[1]
    cdef float bB = <float>rgba[2]
    cdef float aB = <float>rgba[3]

    cdef int w = self.w
    cdef int h = self.h
    cdef int n = len(xya)

    cdef double pa
    cdef double pb

    cdef float half = 0

    for i in xrange(n):
      pa = xya[i,0]
      pb = xya[i,1]
      if pa<0 or pa>=1.0 or pb<0 or pb>=1.0:
        # raise ValueError('points must be within the unit square.')
        continue
      o = <int>floor((pb+half)*h)*self.stride+<int>floor((pa+half)*w)*4
      self._operator_over(o, pix, rB, gB, bB, aB)
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
    cdef char[:] pix = self.pixels
    cdef int o = 0
    cdef int i = 0

    cdef float rB = <float>rgba[0]
    cdef float gB = <float>rgba[1]
    cdef float bB = <float>rgba[2]
    cdef float aB = <float>rgba[3]

    cdef int w = self.w
    cdef int h = self.h
    cdef int n = len(xya)

    cdef double dx
    cdef double dy
    cdef double pa
    cdef double pb
    cdef double gamma

    cdef float half = 0

    for i in xrange(n):
      dx = xyb[i,0]-xya[i,0]
      dy = xyb[i,1]-xya[i,1]
      dd = sqrt(dx*dx+dy*dy)
      gamma = atan2(dy, dx)

      for j in xrange(grains):
        rnd = _random()*dd
        pa = xya[i,0]+rnd*cos(gamma)
        pb = xya[i,1]+rnd*sin(gamma)
        if pa<0 or pa>=1.0 or pb<0 or pb>=1.0:
          # raise ValueError('points must be within the unit square.')
          continue
        # o = <int>floor(pb*h)*self.stride+<int>floor(pa*w)*4
        o = <int>floor((pb+half)*h)*self.stride+<int>floor((pa+half)*w)*4
        self._operator_over(o, pix, rB, gB, bB, aB)
    return

  cpdef write_to_png(self, str name):
    self.sur.write_to_png(name)

