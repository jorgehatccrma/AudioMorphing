function makeball(n,frames)
y = cumsum(ones(n,n));
x = y';
for i=1:frames
	x0 = n/2 + sin(i/frames*2*pi)*n/3;
	y0 = n/2 + cos(i/frames*2*pi)*n/3;
	frame = exp(-((x-x0).^2 + (y-y0).^2)/n);
	simage(frame);
	WriteImage(sprintf('ball/ball%05d', i), frame/max(max(frame))*255);
	drawnow;
end
