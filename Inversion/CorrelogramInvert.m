% [y,cochleagram]=CorrelogramInvert(correlogram, sr, frameIncrement,...
%				winLength, earFilters, gains, agcParms, maxIters))
% Invert a correlogam back into the time domain.  For each channel, undo the
% autocorrelations and recover a spectrogram, then invert each spectrogram
% to get a cochleagram channel.  The final cochleagram estimate is then
% run back through the cochlear inversion.
% 
% earFilters, gains, agcParms, and sr are all parameters of the cochlear
% inversion.  frameIncrement and winLength are parameters of the correlogram
% inversion.

function [y,cochleagram]=CorrelogramInvert(correlogram, sr, frameIncrement,...
				winLength, earFilters, gains, agcParms, maxIters))

if nargin < 8
	maxIters = 10;
end

if nargin < 7
	agcParms = [.0032 .0016 .0008 .0004; ...
			EpsilonFromTauFS(.64,sr) EpsilonFromTauFS(.16,sr) ...
			EpsilonFromTauFS(.04,sr) EpsilonFromTauFS(.01,sr)];
end

if nargin < 6
	earQ = 8;
	stepfactor = earQ/32;
	[defaultEarFilters, defaultCfs, defaultGains] = ...
				DesignLyonFilters(sr, earQ, stepfactor); 
	gains = defaultGains;
end

if nargin < 5
	earFilters = defaultEarFilters;
end

[channels filtorder] = size(earFilters);
[x agcStages] = size(agcParms);
outputMax = agcParms(1,agcStages)*8;

[pixels frames] = size(correlogram);
if pixels/winLength ~= channels-2
	error('Ear model and correlogram don''t have same number of channels.')
end

lastSpec = [];
iterations = maxIters;	% First time through....
cHalfWaveTrue = 1;		% Correlograms need HWR Inversion
for chan = 3:channels
%	fprintf('Working on channel %d.\n', chan);
	spec = Cgram2Specgram(correlogram, chan-2, channels-2, outputMax);
	if max(max(abs(spec))) == 0
		fprintf('Spectrogram of channel %d is zero, skipping.\n', ...
			chan);
				% Fill in the missing channel of zeros
		if exist('cochleagram') == 1
			cochleagram(chan,:) = 0*cochleagram(chan-1,:);
			fprintf(' Filling in channel %d.\n',chan);
		end
	else
		[coch lastSpec] = SpectrumInversion(spec, frameIncrement, ...
						winLength, iterations, ...
						lastSpec, cHalfWaveTrue);
		iterations = floor(maxIters/3);	% From now on, just do a couple of iterations.
		cochleagram(chan,:) = coch;
%		simage(cochleagram, 0, outputMax);
		plot(coch(1:1500));
		drawnow;
	end
end

cochlearIterations = 10;
y=CochlearInversion(cochleagram, earFilters, gains, agcParms, sr, ...
			cochlearIterations);
