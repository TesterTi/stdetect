function [trdata, trgt, tedata, tegt, trpositions, tepositions] = label_Spectrogram(data, template, width, height)

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


if any(size(data) ~= size(template))
    fprintf(2, 'Error: the spectrogram and its template should be of the same size!\n')
    return;
end


% Only labels as signal or noise

div = 2;   % Portion of data used for training i.e. 1/div

cols = (size(data, 1)- (height-1)) * (size(data, 2) - (width-1));
d = zeros(cols, (width*height)+1);
positions = zeros(cols, 2);

count = 1;
for j = 1:size(data, 1)-(height-1)
    for i = 1:size(data,2)-(width-1)
        wtemplate = template(j:(j+(height-1)), i:(i+(width-1)));
        
        d(count, 1:(width*height)) = reshape(data(j:(j+(height-1)), i:(i+(width-1))), 1, width*height);
        if sum(sum(wtemplate)) > 0
            d(count, (width*height)+1) = 1;
        else
            d(count, (width*height)+1) = 0;
        end
        count = count + 1;
    end
end
signal = d(d(:, (width*height)+1) == 1, 1:(width*height));
noise = d(d(:, (width*height)+1) == 0, 1:(width*height));

sigpos = positions(d(:, (width*height)+1) == 1, :);
noipos = positions(d(:, (width*height)+1) == 0, :);

if size(signal, 1) ~= 0
    num = min([size(signal, 1), size(noise, 1)]);
else
    num = size(noise, 1);
end

trcut = floor(num/div);

ord = randperm(size(signal, 1));
signal = signal(ord, :);
sigpos = sigpos(ord, :);
ord = randperm(size(noise, 1));
noise = noise(ord, :);
noipos = noipos(ord, :);

if size(signal, 1) ~= 0
    trdata = [signal(1:trcut, :); noise(1:trcut, :)];
    tedata = [signal(trcut+1:(div*trcut), :); noise(trcut+1:(div*trcut), :)];

    trpositions = [sigpos(1:trcut, :); noipos(1:trcut, :)];
    tepositions = [sigpos(trcut+1:(div*trcut), :); noipos(trcut+1:(div*trcut), :)];
    
    trgt = zeros(size(trdata, 1), 2);
    tegt = zeros(size(tedata, 1), 2);
    trgt(1:trcut, 1) = 1;
    trgt(trcut+1:end, 2) = 1;

    tegt(1:(div*trcut)-(trcut), 1) = 1;
    tegt((div*trcut)-(trcut)+1:end, 2) = 1;
else
    trdata = noise(1:trcut, :);
    tedata = noise(trcut+1:(div*trcut), :);

    trpositions = noipos(1:trcut, :);
    tepositions = noipos(trcut+1:(div*trcut), :);

    trgt = zeros(size(trdata, 1), 2);
    tegt = zeros(size(tedata, 1), 2);

    trgt(:, 2) = 1;

    tegt(:, 2) = 1;
end