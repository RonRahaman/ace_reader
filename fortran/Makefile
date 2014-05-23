F90 = gfortran
F90FLAGS = -cpp -std=f2008 -fbacktrace -g -fbounds-check -ffpe-trap=invalid,overflow,underflow
LDFLAGS  += -g
SOURCE = $(wildcard *.F90)
OBJ = $(source:.F90=.o)

$(OBJ): $(SOURCE)

%.o: %.F90
	$(F90) $(F90FLAGS) -c $<

clean:
	rm *.o *.mod

include DEPENDENCIES
