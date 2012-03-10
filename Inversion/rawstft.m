function array = rawstft(wave,segsize,nlap,ntrans);
%function array = rawstft(wave,segsize,nlap,ntrans);
% defaults spectrogram(wave,128,8,4)
% nlap is number of hamming windows overlapping a point;
% ntrans is factor by which transform is bigger than segment;
%returns a spectrogram 'array' with raw FFT outputs
% Started with Dick Lyon's spectrogram routine and stripped out
% the nice image smoothing and such.

if nargin < 4; ntrans=4; end
if nargin < 3; nlap=8; end
if nargin < 2; segsize=128; end

wave = filter([1 -0.95],[1],wave);
s = length(wave);
nsegs = floor(s/(segsize/nlap))-nlap+1;
array = zeros(ntrans/2*segsize,nsegs);
window = 0.54-0.46*cos(2*pi/(segsize+1)*(1:segsize)');
for i = 1:nsegs
 seg = zeros(ntrans*segsize,1); % leave half full of zeroes
 seg(1:segsize) = ...
	 window.*wave(((i-1)*segsize/nlap+1):((i+nlap-1)*segsize/nlap))';
 seg = abs(fft(seg));
						% reverse for image display
 array(:,i) = seg(((ntrans/2*segsize)+1):(ntrans*segsize)); 
end

