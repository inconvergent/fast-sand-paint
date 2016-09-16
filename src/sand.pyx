# -*- coding: utf-8 -*-
# cython: profile=True

from __future__ import division

cimport cython

from libc.math cimport floor
from libc.math cimport ceil
from libc.math cimport sin
from libc.math cimport sqrt
from libc.math cimport cos

from helpers cimport _random
from helpers cimport _max
from helpers cimport _4max
from helpers cimport _min
from helpers cimport _4min
from helpers cimport _randint
from helpers cimport _double_to_char


from cpython cimport array

import array
import cairocffi as cairo

cdef double PI = 3.14159265359
cdef double TWOPI = 2.0*PI

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
  cdef void _transfer_pixels(self, double gamma) nogil:
    cdef int i
    cdef int ii
    for i in xrange(self.w*self.h):
      ii = 4*i
      self.pixels[ii] = _double_to_char(self.raw_pixels[ii], gamma)
      self.pixels[ii+1] = _double_to_char(self.raw_pixels[ii+1], gamma)
      self.pixels[ii+2] = _double_to_char(self.raw_pixels[ii+2], gamma)
      self.pixels[ii+3] = _double_to_char(self.raw_pixels[ii+3], gamma)

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
  cdef void _find_min_rgba(self):
    #TODO: return values if i need them
    cdef int i = 0
    cdef int ii = 0
    cdef double mb = self.raw_pixels[ii]
    cdef double mg = self.raw_pixels[ii+1]
    cdef double mr = self.raw_pixels[ii+2]
    cdef double ma = self.raw_pixels[ii+3]

    with nogil:
      for i in xrange(self.w*self.h):
        ii = 4*i
        mb = _min(mb, self.raw_pixels[ii])
        mg = _min(mg, self.raw_pixels[ii+1])
        mr = _min(mr, self.raw_pixels[ii+2])
        ma = _min(ma, self.raw_pixels[ii+3])

    print('min', mr, mg, mb, ma)

    return

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef void _find_max_rgba(self):
    #TODO: return values if i need them
    cdef int i = 0
    cdef int ii = 0
    cdef double mb = self.raw_pixels[ii]
    cdef double mg = self.raw_pixels[ii+1]
    cdef double mr = self.raw_pixels[ii+2]
    cdef double ma = self.raw_pixels[ii+3]

    with nogil:
      for i in xrange(self.w*self.h):
        ii = 4*i
        mb = _max(mb, self.raw_pixels[ii])
        mg = _max(mg, self.raw_pixels[ii+1])
        mr = _max(mr, self.raw_pixels[ii+2])
        ma = _max(ma, self.raw_pixels[ii+3])

    print('max', mr, mg, mb, ma)

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
  cpdef void set_transparent_pixel(self):
    cdef int i = 0

    cdef double r = 1.0
    cdef double a = 0.95

    with nogil:
      self.raw_pixels[i] = r*a
      self.raw_pixels[i+1] = r*a
      self.raw_pixels[i+2] = r*a
      self.raw_pixels[i+3] = a
    return

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef void set_bg_from_bw_array(self, double[:,:] bw):
    cdef int i
    cdef int j
    cdef int ii

    cdef double x

    with nogil:
      for i in range(self.h):
        for j in range(self.w):
          ii = 4*(i*self.h+j)
          x = bw[i,j]
          self.raw_pixels[ii] = x
          self.raw_pixels[ii+1] = x
          self.raw_pixels[ii+2] = x
          self.raw_pixels[ii+3] = 1.0
    return

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef void set_bg_from_rgb_array(self, double[:,:,:] rgb):
    cdef int i
    cdef int j
    cdef int ii

    with nogil:
      for i in range(self.h):
        for j in range(self.w):
          ii = 4*(i*self.h+j)
          self.raw_pixels[ii] = rgb[i,j,2]
          self.raw_pixels[ii+1] = rgb[i,j,1]
          self.raw_pixels[ii+2] = rgb[i,j,0]
          self.raw_pixels[ii+3] = 1.0
    return

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef void set_rgba(self, list rgba):
    if not len(rgba)==4:
      raise ValueError('rgba must be a list with four elements')

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
      long[:] grains
      ):
    cdef int w = self.w
    cdef int h = self.h
    cdef long n = len(xya)

    cdef double pa
    cdef double pb
    cdef double dx
    cdef double dy
    cdef double rnd

    cdef int o
    cdef long i
    cdef long j
    with nogil:
      for i in xrange(n):
        dx = xyb[i,0]-xya[i,0]
        dy = xyb[i,1]-xya[i,1]

        for j in xrange(grains[i]):
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
  cpdef void paint_filled_circles(
      self,
      double[:,:] xy,
      double[:] rr,
      long[:] grains
      ):

    cdef int w = self.w
    cdef int h = self.h
    cdef long n = len(xy)

    cdef double x
    cdef double y
    cdef double rndx
    cdef double rndy
    cdef double dd
    cdef double r
    cdef double r2

    cdef int o = 0
    cdef long i = 0
    cdef long k = 0
    with nogil:
      for k in xrange(n):
        r = rr[k]
        r2 = r*r
        x = xy[k, 0]
        y = xy[k, 1]
        for i in xrange(grains[k]):
          rndx = x + (1.0-2.0*_random())*r
          rndy = y + (1.0-2.0*_random())*r
          dx = x-rndx
          dy = y-rndy
          dd = dx*dx+dy*dy

          if dd>=r2 or rndx<0.0 or rndx>=1.0 or rndy<0.0 or rndy>=1.0:
            continue
          o = <int>floor(rndy*h)*self.stride+<int>floor(rndx*w)*4
          self._operator_over(o)
    return

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  @cython.cdivision(True)
  cpdef void paint_filled_circle_strokes(
      self,
      double[:,:] xya,
      double[:,:] xyb,
      double[:] rr,
      long cmult,
      long[:] grains
      ):

    cdef int w = self.w
    cdef int h = self.h
    cdef long n = len(xya)
    cdef long g

    cdef double x
    cdef double y
    cdef double rndx
    cdef double rndy
    cdef double rndab
    cdef double ab
    cdef double dd
    cdef double dx
    cdef double dy
    cdef double kdx
    cdef double kdy
    cdef double r
    cdef double r2

    cdef int o
    cdef long i
    cdef long k
    cdef long j
    with nogil:
      for k in xrange(n):
        kdx = xyb[k,0] - xya[k,0]
        kdy = xyb[k,1] - xya[k,1]
        ab = sqrt(kdx*kdx+kdy*kdy)
        r = rr[k]
        r2 = r*r
        g = grains[k]
        for j in xrange(<long>ceil(ab/self.one*<double>cmult)):
          rndab = _random()
          x = xya[k,0] + rndab*kdx
          y = xya[k,1] + rndab*kdy
          for i in xrange(g):
            rndx = x + (1.0-2.0*_random())*r
            rndy = y + (1.0-2.0*_random())*r
            dx = x-rndx
            dy = y-rndy
            dd = dx*dx+dy*dy

            if dd>=r2 or rndx<0.0 or rndx>=1.0 or rndy<0.0 or rndy>=1.0:
              continue
            o = <int>floor(rndy*h)*self.stride+<int>floor(rndx*w)*4
            self._operator_over(o)
    return

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef void paint_circles(
      self,
      double[:,:] xy,
      double[:] rr,
      long[:] grains
      ):

    cdef int w = self.w
    cdef int h = self.h
    cdef long n = len(xy)

    cdef double x
    cdef double y
    cdef double rndx
    cdef double rndy
    cdef double r
    cdef double r2
    cdef double a

    cdef int o = 0
    cdef long i = 0
    cdef long k = 0
    with nogil:
      for k in xrange(n):
        r = rr[k]
        r2 = r*r
        x = xy[k, 0]
        y = xy[k, 1]
        for i in xrange(grains[k]):
          a = _random()*TWOPI
          rndx = x + cos(a)*r
          rndy = y + sin(a)*r

          if rndx<0.0 or rndx>=1.0 or rndy<0.0 or rndy>=1.0:
            continue
          o = <int>floor(rndy*h)*self.stride+<int>floor(rndx*w)*4
          self._operator_over(o)
    return

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef void paint_triangles(
      self,
      double[:,:] xya,
      double[:,:] xyb,
      double[:,:] xyc,
      long[:] grains
      ):

    cdef int w = self.w
    cdef int h = self.h
    cdef long n = len(xya)

    cdef double v1x
    cdef double v1y
    cdef double v2x
    cdef double v2y
    cdef double a1
    cdef double a2
    cdef double dd
    cdef double ddx
    cdef double ddy

    cdef int o
    cdef long i
    cdef long k
    with nogil:
      for k in xrange(n):

        v1x = xyb[k,0]-xya[k,0]
        v1y = xyb[k,1]-xya[k,1]
        v2x = xyc[k,0]-xya[k,0]
        v2y = xyc[k,1]-xya[k,1]

        for i in xrange(2*grains[k]):
          a1 = _random()
          a2 = _random()

          ## discarding half the grains. improve this.
          if a1+a2>1.0:
            continue

          ddx = v1x*a1 + v2x*a2 + xya[k,0]
          ddy = v1y*a1 + v2y*a2 + xya[k,1]

          if ddx<0.0 or ddx>=1.0 or ddy<0.0 or ddy>=1.0:
            continue
          o = <int>floor(ddy*h)*self.stride+<int>floor(ddx*w)*4
          self._operator_over(o)
    return

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef void write_to_png(self, str name, double gamma=1.0):
    self._transfer_pixels(gamma)
    self.sur.write_to_png(name)

