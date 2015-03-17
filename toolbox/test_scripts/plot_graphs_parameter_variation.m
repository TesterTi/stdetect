function plot_graphs_parameter_variation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Plots the Parameter variation figures presented in Chapter 5
%
%   Before running this the results should be calculated using
%   the functions:
%       parameter_test_run_original_pca
%       parameter_test_run_perrin_pca
%       parameter_test_run_original_intensity
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

% Figure 5.3(a)
load './test_scripts/results/results_parameter_tests_original_pca.mat'

figure
subplot(2,1,1), plot([0:1/50:1], mean(line_location_results_alpha, 2), 'k', 'LineWidth', 0.8);
hold on
subplot(2,1,1), plot([0:1/50:1], mean(line_location_results_beta, 2), 'b', 'LineWidth', 0.8);
plot([0:1/50:1], mean(line_location_results_gamma, 2), 'r', 'LineWidth', 0.8);
plot([0:1/50:1], mean(line_location_results_walkrate, 2), 'g', 'LineWidth', 0.8);
axis([0 1 0 0.5]);
xlabel('Paramter Value', 'FontSize', 22);
ylabel('LLA', 'FontSize', 22);
legend('Alpha', 'Beta', 'Gamma', 'c');


clear all


% Figure 5.3(b)
load './test_scripts/results/results_parameter_tests_perrin_pca'

figure
subplot(2,1,1), plot([0:1/50:1], mean(line_location_results_beta, 2), 'b', 'LineWidth', 0.8);
hold on
plot([0:1/50:1], mean(line_location_results_gamma, 2), 'r', 'LineWidth', 0.8);
plot([0:1/50:1], mean(line_location_results_walkrate, 2), 'g', 'LineWidth', 0.8);
axis([0 1 0 0.4]);
xlabel('Paramter Value', 'FontSize', 22);
ylabel('LLA', 'FontSize', 22);
legend('Beta', 'Gamma', 'c');


clear all


% Figure 5.9
load './test_scripts/results/results_parameter_tests_original_intensity'

figure
subplot(2,1,1), plot([0:1/50:1], mean(line_location_results_alpha, 2), 'k', 'LineWidth', 0.8);
hold on
subplot(2,1,1), plot([0:1/50:1], mean(line_location_results_beta, 2), 'b', 'LineWidth', 0.8);
plot([0:1/50:1], mean(line_location_results_gamma, 2), 'r', 'LineWidth', 0.8);
plot([0:1/50:1], mean(line_location_results_walkrate, 2), 'g', 'LineWidth', 0.8);
axis([0 1 0 0.2]);
xlabel('Paramter Value', 'FontSize', 22);
ylabel('LLA', 'FontSize', 22);
legend('Alpha', 'Beta', 'Gamma', 'c');

clear all


% Figure 5.13
load './test_scripts/results/results_parameter_tests_original_pca_single'

figure
subplot(2,1,1), plot([0:1/50:1], mean(line_location_results_walkrate, 2), 'g', 'LineWidth', 0.8);
axis([0 1 0 0.5]);
xlabel('Paramter Value', 'FontSize', 22);
ylabel('LLA', 'FontSize', 22);
legend('c');

clear all