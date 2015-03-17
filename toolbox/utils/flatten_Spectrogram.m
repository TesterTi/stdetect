function result = flatten_Spectrogram(data, width, height)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   FLATTEN_SPECTROGRAM create pixel vectors from an image.
%       RESULT = FLATTEN_SPECTROGRAM(DATA, WIDTH, HEIGHT) returns a set of
%       vectors of pixel values. These are extracted by passing a rolling 
%       window of size (HEIGHT,WIDTH) over an image (DATA).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Copyright 2007, 2010 Thomas Lampert
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


cols = (size(data, 1) - (height-1)) * (size(data, 2) - (width-1));
result = zeros(cols, width*height);
t = 1;
for j = 1:size(data, 1)-(height-1)
    for i = 1:size(data,2)-(width-1)
        result(t, :) = reshape(data(j:(j+(height-1)), i:(i+(width-1))), 1, width*height);
        t = t + 1;
    end
end