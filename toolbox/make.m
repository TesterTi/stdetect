
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Makes the mex files contained in this distribution
%   
%   Copyright 2009, 2010 Thomas Lampert
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


fprintf('Compiling Mex Files...');

done = 1;

try
    mex(['.' filesep 'snake' filesep 'mex' filesep 'snake.c']);
catch err
    fprintf('Could not compile ./snake/mex/snake.c!\n');
    done = 0;
end

try
    mex(['.' filesep 'line_detection' filesep 'pca' filesep 'mex' filesep 'pca_gaussian.c']);
catch err
    fprintf('Could not compile ./line_detection/pca/mex/pca_gaussian.c!\n');
    done = 0;
end

try
    mex(['.' filesep 'line_detection' filesep 'pca' filesep 'mex' filesep 'pca_convolution.c']);
catch err
    fprintf('Could not compile ./line_detection/pca/mex/pca_convolution.c!\n');
    done = 0;
end

try
    mex(['.' filesep 'line_detection' filesep 'bar' filesep 'mex' filesep 'bar_convolution.c']);
catch err
    fprintf('Could not compile ./line_detection/bar/mex/bar_convolution.c!\n');
    done = 0;
end

if done
    fprintf('Done\n');
else
    fprintf('One or more mex files were not compiled.\n');
end