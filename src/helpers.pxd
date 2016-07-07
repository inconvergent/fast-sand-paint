# -*- coding: utf-8 -*-

cimport cython

# from libc.math cimport floor

from libc.stdlib cimport rand
cdef extern from "limits.h":
  int INT_MAX

@cython.wraparound(False)
@cython.boundscheck(False)
@cython.nonecheck(False)
cdef inline double _random() nogil:
  return <double>rand()/<double>INT_MAX

@cython.wraparound(False)
@cython.boundscheck(False)
@cython.nonecheck(False)
cdef inline int _randint(int a) nogil:
  return rand()%a

@cython.wraparound(False)
@cython.boundscheck(False)
@cython.nonecheck(False)
cdef inline double _char_to_double(unsigned char a) nogil:
  return <double>a/255.0

@cython.wraparound(False)
@cython.boundscheck(False)
@cython.nonecheck(False)
cdef inline unsigned char _double_to_char(double a) nogil:
  if a<=0.0:
    return 0
  if a>=1.0:
    return 255
  return <unsigned char>(a*255.0)

