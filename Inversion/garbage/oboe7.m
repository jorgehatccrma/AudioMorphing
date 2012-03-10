% Add a bit of noise to each image.
dir = 'test/';
frameList = 1:30;

bright=ReadImage(sprintf([dir 'test%05d'], frameList(1)));
randn('seed',0);
noise = randn(size(bright)) > 0;

% M = moviein(length(frameList));
for frameNum=frameList
	bright=ReadImage(sprintf([dir 'test%05d'], frameNum));
	[rows cols] = size(bright);
	WriteImage(sprintf([dir 'testn%05d'], frameNum), bright + noise);
end
