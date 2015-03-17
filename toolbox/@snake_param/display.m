function display(p)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   DISPLAY Display a snake_param object
%       DISPLAY(P) displays the values set in the snake_param object P.
%
%
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


disp(' ');
disp([inputname(1),' = '])
disp(' ');
disp(['   Snake Length : ' num2str(p.slength)])
disp(['   Range        : ' num2str(p.range)])
if p.forward
    disp('   Forward      : true')
else
    disp('   Forward      : false')
end
if p.perrin
    disp('   Int. Energy  : perrin');
else
    disp('   Int. Energy  : original');
end
disp(['   Walk Rate    : ' num2str(p.walkrate)]);
disp(['   Alpha        : ' num2str(p.alpha)]);
disp(['   Beta         : ' num2str(p.beta)]);
disp(['   Gamma        : ' num2str(p.gamma)]);
disp(['   Corr Weight  : ' num2str(p.correlationWeight)]);
disp(['   Blocked      : ' num2str(p.blocked(1,:))]);
for i = 2:size(p.blocked, 1)
    disp(['                  ' num2str(p.blocked(i, :))]);
end
disp(['   Window Width : ' num2str(p.windowWidth)]);
disp(['   Window Height: ' num2str(p.windowHeight)]);
if p.forward
    disp(['   Plot Snake   : true' ]);
else
    disp(['   Plot Snake   : false' ]);
end
if p.relativeWindow
    disp(['   Rel.   Window: true' ]);
else
    disp(['   Rel.   Window: false' ]);
end
if p.movingMean
    disp(['   Moving Mean  : true']);
else
    disp(['   Moving Mean  : false']);
end
disp(['   Window Offset: ' num2str(p.windowOffset)]);
%disp(['   Harmony #    : ' num2str(p.harmonyNumber)]);
%disp(['   Harmony Mask : ' num2str(p.harmonicMask)]);
disp(' ');