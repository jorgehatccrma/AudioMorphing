% Ear Model Parameters
earQ = 4;
stepfactor = .5;

if exist('useTap') ~= 1
        useTap = 1;
end

if useTap
	if useTap == 1
		if exist('tapestry') ~= 1
			tapestry = ReadSound('data.adc');
		end
		sr=16000;
		input = tapestry;			% The whole sentence
%		input = tapestry(14000:25000);          % The word 'tapestry'
%	       input = tapestry(14000:17000);          % The word 'tap'
%	       input = tapestry(6000:9000);            % Part of 'huge'
		input = .01*input;
%		input = input.*hamming(length(input))';
	else
		if exist('oboe') ~= 1
			oboe = ReadSound('../Sounds/ShortMcAdams.m22');
		end
		sr=22254.545454;
		input = oboe.*hamming(length(oboe))';
	end
else
        len = 2000;
        input = zeros(1,len);
        pulses = 10:80:len;
	sr = 16000;
        input(pulses) = ones(1,length(pulses));
end
agcParms = [.0032 .0016 .0008 .0004; ...
                EpsilonFromTauFS(.64,sr) EpsilonFromTauFS(.16,sr) ...
                EpsilonFromTauFS(.04,sr) EpsilonFromTauFS(.01,sr)];

signalEnergy = sum(input.^2);

if ~(exist('earFilters') == 1)
        [earFilters, cfs, gains] = DesignLyonFilters(sr, earQ, stepfactor);
        [channels, width] = size(earFilters);
end

if ~(exist('cochleagram') == 1)
        soscascade('reset');
        sosOutput = soscascade(input, earFilters);
        hwrOutput = max(0,sosOutput);
        agc('reset');
        cochleagram = agc(hwrOutput, agcParms);
        clear hwrOutput sosOutput;
end

if ~(exist('correlogram') == 1)
        correlogram=CorrelogramArray(cochleagram, sr, sr/64, 256);
end

