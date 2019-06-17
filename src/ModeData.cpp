#include "ModelData.h"
#include <iostream>
#include <string>
#include <vector>
#include "mex.hpp"
#include "mexAdapter.hpp"

Array ModelData::getArray(std::vector<double> data) {
    unsigned long dataSize = data.size();
    ArrayFactory factory;
    auto data_p = factory.createBuffer<double>(dataSize);
    //--------------------------------------------------------------------------
    //fill data
    //--------------------------------------------------------------------------
    double* dataPtr = data_p.get();
    std::copy(data.begin(), data.end(), dataPtr);
    
    return factory.createArrayFromBuffer({ 3, dataSize / 3 }, std::move(data_p));
}

int ModelData::getNumberOfVertexes() {
    return vertexes.size() / 3;
}


void ModelData::setColorsIfNotExists() {
    if (colors.size() == 0) {
        int numberOfVertexes = getNumberOfVertexes();
        for(int i = 0; i < numberOfVertexes; i++) {
            colors.push_back(0.2980); //R
            colors.push_back(0.5725); //G
            colors.push_back(0.6863); //B
        }
    }
}

ModelData& ModelData::operator +=(const ModelData& data) {
    // if (this->vertexes.size() == 0) {
    //   *this = data;
    //   return *this;
    // }
    
    this->vertexes.insert( this->vertexes.end(), data.vertexes.begin(), data.vertexes.end());
    this->colors.insert( this->colors.end(), data.colors.begin(), data.colors.end());
    int sizeOfData = data.vertexes.size() / 3;
    
    int lastFace = this->faces.size() > 0 ? this->faces.back() : 0;
    
    for (int i=lastFace + 1; i<= lastFace + sizeOfData; i++) {
        this->faces.push_back(i);
    }
    
    return *this;
}

ModelData& ModelData::operator =(const ModelData& data) {
    this->vertexes = data.vertexes;
    this->colors = data.colors;
    int sizeOfData = data.vertexes.size() / 3;
    
    this->faces.clear();
    for (int i = 1; i<= sizeOfData; i++) {
        this->faces.push_back(i);
    }
    
    return *this;
}

//============================================================================
//Mapping function
//============================================================================
Array ModelData::getVertexesArray() {
    return this->getArray(this->vertexes);
}

Array ModelData::getFacesArray() {
    return this->getArray(this->faces);
}

Array ModelData::getColorsArray() {
    return this->getArray(this->colors);
}

StructArray ModelData::parseDataToStruct() {
    ArrayFactory factory;
    StructArray data = factory.createStructArray({ 1,1 },{"vertexes", "colors", "faces"} );
    data[0]["vertexes"] = this->getVertexesArray();
    data[0]["colors"] = this->getColorsArray();
    data[0]["faces"] = this->getFacesArray();
    
    return data;
}
