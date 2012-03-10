% output = FindHarmonics(cor,width,harmonics)
%
% Analyze a correlogram and simulate sound separation by selecting
% harmonics from the correlogram.  The harmonic selection algorithm is 
% based on look for peaks and valleys and is not very robust.
%
% If there are no output arguments then just show the pictures.  The
% first column is the original correlogram, the second column is the 
% cochlear summary (across time delays), the third column shows the
% peaks in the cochleagram, the fourth column shows the spectral labels
% and the fifth column shows the separated correlogram.
%
% Option... results *might* be better if verything is done based on the
% zero delay value.

function output = FindHarmonics(cor,width,harmonics)

[pixels,frames] = size(cor);
channels = pixels/width;

if nargout > 0
	output = zeros(pixels,frames);
end

for frame=1:frames
	corFrame = reshape(cor(:,frame),channels,width);
	scale = length(colormap)/max(max(corFrame));
	if nargout == 0
		subplot(1,5,1);
		image(corFrame*scale);
	end

	cochlea = sum(corFrame');		% Find the spectrum
%	cochlea = corFrame(:,1);

	if nargout == 0
		subplot(1,5,2);
		plot(cochlea,channels+1-(1:channels));
	end

	[m c] = max(cochlea);			% Separate the peaks
	peaks = (cochlea>m/2) .* cochlea;
	if nargout == 0
		subplot(1,5,3);
		plot(peaks,channels+1-(1:channels));
	end
	
	peakIndex = 0;				% Now label each peak
	peakState = 0;
	lastVal = 0;
	for c=channels+1-(1:channels)
		if peakState > 0
			if peaks(c) == 0
				peakState = 0;
			end
		else					% Not in Peak
			if peaks(c) > 0
				peakState = 1;
				peakIndex = peakIndex + 1;
			end
		end
		peakPointers(c) = peakState*peakIndex;
	end

	bottom = channels;
	top = max(find(peakPointers == 1));
	peakPointers(top:bottom) = (top:bottom)>0;

						% Now fill in the gaps between
						% peaks.  Use the minimum as
						% the breakpoint.
	for i=1:(max(peakPointers)-1)
		bottom = min(find(peakPointers == i));
		top = max(find(peakPointers == (i+1)));
		[m p] = min(cochlea(top:bottom));
		if p > 0
			range = (top+1):(top+p-2);
			peakPointers(range) = peakPointers(top)*(range>0);
			range = (top+p-1):(bottom-1);
			peakPointers(range) = peakPointers(bottom)*(range>0);
%			fprintf('%d from %d to %d: min at %d\n',i,top,bottom,p);
		end
	end
	bottom = min(find(peakPointers == max(peakPointers)));
	top = 1;
	peakPointers(top:bottom) = peakPointers(bottom)*((top:bottom) > 0);

	if nargout == 0
		subplot(1,5,4);
		plot(peakPointers,channels+1-(1:channels));
	end

	mask = zeros(1,channels);
	for i=harmonics
		mask = mask | (i==peakPointers);
	end
	mask = find(mask);

	outFrame = zeros(channels,width);
	outFrame(mask,:) = corFrame(mask,:);
	if nargout == 0
		subplot(1,5,5);
		image(outFrame*scale);
		drawnow;
	else
		output(:,frame) = reshape(outFrame,channels*width,1);
	end
end
