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
        
        function buildModel(obj, view)
            view.prepareDraw(1);
            
            for i = 1: length(obj.listOfRooms)
                isShowCeiling = 1;
                axesIndex = 1;
                obj.buildRoom(obj.listOfRooms(i), isShowCeiling, axesIndex, view);
            end
           
            view.drawObjects(obj.listOfObjects);
            
            view.finishDraw(1);
        end
        
        function updateObjects(obj, view) 
%             for i = 1: length(obj.listOfObjects)
%                 obj.listOfObjects(i).x = obj.listOfObjects(i).x + 5;
%             end
%             
%             view.updateObjects(obj.listOfObjects);
        end
        
        function result = checkArea(obj, location)
            for i = 1:length(obj.listOfRooms)
                currentRoom = obj.listOfRooms(i);
                
                if currentRoom.isContain([location.x, location.y, location.z])
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
            view.finishDraw(2);
        end
    end
    
    methods (Access = private) 
        function buildRoom(obj, room, isShowCeiling, axesIndex, view)
            view.plotModel(room.body, axesIndex);
            if isShowCeiling
                view.plotModel(room.ceiling, axesIndex);
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

