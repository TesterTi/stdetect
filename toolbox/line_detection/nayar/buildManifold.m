function [projected_windowset, pcvec, coarse_to_fine, mask] = buildManifold(x_size, y_size)

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

subspace_dim = 8;


tic

    %%%%%%%%%%%%%%%%%%%%%%%%%
    % Create training set
    %%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('Compiling data set...\n');
    coarse_to_fine = cell(coarse_to_fine_level,1);
    
    %%%%%%%%%%%%%%%%%%%%%%
    % Same model as Bar detector
    %   Need to edit parametric_detect.m if changed
    %%%%%%%%%%%%%%%%%%%%%%
    net = create_Bar_Masks(x_size, 1, 0:-0.05:-(pi/2));
    mask = sum(net.templates, 3);
    mask(mask > 0) = 1;
    num_mask_elements = numel(mask(mask > 0));
    
    for i = 0:(coarse_to_fine_level-1)
        fprintf(['Level: ' num2str(i+1) '\n']);
        count = 1;
        windowset = [];
        for width = 1
            Th = 0:-0.05*(coarse_to_fine_level-i):-(pi/2);
            
            windows = create_Bar_Masks(x_size, width, Th);
            
            for j = 1:size(windows.templates, 3)
                window = windows.templates(:,:,j);
                windowset(count, :) = reshape(window(mask > 0), 1, num_mask_elements);
                
                count = count + 1;
            end
        end
        coarse_to_fine{i+1} = windowset;
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % Model as described by Nayar et al.
    %   Need to edit parametric_detect.m if changed
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
%     A = 10;
%     B = 20;
%     s = 0;
%     
%     mask = diskmask(x_size, y_size);
%     num_mask_elements = numel(mask(mask > 0));
%     for i = 0:(coarse_to_fine_level-1)
%         fprintf(['Level: ' num2str(i+1) '\n']);
%         count = 1;
%         windowset = [];
%         for p = 0
%             for w = 1
%                 for Th = 0:2.8648*(coarse_to_fine_level-i):90
%                     vector = [A, B, Th * (pi/180), p, w, s];
%                     
%                     window = parametricline(vector, x_size, y_size);
%                     imagesc(window), pause
%                     %%% Full window
%                     %windowset(count, :) = reshape(window, 1, x_size*y_size);
%                     
%                     % Circular window (according to mask)
%                     windowset(count, :) = reshape(window(mask > 0), 1, num_mask_elements);
%                     
%                     %%% Full window with 0 where mask is not true
%                     %windowset(count, :) = reshape(window .* mask, 1,x_size*y_size);
% 
%                     %windows(:,:,count) = window .* mask;
%                     count = count + 1;
%                 end
%             end
%         end
%         coarse_to_fine{i+1} = windowset;
%     end
   

    
    
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

    pcvec = pcvec(:,1:subspace_dim);
    
    %save('last_built_manifold', 'projected_windowset', 'pcvec', 'coarse_to_fine');

toc
