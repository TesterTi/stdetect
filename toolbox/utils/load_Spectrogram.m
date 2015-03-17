function [spectrogram] = load_Spectrogram(filename, loadTemplate)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   LOAD_SPECTROGRAM todo:description
%       [spectrogram] = LOAD_SPECTROGRAM(FILENAME, LOADTEMPLATE)
%       
%
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

if isempty(filename)
    fprintf(2, 'Error: filename must be specified\n');
    spectrogram.z_spec = [];
end

filename = strrep(filename, '\', filesep);

try 
    [fid_in, msg] = fopen(filename,'r','l');
catch e
    fprintf(2, 'Error: file %s cannot be opened!\n', filename);
    spectrogram.z_spec = [];
    return;
end

if fid_in < 0
    fprintf(2, 'Error: file %s cannot be opened!\n', filename);
    fprintf(2, 'The following error message was returned: %s.\n', msg);
    spectrogram.z_spec = [];
    return;
else
    % Spectrogram File Structure:
    %   1. Dimensions (t,f) 2 x 'uint32'
    %   2. Frequency Resolution 1 x 'float32'
    %   3. Time Resolution 1 x 'float32'
    %   4. Spectrogram Data t x f x 'float32'
    
    try
        size = fread(fid_in,2,'uint32');
        if isempty(size) || numel(size) ~= 2
            throw(MException('load_Spectrogram:invalidSizeFormat', 'Invalid format'));
        end
            
        f_res = fread(fid_in,1,'float32');
        if isempty(f_res)
            throw(MException('load_Spectrogram:invalidF_resFormat', 'Invalid format'));
        end
        
        t_res = fread(fid_in,1,'float32');
        if isempty(t_res)
            throw(MException('load_Spectrogram:invalidT_resFormat', 'Invalid format'));
        end
        
        z_spec = fread(fid_in, [size(1),size(2)], 'float32');
        if isempty(z_spec)
            throw(MException('load_Spectrogram:invalidZ_specFormat', 'Invalid format'));
        end
    catch e
        fprintf(2, 'Error: could not read the spectrogram''s ');
        switch e.identifier
            case 'load_Spectrogram:invalidSizeFormat'
                fprintf(2, 'size properties');
            case 'load_Spectrogram:invalidF_resFormat'
                fprintf(2, 'frequency resolution property');
            case 'load_Spectrogram:invalidT_resFormat'
                fprintf(2, 'time resolution property');
            case 'load_Spectrogram:invalidZ_specFormat'
                fprintf(2, 'values');
        end
        fprintf(2, ', aborting operation.\n');
        spectrogram.z_spec = [];
        fclose(fid_in);
        return;
    end
    
    fclose(fid_in);
    
    spectrogram.size = size;
    spectrogram.f_res = f_res;
    spectrogram.t_res = t_res;
    spectrogram.z_spec = z_spec;
    % REMOVE FIRST COLUMN TO CORRECT HARMONIC RELATIONSHIP
    %z_spec = z_spec(:,2:end);
    
    if loadTemplate
        filename = strrep(filename, '\', filesep);
        filename = strrep(filename, '/', filesep);
        
        % Load corresponding template
        t = find(filename == filesep);
        if ~isempty(t)
            path = [filename(1:t(end)), 'templates', filesep];
        end
        
        search_string = 'ip_test_data_';
        t  = strfind(filename, search_string);
        t2 = strfind(filename, '_');
        if ~isempty(t) && ~isempty(t2)
            filename = filename(t+numel(search_string):t2(end-1)-1);
        end
        
        try
            load([path 'template_' filename]);
            
            % REMOVE FIRST COLUMN TO CORRECT HARMONIC RELATIONSHIP
            %template = template(:, 2:end);
            
            spectrogram.template = template;
            
            SNR = get_SNR(spectrogram);
            spectrogram.snr = SNR;
        catch e
            fprintf(2, 'Error: template %s could not be loaded.\n', [path 'template_' filename])
            fprintf(2, 'Returning spectrogram without ground truth information.\n')
            spectrogram.template = [];
            return;
        end
    else
        spectrogram.template = [];
    end
end