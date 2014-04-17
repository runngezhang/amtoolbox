function [ varargout ] = baumgartner2014pmv2ppp( varargin )
%BAUMGARTNER2014PMV2PPP PMV to PPP conversion
%   Usage:  [ qe,pe,eb ] = baumgartner2014pmv2ppp( p,tang,rang );
%           [ qe,pe,eb ] = baumgartner2014pmv2ppp( p,tang,rang,exptang );
%
%   Input parameters:
%     p          : prediction matrix (response PMVs)
%     tang       : possible polar target angles. As default, ARI's MSP 
%                  polar angles in the median SP is used.
%     rang       : polar angles of possible response angles.
%                  As default regular 5 deg.-sampling is used (-30:5:210).    
%
%   Output parameters:
%     qe         : quadrant error rate
%     pe         : local polar RMS error in degrees
%     eb         : elevation bias in degrees; QEs and up-rear quadrant excluded
%
%   `baumgartner2014pmv2ppp(...)` retrieves commonly used PPPs (Psychoacoustic 
%   performance parameters) for sagittal-plane (SP) localization like quadrant 
%   error (QE), local polar RMS error (PE), and elevation bias (EB) from
%   response PMVs (probability mass vectors) predicted by a localization
%   model. PPPs are retreived either for a specific polar target angle or as
%   an average across all available target angles. The latter is the
%   default.
%
%   `baumgartner2014pmv2ppp` needs the following optional parameter in order 
%   to retrieve the PPPs for a specific (set of) target angles:
%
%     'exptang', exptang   experimental polar target angles
%
%   `baumgartner2014pmv2ppp` accepts the following flag:
%
%     'print'      Display the outcomes.
%     'QE_PE_EB'   Compute QE, PE, and EB. This is the default.
%     'QE'         Compute QE.
%     'PE'         Compute PE.
%     'EB'         Compute EB.
%     'absPE'      Compute absolute polar error.
%
%   Example:
%   ---------
%
%   To evaluate chance performance of QE and PE use :::
%
%     [qe,pe] = baumgartner2014pmv2ppp('chance');
%
%   References: baumgartner2014

% AUTHOR : Robert Baumgartner

definput.keyvals.p=ones(72,44);
definput.keyvals.rang=-90:5:269;
definput.keyvals.tang=[-30:5:70,80,100,110:5:210];
definput.keyvals.exptang=[];

definput.flags.print = {'noprint','print'};
definput.flags.chance = {'','chance'};
definput.flags.ppp = {'QE_PE_EB','QE','PE','EB','absPE'};

[flags,kv]=ltfatarghelper({'p','tang','rang','exptang'},definput,varargin);

p = kv.p;

if flags.do_chance
  p = ones(length(kv.rang),length(kv.tang));
end

if size(p,1) == 49 % rang: default for baumgartner2013
  kv.rang=-30:5:210;
end
    
p = p./repmat(sum(p),length(kv.rang),1);  % ensure probability mass vectors
tang = kv.tang(:);
rang = kv.rang(:);
nt = length(tang);

if flags.do_QE_PE_EB || flags.do_PE || flags.do_QE || flags.do_EB
  
  qet = zeros(nt,1); % QE for each target angle
  pet = zeros(nt,1); % PE for each target angle
  ebt = zeros(nt,1); % EB for each target angle
  isnotuprear = false(nt,1);
  for ii = 1:nt % for all target positions
      d = tang(ii)-rang;                 % wraped angular distance between tang & rang
      iduw = (d < -180) | (180 < d);     % 180°-unwrap indices
      d(iduw) = mod(d(iduw) + 180,360) - 180; % 180 deg unwrap
      d = abs(d);                        % absolut distance
      qet(ii) = sum( p(d>=90,ii) );
      pc = p(d<90,ii);                   % pmv for conditional probability excluding QEs
      pc = pc/sum(pc);                   % normalization to sum=1
      pet(ii) = sqrt( sum( pc .* (d(d<90)).^2 )); % RMS of expected difference
      if tang(ii) < 80
        ebt(ii) = sum( pc .* rang(d<90) ) - tang(ii); % expectancy value of rang - tang
        isnotuprear(ii) = true;
      elseif tang(ii) > 180 % elevation instead of polar angle
        ebt(ii) = -( sum( pc .* rang(d<90) ) - tang(ii) );
      else % exclude up-rear quadrant
        isnotuprear(ii) = false;
      end
  end
  ebt = ebt(isnotuprear);

  if ~isempty(kv.exptang)

      qetb = (qet(1)+qet(end))/2;  % boundaries for extang
      petb = (pet(1)+pet(end))/2;
      ebtb = (ebt(1)+ebt(end))/2;

      extang = tang(:); % extended tang for targets outside
      exqet = qet(:);
      expet = pet(:);
      expb = ebt(:);
      if min(extang)>-90; 
        extang = [-90; extang]; 
        exqet = [qetb; exqet];
        expet = [petb; expet];
        expb = [ebtb; expb];
        isnotuprear = [true;isnotuprear];
      end
      if max(extang)<270; 
        extang = [extang; 270]; 
        exqet = [exqet; qetb];
        expet = [expet; petb];
        expb = [expb; ebtb];
        isnotuprear = [isnotuprear;true];
      end

      qet = interp1(extang,exqet,kv.exptang);
      pet = interp1(extang,expet,kv.exptang);
      excluderu = kv.exptang < 80 | kv.exptang > 180;
      ebt = interp1(extang(isnotuprear),expb,kv.exptang(excluderu));
  end

  qe = mean(qet)*100;
  pe = mean(pet);
  eb = mean(ebt);

  if flags.do_QE_PE_EB
    varargout{1} = qe;
    varargout{2} = pe;
    varargout{3} = eb;
  elseif flags.do_PE 
    varargout{1} = qe;
  elseif flags.do_QE 
    varargout{1} = pe;
  elseif flags.do_EB
    varargout{1} = eb;
  end
  
  
elseif flags.do_absPE
  
  apet = zeros(nt,1);
  for ii = 1:nt % for all target positions

      d = tang(ii)-rang;                 % wraped angular distance between tang & rang
      iduw = (d < -180) | (180 < d);     % 180-deg unwrap indices
      d(iduw) = mod(d(iduw) + 180,360) - 180; % 180-deg unwrap
      d = abs(d);                        % absolut distance
      apet(ii) = sum( p(:,ii) .* d);     % absolute polar angle error for target ii

  end

  ape = mean(apet);
  
  varargout{1} = ape;
  
end

%% Print Output

if flags.do_print
  if flags.do_QE_PE_EB
    fprintf('Quadrant errors (%%) \t\t %4.1f \n',qe)
    fprintf('Local polar RMS error (deg) \t %4.1f \n',pe)
    fprintf('Local polar bias (deg) \t\t %4.1f \n',eb)
  elseif flags.do_PE 
    fprintf('Quadrant errors (%%) \t\t %4.1f \n',qe)
  elseif flags.do_QE 
    fprintf('Local polar RMS error (deg) \t %4.1f \n',pe)
  elseif flags.do_EB
    fprintf('Local elevation bias (deg) \t\t %4.1f \n',eb)
  elseif flags.do_absPE
    fprintf('Absolute polar error (deg) \t\t %4.1f \n',ape)
  end
end

end