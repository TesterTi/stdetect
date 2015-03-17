function [tpr, fpr] = test_Bar_multiscale

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Method used in Chapter 3 (Multi-scale Bar detector)
%   recreates the Bar detector's results presented in Figure 3.12
%
%   temp results are stored under the directory
%   .\test_scripts\results\bar_multiscale\
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


lengths = [6, 7, 8, 9, 10, 12, 14, 16, 18, 20];

thresholds = 0:0.5:142;

fprintf('Finding max value...');
max_val = findMax;
fprintf('done\n');

% Calculate bar responses
test_Bar_Tests_Stage1(max_val, lengths);

bars = cell(1, numel(lengths));
for l = 1:numel(lengths)
    bars{l} = create_Bar_Masks(lengths(l), 1, 0:-0.05:-(pi/2));
end

% Calculate detection performance
[tpr, fpr] = test_Bar_Tests_Stage2(bars, lengths, thresholds, max_val);

save(['.' filesep 'test_scripts' filesep 'results' filesep 'bar_multiscale_tpr_fpr'], 'tpr', 'fpr');

% Plot Output
figure, plot(fpr, tpr, '-r');
axis([0 1 0 1]);
axis square;
title('Multi-Scale Bar ROC Curve');
xlabel('False Positive Rate');
ylabel('True Positive Rate');