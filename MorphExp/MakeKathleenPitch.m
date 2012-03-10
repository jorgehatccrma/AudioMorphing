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
frameIncrement=64;
low=100;
high=330;

	clg;
	disp('Calculating pitch of yellow....');

	[pitch, energy, strength, correlation] = rabpitch(yellow,sr, ...
			sr/frameIncrement,low,high);
	
	subplot(2,1,1);
	imagesc(correlation);
	hold on
	plot(ones(1,size(correlation,2))*22050/low);
	plot(ones(1,size(correlation,2))*22050/high);
	plot([1*22050./pitch' 2*22050./pitch' 3*22050./pitch']);
	axis([0 size(correlation,2) 0 300])
	hold off
	drawnow


if 1
	s1pitch=pitchsnake(yellow,sr,sr/frameIncrement,low,high);
end
	s1width = length(pitch);

	disp('Calculating mfcc of yellow....');
	[s1Mfcc,s1Spect,s1Fb, s1Fbrecon, s1Smooth] = ...
		mfcc2(yellow, sr, sr/frameIncrement);
	s1Mfcc = s1Mfcc(:,1:s1width);
	s1Smooth = s1Smooth(:,1:s1width);
	s1Spect = abs(s1Spect(:,1:s1width));



	subplot(2,1,2);
	imagesc(flipud(s1Spect)); title('yellow');
	harm = 12;
	hold on;plot([ ...
		      256-1*pitch'/(22050/512) ...
		      256-2*pitch'/(22050/512) ...
		      256-harm*pitch'/(22050/512) ...
		      256-harm*s1pitch'/(22050/512) ...
		      ]);
	hold off
	axis([0 length(pitch) 170 256])
