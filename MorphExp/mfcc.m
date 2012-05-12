%  mfcc - Mel frequency cepstrum coefficient analysis.
%   [ceps,freqresp,fb,recon] = mfcc(input, samplingRate)
% Find the cepstral coefficients (ceps) corresponding to the
% input.  Three other quantities are optionally returned that
% represent the detailed fft magnitude (freqresp), the mel-scale 
% filter bank output (fb), and the reconstruction of the filter
% bank output by inverting the cosine transform.
%  -- Malcolm Slaney, August 1993

function [ceps,freqresp,fb,recon] = mfcc(input, samplingRate)

%	Filter bank parameters
lowestFrequency = 133.3333;
linearFilters = 13;
linearSpacing = 66.66666666;
logFilters = 27;
logSpacing = 1.0711703;
fftSize = 512;
cepstralCoefficients = 13;
% windowSize = 400;
% frameRate = 100;
windowSize = 256;
frameRate = samplingRate/32;
if (nargin < 2) samplingRate = 16000; end;

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
filterWeights = zeros(totalFilters,fftSize);
triangleHeight = 2./(upper-lower);
fftFreqs = (0:fftSize-1)/fftSize*samplingRate;

for chan=1:totalFilters
	filterWeights(chan,:) = ...
  (fftFreqs > lower(chan) & fftFreqs <= center(chan)).* ...
   triangleHeight(chan).*(fftFreqs-lower(chan))/(center(chan)-lower(chan)) + ...
  (fftFreqs > center(chan) & fftFreqs < upper(chan)).* ...
   triangleHeight(chan).*(upper(chan)-fftFreqs)/(upper(chan)-center(chan));
end
%semilogx(fftFreqs,filterWeights')
%axis([lower(1) upper(totalFilters) 0 max(max(filterWeights))])

hamWindow = 0.54 - 0.46*cos(2*pi*(0:windowSize-1)/windowSize);

% Figure out Discrete Cosine Transform.  We want a matrix
% dct(i,j) which is totalFilters x cepstralCoefficients in size.
% The i,j component is given by 
%                 i/totalFilters * (j+0.5) pi
% where we have assumed that i and j start at 0.
dctMatrix = cos((0:totalFilters-1)'/totalFilters * ...
                ((0:cepstralCoefficients-1)+0.5)*pi);

% Filter the input with the preemphasis filter.  Also figure how
% many columns of data we will end up with.
preEmphasized = filter([1 -.97], 1, input);
windowStep = samplingRate/frameRate;
cols = fix((length(input)-windowSize)/windowStep);

% Allocate all the space we need for the output arrays.
ceps = zeros(cepstralCoefficients, cols);
if (nargout > 1) freqresp = zeros(fftSize/2, cols); end;
if (nargout > 2) fb = zeros(totalFilters, cols); end;

% Ok, now let's do the processing.  For each chunk of data:
%    * Window the data with a hamming window,
%    * Shift it into FFT order,
%    * Find the magnitude of the fft,
%    * Convert the fft data into filter bank outputs,
%    * Find the log base 10,
%    * Find the cosine transform to reduce dimensionality.
for start=0:cols-1
    first = start*windowStep + 1;
    last = first + windowSize-1;
    fftData = zeros(1,fftSize);
    fftData(1:windowSize) = preEmphasized(first:last).*hamWindow;
    fftMag = abs(fft(fftshift(fftData)));
    earMag = log10(filterWeights * fftMag');

    ceps(:,start+1) = dctMatrix' * earMag;
    if (nargout > 1) freqresp(:,start+1) = fftMag(1:fftSize/2)'; end;
    if (nargout > 2) fb(:,start+1) = earMag; end
end

% OK, just to check things, let's also reconstruct the original FB
% output.  We do this by multiplying the cepstral data by the cosine 
% transform
if (nargout > 3) recon = dctMatrix * ceps; end;
