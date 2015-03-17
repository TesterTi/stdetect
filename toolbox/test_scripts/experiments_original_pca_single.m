
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  To collate results for Section 5.5.1 (Figures 5.14-5.18 and corresponding
%  graphs in Appendix A)
%
%  NEED TO EDIT ./@signatureDatabase/database.xls or SignatureDatabase.m with 
%  the following information: Harmonics = 1, Mask = 1
%
%  saves results './test_scripts/results/'
%
%  After the results have been saved the 'calculate_means script.m'
%  should be used to average the results and then 'plot_graphs_lla.m'
%  and 'plot_graphs_FPandTP' should be used to recreate the graphs
%  presented in the thesis.
%
%  The loops are parfor, to speed up calculation use Matlab's distributed
%  functionality.
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

for x = 1:10
    
    [results_str, lla_str] = snrtestsstraight('pca', 0, 1);
    
    save(['.' filesep 'test_scripts' filesep 'results' filesep 'results_pca_original_single_' num2str(x)], 'results_str', 'lla_str');
    
    slopes = [1, 2, 4, 8, 16];
    parfor slope_ind = 1:numel(slopes)
      [temp_results, temp_lla] = snrtestssloped(num2str(slopes(slope_ind)), 'pca', 0, 1);
      results_slo(:, :, slope_ind) = temp_results;
      lla_slo(slope_ind, :)        = temp_lla;
    end
    
    save(['.' filesep 'test_scripts' filesep 'results' filesep 'results_pca_original_single_' num2str(x)], 'results_slo', 'lla_slo', 'results_str', 'lla_str');

    periods = [10, 15, 20];
    percentage_variances = [1, 2, 3, 4, 5];
    for period_ind = 1:numel(periods)
        parfor pv_ind = 1:numel(percentage_variances)
            [temp_results_sin, temp_lla] = snrtestssinusoidal(num2str(periods(period_ind)), num2str(percentage_variances(pv_ind)), 'pca', 0, 1);
            lla_sin(period_ind, :, pv_ind) = temp_lla;
            results_sin{period_ind, pv_ind} = temp_results_sin;
        end
        save(['.' filesep 'test_scripts' filesep 'results' filesep 'results_pca_original_single_' num2str(x)], 'results_slo', 'lla_slo', 'results_str', 'lla_str', 'results_sin', 'lla_sin');
    end
    

    clear 'results_sin'
    clear 'lla_sin'
    clear 'results_str'
    clear 'lla_str'
    clear 'results_slo'
    clear 'lla_slo'

end

clear all