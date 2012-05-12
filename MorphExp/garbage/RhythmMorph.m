function [final1,final2]=RhythmMorph(sound1,sound2,sr,lambdaList)

if nargin < 3
	sr = 22050;
end

if nargin < 4
	lambdaList=[0:0.25:1];
end

specLength = 256;
frameTime = sr/(specLength/4);

	disp('Computing mfcc, and spectrogram of signal 1.');
	sound1mfcc = mfcc2(sound1, sr, specLength);
	sound1spect = ppspect(sound1, specLength);

	disp('Computing mfcc, and spectrogram of signal 2.');
	sound2mfcc = mfcc2(sound2, sr, specLength);
	sound2spect = ppspect(sound2, specLength);

	sound1width = min([size(sound1mfcc,2), size(sound1spect,2)]);
	sound1mfcc = sound1mfcc(:, 1:sound1width);
	sound1spect = sound1spect(:, 1:sound1width);
	
	sound2width = min([size(sound2mfcc,2), size(sound2spect,2)]);
	sound2mfcc = sound2mfcc(:, 1:sound2width);
	sound2spect = sound2spect(:, 1:sound2width);

	disp('Computing the dynamic time warping.');
	[error,path1,path2] = dtwmem(sound1mfcc, sound2mfcc,2);

	clear sound1mfcc
	clear sound2mfcc

% Now (optionally) plot the result.  
if 1
	m = max(size(sound1spect,2), size(sound2spect,2));
	d1 = specLength/2+1;
	
	subplot(3,1,1);
		imagesc(sound1spect);
		axis([1 m 1 d1]);
	title('Signal 1');

	s15 = zeros(size(sound1spect));
	for i=1:size(sound1spect,2)
		s15(:,i) = sound2spect(:,path1(i));
	end
	subplot(3,1,2);
		imagesc(s15);
		axis([1 m 1 d1]);
	title('Signal 2 warped to be like Signal 1');
	clear s15
	
	subplot(3,1,3);
		imagesc(sound2spect);
		axis([1 m 1 d1]);
	title('Signal 2');
	drawnow;
end

whos;

% OK, now we have the two spectrograms: sound1spect and sound2spect
% We have warping paths: path1 and path2
specLength = size(sound2spect,1);
f=(1:specLength)'-1;
f1 = flipud(sound1spect);
f2 = flipud(sound2spect);
final1=[];
final2=[];
for lambda=lambdaList
	[index1,index2]=TimeWarpPaths(path1,path2,lambda);
	specLength = length(index1);
	image1 = zeros(size(sound2spect,1),specLength);
	image2 = zeros(size(sound2spect,1),specLength);
	
	for i=1:specLength
		image1(:,i) = f1(:,index1(i));
		image2(:,i) = f2(:,index2(i));
	end
	image1=flipud(image1);
	image2=flipud(image2);
	if nargout < 1
		filename = sprintf('image%g.raw',lambda);
	end
	final1=[final1 image1];
	final2=[final2 image2];
end		

