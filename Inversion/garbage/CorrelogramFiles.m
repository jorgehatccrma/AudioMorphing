function CorrelogramFiles(sound, sr, fileSpec, pixelSize)
global agcParms earQ stepfactor frameIncrement winLength
global earFilters cfs gains

if nargin < 4
	pixelSize = 255;
end

df = 1;
earQ = 4;
stepfactor = .25;
differ = 0;
frameIncrement = 128;
winLength = 1024;

cochleagram = LyonPassiveEar(sound, sr, df, earQ, stepfactor, differ);

agcParms = [.0032 .0016 .0008 .0004; ...
		EpsilonFromTauFS(.64,sr) EpsilonFromTauFS(.16,sr) ...
		EpsilonFromTauFS(.04,sr) EpsilonFromTauFS(.01,sr)];
correlogramMax = agcParms(1,4)*8;

[channels len] = size(cochleagram);

frameNumber = 1;
for startSamp=1:frameIncrement:len
	correlogram=CorrelogramFrame(cochleagram, winLength, startSamp, ...
					winLength);
	[rows cols] = size(correlogram);
	fileName = sprintf(fileSpec, frameNumber);
	frameNumber = frameNumber+1;
	WriteImage(fileName, correlogram*255/correlogramMax,pixelSize);
end

