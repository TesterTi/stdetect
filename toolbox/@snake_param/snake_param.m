function p = snake_param(varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   SNAKE_PARAM class constructor
%       P = SNAKE_PARAM constructs a snake parameter object P with the
%       default parameter values.
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


switch nargin
    case 0
        % if no input arguments, create a default object  
        
        p.slength = 20;     % length of the contour (number of snake points)

        p.range = [];       % set from signature database in analyse_spectrogram
        
	p.walkrate = 0.36;  % walkrate

	p.alpha = 0.1;      % applied to ECont (Continuity weighting)
        
        p.beta = 0.16;      % applied to Ecurv (Curvature weighting or Perrin weighting)
        
        p.gamma = 1;        % applied to Eimage (Potential weighting)
        
        p.perrin = 1;       % use Perrin internal energy (ignores the parameter alpha)
        
        p.correlationWeight = 0.0; % IGNORE: obsolete

        p.forward = 1;      % IGNORE: obsolete

        p.blocked = [1,1,1;
                     0,0,0;  % Stops the snake points moving into other time steps (y axis)
                     1,1,1];
        
        p.windowWidth = 3;   % Size of the external energy window (width, frequency axis)

        p.windowHeight = 21; % Size of the external energy window (height, time axis)
        
        p.outputPlot = 0;    % IGNORE: obsolete
        
        p.harmonyNumber = 0; % set from signature database in analyse_spectrogram

        p.harmonicSet = [];  % set from signature database in analyse_spectrogram
        
        p.relativeWindow = 0; % IGNORE: obsolete
        
        p.movingMean = 0;    % IGNORE: obsolete
        
        p.windowOffset = 1;  % Shifts the window to compensate for large window potential energy forms
			     % see section 4.2.4.1 A Note on the Vertices' Neighbourhood in the thesis
        
        p = class(p, 'snake_param');
    case 1
    % if single argument of class stock, return it
        if (isa(varargin{1},'snake_param'))
            p = varargin{1}; 
        else
            error('Input argument is not a snake_param object')
        end
    case 3
    % create object using specified values
        p = class(p, 'snake_param');
    otherwise
        error('Wrong number of input arguments')
end