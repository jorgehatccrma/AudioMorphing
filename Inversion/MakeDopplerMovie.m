function MakeDopplerMovie(brightPath,motionPath,outputName,frameList)

if length(outputName) > 0
	outputDir = '/usr/tmp/makedoppler/';
	outputPrefix = 'rgb';
	outputPath = [outputDir outputPrefix '%05d'];
	unix(['rm -rf ' outputDir]);
	unix(['mkdir ' outputDir]);
end

maxBright = 256;
maxMotion = 5;
frameIndex = 1;
maxMotionSeen = 0;
for frameNum=frameList
	bright=ReadImage(sprintf(brightPath, frameNum));

	motion=ReadImage(sprintf(motionPath, frameNum));
	[rows cols] = size(motion);
	relMotion = (motion-128)/10;

	delay = max(1,cumsum(ones(rows,cols)')'-1);
	relMotion = relMotion ./ delay ;
	relMotion(:,1:20) = zeros(rows,20);
	hist(reshape(relMotion,1,rows*cols),[-.3:.05:.3])
	drawnow;
	maxMotionImage = maxMotion / cols;
	maxMotionSeen = max(maxMotionSeen,max(max(abs(relMotion))))

%	Colorize(bright(:,1:256),relMotion(:,1:256),maxBright,maxMotionImage);
	if length(outputPath > 0)
		rgb = Colorize(bright,-relMotion,maxBright,maxMotionImage);
		fp = fopen(sprintf(outputPath, frameNum), 'wb');
		fwrite(fp,rgb*255,'uchar');
		fclose(fp);
	else
		Colorize(bright,-relMotion,maxBright,MaxMotionImage);
		title(sprintf('Relative Motion of Frame %d',frameNum));
		drawnow;
	end
%	 M(:,frameIndex) = getframe;
	frameIndex = frameIndex + 1;
end
% movie(M);

if maxMotionSeen > 0
	fprintf('The maximum motion seen is %g or %g.\n', ...
		maxMotionSeen, maxMotionSeen*cols);
end

if length(outputName) > 0
	unix(['find ' outputDir outputPrefix '* -print | makemoov.sun -x ' ...
		num2str(cols) ' -y ' num2str(rows) ' -rpza -output '  ...
		outputName]);
end
