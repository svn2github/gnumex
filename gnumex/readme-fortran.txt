SOME COMMENTS ON FORTRAN MEX FILES

The following guidelines may help clear things regarding Fortran programs.
Gnumex uses the compile switches -fcase-upper and -fno-underscoring. The first
means that all exported symbols are translated to all-upper-case in the
created .obj files (the case used in the source file is thus irrelevant), and
the second means that trailing underscores are not added to these symbols
(which is otherwise the default). The Fortran mx and mex-functions of Matlab
have all-uppercase names (despite the Matlab documentation and demos using
mixed-case for them) and do not have trailing underscores. If Fortran programs
are called from C they must therefore be called with all-uppercase. It would
be possible to change to using the switch –fcase-preserve, and then C and
Fortran could be mixed more freely (e.g. by calling C-functions that are not
all-upper-case from Fortran), but then the gateway routine and all mx and mex
functions used must be spelled with all-upper-case (MEXFUNCTION and MXGETPR for
example). As –fcase-lower folds everything to lower case it is not very useful
in this context.

As Matlab sends integer memory addresses (pointers) to the gateway routine,
these must be translated to arrays and in g77 the construct %val may be used.
The demo Fortran programs that come with Matlab some use this construct,
others use instead the functions mxCopyPtrToXXX and mxCopyXXXToPtr. With g77 it
is much simpler to stick with the %val construct. The example gateway routine of
Matlab, yprimefg.f (in <matlabroot>\extern\examples\mex) is totally incompatible
with g77. However with Gnumex there is a routine, yprime_g77.f which is
compatible. This gateway routine calls the computational routine yprimef.f (the
one that comes with Matlab is actually g77-compatible, but for convenience a
similar routine is enclosed with Gnumex). To try out Fortran mexing use Gnumex
to create an options.bat file for Fortran, compile with mex and call yprime_g77.
From the Matlab prompt one can for instance issue:

    >> gnumex fortran
    >> mex yprime_g77.f yprimef.f
    >> yprime_g77(1, 1:4)

and should receive the answer yp = 2.0000  8.9685  4.0000  -1.0947.
