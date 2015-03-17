function [class, Y, teperc, conf, act] = test_Network(net, tedata, tegt)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   TEST_NETWORK todo:description
%       [CLASS, Y, TEPERC, CONF, ACT] = TEST_NETWORK(NET, TEDATA, TEGT)
%
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


switch net.type
    case 'knn'
        [Y, conf] = knnfwd(net, tedata);
    case 'wknn'
        [Y, conf] = knnweightfwd(net, tedata);
    case 'rbf'
        [Y, act] = rbffwd(net, tedata);
        %act = Y(:,size(Y,2));
    case 'gauss'
        [Y, act] = gaussfwd(net, tedata);
    case 'mlp'
        Y = mlpfwd(net, tedata);
    case 'euclid'
        [Y, conf] = euclidfwd(net, tedata);
    case 'som_map'
        Y = somfwd(net, tedata);
    case 'mahalanobis'
        [Y, conf] = mahalanobisfwd(net, tedata);
    otherwise
        fprintf('Network type not known!\n');
end

% fix for 2 classes receive same number of votes
maxs = max(Y,[],2);
maxs = repmat(maxs, [1, size(Y, 2)]);
[I, J] = find(Y == maxs);
class(I) = J;

% figure,
% plot(tedata(find(class == 1), 1), tedata(find(class == 1),2), '.b');
% hold on;
% plot(tedata(find(class == 2), 1), tedata(find(class == 2),2), '.r');
% %plot(net.trsigmean(1), net.trsigmean(2), '.g');
% %plot(net.trnoisemean(1), net.trnoisemean(2), '.k');
% hold off;
% 
% for i = 1:size(Y, 1)
%     current = Y(i, :);
%     pos = find(current == max(current));
%     ord = randperm(numel(pos));
%     class(i) = pos(ord(1));
% end

if exist('tegt', 'var')
   conf = confmat(Y, tegt)
   teperc = sum(diag(conf))/sum(sum(conf));
   fprintf('Classification Performance: %f\n', teperc);
end