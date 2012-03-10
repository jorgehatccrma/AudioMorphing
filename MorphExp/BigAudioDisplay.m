clg

m = max(size(s1Smooth,2), size(s2Smooth,2));
d1 = 257;

subplot(3,2,2);
imagesc(flipud(s1Smooth));
axis([1 m 1 d1]);
title('Signal 1 Smooth Spectrogram');

subplot(3,2,4);
s15 = zeros(size(s1Smooth));
for i=1:size(s1Smooth,2)
	s15(:,i) = s2Smooth(:,path1(i));
end
imagesc(flipud(s15));
axis([1 m 1 d1]);
title('Signal 2 warped to be like Signal 1');

subplot(3,2,6);
imagesc(flipud(s2Smooth));
axis([1 m 1 d1]);
title('Signal 2 Smooth Spectrogram');


subplot(3,2,1);
imagesc(s1correlate(1:300,:));
axis([1 m 1 300])
hold on
plot([sr./s1pitch' sr./s1rabpitch']);
title('Signal 1 Correlation and Pitch');
hold off

subplot(3,2,3);
s15 = zeros(size(s1correlate));
for i=1:size(s1Smooth,2)
	s15(:,i) = s2correlate(:,path1(i));
end
imagesc(s15(1:300,:));
axis([1 m 1 300]);
title('Signal 2 warped to be like Signal 1');

subplot(3,2,5);
imagesc(s2correlate(1:300,:));
axis([1 m 1 300])
hold on
plot([sr./s2pitch' sr./s2rabpitch']);
title('Signal 2 Correlation and Pitch');
hold off
