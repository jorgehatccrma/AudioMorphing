%function y = DTWInterpolate(a,b,lambda)
% y = Intepolate(a,b,lambda)
% This function computes a straightforward interpolation between two
% multi-dimensional prototypes, a and b.  Lambda is a fraction between
% 0 and 1.

a=TestVowelSpectrum('a',22050,512)';
i=TestVowelSpectrum('i',22050,512)';
u=TestVowelSpectrum('u',22050,512)';

[error,path1,path2] = dtw4(a/max(a), u/max(u));

au = zeros(length(a),100);
for l=0:99
	lambda = l/99;
	[index1,index2] = TimeWarpPaths(path1, path2, lambda);
	
	y = (1-lambda)*a(index1) + lambda*u(index2);
	au(:,l+1) = y';
	%plot([a b y]);drawnow;
end;


[error,path1,path2] = dtw4(i/max(i), a/max(a));

ia = zeros(length(a),100);
for l=0:99
	lambda = l/99;
	[index1,index2] = TimeWarpPaths(path1, path2, lambda);
	
	y = (1-lambda)*i(index1) + lambda*a(index2);
	ia(:,l+1) = y';
	%plot([a b y]);drawnow;
end;


[error,path1,path2] = dtw4(u/max(u), i/max(i));

ui = zeros(length(a),100);
for l=0:99
	lambda = l/99;
	[index1,index2] = TimeWarpPaths(path1, path2, lambda);
	
	y = (1-lambda)*u(index1) + lambda*i(index2);
	ui(:,l+1) = y';
	%plot([a b y]);drawnow;
end;


subplot(3,1,1); imagesc(ui(1:60,:)); title('/u/ to /i/');
subplot(3,1,2); imagesc(ia(1:60,:)); title('/i/ to /a/');
subplot(3,1,3); imagesc(au(1:60,:)); title('/a/ to /u/');
