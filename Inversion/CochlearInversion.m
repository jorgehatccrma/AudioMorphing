function y=CochlearInversion(cochleagram, earFilters, gains, agcParms, sr, ...
				cochlearIterations)

if nargin < 6
	cochlearIterations=10;
end

invertAGC=1;
if invertAGC
%	fprintf('Inverting the AGC.\n');
	inverseagc('reset');
	agcInversion = inverseagc(cochleagram, agcParms);
else
	agcInversion = cochleagram;
end

invsoscascade('reset');
y=fliplr(invsoscascade(fliplr(2*agcInversion), earFilters, gains));
yfirst = y;
plot([y;yfirst]')
drawnow;

for i=2:cochlearIterations
	% Now let's compute the FB output of the first reconstruction
	soscascade('reset');
	sos2Output = soscascade(y, earFilters);

	% OK, now let's combine the original (given) HWR output with 
	% the new Filter bank output based on the first reconstructed 
	% signal.  Take the positive values from the original signal 
	% with the negative values from the new reconstruction.
	fixedOutput = sign(agcInversion).*agcInversion + ...
		(1-sign(agcInversion)).*min(0,sos2Output);
	clear sos2Output;

	invsoscascade('reset');
	y=fliplr(invsoscascade(fliplr(fixedOutput), earFilters, gains));
	clear fixedOutput;
end
