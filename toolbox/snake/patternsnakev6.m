function snakePos = patternsnakev6(I, p, nets)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   PATTERNSNAKEV6 Wrapper for the snake algorithm written in C code.
%       SNAKEPOS = PATTERNSNAKEV6(I, P, NETS, WALKRATE) Passes the correct 
%       information to the main Snake algorithm which has been recoded in C.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Copyright 2007, 2010 Thomas Lampert
%
%
%   This file is part of STDetect.
%
%   STDetect is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   STDetect is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with STDetect. If not, see <http://www.gnu.org/licenses/>.
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


range         = p.range;

% Set snake with initial positions passed in range
% as passing to C subtract 1 from all positions
snakePos      = zeros(p.snakeLength, 2);
snakePos(:,1) = repmat(range(1), p.snakeLength, 1)-1;
snakePos(:,2) = repmat((ceil(p.windowHeight/2):size(I,1)-floor(p.windowHeight/2))', 1)-1;

p             = set(p, 'Range', [range(1)-1, range(2)-1]);

% plot snake movement
if p.outputPlot
    scrsz     = get(0,'ScreenSize');
    h4        = figure('Position',[1 1 scrsz(3) scrsz(4)/4]);
    colormap(gray);
    imagesc(I), hold on;
    t1        = title('Detection Process');
    set(gca, 'yticklabel', 190+5:5:190+size(I,1));
    h5        = plot(snakePos(1,1), snakePos(1,2), 'sr');
    h6        = plot(snakePos(1,1), snakePos(1,2), 'sr');
    h3        = plot(snakePos(1,1), snakePos(1,2), 'sc');
    h2        = plot(snakePos(:,1), snakePos(:,2), 'sc');
    
    xlabel('Frequency');
    ylabel('Time');
    axis([1 size(I,2) 1 size(I, 1)]);
    axis xy;
    hold off;
    pause(2)
end

inv_covar     = inv(nets{2}.covar{1}.^2);

try
    snakePos      = snake(I, p.range, nets, p.walkRate, p.alpha, p.beta, ...
                            p.gamma, 0.0, p.blocked, snakePos, ...
                                p.harmonyNumber, p.harmonicSet, inv_covar, ...
                                    p.outputPlot, p.relativeWindow, ...
                                        p.internalEnergy, p.windowOffset);

    % As result is being returned from C add 1 to each position
    snakePos      = snakePos + 1;
catch e
    if strcmp(e.identifier, 'MATLAB:UndefinedFunction')
        fprintf(2, 'Error: could not invoke the mex implementation of ''snake''.\n');
        fprintf(2, 'Aborting process.\n');
        snakePos = -1;
        return;
    else
        rethrow(e);
    end
end