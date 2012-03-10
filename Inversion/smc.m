% Code to create figures for the IEEE-SMC-95 (in Vancouver) paper.
% Be sure to set the output options to bitmap graphics with EPS!

% Set figure 1 to be all black lines
if 0
	set(1,'defaultaxescolororder',[0 0 0]);
	set(figure(1),'position',[109 174 349 254]);
	% Scale resulting spectrogram by 45%
end

% Spectrogram phase with a sinusoid
if 0
	input=sin((0:2047)/25*2*pi);
%	input = input .* (0.54+0.46*sin((1:length(input))/length(input)*pi));
	winIncrement = 64;
	winLength = 256;
	fftShift = 1;
	spectrum = abs(ComplexSpectrum(input, winIncrement, ...
							winLength, fftShift));

	if 1
		iterations = 0;
		ns0 = SpectrumInversion(spectrum, winIncrement,...
						winLength, iterations, ones(size(spectrum)));
			
		iterations = 5;			
		ns10 = SpectrumInversion(spectrum, winIncrement,...
						winLength, iterations, ones(size(spectrum)));
	end
	
	if 1
		iterations = 0;
		s0 = SpectrumInversion(spectrum, winIncrement,...
						winLength, iterations);
			
		iterations = 5;			
		s10 = SpectrumInversion(spectrum, winIncrement,...
						winLength, iterations);
	end
	
	clg
	l=256;h=1.4;
	subplot(2,2,1); plot(ns0);ylabel('Zero Phase');axis([1 l -h h]);
							  title('Zero Iterations');
	subplot(2,2,2); plot(ns10);axis([1 l -h h]);
							   title('Five Iterations');
	subplot(2,2,3); plot(s0);ylabel('Rotated Phase');axis([1 l -h h]);
	subplot(2,2,4); plot(s10);axis([1 l -h h]);
end

if exist('tapestry') ~= 1
%	tapestry = ReadSound('PowerMalcolm:data.adc');
	tapestry = ReadSound('data.adc');
	sr = 16000;
	agcParms = [.0032 .0016 .0008 .0004; ...
            EpsilonFromTauFS(.64,sr) EpsilonFromTauFS(.16,sr) ...
            EpsilonFromTauFS(.04,sr) EpsilonFromTauFS(.01,sr)];
end

if 0
	tapGain = 1;
	input = tapGain*tapestry(14000:17000);
	impulse = zeros(1,512);
	impulse(length(impulse)/2) = 1;
	impulse(length(impulse)/2+1) = 0.5;
	impulse(length(impulse)/2-1) = 0.5;
	
	earQ = 8; stepfactor = earQ/32;
	if ~(exist('earFilters') == 1)
		[earFilters, cfs, gains] = DesignLyonFilters(sr, earQ, stepfactor);
		[channels, width] = size(earFilters);
	end

	cochlearIterations = 5;
	soscascade('reset');
	agc('reset');
	cochleagram = LyonPassiveEar(input, sr, 1, earQ, stepfactor, 0,1,3);
	paddedCoch = [zeros(2,size(cochleagram,2)) ;  cochleagram];
	coch1=CochlearInversion(paddedCoch, earFilters, gains, agcParms, sr, ...
				cochlearIterations);
				
	cochlearIterations = 5;
	soscascade('reset');
	agc('reset');
	cochleagram = LyonPassiveEar(input, sr, 1, earQ, stepfactor, 0,1,3)/100;
	paddedCoch = [zeros(2,size(cochleagram,2)) ;  cochleagram];
	cochnoagc=CochlearInversion(paddedCoch, earFilters, gains, agcParms, sr, ...
				cochlearIterations);
	cochnoagc = cochnoagc/max(max(cochnoagc))*.5;
	
	cochlearIterations = 1;
	soscascade('reset');
	agc('reset');
	cochleagram = LyonPassiveEar(impulse, sr, 1, earQ, stepfactor, 0,1,3);
	paddedCoch = [zeros(2,size(cochleagram,2)) ;  cochleagram];
	impulse1=CochlearInversion(paddedCoch, earFilters, gains, agcParms, sr, ...
				cochlearIterations);

	cochlearIterations = 10;
	soscascade('reset');
	agc('reset');
	cochleagram = LyonPassiveEar(impulse, sr, 1, earQ, stepfactor, 0,1,3);
	paddedCoch = [zeros(2,size(cochleagram,2)) ;  cochleagram];
	impulse5=CochlearInversion(paddedCoch, earFilters, gains, agcParms, sr, ...
				cochlearIterations);
	clg;
	subplot(2,2,1);plot(impulse1);title('One Iteration');axis([1 512 -.05 .05]);
	subplot(2,2,2);plot(impulse5);title('Five Iterations');axis([1 512 -.05 .05]);
	subplot(2,2,3);plot(coch1);title('Tap with AGC');
	subplot(2,2,4);plot(cochnoagc);title('Tap without Compression');
end

if 1
	earQ = 4;
	stepfactor = .5;
%	input = .01*tapestry(14000:17000);
	input = .01*tapestry;

	if ~(exist('earFilters') == 1)
        [earFilters, cfs, gains] = DesignLyonFilters(sr, earQ, stepfactor);
        [channels, width] = size(earFilters);
	end
	frameIncrement = 64;
	winLength=256;
	soscascade('reset');
	agc('reset');
	cochleagram = LyonPassiveEar(input, sr, 1, earQ, stepfactor, 0,1,3);
    correlogram=CorrelogramArray(cochleagram, sr, sr/frameIncrement, winLength);

	% Correlogram Inversion of Tapestry with no iterations.
	[cory1,cochleagram]=CorrelogramInvert(correlogram, sr, frameIncrement,...
					winLength, earFilters, gains, agcParms,1);
	cory1 = cory1/max(max(cory1))*.5;

	% Correlogram Inversion of Tapestry with 10 iterations.
	[cory,cochleagram]=CorrelogramInvert(correlogram, sr, frameIncrement,...
					winLength, earFilters, gains, agcParms);
	cory = cory/max(max(cory))*.5;
	
	len = 3000;
	impulses = zeros(1,len);
	pulses = 10:80:len;
	sr = 16000;
	impulses(pulses) = ones(1,length(pulses));

	soscascade('reset');
	agc('reset');
	cochleagram = LyonPassiveEar(impulses, sr, 1, earQ, stepfactor, 0,1,3);
    correlogram=CorrelogramArray(cochleagram, sr, sr/frameIncrement, winLength);

	% Correlogram Inversion of Impulse Train with 10 iterations.
	[cori,cochleagram]=CorrelogramInvert(correlogram, sr, frameIncrement,...
					winLength, earFilters, gains, agcParms);
	cori = cori/max(max(cori))*50;
	% Correlogram Inversion of Impulse Train with no iterations.
	[cori1,cochleagram]=CorrelogramInvert(correlogram, sr, frameIncrement,...
					winLength, earFilters, gains, agcParms,1);
	cori1 = cori1/max(max(cori1))*2.5;

	clg
	subplot(2,2,1);plot(cori1);title('Zero Iterations');axis([1 200 -.3 .3]);
								ylabel('Impulse Train');
	subplot(2,2,2);plot(cori);title('10 Iterations');axis([1 200 -.3 .3]);
	subplot(2,2,3);plot(cory1);ylabel('Tap Reconstruction');
	subplot(2,2,4);plot(cory);

end
