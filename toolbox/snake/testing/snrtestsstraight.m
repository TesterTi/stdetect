function [results_straight, lla_straight, lla_straight_temp] = snrtestsstraight(external, perrin, single)

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



path = [getDataPath 'test_set' filesep 'V' filesep];

SNR = [8:-0.5:0];

p = snake_param;
if perrin
    p = set(p, 'InternalEnergy', 'Perrin');
else
    p = set(p, 'InternalEnergy', 'Original');
end


if strcmpi(external, 'pca')
    if perrin
        % perrin pca
        p = set(p, 'Beta', .16);
        p = set(p, 'WalkRate', .36);
        p = set(p, 'Gamma', 1);
    else
        % original pca
        p = set(p, 'Beta', .22);
        p = set(p, 'WalkRate', .36);
        p = set(p, 'Gamma', 1);
        p = set(p, 'Alpha', 0.96);

	if exist('single', 'var') && single == 1
    	    p = set(p, 'WalkRate', .72);  % for single contour
	end
    end
else
    if perrin
        %Perrin intensity
        p = set(p, 'Beta', 1.00);
        p = set(p, 'WalkRate', 0.54);
        p = set(p, 'Gamma', .8);
    else
        % original intensity
        p = set(p, 'Beta', .66);
        p = set(p, 'WalkRate', .18);
        p = set(p, 'Gamma', .82);
        p = set(p, 'Alpha', .5);
    end
end



results_straight = zeros(17, 3);
lla_straight     = zeros(1, 17);

SNR_index = 0;
out_of_range = [ceil(p.windowHeight/2)+(p.snakeLength/2), floor(p.windowHeight/2)+ceil(p.snakeLength/2)-1];
for real = [-1:0.5:7]

    fprintf('SNR: %.2f', real);
    
    SNR_index = SNR_index + 1;
    
    slopes = [1, 2, 4, 8, 16];
    
    count = 0;
    lla_straight_temp = [];
    results_straight_temp = [];
    for j = 1:10
        for i = 1:numel(SNR)
            %for s = 1:numel(slopes)
            for s = 1:1
                
                spectrogram = load_Spectrogram([path 'ip_test_data_P1_V_' num2str(slopes(s)) '_' num2str(SNR(i)) '_' num2str(j) '.dat'], 1);
                
                if round(spectrogram.snr * 2)/2 == real
                    count = count + 1;

                    d = analyse_Spectrogram(spectrogram, external, [], p);
                    
                    [spectrogram.template, d] = extract_fundamental(spectrogram.template, d);
                    
                    if slopes(s) ~= 16
                        [temp_results, temp_lla]       = testmetrics(d(201:spectrogram.size(1)-out_of_range(2), :), spectrogram.template(201:spectrogram.size(1)-out_of_range(2), :));
                    else
                        [temp_results, temp_lla]       = testmetrics(d(126:spectrogram.size(1)-out_of_range(2), :), spectrogram.template(126:spectrogram.size(1)-out_of_range(2), :));
                    end
                    
                    results_straight_temp(count, :) = temp_results;                    
                    lla_straight_temp(count)       = temp_lla;
                end
                
            end
        end
    end
    
    if count > 0
        lla_straight(SNR_index)  = mean(lla_straight_temp);
        results_straight(SNR_index, :) = mean(results_straight_temp, 1);
    end
    
    if real < 0
        fprintf('\b\b\b\b\b\b\b\b\b\b');
    else
        fprintf('\b\b\b\b\b\b\b\b\b');
    end
end