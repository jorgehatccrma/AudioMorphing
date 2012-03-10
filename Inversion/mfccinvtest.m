% function [output,spectrogram,fbOutput,cepOutput,fbRecon] = mfccinvtest(...
%			input, samplingRate, frameRate, useFB, useDCT, ...
%			useRasta,showHighs)
%
% output is the final spectrogram reconstruction (without preemphasis)
% spectrogram is the intial (exact) signal spectrogram (with high-freq-emphasis)
% fbOutput is the filter-bank output (40 channels)
% cepOutput is the cepstral output (13 channels)
% fbRecon is the reconstruction of the filterbank output from DCT (40 channels)
%  The final output (fbOutput, cepOutput, spectrogram) is filtered by RASTA.
% Cleanup up on January 29, 1996

function [output,spectrogram,fbOutput,cepOutput,fbRecon] = mfccinvtest(...
			input, samplingRate, frameRate, useFB, useDCT, ...
			useRasta, showHighs)

[r c] = size(input);
if (r > c) 
	input=input';
end
if (nargin < 2) samplingRate = 16000; end;
if (nargin < 3) frameRate = 100; end;
if (nargin < 4) useFB = 1; end;
if (nargin < 5) useDCT = 1; end;
if (nargin < 6) useRasta = 0; end;
if (nargin < 7) showHighs = 1; end;

origMFCC = 0;

%	Filter bank parameters
lowestFrequency = 133.3333;
linearFilters = 13;
linearSpacing = 66.66666666;
logFilters = 27;
logSpacing = 1.0711703;
fftSize = 512;
cepstralCoefficients = 13;
if (origMFCC > 0)
	fftSize = 512;
	windowSize = 400;
	hamWindow = 0.54 - 0.46*cos(2*pi*(0:windowSize-1)/windowSize);
else
	fftSize = 1024;
	windowSize = 512;
	a = .54;
	b = -.46;
	wr = sqrt((samplingRate/frameRate)/windowSize);
	phi = pi/windowSize;
	hamWindow = 2*wr/sqrt(4*a*a+2*b*b)*(a + b*cos(2*pi*(0:windowSize-1)/windowSize + phi));
end

% Keep this around for later....
totalFilters = linearFilters + logFilters;

% Now figure the band edges.  Interesting frequencies are spaced
% by linearSpacing for a while, then go logarithmic.  First figure
% all the interesting frequencies.  Lower, center, and upper band
% edges are all consequtive interesting frequencies. 

freqs = lowestFrequency + (0:linearFilters-1)*linearSpacing;
freqs(linearFilters+1:totalFilters+2) = ...
				      freqs(linearFilters) * logSpacing.^(1:logFilters+2);

lower = freqs(1:totalFilters);
center = freqs(2:totalFilters+1);
upper = freqs(3:totalFilters+2);

% We now want to combine FFT bins so that each filter has unit
% weight, assuming a triangular weighting function.  First figure
% out the height of the triangle, then we can figure out each 
% frequencies contribution
mfccFilterWeights = zeros(totalFilters,fftSize/2);
triangleHeight = 2./(upper-lower);
fftFreqs = (0:(fftSize/2-1))/fftSize*samplingRate;

for chan=1:totalFilters
	mfccFilterWeights(chan,:) = ...
  (fftFreqs > lower(chan) & fftFreqs <= center(chan)).* ...
   triangleHeight(chan).*(fftFreqs-lower(chan))/(center(chan)-lower(chan)) + ...
  (fftFreqs > center(chan) & fftFreqs < upper(chan)).* ...
   triangleHeight(chan).*(upper(chan)-fftFreqs)/(upper(chan)-center(chan));
end
%semilogx(fftFreqs,mfccFilterWeights')
%axis([lower(1) upper(totalFilters) 0 max(max(mfccFilterWeights))])

% Figure out Discrete Cosine Transform.  We want a matrix
% dct(i,j) which is totalFilters x cepstralCoefficients in size.
% The i,j component is given by 
%                cos( i * (j+0.5)/totalFilters pi )
% where we have assumed that i and j start at 0.
fbDCTMatrix = 1/sqrt(totalFilters/2)*cos((0:(cepstralCoefficients-1))' * ...
						(2*(0:(totalFilters-1))+1) * pi/2/totalFilters);
fbDCTMatrix(1,:) = fbDCTMatrix(1,:) * sqrt(2)/2;

fftDCTMatrix = 1/sqrt(fftSize/2)*cos((0:(cepstralCoefficients-1))' * ...
						(2*(0:(fftSize/2-1))+1) * pi/2/(fftSize/2));
fftDCTMatrix(1,:) = fftDCTMatrix(1,:) * sqrt(2)/2;

%imagesc(fbDCTMatrix)
%imagesc(fftDCTMatrix);

% Filter the input with the preemphasis filter.  Also figure how
% many columns of data we will end up with.
preEmphasized = filter([1 -.97], 1, input);
windowStep = samplingRate/frameRate;
cols = fix((length(input)-windowSize)/windowStep);

% Invert the filter bank center frequencies.  For each FFT bin
% we want to know the exact position in the filter bank to find
% the original frequency response.  The next block of code finds the
% integer and fractional sampling positions.
fbi = zeros(fftSize/2, totalFilters);
j = 1;
for i=1:(fftSize/2)
	fr = (i-1)/(fftSize/2)*samplingRate/2;
	if fr > center(j+1)
		j = j + 1;
	end
	if j > totalFilters-1
		j = totalFilters-1;
	end
	fr = min(totalFilters-.0001, ...
			    max(1,j + (fr-center(j))/(center(j+1)-center(j))));
	fri = fix(fr);
	frac = fr - fri;
	fbi(i,j) = samplingRate/fftSize * (1-frac);
	fbi(i,j+1) = samplingRate/fftSize * frac;
end

% Allocate all the space we need for the output arrays.
spectrogram = zeros(fftSize/2, cols);

% Ok, now let's do the processing.  For all data:
%    * Window the data with a hamming window,
%    * Shift it into FFT order,
%    * Find the magnitude of the fft,
%    * Convert the fft data into filter bank outputs,
%    * Find the log base 10,
%    * Find the cosine transform to reduce dimensionality.
%
% For now, we just compute the spectrum.  The remaining steps will
% follow and are optional.
for start=0:cols-1
    first = start*windowStep + 1;
    last = first + windowSize-1;
    fftData = zeros(fftSize,1);
    fftData(1:windowSize) = preEmphasized(first:last).*hamWindow;
    fftMag = fft(fftshift(fftData));
	spectrogram(:,start+1) = abs(fftMag(1:(fftSize/2)));
end

% OK, here are the forward paths.  Our final output depends
% on which components are plugged together.
if (useFB > 0)
	if (useDCT > 0)
		fbOutput = log10(mfccFilterWeights * spectrogram);
		cepOutput = fbDCTMatrix * fbOutput;
	else
		fbOutput = log10(mfccFilterWeights * spectrogram);		
	end
else
	if (useDCT > 0)
		cepOutput = fftDCTMatrix * log10(spectrogram);
	else
	end
end

if (useRasta > 0)
	if (useDCT > 0)
		cepOutput = rasta(cepOutput, frameRate);
	elseif (useFB > 0)
		fbOutput = rasta(fbOutput, frameRate);
	else
		spectrogram = rasta(spectrogram, frameRate);
	end
end

% The inverse path.
if (useFB > 0)
	if (useDCT > 0)
		fbRecon = fbDCTMatrix' * cepOutput;
		spectrogramRecon = fbi * 10.^fbRecon;
	else
		fbRecon = fbOutput;
		spectrogramRecon = fbi * 10.^fbRecon;		
	end
else
	if (useDCT > 0)
		spectrogramRecon = 10.^(fftDCTMatrix' * cepOutput);
	else
		spectrogramRecon = spectrogram;
	end
end
		
% Now compensate for the coloration added by the preemphasis filter.
% We compute the absolute value of the spectrum of the z-transform
% describing the filter.
if (showHighs == 0)
	i=sqrt(-1);
	color=1.0 ./ abs(1-.97*exp(i*(0:(fftSize/2-1))'/(fftSize/2)*pi));
	
	for j=1:size(spectrogramRecon,2)
		spectrogramRecon(:,j) = color .* spectrogramRecon(:,j);
	end
end
output = spectrogramRecon;
