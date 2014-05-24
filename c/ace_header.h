#ifndef __ACE_HEADER_H__
#define __ACE_HEADER_H__

#include<stdbool.h>
#include "endf_header.h"

//===============================================================================
// DISTANGLE contains data for a tabular secondary angle distribution whether it
// be tabular or 32 equiprobable cosine bins
//===============================================================================

typedef struct distangle_t {
  int      n_energy;
  double * energy;
  int    * type;
  int    * location;
  double * data;
  //void(*clear)(struct distangle_t *);
} DistAngle;

void distangle_clear(struct distangle_t * d) {
  free(d->energy);
  free(d->type);
  free(d->location);
  free(d->data);
  free(d);
  return;
}

//===============================================================================
// DISTENERGY contains data for a secondary energy distribution for all
// scattering laws
//===============================================================================

typedef struct distenergy_t {
  int            law;
  Tab1         * p_valid;
  double       * data;
  distenergy_t * next;
  //void(*clear)(struct distenergy_t *);
} DistEnergy;

void distenergy_clear(struct distenergy_t * d) {
  tab1_clear(d->p_valid);
  free(data);
  if (d->next != NULL)
    distenergy_clear(p->next);
  return;
}

//===============================================================================
// REACTION contains the cross-section and secondary energy and angle
// distributions for a single reaction in a continuous-energy ACE-format table
//===============================================================================

typedef struct reaction_t {
  int          MT;
  double       Q_value;
  int          multiplicity;
  int          threshold;
  bool         scatter_in_cm;
  double     * sigma;
  bool         has_angle_dist;
  bool         has_energy_dist;
  DistAngle  * adist;
  DistEnergy * edist;
  //void(*clear)(struct reaction_t *);
} Reaction;

void reaction_clear(struct reaction_t * r) {
  free(r->sigma);
  distangle_clear(r->adist);
  distenergy_clear(r->edist);
  return;
}










#endif
