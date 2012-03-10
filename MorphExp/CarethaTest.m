% Caretha Edited (CarethaEdit.aiff)
%
% 				Begin	End
% Utterance			   Sample
% ---------------------------	------	------			
% Morning (up)			1	30000
% Morning (down)		30000	70000
% Corner (down)			70000	100000
% Yellow (monotone)		100000	140000
% Yellow (up)			140000	175000
% Yellow (up higher)		175000	215000
% Blue (down)			215000	255000
% Good Morning (spoken, slow)	255000	325000
% Good Morning (whispered)	325000	350000	
% Good Morning (spoken)		350000	390000


if ( ~ exist('Caretha') == 1)
	[Caretha,sr]=ReadSound('/home/interval/malcolm/CarethaEdit.aiff');
end

if ( ~ exist('morningup') == 1)
	morningup = Caretha(1:30000);
	morningdown = Caretha(30001:70000);
	cornerdown = Caretha(70001:100000);
	yellowflat = Caretha(100001:140000);
	yellowup = Caretha(140001:175000);
	yellowhigh = Caretha(175001:215000);
	bluedown = Caretha(215001:255000);
	gmslow = Caretha(255001:325000);
	gmwhisper = Caretha(325001:350000);
	gmspoken = Caretha(350001:390000);
	clear Caretha
end

slope = .5;
x=[0:.1:1];
b = -3 + 4*slope - 3*(-4+4*slope)/2;
c = 3*(-4 + 4*slope)/2;
d = 4 - 4*slope;
lambda = b*x + c*x.^2 + d*x.^3;

if 0
	p=pitchsnake(gmspoken,sr,sr/64,100,400);
	p=pitchsnake(gmslow,sr,sr/64,100,400);
end

if 0
	[morning final] = AudioMorph(morningup,morningdown,sr);
end

if 0
	[gm final] = AudioMorph(gmwhisper, gmspoken,sr);
	WriteSound(gm,sr,'goodmorning.aiff');
end

if 0
	[mc final] = AudioMorph(morningup, cornerdown, sr);
	WriteSound(mc,sr,'morningcorner.aiff');
end

if 0
	[yb final] = AudioMorph(yellowup, bluedown, sr, lambda);
	WriteSound(yb,sr,'yellowblue.aiff');
end

if 0
	y = BigAudioMorph('mc',morningup,cornerdown,sr,x);
end

if 1
	name = 'mc'
	s1 = morningup;
	s2 = cornerdown;
	sr = 22050;
	lambdaList = 0:.1:1;

	am1
	am2
	am3
	am4
	am5
	am6
	am7
end
