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
            listOfRooms = [];
            %--------------------------------------------------------------
            %read model data
            %--------------------------------------------------------------
            resources = dir(interactor.resourcePath);
            %Remove two first rows, cause two first row is '.' and '..',it's not neccessory
            resources(1:2, :) = [];
            %--------------------------------------------------------------
            [rows,~] = size(resources);
            for i = 1: rows
                if contains(resources(i).name, '.stl')
                    path = strcat(resources(i).folder, '/', resources(i).name);

                    readResult = interactor.readSTLFileFromMex(path);

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
                        floor = str2double(splitResult(2));
                    catch
                        name = 'UnKnown';
                        floor = 0;
                        isCeiling = 0;
                    end

                    listOfRooms = interactor.addRoomIntoList(listOfRooms, name, floor, readResult, isCeiling);
                end
            end
        end
    end

    methods (Access = private)
        %Add a room into listOfRoomss
        function listOfRooms = addRoomIntoList(obj, listOfRooms, name, floor, geometry, isCeiling)
            %If room already exists => update room
            count = length(listOfRooms);
            for i = 1 : count
                room = listOfRooms(i);
                if strcmpi(room.name, name) && room.floor == floor
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
            room = RoomEntity(name, floor);
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

        function result = readSTLFileFromMex(obj, fileName)
            [v, c, f] = STLReader(fileName);
            result = Geometry(v', f', c');
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
