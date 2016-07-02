# -*- coding: utf-8 -*-
# cython: profile=True

from __future__ import division

cimport numpy as np


cdef class Sand:

  cdef int w
  cdef int h
  cdef int stride
  cdef double one
  cdef size_t size
  cdef unsigned char[:] pixels
  cdef readonly sur # cairo ImageSurface
  cdef ctx

  cdef void _operator_over(self, int, float, float, float, float)

  cpdef void set_bg(self, list rgba)

  cpdef void paint_dots(self, double[:,:], list)
  cpdef void paint_strokes(self, double[:,:], double[:,:], int, list)
  cpdef write_to_png(self, str)

