function [tpr, fpr] = roc_rate(x, t)

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


% Calculates the true positive rate and the false positive rate for a ROC
% curve using the binary detection x and template t.

if max(max(x)) ~= min(min(x))
    signalLevel = max(max(x));
else
    signalLevel = 1;
end

x(x > 0) = signalLevel;
t(t > 0) = signalLevel;

difference = t - (x*2);

tp = sum(sum(difference == -signalLevel));
fp = sum(sum(difference == -(2*signalLevel)));
tn = sum(sum(difference == 0));
fn = sum(sum(difference == signalLevel));

if (tp+fn) ~= 0
    tpr = tp / (tp+fn);
else
    tpr = 1;
end

if (fp+tn) ~= 0
    fpr = fp / (fp+tn);
else
    fpr = 0;
end

%fprintf('TPR: %2.4f FPR: %2.4f\n', tpr, fpr);