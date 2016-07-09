# -*- coding: utf-8 -*-

cimport cython

from libc.math cimport pow

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
cdef inline double _min(double a, double b) nogil:
  if a<b:
    return a
  return b

@cython.wraparound(False)
@cython.boundscheck(False)
@cython.nonecheck(False)
cdef inline double _4min(double a, double b, double c, double d) nogil:
  cdef int i
  cdef double *data = [b, c, d]
  cdef double m = a
  for i in xrange(3):
    if m<data[i]:
      m = data[i]
  return m

@cython.wraparound(False)
@cython.boundscheck(False)
@cython.nonecheck(False)
cdef inline double _max(double a, double b) nogil:
  if a>b:
    return a
  return b

@cython.wraparound(False)
@cython.boundscheck(False)
@cython.nonecheck(False)
cdef inline double _4max(double a, double b, double c, double d) nogil:
  cdef int i
  cdef double *data = [b, c, d]
  cdef double m = a
  for i in xrange(3):
    if m>data[i]:
      m = data[i]
  return m

@cython.wraparound(False)
@cython.boundscheck(False)
@cython.nonecheck(False)
cdef inline unsigned char _double_to_char(double a, double g) nogil:
  if a<=0.0:
    return 0
  if a>=1.0:
    return 255
  return <unsigned char>(pow(a, g)*255.0)

