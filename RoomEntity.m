classdef RoomEntity
%Define a Room Entity in building model
%
%========================================
%name: name of room
%floor: floor level of the room
%ceiling: a ceiling part Geometry of room
%body: a body part Geometry of room
%isContain(locationArray): Determine whether the location is contained in
%room
%========================================
%example: isContain([3,4,5]);
    
    properties
        name    %Name of room
        floor   %Level of floor
        ceiling %Struct of vertexes, faces, colors
        body    %Struct of vertexes, faces, colors
    end
    
    methods (Access = public)
        function obj = RoomEntity(name,floor)
            obj.name = name;
            obj.floor = floor;
            obj.body = Geometry();
            obj.ceiling = Geometry();
        end
        
        function out = isContain(obj,location)
            out = obj.isContainLocation(location, obj.body.vertexes);
        end
    end
    
    methods (Access = private)
        function out = isContainLocation(obj, location, vertexes) 
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
    end
end

