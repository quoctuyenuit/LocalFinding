classdef Presenter < handle
    properties (Access = private)
        interactor Interactor
        listOfRoom %List of rooms in model
        listOfObjects %List of current objects
    end
    methods (Access = public)
        %Constructor
        function presenter = Presenter()
            presenter.interactor = Interactor();
            presenter.retrieveData();
        end
        %==================================================================
        function buildModel(obj, view)
            for i = 1: length(obj.listOfRoom)
                modelInformation.faces = obj.listOfRoom(i).faces;
                modelInformation.vertexes = obj.listOfRoom(i).vertexes;
                modelInformation.colors = obj.listOfRoom(i).colors;
                view.plotModel(modelInformation, 1);
            end
           
            view.drawObjects(obj.listOfObjects);
            
        end
        
        function updateObjects(obj, view) 
            for i = 1: length(obj.listOfObjects)
                obj.listOfObjects(i).x = obj.listOfObjects(i).x + 5;
            end
            
            view.updateObjects(obj.listOfObjects);
        end
        
        function result = checkArea(obj, location)
            for i = 1:length(obj.listOfRoom)
                currentRoomVertexes = obj.listOfRoom(i).vertexes;
                if obj.isInsideOf(currentRoomVertexes, location)
                    result.label = obj.listOfRoom(i).label;
                    result.floor = obj.listOfRoom(i).floor;
                    return;
                end
            end
%           if none of rooms contains the location then result is null
            result = 0;
        end
        
        function viewOnFloor(obj, floorNumber, view)
            for i = 1: length(obj.listOfRoom)
                if (obj.listOfRoom(i).floor == floorNumber)
                    modelInformation.faces = obj.listOfRoom(i).faces;
                    modelInformation.vertexes = obj.listOfRoom(i).vertexes;
                    modelInformation.colors = obj.listOfRoom(i).colors;
                    
                    view.plotModel(modelInformation, 2);
                end
            end
        end
    end
    
    methods (Access = private) 
        function retrieveData(obj)
            %--------------------------------------------------------------
            %read objects data
            %--------------------------------------------------------------
            obj.listOfObjects = obj.interactor.retrieveObjects("Resources/locations.json");
            %--------------------------------------------------------------
            %read model data
            %--------------------------------------------------------------
            resources = dir("Resources");
            %Remove two first rows, cause two first row is '.' and '..',it's not neccessory
            resources(1:2, :) = []; 
            %--------------------------------------------------------------
            [rows,~] = size(resources);
            index = 1;
            for i = 1: rows
                if contains(resources(i).name, '.stl')
                    path = strcat(resources(i).folder, '/', resources(i).name);
                    readResult = obj.interactor.retrieveData(path);
                    
                    try
                        fileName = erase(resources(i).name, '.stl');
                        splitResult = split(fileName, '_');
                        obj.listOfRoom(index).label = splitResult(1);
                        obj.listOfRoom(index).floor = str2double(splitResult(2));
                    catch
                        result.label = 'UnKnown';
                        result.floor = 0;
                    end
                    
                    obj.listOfRoom(index).vertexes = readResult.vertexes;
                    obj.listOfRoom(index).faces = readResult.faces;
                    obj.listOfRoom(index).colors = readResult.colors;
                    index = index + 1;
                end
            end
        end
        
        function is = isInsideOf(obj, vertexes, location) 
            maxX = max(vertexes(:,1));
            minX = min(vertexes(:,1));
            
            if (location.x < minX || location.x > maxX)
                is = 0;
                return;
            end
            
            maxY = max(vertexes(:,2));
            minY = min(vertexes(:,2));
            
            if (location.y < minY || location.y > maxY)
                is = 0;
                return;
            end
            
            is = 1;
            
            maxZ = max(vertexes(:,3));
            minZ = min(vertexes(:,3));
            
            if (location.z < minZ || location.z > maxZ)
                is = 0;
                return;
            end
        end
    end
end

