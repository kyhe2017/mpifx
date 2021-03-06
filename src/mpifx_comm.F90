include(mpifx_comm.m4)

!> Contains the extended MPI communicator.
module mpifx_comm_module
  use mpifx_helper_module
  use mpi
  implicit none
  private

  public :: mpifx_comm

  !> MPI communicator with some additional information.
  type mpifx_comm
    integer :: id         !< Communicator id.
    integer :: size       !< Nr. of processes (size).
    integer :: rank       !< Rank of the current process.
    integer :: masterrank !< Index of the master node.
    logical :: master     !< True if current process is the master (rank == 0).
  contains
    !> Initializes the MPI environment.
    procedure :: init => mpifx_comm_init

    !> Creates a new communicator by splitting the old one.
    procedure :: split => mpifx_comm_split

  end type mpifx_comm

contains

  !> Initializes a communicator to contain all processes.
  !!
  !! \param self  Initialized instance on exit.
  !! \param commid  MPI Communicator ID (default: \c MPI_COMM_WORLD)
  !! \param error  Error flag on return containing the first error occuring
  !!     during the calls mpi_comm_size and mpi_comm_rank.
  !!
  subroutine mpifx_comm_init(self, commid, error)
    class(mpifx_comm), intent(out) :: self
    integer, intent(in), optional :: commid
    integer, intent(out), optional :: error

    integer :: error0

    _handle_inoptflag(self%id, commid, MPI_COMM_WORLD)
    call mpi_comm_size(self%id, self%size, error0)
    call handle_errorflag(error0, "mpi_comm_size() in mpifx_comm_init()", error)
    if (error0 /= 0) then
      return
    end if
    call mpi_comm_rank(self%id, self%rank, error0)
    call handle_errorflag(error0, "mpi_comm_rank() in mpifx_comm_init()", error)
    if (error0 /= 0) then
      return
    end if
    self%masterrank = 0
    self%master = (self%rank == self%masterrank)
    
  end subroutine mpifx_comm_init

  !> Creates a new communicators by splitting the old one.
  !!
  !! \param self  Communicator instance.
  !! \param splitkey  Key for the splitting. Processes invoking the routine
  !!     with the same value for splitkey will be belong to the same
  !!     communicator.
  !! \param rankkey  Is used to determine the rank of the process in its new
  !!     communicator. Processes calling the routine with a higher value will
  !!     have a higher rank in the new communicator.
  !! \param newcomm  New communicator for the given process.
  !! \param error  Optional error code on return.
  !!
  !! Example:
  !!
  !!     program test_split
  !!       use libmpifx_module
  !!       implicit none
  !!     
  !!       type(mpifx_comm) :: allproc, groupproc
  !!       integer :: groupsize, mygroup
  !!     
  !!       call mpifx_init()
  !!       call allproc%init()
  !!       groupsize = allproc%size / 2
  !!       mygroup = allproc%rank / groupsize
  !!       call allproc%split(mygroup, allproc%rank, groupproc)
  !!       write(*, "(3(A,1X,I0,1X))") "ID:", allproc%rank, "SUBGROUP", &
  !!           & mygroup, "SUBGROUP ID", groupproc%rank
  !!       call mpifx_finalize()
  !!       
  !!     end program test_split
  !!       
  !! \see MPI documentation (\c MPI_COMM_SPLIT)
  !!
  subroutine mpifx_comm_split(self, splitkey, rankkey, newcomm, error)
    class(mpifx_comm), intent(inout) :: self
    integer, intent(in) :: splitkey, rankkey
    class(mpifx_comm), intent(out) :: newcomm
    integer, intent(out), optional :: error

    integer :: error0, newcommid
    
    call mpi_comm_split(self%id, splitkey, rankkey, newcommid, error0)
    call handle_errorflag(error0, "mpi_comm_split() in mpifx_comm_split()",  &
        & error)
    if (error0 /= 0) then
      return
    end if
    call newcomm%init(newcommid, error)

  end subroutine mpifx_comm_split
    
  
end module mpifx_comm_module
