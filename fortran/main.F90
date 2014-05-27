program main
  use global
  use constants
  use ace
  implicit none

  ! Directory containing ACE files (read from command line arg)
  character(len=1028) :: data_dir
  ! Size of global 'nuclides' array
  integer, parameter  :: n_nuclides = 2
  ! Size of global 'sab_table' array
  integer, parameter  :: n_sab = 0
  ! Size of global 'xs_listings' array
  integer, parameter  :: n_listings = n_nuclides + n_sab
  ! Loop controls
  integer             :: i,j

  ! Get command line arg
  call get_command_argument(1, data_dir)

  ! Stop if no arg is given
  if (len_trim(data_dir) .eq. 0) then
    print *, 'USAGE:  ./main data_dir'
    print *, '    where data_dir is directory containing the ACE library files'
    stop
  endif
  
  ! Add trailing slash 
  if (data_dir(len_trim(data_dir):len_trim(data_dir)) .ne. '/') then
    data_dir = trim(data_dir) // '/'
  endif

  ! Allocate global arrays
  allocate(xs_listings(n_listings))
  allocate(nuclides(n_nuclides))

  ! Poppulate xs_listings
  xs_listings(1) % name = '92234.70c'
  xs_listings(1) % type = ACE_NEUTRON
  xs_listings(1) % filetype = BINARY
  xs_listings(1) % location = 5781
  xs_listings(1) % recl = 4096
  xs_listings(1) % entries = 512
  xs_listings(1) % path = trim(data_dir) // 'endf70j'

  xs_listings(2) % name = '1001.70c'
  xs_listings(2) % type = ACE_NEUTRON
  xs_listings(2) % filetype = BINARY
  xs_listings(2) % location = 1
  xs_listings(2) % recl = 4096
  xs_listings(2) % entries = 512
  xs_listings(2) % path = trim(data_dir) // 'endf70a'

  ! Read each xs_listings into nuclides
  call read_ace_table(1, 1)
  call read_ace_table(2, 2)

  ! Print results to file
  call print_nuclides_info('nuclides_info.txt')
  call print_nuclides_values('nuclides_values.txt')

contains

  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ! PRINT_NUCLIDES_INFO will output the sizes of all the allocatable arrays
  ! for each Nuclide in the global nuclides array
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  subroutine print_nuclides_info(filename)
      character(*), intent(in) :: filename    ! name of the output file
      integer :: i
      type(Nuclide), pointer :: n => null()   ! pointer to Nuclide

      ! Unit number has no significance -- I just chose a weird one so as not to
      !   conflict with existing unit numbers in OpenMC
      open(unit=857, file=filename, status='replace')
      ! Write header
      write(857, '(17a12)') 'name', 'n_grid', 'grid_index', 'energy', 'total', &
          'elastic', 'fission', 'nu_fission', 'absorption', 'heating', &
          'index_fission', 'nu_t_data', 'nu_p_data', 'nu_d_data', &
          'nu_d_precursor_data', 'nu_d_edist', 'reactions'
      ! Write sizes of all allocatable arrays in nuclide
      do i = 1, n_nuclides
        n => nuclides(i)
        write(857, '(a12, 16i12)') n % name, n % n_grid, size(n % grid_index), &
            size(n % energy), size(n % total), size(n % elastic), &
            size(n % fission), size(n % nu_fission), size(n % absorption), &
            size(n % heating), size(n % index_fission), size(n % nu_t_data), &
            size(n % nu_p_data), size(n % nu_d_data), &
            size(n % nu_d_precursor_data), size(n % nu_d_edist), size(n % reactions)
      enddo
      close(unit=857)
  end subroutine print_nuclides_info

  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ! PRINT_NUCLIDES_VALUES will print the the values of all elements in the 
  ! energy, total, elastic, fission, and absorbtipon arrays for every Nuclide in 
  ! the global Nuclides array (in ASCII formatted table)
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  subroutine print_nuclides_values(filename)
      character(*), intent(in) :: filename    ! name of the output file
      integer :: i
      type(Nuclide), pointer :: n => null()   ! pointer to Nuclide

      ! Unit number has no significance -- I just chose a weird one so as not to
      !   conflict with existing unit numbers in OpenMC
      open(unit=857, file=filename, status='replace')
      write(857, *) n_nuclides
      do i = 1, n_nuclides
        n => nuclides(i)
        write(857, *) n % name, n % n_grid, n % energy, n % total, n % elastic, &
            n % fission, n % absorption
      enddo
      close(unit=857)
  end subroutine print_nuclides_values

end program main
