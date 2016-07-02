# -*- coding: utf-8 -*-

cimport cython

# from libc.math cimport floor

from libc.stdlib cimport rand
cdef extern from "limits.h":
  int INT_MAX

@cython.wraparound(False)
@cython.boundscheck(False)
@cython.nonecheck(False)
cdef inline float _random():
  return <float>rand()/<float>INT_MAX

@cython.wraparound(False)
@cython.boundscheck(False)
@cython.nonecheck(False)
cdef inline float _char_to_float(unsigned char a):
  return <float>a/255.0

@cython.wraparound(False)
@cython.boundscheck(False)
@cython.nonecheck(False)
cdef inline unsigned char _float_to_char(float a):
  if a<=0.0:
    return 0
  if a>=1.0:
    return 255
  return <unsigned char>(a*255.0)

