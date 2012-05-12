if 0
	if (size(lambdaList,1) > size(lambdaList,2)) 
		lambdaList = lambdaList'; 
	end

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
	end
	volumeList = [lambdaList;1-lambdaList];
end


windowSize=256;
frameIncrement=32;

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
	disp('Calculating dynamic time warping between MFCCs');
	[error,path1,path2] = dtw(s1Mfcc, s2Mfcc);
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
