module mexinterface
  use, intrinsic :: iso_c_binding

  interface

    function mxgetpr(pm)
      import c_ptr
      integer :: pm
      type(c_ptr) :: mxgetpr
    end function mxgetpr

    function mxgetm(pm)
      integer :: pm, mxgetm
    end function mxgetm

    function mxgetn(pm)
      integer pm, mxgetn
    end function mxgetn

    function mxcreatedoublematrix(m, n, type)
      integer m, n, type, mxcreatedoublematrix
    end function mxcreatedoublematrix

    subroutine mexerrmsgtxt(s)
      character s(*)
    end subroutine mexerrmsgtxt

    subroutine mexprintf(s)
      character s(*)
    end subroutine mexprintf

  end interface
end module mexinterface
