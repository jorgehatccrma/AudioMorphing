% Ear Model Parameters

if 1
	earQ = 4;
	stepfactor = .25;
	sr = 22254.5454;

	agcParms = [.0032 .0016 .0008 .0004; ...
			EpsilonFromTauFS(.64,sr) EpsilonFromTauFS(.16,sr) ...
			EpsilonFromTauFS(.04,sr) EpsilonFromTauFS(.01,sr)];

	[earFilters, cfs, gains] = DesignLyonFilters(sr, earQ, stepfactor);
	[channels, width] = size(earFilters);
	frameIncrement=128;
	winLength=1024;

	if exist('oboe') ~= 1
		oboe = ReadSound('../Sounds/ShortMcAdams.m22');
	end
	input = oboe;
	input = input'.*hamming(length(input));
	FileSpec = 'oboe/oboe%05d';
	if 1
		CorrelogramFiles(input, sr, FileSpec, 65535);
	end
	[y coch] = CorrelogramInvert(FileSpec, earFilters, gains, ...
					agcParms, sr, frameIncrement, ...
					winLength);
end
if 0
	if exist('huge') ~= 1
		huge = ReadSound('data.adc');
	end
	tap = huge(14000:17000);
	tap = tap'.*hamming(length(tap));
	FileSpec = '/usr/tmp/tap/tap%05d';
	if 1
		CorrelogramFiles(tap, sr, FileSpec, 65535);
	end
	[y coch] = CorrelogramInvert(FileSpec, earFilters, gains, ...
					agcParms, sr, frameIncrement, ...
					winLength);
end

oboepics='/usr/tmp/oboe/motion-oboe%05d(512x94).pgm';
frameIncrement=222;
winLength=256;
if 0
	oboe = ReadSound('../Sounds/ShortMcAdams.m22');
	df = 1;
	agcf = 1;
	differ = 1;
	taufactor = 1;
	dtCochleagram = LyonPassiveEar(oboe, sr, df, earQ, stepfactor, ...
					differ, agcf, taufactor);
	subplot(2,2,4);
	simage(CorrelogramFrame(dtCochleagram,512,10000,1024),0,.0032)
	title('dtCochleagram');
	drawnow;

	differ = 0;
	taufactor = 1;
	tCochleagram = LyonPassiveEar(oboe, sr, df, earQ, stepfactor, ...
					differ, agcf, taufactor);
	subplot(2,2,2);
	simage(CorrelogramFrame(tCochleagram,512,10000,1024),0,.0032)
	title('tCochleagram');
	drawnow;

	differ = 1;
	taufactor = 0;
	dCochleagram = LyonPassiveEar(oboe, sr, df, earQ, stepfactor, ...
					differ, agcf, taufactor);
	subplot(2,2,3);
	simage(CorrelogramFrame(dCochleagram,512,10000,1024),0,.0032)
	title('dCochleagram');
	drawnow;

	differ = 0;
	taufactor = 0;
	Cochleagram = LyonPassiveEar(oboe, sr, df, earQ, stepfactor, ...
					differ, agcf, taufactor);
	subplot(2,2,1);
	simage(CorrelogramFrame(Cochleagram,512,10000,1024),0,.0032)
	title('Cochleagram');
	drawnow;
end

if 0
	[y cochleagram]=CorrelogramInvert(oboepics, earFilters, gains,...
					agcParms, sr, frameIncrement, winLength)
end
