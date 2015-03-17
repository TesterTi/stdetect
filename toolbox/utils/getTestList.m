function [pathlist, filenamelist] = getTestList()

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


path1 = getDataPath;
count = 1;

PATH = [path1 'test_set' filesep 'V' filesep];
for i = 1:2
    for slope = [1, 2, 4, 8, 16]
        for SNR = 0:0.5:8
            pathlist{count}     = PATH;
            filenamelist{count} = ['ip_test_data_P1_V_' num2str(slope) '_' num2str(SNR) '_' num2str(i) '.dat'];

            count = count + 1;
        end
    end
end

PATH = [path1 'test_set' filesep 'N' filesep];
for i = 1:10
    pathlist{count}     = PATH;
    filenamelist{count} = ['ip_test_data_N_' num2str(i) '_X.dat'];
    
    count = count + 1;
end

sinusoid = {'S10', 'S15', 'S20'};
for j = 1:numel(sinusoid)
    PATH = [path1 'test_set' filesep sinusoid{j} filesep];
    for i = 1:2
        for amplitude = 1:5
            for SNR = 0:0.5:8
                pathlist{count}     = PATH;
                filenamelist{count} = ['ip_test_data_P1_' sinusoid{j} '_' num2str(amplitude) '_' num2str(SNR) '_' num2str(i) '.dat'];

                count = count + 1;
            end
        end
    end
end