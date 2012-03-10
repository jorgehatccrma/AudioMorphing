% Test a discrepancy between LyonPassiveEar and ICASSPCochRes

if exist('tapestry') ~= 1
	tapestry = ReadSound('PowerMalcolm:data.adc');
	sr=16000;
end

% From the published code

df = 1;
earQ = 8;
stepfactor = earQ/32;
differ=0;
agcf=1;
taufactor=3;

input = tapestry(14000:17000);
[earFilters, cfs, gains] = DesignLyonFilters(sr, earQ, stepfactor);
[channels, width] = size(earFilters);

nSamples = length(input);
nOutputSamples = nSamples/df;
[nChannels filterWidth] = size(earFilters);

sosOutput = zeros(nChannels, df);
sosState = zeros(nChannels, 2);
agcState = zeros(nChannels, 4);
y = zeros(nChannels, nOutputSamples);

decEps = EpsilonFromTauFS(df/sr*taufactor,sr);
decState = zeros(nChannels, 2);
decFilt = SetGain([0 0 1 -2*(1-decEps) (1-decEps)^2], 1, 0, sr);

eps1 = EpsilonFromTauFS(.64,sr);
eps2 = EpsilonFromTauFS(.16,sr);
eps3 = EpsilonFromTauFS(.04,sr);
eps4 = EpsilonFromTauFS(.01,sr);

tar1 = .0032;
tar2 = .0016;
tar3 = .0008;
tar4 = .0004;

agcParms = [.0032 .0016 .0008 .0004; ...
                EpsilonFromTauFS(.64,sr) EpsilonFromTauFS(.16,sr) ...
                EpsilonFromTauFS(.04,sr) EpsilonFromTauFS(.01,sr)];
				
for i=0:nOutputSamples-1
	sosOutput = soscascade(input(i*df+1:i*df+df), earFilters, ...  
				sosOutput, sosState);
	output = max(0, sosOutput);		%% Half Wave Rectify
	if agcf > 0
		output = agc(output, [tar1 tar2 tar3 tar4; ...
				      eps1 eps2 eps3 eps4], ...
				output, agcState);
		if i == nOutputSamples-1
			agcState
		end
	end

	if differ > 0
		output = [output(1,:);output(1:nChannels-1,:) - ...
					output(2:nChannels,:)];
		output = max(0, output);
	end

	if df > 1
		output = sosfilters(output, decFilt, output, decState);
	end
	y(:,i+1) = output(:,df);
end


        soscascade('reset');
        icasspsosOutput = soscascade(input, earFilters);
        icassphwrOutput = max(0,icasspsosOutput);
        agc('reset');
		if agcf > 0
        	icasspcochleagram = agc(icassphwrOutput, agcParms);
		else
			icasspcochleagram = icassphwrOutput;
		end

	soscascade('reset');
	agc('reset');
	mcochleagram = LyonPassiveEar(input, sr, df, earQ, stepfactor, differ, ...
									agcf, taufactor);

y(1:2,:) = zeros(size(y(1:2,:)));
icasspcochleagram(1:2,:) = zeros(size(icasspcochleagram(1:2,:)));

subplot(3,1,1);imagesc(y(:,300:500));title('y');
subplot(3,1,2);imagesc(icasspcochleagram(:,300:500));title('icassp');
subplot(3,1,3);imagesc(mcochleagram(:,300:500));title('mcochleagram');

if 1
	p = 1;
	plot([y(:,p) icasspcochleagram(:,p) mcochleagram(:,p)]);
end
