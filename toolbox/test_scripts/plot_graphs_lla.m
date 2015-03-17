
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Plots the LLA figures presented in Chapter 5
%
%   Before running this the results should be calculated using
%   the functions:
%       parameter_test_run_original_pca
%       parameter_test_run_perrin_pca
%       parameter_test_run_original_intensity
%       parameter_test_run_original_pca_single
%   and then the calculate_means.m script should be executed to average the
%   raw results. The results will then be in the workspace ready to be used
%   in this script.
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

figure, subplot(2,1,1), plot([-1:0.5:7], lla_str, 'LineWidth', 0.8);
axis([-1 7 0 1]);
%title(['Vertical Performance ' title_Str], 'FontSize', 22);
xlabel('SNR (dB)', 'FontSize', 22);
ylabel('LLA', 'FontSize', 22);






figure, subplot(2,1,1), subplot(2,1,1), plot([-1:0.5:7], lla_slo, 'LineWidth', 0.8);
axis([-1 7 0 1]);
%title(['Oblique Performance ' title_Str], 'FontSize', 22);
xlabel('SNR (dB)', 'FontSize', 22);
ylabel('LLA', 'FontSize', 22);
legend({'1 Hz/s', '2 Hz/s', '4 Hz/s', '8 Hz/s', '16 Hz/s'}, 'FontSize', 30 , 'Location', 'NorthWest');







figure, subplot(2,1,1), 
plot([-1.5:0.5:6], squeeze(lla_sin(1,2:end,1)), 'r', 'LineWidth', 0.8);
hold on
plot([-2:0.5:6], squeeze(lla_sin(1,:,2:3)), 'LineWidth', 0.8);
plot([-2:0.5:5.5], squeeze(lla_sin(1,1:end-1, 4)), 'k', 'LineWidth', 0.8);
plot([-2:0.5:5], squeeze(lla_sin(1,1:end-2, 5)), 'c', 'LineWidth', 0.8);
hold off
axis([-2 6 0 1]);
%title(['10 Sec. Period Sinusoidal Performance ' title_Str], 'FontSize', 22);
xlabel('SNR (dB)', 'FontSize', 22);
ylabel('LLA', 'FontSize', 22);
legend({'1\%', '2\%', '3\%', '4\%', '5\%'}, 'FontSize', 30 , 'Location', 'NorthWest');


figure, subplot(2,1,1)
plot([-1.5:0.5:6], squeeze(lla_sin(2,2:end,1)), 'c', 'LineWidth', 0.8);
hold on
plot([-1.5:0.5:6], squeeze(lla_sin(2,2:end,2)), 'k', 'LineWidth', 0.8);
plot([-2:0.5:6], squeeze(lla_sin(2,:,3:end)), 'LineWidth', 0.8);
hold off
axis([-2 6 0 1]);
%title(['15 Sec. Period Sinusoidal Performance ' title_Str], 'FontSize', 22);
xlabel('SNR (dB)', 'FontSize', 22);
ylabel('LLA', 'FontSize', 22);
legend({'1\%', '2\%', '3\%', '4\%', '5\%'}, 'FontSize', 30, 'Location', 'NorthWest' );


figure, subplot(2,1,1)
plot([-2:0.5:6], squeeze(lla_sin(3,:,1)), 'k', 'LineWidth', 0.8);
hold on
plot([-1.5:0.5:6], squeeze(lla_sin(3,2:end,2)), 'c', 'LineWidth', 0.8);
plot([-2:0.5:6], squeeze(lla_sin(3,:,3:end)), 'LineWidth', 0.8);
hold off
axis([-2 6 0 1]);
%title(['20 Sec. Period Sinusoidal Performance ' title_Str], 'FontSize', 22);
xlabel('SNR (dB)', 'FontSize', 22);
ylabel('LLA', 'FontSize', 22);
legend({'1\%', '2\%', '3\%', '4\%', '5\%'}, 'FontSize', 30, 'Location', 'NorthWest' );