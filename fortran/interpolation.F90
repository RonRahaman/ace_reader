module interpolation

  use constants
  use endf_header, only: Tab1
  use search,      only: binary_search
  use string,      only: to_str

  implicit none

  interface interpolate_tab1
    module procedure interpolate_tab1_array
  end interface interpolate_tab1

contains

!===============================================================================
! INTERPOLATE_TAB1_ARRAY interpolates a function between two points based on
! particular interpolation scheme. The data needs to be organized as a ENDF TAB1
! type function containing the interpolation regions, break points, and
! tabulated x's and y's.
!===============================================================================

  function interpolate_tab1_array(data, x, loc_start) result(y)

    real(8), intent(in)           :: data(:)   ! array of data
    real(8), intent(in)           :: x         ! x value to find y at
    integer, intent(in), optional :: loc_start ! starting location in data
    real(8)                       :: y         ! y(x)

    integer :: i               ! bin in which to interpolate
    integer :: j               ! index for interpolation region
    integer :: loc_0           ! starting location
    integer :: n_regions       ! number of interpolation regions
    integer :: n_points        ! number of tabulated values
    integer :: interp          ! ENDF interpolation scheme
    integer :: loc_breakpoints ! location of breakpoints in data
    integer :: loc_interp      ! location of interpolation schemes in data
    integer :: loc_x           ! location of x's in data
    integer :: loc_y           ! location of y's in data
    real(8) :: r               ! interpolation factor
    real(8) :: x0, x1          ! bounding x values
    real(8) :: y0, y1          ! bounding y values

    ! determine starting location
    if (present(loc_start)) then
      loc_0 = loc_start - 1
    else
      loc_0 = 0
    end if

    ! determine number of interpolation regions
    n_regions = int(data(loc_0 + 1))

    ! set locations for breakpoints and interpolation schemes
    loc_breakpoints = loc_0 + 1
    loc_interp      = loc_breakpoints + n_regions

    ! determine number of tabulated values
    n_points  = int(data(loc_interp + n_regions + 1))

    ! set locations for x's and y's
    loc_x = loc_interp + n_regions + 1
    loc_y = loc_x + n_points

    ! find which bin the abscissa is in -- if the abscissa is outside the
    ! tabulated range, the first or last point is chosen, i.e. no interpolation
    ! is done outside the energy range
    if (x < data(loc_x + 1)) then
      y = data(loc_y + 1)
      return
    elseif (x > data(loc_x + n_points)) then
      y = data(loc_y + n_points)
      return
    else
      i = binary_search(data(loc_x + 1:loc_x + n_points), n_points, x)
    end if

    ! determine interpolation scheme
    if (n_regions == 0) then
      interp = LINEAR_LINEAR
    elseif (n_regions == 1) then
      interp = int(data(loc_interp + 1))
    elseif (n_regions > 1) then
      do j = 1, n_regions
        if (i < data(loc_breakpoints + j)) then
          interp = int(data(loc_interp + j))
          exit
        end if
      end do
    end if

    ! handle special case of histogram interpolation
    if (interp == HISTOGRAM) then
      y = data(loc_y + i)
      return
    end if

    ! determine bounding values
    x0 = data(loc_x + i)
    x1 = data(loc_x + i + 1)
    y0 = data(loc_y + i)
    y1 = data(loc_y + i + 1)

    ! determine interpolation factor and interpolated value
    select case (interp)
    case (LINEAR_LINEAR)
      r = (x - x0)/(x1 - x0)
      y = (1 - r)*y0 + r*y1
    case (LINEAR_LOG)
      r = (log(x) - log(x0))/(log(x1) - log(x0))
      y = (1 - r)*y0 + r*y1
    case (LOG_LINEAR)
      r = (x - x0)/(x1 - x0)
      y = exp((1-r)*log(y0) + r*log(y1))
    case (LOG_LOG)
      r = (log(x) - log(x0))/(log(x1) - log(x0))
      y = exp((1-r)*log(y0) + r*log(y1))
    case default
      print *, "Unsupported interpolation scheme: " // to_str(interp)
      stop
    end select

  end function interpolate_tab1_array

end module interpolation
