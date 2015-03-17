
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   To collate results for Section 5.4.1 (Figure 5.9)
%
%   saves results './test_scripts/results/'
%
%   After this script has completed use the 'plot_graphs_parameter_variation.m'
%   to recreate the parameter variation graphs.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Copyright 2010 Thomas Lampert
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

clear all

line_location_results_alpha = zeros(51, 1);
for i = 1
    [line_location_results_alpha(:, i), results_alpha(:,:,i)] = snrtests_parameter('Alpha', 'original', 'intensity');

    save(['.' filesep 'test_scripts' filesep 'results' filesep 'results_parameter_tests_original_intensity'], 'line_location_results_alpha', 'results_alpha');
end

line_location_results_beta = zeros(51, 1);
for i = 1
    [line_location_results_beta(:, i), results_beta(:,:,i)] = snrtests_parameter('Beta', 'original', 'intensity');
    
    save(['.' filesep 'test_scripts' filesep 'results' filesep 'results_parameter_tests_original_intensity'], 'line_location_results_alpha', 'results_alpha', 'line_location_results_beta', 'results_beta');
end

line_location_results_gamma = zeros(51, 1);
for i = 1
    [line_location_results_gamma(:, i), results_gamma(:,:,i)] = snrtests_parameter('Gamma', 'original', 'intensity');
    
    save(['.' filesep 'test_scripts' filesep 'results' filesep 'results_parameter_tests_original_intensity'], 'line_location_results_alpha', 'results_alpha', 'line_location_results_beta', 'results_beta', 'line_location_results_gamma', 'results_gamma');
end

line_location_results_walkrate = zeros(51, 1);
for i = 1
    [line_location_results_walkrate(:, i), results_walkrate(:,:,i)] = snrtests_parameter('WalkRate', 'original', 'intensity');

    save(['.' filesep 'test_scripts' filesep 'results' filesep 'results_parameter_tests_original_intensity'], 'line_location_results_alpha', 'results_alpha', 'line_location_results_beta', 'results_beta', 'line_location_results_gamma', 'results_gamma', 'line_location_results_walkrate', 'results_walkrate');
end