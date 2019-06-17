classdef LoraObject 
    properties
        x
        y
        z
        name           %Name of object
        id
    end
    
    methods (Access = public)
        function obj = LoraObject(location)
            if nargin == 0 
                obj.x = 0;
                obj.y = 0;
                obj.z = 0;
            else
                obj.x = location.x;
                obj.y = location.y;
                obj.z = location.z;
            end
        end
        
        function out = getLocation(obj)
            out.x = obj.x;
            out.y = obj.y;
            out.z = obj.z;
        end
    end
end

