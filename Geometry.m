classdef Geometry
%Define a geometry of mini model
%
%=============================================
%vertexes: matrix(n,3) contain list of vertexes
%faces: matrix(n,3) contain list of faces
%colors: matrix(n,1) contain list of colors in model
%Geometry(vertexes, faces, colors)

    properties
        vertexes
        faces
        colors
    end
    
    methods
        function obj = Geometry(v, f, c)
            if nargin == 0
                obj.vertexes = [];
                obj.faces = [];
                obj.colors = [];
            elseif nargin ~= 3
                error('Invalid parameter for Geometry');
            else
                obj.vertexes = v;
                obj.faces = f;
                obj.colors = c;
            end
        end
        
        function obj = concat(obj, geometry)
            obj.vertexes = [obj.vertexes; geometry.vertexes];
            obj.colors = [obj.colors; geometry.colors];
            obj.faces = obj.getFaces(length(geometry.colors));
        end
    end
    
    methods (Access = private)
        function faces = getFaces(obj, countNeeded)
            [rows, ~] = size(obj.faces);
            countNeeded = countNeeded / 3;
            
            faces = zeros(rows + countNeeded, 3);
            faces(1:rows, :) = obj.faces;
            
            for i = 1 : countNeeded
                if isempty(faces)
                    maxValue = 0;
                else
                    maxValue = max(faces(:));
                end
                faces(rows + i, :) = maxValue + 1:maxValue+3;
            end
        end
    end
end

