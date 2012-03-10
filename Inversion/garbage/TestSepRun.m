fp = fopen('TestSepRun.results','wa');
for frameRate = [16000/32 16000/64 16000/128]
	for width = [128 256 512]
		for earQ=[4 8]
			for gain=[1 .1 .01 .001]
				for stepfactor=[.25 .5]
					name=sprintf(...
					   'testsep-%d-%f-%d-%d-%g.aiff', ...
					   earQ, stepfactor, frameRate, ...
					   width, gain);
					tfp = fopen(name,'r');
					if tfp > 0
						fclose(tfp);
						fprintf('Skipping %s.\n',...
							name);
					else
						err = TestSep(earQ,...
							stepfactor,...
							frameRate,width,gain);
						fprintf(fp, ...
							'%s error is %g.\n', ...
							name, err);
					end
				end
			end
		end
	end
end
