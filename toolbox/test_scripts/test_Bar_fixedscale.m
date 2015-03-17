function [tpr, fpr] = test_Bar_fixedscale

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Method used in Chapter 3 (Fixed-scale Bar detector).
%   Recreates the Fixed-scale Bar detector's results presented in Figure 3.12
%   if the variable 'thesis' is set to 1 and the performance presented in 
%   the paper "A Detailed Investigation into Low-Level Feature Detection in 
%   Spectrogram Images" if set to 0.
%
%   temp results are stored under the directory
%   .\test_scripts\results\bar_fixedscale\
%   and will require approximately 2GB of available disk space, the files
%   contained within this folder can be deleted after completion.
%
%   Please note that this implementation of the fixed-scale bar detector improves 
%   performance to be greater than that of the multi-scale bar detector. The
%   results presented in the thesis were based upon an older detection mechanism.
%   Please see upcoming paper entitled "A Detailed Investigation into Low-Level 
%   Feature Detection in Spectrogram Images" for further information.
%   To reproduce the results presented in the thesis set the variable
%   'thesis' to 1.
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

thesis = 1;

length = 21;

thresholds = 0:0.5:142;

fprintf('Finding max value...');
max_val = findMax;
fprintf('done\n');

% Calculate bar responses
test_Bar_Tests_Stage1(max_val, length);

bars{1} = create_Bar_Masks(length, 1, 0:-0.05:-(pi/2));

% Calculate detection performance
if thesis
    [tpr, fpr] = test_Bar_Tests_Stage2_thesis(length, thresholds);
else
    [tpr, fpr] = test_Bar_Tests_Stage2(bars, length, thresholds, max_val);
end

save(['.' filesep 'test_scripts' filesep 'results' filesep 'bar_fixedscale_tpr_fpr'], 'tpr', 'fpr');


% Plot Output
figure, plot(fpr, tpr, '-r');
axis([0 1 0 1]);
axis square;
title('Fixed-Scale Bar ROC Curve');
xlabel('False Positive Rate');
ylabel('True Positive Rate');