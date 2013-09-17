program mini_reader_f

implicit none

integer, parameter :: in = 500

integer :: NXS(16)             ! Descriptors for ACE XSS tables
integer :: JXS(32)             ! Pointers into ACE XSS tables
real(8), allocatable :: XSS(:) ! Cross section data
character(len=:), allocatable :: filename
integer :: record_length
integer :: location

! values taken from cross_sections.xml
filename = 'endf70a'
location = 1
record_length = 4096

call read_ace_table(filename, record_length, location)

contains


! =======================================================================
! from openmc/sr/ace.f90:read_ace_table()

subroutine read_ace_table(filename, record_length, location)

  character(len=*), intent(in) :: filename ! path to ACE cross section library
  integer, intent(in)          :: record_length ! Fortran record length
  integer, intent(in)          :: location      ! location of ACE table

  integer       :: i             ! loop index for XSS records
  integer       :: j, j1, j2     ! indices in XSS

  character(10) :: name          ! name of ACE table
  real(8)       :: awr           ! atomic weight ratio for table
  real(8)       :: kT            ! temperature of table
  character(10) :: date_         ! date ACE library was processed
  character(70) :: comment       ! comment for ACE table
  character(10) :: mat           ! material identifier
  integer       :: zaids(16)     ! list of ZAIDs (only used for S(a,b))
  real(8)       :: awrs(16)      ! list of atomic weight ratios (not used)
  integer       :: length        ! length of ACE table
  integer       :: entries       ! number of entries on each record

  ! Open ACE file
  open(UNIT=in, FILE=filename, STATUS='old', ACTION='read', &
    ACCESS='direct', RECL=record_length)

  ! Read all header information
  read(UNIT=in, REC=location) name, awr, kT, date_, & 
    comment, mat, (zaids(i), awrs(i), i=1,16), NXS, JXS

!   ! determine table length
!   length = NXS(1)
!   allocate(XSS(length))

!   ! Read remaining records with XSS
!   do i = 1, (length + entries - 1)/entries
!     j1 = 1 + (i-1)*entries
!     j2 = min(length, j1 + entries - 1)
!     read(UNIT=IN, REC=location + i) (XSS(j), j=j1,j2)
!   end do

  ! Close ACE file
  close(UNIT=in)

end subroutine read_ace_table

end program mini_reader_f
