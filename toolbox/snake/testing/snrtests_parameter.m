function [llr, results] = snrtests_parameter(test_parameter, internal_energy, external_energy)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

points = 50;

parameter_values = [0:1/points:1];

if strcmpi(test_parameter, 'SnakeLength')
    parameter_values = [1:points];
end

p = snake_param();

llr = zeros(1, numel(parameter_values));
results = zeros(3, numel(parameter_values));

parfor parameter_value_index = 1:numel(parameter_values)
    
    fprintf('%s: %.2f\n', test_parameter, parameter_values(parameter_value_index));
    
    params = [get(p, 'Gamma'), get(p, 'Beta'), get(p, 'WalkRate'), get(p, 'WindowWidth'), get(p, 'Windowheight')];
	
    if strcmpi(internal_energy, 'original')
        alpha = get(p, 'Alpha');
    end
    
	switch lower(test_parameter)
		case 'gamma'
			params(1) = parameter_values(parameter_value_index);
		case 'beta'
			params(2) = parameter_values(parameter_value_index);
		case 'walkrate'
			params(3) = parameter_values(parameter_value_index);
		case 'alpha'
            		alpha     = parameter_values(parameter_value_index);
    end
    
    if strcmpi(internal_energy, 'perrin')
        [loss, results_tmp] = evaluate_performance(params, [], external_energy);
    else
        [loss, results_tmp] = evaluate_performance(params, alpha, external_energy);
    end
    
    results(:, parameter_value_index) = results_tmp;
    llr(parameter_value_index) = 1-loss;

end