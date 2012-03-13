% function [signal,lastSpectrum] = SpectrumInversion(spectrum,frameIncrement,...
%					winLength, iterations, ...
%					initialPhase, hwr);
% Invert a spectrogram into the original time-domain signal by recovering
% the phase.  The frameIncrement and winLength describe the original parameters
% of the spectrogram.  iterations is the number of phase-recovery iterations
% to perform.  InitialPhase is an array of initial phase guesses (perhaps
% from a similar reconstruction), and hwr is a flag indicating whether the
% signal is positive only (which can be enforced each time through the loop.)

function [signal,lastSpectrum] = SpectrumInversion(spectrum, frameIncrement,...
					winLength, iterations, ...
					initialPhase, hwr);
if nargin < 4
	iterations = 10;
end

if nargin < 5
	initialPhase = [];
end

if nargin < 6
	hwr = 0;
end

iter = 0;					% First time through
cInitialPhase = 2;			% Linearly weighted cross-correlation
%cInitialPhase = 0;			% Zero Phase at start for each frame.
cNoCorrelation = 0;			% Don't do any cross-correlation
cFFTShift = 1;				% Always do the FFTShift

if length(initialPhase) > 0
	spectrum = MatchMagnitudes(spectrum, initialPhase);

	signal=real(InvertAndAdd(spectrum, frameIncrement, winLength, ...
					iter, cFFTShift, cNoCorrelation));
else
	signal=real(InvertAndAdd(abs(spectrum), frameIncrement, winLength, ...
					iter, cFFTShift, cInitialPhase));
end

if max(max(abs(spectrum))) == 0
	fprintf('Spectrum is zero. Returning without iterations.\n');
	lastSpectrum = spectrum;
	return
end
	
for iter=1:iterations
	lastSpectrum = ComplexSpectrum(signal, frameIncrement, winLength, ...
					cFFTShift);
	if size(lastSpectrum,1) == size(spectrum,1)+1
		fprintf('Adding an extra row to spectrum\n');
		spectrum = [spectrum;zeros(1,size(spectrum,2))];
	end
	theErr = sum(sum((abs(spectrum)-abs(lastSpectrum)).^2))/ ...
		sum(sum(abs(spectrum).^2))*100;
% 	fprintf('Error for iteration %d is %g%%.\n', iter, theErr);
%	corInvError(iter, c) = theErr;
%	errorHistory(f) = theErr;
	lastSpectrum = MatchMagnitudes(spectrum, lastSpectrum);
	signal = real(InvertAndAdd(lastSpectrum, frameIncrement, winLength, ...
					iter, cFFTShift, cInitialPhase));
	if hwr > 0
		signal = max(0,signal);
	end
%	WriteSound(signal,16000,sprintf('MatlabRecon%d.aiff',iter));
%	pix = min(1500,min(length(cochleagram(c,:)),length(yp)));
%	plot([yp(1:pix)' -cochleagram(c,1:pix)']);
%	drawnow;
end
