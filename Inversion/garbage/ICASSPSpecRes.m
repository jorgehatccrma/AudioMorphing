% Try out spectrogram inversion

len = 3000;

if exist('useTap') ~= 1
        useTap = 1;
end

if exist('winIncrement') ~= 1
        winIncrement = 64;
end

if exist('winLength') ~= 1
        winLength = 4 * winIncrement;
end

if exist('amCarrier') ~= 1
        amCarrier = 300;
end

if exist('amModulator') ~= 1
        amModulator = 60;
end

if exist('fftShift') ~= 1
        fftShift = 1;
end

if exist('sr') ~= 1
        sr = 16000;
end

if exist('specIters') ~= 1
        specIters = 10;
end

if exist('fileSave') ~= 1
        fileSave = '';
end

if exist('timeWarp') ~= 1
        timeWarp = 1;
end

if exist('valleyThreshold') ~= 1
        valleyThreshold = 2;                    % fraction of maximum
        fprintf('valleyThreshold is %g.\n', valleyThreshold);
end

%       0 means assume 0 phase for all windows (only matters after first.)
%       1 means do unweighted cross-correlation and pick peak
%       2 means do linearly weighted cross-correlation to pick peak.
if exist('initialPhase') ~= 1
        initialPhase = 2;
end

fprintf('useTap=%d, winIncrement=%d, winLength=%d\n', useTap, winIncrement, winLength);
fprintf('amCarrier=%g, amModulator=%g\n', amCarrier, amModulator);
fprintf('sr=%g, fftShift=%d, initialPhase=%d\n', sr, fftShift, initialPhase);
fprintf('specIters=%g, fileSave=%s, timeWarp=%g.\n', specIters, fileSave, timeWarp);
fprintf('valleyThreshold=%g.\n', valleyThreshold);

if useTap
        if exist('tapestry') ~= 1
                tapestry = ReadSound('data.adc');
        end
        if useTap < 2
%               input = tapestry(14000:17000);
                input = tapestry(14000:25000);
        else
                input = tapestry;
        end
else
        t2pi=(1:len)/sr*2*pi;
        input = cos(t2pi*amModulator).*cos(t2pi*amCarrier);
end

s = ComplexSpectrum(input, winIncrement, winLength, fftShift);
[frameLength frameCount] = size(s);

if valleyThreshold < 1
        initialS = s;
        for j=1:frameCount
                threshold = abs(max(s(:,j))) * valleyThreshold;
                els = find(abs(s(:,j))<threshold);
                if length(els) > 0; s(els,j) = 0*els; end
        end
end
                
if timeWarp ~= 1
        s = abs(s);
        newFrameCount = floor((frameCount-1)/timeWarp)+1;
        newSpec = zeros(frameLength,newFrameCount);
        for j=0:(newFrameCount-1)
                t = j*timeWarp + 1;
                if fix(t) == t
                        newSpec(:,j+1) = s(:,t);
                else
                        lowerT = floor(t);
                        upperT = lowerT + 1;
                        newSpec(:,j+1) = s(:,lowerT)*(upperT-t) + s(:,upperT)*(t-lowerT);
                end
        end
        s = newSpec;
        clear newSpec;
        [frameLength frameCount] = size(s);
        simage(s);
        drawnow;
end             

if 0
        p = ones(winLength, frameCount);
        p(:,1) = zeros(winLength,1);
        p(1,:) = zeros(1, frameCount);
        p = cumsum(p);
        p = cumsum(p')';
        p = p * incr/winLength * 2 * pi;
        i = sqrt(-1);
        sl = abs(s).*exp(i*p);
        yp = real(InvertAndAdd(sl, incr, winLength, 0, fftShift, initialPhase));
else
        yp = real(InvertAndAdd(abs(s), winIncrement, winLength, 0, fftShift, initialPhase));
%       i=sqrt(-1);
%       yp = real(InvertAndAdd(abs(s).*exp(i*rand(size(s))*100), winIncrement, winLength, 0, fftShift, initialPhase));
%       yp = rand(size(input));
%       yp = real(InvertAndAdd((s), winIncrement, winLength, 0, fftShift, initialPhase));
end
playsound(yp/max(yp),16000);

if exist('fileSave') == 1 & length(fileSave) > 0
        WriteSound(yp,16000,[fileSave '0.aiff']);
end

for f=1:specIters
        s2 = ComplexSpectrum(yp, winIncrement, winLength, fftShift);
        theErr = sum(sum((abs(s)-abs(s2)).^2))/sum(sum(abs(s).^2))*100;
        fprintf('Error at iteration %d is %g%%.\n', f, theErr);
        errorHistory(f) = theErr;
        s2 = MatchMagnitudes(s, s2);
        yp = real(InvertAndAdd(s2, winIncrement, winLength, f, fftShift, initialPhase));
       plot(yp(1:1500));
        drawnow;
       playsound(yp/max(yp),16000);
        if exist('fileSave') == 1 & length(fileSave) > 0
                WriteSound(yp,16000,[fileSave num2str(i) '.aiff']);
        end
end
