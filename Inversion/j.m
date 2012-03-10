for i = 1:43
	orig(i) = max(max(correlogram(:,i)));
	new(i) = max(max(ReadImage(sprintf('/usr/tmp/tap/tap%05d',i))));
end
plot([orig' new'/255*.0032]);

