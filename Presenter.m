classdef Presenter < handle
    properties (Access = private)
        interactor Interactor
        listOfObjects   %List of current objects
        listGateways
        timerObj
    end
    
    properties (Access = public)
        listOfRooms     %List of rooms in model, let it in public to get from view
        modelData
    end
    
    methods (Access = public)
        %Constructor
        function presenter = Presenter()
            presenter.interactor = Interactor();
            [presenter.listOfRooms, presenter.modelData] = presenter.interactor.retrieveListOfRooms;
            presenter.listOfObjects = presenter.interactor.retrieveListOfObjects();
            presenter.listGateways = presenter.interactor.retrieveListGateways();
            presenter.timerObj = timer('ExecutionMode', 'fixedRate', 'Period', 3, 'TimerFcn', {@presenter.updateObjects});
            start(presenter.timerObj);
        end
        
        function list = getListOfFloors(obj)
            maxFloor = obj.getMaxFloor();
            minFloor = obj.getMinFloor();
            list = cell(1, maxFloor - minFloor + 1);
            
            for i = minFloor : maxFloor
                list(i - minFloor + 1) = sprintfc('%d',i);
            end
        end
        %==================================================================
        %Get nodes data
        %==================================================================
        function out = getListNodes(obj) 
            n = length(obj.listOfObjects);
            out = repmat(ObjectView(), n, 1);
            for i = 1 : n
                data = obj.listOfObjects(i);
                out(i).data = data;
                checkedResult = obj.checkArea(data.getLocation());
                out(i).level = checkedResult.level;
                out(i).locationName = checkedResult.name;
                out(i).color = [0 0 1]; %blue
            end
        end
        %==================================================================
        %Get gateways data
        %==================================================================
        function out = getListGateways(obj)
            n = length(obj.listGateways);
            out = repmat(ObjectView(), n, 1);
            for i = 1 : n
                data = obj.listGateways(i);
                out(i).data = data;
                checkedResult = obj.checkArea(data.getLocation());
                out(i).level = checkedResult.level;
                out(i).locationName = checkedResult.name;
                out(i).color = [1 0 0]; %red
            end
        end
        %==================================================================
        function out = getModelDataAt(obj, level)
            n = length(obj.listOfRooms);
            out.vertexes = [];
            out.faces = [];
            out.colors = [];
            for i = 1: n
                if obj.listOfRooms(i).level == level
                    out = obj.concatModelData(out, obj.listOfRooms(i));
                end
            end
        end
        %==================================================================
        function updateObjects(obj, timerObj, timerData) 
            for i = 1: length(obj.listOfObjects)
                obj.listOfObjects(i).x = rand * 10000;
                obj.listOfObjects(i).z = rand * 50000;
                
            end
        end
        
        function result = checkArea(obj, location)
            for i = 1:length(obj.listOfRooms)
                currentRoom = obj.listOfRooms(i);
                
                if obj.roomContainLocation(currentRoom, location)
                    result.name = currentRoom.name;
                    result.level = currentRoom.level;
                    return;
                end
            end
            result.name = 'Không thuộc mô hình';
            result.level = -1;
        end
    end
    
    methods (Access = private)
        function lhs = concatModelData(obj, lhs, rhs)
            lhs.vertexes = [lhs.vertexes; rhs.body.vertexes];
            lhs.colors = [lhs.colors; rhs.body.colors];
            [n, ~] = size(rhs.body.vertexes);
            lhs.faces = obj.concatFaces(lhs.faces, n); 
        end
        
        function newFaces = concatFaces(obj, faces, numberOfFaces)
            if mod(numberOfFaces, 3) ~= 0
                error('numberOfFaces have to divisible by 3');
            end
            newColumns = numberOfFaces / 3;
            if isempty(faces)
                maxOfFaces = 1;
            else
                maxOfFaces = max(faces(:)) + 1;
            end
            [col, ~] = size(faces);
            newFaces = repmat([0 0 0], col + newColumns, 1);
            newFaces(1:col, :) = faces; %copy old data
            
            for i = col + 1: col + newColumns
                newFaces(i, :) = maxOfFaces:1:maxOfFaces + 2;
                maxOfFaces = maxOfFaces + 3;
            end
        end
        
        function out = roomContainLocation(obj, room, location) 
            out = (obj.isContainLocation(location, room.body.vertexes) || obj.isContainLocation(location, room.ceiling.vertexes));
        end
        
        function out = isContainLocation(obj, location, vertexes) 
            if isempty(vertexes)
                out = 0;
                return;
            end
            
            maxX = max(vertexes(:,1));
            minX = min(vertexes(:,1));
            
            if (location.x < minX || location.x > maxX)
                out = 0;
                return;
            end
            
            maxY = max(vertexes(:,2));
            minY = min(vertexes(:,2));
            
            if (location.y < minY || location.y > maxY)
                out = 0;
                return;
            end
            
            maxZ = max(vertexes(:,3));
            minZ = min(vertexes(:,3));
            
            if (location.z < minZ || location.z > maxZ)
                out = 0;
                return;
            end
            
            out = 1;
        end
        
        function out = getMaxFloor(obj)
            out = obj.listOfRooms(1).level;
            for i = 1 : length(obj.listOfRooms)
                if out < obj.listOfRooms(i).level
                    out = obj.listOfRooms(i).level;
                end
            end
        end
        
        function out = getMinFloor(obj)
            out = obj.listOfRooms(1).level;
            for i = 1 : length(obj.listOfRooms)
                if out > obj.listOfRooms(i).level
                    out = obj.listOfRooms(i).level;
                end
            end
        end
    end
end

