% [err, y, coch, cor]=TestSep(earQ,stepfactor,frameRate,width,gain)
% Explore the range of valid parameters for the correlogram
% reconstruction.
function [err, y, coch, cor]=TestSep(earQ,stepfactor,frameRate,width,gain)
global tapestry

if nargin < 5
	gain = 1;
end

if nargin < 4
	width = 128;
end

signal=[];
if length(signal) < 1
	if exist('tapestry') ~= 1
		tapestry = ReadSound('data.adc');
	end
	sr=16000;
%       signal = tapestry(14000:25000);          % The word 'tapestry'
	signal = tapestry(14000:17000);          % The word 'tap'
	signal = gain*signal.*hamming(length(signal))';
end

if nargin < 3
	frameRate = sr/64;
end

if nargin < 1
	earQ = 4;
end

if nargin < 2
	stepfactor = earQ/16;
end

name=sprintf('TestSep-%d-%f-%d-%d-%g.aiff', earQ, stepfactor, frameRate, ...
		width, gain);

if exist(name) == 2
	fprintf('The %s file already exists... skipping.\n', ...
			name);
	err = 0;
	return;
end

df = 1;
differ = 0;

soscascade('reset');
agc('reset');
coch = LyonPassiveEar(signal,sr,df,earQ,stepfactor,differ);
[defaultEarFilters, defaultCfs, defaultGains] = ...
				DesignLyonFilters(sr, earQ, stepfactor);

cor = CorrelogramArray(coch,sr,frameRate,width);

y = CorrelogramInvert(cor,sr,floor(sr/frameRate),width,defaultEarFilters, ...
			defaultGains);

sigspec = rawstft(signal,256,2,2) .^ 2;
yspec = rawstft(y,256,2,2) .^ 2;
err = sum(sum(abs(sigspec-yspec)));
sigpow = sum(sum(sigspec));
err = 10*log10(sigpow/err);

fprintf('For %s, SNR is %g.\n', name, err);
WriteSound(y,sr,name);
