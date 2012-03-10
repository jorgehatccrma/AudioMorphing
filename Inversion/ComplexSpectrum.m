function s = ComplexSpectrum(input, increment, winLength, doFFTShift)
% function s = ComplexSpectrum(input, increment, winLength, doFFTShift)
% Compute the complex spectrum of an input signal.  Each frame is winLength
% long and starts increment samples after previous frame's start.  doFFTShift
% (default value true) controls whether the data is shifted so that it's
% center is at the start and end of the array (so FFT is more cosine phase)
% Only zero and the positive frequencies are returned.

if nargin < 4
        doFFTShift = 1;
end

inputLength = length(input);
frameCount = floor((inputLength-winLength)/increment)+1;
fftLen = 2^(nextpow2(winLength)+1);

a = .54;
b = -.46;
wr = sqrt(increment/winLength);
phi = pi/winLength;
ws = 2*wr/sqrt(4*a*a+2*b*b)*(a + b*cos(2*pi*(0:winLength-1)/winLength + phi));
s = zeros(fftLen/2+1, frameCount);

for i=1:frameCount
        start = (i-1)*increment + 1;
        last = start + winLength - 1;
        f = zeros(fftLen, 1);
        f(1:winLength) = ws.*input(start:last);
        if doFFTShift
                f = [f(winLength/2+1:winLength) ; ...
				     zeros(fftLen-winLength, 1) ; ...
                     f(1:winLength/2)];
        end
		specslice = fft(f);
		s(:,i) = specslice(1:(fftLen/2+1));
end
