
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This script is used to process the raw results of each experiment 
%   (experiments_perrin_pca, experiments_original_pca, 
%   experiments_original_intensity or experiments_pca_original_single).
%   The output is left in Matlab's workspace ready for the plot_graphs_lla
%   and plot_graphs_FPandTP scripts which plot the graphs.
%
%   Change the header and target_directory (below) to the desired values.
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% change header to the desired results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
header = 'results_pca_perrin';
%header = 'results_pca_original';
%header = 'results_intensity_original';
%header = 'results_pca_original_single';


target_directory = './test_scripts/results/'; % where results are stored (output of 'experiments_<int_energy>_<ext_energy>' scripts)


if strcmp(header, 'results_intensity_original')
    number_of_repetitions = 1;
else
    number_of_repetitions = 10;
end


for i = 1:number_of_repetitions
    load([target_directory header '_' num2str(i) '.mat']);
    
%     if numel(lla_str) == 20
%         lla_str = lla_str(1:17);
%     end
%     if size(lla_slo,2) == 20
%         lla_slo = lla_slo(:, 1:17);
%     end
%     if size(results_str,1) == 20
%         results_str = results_str(1:17, :);
%     end
%     if size(lla_sin,1) == 20
%         lla_sin = lla_sin(:, 1:17, :);
%     end
    
    x_str(:,i) = lla_str;
    
    x_slo(:,:,i) = lla_slo;
    
    y_str(:,:,i) = results_str;
end


for j = 1:3
    for i = 1:number_of_repetitions
        load([target_directory header '_' num2str(i) '.mat']);
        
%             if numel(lla_str) == 20
%         lla_str = lla_str(1:17);
%     end
%     if size(lla_slo,2) == 20
%         lla_slo = lla_slo(:, 1:17);
%     end
%     if size(results_str,1) == 20
%         results_str = results_str(1:17, :);
%     end
%     if size(lla_sin,2) == 20
%         lla_sin = lla_sin(:, 1:17, :);
%     end
    
        lla_sin = squeeze(lla_sin(j,:,:));
        
        results_slo = squeeze(results_slo(j,:,:));
        
        x_sin(:,:,i) = lla_sin;
        
        y_slo(:,:,i) = results_slo;
    end
    
    x_lla_sin(j,:,:) = mean(x_sin, 3);
    x_lla_sin_std(j,:,:) = std(x_sin, [], 3);
    
    x_results_slo(j,:,:) = mean(y_slo, 3);
    x_results_slo_std(j,:,:) = std(y_slo, [], 3);
end

lla_sin = x_lla_sin;
lla_sin_std = x_lla_sin_std;

results_slo = x_results_slo;
results_slo_std = x_results_slo_std;






for j = 1:3
    for k = 1:5
        for i = 1:number_of_repetitions
            load([target_directory header '_' num2str(i) '.mat']);
%     if size(results_sin{j,k},1) == 20
%         results_sin{j,k} = results_sin{j,k}(1:17, :);
%     end
            y_sin(:,:,i) = results_sin{j,k};
        end

        x_results_sin{j,k} = mean(y_sin, 3);
        x_results_sin_std{j,k} = std(y_sin, [], 3);
    end
end

results_sin = x_results_sin;
results_sin_std = x_results_sin_std;




clear x_results_slo;
clear x_results_slo_std;
clear x_results_sin;
clear x_results_sin_std;
clear x_lla_sin;
clear x_lla_sin_std;
clear x_sin
clear y_slo
clear y_sin
clear header
clear i
clear j
clear k

lla_str = mean(x_str, 2);
lla_str_std = std(x_str, [], 2);

lla_slo = squeeze(mean(x_slo, 3));
lla_slo_std = std(x_slo, [], 3);

results_str = mean(y_str, 3);
results_str_std = std(y_str, [], 3);

clear x_str
clear x_slo
clear y_str
clear number_of_repetitions