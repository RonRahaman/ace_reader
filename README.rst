==========
ACE reader
==========

This repo contains ACE cross-section readers in FORTRAN and C.

-------
FORTRAN
-------

The FORTRAN version is modified from OpenMC (http://github.com/mit-crpg/openmc)
with fewer modules and minimal dependencies.  For testing puprposes, it
contains a main.F90 file that reads cross-sections for two nuclei from two ACE
files (U-234 and H-1 from endf70j and endf70a, respectively) and prints the
parsed data from ACE files.

To make it, simply run the Makefile.

To use it, run:

./main ~/data_dir 

where ~/data_dir is the location of your ACE library files (such as endf70a, endf70b, etc)

-----
C
-----

The C version is under development.  Currently, it mirrors the FORTRAN version
as closely as possible.
