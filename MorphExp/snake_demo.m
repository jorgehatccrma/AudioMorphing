function snake_demo(action,arg)
% SNAKES
% By Chris Bregler and Malcolm Slaney, Interval Technical Report IRC 1995-017
% Copyright (c) 1995 Interval Research Corporation.
%
% Usage
%
% snake_demo ([image_data])
%
% This function provides an interactive GUI for showing how the
% snake m-file works.  For more information about the GUI press the help
% button.  For more information about the snake function itself type
% help snake

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

global snakeImage snakePoints snakeGradient snakeGlobals;

if length(snakeGlobals) ~= 10,
  snakeGlobals = zeros(10);
end

loadGlobals = ['movingPoint = snakeGlobals(1);' ...
                           'displayHndl = snakeGlobals(2);' ...
                           'useGradHndl = snakeGlobals(3);' ...
                           'betaHndl = snakeGlobals(4);' ...
                           'sigmaHndl = snakeGlobals(5);' ...
                           'XdeltaHndl = snakeGlobals(6);' ...
                           'YdeltaHndl = snakeGlobals(7);' ...
                           'XresolutionHndl = snakeGlobals(8);' ...
                           'YresolutionHndl = snakeGlobals(9);' ...
                           'snakeGradientSigma = snakeGlobals(10);'];

saveGlobals = ['snakeGlobals = [movingPoint, displayHndl,' ...
                           'useGradHndl, betaHndl, sigmaHndl, XdeltaHndl, ' ...
                           'YdeltaHndl, XresolutionHndl, YresolutionHndl, ' ...
                           'snakeGradientSigma];'];

eval(loadGlobals);

if nargin < 1
        action = 'init';
        o=ones(64,48);
        x=cumsum(o')';
        y=cumsum(o);
        snakeImage = 100*exp(-(y-50+20*exp(-(x-size(x,2)/2).^2/32/32)).^2/100);
%       snakeImage = get(image,'CData');
end

if ~isstr(action)
        snakeImage = action;
        action = 'init';
end

if strcmp(action, 'help')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The HELP command
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ttlStr='Snakes Help';
    hlpStr= ...
    [' Welcome to SNAKES.  This demonstration allows you to experiment      '
     ' with the image processing technique known as snakes.  Snakes are     '
     ' used to interactively align splines to contours or other features    '
     ' in images.                                                           '
     '                                                                      '
     ' By Chris Bregler and Malcolm Slaney                                  '
     ' Interval Technical Report IRC 1995-017                               '
     ' Copyright (c) 1995 Interval Research Corporation.                    '
     '                                                                      '
     ' To select Contour Points:  Use the mouse button to place points in   '
     '   the image.  For example put 20 points along the upper half of the  '
     '   head. Press shift and the mouse button to move a point to a new    '
     '   location. Only the points are considered in the algorithm.         '
     '                                                                      '
     ' Each time you press the iterate button the snake will move so as to  '
     '   minimize the curvature and maximize the value of the data under    '
     '   the contour.                                                       '
     '                                                                      '
     ' A detailed description of the snake algorithm can be found in:       '
     ' "Using Dynamic Programming for Solving Variational Problems in       '
     ' Vision" by Amir A. Amini, Terry E. Weymouth, and Ramesh C. Jain,     '
     ' IEEE Transactions on Pattern Analysis and Machine Intelligence,      '
     ' Vol. 12, No. 9, September 1990, pp 855-867.                          '];
    old_fig=watchon;
    pos = get(0,'DefaultFigurePosition');
    help_fig=figure('Name','Snakes Help Window','NumberTitle','off',...
                    'Position',pos, 'Colormap',[]);
    uicontrol('Style','edit', 'units','normalized', ...
              'Position',[0.05 0.05 0.9 0.9],...
              'HorizontalAlignment','Left',...
              'BackgroundColor',[0.5 0.5 0.5], ...
              'ForegroundColor',[1 1 1], ...
              'Max',30,'String',hlpStr);
   watchoff(old_fig);
elseif strcmp(action, 'helpparm')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The PARAMETER HELP command
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ttlStr='Snakes Parameters';
    hlpStr= ...
    [' X / Y Resolution:  Pixel step size for the snake alignment algorithm.'
     '   Increasing this value speeds up the computation.                   '
     ' X / Y Range:  Maximum number of pixels that each point will be moved '
     '   per iteration.                                                     '
     ' Beta:  "Smoothness" parameter.  Increasing beta results in smoother  '
     '   contours.  Smaller values allow the snake to track more locally.   '
     ' Sigma:  Spread (in pixels) of the gaussian image gradient operator.  '
     ' Fit to Gradient:  Snakes should be aligned to the image gradient.    '
     ' Iterate:  Press this button to run one iteration of the snake code.  '
     '                                                                      '
     ' Note: The run time of this algorithm is proportional to the product  '
     ' of the number of pixel searched in the x direction, the number of    '
     ' pixel searched in the y direction, and the number of snake points.   '
     ' The number of search locations is equal to length(-range:resol:range)'
     '                                                                      '
     ' The optimal value of beta is proportional to the values in the image.'];
    old_fig=watchon;
    pos = get(0,'DefaultFigurePosition');
    help_fig=figure('Name','Snakes Parameter Help Window','NumberTitle', ...
                                        'off','Position',pos, 'Colormap',[]);
    uicontrol('Style','edit', 'units','normalized', ...
              'Position',[0.05 0.05 0.9 0.9],...
              'HorizontalAlignment','Left',...
              'BackgroundColor',[0.5 0.5 0.5], ...
              'ForegroundColor',[1 1 1], ...
              'Max',30,'String',hlpStr);
   watchoff(old_fig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The INIT command - clear the arrays and set up the demo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(action, 'init')
        snakePoints = [];
        snakeGradient = [];
        movingPoint = 0;
        clg;
        eval(saveGlobals); snake_demo('initFrame'); eval(loadGlobals);
        eval(saveGlobals); snake_demo('redraw'); eval(loadGlobals);

        set(gcf,'WindowButtonDownFcn','snake_demo ''down'';');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The clear command - Reset the point list
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(action, 'clear')
        snakePoints=[];
        eval(saveGlobals); snake_demo('redraw'); eval(loadGlobals);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The computegrad command - Compute the gradient of the image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(action, 'computegrad')
        sigma = str2num(get(sigmaHndl,'String'));
        if sigma <= 1
                sigma = 1;
                set(sigmaHndl, 'String', sprintf('%g',sigma));
        end

        if exist('snakeGradientSigma') == 1 & sigma == snakeGradientSigma
                eval(saveGlobals); return;
        end
        snakeGradientSigma = sigma;
        % Calculate a normal distribution with a standard deviation of sigma.
        % Cut off when tails reach 1% of the maximum value.
        i = 1;
        maxval = 1/(sqrt(2*pi)*snakeGradientSigma);
        gi = maxval;
        g = [gi];
        while gi >= 0.01*maxval
                gi = maxval * exp(-0.5*i^2/snakeGradientSigma^2);
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
                dgi = i / (sqrt(2*pi) * snakeGradientSigma^3) * ...
                                exp(-0.5*i^2/snakeGradientSigma^2);
                dg = [dgi dg -dgi];
                i = i + 1;
                if dgi > maxval
                        maxval = dgi;
                end
        end

        % Calculate the derivative of a Gaussian in x convolved with snakeImage
        sub = 1+floor(length(dg)/2):(1+size(snakeImage,2)+length(dg)/2-1);
        fi1 = zeros(size(snakeImage));
        for i=1:size(snakeImage,1)
                new = conv(snakeImage(i,:),dg);
                fi1(i,:) = new(sub);
        end

        % Smooth the resulting derivative in y
        fi2 = zeros(size(fi1));
        sub = 1+floor(length(g)/2):(1+size(fi1,1)+length(g)/2-1);
        for i=1:size(fi1,2)
                new = conv(fi1(:,i)',g');
                fi2(:,i) = new(sub)';
        end

        % Calculate the derivative of a Gaussian in y convolved with snakeImage
        fi3 = zeros(size(snakeImage));
        sub = 1+floor(length(dg)/2):(1+size(snakeImage,1)+length(dg)/2-1);
        for i=1:size(snakeImage,2)
                new = conv(snakeImage(:,i)',dg');
                fi3(:,i) = new(sub)';
        end

        % Smooth the resulting derivative in x
        sub = 1+floor(length(g)/2):(1+size(snakeImage,2)+length(g)/2-1);
        fi4 = zeros(size(fi3));
        for i=1:size(fi3,1)
                new = conv(fi3(i,:),g);
                fi4(i,:) = new(sub);
        end

        if 0
                subplot(2,2,1);
                imagesc(fi1);
                title('fi1 = dGx * snakeImage');
                subplot(2,2,2);
                imagesc(fi2);
                title('fi2 = Gy * fi1');
                subplot(2,2,3);
                imagesc(fi3);
                title('fi3 = dGy * snakeImage');
                subplot(2,2,4);
                imagesc(fi4);
                title('fi4 = Gx * fi3');
        end

        snakeGradient = sqrt(fi2.^2+fi4.^2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The (mouse) down command - Add a point to the path, or dispatch to move
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(action, 'down')
        if ~strcmp(get(gcf,'SelectionType'),'normal')
                eval(saveGlobals); snake_demo('movePoint'); eval(loadGlobals);
                set(gcf,'WindowButtonMotionFcn','snake_demo(''movePoint'');');
                set(gcf,'WindowButtonUpFcn','snake_demo(''up'');');
                eval(saveGlobals); return;
        end
        currPt = get(gca,'CurrentPoint');
    currPt = round(currPt(1,1:2));
        if (currPt(1))>-1&(currPt(1)<size(snakeImage,2))& ...
                        (currPt(2)>0)&(currPt(2)<size(snakeImage,1)),
            snakePoints = [snakePoints;currPt];
        else
%           set(txtHndl,'String',' Please click inside the axis square');
                eval(saveGlobals); return;
        end
        line(currPt(1),currPt(2), ...
                        'LineStyle','.', ...
                        'Color','r', ...
                        'MarkerSize', 25, ...
                        'EraseMode','none');

        if size(snakePoints,1) > 1
                numPts = size(snakePoints,1);
                line(snakePoints([numPts-1 numPts],1),...
                     snakePoints([numPts-1 numPts],2), ...
                     'Color','b', ...
                     'EraseMode','none');
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The initFrame command - Draw the GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(action, 'initFrame')
    axes( ...
        'Units','normalized', ...
        'Position',[0.05 0.05 0.65 0.90], ...
        'XTick',[],'YTick',[], ...
        'Box','on');

    %====================================
    % Information for all buttons
    labelColor=[0.8 0.8 0.8];
    top=0.95;
    bottom=0.05;
        labelSpace = .19;
        btnCnt = 10 + 2*2;                      % 10 singles, 2 doubles
        btnSpread = 0.01;                       % Border Spread
        btnSize = (top-bottom-btnSpread)/btnCnt - btnSpread;
        space = btnSize+btnSpread;

    left=0.68;
    btnWid=0.28;
    % Spacing between the button and the next command's label
%    spacing=0.02;

    %====================================
    % The CONSOLE frame
    frmBorder=0.02;
    yPos=0.05-frmBorder;
    frmPos=[left-frmBorder bottom btnWid+2*frmBorder top-bottom];
    h=uicontrol( ...
        'Style','frame', ...
        'Units','normalized', ...
        'Position',frmPos, ...
                'BackgroundColor',[0.50 0.50 0.50]);

        bottom = bottom + btnSpread;

    %====================================
    % The Iterate button
    labelStr='Iterate';
    infoHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[left bottom btnWid 2*btnSize], ...
        'String',labelStr, ...
        'Callback','snake_demo(''iterate'')');
    %====================================
    % The Clear button
    labelStr='Clear Points';
    clearHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[left bottom+2*space btnWid 2*btnSize], ...
        'String',labelStr, ...
        'Callback','snake_demo(''clear'')');
    %====================================
    % The Display Gradient Checkbox
    displayHndl=uicontrol( ...
        'Style','checkbox', ...
        'Units','normalized', ...
        'Position',[left bottom+4*space btnWid 1*btnSize], ...
        'String','Display Gradient', ...
        'Callback','snake_demo(''redraw'')');
    %====================================
    % The Compute Gradient Checkbox
    useGradHndl=uicontrol( ...
        'Style','checkbox', ...
        'Units','normalized', ...
        'Position',[left bottom+5*space btnWid 1*btnSize], ...
        'String','Fit to Gradient', 'Value', 0);
    %====================================
    % The Sigma EditBox
    sigmaHndl=uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',[left+labelSpace bottom+6*space ...
                    btnWid-labelSpace 1*btnSize], ...
        'String','1.5');
    %====================================
    % The Sigma Label
    sigmaLabelHndl=uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position',[left bottom+6*space labelSpace 1*btnSize], ...
        'String', 'Gaussian Sigma');
    %====================================
    % The Beta EditBox
    betaHndl=uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',[left+labelSpace bottom+7*space ...
                    btnWid-labelSpace 1*btnSize], ...
        'String','0.1');
    %====================================
    % The Beta Label
    betaLabelHndl=uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position',[left bottom+7*space labelSpace 1*btnSize], ...
        'String', 'Beta');
    %====================================
    % The Y-Delta EditBox
    YdeltaHndl=uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',[left+labelSpace bottom+8*space ...
                    btnWid-labelSpace 1*btnSize], ...
        'String','1');
    %====================================
    % The Y-Delta Label
    YdeltaLabelHndl=uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position',[left bottom+8*space labelSpace 1*btnSize], ...
        'String', 'Y Range');
    %====================================
    % The Y-Resolution EditBox
    YresolutionHndl=uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',[left+labelSpace bottom+9*space ...
                    btnWid-labelSpace 1*btnSize], ...
        'String','1');
    %====================================
    % The Y-Resolution Label
    YresolutionLabelHndl=uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position',[left bottom+9*space labelSpace 1*btnSize], ...
        'String', 'Y Resolution');
    %====================================
    % The X-Delta EditBox
    XdeltaHndl=uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',[left+labelSpace bottom+10*space ...
                    btnWid-labelSpace 1*btnSize], ...
        'String','1');
    %====================================
    % The X-Delta Label
    XdeltaLabelHndl=uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position',[left bottom+10*space labelSpace 1*btnSize], ...
        'String', 'X Range');
    %====================================
    % The X-Resolution EditBox
    XresolutionHndl=uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',[left+labelSpace bottom+11*space ...
                    btnWid-labelSpace 1*btnSize], ...
        'String','1');
    %====================================
    % The X-Resolution Label
    resolutionLabelHndl=uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position',[left bottom+11*space labelSpace 1*btnSize], ...
        'String', 'X Resolution');

    %====================================
    % The HELP parameters button
    HelpHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[left bottom+12*space btnWid 1*btnSize], ...
        'String','Parameter Help',...
        'Callback','snake_demo(''helpparm'')');
    %====================================
    % The HELP button
    HelpHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[left bottom+13*space btnWid 1*btnSize], ...
        'String','Help',...
        'Callback','snake_demo(''help'')');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The iterate command - Perform one iteration of the snake search
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(action,'iterate')
        if size(snakePoints,1) < 1
                disp('Need to specify control points first.');
                eval(saveGlobals); return;
        end

        beta = str2num(get(betaHndl,'String'));
        if beta <= 0
                beta = 0.02;
                set(betaHndl,sprintf('%g',beta));
        end
        alpha = 0*ones(1,size(snakePoints,1));
        beta = beta*ones(1,size(snakePoints,1));

        XmaxDelta = str2num(get(XdeltaHndl,'String'));
        if XmaxDelta <= 0
                XmaxDelta = 0;
                set(XdeltaHndl, 'String', sprintf('%g',XmaxDelta));
        end

        Xresolv = str2num(get(XresolutionHndl,'String'));
        if Xresolv <= 1
                Xresolv = 1;
                set(XresolutionHndl, 'String', sprintf('%g',Xresolv));
        end

        YmaxDelta = str2num(get(YdeltaHndl,'String'));
        if YmaxDelta < 0
                YmaxDelta = 0;
                set(YdeltaHndl, 'String', sprintf('%g',YmaxDelta));
        end

        Yresolv = str2num(get(YresolutionHndl,'String'));
        if Yresolv < 1
                Yresolv = 1;
                set(YresolutionHndl, 'String', sprintf('%g',Yresolv));
        end

        if get(useGradHndl, 'Value')
                eval(saveGlobals);snake_demo('computegrad');eval(loadGlobals);
                [snakePoints e]= snake(snakePoints, alpha, beta, ...
                                       XmaxDelta,Xresolv, ...
                                       YmaxDelta, Yresolv, snakeGradient);
        else
                [snakePoints e]= snake(snakePoints, alpha, beta, ...
                                       XmaxDelta,Xresolv, ...
                                       YmaxDelta, Yresolv, snakeImage);
        end
        eval(saveGlobals); snake_demo('redraw'); eval(loadGlobals);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The movePoint command - Move a point in the path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(action, 'movePoint')
        currPt = get(gca,'CurrentPoint');
    x = currPt(1,1);
        y = currPt(1,2);
        if ~(movingPoint > 0)
                dist = (snakePoints(:,1)-x).^2 + (snakePoints(:,2)-y).^2;
                [error movingPoint] = min(dist);
                line(snakePoints(movingPoint,1), ...
                                snakePoints(movingPoint,2), ...
                                'LineStyle','.', ...
                                'Color','g', ...
                                'MarkerSize', 25, ...
                                'EraseMode','none');
        end
        snakePoints(movingPoint,:) = [x y];
        eval(saveGlobals); snake_demo('redraw'); eval(loadGlobals);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The redraw command - Draw the image and the current path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(action, 'redraw')
        if get(displayHndl, 'Value')
                eval(saveGlobals);snake_demo('computegrad');eval(loadGlobals);
                imagesc(snakeGradient);
        else
                imagesc(snakeImage);
        end
        axis('equal')
        axis('off')
        colormap(1-gray);

        numPts = size(snakePoints,1);
        if numPts > 0
                currPt = snakePoints(1,:);
                line(currPt(1),currPt(2), ...
                        'LineStyle','.', ...
                        'Color','r', ...
                        'MarkerSize', 25, ...
                        'EraseMode','none');
        end

        for i=2:numPts
                currPt = snakePoints(i,:);
                line(currPt(1),currPt(2), ...
                        'LineStyle','.', ...
                        'Color','r', ...
                        'MarkerSize', 25, ...
                        'EraseMode','none');
                line(snakePoints([i-1 i],1),snakePoints([i-1 i],2), ...
                'Color','b', ...
                'EraseMode','none');
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The up command - Mouse button is up, stop changing the path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(action, 'up')
        set(gcf,'WindowButtonMotionFcn','');
        set(gcf,'WindowButtonUpFcn','');
        movingPoint = 0;
else
        disp('Illegal command');
end

eval(saveGlobals);



