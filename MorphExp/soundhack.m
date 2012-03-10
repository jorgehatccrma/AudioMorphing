function soundhack(data,sr)
if nargin < 2
	sr = 22050;
end
WriteSound(data, sr, 'foo.aiff');
unix('sfplay foo.aiff');
unix('rm foo.aiff');
