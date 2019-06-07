classdef Presenter < handle
    properties (Access = private)
        interactor Interactor
        listOfRooms     %List of rooms in model
        listOfObjects   %List of current objects
    end
    methods (Access = public)
        %Constructor
        function presenter = Presenter()
            presenter.interactor = Interactor();
            presenter.listOfRooms = presenter.interactor.retrieveListOfRooms;
            presenter.listOfObjects = presenter.interactor.retrieveListOfObjects();
            presenter.updateLoraObjects();
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
        function buildModel(obj, view)
            axesIndex = 1;
            view.prepareDraw(axesIndex);
            
            for i = 1: length(obj.listOfRooms)
                isShowCeiling = 1;
                obj.buildRoom(obj.listOfRooms(i), isShowCeiling, axesIndex, view);
            end
            
            for i = 1: length(obj.listOfObjects)
                obj.listOfObjects(i) = view.drawObject(obj.listOfObjects(i), axesIndex);
            end
            
            view.finishDraw(axesIndex);
        end
        
        function updateObjects(obj, view) 
            for i = 1: length(obj.listOfObjects)
                obj.listOfObjects(i).location.x = rand * 10000;
                view.updateObject(obj.listOfObjects(i), 1);
                view.updateObject(obj.listOfObjects(i), 2);
            end
        end
        
        function result = checkArea(obj, location)
            for i = 1:length(obj.listOfRooms)
                currentRoom = obj.listOfRooms(i);
                
                if obj.roomContainLocation(currentRoom, location)
                    result.label = currentRoom.name;
                    result.floor = currentRoom.floor;
                    return;
                end
            end
%           if none of rooms contains the location then result is null
            result = 0;
        end
        
        function viewOnFloor(obj, floorNumber, view)
            view.prepareDraw(2);
            for i = 1: length(obj.listOfRooms)
                room = obj.listOfRooms(i);
                if (room.floor == floorNumber)
                    isShowCeiling = 0; %False
                    axesIndex = 2; %Show on 2D mode
                    obj.buildRoom(room, isShowCeiling, axesIndex, view);
                end
            end
            for i = 1 : length(obj.listOfObjects)
                if obj.listOfObjects(i).floor == floorNumber
                    obj.listOfObjects(i) = view.drawObject(obj.listOfObjects(i), 2);
                end
            end
            view.finishDraw(2);
        end
    end
    
    methods (Access = private)
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
            out = obj.listOfRooms(1).floor;
            for i = 1 : length(obj.listOfRooms)
                if out < obj.listOfRooms(i).floor
                    out = obj.listOfRooms(i).floor;
                end
            end
        end
        
        function out = getMinFloor(obj)
            out = obj.listOfRooms(1).floor;
            for i = 1 : length(obj.listOfRooms)
                if out > obj.listOfRooms(i).floor
                    out = obj.listOfRooms(i).floor;
                end
            end
        end
        
        function buildRoom(obj, room, isShowCeiling, axesIndex, view)
            view.plotModel(room.body, axesIndex);
            if isShowCeiling
                view.plotModel(room.ceiling, axesIndex);
            end
        end     
        
        function updateLoraObjects(obj)
            for i = 1: length(obj.listOfObjects)
                curObject = obj.listOfObjects(i);
                
                for j = 1: length(obj.listOfRooms)
                    curRoom = obj.listOfRooms(j);
                    if obj.roomContainLocation(curRoom, curObject.location)
                        curObject.locationName = curRoom.name;
                        curObject.floor = curRoom.floor;
                        break;
                    end
                end
            end
        end
    end
end

