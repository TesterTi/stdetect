function plot_ROC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Plots the Bar, Nayar and PCA ROC performance, presented in Chapter 3
%   Figure 3.12
%
%   Before running this the results should be calculated using
%   the functions:
%       test_PCA
%       test_Bar_multiscale
%       test_Bar_fixedscale
%       test_Nayar
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

% Figure 3.12
load './test_scripts/results/nayar_tpr_fpr'

figure
plot(fpr, tpr, 'k', 'LineWidth', 0.8);
hold on

load './test_scripts/results/bar_multiscale_tpr_fpr'

plot(fpr, tpr, 'r', 'LineWidth', 0.8);

load './test_scripts/results/bar_fixedscale_tpr_fpr'

plot(fpr, tpr, 'g', 'LineWidth', 0.8);

load './test_scripts/results/pca_tpr_fpr'

plot(fpr, tpr, 'b', 'LineWidth', 0.8);

axis([0 1 0 1]);
xlabel('False Positive Rate', 'FontSize', 22);
ylabel('True Positive Rate', 'FontSize', 22);
legend('Nayar', 'Bar Multi-Scale', 'Bar Fixed-Scale', 'PCA', 'Location', 'SouthEast');
axis square;

clear all