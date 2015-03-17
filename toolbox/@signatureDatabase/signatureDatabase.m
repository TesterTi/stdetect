function db = signatureDatabase(varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   SIGNATUREDATABASE class constructor. 
%       DB = SIGNATUREDATABASE(ARG1) the optional argument ARG1 can be a 
%       filename referring to a .csv signature database or a signature 
%       database object. If no argument is passed then the default 
%       signature database is loaded from 'database.csv'.
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

dbread = 0;

switch nargin
    case 0
        %fprintf('Loading Signature Database...');
        % read database from default xls file
        try 
            fid = fopen(['@signatureDatabase' filesep 'database.xls']);
            data = textscan(fid, '%s%f%f%s%s', 'Delimiter', ',', 'CommentStyle', {'\*', '*\'});
        catch e
            fprintf(2, 'Error: the signature database %s could not be read!\n', ['@signatureDatabase' filesep 'database.xls']);
            fprintf(2, 'Aborting the process.\n')
            try
                fclose(fid);
            catch e
            end
            db = [];
            return;
        end

        fclose(fid);
        %fprintf('Done\n');
        
        dbread = 1;
        
    case 1
        if (isa(varargin{1},'char'))
            %fprintf('Loading Signature Database...');
            % read database from file specified
            try 
                fid = fopen(varargin{1});
                data = textscan(fid, '%s%f%f%s%s', 'Delimiter', ',', 'CommentStyle', {'\*', '*\'});
            catch e
                fprintf(2, 'Error: the signature database %s could not be read!\n', varargin{1});
                fprintf(2, 'Aborting the process.\n')
                try
                    fclose(fid);
                catch e
                end 
                db = [];
                return;
            end

            fclose(fid);
            %fprintf('Done\n');

            dbread = 1;
        else
            fprintf(2, 'Input argument is not a file name');
	    db = [];
            return
        end
%    case 3
    % create object using specified values
%        p = class(f, 'signatureDatabase');
    otherwise
        fprintf(2, 'Wrong number of input arguments');
        db = [];
        return
end



if dbread == 1
        
        errstr = '';
        for i = 1:numel(data{1})
            ok = 1;
            
            if numel(data{2}) > 0
                db.database{i}.type = data{1}{i};
            else
                ok = 0;
                errstr = ['type for entry ', num2str(i), ' is empty'];
            end
            
            if ok == 1
                if numel(data{2}) > 0
                    db.database{i}.fundamental = data{2}(i);
                else
                    ok = 0;
                    errstr = ['fundamental for entry ', num2str(i), ' is empty or an invalid character'];
                end
            end
            
            if ok == 1
                if numel(data{3}) > 0
                    db.database{i}.searchRange = data{3}(i);
                else
                    ok = 0;
                    errstr = ['search Range for entry ', num2str(i), ' is empty or an invalid character'];
                end
            end
            
            if ok == 1
                if numel(data{4}) > 0
                    db.database{i}.harmonics = str2num(data{4}{i});
                else
                    ok = 0;
                    errstr = ['harmonic for entry ', num2str(i), ' is empty or contains an invalid character'];
                end
            end
            
            if ok == 1
                if numel(data{5}) > 0
                    db.database{i}.mask = str2num(data{5}{i});
                    if ~all((db.database{i}.mask == 1) | (db.database{i}.mask == 0) == 1)
                        ok = 0;
                        errstr = ['mask for entry ', num2str(i), ' contains an invalid character'];
                    end
                else
                    ok = 0;
                    errstr = ['mask for entry ', num2str(i), ' is empty'];
                end
            end
            
            if ok == 1 && numel(db.database{i}.mask) ~= numel(db.database{i}.harmonics)
                ok = 0;
                errstr = 'The number of entries in the Mask must equal those in the Harmonic set';
            end
            
            if ~isempty(errstr)
                fprintf(2, ['Error: ' errstr, '\n']);
                db = [];
                return;
            end

        end

        db = class(db, 'signatureDatabase');
end