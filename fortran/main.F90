program main
  use global
  use constants
  use ace
  implicit none

  allocate(xs_listings(1))
  allocate(nuclides(1))

  xs_listings(1) % name = '1001.70c'
  ! xs_listings(1) % alias = "H-1.70c" 
  xs_listings(1) % type = ACE_NEUTRON
  ! xs_listings(1) % zaid = "1001"
  xs_listings(1) % filetype = BINARY
  xs_listings(1) % location = 1
  xs_listings(1) % recl = 4096
  xs_listings(1) % entries = 512
  ! xs_listings(1) % awr = "0.999167" 
  ! xs_listings(1) % kT = 
  ! xs_listings(1) % metastable = 
  xs_listings(1) % path = '/homes/rahaman/data/endf70a'

  call read_ace_table(1, 1)

end program main
