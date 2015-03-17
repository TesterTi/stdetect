function [tpr, fpr] = test_Nayar

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Method used in Chapter 3, recreates the Nayar detector's results 
%   presented in Figure 3.12
%
%   temp results are stored under the directory
%   %path%\results\nayar\
%   and will require approximately 2GB of available disk space, the files
%   contained within this folder can be deleted after completion.
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


THRESHOLDS = 0:0.1:10;

windowsize = 21;

fprintf('Finding max value...');
max_val = findMax;
fprintf('done\n');

[projected_windowset, pcvec, coarse_to_fine] = buildManifold(windowsize, windowsize);

% Calculate responses
test_Nayar_Tests_Stage1(max_val, projected_windowset, pcvec, coarse_to_fine);

[tpr, fpr] = test_Nayar_Tests_Stage2(THRESHOLDS, windowsize);

save(['.' filesep 'test_scripts' filesep 'results' filesep 'nayar_tpr_fpr'], 'tpr', 'fpr');

% Plot Output
figure, plot(fpr, tpr, '-r');
axis([0 1 0 1]);
title('Parametric ROC Curve');
xlabel('False Positive Rate');
ylabel('True Positive Rate');