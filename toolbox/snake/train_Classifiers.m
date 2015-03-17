function nets = train_Classifiers(p, dimensionality)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   TRAIN_CLASSIFIERS trains the classifiers to be used in the detection
%                     process.
%       NETS = TRAIN_CLASSIFIERS(P) returns the classifier/s trained on the
%       data loaded from a synthetic 0dB SNR spectrogram. The training 
%       processuses the parameters specified in the snake_param object P.
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


nets = cell(0);
nets{1}.height = p.windowHeight;
nets{1}.width = p.windowWidth;
nets{1}.list = {};

filters = train_PCA_filters(p, dimensionality);

gauss = train_Gauss(filters, p);

% check that an error has not occurred while training the system.
if isempty(gauss) || isempty(filters)
    nets = [];
    return;
end

net.mu = {gauss.Mu};
net.covar = {gauss.Covar};
net.type = 'gauss';


net.width = p.windowWidth;
net.height = p.windowHeight;
for i = 1:size(filters.templates, 3)
    net.pcvec(:,i) = reshape(filters.templates(:,:,i), 1, filters.window_Width*filters.window_Height);
end
net.featureName = 'PCAWindow';
net.filters = filters;
net.gaussian = gauss;

nets{numel(nets) + 1} = net;