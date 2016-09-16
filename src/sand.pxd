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

  cdef readonly sur
  cdef ctx

  cdef void _transfer_pixels(self, double) nogil

  cdef void _operator_over(self, int) nogil
  # cdef void _operator_over_mix(self, int, int) nogil
  cdef void _operator_swap(self, int, int) nogil

  cdef void _find_max_rgba(self)
  cdef void _find_min_rgba(self)

  cpdef void set_bg(self, list)
  cpdef void set_transparent_pixel(self)
  cpdef void set_bg_from_bw_array(self, double[:,:])
  cpdef void set_bg_from_rgb_array(self, double[:,:,:])

  cpdef void set_rgba(self, list)

  cpdef void distort_dots_swap(self, double[:,:])
  cpdef void distort_dots_wind(self, double[:,:])

  cpdef void paint_dots(self, double[:,:])
  cpdef void paint_strokes(self, double[:,:], double[:,:], long[:])

  cpdef void paint_filled_circles(self, double[:,:], double[:], long[:])
  cpdef void paint_filled_circle_strokes(self, double[:,:], double[:,:],
      double[:], long, long[:])
  cpdef void paint_circles(self, double[:,:], double[:], long[:])

  cpdef void paint_triangles(self, double[:,:], double[:,:], double[:,:], long[:])

  cpdef void write_to_png(self, str, double gamma=*)

