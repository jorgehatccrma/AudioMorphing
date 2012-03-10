% Combine a brightness and velocity image into one combined image.  Input is
% two arrays and optionally two maximum values.  Output is either a tripple
% set of red, green, and blue images, a single interleaved array of RGB, or
% an image on the screen.

function [r,g,b] = Colorize(bright,velocity,brightMax,velMax)
global dopplerColormap dopplerNumVelocity dopplerNumBrightness

if length(dopplerColormap) == 0 | nargin < 2
        l = length(colormap);
        a=floor(sqrt(l));
        b = floor(l/a);
        if rem(b,2) == 1
                dopplerNumVelocity = b;
        else
                dopplerNumVelocity = b-1;
        end
        dopplerNumBrightness = floor(l/dopplerNumVelocity);
        l = dopplerNumBrightness*dopplerNumVelocity;

        brightArray = (cumsum(ones(dopplerNumBrightness, ...
					dopplerNumVelocity))-1) / ...
			dopplerNumBrightness;
        velocityArray = cumsum(ones(dopplerNumBrightness, ...
					dopplerNumVelocity)')' - ...
			floor((dopplerNumVelocity+1)/2);

        maxAbsVel = max(max(abs(velocityArray)));
        red = min(max(0,(velocityArray+maxAbsVel)/maxAbsVel),1);
        green = 1-abs(velocityArray/maxAbsVel);
        blue= min(max(0,(-velocityArray+maxAbsVel)/maxAbsVel),1);

        brightScale = brightArray/max(max(brightArray));
        dopplerColormap = [reshape(red.*brightScale,l,1) ...
				reshape(green.*brightScale,l,1) ...
				reshape(blue.*brightScale,l,1)];
end

if nargin < 2
	bright = brightArray;
	velocity = velocityArray;
end

if nargin < 3
        brightMax = max(max(bright))
end
if nargin < 4
        velMax = max(max(abs(velocity)))
end

color = min(max(floor(bright/brightMax*dopplerNumBrightness),0), ...
		  dopplerNumBrightness-1) + ...
	max(min(floor((velocity+velMax)/(2*velMax)*dopplerNumVelocity), ...
			dopplerNumVelocity-1),0) * dopplerNumBrightness+1;

if nargout > 2
	[rows,cols] = size(bright);
	r = reshape(dopplerColormap(color,1),rows,cols);
	g = reshape(dopplerColormap(color,2),rows,cols);
	b = reshape(dopplerColormap(color,3),rows,cols);
else
	if nargout > 0
		r = dopplerColormap(color',1);
		g = dopplerColormap(color',2);
		b = dopplerColormap(color',3);
		l = length(r);
		rgb(3:3:3*l) = b';
		rgb(2:3:3*l) = g';
		rgb(1:3:3*l) = r';
		r = rgb;
	else
		colormap(dopplerColormap);
		image(color);
	end
end
