function op1=amthelp(varargin)
%AMTHELP Help on the AMToolbox
%   Usage:  amthelp;
%           v=amthelp('version');
%           mlist=amthelp('modules');
%
%   `amthelp` displays some general help on the AMToolbox.
%
%   `amthelp('version')` returns the version number.
%
%   `amthelp('modules')` returns a cell array of installed modules and
%   corresponding version numbers.
%
%   See also:  amtstart

%   AUTHOR : Peter Søndergaard.  
%   TESTING: NA
%   REFERENCE: NA

% Verify that LTFAT has been installed
if ~exist('ltfatarghelper','file')  
    amtdisp('');
    amtdisp('--- AMTOOLBOX - The Auditory Modeling toolbox. ---');
    amtdisp('')
    error(['The toolbox require the LTFAT toolbox to properly function. ' ...
         'Please download and install it from http://ltfat.sourceforge.net,' ...
         'and then call the LTFATSTART command BEFORE you use the AMT.'])
end;

bp=amtbasepath;

definput.keyvals.versiondata=[];
definput.keyvals.modulesdata=[];
definput.flags.mode={'general','version','modules','authors'};

[flags,kv]=ltfatarghelper({},definput,varargin);

if flags.do_general
  amtdisp(' ');
  amtdisp('--- AMT - The Auditory Modeling Toolbox. ---');
  amtdisp(' ')

  amtdisp(['Version ',kv.versiondata]);
  amtdisp(' ');
  amtdisp('Installed modules:');
  amtdisp(' ');
  amtdisp('Name:            Version:  Description');
  modinfo=amthelp('modules');
  for ii=1:length(modinfo);
    s=sprintf(' %-15s %7s  %s',modinfo{ii}.name,modinfo{ii}.version, ...
	      modinfo{ii}.description);
    amtdisp(s);
  end;

  amtdisp(' ')
  if isoctave
    amtdisp('Type amthelp("modulename") where "modulename" is the name of one');
    amtdisp('of the modules to see help on that module.');
    
  else
    amtdisp('Type "help modulename" where "modulename" is the name of one')
    amtdisp('of the modules to see help on that module.') 

  end; 
  amtdisp(' ');
  amtdisp('For other questions, please don''t hesitate to send an email to amtoolbox-help@lists.sourceforge.net.'); 
    
end;
  
if flags.do_version
  op1=kv.versiondata;
end;

if flags.do_modules
  op1={};
  for ii=1:numel(kv.modulesdata)
    
    p=kv.modulesdata{ii};
    
    % Get the first line of the help file
    [FID, MSG] = fopen ([bp,p.name,filesep,'Contents.m'],'r');
    if FID==-1
      error('Module %s does not contain a Contents.m file.',p.name);
    end;
    firstline = fgetl (FID);
    fclose(FID);
    
    
    % Load the information into the cell array.	
    op1{ii}.name=p.name;
    op1{ii}.version=p.version;
    op1{ii}.description=firstline(2:end);
  end;
end;
