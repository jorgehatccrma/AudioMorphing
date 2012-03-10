function [y,final] = AudioMorph(s1,s2,sr,lambdaList,volumeList)
global s1pitch s1width s1mfcc 
global s2pitch s2width s2mfcc
global s1Mfcc s1Smooth s1PitchSpect
global s2Mfcc s2Smooth s2PitchSpect
global s1Spect s2Spect
global path1 path2
global frameIncrement windowSize
global index1 index2
global final

clear s1pitch
clear s1PitchSpect
clear s2PitchSpect

if nargin < 3
	sr = 22050;
end

if nargin < 4
	lambdaList=[0:.33333:1];
end
if (size(lambdaList,1) > size(lambdaList,2)) lambdaList = lambdaList'; end

if isstr(lambdaList)
	if strcmp(lambdaList,'1as2')
		lambdaList = 1;
		volumeList = [0;1];
	elseif strcmp(lambdaList,'2as1')
		lambdaList = 0;
		volumeList = [1;0];
	elseif strcmp(lambdaList,'1')
		lambdaList = 0;
		volumeList = [0;1];
	elseif strcmp(lambdaList,'2')
		lambdaList = 1;
		volumeList = [1;0];
	end
elseif nargin < 5			% Debugging Feature 
	volumeList = [lambdaList;1-lambdaList];
end


windowSize=256;
frameIncrement=32;

% Calculate both pitch signals
if exist('s1pitch') ~= 1
	disp('Calculating pitch of s1....');
	s1pitch=pitchsnake(s1,sr,sr/frameIncrement,100,330);
	s1width = length(s1pitch);
	disp('Calculating pitch of s2....');
	s2pitch=pitchsnake(s2,sr,sr/frameIncrement,100,330);
	s2width = length(s2pitch);
else
	disp('Pitch 1 & 2 already exists and not recalculated.');
end

if exist('s1PitchSpect') ~= 1
	disp('Calculating mfcc of s1....');
	[s1Mfcc,s1Spect,s1Fb, s1Fbrecon, s1Smooth] = ...
			mfcc2(s1, sr, sr/frameIncrement);
	s1Mfcc = s1Mfcc(:,1:s1width);
	s1Smooth = s1Smooth(:,1:s1width);
	s1Spect = abs(s1Spect(:,1:s1width));
	s1PitchSpect = s1Spect ./ s1Smooth;
	clear s1Fb
	clear s1Fbrecon
%	clear s1Spect
else
	disp('MFCC 1 already exists and not recalculated.');
end
	
if 0
	imagesc(s1PitchSpect(1:50,:));hold on
	plot(((s1pitch'/(sr/(size(s1Spect,1)*2))) * (1:8)) + 1);
	title('s1PitchSpect vs s1pitch'); hold off; drawnow;
end

if exist('s2PitchSpect') ~= 1
	disp('Calculating mfcc of s2....');
	[s2Mfcc,s2Spect,s2Fb, s2Fbrecon, s2Smooth] = ...
			mfcc2(s2, sr, sr/frameIncrement);
	s2Mfcc = s2Mfcc(:,1:s2width);
	s2Smooth = s2Smooth(:,1:s2width);
	s2Spect = abs(s2Spect(:,1:s2width));
	s2PitchSpect = s2Spect ./ s2Smooth;
	clear s2Fb
	clear s2Fbrecon
%	clear s2Spect
else
	disp('MFCC 2 already exists and not recalculated.');
end

if 0
	imagesc(s2PitchSpect(1:50,:));hold on
	plot(((s2pitch'/(sr/(size(s2Spect,1)*2))) * (1:8)) + 1);
	title('s2PitchSpect vs s2pitch'); hold off; drawnow
	drawnow;
end

if exist('path1') ~= 1 | length(path1) < 1
	disp('Calculating dynamic time warping between MFCCs');
	[error,path1,path2] = dtw(s1Mfcc, s2Mfcc);
else
	disp('DTW Path (path1) already exists.  Not recalculating.');
end


% Now (optionally) plot the result.  
if 1
	m = max(size(s1Smooth,2), size(s2Smooth,2));
	d1 = 257;
	
	subplot(3,1,1);
	imagesc(flipud(s1Smooth));
	axis([1 m 1 d1]);
	title('Signal 1');

	s15 = zeros(size(s1Smooth));
	for i=1:size(s1Smooth,2)
		s15(:,i) = s2Smooth(:,path1(i));
	end
	subplot(3,1,2);
	imagesc(flipud(s15));
	axis([1 m 1 d1]);
	title('Signal 2 warped to be like Signal 1');
	
	subplot(3,1,3);
		imagesc(flipud(s2Smooth));
		axis([1 m 1 d1]);
	title('Signal 2');
	drawnow;
end

% OK, now we have the two pitch spectrograms: s1PitchSpect and s2PitchSpect
% We have two smooth spectrograms: s1Smooth, s2Smooth
% We have warping paths: path1 and path2
% We have pitch values: s1pitch and s2pitch
disp('Do the final morph...');
specLength = size(s2Smooth,1);
f=(1:specLength)'-1;
final=[];
for l=1:length(lambdaList);
	lambda = lambdaList(l);
	[index1,index2]=TimeWarpPaths(path1,path2,lambda);
	specWidth = length(index1);
	image = zeros(size(s2Smooth,1),specWidth);
	alpha = s2pitch(index2)./s1pitch(index1);
	
	for i=1:specWidth
				% First scale the pitch spectrograms
				% by their difference in pitch
				% See page 101 of Malcolm's first log
				% book for derivation of the following.
		i0=round(f/(1 + lambda*(alpha(i) - 1))) + 1;
		i0=max(1,min(specLength,i0));
		i1=round(alpha(i)*f/(1 + lambda*(alpha(i) - 1))) + 1;
		i1=max(1,min(specLength,i1));
		newPitchSpec = volumeList(1,l)*s2PitchSpect(i1,index2(i)) + ...
				volumeList(2,l)*s1PitchSpect(i0,index1(i));
		
		if 1
			s1Warp(:,i) = s1PitchSpect(i0,index1(i));
			s2Warp(:,i) = s2PitchSpect(i1,index2(i));
			lambdaWarp(:,i) = newPitchSpec;
		end
				% Now interpolate the smooth 
				% spectrum.
		if 0
			newSmoothSpec = TukeyMorph(s1Smooth(:,index1(i)), ...
				s2Smooth(:,index2(i)), lambda);
		elseif 0	% Tukey morph on untilted spectrums
			mt = SpectralTilt(s1Smooth(:,index1(i)),-1);
			ct = SpectralTilt(s2Smooth(:,index2(i)),-1);
			newSmoothSpec = TukeyMorph(mt, ct, lambda);
			newSmoothSpec = SpectralTilt(newSmoothSpec,1);
		else
			newSmoothSpec = Interpolate(s1Smooth(:,index1(i)), ...
				s2Smooth(:,index2(i)), volumeList(1,l), ...
				volumeList(2,l));
		end
			
		if 1
			lambdaSmooth(:,i) = newSmoothSpec;
		end
		
		image(:,i) = newPitchSpec .* newSmoothSpec;
	end
	final=[final image];
end		

if 0
				% Plot original and morphed spectrograms
	subplot(3,1,1);imagesc(s1Spect);title('s1Spect');
	subplot(3,1,2);imagesc(image);title('50% Morph');
	subplot(3,1,3);imagesc(s2Spect);title('s2Spect');

				% Plot pitch and morphed spectrograms
	subplot(3,1,1);imagesc(SpectralTilt(s1PitchSpect,-1));
		title('s1PitchSpectrum');
	subplot(3,1,2);imagesc(image);title('50% Morph');
	subplot(3,1,3);imagesc(SpectralTilt(s2PitchSpect,-1));
		title('s2PitchSpectrum');
	
				% Plot spectral slices
	frame=128;
	subplot(3,1,2);plot(image(:,frame));
	subplot(3,1,1);plot(s1PitchSpect(:,index1(frame)));
	subplot(3,1,3);plot(s2PitchSpect(:,index2(frame)));
	
				% Plot spectral slices (overlayed)
	clg;plot([s1PitchSpect(:,index1(frame)) image(:,frame) ...
				s2PitchSpect(:,index2(frame))])
	axis([0 50 0 4])

				% Plot pitch warps
	subplot(3,1,1);imagesc(s1Warp);title('s1 Pitch Warp');
	subplot(3,1,2);imagesc(lambdaWarp);title('50% Morph');
	subplot(3,1,3);imagesc(s2Warp);title('s2 Pitch Warp');

				% Plot pitch warps (overlayed)
	frame = 80;
	clg;plot([s1Warp(:,frame) lambdaWarp(:,frame) ...
				s2Warp(:,frame)])
	axis([0 50 0 4])
	drawnow;
end

if 1
				% Convert the spectrogram back to sound
%	ys1 = SpectrumInversion( ...
%		SpectralTilt(s1PitchSpect.*s1Smooth,-1),frameIncrement, ...
%			windowSize);
	y = SpectrumInversion(SpectralTilt(final,-1),frameIncrement, ...
		windowSize);
%	ys2 = SpectrumInversion( ...
%		SpectralTilt(s2PitchSpect.*s2Smooth,-1),frameIncrement, ...
%			windowSize);
end

if 0
	s1True = abs(ComplexSpectrum(s1,frameIncrement,windowSize));
	s2True = abs(ComplexSpectrum(s2,frameIncrement,windowSize));
	
	ys1true = SpectrumInversion(s1True,frameIncrement,windowSize);
	sound(ys1true,22050);
	ys2true = SpectrumInversion(s2True,frameIncrement,windowSize);
	sound(ys2true,22050);
	
	subplot(2,1,1);plot(s1);title('s1');
	subplot(2,1,2);plot(-ys1true);title('s1 reconstruction');
	while 1
		start = input('Starting sample? ');
		subplot(2,1,1); axis([start start+1000 -.2 .2]);
		subplot(2,1,2); axis([start start+1000 -.2 .2]);
	end		
				% Hmmm, problems with inversion
				% of s1 around sample 2400.
	ys1true1 = SpectrumInversion(s1True,frameIncrement,windowSize,1);
end

if 0
				% Check to make sure that I can
				% successfully invert the MFCC
				% spectrograms.
	[s1Mfcc,s1Spect,s1Fb, s1Fbrecon, s1Smooth] = ...
			mfcc2(s1, sr, sr/frameIncrement);
	s1Mfcc = s1Mfcc(:,1:s1width);
	s1Smooth = s1Smooth(:,1:s1width);
	s1Spect = abs(s1Spect(:,1:s1width));
	s1PitchSpect = s1Spect ./ s1Smooth;
	clear s1Fb
	clear s1Fbrecon
	
	ys1 = SpectrumInversion(SpectralTilt( ...
			s1PitchSpect.*s1Smooth,-1),frameIncrement,windowSize);
end

if 0
	subplot(3,2,1);
	imagesc(s1Smooth);title('s1Smooth');
	
	subplot(3,2,2);
	imagesc(s1PitchSpect);title('s1PitchSpect');
	
	subplot(3,2,3);
	imagesc(lambdaSmooth(:,1:size(image,2))); title('lambdaSmooth');
	
	subplot(3,2,4);
	imagesc(lambdaWarp(:,1:size(image,2))); title('lambdaWarp');
	
	subplot(3,2,5);
	imagesc(s2Smooth);title('s2Smooth');
	
	subplot(3,2,6);
	imagesc(s2PitchSpect);title('s2PitchSpect');
end
