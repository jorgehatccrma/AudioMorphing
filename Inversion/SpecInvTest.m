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

if exist('fileSave') ~= 1
        fileSave = '';
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
% fprintf('fileSave=%s\n', fileSave);

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

yp = SpectrumInversion(abs(s), winIncrement, winLength, 10);
