function setpaths

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   SETPATHS Adds paths necessary for execution to matlab current path list
%       SETPATHS Adds all the subdirectories to the matlab search space.
%       (called automatically when analyse_Spectrogram is run).
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


fprintf('Setting Paths...');
path('./utils/netlab', path);
path(path, './snake');
path(path, './snake/testing');
path(path, './test_scripts');
path(path, './utils');
path(path, './line_detection/pca');
path(path, './line_detection/pca/classifier');
path(path, './line_detection/bar');
path(path, './line_detection/nayar');
path(path, './metrics');
fprintf('Done\n');