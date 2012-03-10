function y = InvertAndAdd(s, increment, winLength, iteration, doFFTShift, initialPhase);
% function y = InvertAndAdd(s, increment, winLength, iteration, ...
%		doFFTShift, initialPhase);
% Perform one stage of the Spectrogram Inversion.  Invert the (complex) 
% spectrogram (s), assuming frames are "increment" samples apart and the window
% is "winLength" samples long in the time domain.  The "iteration" variable
% controls how phase is estimated (phase guessing is only done on the first
% iteration.)  doFFTShift says whether the data was shifted to give cosine
% phase before FFT'ing.  initialPhase determines the phase guessing algorithm
% used on iteration 1.
%
% The spectrogram argument is just the positive frequencies of the spectrogram.

if nargin < 4
        iteration = 1;
%       disp('Assuming no Roucos-Wilgus.');
end

if nargin < 5
        doFFTShift = 1;
end

%       0 means assume 0 phase for all windows (only matters after first.)
%       1 means do unweighted cross-correlation and pick peak
%       2 means do linearly weighted cross-correlation to pick peak.
if nargin < 6
        initialPhase = 2;
end

[fftLen frameCount] = size(s);
fftLen = floor(fftLen/2)*2*2;			% Either 256 or 257 implies 512 length
if (winLength > fftLen)
	error('winLength is greater than fftLen');
end

y = zeros(1, (frameCount-1)*increment + winLength);
c = zeros(1, (frameCount-1)*increment + winLength);

a = .54;
b = -.46;
wr = sqrt(increment/winLength);
phi = pi/winLength;
ws = 2*wr/sqrt(4*a*a+2*b*b)*(a + b*cos(2*pi*(0:winLength-1)/winLength + phi));
%ws = ones(size(ws));

if initialPhase >= 2
        weighting = abs((0:winLength-1)-winLength/2)/(winLength/2);
else
        weighting = ones(1,winLength);
end

for i=1:frameCount
		halfSlice = s(:,i);
		halfLen = length(halfSlice);
		slice = zeros(1,fftLen);
		slice(1:halfLen) = halfSlice;
		slice(fftLen:-1:fftLen-halfLen+2) = conj(halfSlice(2:halfLen));
		slice = real(ifft(slice));
        if doFFTShift
                win = fftshift(slice);
                win = win((fftLen-winLength)/2+1:(fftLen+winLength)/2);
        else
                win = slice(1:winLength);
        end
        first = (i-1)*increment + 1;
        last = first + winLength - 1;
        if initialPhase > 0 & iteration < 1
                wf = fft(win);
                yf = fft(y(first:last));
                correlation = real(ifft(yf .* conj(wf))) .* weighting;
                [m shift] = max(correlation);
                win = win(1+rem((0:winLength-1)-shift+winLength, winLength));
        end
        win = win(1:winLength).*ws;
        y(first:last) = y(first:last) + win;
        c(first:last) = c(first:last) + ws.^2;
end
y = y./c;


% Test Code..... as of December 1, 1995.
%len=2000;
%window = [sin((1:200)/200*pi/2) ...
%		ones(1,len-200-200) ...
%		cos(-(1:200)/200*pi/2)];
%input = sin((1:2000)*2*pi/10) .* window;
%spec=abs(ComplexSpectrum(input,64,256));
%y=SpectrumInversion(spec,64,256);

%Error for iteration 1 is 29.2517%.
%Error for iteration 2 is 9.10153%.
%Error for iteration 3 is 3.73284%.
%Error for iteration 4 is 1.68824%.
%Error for iteration 5 is 0.783758%.
%Error for iteration 6 is 0.382757%.
%Error for iteration 7 is 0.196192%.
%Error for iteration 8 is 0.107335%.
%Error for iteration 9 is 0.0643242%.
%Error for iteration 10 is 0.0425502%.
