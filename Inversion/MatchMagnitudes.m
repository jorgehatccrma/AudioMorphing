% function output = MatchMagnitudes(reference, input)
% Take the magnitude from the reference and the phase from the input
% and return a new array.

function output = MatchMagnitudes(reference, input)
referenceMag = reference .* conj(reference);
inputMag = input .* conj(input);
output = input .* sqrt(referenceMag ./ (inputMag+.00000001));
%ms = s .* conj(s);
%fprintf('reference mag is %g, original mag is %g\n', max(max(m2)), max(max(mi)));
%fprintf('new mag is %g.\n', max(max(ms)));
