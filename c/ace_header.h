#ifndef __ACE_HEADER_H__
#define __ACE_HEADER_H__

#include <stdlib.h>
#include <stdbool.h>
#include "endf_header.h"
#include "constants.h"

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

// Needs a lot of work...
void distangle_clear(struct distangle_t * d) {
  free(d -> energy);
  free(d -> type);
  free(d -> location);
  free(d -> data);
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

// Needs a lot of work...
void distenergy_clear(struct distenergy_t * d) {
  tab1_clear(d -> p_valid);
  free(d -> data);
  if (d -> next != NULL)
    distenergy_clear(p -> next);
  free(d);
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

// Needs a lot of work...
void reaction_clear(struct reaction_t * r) {
  free(r->sigma);
  distangle_clear(r -> adist);
  distenergy_clear(r -> edist);
  free(r);
  return;
}

//===============================================================================
// URRDATA contains probability tables for the unresolved resonance range.
//===============================================================================

typedef struct urrdata_t {
  int        n_energy;        // # of incident neutron energies
  int        n_prob;          // # of probabilities
  int        interp;          // inteprolation (2=lin-lin, 5=log-log)
  int        inelastic_flag;  // inelastic competition flag
  int        absorption_flag; // other absorption flag
  bool       multiply_smooth; // multiply by smooth cross section?
  double   * energy;          // incident energies
  double *** prob;            // actual probabibility tables
  //void(*clear)(struct urrdata_t *);
} UrrData;

// Needs a lot of work...
void urrdata_clear(struct urrdata_t * u) {
  free(u -> energy);
  free(u -> **prob);
  free(u -> *prob);
  free(u -> prob);
  free(u);
  return;
}

//===============================================================================
// NUCLIDE contains all the data for an ACE-format continuous-energy cross
// section. The ACE format (A Compact ENDF format) is used in MCNP and several
// other Monte Carlo codes.
//===============================================================================

typedef struct nuclide_t {
  char   name[10]; // name of nuclide, e.g. 92235.03c
  int    zaid;     // Z and A identifier, e.g. 92235
  int    listing;  // index in xs_listings
  double awr;      // weight of nucleus in neutron masses
  double kT;       // temperature in MeV (k*T)

  // Energy grid information
  int      n_grid;     // # of nuclide grid points
  int    * grid_index; // pointers to union grid
  double * energy;     // energy values corresponding to xs

  // Microscopic cross sections
  double * total;      // total cross section
  double * elastic;    // elastic scattering
  double * fission;    // fission
  double * nu_fission; // neutron production
  double * absorption; // absorption (MT > 100)
  double * heating;    // heating

  // Fission information
  bool  fissionable;         // nuclide is fissionable?
  bool  has_partial_fission; // nuclide has partial fission reactions?
  int   n_fission;           // # of fission reactions
  int * index_fission;       // indices in reactions

  // Total fission neutron emission
  int      nu_t_type;
  double * nu_t_data;

  // Prompt fission neutron emission
  int      nu_p_type;
  double * nu_p_data;

  // Delayed fission neutron emission
  int          nu_d_type;
  int          n_precursor; // # of delayed neutron precursors
  double     * nu_d_data;
  double     * nu_d_precursor_data;
  DistEnergy * nu_d_edist;

  // Unresolved resonance data
  bool      urr_present;
  int       urr_inelastic;
  UrrData * urr_data;

  // Reactions
  int        n_reaction; // # of reactions
  Reaction * reactions;

  //void (*clear) (struct nuclide_t *);

} Nuclide;

// Needs a lot of work...
void nuclide_clear(struct nuclide_t *n) {
  free(n -> grid_index);
  free(n -> energy);
  free(n -> total);
  free(n -> elastic);
  free(n -> fission);
  free(n -> nu_fission);
  free(n -> absorption);
  free(n -> heating);
  free(n -> index_fission);
  free(n -> nu_t_data);
  free(n -> nu_p_data);
  free(n -> nu_d_data);
  free(n -> nu_d_precursor_data);
  distenergy_clear(n -> nu_d_edist);
  urrdata_clear(n -> urr_data);
  reaction_clear(n -> reactions);
  return;
}

//===============================================================================
// SALPHABETA contains S(a,b) data for thermal neutron scattering, typically off
// of light isotopes such as water, graphite, Be, etc
//===============================================================================

typedef struct salphabeta_t {
  char   name[10]; // name of table, e.g. lwtr.10t
  int    zaid;     // Z and A identifier, e.g. 6012 for Carbon-12
  double awr;      // weight of nucleus in neutron masses
  double kT;       // temperature in MeV (k*T)

  // threshold for S(a,b) treatment (usually ~4 eV)
  double threshold_inelastic;
  double threshold_elastic;

  // Inelastic scattering data
  int        n_inelastic_e_in;  // # of incoming E for inelastic
  int        n_inelastic_e_out; // # of outgoing E for inelastic
  int        n_inelastic_mu;    // # of outgoing angles for inelastic
  int        secondary_mode;    // secondary mode (equal/skewed)
  double *   inelastic_e_in;
  double **  inelastic_sigma;
  double **  inelastic_e_out;
  double *** inelastic_mu;

  // Elastic scattering data
  int       elastic_mode;   // elastic mode (discrete/exact)
  int       n_elastic_e_in; // # of incoming E for elastic
  int       n_elastic_mu;   // # of outgoing angles for elastic
  double *  elastic_e_in;
  double *  elastic_P;
  double ** elastic_mu;
} SAlphaBeta;

//===============================================================================
// XSLISTING contains data read from a cross_sections.xml file
//===============================================================================

typedef struct xslisting_t {
  char   name[12];           // table name, e.g. 92235.70c
  char   alias[12];          // table alias, e.g. U-235.70c
  int    type;               // type of table (cont-E neutron, S(A,b), etc)
  int    zaid;               // ZAID identifier = 1000*Z + A
  int    filetype;           // ASCII or BINARY
  int    location;           // location of table within library
  int    recl;               // record length for library
  int    entries;            // number of entries per record
  double awr;                // atomic weight ratio (# of neutron masses)
  double kT;                 // Boltzmann constant * temperature (MeV)
  bool   metastable;         // is this nuclide metastable?
  char   path[MAX_FILE_LEN]; // path to library containing table
} XsListing;

#endif

