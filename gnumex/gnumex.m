function varargout = gnumex(varargin)
  % mex bat options file creator for cygwin / mingw gcc
  %
  % Updated for matlab version 6, rationalized perl
  % Facility for added libraries, Fortran engine compilation
  % Matthew Brett 3/5/2000 (DB), 9/7/2001 (PJ), 19/7/02 (RBH)
  %
  % Copyright 2000 Free Software Foundation, Inc.
  % This program is free software; you can redistribute it and/or modify
  % it under the terms of the GNU General Public License as published by
  % the Free Software Foundation; either version 2 of the License, or
  % (at your option) any later version.

  % current version number
  VERSION = 1.11;
  mlv = sscanf(version,'%f',1); % MATLAB VERSION
  if mlv < 5
    error('gnumex will not work for versions before 5.0');
  end

  if nargin < 1
    action = 'startup';
  else
    action = lower(varargin{1});
  end

  if strcmp(action, 'version')
    varargout = {VERSION};

  elseif strcmp(action, 'startup')
    % initialises window, controls, sets callbacks

    ounits = get(0, 'Units');
    set(0, 'Units', 'points');
    sz = get(0, 'Screensize');
    set(0, 'Units', ounits);

    % size of gnumex window, in points
    gm_sz = [335 414];

    cygfig = figure('Color',[0.8 0.8 0.8], ...
      'Name', 'Gnumex mex opt file setup',...
      'NumberTitle','off',...
      'Units','points', ...
      'Position',[sz(3:4)/2-[200 155] gm_sz], ...
      'Resize', 'off',...
      'Menubar','none', ...
      'Tag','cygfig');

    % will contain all the GUI objects with useful values
    actfig = [];

    % path browse callback
    if mlv >= 7.4
      pbrowsecb = ['f=get(gcbo,''UserData'');' ...
        'p=uigetpath74(get(f,''UserData''));' ...
        'if ~isempty(p),set(f,''String'',p),end'];
    else
      pbrowsecb = ['f=get(gcbo,''UserData'');' ...
        'p=uigetpath(get(f,''UserData''));' ...
        'if ~isempty(p),set(f,''String'',p),end'];
    end
    % file browse callback
    fbrowsecb = ['f=get(gcbo,''UserData'');' ...
      '[fn p]=uiputfile(get(f, ''String''), get(f,''UserData''));' ...
      'fprintf(''%s'', pwd);'...
      'cd(pwd);if (fn~=0),set(f,''String'',fullfile(p, fn));end'];

    % control vs label vertical offsets
    utxto = -17;
    ubrwso = -20;
    lstbo = -15;

    % vertical distances between things
    below_txt = 42;
    below_lst = 32;

    % horizontal starting points
    lbl_st = 11;
    butt_st = 258;
    lst_st = 256;

    % size for buttons, list boxes
    butt_sz = [64 20];
    lbl_sz = [165 13];
    txt_sz = [227 12];
    lst_sz = [69 32];

    % vertical position of current landmark (starts as top of screen)
    landm = gm_sz(2);

    % gcc binary path stuff
    landm = landm - 20; % set landmark to self
    b = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'HorizontalAlignment','left', ...
      'Position',[lbl_st landm lbl_sz], ...
      'String','Cygwin root path', ...
      'Style','text', ...
      'Tag','labelcygwin');
    b = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'BackgroundColor',[1 1 1], ...
      'HorizontalAlignment','left', ...
      'Position',[lbl_st landm+utxto txt_sz], ...
      'Style','edit', ...
      'UserData', 'Select gcc directory',...
      'Tag','editcygwin');
    c = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'Position',[258.207 landm+ubrwso butt_sz], ...
      'String','Browse', ...
      'UserData', b, ...
      'CallBack', pbrowsecb, ...
      'Tag','Browse cygwin');
    actfig = [actfig b];

    % gcc binary path stuff
    landm = landm - below_txt;
    b = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'HorizontalAlignment','left', ...
      'Position',[lbl_st landm lbl_sz], ...
      'String','Mingw root path', ...
      'Style','text', ...
      'Tag','labelmingw');
    b = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'BackgroundColor',[1 1 1], ...
      'HorizontalAlignment','left', ...
      'Position',[lbl_st landm+utxto txt_sz], ...
      'Style','edit', ...
      'UserData', 'Select gcc directory',...
      'Tag','editmingw');
    c = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'Position',[258.207 landm+ubrwso butt_sz], ...
      'String','Browse', ...
      'UserData', b, ...
      'CallBack', pbrowsecb, ...
      'Tag','Browse mingw');
    actfig = [actfig b];

    % path to these utilities
    landm = landm - below_txt;
    b = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'HorizontalAlignment','left', ...
      'Position',[lbl_st landm lbl_sz], ...
      'String','Path to gnumex file utilities', ...
      'Style','text', ...
      'Tag','labelgnumex');
    b = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'BackgroundColor',[1 1 1], ...
      'HorizontalAlignment','left', ...
      'Position',[lbl_st landm+utxto txt_sz], ...
      'Style','edit', ...
      'UserData', 'Select directory containing gnumex files',...
      'Tag','editgnumex');
    c = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'Position',[258.207 landm+ubrwso butt_sz], ...
      'String','Browse', ...
      'UserData', b, ...
      'CallBack', pbrowsecb, ...
      'Tag','Browse gnumex');
    actfig = [actfig b];

    % select menu for mingw,cygwin,mno-cygwin linking
    landm = landm - below_txt-5;
    b = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'HorizontalAlignment','left', ...
      'Position',[lbl_st landm lbl_sz], ...
      'String','Mingw, Cygwin, or Cygwin-mingw linking?', ...
      'Style','text', ...
      'Tag','labelmingwf');
    b = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'Position',[256 landm+lstbo lst_sz], ...
      'String',strvcat('Mingw','Cygwin','Cygwin-mingw'), ...
      'Style','popupmenu', ...
      'Tag','popmingwf', ...
      'Value',1);
    actfig = [actfig b];

    % mex file or engine exe creation
    landm = landm - below_lst;
    b = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'HorizontalAlignment','left', ...
      'Position',[lbl_st landm lbl_sz], ...
      'String','Generate mex dll or engine exe?', ...
      'Style','text', ...
      'Tag','labelmexf');
    b = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'Position',[256 landm+lstbo lst_sz], ...
      'String',['Mex dll   ';'Engine exe'], ...
      'Style','popupmenu', ...
      'Tag','popmexf', ...
      'Value',1);
    actfig = [actfig b];

    % language for compile
    landm = landm - below_lst;
    b = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'HorizontalAlignment','left', ...
      'Position',[lbl_st landm lbl_sz], ...
      'String','Language for compilation?', ...
      'Style','text', ...
      'Tag','labellang');
    b = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'Position',[256 landm+lstbo lst_sz], ...
      'String',['C / C++';'Fortran'], ...
      'Style','popupmenu', ...
      'Tag','poplang', ...
      'Enable', 'on',...
      'Value',1);
    actfig = [actfig b];

    % precompiled libraries flag
    landm = landm - below_lst;
    b = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'HorizontalAlignment','left', ...
      'Position',[lbl_st landm lbl_sz], ...
      'String','Safe or quick compile?', ...
      'Style','text', ...
      'Tag','labelsafef');
    b = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'Position',[256 landm+lstbo lst_sz], ...
      'String',['Safe ';'Quick'], ...
      'Style','popupmenu', ...
      'Tag','popsafef', ...
      'Value',1);
    actfig = [actfig b];

    % Processor to compile for
    landm = landm - below_lst;
    b = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'HorizontalAlignment','left', ...
      'Position',[lbl_st landm lbl_sz], ...
      'String','Processor to compile for?', ...
      'Style','text', ...
      'Tag','labelscpu');
    b = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'Position',[256 landm+lstbo lst_sz], ...
      'String',strvcat('All','>=Pentium 2','>=Pentium 3','>=Pentium 4'), ...
      'Style','popupmenu', ...
      'Tag','popcpu', ...
      'Value',1);
    actfig = [actfig b];

    % precompiled libraries directory
    landm = landm - below_lst;
    b = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'HorizontalAlignment','left', ...
      'Position',[lbl_st landm lbl_sz], ...
      'String','Path for quick option precompiled libraries', ...
      'Style','text', ...
      'Tag','labelprecomdir');
    b = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'BackgroundColor',[1 1 1], ...
      'HorizontalAlignment','left', ...
      'Position',[lbl_st landm+utxto txt_sz], ...
      'Style','edit', ...
      'UserData', 'Select directory for precompiled libraries',...
      'Tag','editprecomdir');
    c = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'Position',[258.207 landm+ubrwso butt_sz], ...
      'String','Browse', ...
      'UserData', b, ...
      'CallBack', pbrowsecb, ...
      'Tag','Browse precomdir');
    actfig = [actfig b];

    % name for options file
    landm = landm - below_txt;
    b = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'HorizontalAlignment','left', ...
      'Position',[lbl_st landm lbl_sz], ...
      'String','Opts bat file to create', ...
      'Style','text', ...
      'Tag','labeloptsname');
    b = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'BackgroundColor',[1 1 1], ...
      'HorizontalAlignment','left', ...
      'Position',[lbl_st landm+utxto txt_sz], ...
      'Style','edit', ...
      'UserData', 'Select file name for opts bat file',...
      'Tag','editoptsname');
    c = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'Position',[258.207 landm+ubrwso butt_sz], ...
      'String','Browse', ...
      'UserData', b, ...
      'CallBack',fbrowsecb, ...
      'Tag','Browse optfile');
    actfig = [actfig b];

    % buttons
    landm = landm - 52;
    c = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'Position',[178.207 landm butt_sz], ...
      'String','Make opts', ...
      'UserData', b, ...
      'CallBack', 'gnumex(''makeopt'')',...
      'Tag','Browse optfile');
    c = uicontrol('Parent',cygfig, ...
      'Units','points', ...
      'Position',[258.207 landm butt_sz], ...
      'String','Quit', ...
      'UserData', b, ...
      'Callback','close(gcf)',...
      'Tag','Browse optfile');

    % menus
    b = uimenu('Parent',cygfig, ...
      'Label','&File', ...
      'Tag','Filemenu');
    uimenu('Parent',b, ...
      'Label','&Make opts file',...
      'CallBack', 'gnumex(''makeopt'')',...
      'Tag','makeopt');
    uimenu('Parent',b, ...
      'Label','&Load config',...
      'UserData',fullfile(pwd, 'gnumexcfg.mat'),...
      'CallBack', 'gnumex(''menuloadconfig'')',...
      'Tag','loadconfig');
    actfig = [actfig b];

    uimenu('Parent',b, ...
      'Label','&Save config',...
      'CallBack', 'gnumex(''menusaveconfig'')',...
      'Tag','saveconfig');
    uimenu('Parent',b, ...
      'Label','&Default config',...
      'CallBack', 'gnumex(''menudefaults'')',...
      'Tag','defaultconfig');
    uimenu('Parent',b, ...
      'Label','&Close',...
      'Callback','close(gcf)',...
      'Tag','close');

    % Properties to set for each GUI object
    HDefs = {...
      'String', ...
      'String', ...
      'String', ...
      'Value', ...
      'Value', ...
      'Value', ...
      'Value', ...
      'Value', ...
      'String', ...
      'String', ...
      'UserData'};

    pstruct = gnumex('cfg_defaults');
    PDefs = cell2struct([num2cell(actfig') HDefs' fieldnames(pstruct)],...
      {'handle','property','name'},2);
    set(cygfig,'UserData',PDefs);
    gnumex('struct2fig', pstruct, PDefs);

  elseif (strcmp(action, 'cfg_defaults'))
    % load cfg file, otherwise return defaults
    pstruct = gnumex('defaults');
    tmp = gnumex('loadconfig', pstruct.cfgfile);
    if ~isempty(tmp), pstruct = tmp; end
    varargout = {pstruct};

  elseif (strcmp(action, 'defaults'))
    % load defaults, return as structure

    % Collect sensible defaults
    [cygwinpath, mingwpath] = find_paths;
    if ~isempty(mingwpath) | isempty(cygwinpath)
      mingwf = 1; % mingw compiles are used
    else
      mingwf = 2; % .. unless cygwin is installed and mingw is not
    end
    
    % safe / quick defaults
    if mlv >= 6  % matlab version 6 or greater
      safef = 2; % quick
    else
      safef = 1; % safe
    end

    % options file name
    try
      optdir = prefdir(1);
    catch
      optdir = pwd;
    end

    pstruct = struct(...
      'cygwinpath',cygwinpath,...
      'mingwpath' ,mingwpath,...
      'gnumexpath',findmfile('gnumex'),...
      'mingwf'    ,mingwf,...
      'mexf'      ,1,...
      'lang'      ,1,...
      'safef'     ,safef,...
      'cpu'       ,1,...
      'precompath',pwd,...
      'optfile'   ,fullfile(optdir, 'mexopts.bat'),...
      'cfgfile'   ,fullfile(findmfile('gnumex'),...
      'gnumexcfg.mat'));
    varargout = {pstruct};

  elseif (strcmp(action, 'struct2fig'))
    % put struct into current figure
    if nargin < 2
      error('Expecting a structure to write');
    end
    pstruct = varargin{2};
    if nargin < 3
      PDefs = get(gcf, 'UserData');
    else
      PDefs = varargin{3};
    end
    for i = 1:size(PDefs, 1)
      set(PDefs(i).handle,PDefs(i).property,...
        getfield(pstruct, PDefs(i).name));
    end

  elseif (strcmp(action, 'fig2struct'))
    % put figure data into structure
    if nargin < 2
      PDefs = get(gcf, 'UserData');
      % ckeck if this is valid information
      if ~isstruct(PDefs) | ~isfield(PDefs, 'handle')
        varargout = {[]};
        return
      end
    else
      PDefs = varargin{2};
    end
    pstruct = [];
    for i = 1:size(PDefs, 1)
      pstruct = setfield(pstruct,PDefs(i).name, ...
        get(PDefs(i).handle,PDefs(i).property));
    end
    varargout = {pstruct};

  elseif (strcmp(action, 'find_cygfig'))
    allfigs = findobj('Type','figure');
    alltags = get(allfigs, 'Tag');
    tmp =  strmatch('cygfig', alltags);
    if isempty(tmp)
      varargout = {[]};
    else
      varargout = {allfigs(tmp)};
    end

  elseif (strcmp(action, 'fig_def2struct'))
    % if figure is present, returns that, else defaults
    tmp = gnumex('find_cygfig');
    if isempty(tmp)
      pstruct = gnumex('cfg_defaults');
    else
      pstruct = gnumex('fig2struct');
    end
    varargout = {pstruct};

  elseif (strcmp(action, 'loadconfig'))
    % load config file, return as structure
    if nargin < 2
      error('Expecting a config file name')
    end
    varargout = {[]};
    if exist(varargin{2})== 2
      load(varargin{2}, '-mat')
      if exist('pstruct', 'var')
        varargout = {pstruct};
      else
        warndlg(...
          ['File ' varargin{2} ' does not contain valid config settings'],...
          'Did not load gnumex config file');
      end
    end

  elseif (strcmp(action, 'saveconfig'))
    % save config in structure as file
    if nargin < 3
      error('Expecting struct and file name')
    end
    pstruct = varargin{2};
    save(varargin{3}, 'pstruct', '-mat');

  elseif (strcmp(action, 'menuloadconfig'))
    % menu callback for load config
    pstruct = gnumex('fig2struct');
    [f p] = uigetfile(pstruct.cfgfile, 'Configuration file to load');
    if ~isempty(f)
      fn = fullfile(p, f);
      pstruct = gnumex('loadconfig', fn);
      if ~isempty(pstruct)
        pstruct.cfgfile = fn;
        gnumex('struct2fig', pstruct);
      end
    end

  elseif (strcmp(action, 'menusaveconfig'))
    % menu callback for save config
    pstruct = gnumex('fig2struct');
    [f p] = uiputfile(pstruct.cfgfile, 'Configuration file to save');
    if ~isempty(f)
      fn = fullfile(p, f);
      gnumex('saveconfig', pstruct, fn);
      pstruct.cfgfile = fn;
      gnumex('struct2fig', pstruct);
    end

  elseif (strcmp(action, 'menudefaults'))
    % menu callback for defaults load
    gnumex('struct2fig', gnumex('defaults'));

  elseif (strcmp(action, 'checkstruct'))
    % checks struct for errors. Gives warnings
    % Returns 0 if errors, 1 if none

    if nargin < 2
      error('Expecting struct as input argument')
    end
    pstruct = varargin{2};

    % check only path for selected compile type
    if pstruct.mingwf == 1 | pstruct.mingwf == 3
      outvs = fdwarn(fullfile(pstruct.mingwpath, 'bin'), 'gcc.exe');
    else
      cgwbin = fullfile(pstruct.cygwinpath, 'bin');
      outvs = fdwarn(cgwbin, 'gcc.exe');
      if outvs{1}
        % Check that gcc is ok (has version <= 3.2)
        [err,verss] = dos([fullfile(cgwbin, 'gcc.exe') ' -dumpversion']);
        if err
          outvs = [outvs; {0, 'unable to obtain gcc version'}];
        else
          vers = sscanf(verss, '%f', 1);
          versmsg = 'Gnumex needs gcc version 3.2 or earlier. See README file';
          if vers > 3.2, outvs = [outvs; {0, versmsg}]; end
        end
      end
    end
    outvs = [outvs; fdwarn(pstruct.gnumexpath, 'linkmex.pl')];
    errinds = cat(1, outvs{:, 1});
    varargout = {all(errinds) outvs(~errinds, 2)};
    
  elseif (strcmp(action, 'check-cygwin1.dll'))
    % This checks if cygwin1.dll is on the Windows path
    pstruct = varargin{2};
    varargout = {1, ''};
    if pstruct.mingwf ~= 1
      whichcmd = fullfile(pstruct.cygwinpath, 'bin', 'which.exe');
      lscmd = fullfile(pstruct.cygwinpath, 'bin', 'ls.exe');
      [err,reslt] = dos([whichcmd ' cygwin1.dll']);
      if ~err % if which is not found don't bother and return ok
        [err,reslt] = dos([lscmd ' ' reslt]);
        st = 'With mex-files from cygwin, cygwin1.dll must be on the Windows path';
        if err, varargout = {0, st}; end
      end
    end

  elseif (strcmp(action, 'parsepaths'))
    % parse paths (knock off trailing slash), short paths
    % paths are variables with 'path' in their name
    if nargin < 2
      error('Expecting a struct as argument');
    end
    pstruct = varargin{2};

    fnames = fieldnames(pstruct);
    for i=1:length(fnames)
      if ~isempty(findstr(fnames{i},'path'))
        s = getfield(pstruct, fnames{i});
        if mlv >= 7.4
          s = shortpath74(s);
        else
          s = shortpath(s);
        end
        while ~isempty(s) & s(end) == '\'
          s = s(1:end-1);
        end
        pstruct = setfield(pstruct, fnames{i}, s);
      end
    end
    varargout = {pstruct};
    
  elseif (strcmp(action, 'makedeffiles'))
    % Use nm.exe to extract the names of mex-, mx- and mat-functions from
    % .lib-files in Matlab's lcc library folder and write them to .def
    % files in the gnumex.m folder. These .def-files can then be used as
    % input to dlltool to create .lib-files in a format apropriate for
    % gcc. From version 7.4 of Matlab no def-files come with matlab, but
    % this provides a workaround.
    nmcmd = varargin{2};
    deffiles = varargin{3};
    % defdir = varargin{4};
    % libs will probably be {'libmex', 'libmx', 'libmat', 'libeng'};
    libdir = [matlabroot '\extern\lib\win32\lcc\'];
    for i=1:length(deffiles)
      [p, lib] = fileparts(deffiles{i});
      [err,list] = dos([nmcmd ' -g --defined-only "' libdir lib '.lib"']);
      if err, error('extracting symbols from lib-file failed'); end
      tok = textscan(list,'%*s%s%s%*[^\n]');
      code = char(tok{1});
      symbols = tok{2}(code=='T');
      %fid = fopen([defdir '\' deffiles{i}], 'w');
      fid = fopen(deffiles{i}, 'w');
      if fid < 0, error (['Cannot open file ' deffiles{i} ' for writing']); end
      fprintf(fid, 'LIBRARY %s.dll\nEXPORTS\n', lib);
      J = strmatch('_', symbols)';
      for j = J, symbols{j}(1) = ''; end
      for j = 1:length(symbols), fprintf(fid,'%s\n', symbols{j}); end
      fclose(fid);
    end
    
  elseif (strcmp(action, 'makeopt'))
    % write struct info to opt file
    % all the above to get here!
    if nargin < 2
      pstruct = gnumex('fig2struct');
    else
      pstruct = varargin{2};
    end
    if nargin < 3
      gui_f = 1; % flag for GUI warnings / confirm boxes
    else
      gui_f = varargin{3};
    end

    % parse paths
    pps = gnumex('parsepaths', pstruct);
    if mlv >= 7.4
      mlr = shortpath74(matlabroot);
    else
      mlr = shortpath(matlabroot);
    end

    % get matlab version
    % find perl location
    if mlv < 6  % matlab 5
      perlpath=fullfile(mlr, 'bin', 'perl.exe');
      if ~exist(perlpath,'file')
        perlpath=fullfile(mlr, 'bin','nt','perl.exe');
      end
    else % matlab 6
      perlcont = fullfile('sys','perl','win32','bin','perl.exe');
      perlpath = fullfile(mlr, perlcont);
    end

    if ~exist(perlpath,'file')
      perlpath='perl.exe';
      warndlg('You may need to set path by hand in options file', ...
        'Failed to find matlab version of perl.exe');
    end

    % set libraries to compile for mex/eng creation
    if mlv < 5.2    % < 5.2
      mexdefs = {'matlab.def'};
      engdefs = {'libmx.def', 'libeng.def', 'libmat.def'};
      fmexdefs = {'df50mex.def'}; % not checked
      fengdefs = {'dfmx.def', 'dfmat.def', 'dfeng.def'}; % ditto
    elseif mlv < 5.3 % 5.2
      mexdefs = {'matlab.def', 'libmat.def', 'libmatlb.def'};
      engdefs = {'libmx.def', 'libeng.def', 'libmat.def'};
      fmexdefs = {'df50mex.def'};
      fengdefs = {'dfmx.def', 'dfmat.def', 'dfeng.def'};
    elseif mlv < 6  % 5.3
      mexdefs = {'matlab.def', 'libmatlbmx.def'};
      engdefs = {'libmx.def', 'libeng.def', 'libmat.def'};
      fmexdefs = {'df50mex.def'};
      fengdefs = {'dfmx.def', 'dfmat.def', 'dfeng.def'};
    elseif mlv < 7 % matlab 6
      mexdefs = {'libmx.def', 'libmex.def',...
        'libmat.def', '_libmatlbmx.def'};
      engdefs = {'libmx.def', 'libeng.def', 'libmat.def'};
      fmexdefs = {'libmx.def', 'libmex.def',...
        'libmat.def', '_libmatlbmx.def'};
      fengdefs = {'libmx.def', 'libeng.def', 'libmat.def'};
    else % matlab 7
      mexdefs =  {'libmx.def', 'libmex.def', 'libmat.def'};
      engdefs =  {'libmx.def', 'libeng.def', 'libmat.def'};
      fmexdefs = {'libmx.def', 'libmex.def', 'libmat.def'};
      fengdefs = {'libmx.def', 'libeng.def', 'libmat.def'};
    end

    [okf msg] = gnumex('checkstruct', pps);
    if ~okf & gui_f
      warndlg(msg, 'Gnumex argument check failed');
      return
    elseif ~okf
      error('%s\n', msg{:});
    end
    
    [okf msg] = gnumex('check-cygwin1.dll', pps);
    if ~okf 
      if gui_f, warndlg(msg, 'Path warning'); uiwait        
      else      warning(msg); end
    end
    
    if mlv >= 7.4
      path_to_deffiles = pps.gnumexpath;
      deffiles = strcat(path_to_deffiles, '\', union(mexdefs,engdefs)); 
      if ~all(paths_exist(deffiles))
        % Check that nm.exe can be found
        nm = fullfile(pps.cygwinpath, 'bin', 'nm.exe');
        if ~exist(nm, 'file'), nm = fullfile(pps.mingwpath, 'bin', 'nm.exe'); end
        if ~exist(nm, 'file'), error('Cannot find nm.exe'); end
        if gui_f, 
          set(gcf, 'Pointer', 'watch');
        else
          disp('Making .def-files ...');
        end
        %gnumex('makedeffiles', nm, deffiles, path_to_deffiles);
        gnumex('makedeffiles', nm, deffiles);
        if gui_f, set(gcf, 'Pointer', 'arrow'); end
      end
    else
      path_to_deffiles = [mlr '\extern\include'];
    end
    
    % Optimization rules for Pentiums 1:4
    optimflags = {'-march=pentium',...
      '-march=pentium2',...
      '-march=pentium3 -mfpmath=sse',...
      '-march=pentium4 -mfpmath=sse'};

    % get the relevant path
    if pps.mingwf == 1
      gccpath = pps.mingwpath;
    else
      gccpath = pps.cygwinpath;
    end
    gccpath = fullfile(gccpath, 'bin');

    % dlltool command needs to be custom thing for
    % Fortran linking
    if pps.lang == 2
      dllcmd = [pps.gnumexpath '\mexdlltool -E --as ' ...
        gccpath '\as.exe'];
    else
      dllcmd = 'dlltool';
    end

    % check that the right one of mingw/cygwin has been selected
    cpf = exist(fullfile(gccpath,'cygpath.exe'),'file');
    if pps.mingwf == 1 & cpf
      if strcmp('Cancel',...
          questdlg(...
          {'cygpath in binary directory',...
          'This appears to clash with selection of mingw links',...
          'Do you want to continue'},...
          'Mingw/Cygwin mismatch','Continue','Cancel','Cancel'))
        return
      end
    elseif pps.mingwf > 1 & ~cpf
      warndlg('For Cygwin or Cygwin/mingw, need cygpath in binary directory',...
        'Gnumex argument check failed');
      return
    end

    if exist(pps.optfile, 'file') & gui_f
      gstr = questdlg(['Please confirm overwrite of opt file ' pps.optfile], ...
        'Please confirm','Confirm','Cancel','Cancel');
      if strcmp(gstr, 'Cancel')
        return
      end
    end

    % specify libraries
    % eng / mat library root name, library list
    if pps.mexf == 1 % mex file
      if pps.lang == 1  % c/c++
        defs2link = mexdefs;
        librootn = 'mexlib';
      else % fortran
        defs2link = fmexdefs;
        librootn = 'fmexlib';
      end
    else % engine file
      if pps.lang == 1  % c/c++
        defs2link = engdefs;
        librootn = 'englib';
      else % fortran
        defs2link = fengdefs;
        librootn = 'fenglib';
      end
    end

    % create libraries if precomp option required
    if (pps.safef == 2)
      dlgt = 'Precompiled libraries problem';
      INCROOT = [path_to_deffiles '\'];
      %DESTPATH = [pps.precompath '\'];

      % check for files to rewrite, make directory if doesn't exist
      if ~exist(pps.precompath, 'dir')
        rewritef = 1;
      else
        % check whether files need rewriting
        rewritef = 0;
        for i = 1:length(defs2link)
          defoutfils{i} = fullfile(pps.precompath, ...
            sprintf('%s%d.lib', librootn, i));
          if ~exist(defoutfils{i}, 'file')
            rewritef = 1;
          end
        end
      end

      if ~rewritef & gui_f
        gstr = questdlg('Output libraries exist', ...
          'Overwrite?','Overwrite','Use current','Use current');
        rewritef = strcmp(gstr, 'Overwrite');
      end

      if rewritef
        % make temporary bat file to do the work
        tfn = [tempname '.bat'];
        [tfid msg] = fopen(tfn, 'wt');
        if (tfid == -1)
          wrndlg(['Cannot open temporary bat file ' tfn], dlgt);
          return
        end
        %if mlv >= 7.0
        %  fp = @(x) fprintf(tfid, '%s\n', x);
        %else
          fp = inline(['fprintf(' num2str(tfid) ', ''%s\n'', x)']);
        %end
        fp('@echo off');
        if ~exist(pps.precompath, 'dir')
          fp(['mkdir "' pps.precompath '"']);
        end
        fp(['set PATH=' gccpath]);
        % if specified directory does not exist, we will try to create it
        % else, if flag file present, delete it
        if exist(defoutfils{1}, 'file')
          delete(defoutfils{1});
        end
        for i = 1:length(defs2link)
          fp(sprintf('%s --def "%s%s" --output-lib "%s"', ...
            dllcmd, INCROOT, defs2link{i}, defoutfils{i}));
        end
        fp('echo Done.');
        fclose(tfid);
        if gui_f, set(gcf, 'Pointer', 'watch'); 
        else disp('Creating libraries ...'); end
        [s m] = dos(tfn);
        if gui_f, set(gcf, 'Pointer', 'arrow'); end
        % check if succeeded, end if no
        if ~exist(defoutfils{1}, 'file')
          warndlg(...
            {'Unsuccessful in creating precompiled libraries',...
            ['Returned message was: ' m], ...
            ['Please check ' tfn]}, dlgt);
          return
        else
          delete(tfn);
        end
      end
    end

    [fid msg] = fopen(pstruct.optfile, 'wt');
    if (fid == -1)
      warndlg(['Could not open optfile ' pstruct.optfile], msg);
      return
    end

    % Added libraries
    % This could be done with the LINKFLAGSPOST variable I think,
    % but I don't know if this is compatible with versions of matlab
    % < 5.3
    add_libs = {};
    if (pps.lang == 2) % fortran
      add_libs = {add_libs{:} '-lg2c'};
    end

    % make a little report
    rep = char(gnumex('report', pps));

    % inline functin for printing to options .bat file
    %if mlv >= 7.4
    %  fp = @(x) fprintf(fid, '%s\n', x);
    %else
      fp = inline(['fprintf(' num2str(fid) ', ''%s\n'', x)']);
    %end
    
    % at last
    if gui_f
      set(gcf, 'Pointer', 'watch');
    else
      disp(rep);
    end

    % --------------------------------------------------------------

    fp('@echo off');
    fp(['rem ' pps.optfile]);
    fp(['rem Generated by gnumex.m script in ' pps.gnumexpath]);
    fp(['rem gnumex version: ' num2str(VERSION)]);
    fp('rem Compile and link options used for building MEX etc files with');
    fp('rem the Mingw/Cygwin tools.  Options here are:');
    for i = 1:size(rep, 1)
      fp(['rem ' rep(i,:)]);
    end

    fp(['rem Matlab version ' num2str(mlv)]);
    fp('rem');
    fp(['set MATLAB=' mlr]);
    fp(['set GM_PERLPATH=' perlpath]);
    fp(['set GM_UTIL_PATH=' pps.gnumexpath]);
    fp(['set PATH=' gccpath ';%PATH%']);
    fp('rem');
    if (pps.safef == 2)
      fp('rem precompiled library directory');
      fp(['set GM_QLIB_NAME=' pps.precompath]);
      fp('rem');
    end
    fp('rem directory for .def-files');
    fp(['set GM_DEF_PATH=' path_to_deffiles]);
    fp('rem Added libraries for linking');
    fp(['set GM_ADD_LIBS=' sepcat(add_libs, ' ')]);
    fp('rem');
    fp('rem Type of file to compile (mex or engine)');
    if pps.mexf == 1, mtype = 'mex'; else mtype = 'eng';end
    fp(['set GM_MEXTYPE=' mtype]);
    fp('rem');
    fp('rem Language for compilation');
    if pps.lang == 1, mlang = 'c'; else mlang = 'f';end
    fp(['set GM_MEXLANG=' mlang]);
    fp('rem');
    fp('rem def files to be converted to libs');
    fp(['set GM_DEFS2LINK=' sepcat(defs2link) ';']);
    fp('rem');
    fp('rem dlltool command line');
    fp(['set GM_DLLTOOL=' dllcmd]);
    fp('rem');
    fp('rem compiler options; add compiler flags to compflags as desired');
    fp('set NAME_OBJECT=-o');
    if mlv > 5.1
      fp(['set COMPILER=gcc']);
    else
      fp('rem Need wrapper for compiler to move .o output to .obj');
      fp(['set COMPILER=mexgcc']);
    end

    if (pps.mingwf == 3)
      c = '-mno-cygwin';
    else
      c = '';
    end
    if pps.lang == 2 % fortran
      % stdcall compile, upper case symbols, no underscore suffix
      c = ['-fcase-upper -fno-underscoring ' c];
    end
    fp(['set COMPFLAGS=-c -DMATLAB_MEX_FILE ' c]);
    fp(['set OPTIMFLAGS=-O3 -malign-double -fno-exceptions -funroll-all-loops ' optimflags{pps.cpu}]);
    fp('set DEBUGFLAGS=-g');
    if pps.lang == 1
      fp(['set CPPCOMPFLAGS=%COMPFLAGS% -x c++ ' c]);
      fp('set CPPOPTIMFLAGS=%OPTIMFLAGS%');
      fp('set CPPDEBUGFLAGS=%DEBUGFLAGS%');
    end
    fp('rem');
    fp('rem NB Library creation commands occur in linker scripts');

    % main linker parameters
    if (pps.mingwf == 3)    % cygwin/mingw compile
      linkfs = ['-mno-cygwin -mwindows'];
    else                  % mingw or cygwin compile
      linkfs = '';
    end
    linker = '%GM_PERLPATH% %GM_UTIL_PATH%\linkmex.pl';
    if (pps.mexf == 1)    % mexf compile
      if mlv >= 7.1, oext = 'mexw32'; else oext = 'dll'; end
    else                  % engine compile
      oext = 'exe';
    end

    % resource linker parameters
    if (pps.mingwf == 1)    % mingw compile
      rclinkfs = '';
    else                  % cygwin or cygwin/mingw compile
      rclinkfs = '--unix';
    end

    fp('rem');
    fp('rem Linker parameters');
    fp(['set LINKER=' linker]);
    fp(['set LINKFLAGS=' linkfs]);
    if pps.lang == 1 % c
      % indicator to linkmex script that this is a c++ file
      % so linker can be set to g++ rather than gcc
      fp(['set CPPLINKFLAGS=GM_ISCPP ' linkfs]);
    end
    fp('set LINKOPTIMFLAGS=-s');
    fp('set LINKDEBUGFLAGS=-g  -Wl,--image-base,0x28000000\n');
    fp('set LINK_FILE=');
    fp('set LINK_LIB=');
    fp(['set NAME_OUTPUT=-o %OUTDIR%%MEX_NAME%.' oext]);
    fp('rem');
    fp('rem Resource compiler parameters');
    fp(['set RC_COMPILER=%GM_PERLPATH% %GM_UTIL_PATH%\rccompile.pl '...
      rclinkfs ' -o %OUTDIR%mexversion.res']);
    fp('set RC_LINKER=');

    % done
    fclose(fid);
    msg = ['Created opt file ' pstruct.optfile];
    if gui_f
      set(gcf, 'Pointer', 'arrow');
      msgbox(msg, 'Gnumex opt file');
    else
      disp(msg);
    end

    % --------------------------------------------------------------

  elseif (strcmp(action, 'report'))
    % Compiles a little report on current options
    if nargin < 2
      pstruct = gnumex('fig_def2struct');
    else
      pstruct = varargin{2};
    end

    switch pstruct.mingwf
      case 1
        lnk = 'Mingw';
      case 2
        lnk = 'Cygwin (cygwin*.dll)';
      case 3
        lnk = 'Cygwin / mingw (-mno-cygwin)';
    end
    switch pstruct.mexf
      case 1
        mext = 'Mex (*.dll)';
      case 2
        mext = 'Engine / mat (*.exe)';
    end
    switch pstruct.safef
      case 1
        safet = 'Safe linking to temporary libraries';
      case 2
        safet = 'Fast linking to precompiled libraries';
    end
    switch pstruct.lang
      case 1
        lang = 'C / C++';
      case 2
        lang = 'Fortran';
    end
    switch pstruct.cpu
      case 1
        cpu = 'pentium';
      case 2
        cpu = 'pentium 2';
      case 3
        cpu = 'pentium 3';
      case 4
        cpu = 'pentium 4';
    end

    varargout = {{[lnk ' linking'],...
      [mext ' creation'],...
      safet,...
      ['Language: ' lang],...
      ['Compiling for ' cpu ' and above']}};

  elseif (strcmp(action, 'test'))
    % Rather hackey test script
    % Usage: gnumex('test', cygwinoldpath, testf)
    %   for example: gnumex test
    %   or:          gnumex test c:\cygwin_old
    %   or:          gnumex test c:\cygwin_old 1
    %
    % NOTE: no-cygwin (ctype=3) does not work with old cygwin (the one with gcc
    %       3.2) but cygwin only works with the old cygwin. So to test properly
    %       both versions of cygwin must be present. For testing, it is assumed
    %       that the new version is returned by gnumex('fig_def2struct') below,
    %       and the old cygwin path is pointed to by the command line argument.
    
    % arg - testf
    % non-zero if we are testing output of yprime dll with cygwin
    % This causes matlab to crash and die after a few Cygwin tests on my machine
    testf = 0;
    cygwin_old_path = '';
    if nargin >= 3
      testf = varargin{3};
    end
    if nargin >= 2
      cygwin_old_path = varargin{2};
    end
    % File to save results
    flagfile = 'checked.mat';

    % path to file examples
    fortran_mexfun = 'yprime_g77';
    exroot = fullfile(matlabroot, 'extern', 'examples');
    fexpath = findmfile('gnumex');
    fortran_examples = {fullfile(fexpath, [fortran_mexfun '.f']) ...
      ,                 fullfile(fexpath, 'yprimef.f')};
    % file examples
    % 4x4 cell matrix, col 1 mex, col 2 eng, row 1 c row 2 fortran
    mexstr{1,1} = {fullfile(exroot, 'mex', 'yprime.c')};
    mexstr{2,1} = fortran_examples;
    mexstr{1,2} = {fullfile(exroot, 'eng_mat', 'engwindemo.c')};
    mexstr{2,2} = {fullfile(fexpath, 'fengdemo.f')};

    % c and fortran versions of evals to test (testf = 1)
    mexteststr = {'yprime(1, 1:4)', [fortran_mexfun '(1, 1:4)']};

    % correct result from yprime
    corr_r = [2.0000    8.9685    4.0000   -1.0947];

    % Fill structure
    pstruct = gnumex('fig_def2struct');
    pstruct.precompath = pwd;
    pstruct.optfile = fullfile(pwd,'testopts.bat');
    cygwinpath = pstruct.cygwinpath;

    % delete existing libaries, checked flag file
    %  --- No. don't delete them to make the test run faster!
    % delete *.lib 
    if exist(flagfile, 'file')
      delete(flagfile)
    end

    % test each in turn
    success = cell(3,2,2,2);
    for ctype = 1:3  % mingw, cygwin, mno-cygwin
      pstruct.mingwf = ctype;
      if ~isempty(cygwin_old_path) & ctype == 2
        pstruct.cygwinpath = cygwin_old_path; 
      else
        pstruct.cygwinpath = cygwinpath;
      end
      for safef = 1:2  % create libs, use precompiled
        pstruct.safef = safef;
        for lang = 1:2  % c, fortran
          pstruct.lang = lang;
          clear yprime
          clear(fortran_mexfun)
          for targ = 1:2  % mex, engine
            if targ == 2 & ctype == 2, continue, end 
            %                                 (engine doesn't work with cygwin)
            pstruct.mexf = targ;
            try
              gnumex('makeopt', pstruct, 0);
              mex('-f', pstruct.optfile, mexstr{lang, targ}{:});
              if targ == 1 & (ctype ~= 2 | testf)
                r = eval(mexteststr{lang});
                if any((r - corr_r) > eps)
                  error(['Mex gave ' num2str(r)]);
                end
              end
              fprintf('OK\n');
            catch
              fprintf('Failed with %s\n', lasterr);
              success{ctype, safef, lang, targ} = lasterr;
            end
          end
        end
      end
    end

    % delete existing libaries, clear dll
    %  --- No. don't delete them to make the test run faster!
    % delete *.lib
    clear yprime
    clear(fortran_mexfun)

    % save flag file
    save(flagfile, 'success');

    %   elseif (strcmp(action, 'fbrowsecb')) % NEVER CALLED
    %     f=get(gcbo,'UserData');
    %     [fn p]=uiputfile(get(f, 'String'), get(f,'UserData'))
    %     cd(pwd);
    %     if ~isempty(fn),
    %       set(f,'String',fullfile(p, fn));
    %     end

  elseif (strcmp(action, 'usage'))

    [path_opts cmd_opts] = gnumex('command_options');
    fprintf('gnumex command line options:\n');
    fprintf('%s=[path]\n', path_opts{:});
    fprintf('%s\n', cmd_opts{:, 1});
    fprintf('%s\n', 'usage');

  elseif (strcmp(action, 'command_options'))

    path_opts = {...
      'cygwinpath',...
      'mingwpath',...
      'gnumexpath',...
      'precompath',...
      'optfile',...
      'cfgfile'};
    cmd_opts = {...
      'mingw',     'mingwf',     1;...
      'cygwin',    'mingwf',     2;...
      'no-cygwin', 'mingwf',     3;...
      'mex',       'mexf',       1;...
      'eng',       'mexf',       2;...
      'c',         'lang',       1;...
      'fortran',   'lang',       2;...
      'safe',      'safef',      1;...
      'quick',     'safef',      2;...
      'p1',        'cpu',        1;...
      'p2',        'cpu',        2;...
      'p3',        'cpu',        3;...
      'p4',        'cpu',        4 ...
      };
    varargout = {path_opts, cmd_opts};

  else % otherwise unrecognized option

    % implement a command line option parser
    pstruct = gnumex('fig_def2struct');
    [path_opts cmd_opts] = gnumex('command_options');
    args = varargin;

    % first try path setters (with = in arg)
    args_remaining = logical(ones(size(args)));
    errstr = {};
    for i = 1:length(args)
      arg = args{i};
      for p = path_opts
        if ~isempty(strmatch(p, arg))
          args_remaining(i)=0;
          p = char(p);
          p_st = length(p)+ 2;
          if isempty(strmatch([p '='], arg)) ...
              | length(arg) < p_st
            errstr{end+1} = ['Path syntax is ' p '=[path]'];
          else
            pstruct = setfield(pstruct,...
              p,...
              arg(p_st:end));
          end
          continue;
        end
      end
    end
    args = args(args_remaining);

    % and non path arguments
    [ok_opts opt_inds] = ismember(args, cmd_opts(:,1));

    if ~all(ok_opts)
      errstr{end+1} = sprintf('Unrecognized option: %s\n',args{~ok_opts});
    end
    if ~isempty(errstr)
      gnumex('usage');
      error(sprintf('%s\n', errstr{:}));
    end

    for i = 1:length(args)
      pstruct = setfield(pstruct,...
        cmd_opts{opt_inds(i),2},...
        cmd_opts{opt_inds(i),3});
    end
    gnumex('makeopt', pstruct, 0);
  end
  return


  % subroutines

function varargout = fdwarn(pathname, filename)
  % checks whether path is valid, then for file therein contained
  % returns true if both are true, msg for warning if not

  okf = 1;
  warnmsg = [];
  if ~exist(pathname, 'dir')
    warnmsg = [pathname ' does not appear to be a valid' ...
      ' directory'];
    okf = 0;
  else
    if ~exist(fullfile(pathname,filename),'file')
      warnmsg = [pathname ' does not contain ' filename];
      okf = 0;
    end
  end
  varargout = {{okf warnmsg}};
  return

function dir = findmfile(mfilename)
  % returns dir for m file for function specified

  dir = lower(which(mfilename));
  if isempty(dir)
    return
  end
  t = findstr(dir, [filesep mfilename '.m']);
  if isempty(t)
    return
  end
  dir = dir(1:t(1)-1);
  return

function s = sepcat(strs, sep)
  % returns cell array of strings as one char string, separated by sep
  if nargin < 2
    sep = ';';
  end
  if isempty(strs)
    s = '';
    return
  end
  strs = strs(:)';
  strs = [strs; repmat({sep}, 1, length(strs))];
  s = [strs{1:end-1}];
  
function tf = mingw_before_cygwin(cygwinpath)
  % return 1 if mingw is on the Windows path and not after cygwin.
  path = getenv('path');
  tf = false;
  while ~isempty(path)
    [dir,path] = strtok(path,';');
    if strcmp(dir, cygwinpath), return, end
    if strfind(lower(dir), 'mingw') & strcmp(lower(dir(1:end)))
    end
  end

function [cygwinpath, mingwpath] = find_paths();
  % Try to find locations of cygwin and mingw
  % Mark Levedahl suggested this to find Cygwin
  reg_cygwin = 'SOFTWARE\Cygnus Solutions\Cygwin\mounts v2\/';
  reg_mingw = 'Software\Microsoft\Windows\CurrentVersion\Uninstall\MinGW';
  cygwinpath = find_path(reg_cygwin, 'native', 'c:\cygwin');
  mingwpath = find_path(reg_mingw', 'InstallLocation', 'c:\mingw');
  
function folder = find_path(subkey, valname, default)
  % Try to find folder of cygwin / mingw in the registry, else use default
  try
    folder = winqueryreg('HKEY_LOCAL_MACHINE', subkey, valname);
  catch
    % -- look for a user mount
    try
      folder = winqueryreg('HKEY_CURRENT_USER', subkey, valname);
    catch
      folder = default;
    end
  end
  % if folder doesn't containg bin/gcc.exe, make it empty
  gccfullfile = fullfile(folder, 'bin', 'gcc.exe');
  if ~exist(gccfullfile, 'file'), folder = ''; end

function tf = paths_exist(paths)
% Checks if paths exist, returning tf matrix of same size as paths
if ischar(paths)
  paths = cellstr(paths);
end
tf = zeros(size(paths));
for pi = 1:length(paths)
  tf(pi) = exist(paths{pi}, 'file');
end
return
  