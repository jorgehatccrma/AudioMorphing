function sgiplay(data,sr)

if ( nargin < 2 )
	sr = 22050;
end

WriteSound(data,sr,'/tmp/foo.aiff');
eval('!sfplay /tmp/foo.aiff');
