if (exist('kathleen') ~= 1)
	if 0
		kathleen=ReadSound('KathleenRaw2.aiff');
	else
		load Kathleen.mat
	end
end

if (exist('yellow') ~= 1)
	yellow = kathleen(20000:50000);
	blue = kathleen(75000:105000);
	pope = kathleen(130000:160000);
	morning = kathleen(195000:230000);
	corner = kathleen(245000:275000);
	morning2 = kathleen(310000:345000);
end

sr = 22050;

if 1
	yellowblue = AudioMorph(yellow,blue,sr,[0:.1:1]);
end

global s1Spect s2Spect;
global s1pitch s2pitch;

global final
yellowasblue = AudioMorph(yellow, blue, sr, 1, [0;1]);
yab = final;
if 1
	blueasyellow = AudioMorph(yellow, blue, sr, 0, [1;0]);
	bay = final;
end

if 0
	clg
	imagesc(flipud(s1Spect)); title('yellow');
	hold on;plot(256-12*s1pitch/(22050/512));hold off
end
	
if 1
	subplot(2,2,1);
	imagesc(flipud(s1Spect)); title('yellow');
	hold on;plot(256-12*s1pitch/(22050/512));hold off
	subplot(2,2,2);
	imagesc(flipud(yab)); title('yellow as blue');
	hold on; plot(256-12*s2pitch/(22050/512));hold off
	subplot(2,2,3);
	imagesc(flipud(bay)); title('blue as yellow');
	hold on; plot(256-10*s1pitch/(22050/512));hold off
	subplot(2,2,4);
	imagesc(flipud(s2Spect)); title('blue');
	hold on; plot(256-10*s2pitch/(22050/512));hold off
end

if 1
	WriteSound([yellow/max(yellow) blueasyellow/max(blueasyellow) ...
		blue/max(blue) yellowasblue/max(yellowasblue)],22050, ...
		'y-bay-b-yab.aiff');
end
