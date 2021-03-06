% Generate some gaussians... used for filtering the snake_demo.

sigma = 2;

% Calculate a normal distribution with a standard deviation of sigma.
% Cut off when tails reach 1% of the maximum value.
i = 1;
maxval = 1/(sqrt(2*pi)*sigma);
gi = maxval;
g = [gi];
while gi >= 0.01*maxval
	gi = maxval * exp(-0.5*i^2/sigma^2);
	g = [gi g gi];
	i = i + 1;
end

% Calculate the derivative of a normal distribution with a standard 
% deviation of sigma.
% Cut off when tails reach 1% of the maximum value.
i = 1;
maxval = 0;
dgi = [maxval];
dg = [dgi];
while dgi >= 0.01*maxval
	dgi = i / (sqrt(2*pi) * sigma^3) * exp(-0.5*i^2/sigma^2);
	dg = [dgi dg -dgi];
	i = i + 1;
	if dgi > maxval
		maxval = dgi;
	end
end

% Calculate the derivative of a Gaussian in x convolved with theImage
sub = 1+floor(length(dg)/2):(1+size(theImage,2)+length(dg)/2-1);
fi1 = zeros(size(theImage));
for i=1:size(theImage,1)
	new = conv(theImage(i,:),dg);
	fi1(i,:) = new(sub);
end

% Smooth the resulting derivative in y
fi2 = zeros(size(fi1));
sub = 1+floor(length(g)/2):(1+size(fi1,1)+length(g)/2-1);
for i=1:size(fi1,2)
	new = conv(fi1(:,i)',g');
	fi2(:,i) = new(sub)';
end

% Calculate the derivative of a Gaussian in y convolved with theImage
fi3 = zeros(size(theImage));
sub = 1+floor(length(dg)/2):(1+size(theImage,1)+length(dg)/2-1);
for i=1:size(theImage,2)
	new = conv(theImage(:,i)',dg');
	fi3(:,i) = new(sub)';
end

% Smooth the resulting derivative in x
sub = 1+floor(length(g)/2):(1+size(theImage,2)+length(g)/2-1);
fi4 = zeros(size(fi3));
for i=1:size(fi3,1)
	new = conv(fi3(i,:),g);
	fi4(i,:) = new(sub);
end

subplot(2,2,1);
imagesc(fi1);
title('fi1 = dGx * theImage');
subplot(2,2,2);
imagesc(fi2);
title('fi2 = Gy * fi1');
subplot(2,2,3);
imagesc(fi3);
title('fi3 = dGy * theImage');
subplot(2,2,4);
imagesc(fi4);
title('fi4 = Gx * fi3');

