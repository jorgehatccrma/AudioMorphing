function [y,final] = BigAudioMorph(name,s1,s2,sr,lambdaList,volumeList)
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

if nargin < 4
	sr = 22050;
end

if nargin < 5
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
elseif nargin < 6			% Debugging Feature 
	volumeList = [lambdaList;1-lambdaList];
end


windowSize=256;
frameIncrement=32;

% Calculate both pitch signals
if exist('s1pitch') ~= 1
	disp('Calculating pitch of s1....');
	[s1pitch,s1rabpitch,s1energy,s1correlate]=pitchsnake(s1,sr, ...
						sr/frameIncrement,100,330);
	clear s1energy
	s1correlate = s1correlate(1:300,:);
	s1width = length(s1pitch);
	disp('Calculating pitch of s2....');
	[s2pitch,s2rabpitch,s2energy,s2correlate]=pitchsnake(s2,sr, ...
						sr/frameIncrement,100,330);
	clear s2energy
	s2correlate = s2correlate(1:300,:);
	s2width = length(s2pitch);
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
end

if exist('path1') ~= 1
	disp('Calculating dynamic time warping between MFCCs');
	[error,path1,path2] = dtw(s1Mfcc, s2Mfcc);
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

finalX = max(size(s1Smooth,2), size(s2Smooth,2));
finalY = size(s1Smooth,1);
mkdirCmd = sprintf('!mkdir %s; rm %s/image*', name, name);
eval(mkdirCmd);
imgNum = 0;

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
		newSmoothSpec = Interpolate(s1Smooth(:,index1(i)), ...
			s2Smooth(:,index2(i)), volumeList(1,l), ...
			volumeList(2,l));
			
		if 1
			lambdaSmooth(:,i) = newSmoothSpec;
		end
		
		image(:,i) = newPitchSpec .* newSmoothSpec;
	end
	ypart = SpectrumInversion(SpectralTilt(image,-1),frameIncrement, ...
		windowSize);
	y = [y ypart];
	fileName = sprintf('%s/sound%04d.aiff', name, round(lambda*1000));
	WriteSound(ypart,sr,fileName);

	fileName = sprintf('%s/image(%dx%d)%04d', name, finalX, finalY, ...
				imgNum);
	imgNum = imgNum+1;
	partImage = zeros(finalY, finalX);
	partImage(1:size(image,1), 1:size(image,2)) = image;
	fp = fopen(fileName, 'wb');
	if (fp >= 0)
		fwrite(fp, partImage'/max(max(image))*255, 'char');
		fclose(fp);
	end
	for i=2:length(ypart)/sr*4
		newFile = sprintf('%s/image(%dx%d)%04d', name, ...
					finalX, finalY, imgNum);
		imgNum = imgNum + 1;
		lnCmd = sprintf('!ln "%s" "%s"', fileName, newFile);
		eval(lnCmd);
	end

	final=[final image];
end		

% saveCmd = sprintf('save %s/results', name);
% eval(saveCmd);

soundName = sprintf('%s/sound.aiff',name);
WriteSound(y,sr,soundName);


if 1
	clg

	m = max(size(s1Smooth,2), size(s2Smooth,2));
	d1 = 257;

	subplot(3,2,2);
	imagesc(flipud(s1Smooth));
	axis([1 m 1 d1]);
	title('Signal 1 Smooth Spectrogram');

	subplot(3,2,4);
	s15 = zeros(size(s1Smooth));
	for i=1:size(s1Smooth,2)
		s15(:,i) = s2Smooth(:,path1(i));
	end
	imagesc(flipud(s15));
	axis([1 m 1 d1]);
	title('Signal 2 warped to be like Signal 1');

	subplot(3,2,6);
	imagesc(flipud(s2Smooth));
	axis([1 m 1 d1]);
	title('Signal 2 Smooth Spectrogram');


	subplot(3,2,1);
	imagesc(s1correlate);
	axis([1 m 1 300])
	hold on
	plot([sr./s1pitch' sr./s1rabpitch']);
	title('Signal 1 Correlation and Pitch');
	hold off

	subplot(3,2,3);
	s15 = zeros(size(s1correlate));
	for i=1:size(s1Smooth,2)
		s15(:,i) = s2correlate(:,path1(i));
	end
	imagesc(s15(1:300,:));
	axis([1 m 1 300]);
	title('Signal 2 warped to be like Signal 1');

	subplot(3,2,5);
	imagesc(s2correlate);
	axis([1 m 1 300])
	hold on
	plot([sr./s2pitch' sr./s2rabpitch']);
	title('Signal 2 Correlation and Pitch');
	hold off

	prntCmd = sprintf('print %s/fig.ps -dpsc', name);
	eval(prntCmd);
	prntCmd = sprintf('!lpr -Pfiery -s %s/fig.ps; compress %s/fig.ps', ...
			name, name);
end
