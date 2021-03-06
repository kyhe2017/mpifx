include(mpifx_constants.m4)

!> Exports some MPI constants.
!! \cond HIDDEN
module mpifx_constants_module
  use mpi
  private

  public :: MPI_MAX, MPI_MIN, MPI_SUM, MPI_PROD
  public :: MPI_LAND, MPI_BAND, MPI_LOR, MPI_BOR, MPI_LXOR ,MPI_BXOR
  public :: MPI_MAXLOC, MPI_MINLOC
  
end module mpifx_constants_module

!> \endcond
