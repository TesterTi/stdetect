function plot_ROC_harmonic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Plots the Bar and Bar with harmonic transform ROC performance, 
%   presented in Chapter 3, Figure 3.14
%
%   Before running this the results should be calculated using
%   the functions:
%       test_Bar_multiscale
%       test_Bar_multiscale_harmonic
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

% Figure 3.14
load './test_scripts/results/bar_multiscale_tpr_fpr'

figure
plot(fpr, tpr, 'k', 'LineWidth', 0.8);
hold on

load './test_scripts/results/bar_multiscale_harmonic_tpr_fpr'

plot(fpr, tpr, 'r', 'LineWidth', 0.8);

axis([0 1 0 1]);
xlabel('False Positive Rate', 'FontSize', 22);
ylabel('True Positive Rate', 'FontSize', 22);
legend('Original Spectrogram', 'Harmonic Transform', 'Location', 'SouthEast');
axis square

clear all