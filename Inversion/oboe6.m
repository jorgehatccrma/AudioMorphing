% dir = '/usr/tmp/oboe/'
dir = 'oboe/';
frameList = 320:2:360;
% M = moviein(length(frameList));
frameIndex = 1;
for frameNum=frameList
	bright=ReadImage(sprintf([dir 'oboe%05d'], frameNum));

	motion=ReadImage(sprintf([dir 'motion-smalloboe%05d.pgm'], frameNum));
	[rows cols] = size(motion);

	delay = max(1,cumsum(ones(rows,cols)')'-1);
	relMotion = (motion-128)/10 ./ delay ;
	relMotion(:,1:20) = zeros(rows,20);

%	Colorize(bright(:,1:256),relMotion(:,1:256),100,.01);
	Colorize(bright(:,1:128),relMotion(:,1:128),500,.005);
	title(sprintf('Relative Motion of Frame %d',frameNum));
	drawnow;
%	 M(:,frameIndex) = getframe;
	frameIndex = frameIndex + 1;
end
% movie(M);
