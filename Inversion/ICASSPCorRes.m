[corLen frames] = size(correlogram);
if ~(corLen == 256*channels)
        error('Correlogram Frame Length doesn''t match 256*channels.');
end

if exist('initialPhase') ~= 1
        initialPhase = 0;
        disp('Assuming 0 for first phase in all channels');
end

if exist('initialRotation') ~= 1
        initialRotation = 0;
        disp('Not doing any rotations.');
end

if exist('rotationChannels') ~= 1
        rotationChannels = 3;
end

if exist('laterIterations') ~= 1
        laterIterations = 10;
end

if exist('cochlearIterations') ~= 1
        cochlearIterations = 10;
end

fftShift = 1;

fprintf('initialRotation=%d, initialPhase=%d, fftShift=%d.\n', ...
        initialRotation, initialPhase, fftShift);
fprintf('rotationChannels=%d, laterIterations=%d, cochlearIterations=%d.\n', ...
        rotationChannels, laterIterations, cochlearIterations);

incr=64;
winLength=256;
fftLen=2*winLength;
fftFreqs = (0:(fftLen-1))'/fftLen*sr;
corInvError = zeros(10,channels);

clear estCochleagram
for c=3:channels
        s = zeros(fftLen,frames);
        for f=1:frames
                frame = reshape(correlogram(:,f),channels,winLength);
                d = zeros(fftLen,1);
                d(1:winLength) = frame(c,:)';
                d((winLength+2):fftLen) = flipud(d(2:winLength));
%               d = frame(c,:)';
                d = d * d(1);
                spec = sqrt(abs(fft(d)));
                s(:,f) = spec;
        end
%       figure(1);
%       simage(flipud(s));
%       spectrum=ComplexSpectrum(cochleagram(c,:),64,256,fftShift);
%       figure(2);
%       simage(abs(spectrum));
%       plot([sum(abs(spectrum))' sum(s)']);
%       pause;

        if c > 3 & initialPhase > 0
                if initialPhase > 1             % Do the Delta Phase Calc
                        freqResp = ComplexFreqResp(earFilters(c,:),fftFreqs,sr);
                        for f=1:frames
                                phaseSpec(:,f) = phaseSpec(:,f) .* freqResp;
                        end
                end
                                                % Get the previous phase
                s = MatchMagnitudes(s, phaseSpec);
        else
                s = abs(s);
        end
                
        if initialRotation & c <= rotationChannels% Just do rotation on first 
                yp=real(InvertAndAdd(s, incr, winLength, 0, ...
                        fftShift, initialRotation));
        else
                yp = real(InvertAndAdd(s, incr, winLength, 0, fftShift, 0));
        end
        firstY = yp;

        if c == 3
                itersToRun = 10;
        else
                itersToRun = laterIterations;
        end

        for iter=1:itersToRun
                phaseSpec = ComplexSpectrum(yp, incr, winLength, fftShift);
                theErr = sum(sum((abs(s)-abs(phaseSpec)).^2))/ ...
                        sum(sum(abs(s).^2))*100;
                fprintf('Error for channel %d, iteration %d is %g%%.\n', ...
                        c, iter, theErr);
                corInvError(iter, c) = theErr;
                errorHistory(f) = theErr;
                phaseSpec = MatchMagnitudes(s, phaseSpec);
                yp = max(0,real(InvertAndAdd(phaseSpec, incr, ...
                        winLength, iter, fftShift, initialRotation)));
                pix = min(1500,min(length(cochleagram(c,:)),length(yp)));
                plot([yp(1:pix)' -cochleagram(c,1:pix)']);
                drawnow;
        end
        estCochleagram(c,:) = yp;
        eval(['save specwave' num2str(c) ' s yp']);
end

if 1
        inverseagc('reset');
        agcInversion = inverseagc(estCochleagram, agcParms);
%       agcInversion = output;
        clear sosOutput output;

        invsoscascade('reset');
        y=fliplr(invsoscascade(fliplr(2*agcInversion), earFilters, gains));
        playsound(y/max(y),16000);
%       errorEnergy = sum((huge-y).^2);
%       fprintf('Signal to Error ratio is %g\n', 
%               10*log10(signalEnergy/errorEnergy));

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
%               plot([hwrSave(750:850);fixedOutput(chan,750:850)]');
%               pause(1);
                clear sos2Output;
                invsoscascade('reset');
                y=fliplr(invsoscascade(fliplr(fixedOutput), earFilters, gains));
                clear fixedOutput;
                playsound(y/max(y),16000);
%               errorEnergy = sum((huge-y).^2);
%               fprintf('Signal to Error ratio is %g dB\n', 
%                       10*log10(signalEnergy/errorEnergy));
        end
end
