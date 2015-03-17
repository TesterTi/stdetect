function [fighandle, imhandle] = plotSpec(spectrogram, titlestr, range)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   PLOTSPEC Plots a spectrogram
%       [FIGHANDLE, IMHANDLE] = PLOTSPEC(DATA, TITLESTR, RANGE) returns a 
%       figure handle and image handle to the spectrogram (DATA) displayed.
%       The optional arguments TITLESTR if exists adds a title to the plot  
%       and RANGE in the form [y1 y2 x1 x2] restricts the plot to the 
%       specied range.
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



fighandle = figure;
colormap(gray);
if exist('range', 'var')
    imhandle = imagesc((range(3)*spectrogram.f_res:range(4))*spectrogram.f_res, range(1)*spectrogram.t_res:range(2)*spectrogram.t_res, spectrogram.z_spec(range(1):range(2), range(3):range(4)));
    axis([range(3)*spectrogram.f_res range(4)*spectrogram.f_res  range(1)*spectrogram.t_res range(2)*spectrogram.t_res]);
else
    imhandle = imagesc((0:spectrogram.size(2))*spectrogram.f_res, (0:spectrogram.size(1))*spectrogram.t_res, spectrogram.z_spec); 
    axis([1 spectrogram.size(2)*spectrogram.f_res 1 spectrogram.size(1)*spectrogram.t_res]);
end
axis xy;

if exist('titlestr', 'var')
    title(titlestr);
end 
xlabel('Frequency (Hz)', 'fontsize', 12);
ylabel('Time (sec)', 'fontsize', 12);
colorbar;