# -*- coding: utf-8 -*-
# cython: profile=True

from __future__ import division

cimport numpy as np


cdef class Sand:

  cdef int w
  cdef int h
  cdef int stride
  cdef double one
  cdef double rA
  cdef double gA
  cdef double bA
  cdef double aA
  cdef size_t size
  cdef unsigned char[:] pixels
  cdef double[:] raw_pixels
  cdef readonly sur # cairo ImageSurface
  cdef ctx

  cdef void _operator_over(self, int)

  cpdef void set_bg(self, list rgba)
  cpdef void set_rgba(self, list rgba)

  cpdef void paint_dots(self, double[:,:])
  cpdef void paint_strokes(self, double[:,:], double[:,:], int)
  cpdef write_to_png(self, str)

