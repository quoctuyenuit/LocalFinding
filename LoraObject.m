classdef LoraObject 
    properties
        location       %Store location (x, y, z) where object are located
        level          %Store level of location where object are located
        locationName   %Store name of location where object are located
        name           %Name of object
        viewInformation
        viewDetailInformation
    end
    
    methods (Access = public)
        function obj = LoraObject(location)
            if nargin == 0 
                obj.location.x = 0;
                obj.location.y = 0;
                obj.location.z = 0;
            else
                obj.location.x = location.x;
                obj.location.y = location.y;
                obj.location.z = location.z;
            end
            obj.level = 0;
            obj.locationName = '';
        end
        
        function obj = updateLoraObject(obj, listOfRooms)
            for j = 1: length(listOfRooms)
                curRoom = listOfRooms(j);
                if curRoom.isContain(obj.location)
                    obj.locationName = curRoom.name;
                    obj.level = curRoom.level;
                    return;
                end
            end
        end
    end
end

