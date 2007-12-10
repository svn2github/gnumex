module mexinterface
  use, intrinsic :: ISO_C_BINDING
  interface
    function mxgetpr(pm) bind(c, name = 'MXGETPR')
      import c_int, c_ptr
      integer(c_int) :: pm
      type(c_ptr) mxgetpr
    end function mxgetpr
    !
    function mxgetm(pm) bind(c, name = 'MXGETM')
      import c_int
      integer(c_int) :: pm, mxgetm
    end function mxgetm
    !
    function mxgetn(pm) bind(c, name = 'MXGETN')
      import c_int
      integer(c_int) pm, mxgetn
    end function mxgetn
    !
    function mxcreatedoublematrix(m,n,type) bind(c, name = 'MXCREATEDOUBLEMATRIX')
      import c_int
      integer(c_int) m, n, type, mxcreatedoublematrix
    end function mxcreatedoublematrix
    !
    subroutine mexerrmsgtxt(s) bind(C, name = 'MEXERRMSGTXT')
      import c_char
      character(c_char) s(*)
    end subroutine mexerrmsgtxt
    !
    subroutine mexprintf(s) bind(C, name = 'MEXPRINTF')
      import c_char
      character(c_char) s(*)
    end subroutine mexprintf
    !
  end interface
end module mexinterface
