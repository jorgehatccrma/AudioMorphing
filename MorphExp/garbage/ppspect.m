function array = ppspect(wave,winSize);
%function array = ppspect(wave,winSize);
% defaults spectrogram(wave,256)
% Do a spectrogram, just like the spectrogram in the PatternPlayback
% PhotoShop filters.

if nargin < 2; winSize=256; end

[r c] = size(wave);
if (r < c)
%	wave = filter([1 -0.95],[1],wave');
	wave = wave';
else
%	wave = filter([1 -0.95],[1],wave);
end

segsize = winSize;
nlap = 4;
ntrans = 2;

		Increment=segsize/nlap;
		Length=winSize;
		a = .54;
		b = -.46;
		wr = sqrt(Increment/Length);
		phi = pi/Length;

		window = 2*wr/sqrt(4*a*a+2*b*b)* ...
					(a + b*cos(2*pi*(0:(Length-1))'/Length + phi));
					
s = length(wave);
nsegs = floor(s/(segsize/nlap))-nlap+1;
array = zeros(ntrans/2*segsize+1,nsegs);
%window = 0.54-0.46*cos(2*pi/(segsize+1)*(1:segsize)');
preemph = fliplr(1:(ntrans*segsize/2+1))';

for i = 1:nsegs
 seg = zeros(ntrans*segsize,1); % leave half full of zeroes
 seg(1:segsize) = ...
	 window.*wave(((i-1)*segsize/nlap+1):((i+nlap-1)*segsize/nlap));
 seg = abs(fft(seg));
						% reverse for image display
						% DC is at end of halfseg array
 halfseg = flipud(seg(1:(ntrans/2*segsize+1)));
 halfseg = halfseg.*preemph;
 array(:,i) = halfseg;
end

minimum = min(min(array));
maximum = max(max(array));

array = 255 - (array-minimum)/(maximum-minimum)*255;
