# '--*-Perl-*--';
# linkmex.pl
#
# perl script to link mex file dll / engine file exe
# create library files if not using precompiled libraries
# create temporary files for dll creation
# create dll / exe
# delete temporary files

# mex or engine
$mtype = $ENV{'GM_MEXTYPE'};
# c or Fortran
$lang  = $ENV{'GM_MEXLANG'};
# gnumex path
$gmpath = $ENV{'GM_UTIL_PATH'};
# dlltool command
$dllcmd = $ENV{'GM_DLLTOOL'};
# added libraries
$addlibs = $ENV{'GM_ADD_LIBS'};

# Use precompiled files or create libraries if needed
@libs = ($ENV{GM_DEFS2LINK} =~ /([\w\.]+);/g);
if ($ENV{'GM_QLIB_NAME'} ne "") {
    if ($lang eq 'f') { $libroot = 'f' . $mtype }
    else { $libroot = $mtype } ;
    $libname = $ENV{'GM_QLIB_NAME'}. "\\${libroot}lib";
} else {
    # doh! We'll have to create them
    $libname = $ENV{'LIB_NAME'};
    $mlpath = $ENV{'MATLAB'};
    $libno = 1;
    foreach $lib(@libs) {
	$cmd = "$dllcmd --def $mlpath\\extern\\include\\$lib" .
	    " --output-lib \"${libname}${libno}.lib\"";
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
} else { # fortran
  if ($mtype eq "mex") {
    $linker = 'g77 -shared';
  } else {
    $linker = "g77";
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
  $fn = "fixup.c";
  unlink $fn;
  unless (open (FN,">$fn")) {die "Can't open $fn $!";}
  printf FN "asm(\".section .idata\$3\");\n";
  printf FN "asm(\".long 0,0,0,0, 0,0,0,0\");\n";
  close FN;
  $cmd = "gcc -c -o fixup.o fixup.c";
  $message = `$cmd`;
  print $message unless ($message eq "");
  
  # command to make mex dll
  $cmd = join(" ", $linker, 'mex.def', $arglist,
	      'fixup.o', $addlibs, @libnames);
} else { # engine file
  $cmd = join(" ", $linker,$arglist, @libnames, 
	      '-lkernel32','-luser32','-lgdi32',$addlibs,'-mwindows');
}

# execute via backticks (system doesn't work on W9x)
# print $cmd . "\n";
$message = `$cmd`;

if ($mtype eq 'mex') {
# Cleanup
  unlink "mex.def", "fixup.c", "fixup.o";
}
