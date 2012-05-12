sr = 22050;
l = 5;
specLength = 1024;
frameRate = sr/(specLength/4);

if exist('orchestra') ~= 1 & exist('o') ~= 1
	orchestra = ReadSound('../PetrushkaOrchestra.aiff');
	beg = 5*sr; last = beg+l*sr;
	o = orchestra(beg:last);
	clear orchestra
end

if exist('pianola') ~= 1 & exist('p') ~= 1
	pianola = ReadSound('../PetrushkaPianola.aiff');
	beg = 1.5*sr; last = beg+l*sr;
	p = pianola(beg:last);
	clear pianola
end

if 0 & exist('opitch') ~= 1
	opitch=pitchsnake(o,sr,frameRate);
	owidth = length(opitch);
	ppitch=pitchsnake(p,sr,frameRate);
	pwidth = length(ppitch);
	disp('Finished pitch calculations');
end

if exist('omfcc') ~= 1
	omfcc = mfcc2(o, sr, frameRate);
%	omfcc = omfcc(:,1:owidth);
	pmfcc = mfcc2(p, sr, frameRate);
%	pmfcc = pmfcc(:,1:pwidth);
	disp('Finished mfcc calculations');
end

if exist('ospect') ~= 1
	ospect = ppspect(o,specLength);
%	ospect = ospect(:,1:owidth);
	pspect = ppspect(p,specLength);
%	pspect = pspect(:,1:pwidth);
	disp('Finished spectrogram calculations');
end

if exist('path1') ~= 1
	[error,path1,path2] = dtwmem(omfcc, pmfcc,8);
end


% Now (optionally) plot the result.  
if 1
	m = max(size(ospect,2), size(pspect,2));
	d1 = specLength+1;
	
	subplot(3,1,1);
		imagesc(ospect);
		axis([1 m 1 d1]);
	title('Signal 1');

	s15 = zeros(d1,m);
	lp1=length(path1);
	for i=1:size(ospect,2)
		s15(:,i) = pspect(:,path1(i));
	end
	subplot(3,1,2);
		imagesc(s15);
		axis([1 m 1 d1]);
	title('Signal 2 warped to be like Signal 1');
	
	subplot(3,1,3);
		imagesc(pspect);
		axis([1 m 1 d1]);
	title('Signal 2');
end

fp=fopen('petospect.raw','wb');
fwrite(fp,ospect'*255/max(max(ospect)),'uchar');
fclose(fp);

fp=fopen('petpspect.raw','wb');
fwrite(fp,pspect'*255/max(max(pspect)),'uchar');
fclose(fp);

fp=fopen('petrspect.raw','wb');
fwrite(fp,s15'*255/max(max(s15)),'uchar');
fclose(fp);
