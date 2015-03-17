function [projected_windowset, pcvec, coarse_to_fine] = buildManifold(x_size, y_size)

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FEATURE VECTOR CONSTRUCTION
% vector = [A, B, Th, p, w, s]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Window size
%x_size = 13;
%y_size = 13;

coarse_to_fine_level = 1;

tic

if ~exist('last_built_manifold.mat','file')

    A = 10;
    B = 20;
    s = 0;

    subspace_dim = 8;

    %%%%%%%%%%%%%%%%%%%%%%%%%
    % Create training set
    %%%%%%%%%%%%%%%%%%%%%%%%%

    mask = diskmask(x_size, y_size);
    num_mask_elements = numel(mask(mask > 0));
    fprintf('Compiling data set...\n');
    coarse_to_fine = cell(coarse_to_fine_level,1);
    for i = 0:(coarse_to_fine_level-1)
        fprintf(['Level: ' num2str(i+1) '\n']);
        count = 1;
        windowset = [];
        for p = 0
            for w = 1
                for Th = 0:2.8648*(coarse_to_fine_level-i):90
                    vector = [A, B, Th * (pi/180), p, w, s];
                    
                    window = parametricline(vector, x_size, y_size);
                    imagesc(window), pause
                    %%% Full window
                    %windowset(count, :) = reshape(window, 1, x_size*y_size);
                    
                    % Circular window (according to mask)
                    windowset(count, :) = reshape(window(mask > 0), 1, num_mask_elements);
                    
                    %%% Full window with 0 where mask is not true
                    %windowset(count, :) = reshape(window .* mask, 1,x_size*y_size);

                    %windows(:,:,count) = window .* mask;
                    count = count + 1;
                end
            end
        end
        coarse_to_fine{i+1} = windowset;
    end
    %save ./parametric/coarse_to_fine_restricted2 'coarse_to_fine';
    %load './line detection/parametric/manifold_data/coarse_to_fine2';
    fprintf('Done\n');


    %%%%%%%%%%%%%%%%%%%%%%%%%
    % Normalise set
    %%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Normalising training set...');
    for j = 1:coarse_to_fine_level
        windowset = coarse_to_fine{j};
        for i = 1:size(windowset, 1)
            windowset(i,:) = normaliseVector(windowset(i,:));
        end
        coarse_to_fine{j} = windowset;
    end
    fprintf('Done\n');


    %%%%%%%%%%%%%%%%%%%%%%%
    % Determine PCA vectors
    %%%%%%%%%%%%%%%%%%%%%%%

    fprintf('Computing Principal Components...');
    [pccoeff, pcvec] = pca(coarse_to_fine{end});
    %[pccoeff, pcvec] = KL(coarse_to_fine{end}(1:2000, :));
    fprintf('Done\n');

    %figure, plot(pcresidue(pccoeff), '.-b');
    %title('PCA Coefficient Values');
    %axis tight;

    figure;
    for i = 1:8
        pcWindow = restoreWindowShape(pcvec(:, i), mask);
        subplot(3,3, i) , imagesc(pcWindow), colormap(gray);
        title(['PC Vector: ', num2str(i)]);
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Project windows into PCA space
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('Projecting training set onto PC vectors...');
    projected_windowset = cell(coarse_to_fine_level,1);
    %fig_handles = zeros(1,numel(coarse_to_fine));
    for i = 1:coarse_to_fine_level
        projected_windowset{i} = coarse_to_fine{i} * pcvec(:,1:subspace_dim);

       fig_handles(i) = figure;
       plot3(projected_windowset{i}(:,1), projected_windowset{i}(:,2), projected_windowset{i}(:,3), '.r');
       title(['Window Vectors Projeted into 3D PCA Space (level ' num2str(i) ')']);
    end
    fprintf('Done\n');


    %%%%%%%%%%%%%%%%
    % Test detection
    %%%%%%%%%%%%%%%%

    % fprintf('Testing detection...');
    % % Create test vector
    % paramvector = [10, 20, 45 * (pi/180), 0, 1, 0];
    % window = parametricline(paramvector, x_size, y_size);
    % figure, imagesc(window .* mask), colormap(gray);
    % title('Window to search for');
    % [vector, mu, v] = normaliseVector(reshape(window(mask > 0), 1, num_mask_elements));
    % vector = vector * pcvec(:,1:subspace_dim);
    % %window = coarse_to_fine{5}(1000, :) * pcvec(:,1:subspace_dim);
    % 
    % % for i = 1:5
    % %     figure(fig_handles(i));
    % %     hold on;
    % %     plot3(window(1), window(2), window(3), '.b');
    % %     hold off;
    % % end
    % 
    % % Search manifold for vector
    % [detected, index] = searchManifold(vector, projected_windowset);
    % 
    % if index ~= -1
    %     % for i = 1:5
    %     %     figure(fig_handles(i));
    %     %     hold on;
    %     %     plot3(detected(1), detected(2), detected(3), '.k');
    %     %     hold off;
    %     % end
    % 
    %     % Pick out closest detected vector from manifold
    %     detectedVector = coarse_to_fine{5}(index, :);
    % 
    %     % Restore normalisation parameters
    %     detectedVector = reverseNormalise(detectedVector, mu, v);
    % 
    %     % Convert vector to window shape
    %     window = restoreWindowShape(detectedVector, mask);
    %     fprintf('Done\n');
    %     figure, imagesc(window), colormap(gray);
    %     title('Detected Feature');
    % end

    pcvec = pcvec(:,1:subspace_dim);
    
    %save('last_built_manifold', 'projected_windowset', 'pcvec', 'coarse_to_fine');

else
    load 'last_built_manifold';
end

toc
