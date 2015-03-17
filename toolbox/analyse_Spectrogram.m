function [reconstructed, nets] = analyse_Spectrogram(spectrogram, transform_type, time_range, p, nets, filters, gaussian)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ANALYSE_SPECTROGRAM todo: Description
%       [RECONSTRUCTED, NETS] = ANALYSE_SPECTROGRAM(I, TRANSFORM_TYPE, TIME_RANGE, P, NETS)
%           Sets up the GUI and executes the analysis, displaying the
%           results.
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

signature_database_filename     = ['@signatureDatabase' filesep 'database.csv']; % Signature database filename
%signature_database_filename     = ['@signatureDatabase' filesep 'database_single.csv']; % Signature database filename

plotexternal                    = 0;	% display the external energy transoform (1) or the original spectrogram (0)

alertthreshold                  = 20;	% Number of pixels before alert

gt                              = 1;

gui                             = 1;	% 1 = Display the GUI, 0 = Do not.

run_c_code                      = 1;	% Use C implementations of external energies (doesn't work on some 32bit systems)

writeavi                        = 0;	% Creates an animation of the display in file AVIFILENAME

avifilename                     = ['vid' filesep 'display.avi']; % sets the filename for the animation

dimensionality                  = 3;    % the dimensionality of the external energy (should put in snake_param)
                    
useadaptivewalkrate             = 0;	% **NOT IMPLEMENTED** Bayesian learning and propagation of track position to the next time step

output                          = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%% CHECK INPUT VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('spectrogram', 'var')
    fprintf(2, 'Error: no spectrogram to analyse!\n');
    reconstructed = [];
    return;
end
if ~isfield(spectrogram, 'z_spec') || isempty(spectrogram.z_spec)
    fprintf(2, 'Error: spectrogram should have a ''z_spec'' field containing the spectrogram values!\n');
    reconstructed = [];
    return;
end
if ~isfield(spectrogram, 't_res') || isempty(spectrogram.t_res)
    fprintf(2, 'Error: spectrogram should have a ''t_res'' field containing the time resolution used!\n');
    reconstructed = [];
    return;
end
if ~isfield(spectrogram, 'f_res') || isempty(spectrogram.f_res)
    fprintf(2, 'Error: spectrogram should have a ''f_res'' field containing the frequency resolution used!\n');
    reconstructed = [];
    return;
end
if ~isfield(spectrogram, 'size') || numel(spectrogram.size) ~= 2|| isempty(spectrogram.size)
    fprintf(2, 'Error: spectrogram should have a ''size'' field specifying the size of the spectrogram!\n');
    reconstructed = [];
    return;
end
%if ~isfield(spectrogram, 'snr')
%    error('Spectrogram should have a ''snr'' field specifying the SNR of the spectrogram!');
%end
if any(size(spectrogram.z_spec) ~= spectrogram.size')
    fprintf(2, 'Error: the spectrogram size does not match the value specified in spectrogram.size!\n');
    reconstructed = [];
    return;
end
if isfield(spectrogram, 'template')
    if any(size(spectrogram.template) ~= spectrogram.size')
        fprintf(2, 'Error: the size of the template and spectrogram do not match!\n');
        reconstructed = [];
    return;
    end
end
if ~exist('transform_type', 'var')
    fprintf(2, 'Error: no potential transformation type specified!\n');
    reconstructed = [];
    return;
end

%%%%%%%%%%%% FINISHED CHECKING INPUT VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%% INITIALISE ENVIRONMENT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% turn the gui off if matlab is started with -nodisplay option
if gui && ~usejava('desktop')
    gui = 0;
end

db = signatureDatabase(signature_database_filename);      % Detection Type Database
if isempty(db)
    fprintf(2, 'Error: an error has occurred reading the signature database.\n');
    fprintf(2, 'Aborting the detection process.\n');
    reconstructed = [];
    return;
end

if ~exist('p', 'var')
    p = snake_param();          % Snake parameter object
end

%make

if spectrogram.size(1)-(p.snakeLength+(p.windowHeight-1))+1 < 1
    errstr = ['Image height must be >= ', num2str((p.snakeLength+(p.windowHeight-1))), ' pixels'];
    error(errstr);
end

if useadaptivewalkrate
    adaptWalkData.mun = mean(p.range);
    adaptWalkData.sign = 100;
    adaptWalkData.maxF = spectrogram.size(2);
    adaptWalkData.walkRate = p.walkRate;
    if p.zerodb == 1
        adaptWalkData.peakHeight = 0.03; % Works for 0dB
    else
        adaptWalkData.peakHeight = 0.00008; %WORKS FOR > 0dB
    end
    %adaptWalkData.peakHeight = 0.09; % Experiment
end

if ~exist('time_range', 'var')
    time_range = [1 size(spectrogram.z_spec, 1)];
else
    if numel(time_range) == 0
        time_range = [1 size(spectrogram.z_spec, 1)];
    end
    if time_range(1) > size(spectrogram.z_spec, 1) || time_range(1) < 1 || time_range(2) > size(spectrogram.z_spec, 1) || time_range(1) < 1
        error('Time range specified is out of the spectrogram limits');
    end
end


if ~exist('nets', 'var')
    nets = train_Classifiers(p, dimensionality);                % Use to train classifiers using synthetic data
    %[nets, p] = train_Classifiers_REAL(p);                     % Use to train classifiers using real data
    
    % check that an error has not occurred while training the system.
    if isempty(nets)
        reconstructed = [];
        return;
    end
end

reconstructed = zeros(spectrogram.size');
detectionTypeCounts = zeros(2+getNumberOfTypes(db));

%%%%%%%%%%%% FINISHED INITIALISING ENVIRONMENT %%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%% TRANSFORMING SPECTROGRAM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if output
    fprintf('Applying External Energy...');
end

spectrogramimage = log(spectrogram.z_spec);

switch lower(transform_type)
   case 'bar'
       if run_c_code
           %C code
           spectrogram.z_spec = bar_convolution(scale(spectrogram.z_spec, 1, 255), create_Bar_Masks(21));
       else
           %Matlab code
           spectrogram.z_spec = bar_convolution_matlab(scale(spectrogram.z_spec, 1, 255), create_Bar_Masks(21));
       end
       
       p = set(p, 'WindowOffset', 1);
   case 'pca'
       
       if ~exist('filters', 'var')
           if exist('nets', 'var')
               filters = nets{2}.filters;
           else
               filters = train_PCA_filters(p, dimensionality);
           end
       end
       
       if ~exist('gaussian', 'var')
           if exist('nets', 'var')
               gaussian = nets{2}.gaussian;
           else
               gaussian = train_Gauss(filters, p);
           end
       end
       
       % check that an error has not occurred while training the system.
       if isempty(gaussian) || isempty(filters)
           reconstructed = [];
           return;
       end
           
       clear 'trdata' 'trgt'
       
       if run_c_code
           try 
               %C code
               convolved_images = pca_convolution(spectrogram.z_spec, filters);
               spectrogram.z_spec = pca_gaussian(convolved_images, gaussian, filters);
           catch e
               if strcmp(e.identifier, 'MATLAB:UndefinedFunction')
                   fprintf(2, 'Warning: could not invoke the mex functions ''pca_convolution'' and ''pca_gaussian''.\n');
                   fprintf(2, 'Continuing with Matlab implementations, this will be slower.\n');
               else
                   rethrow(e);
               end
               %Matlab code
               convolved_images = pca_convolution_matlab(spectrogram.z_spec, filters);
               spectrogram.z_spec = pca_gaussian_matlab(convolved_images, gaussian, filters);
           end
       else
           %Matlab code
           convolved_images = pca_convolution_matlab(spectrogram.z_spec, filters);
           spectrogram.z_spec = pca_gaussian_matlab(convolved_images, gaussian, filters);
       end
       
       p = set(p, 'WindowOffset', 2);
       
       %spectrogram.z_spec(spectrogram.z_spec <= p.treshold) = 1-(spectrogram.z_spec(spectrogram.z_spec <= p.treshold);
       %spectrogram.z_spec(spectrogram.z_spec > p.threshold) = 1;
    case 'intensity'
        spectrogram.z_spec = scale(spectrogram.z_spec, 1, findMax);
        p = set(p, 'WindowOffset', 1);
    otherwise
        error('Transformation type unknown!');
end

if plotexternal
    spectrogramimage = spectrogram.z_spec;
end

if output
    fprintf('Done\n');
end

%%%%%%%%%%%% FINISHED TRANSFORMING SPECTROGRAM %%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%% INITIALISE GUI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if gui
    rowTitle = ['Un ';'No '];
    columnTitle = [' Un No'];
    for i = getNumberOfTypes(db):-1:1
        rowTitle = [['T', num2str(i), ' ']; rowTitle];
        columnTitle = [['T', num2str(i), ' '], columnTitle];
    end
    columnTitle = ['    ', columnTitle];
    
    f1 = figure;
    scrsz = get(0,'ScreenSize');
    %set(f1, 'Position', [5 5 scrsz(3) scrsz(4)]);
    set(f1, 'Position', [5+scrsz(3)/4.7 (scrsz(4)-(scrsz(4)/1.15)) 2*(scrsz(3)/3) 2.3*(scrsz(4)/3)]);
    set(f1, 'Name', 'Spectrogram Detection', 'DockControls', 'off', 'Toolbar', 'none', 'MenuBar', 'none');
    
    a1 = axes('Position', [0.04 0.4 0.94 0.56]);
    hold on;
    i1 = imagesc((0:spectrogram.size(2))*spectrogram.f_res, (0:spectrogram.size(1))*spectrogram.t_res, spectrogramimage);
    axis xy;
    axis([1 spectrogram.size(2)*spectrogram.f_res 1 spectrogram.size(1)*spectrogram.t_res]);
    title('Detected Features');
    xlabel('Frequency (Hz)');
    ylabel('Time (sec)');
    colormap gray;
    p1 = plot(-1, -1, '.r', 'MarkerSize', 3);
    l1 = plot([1,spectrogram.size(2)], [0,0], 'g');
    l2 = plot([0,0], [0,0], 'r');
    hold off
    
    
    if useadaptivewalkrate
        %b1 = annotation('textbox', 'Position', [.001 .95 .02, .05], 'String', [{'Adaptive WalkRate'},{'Parameters'},{strcat('     \mu = ', num2str(adaptWalkData.mun))},{strcat('     \sigma = ', num2str(adaptWalkData.sign))}, {strcat('Peak = ', num2str(adaptWalkData.peakHeight))}], 'FitBoxToText', 'On');
        b1 = annotation('textbox', 'Position', [.001 .95 .02, .05], 'String', [{'Adaptive WalkRate'},{'Parameters'},{strcat('     \mu = ', num2str(adaptWalkData.mun))},{strcat('     \sigma = ', num2str(adaptWalkData.sign))}, {strcat('Peak = ', num2str(adaptWalkData.peakHeight))}]);
    end
    %b3 = annotation('textbox', 'Position', [.001 .4 .02, .05], 'String', [{'Snake Parameters'},{strcat('      Length = ', num2str(p.snakeLength))},{strcat('    Forward = ', num2str(p.forward))}, ...
    %    {strcat(' Walk Rate = ', num2str(p.walkRate))}, {strcat('              \alpha = ', num2str(p.alpha))}, {strcat('              \beta = ', num2str(p.beta))}, ...
    %    {strcat('               \gamma = ', num2str(p.gamma))}, {strcat('Corr Weight = ', num2str(p.corrWeight))}, {strcat('    W Width = ', num2str(p.windowWidth))}, {strcat('   W Height = ', num2str(p.windowHeight))}, {strcat(' Harmony # = ', num2str(p.harmonyNumber))}], 'FitBoxToText', 'On');

    %figure,
    %p1 = surf((min(p.range):1/(p.harmonyNumber+1):max(p.range)), [1:2], ones(2,((max(p.range) - min(p.range))*(p.harmonyNumber+1))+1)*p.walkRate);

    annotation(f1, 'textbox', 'Position', [0.01 0.01 0.48 0.32]);
    a2 = axes('Position', [0.05 0.06 0.42 0.23]);
    hold on;
    histogram = zeros(1, spectrogram.size(2));
    alert = zeros(size(histogram));
    i2 = bar(spectrogram.f_res:spectrogram.f_res:(spectrogram.size(2)*spectrogram.f_res), histogram*spectrogram.t_res, 'g');
    hold on;
    plot([1, spectrogram.size(2)*spectrogram.f_res], [alertthreshold, alertthreshold], 'r');
    i3 = bar(spectrogram.f_res:spectrogram.f_res:(spectrogram.size(2)*spectrogram.f_res), alert, 'r');
    xlabel('Frequency (Hz)');
    ylabel('Frequency of Detection (seconds)');
    title('Cumulative Detection Over Time');
    axis([1 spectrogram.size(2)*spectrogram.f_res 0 spectrogram.size(1)*spectrogram.t_res]);
    hold off;
    %pause(1);

    
    annotation(f1, 'textbox', 'Position', [0.51 0.01 0.48 0.32]);
    annotation(f1, 'textbox', 'Position', [0.68 0.28 0.35 0.05], 'String', 'Current Time Step Classification', 'LineStyle', 'none');
    b6 = annotation(f1, 'textbox', 'Position', [0.52 0.24 0.2 0.05], 'String', 'Current Detection: ', 'LineStyle', 'none');
    b2 = annotation(f1, 'textbox', 'Position', [0.52 0.02 0.25 0.23], 'String', ' ', 'FontSize', 16, 'Color', [0 1 0], 'VerticalAlignment', 'middle');
    
    annotation(f1, 'textbox' ,'Position', [0.79 0.24 0.2 0.05], 'String', 'Last Positive Detection:', 'LineStyle', 'none');
    b5 = annotation(f1, 'textbox' ,'Position', [0.79 0.18 0.19 0.07], 'String', 'None', 'VerticalAlignment', 'middle');
    
    annotation(f1, 'textbox', 'Position', [0.79 0.125 0.2 0.05], 'String', 'Confusion Matrix: ', 'LineStyle', 'none');
    b4 = annotation(f1, 'textbox', 'Position', [0.79 0.02 0.19 0.12], 'String', {columnTitle, [rowTitle, num2str(detectionTypeCounts)]}, 'VerticalAlignment', 'middle');

    if writeavi
        aviobj = avifile(avifilename, 'fps', 25, 'compression', 'none');
        frame = getframe(f1);
        aviobj = addframe(aviobj, frame);
    end
end

%%%%%%%%%%%% FINISHED INITIALISING GUI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%% START DETECTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%p1 = dialog('Position', [scrsz(3)/2+5 20 scrsz(3)/2 (scrsz(4)/3.5)], 'WindowStyle', 'normal');
x = [];
y = [];
%for i = 1:p.snakeLength:spectrogram.size(1)-(p.snakeLength+(p.windowHeight-1))+1

if output
    fprintf('Performing Detection...');
end

for i = time_range(1):time_range(2)-(p.snakeLength+(p.windowHeight-1))+1
    %fprintf('Time step: %d\n', i+((p.windowHeight-1)/2));
    %set(l1, 'YData', [i+((p.windowHeight-1)/2), i+((p.windowHeight-1)/2)]);
    if gui
        set(l1, 'YData', [(i+((p.windowHeight-1)/2)+ p.snakeLength/2)*spectrogram.t_res, (i+((p.windowHeight-1)/2)+ p.snakeLength/2)*spectrogram.t_res]);
        set(l2, 'YData', [(i+((p.windowHeight-1)/2)+ p.snakeLength/2)*spectrogram.t_res, (i+((p.windowHeight-1)/2)+ p.snakeLength/2)*spectrogram.t_res]);
    end
    
    if p.movingMean
        nets = updateGaussianMean(spectrogram.z_spec(i:i+p.snakeLength+(p.windowHeight-1)-1, :), nets);
    end
    
    foundintimestep = cell(0);
    foundcount = 0;
    for patternIndex = 1:getNumberOfTypes(db)
        %   range is returned as frequency need to convert to pixels
        temp_range = (getRange(db, patternIndex))*(1/spectrogram.f_res);
        p = set(p, 'Range', [floor(temp_range(1)) ceil(temp_range(2))]);
        h = getHarmonicSet(db, patternIndex);
        h = h(logical(getHarmonicMask(db, patternIndex)));
        p = set(p, 'HarmonyNumber', numel(h));
        p = set(p, 'HarmonicSet', h);
        %p = set(p, 'Range', [50, 150]);
        
        if gui
            set(l2, 'XData', min(p.range, max(p.range)));
            pause(0.07)
        end
        
        found = [];
        if useadaptivewalkrate
            adaptWalkData.found = found;
            if gui
                set(b1, 'String', [{'Adaptive WalkRate'},{'Parameters'},{strcat('     \mu = ', num2str(adaptWalkData.mun))},{strcat('     \sigma = ', num2str(adaptWalkData.sign))}, {strcat('Peak = ', num2str(adaptWalkData.peakHeight))}]);
            end
            
            
            %[snakeDetections, nets, adaptWalkData] = recursivesnake(spectrogram.z_spec(i:end,:), p, nets, adaptWalkData);
            [snakeDetections, nets, adaptWalkData] = recursivesnake(spectrogram.z_spec(i:i+p.snakeLength+(p.windowHeight-1)-1, :), p, nets, adaptWalkData);
        else
            %[snakeDetections, nets] = recursivesnake(spectrogram.z_spec(i:end,:), p, nets);
            [snakeDetections, nets] = recursivesnake(spectrogram.z_spec(i:i+p.snakeLength+(p.windowHeight-1)-1, :), p, nets);
        end
        
        if snakeDetections == -1
            reconstructed = [];
            return;
        end
        
        if ~isempty(snakeDetections)
            snakeDetections(:, 1) = snakeDetections(:, 1) +1;
            
            foundcount = foundcount + 1;
            foundintimestep{foundcount}.positions = snakeDetections;
            foundintimestep{foundcount}.signatureIndex = patternIndex;
        end
    end
    
    if gui
        set(b6, 'String', ['Current Detection (@ ' num2str((i+((p.windowHeight-1)/2)+ p.snakeLength/2) * spectrogram.t_res, '%2.1f') 's): ']);
    end
    if foundcount ~= 0
        % Take whole snake as detection; no overlap
        %reconstructed(i+((p.windowHeight-1)/2):i+((p.windowHeight-1)/2)+p.snakeLength, :) = d(((p.windowHeight-1)/2)+1:p.snakeLength+((p.windowHeight-1)/2)+1, :);
        % Use first point on snake as position for 1 time step
        %reconstructed(i+((p.windowHeight-1)/2), :) = d(((p.windowHeight-1)/2)+1, :);
        % Use average position as middle detection
        
        fundamentalCount = 0;
        fundamentals = [];
        
        for foundIndex = 1:foundcount
            hMask = getHarmonicMask(db, foundintimestep{foundIndex}.signatureIndex);
            for j = 1:size(foundintimestep{foundIndex}.positions, 3)
                fundamentalCount = fundamentalCount + 1;
                %xpos = mean(foundintimestep{foundIndex}.positions(:,1,j))-0.6;
                xpos = mean(foundintimestep{foundIndex}.positions(:,1,j))-0.8;
                %xpos = mean(foundintimestep{foundIndex}.positions(:,1,j));
                %xpos = min(foundintimestep{foundIndex}.positions(:,1,j))
                %xpos = foundintimestep{foundIndex}.positions(round(p.snakeLength/2),1,j)-0.8;
                ypos = i+((p.windowHeight-1)/2)+round(p.snakeLength/2);
                h = harmonies(xpos, getHarmonicSet(db, foundintimestep{foundIndex}.signatureIndex));
                fundamentals(fundamentalCount) = h(1);
                h = round(h);
                
                if gui
                    histogram(h(1)) = histogram(h(1)) + 1;
                end
                
                for k = 1:1%numel(h)
                    if hMask(k)
                        reconstructed(ypos, h(k)) = 1;
                        x = [x, h(k)];
                        y = [y, ypos];
                    end
                end
                
            end
        end
        
        if gui
            [detectstr, detectionTypeCounts] = recogniseDetection(db, fundamentals*spectrogram.f_res, detectionTypeCounts, gt);
            set(b5, 'String', strcat(detectstr, [' @ ' num2str((i+((p.windowHeight-1)/2)+ p.snakeLength/2)*spectrogram.t_res, '%2.1f')], 's'), 'VerticalAlignment', 'middle');
            set(b2, 'String', detectstr, 'Color', [1 0 0], 'VerticalAlignment', 'middle');
        end
    else
        if gui
            detectionTypeCounts(gt, end) = detectionTypeCounts(gt, end) + 1;
            set(b2, 'String', 'No Detection', 'Color', [0 1 0], 'VerticalAlignment', 'middle');
            %'FitBoxToText', 'On', 
        end
    end

    if gui
        set(b4, 'String', {columnTitle, [rowTitle, num2str(detectionTypeCounts)]});
        %set(i1, 'CData', reconstructed);
        %set(i1, 'CData', spectrogram.z_spec);
        set(i1, 'CData', spectrogramimage);
        
        if ~isempty(y) && ~isempty(x)
            set(p1, 'XData', x*spectrogram.f_res);
            set(p1, 'YData', y*spectrogram.t_res);
        end

        set(i2, 'YData', histogram*spectrogram.t_res);
        if ~isempty(histogram(histogram >= alertthreshold))
            alert(histogram >= alertthreshold) = histogram(histogram >= alertthreshold);
            set(i3, 'YData', alert);
        end
        pause(0.05);
        
        if writeavi
            frame = getframe(f1);
            aviobj = addframe(aviobj, frame);
        end
    end
    
end

if gui
   set(l1, 'YData', [0,0]);
   set(l2, 'YData', [0,0]);
   set(b2, 'String', '');
end

if output
    fprintf('Done\n');
end

%%%%%%%%%%%% FINISHED DETECTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%% START TRACK ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%regionlabelled = regiongrow(reconstructed);
%fprintf('Number of regions found %d\n', max(max(regionlabelled)));

% pathAnalysis(spectrogram.z_spec, regionlabelled);
% 
% [overall_perc, noise_perc, signal_perc, msqerr, RNumberRatio, averageRegionCount] = pixel_classification_measure(reconstructed, spectrogram.template);
% 
% if gui
%    outputstring = {strcat('Overall Pixel Classification = ', num2str(overall_perc)),...
%                    strcat('Noise Pixel Classification = ', num2str(noise_perc)),...
%                    strcat('Signal Pixel Classification = ', num2str(signal_perc)),...
%                    strcat('Mean Square Distance = ', num2str(msqerr), ' pixels'),...
%                    strcat('Region Number Ratio = ', num2str(RNumberRatio)),...
%                    strcat('Average Region Count = ', num2str(averageRegionCount))};
% 
%    figure('Name', 'Display Panel', 'Position', [(scrsz(3)/2)-180 (scrsz(4)/2)-120 360 240], 'DockControls', 'off','MenuBar', 'none', 'Toolbar', 'none', 'Resize', 'off');
% 
%    annotation('textbox', 'Position', [0.1 0.9 .8, .1], 'String', 'Track Detection Score', 'LineStyle', 'none', 'HorizontalAlignment', 'center');
%    annotation('textbox', 'Position', [0.1 0.1 .8, .65], 'String', outputstring, 'VerticalAlignment', 'middle');
% end

%%%%%%%%%%%% FINISHED TRACK ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%