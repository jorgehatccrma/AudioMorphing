function s = TestVowelSpectrum(f1, sampleRate, fftSize)

if (nargin < 2) sampleRate = 16000; end
if (nargin < 3) fftSize = 512; end

y = zeros(1,fftSize);
y(1) = 1;

if isstr(f1)
    if f1 == 'a' | f1 == '/a/'
           f1=730; f2=1090; f3=2440;
    elseif f1 == 'i' | f1 == '/i/'
           f1=270; f2=2290; f3=3010;
    elseif f1 == 'u' | f1 == '/u/'
           f1=300; f2=870; f3=2240;
    end
end;

%  FormantFilter(input, f, fs) - Filter an input sequence to model one
%    formant in a speech signal.  The formant frequency (in Hz) is given
%    by f and the bandwidth of the formant is a constant 50Hz.  The
%    sampling frequency in Hz is given by fs.
if f1 > 0
        cft = f1/sampleRate;
        bw = 50;
        q = f1/bw;
        rho = exp(-pi * cft / q);
        theta = 2 * pi * cft * sqrt(1-1/(4 * q*q));
        a2 = -2*rho*cos(theta);
        a3 = rho*rho;
        y=filter([1+a2+a3],[1,a2,a3],y);
end;

%  FormantFilter(input, f, fs) - Filter an input sequence to model one
%    formant in a speech signal.  The formant frequency (in Hz) is given
%    by f and the bandwidth of the formant is a constant 50Hz.  The
%    sampling frequency in Hz is given by fs.
if f2 > 0
        cft = f2/sampleRate;
        bw = 50;
        q = f2/bw;
        rho = exp(-pi * cft / q);
        theta = 2 * pi * cft * sqrt(1-1/(4 * q*q));
        a2 = -2*rho*cos(theta);
        a3 = rho*rho;
        y=filter([1+a2+a3],[1,a2,a3],y);
end;

%  FormantFilter(input, f, fs) - Filter an input sequence to model one
%    formant in a speech signal.  The formant frequency (in Hz) is given
%    by f and the bandwidth of the formant is a constant 50Hz.  The
%    sampling frequency in Hz is given by fs.
if f3 > 0
        cft = f3/sampleRate;
        bw = 50;
        q = f3/bw;
        rho = exp(-pi * cft / q);
        theta = 2 * pi * cft * sqrt(1-1/(4 * q*q));
        a2 = -2*rho*cos(theta);
        a3 = rho*rho;
        y=filter([1+a2+a3],[1,a2,a3],y);
end;

s = (abs(fft(y)));
s = s(1:length(s)/2+1)';
