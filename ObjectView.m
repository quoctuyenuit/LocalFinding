classdef ObjectView
    %OBJECTVIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        data LoraObject
        level                   %Store level of location where object are located
        locationName            %Store name of location where object are located
        viewInformation
        viewDetailInformation
        color
    end
    
    methods
        function obj = ObjectView(data)
            if nargin ~= 0  
                obj.data = data;
            end
            obj.level = 0;
            obj.locationName = '';
            obj.color = [0 0 0];
        end
        
        function obj = updateDataIfNeeded(obj, rhs)
            if rhs.data.id == obj.data.id
                obj.data = rhs.data;
                obj.level = rhs.level;
                obj.locationName = rhs.locationName;
                obj.color = rhs.color;
            end
        end
    end
end

