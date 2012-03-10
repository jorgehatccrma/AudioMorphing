	fprintf('computing morph for lambda of %g.\n', lambda);

	va = 1-lambda;
	vb = lambda;

%	va = 1;
%	vb = 0;
%	fprintf('Fixing va to %g and vb to %g.\n', va, vb);
	
	[index1,index2]=TimeWarpPaths(path1,path2,lambda);
	specWidth = length(index1);
	image = zeros(size(s2Smooth,1),specWidth);
	alpha = s2pitch(index2)./s1pitch(index1);
	
	for i=1:specWidth
				% First scale the pitch spectrograms
				% by their difference in pitch
				% See page 101 of Malcolm's first log
				% book for derivation of the following.
		i0=round(f/(1 + lambda*(alpha(i) - 1))) + 1;
		i0=max(1,min(specLength,i0));
		i1=round(alpha(i)*f/(1 + lambda*(alpha(i) - 1))) + 1;
		i1=max(1,min(specLength,i1));
		newPitchSpec = vb*s2PitchSpect(i1,index2(i)) + ...
				va*s1PitchSpect(i0,index1(i));
		
		if 1
			s1Warp(:,i) = s1PitchSpect(i0,index1(i));
			s2Warp(:,i) = s2PitchSpect(i1,index2(i));
			lambdaWarp(:,i) = newPitchSpec;
		end
				% Now interpolate the smooth 
				% spectrum.
		newSmoothSpec = Interpolate(s1Smooth(:,index1(i)), ...
			s2Smooth(:,index2(i)), vb, va);
			
		if 1
			lambdaSmooth(:,i) = newSmoothSpec;
		end
		
		image(:,i) = newPitchSpec .* newSmoothSpec;
	end
	image(1,:) = image(1,:) * 0;		% Remove DC...Malcolm 5/3/96
	image(2,:) = image(2,:) * 0;
	image(3,:) = image(2,:) * 0.5;		% Smooth transition better

	ypart = SpectrumInversion(SpectralTilt(image,-1),frameIncrement, ...
		windowSize);
	y = [y ypart];
	fileName = sprintf('%s/sound%04d.aiff', name, round(lambda*1000));
	WriteSound(ypart,sr,fileName);

	if 0
		fileName = sprintf('%s/image(%dx%d)%04d', name, finalX, ...
					finalY, imgNum);
		imgNum = imgNum+1;
		partImage = zeros(finalY, finalX);
		partImage(1:size(image,1), 1:size(image,2)) = image;
		fp = fopen(fileName, 'wb');
		if (fp >= 0)
			fwrite(fp, partImage'/max(max(image))*255, 'char');
			fclose(fp);
		end
		for i=2:length(ypart)/sr*4
			newFile = sprintf('%s/image(%dx%d)%04d', name, ...
						finalX, finalY, imgNum);
			imgNum = imgNum + 1;
			lnCmd = sprintf('!ln "%s" "%s"', fileName, newFile);
			eval(lnCmd);
		end

		final=[final image];
	end
