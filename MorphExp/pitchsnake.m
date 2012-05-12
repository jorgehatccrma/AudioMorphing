function smooth = pitchsnake(signal,sr,fr,low,high);


%%%%% HACK BY jorgeh %%%%%%
smooth = linspace(low, high, floor(fr*length(signal)/sr)-8);
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%




graphPitchSnake = 1;
maxSnakePoints = 20;

if (nargin < 2)
	sr = 16000;
end

if (nargin < 3)
	fr=100;		% 10 ms incremement between frames
end

[r c] = size(signal);
if r > c
	signal = signal';
end

if nargin < 4
	[pitch energy correlate] = rabpitch(signal,sr,fr);
else
	[pitch energy correlate] = rabpitch(signal,sr,fr,low,high);
end

npts = min(size(correlate,2),maxSnakePoints);
pts = zeros(npts,2);
if nargin >= 5
	lastPitch = 130;
else
	lastPitch = 85;
end
for i=1:npts
	pts(i,1) = floor((i-1)/(npts-1)*(size(correlate,2)-1)+1);
	if pitch(pts(i,1)) > 0
		lastPitch = sr/pitch(pts(i,1));
		pts(i,2) = lastPitch;
	else
		pts(i,2) = lastPitch;
	end
end

correlate=correlate-min(min(correlate));
for i=1:8
	scale = 2*(9-i);
%	[pts e]= grad_snake_y(pts, 0*ones(1,npts), .002*ones(1,npts), ...
%						 2*scale, 1*scale, correlate, 0);
	[pts e]= snake(pts, 0*ones(1,npts), .002*ones(1,npts), 0, 0, ...
						 2*scale, 1*scale, correlate);

	if graphPitchSnake
		subplot(3,3,i);
		imagesc(correlate);
%		axis([0 size(correlate,2) 60 140]);
		axis([0 size(correlate,2) 0 200]);
		hold on
		plot(pts(:,1),pts(:,2));
		hold off
		drawnow;
	end
end

if graphPitchSnake
	subplot(3,3,9);
	plot(pitch)
	hold on;
	plot(pts(:,1),sr./pts(:,2),'b')
	hold off
	axis([0 size(correlate,2) 150 250])
	drawnow;
end

if pts(1,1) ~= 1 | pts(npts,1) ~= size(correlate,2)
	fprintf('Error: First or last points aren''t at ends.\n');
	disp(pts(1:npts-1:npts,:));
	size(correlate);
	return
end

smooth = zeros(1,size(correlate,2));
index = 1;
for i=1:size(correlate,2)
	if i == pts(index,1)
		smooth(i) = pts(index,2);
	elseif i == pts(index+1,1)
		index = index+1;
		smooth(i) = pts(index,2);
	else
		smooth(i) = (i-pts(index,1))/(pts(index+1,1)-pts(index,1)) * ...
			(pts(index+1,2) - pts(index,2)) + pts(index,2);
	end
end

smooth = sr./smooth;
