classdef Interactor
    properties (Access = private)
        locationsObjects = 'Resources/locations.json'
    end
    methods (Access = public) 
%       the "fileName" have to format follow RoomName_Floor
        function result = retrieveData(interactor, fileName)
            readResult = interactor.readSTLFile(fileName);
            result = Geometry(readResult.vertexes, readResult.faces, readResult.colors);
        end
        
        function result = retrieveObjects(obj) 
            result = obj.readJsonFile(obj.locationsObjects).locations;
        end
    end
    
    methods (Access = private) 
        function result = readSTLFile(obj, fileName)
            fid = fopen(fileName, 'r');
            if fid == -1
                error('File coule not be opened, check name or path.');
            end
            fprintf('Reading file %s.\n',fileName);
            
            numberOfVertex = 0;
            report_num = 0;
            VColor = [0.2980 0.5725  0.6863];
            v = zeros(10000, 3);
            c = zeros(10000, 3);
            while feof(fid) == 0            % Test for end of file, if not then do stuff
                tline = fgetl(fid);         % Reads a line of data from file
                fword = sscanf(tline, '%s');% Make the line a character string
                
                % Check for color
                if strncmpi(fword, 'c', 1) == 1
                    VColor = sscanf(tline,'%*s %f %f %f'); % & if a C, get the RGB color data of the face.
                end
                if strncmpi(fword, 'v',1) == 1      % Checking if a "V"ertex line, as "V" is 1st char.
                    numberOfVertex = numberOfVertex + 1;                % If a V we count the # of V's
                    report_num = report_num + 1;    % Report a counter, so long files show status
                    if report_num > 249
                        report_num = 0;
                    end
                    v(numberOfVertex, :) = sscanf(tline, '%*s %f %f %f'); % & if a V, get the XYZ data of it.
                    c(numberOfVertex, :) = VColor;              % A color for each vertex, which will color the faces.
                end
            end
            %   Build face list; The vertices are in order, so just number them.
            %
            numberOfFacet = numberOfVertex/3;      %Number of faces, numberOfVertex is number of vertices.  STL is triangles.
            flist = 1:numberOfVertex;     %Face list of vertices, all in order.
            f = reshape(flist, 3,numberOfFacet); %Make a "3 by numberOfFacet" matrix of face list data.
            %
            %   Return the faces and vertexs.
            %
            result.faces = f';  %Orients the array for direct use in patch.
            result.vertexes = v(1:numberOfVertex, :);  % "
            result.colors = c(1:numberOfVertex, :);
            %
            fclose(fid);
        end
        
        function result = readJsonFile(obj, fileName) 
            fid = fopen(fileName, 'r');
            if fid == -1
                error('File coule not be opened, check name or path.');
            end
            raw = fread(fid,inf);
            str = char(raw');
            fclose(fid);

            result = jsondecode(str);
        end
    end
end

