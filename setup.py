#!/usr/bin/python3

try:
  from setuptools import setup
  from setuptools.extension import Extension
except Exception:
  from distutils.core import setup
  from distutils.extension import Extension

from Cython.Build import cythonize
import numpy

_extra = [
    '-O3',
    '-ffast-math'
    ]

req = [
    'cairocffi',
    'cython>=0.24.0'
    ]

extensions = [
    Extension('sand',
      sources = ['./src/sand.pyx'],
      extra_compile_args = _extra,
      include_dirs = [numpy.get_include()]
      )
    ]

setup(
    name = "fast-sand-paint",
    version = '0.1.0',
    author = '@inconvergent',
    install_requires = req,
    zip_safe = False,
    license = 'MIT',
    ext_modules = cythonize(
      extensions
      )
    )

