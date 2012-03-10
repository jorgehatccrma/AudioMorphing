% DisplayCorrelogram(cor,width)
% Display a correlogram in the Matlab graphics window.  The width is
% necessary in order to decode the correlogram.

function DisplayCorrelogram(cor,width)

[pixels,frames] = size(cor);
channels = pixels/width;
corMax = max(max(cor));
scale = length(colormap)/corMax;

for j=1:frames
	corFrame = reshape(cor(:,j),channels,width);
	image(corFrame*scale);
	drawnow;
end
