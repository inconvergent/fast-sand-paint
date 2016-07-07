# -*- coding: utf-8 -*-
# cython: profile=True

from __future__ import division

cimport cython

from libc.math cimport floor

from helpers cimport _random
from helpers cimport _randint
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
  cdef void _transfer_pixels(self) nogil:
    cdef int i
    cdef int ii
    for i in xrange(self.w*self.h):
      ii = 4*i
      self.pixels[ii] = _double_to_char(self.raw_pixels[ii])
      self.pixels[ii+1] = _double_to_char(self.raw_pixels[ii+1])
      self.pixels[ii+2] = _double_to_char(self.raw_pixels[ii+2])
      self.pixels[ii+3] = _double_to_char(self.raw_pixels[ii+3])

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef void _operator_over(self, int o) nogil:
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

  # @cython.wraparound(False)
  # @cython.boundscheck(False)
  # @cython.nonecheck(False)
  # cdef void _operator_over_mix(self, int oa, int ob) nogil:
  #   cdef double aA = 0.05
  #   cdef double bA = self.raw_pixels[oa]*aA
  #   cdef double gA = self.raw_pixels[oa+1]*aA
  #   cdef double rA = self.raw_pixels[oa+2]*aA
  #
  #   cdef double bB = self.raw_pixels[ob]
  #   cdef double gB = self.raw_pixels[ob+1]
  #   cdef double rB = self.raw_pixels[ob+2]
  #   cdef double aB = 1.0
  #
  #   cdef double invaA = 1.0 - aA
  #   self.raw_pixels[ob] = bA + bB*invaA
  #   self.raw_pixels[ob+1] = gA + gB*invaA
  #   self.raw_pixels[ob+2] = rA + rB*invaA
  #   self.raw_pixels[ob+3] = aA + aB*invaA

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef void _operator_swap(self, int oa, int ob) nogil:
    cdef double bA = self.raw_pixels[oa]
    cdef double gA = self.raw_pixels[oa+1]
    cdef double rA = self.raw_pixels[oa+2]
    cdef double aA = self.raw_pixels[oa+3]

    cdef double bB = self.raw_pixels[ob]
    cdef double gB = self.raw_pixels[ob+1]
    cdef double rB = self.raw_pixels[ob+2]
    cdef double aB = self.raw_pixels[ob+3]

    self.raw_pixels[ob] = bA
    self.raw_pixels[ob+1] = gA
    self.raw_pixels[ob+2] = rA
    self.raw_pixels[ob+3] = aA

    self.raw_pixels[oa] = bB
    self.raw_pixels[oa+1] = gB
    self.raw_pixels[oa+2] = rB
    self.raw_pixels[oa+3] = aB

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

    with nogil:
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
  cpdef void set_bg_from_image(self, str fn):
    ## TODO: this is slow.
    from PIL import Image
    cdef int i
    cdef int ii
    cdef int j
    cdef int h
    cdef int w

    cdef double r
    cdef double g
    cdef double b

    cdef double a = 1.0

    cdef double scale = 1./255.
    cdef im = Image.open(fn)

    w,h = im.size
    if w!=self.w or h!=self.h:
      raise ValueError('bg image must be same size as sand canvas')

    cdef list data = list(im.convert('RGB').getdata())
    cdef tuple triple

    cdef int k = 0
    for i in range(w):
      for j in range(h):
        ii = 4*(i*h+j)
        triple = data[k]
        r = <double>triple[0]
        g = <double>triple[1]
        b = <double>triple[2]
        self.raw_pixels[ii] = b*scale
        self.raw_pixels[ii+1] = g*scale
        self.raw_pixels[ii+2] = r*scale
        self.raw_pixels[ii+3] = a
        k += 1
    return

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef void set_rgba(self, list rgba):
    cdef double rA = <double>rgba[0]
    cdef double gA = <double>rgba[1]
    cdef double bA = <double>rgba[2]
    cdef double aA = <double>rgba[3]

    with nogil:
      self.rA = rA*aA
      self.gA = gA*aA
      self.bA = bA*aA
      self.aA = aA
    return

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
    with nogil:
      for i in xrange(n):
        pa = xya[i,0]
        pb = xya[i,1]
        if pa<0 or pa>=1.0 or pb<0 or pb>=1.0:
          continue
        o = <int>floor(pb*h)*self.stride+<int>floor(pa*w)*4
        self._operator_over(o)
    return

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef void distort_dots_swap(self, double[:,:] xya):
    cdef int w = self.w
    cdef int h = self.h
    cdef int n = len(xya)
    cdef int aa
    cdef int bb

    cdef double ax
    cdef double ay
    cdef double bx
    cdef double by

    cdef int oa = 0
    cdef int ob = 0
    cdef int i = 0
    with nogil:
      for i in xrange(n):
        aa = _randint(n)
        bb = _randint(n)

        ax = xya[aa,0]
        ay = xya[aa,1]
        bx = xya[bb,0]
        by = xya[bb,1]
        if ax<0 or ax>=1.0 or ay<0 or ay>=1.0:
          continue
        if bx<0 or bx>=1.0 or by<0 or by>=1.0:
          continue

        oa = <int>floor(ay*h)*self.stride+<int>floor(ax*w)*4
        ob = <int>floor(by*h)*self.stride+<int>floor(bx*w)*4

        self._operator_swap(
            oa,
            ob,
            )
    return

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef void distort_dots_wind(self, double[:,:] xya):
    cdef int w = self.w
    cdef int h = self.h
    cdef int n = len(xya)
    cdef int aa
    cdef int bb

    cdef double ax
    cdef double ay
    cdef double bx
    cdef double by

    cdef int oa = 0
    cdef int ob = 0
    cdef int i
    with nogil:
      for i in xrange(0, n, 2):
        ax = xya[i,0]
        ay = xya[i,1]
        bx = xya[i+1,0]
        by = xya[i+1,1]
        if ax<0 or ax>=1.0 or ay<0 or ay>=1.0:
          continue
        if bx<0 or bx>=1.0 or by<0 or by>=1.0:
          continue

        oa = <int>floor(ay*h)*self.stride+<int>floor(ax*w)*4
        ob = <int>floor(by*h)*self.stride+<int>floor(bx*w)*4

        self._operator_swap(
            oa,
            ob,
            )
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
    cdef double dx
    cdef double dy
    cdef double rnd

    cdef int o = 0
    cdef int i = 0

    with nogil:
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

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef write_to_png(self, str name):
    self._transfer_pixels()
    self.sur.write_to_png(name)

