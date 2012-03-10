% spec = Cgram2Specgram(correlogram, channel, channels, fileMax)
% Grab one row of a correlogram and convert the correlation data into
% a spectrogram.  The correlogram argument can either be the output
% of the CorrelogramArray program, or a printf string which will be
% filled in with frame numbers.
% 	chan is the desired channel number to process
%	channels is the total number of channels in the correlogram
%	fileMax tells what value 255 corresponds to in the input files.
function spec = Cgram2Specgram(correlogram, channel, channels, fileMax)
if nargin < 4
	fileMax = .0032;		% Arbitrary, and only needed from files
end

if isstr(correlogram)
	f = 1;
	while f > 0 
		fileName = sprintf(correlogram, f);
		fp = fopen(fileName, 'r');
		if fp > 0
			frame = ReadImage(fp)/255*fileMax;
%			simage(frame);title(num2str(f));drawnow;
%			fprintf('frame %d max is %g.\n', f, ...
%					max(max(frame)));
			[channels winLength] = size(frame);
			fftLen = winLength*2;
					% First two channels of the correlogram
					% are not present in the file.
			useChan = min(max(1,channel-2),channels);

			if length(frame) > 0
				d = zeros(fftLen,1);
				d(1:winLength) = frame(useChan,:)';
				d((winLength+2):fftLen)=flipud(d(2:winLength));
				d = d * d(1);
				spec(:,f) = sqrt(abs(fft(d)));
			else
				break;
			end
			f = f + 1;
		else
			break;
		end
	end
else
	[pixels frames] = size(correlogram);
	winLength = pixels/channels;
	fftLen = winLength*2;
	spec = zeros(fftLen,frames);
	for f=1:frames
		frame = reshape(correlogram(:,f),channels,winLength);
		d = zeros(fftLen,1);
		d(1:winLength) = frame(channel,:)';
		d((winLength+2):fftLen) = flipud(d(2:winLength));
%               d = frame(channel,:)';
		d = d * d(1);
		spec(:,f) = sqrt(abs(fft(d)));
	end
end
