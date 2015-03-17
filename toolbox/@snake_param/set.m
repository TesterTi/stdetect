function p = set(p, varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   SET Set snake_param properties and return the updated object
%       P = SET(P, VARARGIN)
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


propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch prop
       case 'SnakeLength'
           if rem(val, 1) && val <= 0
               error('Snake Length must be a positive integer');
           else
               p.slength = val;
           end
           
       case 'Forward'
           if val == 0 || val == 1
               p.forward  = val;

               % forward is switched swap the range if they do not comply
               if (p.range(1) < p.range(2) && ~p.forward) || (p.range(1) > p.range(2) && p.forward)
                   p.range = [p.range(2) p.range(1)];
               end

               if val
                   p.blocked = [1,1,1;
                                1,0,0;
                                1,1,1];
               else
                   p.blocked = [1,1,1;
                                0,0,1;
                                1,1,1];
               end
           else
               error(['Forward must be 1 (true) or 0 (false)'])
           end
           
       case 'WalkRate'
           if val < 0 || val > 1
               error('Walk Rate must be within the range 0 - 1');
           else
               p.walkrate = val;
           end
           
       case 'Alpha'
           if val < 0 || val > 1
               error('Alpha must be within the range 0 - 1');
           else
               p.alpha = val;
           end
           
       case 'Beta'
           if val < 0 || val > 1
               error('Beta must be within the range 0 - 1');
           else
               p.beta = val;
           end
           
       case 'Gamma'
           if val < 0 || val > 1
               error('Gamma must be within the range 0 - 1');
           else
               p.gamma = val;
           end
           
       case 'PointDist'
           p.dm = val;
           
       case 'CorrWeight'
           p.correlationWeight = val;
           
       case 'Blocked'
           p.blocked = val;
           
       case 'Range'
           if numel(val) == 2
               p.range = val;
               if p.range(1) < p.range(2)
                   p.forward = 1;
                   p.blocked = [1,1,1;
                                1,0,0;
                                1,1,1];
               else
                   p.forward = 0;
                   p.blocked = [1,1,1;
                                0,0,1;
                                1,1,1];
               end
           else
               error('Range must be a vector of length 2');
           end
           
       case 'WindowWidth'
           if rem(val, 1) ~= 0 && val < 1 && rem(val, 2) == 1
               error('Window Width must be a positive odd integer >= 1');
           else
               p.windowWidth = val;
           end
           
       case 'WindowHeight'
           if rem(val, 1) ~= 0 && val < 1 && rem(val, 2) == 1
               error('Window Height must be a positive odd integer >= 1');
           else
               p.windowHeight = val;
           end
           
       case 'OutputPlot'
           p.outputPlot = val;
       
       case 'HarmonyNumber'
           if rem(val, 1) && val <= 0
               error('Harmony Number must be a positive integer');
           else
               p.harmonyNumber = val;
           end
           
       case 'HarmonicSet'
           p.harmonicSet = val;
       
       case 'InternalEnergy'
           switch lower(val)
               case 'perrin'
                   p.perrin = 1;
               case 'original'
                   p.perrin = 0;
               otherwise
                   error(['Internal Energy ''' val ''' Not Recognised']);
           end
       case 'WindowOffset'
           if rem(val, 1) && val <= 0
               error('Window Offset must be a positive integer');
           else
               p.windowOffset = val;
           end
       otherwise
           error([prop, ' Is not a valid snake_param property'])
   end
end