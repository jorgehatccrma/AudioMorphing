function ODG = TestInversion( TestFile, increment, windowlength, iterations )
% Takes the spectrogram of a file, strips out the phase
% then recovers and saves the new file
% Compares new to old using a PEAQ-type descriptor


    FileIn = strcat(TestFile,'.wav');
    FileOut = strcat(TestFile,'_recov.wav');

    [x fs] = wavread(FileIn);
    s = ComplexSpectrum(x',increment,windowlength,1);
    
    s = abs(s);
    
    [signal spectrum] = SpectrumInversion(s,increment,windowlength,iterations);
    
    wavwrite(signal, fs, FileOut);
    
    ODG = PQevalAudio_fn(FileIn, FileOut);
    fprintf('PEAQ Objective Difference Grade: %8.4f\n', ODG);

end

