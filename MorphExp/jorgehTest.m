%%
clear all; close all;

[s1, sr] = wavread('a150.wav');
[s2, sr] = wavread('a190.wav');
[y, final] = AudioMorph(s1, s2, sr);

%% look and listen to the result

figure(2);
imagesc(final);
soundsc(y, sr);