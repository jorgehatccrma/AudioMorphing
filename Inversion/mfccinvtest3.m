% Try to figure out why mfcc inversion doesn't work after RASTA.
% Use all the stages (fb,cosine transform), but turn rasta on and off.
%

if (exist('data') == 1)
else
	data=ReadSound('data.aiff');
end

%tap = data(14000:17000);
tap = data(14000:25000);
%tap = data;

frameRate=250;

useFB=1;
useDCT=1;
useRasta=0;

[output,spectrogram,fbOutput,cepOutput,fbRecon]= ...
	mfccinvtest(tap,16000,frameRate,useFB, useDCT, useRasta);

useFB=1;
useDCT=1;
useRasta=1;

[routput,rspectrogram,rfbOutput,rcepOutput,rfbRecon]= ...
	mfccinvtest(tap,16000,frameRate,useFB, useDCT, useRasta);

if 1
	figure(1);
	subplot(2,3,1);imagesc(flipud(output));title('Spectrogram Recon');
	subplot(2,3,2);imagesc(flipud(fbRecon));title('FB Recon');
	subplot(2,3,3);imagesc(cepOutput);title('Cepstral Output');

	subplot(2,3,4);imagesc(flipud(routput));title('Spectrogram Recon');
	subplot(2,3,5);imagesc(flipud(rfbRecon));title('FB Recon');
	subplot(2,3,6);imagesc(rcepOutput);title('Cepstral Output');
end
if 1
	figure(2);
	line=150;
	subplot(2,3,1);plot(output(:,line));title('Spectrogram Recon');
	subplot(2,3,2);plot(fbRecon(:,line));title('FB Recon');
	subplot(2,3,3);plot(cepOutput(:,line));title('Cepstral Output');

	subplot(2,3,4);plot(routput(:,line));title('Spectrogram Recon');
	subplot(2,3,5);plot(rfbRecon(:,line));title('FB Recon');
	subplot(2,3,6);plot(rcepOutput(:,line));title('Cepstral Output');
end
