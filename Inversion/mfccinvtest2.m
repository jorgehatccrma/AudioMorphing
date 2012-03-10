if (exist('data') == 1)
else
	data=ReadSound('data.aiff');
end

%tap = data(14000:17000);
%tap = data(14000:25000);
tap = data;

frameRate=250;

for useFB=1:1
	for useDCT=1:1
		for useRasta=0:1
			[output,spectrogram,fbOutput,cepOutput,fbRecon]= ...
				mfccinvtest(tap,16000,frameRate,useFB, ...
				useDCT, useRasta,0);
			subplot(3,1,1);
			imagesc(spectrogram);
			title(sprintf('useFB=%d, useDCT=%d, useRasta=%d', ...
				useFB, useDCT, useRasta, 0));
			
			subplot(3,1,2);
			imagesc(output);
			
			subplot(3,1,3);
			plot([spectrogram(:,30) output(:,30)])
			
			drawnow;
	%		print -dps2
		
			s=output;
				
			if (useDCT > 0)
				signal=SpectrumInversion(s,16000/frameRate,...
					size(output,1),10, ...
					2*pi*rand(size(s))-pi);
			else
				signal=SpectrumInversion(s,16000/frameRate,...
					size(output,1));	
			end
			eval(sprintf('s%d%d%d=signal;',useFB,useDCT,useRasta));
			eval(sprintf(...
				'WriteSound(signal,16000,''s%d%d%d.aiff'')',...
				useFB, useDCT, useRasta));
		end
	end
end
