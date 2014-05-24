#ifndef __ENDF_HEADER_H__
#define __ENDF_HEADER_H__

#include <stdlib.h>

typedef struct tab1_t {
    int      n_regions; // # of interpolation regions
    int    * nbt;       // values separating interpolation regions
    int    * interp;    // interpolation scheme
    int      n_pairs;   // # of pairs of (x,y) values
    double * x;         // values of abscissa
    double * y;         // values of ordinate
} Tab1;

// Needs a lot of work
void tab1_clear(struct tab1_t *t) {
  free(t -> nbt);
  free(t -> x);
  free(t -> y);
  free(t);
}

#endif
