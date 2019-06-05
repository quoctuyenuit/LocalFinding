classdef LoraObject 
    properties
        location       %Store location (x, y, z) where object are located
        floor          %Store floor of location where object are located
        locationName   %Store name of location where object are located
    end
    
    methods
        function obj = LoraObject(location)
            obj.location.x = location.x;
            obj.location.y = location.y;
            obj.location.z = location.z;
        end
    end
end

