function  [detectedTracks, nets, adaptWalkData] = recursivesnake(I, p, nets, adaptWalkData)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   RECURSIVESNAKE recursively passes a snake through a region of the
%                  spectrogram
%       [DETECTEDTRACKS, NETS, ADAPTWALKRATE] = RECURSIVESNAKE(I, P, NETS,...
%           ADAPTWALKDATA) returns the detected tracks from a region in the
%       image I. The region is specified in the snake_param object P. NETS 
%       is passed onto the snake algorithm for calculating the external 
%       energy values and P is also to provide the snake's parameters.
%
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

outputplot = 0; % plot snake progress (not recommended when using analyse_Spectrogram GUI)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if size(I,1)-(p.snakeLength+(p.windowHeight-1))+1 < 1
    errstr = ['Image size must be >= ', num2str((p.snakeLength+(p.windowHeight-1)))];
    error(errstr);
end

%p = set(p, 'Forward', 0);

range = p.range;
if range(1) < (p.windowWidth-1)/2 || range(1) > (size(I, 2)-((p.windowWidth-1)/2)-1) ||...
        range(2) < (p.windowWidth-1)/2 || range(2) > (size(I, 2)-((p.windowWidth-1)/2)-1)
    error('Search Range is not within the image!');
end

I = I(1:p.snakeLength+(p.windowHeight-1), :);

original = I;

if exist('adaptWalkData', 'var')
    [walkForce, adaptWalkData] = adaptWalkRate(adaptWalkData, p);
else
    walkForce = ones(1, size(I,2)) * p.walkRate;
end

%set(p1, 'YData', [get(p1, 'YData'), max(get(p1, 'YData'))+1]);
%set(p1, 'ZData', [get(p1, 'ZData'); walkForce]);

s = patternsnakev6(I, p, nets);

if s == -1
    detectedTracks = -1;
    return;
end

count = 1;
detectedTracks(:,:,count) = s;
while (p.forward && all(s(:,1)+3 < range(2))) || (~p.forward && all(s(:,1)-3 > range(2)))
    count = count + 1;
    
    if p.forward
        walkForce = walkForce(int32(((max(s(:,1))+3) - min(p.range)) * (p.harmonyNumber+1))+1:end);
        p = set(p, 'Range', [max(s(:,1))+3, range(2)]);
    else
        p = set(p, 'Range', [min(s(:,1))-3, range(2)]);
    end
	
    s = patternsnakev6(I, p, nets);
    
    detectedTracks(:,:,count) = s;
    %for i = 1:size(s, 1)
    %    h = floor(harmonies(s(i,1), p.harmonicSet));
    %    for j = 1:numel(h)
    %        I(floor(s(i,2)), h(j)) = 0;
    %        I(floor(s(i,2)), h(j)+1) = 0;
    %        I(floor(s(i,2)), h(j)-1) = 0;
    %    end
    %end
end
%s = s(slength+1:end, :);
%s = s(1:end-slength, :);

if size(detectedTracks,3) > 1
    detectedTracks = detectedTracks(:,:,1:end-1);
else
    detectedTracks = [];
end

reconstructed = zeros(size(I));
for j = 1:size(detectedTracks, 3)
   if ~isempty(detectedTracks)
       for i = 1:size(detectedTracks, 1)
           [h] = round(harmonies(detectedTracks(i,1,j), p.harmonicSet));
           for k = 1:numel(h)
               reconstructed(round(detectedTracks(i,2,j)), h(k)) = 1;
           end
       end
   end
end

if outputplot
    scrsz = get(0,'ScreenSize');
    h = figure('Position',[1 scrsz(4)/2-100 scrsz(3) scrsz(4)/2]);
    subplot(2,1,1), imagesc(original), colormap(gray);
    title('Spectrogram');
    xlabel('Frequency');
    ylabel('Time');
    set(gca, 'yticklabel', 190+5:5:190+size(I,1));
    axis([1 size(original,2) 1 size(original, 1)]);
    axis xy;
    subplot(2,1,2), image(reconstructed), colormap(gray);
    title('Detected Features');
    xlabel('Frequency');
    ylabel('Time');
    set(gca, 'yticklabel', 190+5:5:190+size(I,1));
    axis([1 size(reconstructed,2) 1 size(reconstructed, 1)]);
    axis xy;
end
