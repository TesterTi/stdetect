
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   To collate results for Section 5.3.1 (Figure 5.3(a))
%
%   NEED TO EDIT ./@signatureDatabase/database.csv
%   with the following information: Harmonics = 1, Mask = 1
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

line_location_results_walkrate = zeros(51, 10);
for i = 1:10
    [line_location_results_walkrate(:, i), results_walkrate(:,:,i)] = snrtests_parameter('WalkRate', 'original', 'pca');

    save(['.' filesep 'test_scripts' filesep 'results' filesep 'results_parameter_tests_original_pca_single'], 'line_location_results_walkrate', 'results_walkrate');
end