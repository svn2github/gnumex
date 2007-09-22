% MAKEDEF  Make def-files for use with gnumex
%
%   MAKEDEF() uses nm to extract the names of mex-, mx- and mat-functions from
%   .lib-files in Matlab's lcc library folder and writes them to .def files in
%   the current folder. These .def-files can then be used as input to dlltool
%   to create .lib-files in a format apropriate for gcc. From version 7.4 of
%   Matlab no def-files come with matlat, but this functions provides a
%   workaround. It is assumed that the unix utility nm is on the dos-path (it is
%   supplied with both cygwin and mingw). (Kristjan Jonasson, jonasson@hi.is,
%   2007)

function makedef()
   libs = {'libmex', 'libmx', 'libmat'};
   libdir = [matlabroot '\extern\lib\win32\lcc\'];
   for i=1:length(libs)
      lib = libs{i};
      [err,list] = dos(['nm -g --defined-only "' libdir lib '.lib"']);
      if err, error('extracting symbols from lib-file failed'); end
      tok = textscan(list,'%*s%s%s%*[^\n]');
      code = char(tok{1});
      symbols = tok{2}(code=='T');
      fp = fopen([lib '.def'], 'w');
      fprintf(fp, 'LIBRARY %s.dll\nEXPORTS\n', lib);
      J = strmatch('_', symbols)';
      for j = J, symbols{j}(1) = ''; end
      for j = 1:length(symbols), fprintf(fp,'%s\n', symbols{j}); end
      fclose(fp);
   end
end
