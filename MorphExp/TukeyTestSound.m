sr=16000;
a=TestVowelSpectrum('a',sr,512);
i=TestVowelSpectrum('i',sr,512);
u=TestVowelSpectrum('u',sr,512);

as = zeros(length(a)+1,100);
temp = flipud(a');
for j=1:size(as,2)
	as(1:length(a),j) = temp;
end

f=0:(length(a)-1)/length(a)*sr;
pitch=120;
h = zeros(length(a),1);
for j=pitch:pitch:(sr/2)
	k=j/(sr/(2*length(a)));
	h(floor(k)) = 1-(k-floor(k));
	h(floor(k)+1) = k-floor(k);
end

as = zeros(2*length(a),100);
temp = flipud(a') .* h;
temp = [flipud(temp(2:length(temp))) ; 0; temp ];
for j=1:size(as,2)
	as(:,j) = temp;
end



ai = TukeyMorph3(a,i,200);	
temp = [ai(2:size(ai,1),:); zeros(1,size(ai,2)); flipud(ai)];
hf = [flipud(h(2:length(h)));0;h];
for j=1:size(as,2)
	as(:,j) = temp(:,j) .* hf;
end
	

len=2000;
window = [sin((1:200)/200*pi/2) ones(1,len-200-200) cos(-(1:200)/200*pi/2)];
input = sin((1:2000)*2*pi/10) .* window;
spec=abs(ComplexSpectrum(input,64,256));
y=SpectrumInversion(spec,64,256);

% Error for iteration 1 is 29.2515%.
% Error for iteration 2 is 9.10145%.
% Error for iteration 3 is 3.7328%.
% Error for iteration 4 is 1.68821%.
% Error for iteration 5 is 0.783732%.
% Error for iteration 6 is 0.382733%.
% Error for iteration 7 is 0.196168%.
% Error for iteration 8 is 0.107311%.
% Error for iteration 9 is 0.0642992%.
% Error for iteration 10 is 0.0425249%.
