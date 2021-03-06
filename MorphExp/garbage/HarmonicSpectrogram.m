function y=HarmonicSpectrogram(pitch,fftSize,sr);
% Create a spectrogram of a harmonic signal with the indicated pitch.

len = fftSize/2+1;
y = zeros(len,length(pitch));

if 0
	binSize=sr/fftSize;
	f = ((1:len)'-1)*binSize;
	
	for i=1:length(pitch)
		y(:,i) = cos(f/pitch(i)*pi).^2;
	end
else
	for i=1:length(pitch)
		points=1:sr/pitch(i):len;
		indices=floor(points);

		%  Use a triangular approximation to an impulse function.  The important
		%  part is to keep the total amplitude the same.
		voice = zeros(1,fftSize/2+1);
		voice(indices) = (indices+1)-points;
		voice(indices+1) = points-indices;
		
		a = exp(-250*2*pi/sr);
		voice = filter([1], [1,0,-a*a], voice);
		y(:,i) = abs(ComplexSpectrum(voice, 64, fftSize/2));
	end
end
