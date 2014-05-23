F90 = gfortran
F90FLAGS = -cpp -std=f2008 -fbacktrace -g -fbounds-check -ffpe-trap=invalid,overflow,underflow
LDFLAGS  += -g
OBJ = $(patsubst %.F90,%.o,$(wildcard *.F90))
MAIN = main

all: main

main: $(OBJ)
	$(F90) $^ $(LDFLAGS) -o $@

%.o: %.F90
	$(F90) $(F90FLAGS) -c $<

clean:
	rm *.o *.mod

include DEPENDENCIES
