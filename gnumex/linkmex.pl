# '--*-Perl-*--';
# linkmex.pl
#
# perl script to link mex file dll / engine file exe
# create library files if not using precompiled libraries
# create temporary files for dll creation
# create dll / exe
# delete temporary files


$mtype    = $ENV{'GM_MEXTYPE'};   # mex or engine
$lang     = $ENV{'GM_MEXLANG'};   # c or Fortran
$gmpath   = $ENV{'GM_UTIL_PATH'}; # gnumex path
$dllcmd   = $ENV{'GM_DLLTOOL'};   # dlltool command
$addlibs  = $ENV{'GM_ADD_LIBS'};  # added libraries
$compiler = $ENV{'COMPILER'};     # gcc, g95 or gfortran


# Use precompiled files or create libraries if needed
@libs = ($ENV{GM_DEFS2LINK} =~ /([\w\.]+);/g);
if ($ENV{'GM_QLIB_NAME'} ne "") {
  if ($lang eq 'f' || $lang eq 'f77' | $lang eq 'f95' ) { $libroot = 'f' . $mtype }
  else { $libroot = $mtype } ;
  $libname = $ENV{'GM_QLIB_NAME'}. "\\${libroot}lib";
} else {
  # doh! We'll have to create them
  $libname = $ENV{'LIB_NAME'};
  $defpath = $ENV{'GM_DEF_PATH'};
  $libno = 1;
  foreach $lib(@libs) {
    $cmd = "$dllcmd --def $defpath\\$lib --output-lib \"${libname}${libno}.lib\"";
    $message = `$cmd`;
    print $message unless ($message eq "");
    $libno += 1;
  }
}
for $libno(1..$#libs+1) {
  $libnames[$libno] = "\"${libname}${libno}.lib\"";
}

# collect correct linker
$arglist = join(" ", @ARGV);

if ($lang eq 'c') {
  # meed g++ if this is c++
  # unfortunately you cannot directly set a different linker
  # for c++ from the options file, so we'll use the GM_ISCPP
  # word passed to the linker as an indicator
  # (and remove it)
  $iscppf = $arglist =~ s/GM_ISCPP//;
  if ($mtype eq "mex") {
    if ($iscppf) {
      $linker = 'g++ -shared';
    } else {
      $linker = 'gcc -shared';
    }
  } else { # engine
    $linker = "g++";
  }
} elsif ($lang eq 'f' || $lang eq 'f77') { # fortran 77
  if ($mtype eq "mex") {
    $linker = 'g77 -shared';
  } else {
    $linker = "g77";
  }
} else { # Fortran 95 (g95 or gfortran)
  if ($mtype eq "mex") {
    $linker = $compiler . ' -shared';
  } else {
    $linker = $compiler;
  }
} 

if ($mtype eq 'mex') {
  # Create .def file for our MEX file
  $fn = "mex.def";
  unlink $fn;
  unless (open (FN,">$fn")) {die "Can't open $fn $!";}
  if ($lang eq 'c') {
    printf FN "EXPORTS\nmexFunction\n";
  } else {
    printf FN "EXPORTS\n";
    printf FN "_MEXFUNCTION\@16=MEXFUNCTION\n";
  }
  close FN;
  
  # Create fixup.o which may be needed (certainly W95, possibly W98) to
  # terminate the import list
  # $fn = "fixup.c";
  # unlink $fn;
  # unless (open (FN,">$fn")) {die "Can't open $fn $!";}
  # printf FN "asm(\".section .idata\$3\");\n";
  # printf FN "asm(\".long 0,0,0,0, 0,0,0,0\");\n";
  # close FN;
  # $cmd = "gcc -c -o fixup.o fixup.c";
  # $message = `$cmd`;
  # print $message unless ($message eq "");
  
  # command to make mex dll
  $cmd = join(" ", $linker, 'mex.def', $arglist, $addlibs, @libnames);
  # $cmd = join(" ", $linker, 'mex.def', $arglist, 'fixup.o', $addlibs, @libnames);
} else { # engine file
  $cmd = join(" ", $linker,$arglist, @libnames, 
	      '-lkernel32','-luser32','-lgdi32',$addlibs,'-mwindows');
}

# print command (will only be printed if -v switch is given with mex):
print $cmd . "\n";

# execute via backticks (system doesn't work on W9x)
$message = `$cmd`;

#if ($mtype eq 'mex') {
# Cleanup
#  unlink "mex.def", "fixup.c", "fixup.o";
#}
