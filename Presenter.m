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
            presenter.retrieveData();
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
                cuurentRoom = obj.listOfRooms(i);
                
                if cuurentRoom.isContain([location.x, location.y, location.z])
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
        
        function retrieveData(obj)
            %--------------------------------------------------------------
            %read objects data
            %--------------------------------------------------------------
            obj.listOfObjects = obj.interactor.retrieveObjects();
            %--------------------------------------------------------------
            %read model data
            %--------------------------------------------------------------
            resources = dir("Resources");
            %Remove two first rows, cause two first row is '.' and '..',it's not neccessory
            resources(1:2, :) = []; 
            %--------------------------------------------------------------
            [rows,~] = size(resources);
            for i = 1: rows
                if contains(resources(i).name, '.stl')
                    path = strcat(resources(i).folder, '/', resources(i).name);
                    
                    readResult = obj.interactor.retrieveData(path);
                    
                    try
                        fileName = erase(resources(i).name, '.stl');
                        splitResult = split(fileName, '_');
                        %--------------------------------------------------
                        if length(splitResult) >= 3
                            if (str2double(splitResult(3)) == 0)
                                isCeiling = 1;
                            else
                                isCeiling = 0;
                            end
                        else
                            isCeiling = 0;
                        end
                        
                        %--------------------------------------------------
                        name = splitResult(1);
                        disp(name);
                        floor = str2double(splitResult(2));
                    catch
                        name = 'UnKnown';
                        floor = 0;
                        isCeiling = 0;
                    end
                    
                    obj.addRoomIntoList(name, floor, readResult, isCeiling);
                end
            end
        end
        
        %Add a room into listOfRoomss
        function addRoomIntoList(obj, name, floor, geometry, isCeiling)
            %If room already exists => update room
            count = length(obj.listOfRooms);
            for i = 1 : count
                room = obj.listOfRooms(i);
                if strcmpi(room.name, name) && room.floor == floor
                    if isCeiling
                        room.ceiling = room.ceiling.concat(geometry);
                    else
                        room.body = room.body.concat(geometry);
                    end
                    obj.listOfRooms(i) = room;
                    return;
                end
            end
            
            %Orelse, create new room and add it into list
            room = RoomEntity(name, floor);
            if isCeiling
                room.ceiling = geometry;
            else
                room.body = geometry;
            end
            
            if count == 0
                obj.listOfRooms = [room];
            else 
                obj.listOfRooms(count + 1) = room;
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

