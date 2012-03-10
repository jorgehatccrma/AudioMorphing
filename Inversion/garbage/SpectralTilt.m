function new = SpectralTilt(data, direction)
% Add or subtract the spectral tilt due to the (1-.97/z) filter used
% to emphasize the high frequencies in a spectrogram.  A direction of
% plus 1 (the default) emphasizes the high frequencies, while direction
% less than zero undoes the spectral emphasis.

if nargin < 2
	direction = 1;
end

fftSize = floor(size(data,1)/2)*2;

theory = abs(1-.97*exp(i*(0:(size(data,1)-1))'/fftSize*pi));
theory = theory/max(max(theory));

if direction < 0
	theory = 1. ./ theory;
end

new = zeros(size(data));
for j=1:size(data,2)
	new(:,j) = theory.*data(:,j);
end
