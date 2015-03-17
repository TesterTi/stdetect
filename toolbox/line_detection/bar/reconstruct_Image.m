function reconstructed = reconstruct_Image(theta, length, intensity, theta_index, length_index, bars, threshold, lengths)

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

reconstructed = zeros(size(intensity));
for g = max(lengths)+1:size(intensity,1)
    for h = max(lengths)+1:size(intensity,2)-min(lengths)
        %fprintf('x: %4d, y: %4d', g, h);
        
        if intensity(g,h) > threshold
            
            reconstructed(g-length(g,h)+1:g, h-length(g,h)+1:h+length(g,h)-1) = ...
                        reconstructed(g-length(g,h)+1:g, h-length(g,h)+1:h+length(g,h)-1) + bars{length_index(g,h)}.templates(:, :, theta_index(g,h));
        end
        
        %fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b');
    end
end
reconstructed(reconstructed > 0) = 1;
%fprintf('finished\n');
    
%figure, imagesc(reconstructed), colormap(gray), title('Bar Full Reconstructed');