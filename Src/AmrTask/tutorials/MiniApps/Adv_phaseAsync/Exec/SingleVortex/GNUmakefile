AMREX_HOME ?= ../../../../../../../..

PRECISION  = DOUBLE
PROFILE    = FALSE

DEBUG      = TRUE
DEBUG      = FALSE

#DIM        = 2
DIM       = 3
CPPFLAGS += -DUSE_PERILLA -DMPICH_SKIP_MPICXX -std=c++11 -DUSE_PERILLA_PTHREADS

COMP	   = g++
FCOMP	   = gfortran

USE_MPI    = TRUE
USE_OMP    = TRUE

Bpack   := ./Make.package 
Blocs   := . 

include ../Make.Adv
