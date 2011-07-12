function outsig = bincorrnoise(siglen,coher,varargin)
% BINCORRNOISE  Binaurally correlated noise
%   Usage: outsig = bincorrnoise(siglen,coher)
%
%   Input parameters:
%       siglen    - Number of samples of outsig
%       coher     - Interaural coherence of the produced signal.
%
%   Output parameters:
%       outsig  - nsig x 2 correlated noise signal
%
%   BINCORRNOISE(siglen,coher) will generate a interaurally correlated noise signal 
%   with coherence coher. The output is a 2 column matrix of length siglen.
%
%   BINCORRNOISE(siglen,coher,...) will pass all additional parameters onto the NOISE function
%   to select between different types of stochastic noise.
%
%   AUTHOR: Hagen Wierstorf


% ------ Checking of input parameters ------------------------------------

if nargin<2
  error('%s: Too few input parameters.',upper(mfilename));
end;

if ( ~isnumeric(siglen) || ~isscalar(siglen) || siglen<0 )
    error('%s: siglen has to be a positive scalar.',upper(mfilename));
end

if ( ~isnumeric(coher) || ~isscalar(coher) || coher<0)
    error('%s: coher has to be a positive scalar.',upper(mfilename));
end


% ------ Computation -----------------------------------------------------

% Generate correlation matrix
R = [1 coher; coher 1];
% Eigen decomposition
[V,D] = eig(R);

% Form correlating filter
W = V*sqrt(D);

% Generate uncorrelated noise
n = noise(siglen,2,varargin{:});

% Correlate the noise
outsig = n * W';
