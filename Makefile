FC = gfortran
FFLAGS = -g
CC = gcc
CFLAGS = -g

mini_reader_f: mini_reader_f.f90
	$(FC) $(FFLAGS) $< -o $@
