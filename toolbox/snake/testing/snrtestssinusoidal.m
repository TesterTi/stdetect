function [results, lla] = snrtestssinusoidal(period, percentage_variance, external, perrin, single)

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



path = [getDataPath 'test_set' filesep 'S' period filesep];

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
        p = set(p, 'Beta', .46);
        p = set(p, 'WalkRate', .68);
        p = set(p, 'Gamma', .8);
    else
        % original intensity
        p = set(p, 'Beta', .66);
        p = set(p, 'WalkRate', .52);
        p = set(p, 'Gamma', .72);
        p = set(p, 'Alpha', .02);
    end
end




results = zeros(17, 3);
lla     = zeros(1, 17);

SNR_index = 0;
out_of_range = [ceil(p.windowHeight/2)+(p.snakeLength/2), floor(p.windowHeight/2)+ceil(p.snakeLength/2)-1];
for real = [-2:0.5:6]
    
    fprintf('SNR: %.2f', real);
    
    SNR_index = SNR_index + 1;
    count = 0;
    for j = 1:10
        for i = 1:numel(SNR)
            spectrogram = load_Spectrogram([path 'ip_test_data_P1_S' period '_' percentage_variance '_' num2str(SNR(i)) '_' num2str(j) '.dat'], 1);
            
            if round(spectrogram.snr * 2)/2 == real
                count = count + 1;
                d = analyse_Spectrogram(spectrogram, external, [], p);
                
                [spectrogram.template, d] = extract_fundamental(spectrogram.template, d);
                
                [temp_results, temp_lla] = testmetrics(d(out_of_range(1):spectrogram.size(1)-out_of_range(2), :), spectrogram.template(out_of_range(1):spectrogram.size(1)-out_of_range(2), :));
                results(SNR_index, :) = results(SNR_index, :) + temp_results;
                lla(SNR_index) = lla(SNR_index) + temp_lla;
            end
        end
    end
    
    if count > 0
        lla(SNR_index) = lla(SNR_index)/count;
        results(SNR_index, :) = results(SNR_index, :)/count;
    end
    
    if real < 0
        fprintf('\b\b\b\b\b\b\b\b\b\b');
    else
        fprintf('\b\b\b\b\b\b\b\b\b');
    end
end