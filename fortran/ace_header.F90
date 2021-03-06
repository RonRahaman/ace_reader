module ace_header

  use constants,   only: MAX_FILE_LEN
  use endf_header, only: Tab1

  implicit none

!===============================================================================
! DISTANGLE contains data for a tabular secondary angle distribution whether it
! be tabular or 32 equiprobable cosine bins
!===============================================================================

  type DistAngle
    integer              :: n_energy    ! # of incoming energies
    real(8), allocatable :: energy(:)   ! incoming energy grid
    integer, allocatable :: type(:)     ! type of distribution
    integer, allocatable :: location(:) ! location of each table
    real(8), allocatable :: data(:)     ! angular distribution data
    
    ! Type-Bound procedures
    contains
      procedure :: clear => distangle_clear ! Deallocates DistAngle
  end type DistAngle

!===============================================================================
! DISTENERGY contains data for a secondary energy distribution for all
! scattering laws
!===============================================================================

  type DistEnergy
    integer    :: law                 ! secondary distribution law
    type(Tab1) :: p_valid             ! probability of law validity
    real(8), allocatable :: data(:)   ! energy distribution data

    ! For reactions that may have multiple energy distributions such as (n.2n),
    ! this pointer allows multiple laws to be stored
    type(DistEnergy), pointer :: next => null()
    
    ! Type-Bound procedures
    contains
      procedure :: clear => distenergy_clear ! Deallocates DistEnergy
  end type DistEnergy

!===============================================================================
! REACTION contains the cross-section and secondary energy and angle
! distributions for a single reaction in a continuous-energy ACE-format table
!===============================================================================

  type Reaction
    integer :: MT                      ! ENDF MT value
    real(8) :: Q_value                 ! Reaction Q value
    integer :: multiplicity            ! Number of secondary particles released
    integer :: threshold               ! Energy grid index of threshold
    logical :: scatter_in_cm           ! scattering system in center-of-mass?
    real(8), allocatable :: sigma(:)   ! Cross section values
    logical :: has_angle_dist          ! Angle distribution present?
    logical :: has_energy_dist         ! Energy distribution present?
    type(DistAngle)           :: adist ! Secondary angular distribution
    type(DistEnergy), pointer :: edist => null() ! Secondary energy distribution
    
    ! Type-Bound procedures
    contains
      procedure :: clear => reaction_clear ! Deallocates Reaction
  end type Reaction

!===============================================================================
! URRDATA contains probability tables for the unresolved resonance range.
!===============================================================================

  type UrrData
    integer :: n_energy        ! # of incident neutron energies
    integer :: n_prob          ! # of probabilities
    integer :: interp          ! inteprolation (2=lin-lin, 5=log-log)
    integer :: inelastic_flag  ! inelastic competition flag
    integer :: absorption_flag ! other absorption flag
    logical :: multiply_smooth ! multiply by smooth cross section?
    real(8), allocatable :: energy(:)   ! incident energies
    real(8), allocatable :: prob(:,:,:) ! actual probabibility tables
    
    ! Type-Bound procedures
    contains
      procedure :: clear => urrdata_clear ! Deallocates UrrData
  end type UrrData

!===============================================================================
! NUCLIDE contains all the data for an ACE-format continuous-energy cross
! section. The ACE format (A Compact ENDF format) is used in MCNP and several
! other Monte Carlo codes.
!===============================================================================

  type Nuclide
    character(10) :: name    ! name of nuclide, e.g. 92235.03c
    integer       :: zaid    ! Z and A identifier, e.g. 92235
    integer       :: listing ! index in xs_listings
    real(8)       :: awr     ! weight of nucleus in neutron masses
    real(8)       :: kT      ! temperature in MeV (k*T)

    ! Energy grid information
    integer :: n_grid                     ! # of nuclide grid points
    integer, allocatable :: grid_index(:) ! pointers to union grid
    real(8), allocatable :: energy(:)     ! energy values corresponding to xs

    ! Microscopic cross sections
    real(8), allocatable :: total(:)      ! total cross section
    real(8), allocatable :: elastic(:)    ! elastic scattering
    real(8), allocatable :: fission(:)    ! fission
    real(8), allocatable :: nu_fission(:) ! neutron production
    real(8), allocatable :: absorption(:) ! absorption (MT > 100)
    real(8), allocatable :: heating(:)    ! heating

    ! Fission information
    logical :: fissionable         ! nuclide is fissionable?
    logical :: has_partial_fission ! nuclide has partial fission reactions?
    integer :: n_fission           ! # of fission reactions
    integer, allocatable :: index_fission(:) ! indices in reactions

    ! Total fission neutron emission
    integer :: nu_t_type
    real(8), allocatable :: nu_t_data(:)

    ! Prompt fission neutron emission
    integer :: nu_p_type
    real(8), allocatable :: nu_p_data(:)

    ! Delayed fission neutron emission
    integer :: nu_d_type
    integer :: n_precursor ! # of delayed neutron precursors
    real(8), allocatable :: nu_d_data(:)
    real(8), allocatable :: nu_d_precursor_data(:)
    type(DistEnergy), pointer :: nu_d_edist(:) => null()

    ! Unresolved resonance data
    logical                :: urr_present
    integer                :: urr_inelastic
    type(UrrData), pointer :: urr_data => null()

    ! Reactions
    integer :: n_reaction ! # of reactions
    type(Reaction), pointer :: reactions(:) => null()
    
    ! Type-Bound procedures
    contains
      procedure :: clear => nuclide_clear ! Deallocates Nuclide
  end type Nuclide

!===============================================================================
! SALPHABETA contains S(a,b) data for thermal neutron scattering, typically off
! of light isotopes such as water, graphite, Be, etc
!===============================================================================
     
  type SAlphaBeta
    character(10) :: name ! name of table, e.g. lwtr.10t
    integer       :: zaid ! Z and A identifier, e.g. 6012 for Carbon-12
    real(8)       :: awr  ! weight of nucleus in neutron masses
    real(8)       :: kT   ! temperature in MeV (k*T)

    ! threshold for S(a,b) treatment (usually ~4 eV)
    real(8) :: threshold_inelastic
    real(8) :: threshold_elastic = 0.0

    ! Inelastic scattering data
    integer :: n_inelastic_e_in  ! # of incoming E for inelastic
    integer :: n_inelastic_e_out ! # of outgoing E for inelastic
    integer :: n_inelastic_mu    ! # of outgoing angles for inelastic
    integer :: secondary_mode    ! secondary mode (equal/skewed)
    real(8), allocatable :: inelastic_e_in(:)
    real(8), allocatable :: inelastic_sigma(:) 
    real(8), allocatable :: inelastic_e_out(:,:)
    real(8), allocatable :: inelastic_mu(:,:,:)

    ! Elastic scattering data
    integer :: elastic_mode   ! elastic mode (discrete/exact)
    integer :: n_elastic_e_in ! # of incoming E for elastic
    integer :: n_elastic_mu   ! # of outgoing angles for elastic
    real(8), allocatable :: elastic_e_in(:)
    real(8), allocatable :: elastic_P(:)
    real(8), allocatable :: elastic_mu(:,:)
  end type SAlphaBeta

!===============================================================================
! XSLISTING contains data read from a cross_sections.xml file
!===============================================================================

  type XsListing
    character(12) :: name       ! table name, e.g. 92235.70c
    character(12) :: alias      ! table alias, e.g. U-235.70c
    integer       :: type       ! type of table (cont-E neutron, S(A,b), etc)
    integer       :: zaid       ! ZAID identifier = 1000*Z + A
    integer       :: filetype   ! ASCII or BINARY
    integer       :: location   ! location of table within library
    integer       :: recl       ! record length for library
    integer       :: entries    ! number of entries per record
    real(8)       :: awr        ! atomic weight ratio (# of neutron masses)
    real(8)       :: kT         ! Boltzmann constant * temperature (MeV)
    logical       :: metastable ! is this nuclide metastable?
    character(MAX_FILE_LEN) :: path ! path to library containing table
  end type XsListing

  contains

!===============================================================================
! DISTANGLE_CLEAR resets and deallocates data in Reaction.
!===============================================================================    
  
    subroutine distangle_clear(this)
      
      class(DistAngle), intent(inout) :: this ! The DistAngle object to clear
      
      if (allocated(this % energy)) &
           deallocate(this % energy, this % type, this % location, this % data)
      
    end subroutine distangle_clear    

!===============================================================================
! DISTENERGY_CLEAR resets and deallocates data in DistEnergy.
!===============================================================================    
  
    recursive subroutine distenergy_clear(this)
      
      class(DistEnergy), intent(inout) :: this ! The DistEnergy object to clear
      
      ! Clear p_valid
      call this % p_valid % clear()
      
      if (allocated(this % data)) &
           deallocate(this % data)
        
      if (associated(this % next)) then
        ! recursively clear this item
        call this % next % clear()
        deallocate(this % next)
      end if
      
    end subroutine distenergy_clear
    
!===============================================================================
! REACTION_CLEAR resets and deallocates data in Reaction.
!===============================================================================    
  
    subroutine reaction_clear(this)
      
      class(Reaction), intent(inout) :: this ! The Reaction object to clear
      
      if (allocated(this % sigma)) &
           deallocate(this % sigma)
      
      if (associated(this % edist)) then
        call this % edist % clear()
        deallocate(this % edist)
      end if
        
      call this % adist % clear()
      
    end subroutine reaction_clear    
    
!===============================================================================
! URRDATA_CLEAR resets and deallocates data in Reaction.
!===============================================================================    
  
    subroutine urrdata_clear(this)
      
      class(UrrData), intent(inout) :: this ! The UrrData object to clear
      
      if (allocated(this % energy)) &
           deallocate(this % energy, this % prob)
      
    end subroutine urrdata_clear      

!===============================================================================
! NUCLIDE_CLEAR resets and deallocates data in Nuclide.
!===============================================================================    
  
    subroutine nuclide_clear(this)
      
      class(Nuclide), intent(inout) :: this ! The Nuclide object to clear
      
      integer :: i ! Loop counter
      
      if (allocated(this % grid_index)) &
           deallocate(this % grid_index)
      
      if (allocated(this % energy)) &
           deallocate(this % total, this % elastic, this % fission,  &
          this % nu_fission, this % absorption)
      if (allocated(this % heating)) &
           deallocate(this % heating)
      
      if (allocated(this % index_fission)) &
           deallocate(this % index_fission)
        
      if (allocated(this % nu_t_data)) &
           deallocate(this % nu_t_data)
        
      if (allocated(this % nu_p_data)) &
           deallocate(this % nu_p_data)
        
      if (allocated(this % nu_d_data)) &
           deallocate(this % nu_d_data)
        
      if (allocated(this % nu_d_precursor_data)) &
           deallocate(this % nu_d_precursor_data)
        
      if (associated(this % nu_d_edist)) then
        do i = 1, size(this % nu_d_edist)
          call this % nu_d_edist(i) % clear()
        end do
        deallocate(this % nu_d_edist)
      end if
      
      if (associated(this % urr_data)) then
        call this % urr_data % clear()
        deallocate(this % urr_data)
      end if
      
      if (associated(this % reactions)) then
        do i = 1, size(this % reactions)
          call this % reactions(i) % clear()
        end do
        deallocate(this % reactions)
      end if
      
    end subroutine nuclide_clear    

end module ace_header
