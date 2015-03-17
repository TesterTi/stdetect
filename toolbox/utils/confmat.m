function [C,rate]=confmat(Y,T)

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


%CONFMAT Compute a confusion matrix.
%
%	Description
%	[C, RATE] = CONFMAT(Y, T) computes the confusion matrix C and
%	classification performance RATE for the predictions mat{y} compared
%	with the targets T.  The data is assumed to be in a 1-of-N encoding,
%	unless there is just one column, when it is assumed to be a 2 class
%	problem with a 0-1 encoding.  Each row of Y and T corresponds to a
%	single example.
%
%	In the confusion matrix, the rows represent the true classes and the
%	columns the predicted classes.  The vector RATE has two entries: the
%	percentage of correct classifications and the total number of correct
%	classifications.
%
%	See also
%	CONFFIG, DEMTRAIN
%

%	Copyright (c) Ian T Nabney (1996-2001)

[n c]=size(Y);
[n2 c2]=size(T);

if n~=n2 | c~=c2
  error('Outputs and targets are different sizes')
end

if c > 1
  % Find the winning class assuming 1-of-N encoding
  [maximum Yclass] = max(Y', [], 1);

  TL=[1:c]*T';
else
  % Assume two classes with 0-1 encoding
  c = 2;
  class2 = find(T > 0.5);
  TL = ones(n, 1);
  TL(class2) = 2;
  class2 = find(Y > 0.5);
  Yclass = ones(n, 1);
  Yclass(class2) = 2;
end

% Compute 
correct = (Yclass==TL);
total=sum(sum(correct));
rate=[total*100/n total];

C=zeros(c,c);
for i=1:c
  for j=1:c
    C(i,j) = sum((Yclass==j).*(TL==i));
  end
end   
