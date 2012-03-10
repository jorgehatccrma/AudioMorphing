% MosaicCorrelogram(cor,width)
% Display a mosaic of correlograms in the Matlab graphics window.  The width is
% necessary in order to decode the correlogram.

function MosaicCorrelogram(cor,width)

maxPics = 5;

[pixels,frames] = size(cor);
channels = pixels/width;
corMax = max(max(cor));
scale = length(colormap)/corMax;

rows = min(maxPics,floor(sqrt(frames)));
cols = min(maxPics,ceil(frames/rows));

for j=1:min(frames,maxPics*maxPics)
	subplot(rows,cols,j);
	corFrame = reshape(cor(:,j),channels,width);
	image(corFrame*scale);
end
