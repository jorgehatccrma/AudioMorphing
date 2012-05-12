function [error,path1,path2] = dtwmem(s1, s2, sub)
% Dynamic Time Warping search... by Malcolm Slaney
% After this routine
%	s1 approximately = s2(path1)
%	s2 approximately = s1(path2)
% and error is a scalar with the lowest energy found.
%
% (c) Interval Research, Inc., May 31, 1995
% This is just like the dtw algorithm, but it doesn't
% precompute the distance's between all the cepstrals.
% This will take less memory, but need 1.5 times the
% CPU time.

if nargin < 3
	sub = 1;
end

% First do the subsampling.
if sub <= 1
	ss1 = s1;
	ss2 = s2;
else
	width = floor(size(s1,2)/sub);
	ss1 = zeros(size(s1,1),width);
	for i=1:width
		ss1(:,i) = sum(s1(:,((i-1)*sub+1):(i*sub))')';
	end
	
%	clg;subplot(2,1,1);imagesc(s1);
%	subplot(2,1,2);imagesc(ss1);drawnow;pause;
	
	width = floor(size(s2,2)/sub);
	ss2 = zeros(size(s2,1),width);
	for i=1:width
		ss2(:,i) = sum(s2(:,((i-1)*sub+1):(i*sub))')';
	end

%	clg;subplot(2,1,1);imagesc(s2);
%	subplot(2,1,2);imagesc(ss2);drawnow;pause;
	
%	ss1 = s1(:,1:sub:size(s1,2));
%	ss2 = s2(:,1:sub:size(s2,2));
end

[d1 l1] = size(ss1);
[d2 l2] = size(ss2);

if (d1 ~= d2)
	fprintf('DTW Error: Depth of two data arrays are not equal.\n')
	return
end

% We're only going to allow slopes of 2,1,.5.  Here are labels
% for the ones we allow.
topPath=1;
midPath=2;
botPath=3;

% We'll fill the global distance array with infinities. Unlike
% the original version, we're going to only keep the current row
% (g), the previous row (gm1), and the current row index minus 2
% (gm2).
gm2=ones(1,l2)*inf;
gm1=ones(1,l2)*inf;
g=ones(1,l2)*inf;
path=ones(l1, l2)*nan;	% Full array for the paths.

% The first two directions are fixed.  They have to be the 
% middle path.
gm2(1) = sum((ss1(:,1)-ss2(:,1)).^2);
path(1,1) = midPath;
gm1(2) = gm2(1) + sum((ss1(:,2)-ss2(:,2)).^2);
path(2,2) = midPath;

for i=3:l1
	for j=3:l2
		lij =   sum((ss1(:,i)  - ss2(:,j)).^2);
		lim1j = sum((ss1(:,i-1)- ss2(:,j)).^2);
		lijm1 = sum((ss1(:,i)  - ss2(:,j-1)).^2);
		top = gm2(j-1) + lim1j + lij;
    	mid = gm1(j-1) + lij;
    	bot = gm1(j-2) + lijm1 + lij;
		[g(j) path(i,j)]= min([top mid bot]);
	end
	gm2 = gm1;
	gm1 = g;
end

error = g(l2);

% Now backtrack through the array looking for the path that got
% us the minimum distance.  Luckily we left a string of 
% directions that we can use to find our way back to the origin.
p1 = l1;
p2 = l2;
while (p1 > 0 & p2 > 0)
	path1(p1) = p2;
	path2(p2) = p1;
	direct = path(p1,p2);
	if (direct == topPath)
		p1 = p1 - 1;
		path1(p1) = p2;
		path2(p2) = p1;
	elseif (direct == botPath)
		p2 = p2 - 1;
		path1(p1) = p2;
		path2(p2) = p1;
	end
	p1 = p1 - 1;
	p2 = p2 - 1;
end

if sub > 1
	len = length(path1);
	width = size(s1,2);
	x=1:width;
	indices = min((x-1)/sub+1,len-.001);
	frac = indices - floor(indices);
	indices = floor(indices);
	oldpath1 = path1;
	path1 = (path1-1)*sub+1;
	path1 = path1(indices).*(1-frac) + path1(indices+1).*frac;
	clg;subplot(2,1,1);plot(oldpath1);
	subplot(2,1,2);plot(path1);drawnow;
	
	len = length(path2);
	width = size(s2,2);
	x=1:width;
	indices = min((x-1)/sub+1,len-.001);
	frac = indices - floor(indices);
	indices = floor(indices);
	path2 = (path2-1)*sub+1;
	path2 = path2(indices).*(1-frac) + path2(indices+1).*frac;
end
	
% Now (optionally) plot the result.  
if 1
	m = max(size(s1,2), size(s2,2));
	
	subplot(3,1,1);
	if (d1 ~= 1)
		imagesc(s1);
		axis([1 m 1 d1]);
	else
		plot(s1)
		axis([1 m min(s1) max(s1)]);
	end
	title('Signal 1');

	s15 = zeros(size(s1));
	for i=1:size(s1,2)
		s15(:,i) = s2(:,path1(i));
	end
	subplot(3,1,2);
	if (d1 ~= 1)
		imagesc(s15);
		axis([1 m 1 d1]);
	else
		plot(s15);
		axis([1 m min(s15) max(s15)]);
	end
	title('Signal 2 warped to be like Signal 1');
	
	subplot(3,1,3);
	if (d1 ~= 1)
		imagesc(s2);
		axis([1 m 1 d1]);
	else
		plot(s2);
		axis([1 m min(s2) max(s2)]);
	end
	title('Signal 2');
	drawnow;
end

% The following is useful test code... generate a known warping 
% signal, generate two arrays of sort of random data, and then
% use d1 and d2 as dtw input.
if 0
	warp = [ones(1,4) ones(1,4)*2 ones(1,4) ones(1,4)*.5];
	warp = cumsum(warp);
	
	d1 = rand(2,max(warp));
	d1(1,:) = filter([1 1 1 1],[1],d1(1,:)')';
	d1(2,:) = filter([1 1 1 1],[1],d1(2,:)')';	
	d2 = d1(:,warp);
end 

if 0
	warp = [ones(1,4) ones(1,4)*2 ones(1,4) ones(1,4)*.5];
	warp = cumsum(warp);
	
	d1 = rand(1,max(warp));
	d1(1,:) = filter([1 1 1 1],[1],d1(1,:)')';
	d2 = d1(:,warp);
end 
