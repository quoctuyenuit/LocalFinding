classdef Interactor
    properties (Access = private)
        locationsObjectsPath = 'Resources/locations.json'
        resourcePath = 'Resources'
    end
    methods (Access = public) 
        function listOfObjects = retrieveListOfObjects(interactor)
            listRaw = interactor.readJsonFile(interactor.locationsObjectsPath).locations;
            [rows, ~] = size(listRaw);
            listOfObjects = repmat(LoraObject(), rows, 1);
            for i = 1 : rows
                listOfObjects(i).location.x = listRaw(i).x;
                listOfObjects(i).location.y = listRaw(i).y;
                listOfObjects(i).location.z = listRaw(i).z;

                listOfObjects(i).name = listRaw(i).label;
            end
        end

        function listOfRooms = retrieveListOfRooms(interactor)
            %--------------------------------------------------------------
            %read model data
            %--------------------------------------------------------------
            resources = dir(interactor.resourcePath);
            %Remove two first rows, cause two first row is '.' and '..',it's not neccessory
            resources(1:2, :) = [];
            %--------------------------------------------------------------
            [rows,~] = size(resources);
            index = 1;
            listInputs = struct('name', cell(1, rows), 'folderPath', cell(1, rows));
            for i = 1: rows
                listInputs(index).name = resources(i).name;
                listInputs(index).folderPath = resources(i).folder;
                index = index + 1;
            end
            listOfRooms = STLReaderV2(listInputs);
            %--------------------------------------------------------------
            %refactor data
            %--------------------------------------------------------------
            for i = 1: length(listOfRooms)
                listOfRooms(i).ceiling = interactor.refactorData(listOfRooms(i).ceiling.vertexes, listOfRooms(i).ceiling.faces, listOfRooms(i).ceiling.colors);
                listOfRooms(i).body = interactor.refactorData(listOfRooms(i).body.vertexes, listOfRooms(i).body.faces, listOfRooms(i).body.colors);
            end
        end
    end

    methods (Access = private)
        %Data matrix từ C++ mex function trả ra sẽ bị đảo ngược dữ liệu,
        %Data matrix cần nx3
        %Data matrix từ C++ trả về 3xn
        function geometry = refactorData(obj, v, f, c)
            geometry.vertexes = v';
            geometry.colors = c';
            geometry.faces = f';
        end
        
        %Add a room into listOfRoomss
        function listOfRooms = addRoomIntoList(obj, listOfRooms, name, level, geometry, isCeiling)
            %If room already exists => update room
            count = length(listOfRooms);
            for i = 1 : count
                room = listOfRooms(i);
                if strcmpi(room.name, name) && room.level == level
                    if isCeiling
                        room.ceiling = room.ceiling.concat(geometry);
                    else
                        room.body = room.body.concat(geometry);
                    end
                    listOfRooms(i) = room;
                    return;
                end
            end

            %Orelse, create new room and add it into list
            room = RoomEntity(name, level);
            if isCeiling
                room.ceiling = geometry;
            else
                room.body = geometry;
            end

            if count == 0
                listOfRooms = [room];
            else
                listOfRooms(count + 1) = room;
            end
        end

        function result = readJsonFile(obj, fileName)
            fid = fopen(fileName, 'r');
            if fid == -1
                error('File coule not be opened, check name or path.');
            end
            raw = fread(fid,inf);
            str = char(raw');
            fclose(fid);

            result = jsondecode(str);
        end
    end
end
