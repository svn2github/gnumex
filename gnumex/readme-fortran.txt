SOME COMMENTS ON FORTRAN MEX FILES

INTRODUCTION
  This document extends the information in the accompanying file
  README. Gnumex currently (2007/2008) supports both g77 and g95 (with
  MinGW), but not gfortran. The following guidelines may help clear
  things regarding Fortran programs.

FORTRAN FILE EXTENSIONS
  Fortran 77 programs and fortran  should have the extension .f but Fortran 95
  programs 

CASE OPTIONS AND TRAILING UNDERSCORES
  Gnumex uses the compile switches -fcase-upper and -fno-underscoring
  (which both g77 and g95 support). The first means that exported
  symbols are translated to all-upper-case in the created .obj files
  (the case used in the source file is thus irrelevant), and the
  second means that trailing underscores are not added to these
  symbols (which is otherwise the default). The Fortran mx and
  mex-functions of Matlab have all-uppercase names (despite the Matlab
  documentation and demos using mixed-case for them) and do not have
  trailing underscores. If Fortran programs are called from C they
  must therefore be called with all-uppercase. It would be possible to
  change to using the switch -fcase-preserve, and then C and Fortran
  could be mixed more freely (e.g. by calling C-functions that are not
  all-upper-case from Fortran), but then the gateway routine and all
  mx and mex functions used must be spelled with all-upper-case
  (MEXFUNCTION and MXGETPR for example). As -fcase-lower folds
  everything to lower case it is not very useful in this context.

  The reason (or at least one of the reasons) why gfortran does not
  currently work is that it does not offer the -fcase switches, and in
  fact defaults to the behaviour of -fcase-lower.

POINTERS AND %VAL
  Matlab sends integer memory addresses (pointers) to the gateway
  routine and these must be translated to arrays. In g77 the construct
  %val may be used, but in g95 it is possible to use the native
  pointers. The demonstration programs give examples.

DEMONSTRATION PROGRAMS
  The demo Fortran programs that come with Matlab some use the %val
  construct but others use instead the functions mxCopyPtrToXXX and
  mxCopyXXXToPtr. With g77 it is much simpler to stick with the %val
  construct. The example gateway routine of Matlab, yprimefg.f (in
  <matlabroot>\extern\examples\mex) is totally incompatible with both
  g77 and g95. However with Gnumex there are routines, yprime77.f and
  yprime95.f90 which are compatible. The first one calls the
  computational routine in yprimef.f90, but the second contains a
  module with a computational routine that is called (the yprimef.f
  that comes with Matlab is actually g77-compatible, but for
  convenience a similar routine is enclosed with Gnumex).

  To try out Fortran mexing use Gnumex to create an options.bat file
  for Fortran, compile with mex and call yprime77 or yprime95. From
  the Matlab prompt one can for instance issue:

      >> gnumex fortran77
      >> mex yprime77.f yprimef.f
      >> yprime77(1, 1:4)
 
  or:
      >> gnumex fortran95
      >> mex yprime95.f90
      >> yprime77(1, 1:4)

  and should receive the answer: 2.0000  8.9685  4.0000  -1.0947.
