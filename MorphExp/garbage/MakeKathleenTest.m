if (exist('kathleen') ~= 1)
	if 0
		kathleen=ReadSound('KathleenRaw2.aiff');
	else
		load Kathleen.mat
	end
end

if (exist('yellow') ~= 1)
	yellow = kathleen(20000:50000);
	blue = kathleen(75000:105000);
	pope = kathleen(130000:160000);
	morning = kathleen(195000:230000);
	corner = kathleen(245000:275000);
	morning2 = kathleen(310000:345000);
end

sr = 22050;
windowSize=256;

frameIncrement = 64;
s64 = abs(SpectralTilt(ComplexSpectrum(yellow, frameIncrement, windowSize), 1));
ys64 = SpectrumInversion(SpectralTilt(s64,-1), frameIncrement, windowSize);
sys64 = abs(SpectralTilt(ComplexSpectrum(ys64, frameIncrement,windowSize), 1));
plot([s64(:,190) sys64(:,190)]);

frameIncrement = 32;
s32 = abs(SpectralTilt(ComplexSpectrum(yellow, frameIncrement, windowSize), 1));
ys32 = SpectrumInversion(SpectralTilt(s32,-1), frameIncrement, windowSize);
sys32 = abs(SpectralTilt(ComplexSpectrum(ys32, frameIncrement,windowSize), 1));
plot([s32(:,380) sys32(:,380)]);

frameIncrement = 16;
s16 = abs(SpectralTilt(ComplexSpectrum(yellow, frameIncrement, windowSize), 1));
ys16 = SpectrumInversion(SpectralTilt(s16,-1), frameIncrement, windowSize);
sys16 = abs(SpectralTilt(ComplexSpectrum(ys16, frameIncrement,windowSize), 1));
plot([s16(:,4*190) sys16(:,4*190)]);

subplot(2,1,1);
plot([s64(:,190) sys64(:,190)]);;
title('Window increment of 64');
subplot(2,1,2);
plot([s32(:,380) sys32(:,380)]);
title('Window increment of 32');

s=[yellow/max(yellow) ys64/max(ys64) ys32/max(ys32)];
WriteSound([s s], 22050, 'y6432.aiff');

WriteSound(yellow/max(yellow),22050,'yellow.aiff');
WriteSound(ys64/max(ys64),22050,'ys64.aiff');
WriteSound(ys32/max(ys32),22050,'ys32.aiff');
WriteSound(ys16/max(ys16),22050,'ys16.aiff');

if 0
	origSpectrum = ComplexSpectrum(yellow, frameIncrement, windowSize);

	[s1Mfcc,s1Spect,s1Fb, s1Fbrecon, s1Smooth] = ...
			mfcc2(yellow, sr, sr/frameIncrement);
	ys1 = SpectrumInversion( ...
			SpectralTilt(s1Spect,-1),frameIncrement, windowSize);

	ss1 = ComplexSpectrum(ys1, frameIncrement, windowSize);


	plot([2.4*abs(SpectralTilt(origSpectrum(1:256,190),1))  ...
	      abs(s1Spect(1:256,190))])


	plot([2.4*abs(SpectralTilt(origSpectrum(1:256,190),1))  ...
	      abs(SpectralTilt(ss1(1:256,190),1))])

	spectrum=2.4*origSpectrum(:,1:464);
	lastSpectrum = ss1;
	theErr = sum(sum((abs(spectrum)-abs(lastSpectrum)).^2))/ ...
			sum(sum(abs(spectrum).^2))*100
end
