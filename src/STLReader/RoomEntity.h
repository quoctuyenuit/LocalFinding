#pragma once
#ifndef _ROOM_ENTITY_H_
#define _ROOM_ENTITY_H_

#include "ModelData.h"
#include <string>
#include <tuple>
#include <iostream>
using namespace std;

class RoomEntity {
private:
    int level;
    string name;
    
public:
    ModelData ceiling;
    ModelData body;
    
    RoomEntity(string name, int level);
    
    bool operator ==(const RoomEntity& room) const;
    
    tuple<CharArray, TypedArray<int>, StructArray, StructArray> parseDataToStruct();
};
//=============================================================================
//cpp Source code
//=============================================================================
RoomEntity::RoomEntity(string name, int level) {
    this->name = name;
    this->level = level;
}

bool RoomEntity::operator ==(const RoomEntity& room) const {
    return (this->name.compare(room.name) == 0 )&& this->level == room.level;
}

tuple<CharArray, TypedArray<int>, StructArray, StructArray> RoomEntity::parseDataToStruct() {
    ArrayFactory factory;
    StructArray ceilingStruct = factory.createStructArray({ 1,1 },{"vertexes", "colors", "faces"} );
    StructArray bodyStruct = factory.createStructArray({ 1,1 },{"vertexes", "colors", "faces"} );
    
    ceilingStruct[0]["vertexes"] = this->ceiling.getVertexesArray();
    ceilingStruct[0]["colors"] = this->ceiling.getColorsArray();
    ceilingStruct[0]["faces"] = this->ceiling.getFacesArray();
    
    bodyStruct[0]["vertexes"] = this->body.getVertexesArray();
    bodyStruct[0]["colors"] = this->body.getColorsArray();
    bodyStruct[0]["faces"] = this->body.getFacesArray();
    
    return make_tuple(factory.createCharArray(name), factory.createScalar<int>(level), ceilingStruct, bodyStruct);
}
#endif _ROOM_ENTITY_H_