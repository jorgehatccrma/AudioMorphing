function [snake_pnts,e] = snake(pnts, alpha, beta, max_delta_x, resol_x, ...
                          max_delta_y, resol_y, feat_img)
% SNAKES
% By Chris Bregler and Malcolm Slaney, Interval Technical Report IRC 1995-017
% Copyright (c) 1995 Interval Research Corporation.
%
% Usage
%
% [snake_pnts,e] = snake(pnts, alpha, beta, ...
%                        max_delta_y, resol_y, max_delta_x, resol_x, feat_img)
%
% This function computes one iteration of the energy-minimization of
% active contour models described in the paper "Using Dynamic Programming
% for Solving Variational Problems in Vision" by Amir A. Amini, Terry E.
% Weymouth, and Ramesh C. Jain, IEEE Transactions on Pattern Analysis and
% Machine Intelligence, Vol. 12, No. 9, September 1990, pp 855-867.
%
% Snakes align a contour to some feature maxima in an image (for example)
% image boundaries) using dynamic programming.  The quality of the
% alignment is measured by an energy function consisting of an internal
% "contour-smoothness-term" and an external feature term (equation 50 in the
% paper).  Minimizing this energy term leads to a contour that trade offs
% these two criterias (smoothness + maximal feature responses) in some desired
% way.
%
% Inputs:
%   pnts          Starting contour. Each row is a [x,y] coordinate.
%   alpha         Energy contributed by the distance between control points.
%                 Set to zero if length of slope doesn't matter.
%   beta          Energy contributed by the curvature of the snake.  Larger
%                 values of beta cause bends in the snake to have a high cost
%                 and lead to smoother snakes.
%   max_delta_y   Max number of pixels to move each contour point vertically
%   resol_y       Contour points will be moved by multiples of resol_y
%   max_delta_x   Analog to max_delta_y
%   resol_x       Analog to resol_y
%   feat_img      2D-Array of the feature responses in the image.  For example
%                 it can contain the magnitude of the image gradients
%
% Outputs:
%   snake_pnts    New contour points.
%   e             Energy value of these new contour points
%

% SNAKES - A MatLab MEX file to demonstrate snake contour-following.
% This Software was developed by Chris Bregler and Malcolm Slaney of
% Interval Research Corporation.
% Copyright (c) 1995 Interval Research Corporation.
%
% This is experimental software and is being provided to Licensee
% 'AS IS.'  Although the software has been tested on a PowerMac
% 8100 running version 4.2c of MatLab with MEX support and on an
% SGI running version 4.2c, Interval makes no warranties relating
% to the software's performance on these or any other platforms.
%
% Disclaimer
% THIS SOFTWARE IS BEING PROVIDED TO YOU 'AS IS.'  INTERVAL MAKES
% NO EXPRESS, IMPLIED OR STATUTORY WARRANTY OF ANY KIND FOR THE
% SOFTWARE INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY OF
% PERFORMANCE, MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.
% IN NO EVENT WILL INTERVAL BE LIABLE TO LICENSEE OR ANY THIRD
% PARTY FOR ANY DAMAGES, INCLUDING LOST PROFITS OR OTHER INCIDENTAL
% OR CONSEQUENTIAL DAMAGES, EVEN IF INTERVAL HAS BEEN ADVISED OF
% THE POSSIBLITY THEREOF.
%
%   This software program is owned by Interval Research
% Corporation, but may be used, reproduced, modified and
% distributed by Licensee.  Licensee agrees that any copies of the
% software program will contain the same proprietary notices and
% warranty disclaimers which appear in this software program.

  if resol_y < 1; resol_y = 1; end;
  if resol_x < 1; resol_x = 1; end;

  n = size(pnts,1);
  [row,col] = size(feat_img);
  target = reshape(feat_img,row*col,1);
  scan_y = -max_delta_y:resol_y:max_delta_y;
  scan_x = -max_delta_x:resol_x:max_delta_x;
  num_scan_y = size(scan_y,2);
  num_scan_x = size(scan_x,2);
  num_states = num_scan_y * num_scan_x;

  fprintf('n = %d; num_states = %d; ',n,num_states);

  delta_x = ones(num_scan_y,1)*scan_x;
  delta_y = scan_y'*ones(1,num_scan_x);
  delta_x = reshape(delta_x,1,num_states);
  delta_y = reshape(delta_y,1,num_states);

  states_x = round(pnts(:,1))*ones(1,num_states) + ones(n,1)*delta_x;
  states_y = round(pnts(:,2))*ones(1,num_states) + ones(n,1)*delta_y;

  % take care of boundary cases
  states_x = min(max(states_x,1),col);
  states_y = min(max(states_y,1),row);

  states_i = (states_x-1)*row + states_y;

  Smat = zeros(n,num_states^2);
  Imat = zeros(n,num_states^2);

  % forward pass

  for v2 = 1:num_states,
    Smat(1,(v2-1)*num_states+1:v2*num_states) = ...
      -target(states_i(1,:))';
  end;

  for k = 2:n-1,
    fprintf('.');  % debug
    for v2 = 1:num_states, for v1 = 1:num_states,
      v0_domain = 1:num_states;
      [y,i] = min( Smat(k-1,(v1-1)*num_states+v0_domain) ...
              + alpha(k)*( (states_x(k,v1)-states_x(k-1,v0_domain)).^2 ...
                      + (states_y(k,v1)-states_y(k-1,v0_domain)).^2) ...
              + beta(k)*( (states_x(k+1,v2)-2*states_x(k,v1) ...
                       + states_x(k-1,v0_domain)).^2 ...
                     + (states_y(k+1,v2)-2*states_y(k,v1) ...
                       + states_y(k-1,v0_domain)).^2) );
      Smat(k,(v2-1)*num_states+v1) = ...
        y-target(states_i(k,v1));
      Imat(k,(v2-1)*num_states+v1) = i;
    end; end;
  end;

  for v1 = 1:num_states,
    v0_domain = 1:num_states;
    [y,i] = min( Smat(n-1,(v1-1)*num_states+v0_domain) ...
            + alpha(n)*( (states_x(n,v1)-states_x(n-1,v0_domain)).^2 ...
                    + (states_y(n,v1)-states_y(n-1,v0_domain)).^2));
    Smat(n,v1) = y-target(states_i(n,v1));
    Imat(n,v1) = i;
  end;

  [e,final_i] = min(Smat(n,1:num_states));


  % backward pass

  snake_pnts = zeros(n,2);

  snake_pnts(n,:) = [states_x(n,final_i),states_y(n,final_i)];
  v1 = final_i; v2 = 1;
  for k=n-1:-1:1,
    v = Imat(k+1,(v2-1)*num_states+v1);
    v2 = v1; v1 = v;
    snake_pnts(k,:) = [states_x(k,v1),states_y(k,v1)];
  end;

  fprintf('\n');



