function [Y, act] = gaussfwd(net, x)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   GAUSSFWD todo:description
%       [Y, ACT] = GAUSSFWD(NET, X)
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

if numel(net.mu{1}) == size(x, 2)
    
    x = x - net.mu{1}(ones(size(x,1), 1), :);
    
    r_sq = diag(x*inv(net.covar{1}.^2)*x');
    
    act = exp((-1/2)*r_sq);
    
    Y = zeros(size(x, 1), 2);
    valid = (act > net.threshold);
    Y(valid, 2) = act(valid);
    Y(~valid, 1) = 1-act(~valid);
else
    fprintf('Gaussian dimensions do not match data dimension\n');
    act = -1;
    return;
end