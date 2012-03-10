% Recon parameters
if exist('invertAGC') ~= 1
        invertAGC = 1;
end

if exist('useTap') ~= 1
        useTap = 1;
end

if exist('tapGain') ~= 1
        tapGain = 1;
end

if exist('cochSNR') ~= 1
        cochSNR = 1000;
end

if exist('fileSave') ~= 1
        fileSave = '';
end

fprintf('invertAGC=%d, useTap=%d, tapGain=%g.\n', invertAGC, useTap, tapGain);
fprintf('cochSNR=%g, fileSave=%s\n\n', cochSNR, fileSave);

% Ear Model Parameters
earQ = 8;
stepfactor = .5;
sr=16000;
agcParms = [.0032 .0016 .0008 .0004; ...
                EpsilonFromTauFS(.64,sr) EpsilonFromTauFS(.16,sr) ...
                EpsilonFromTauFS(.04,sr) EpsilonFromTauFS(.01,sr)];
chan = 12;

if useTap
        if exist('tapestry') ~= 1
                tapestry = ReadSound('data.adc');
        end
        if useTap < 2
                input = tapGain*tapestry(14000:17000);
        else
                input = tapGain*tapestry;
        end
else
        input = zeros(1,512);
        input(256) = 1;
        input(255) = input(256)/2;
        input(257) = input(256)/2;
%       input = (-256:255)/512;
%       input = sin(2*pi*10*input).*exp(-30*input.^2);
end
signalEnergy = sum(input.^2);

if ~(exist('earFilters') == 1)
        [earFilters, cfs, gains] = DesignLyonFilters(sr, earQ, stepfactor);
        [channels, width] = size(earFilters);
end

if 1
        soscascade('reset');
        sosOutput = soscascade(input, earFilters);
        hwrOutput = max(0,sosOutput);
        agc('reset');
        cochleagram = agc(hwrOutput, agcParms);
%       clear hwrOutput sosOutput;
end

if cochSNR < 1000
        [chan len] = size(cochleagram);
        cochEnergy = sum(sum(cochleagram.^2))/(chan*len);
        noise = randn(chan,len)*cochEnergy/10^(cochSNR/10);
        cochleagram = max(0,noise+cochleagram);
end

if 1
        if invertAGC
                fprintf('Inverting the AGC.\n');
                inverseagc('reset');
                agcInversion = inverseagc(cochleagram, agcParms);
        else
                agcInversion = cochleagram;
        end
%       clear sosOutput;

        invsoscascade('reset');
        y=fliplr(invsoscascade(fliplr(2*agcInversion), earFilters, gains));
        yfirst = y;
%       playsound(y/max(y),16000);
        plot([y;yfirst]')
        drawnow;
        if exist('fileSave') == 1 & length(fileSave) > 1
                WriteSound(yfirst, 16000, [fileSave '0.aiff']);
        end
%       errorEnergy = sum((input-y).^2);
%       fprintf('Signal to Error ratio is %g\n', 
%               10*log10(signalEnergy/errorEnergy));

        for i=2:10
                % Now let's compute the FB output of the first reconstruction
                soscascade('reset');
                sos2Output = soscascade(y, earFilters);

                % OK, now let's combine the original (given) HWR output with 
                % the new Filter bank output based on the first reconstructed 
                % signal.  Take the positive values from the original signal 
                % with the negative values from the new reconstruction.
                fixedOutput = sign(agcInversion).*agcInversion + ...
                        (1-sign(agcInversion)).*min(0,sos2Output);
                plot([hwrOutput(chan,:);fixedOutput(chan,:)]');
                drawnow;
                clear sos2Output;
                invsoscascade('reset');
%       fixedOutput = sosOutput;
                y=fliplr(invsoscascade(fliplr(fixedOutput), earFilters, gains));
                if exist('fileSave') == 1 & length(fileSave) > 1
                        WriteSound(yfirst,16000,[fileSave num2str(i) '.aiff']);
                end
                clear fixedOutput;
%               playsound(y/max(y),16000);
                errorEnergy = sum((input-y).^2);
                snr = 10*log10(signalEnergy/errorEnergy);
                fprintf('Signal to Error ratio is %g dB\n', snr);
        end
end
plot([input;yfirst;y]')
