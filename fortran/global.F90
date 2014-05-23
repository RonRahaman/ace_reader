module global

  use ace_header

  implicit none
  save

  ! Cross section arrays
  type(Nuclide),    allocatable, target :: nuclides(:)    ! Nuclide cross-sections
  type(SAlphaBeta), allocatable, target :: sab_tables(:)  ! S(a,b) tables
  type(XsListing),  allocatable, target :: xs_listings(:) ! cross_sections.xml listings 

end module global
