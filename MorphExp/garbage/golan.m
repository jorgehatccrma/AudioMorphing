if exist('domino') ~= 1
	domino = ReadSound('MorphExp/GolanSounds/Domino22.aiff');
	emf = ReadSound('MorphExp/GolanSounds/EMFbeat22.aiff');
%	kc = ReadSound(':GolanSounds:KCsunshine.aiff');
%	maceo = ReadSound(':GolanSounds:maceo.aiff');
%	meters2 = ReadSound(':GolanSounds:meters2.aiff');
%	toto = ReadSound(':GolanSounds:totodrum.aiff');
end

if 0
	dominos=spectrogram(domino,256,2,2);
	emfs=spectrogram(emf,256,2,2);
	kcs=spectrogram(kc,256,2,2);
	maceos=spectrogram(maceo,256,2,2);
	meters2s=spectrogram(meters2,256,2,2);
	totos=spectrogram(toto,256,2,2);
end

if 0
	subplot(3,2,1);imagesc(dominos);title('domino');
	subplot(3,2,2);imagesc(emfs);title('emf');
	subplot(3,2,3);imagesc(kcs);title('kc');
	subplot(3,2,4);imagesc(maceos);title('maceo');
	subplot(3,2,5);imagesc(meters2s);title('meters2');
	subplot(3,2,6);imagesc(totos);title('toto');
end

[im1 im2] = RhythmMorph(domino,emf,22050,[0 0.5 1.0]);

fp=fopen('im1.raw','wb');
fwrite(fp,im1'/max(max(im1))*255,'uchar');
fclose(fp);

fp=fopen('im2.raw','wb');
fwrite(fp,im2'/max(max(im2))*255,'uchar');
fclose(fp);
