/* ========================================================================
 * C++ source code to read stl file and mapping it to vertexes, colors and faces.
 * VIETNAM National University HCM - University Of Information Technology
 * This is a MEX-file for MATLAB.
 * Copyright 2019
 *=======================================================================*/

#include <fstream>
#include <vector>
#include <future>
#include "mex.hpp"
#include "mexAdapter.hpp"
#include <string>
#include <memory>
#include <iostream>
#include <optional>
#include <tuple>
#include <stdlib.h>
using namespace std;

#define kVERTEX "vertex"
#define kCOLOR "color"
#define fName "name"
#define fFolderPath "folderPath"


using namespace matlab::mex;
using namespace matlab::data;
//==============================================================================
//Body
//==============================================================================


class ModelData {
private:
    Array getArray(std::vector<double> data) {
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
public:
    std::vector<double> vertexes;
    std::vector<double> colors;
    std::vector<double> faces;

    void updateData(const ModelData& data) {
      this->vertexes.insert( this->vertexes.end(), data.vertexes.begin(), data.vertexes.end());
      this->colors.insert( this->colors.end(), data.colors.begin(), data.colors.end());
    }

    int getNumberOfVertexes() {
        return vertexes.size() / 3;
    }

    void setFaces() {
        faces.clear();
        int size = vertexes.size() / 3;
        for (int i = 1; i <= size; i++)
            faces.push_back(i);
    }

    void setColorsIfNotExists() {
        if (colors.size() == 0) {
            int numberOfVertexes = getNumberOfVertexes();
            for(int i = 0; i < numberOfVertexes; i++) {
                colors.push_back(0.2980); //R
                colors.push_back(0.5725); //G
                colors.push_back(0.6863); //B
            }
        }
    }

    //============================================================================
    //Mapping function
    //============================================================================
    Array getVertexesArray() {
        return this->getArray(this->vertexes);
    }

    Array getFacesArray() {
        return this->getArray(this->faces);
    }

    Array getColorsArray() {
        return this->getArray(this->colors);
    }
};

class RoomEntity {
private:
    int level;
    string name;

public:
    ModelData ceiling;
    ModelData body;

    RoomEntity(string name, int level) {
        this->name = name;
        this->level = level;
    }

    bool operator ==(const RoomEntity& room) const {
      return (this->name.compare(room.name) == 0 )&& this->level == room.level;
    }

    tuple<CharArray, TypedArray<int>, StructArray, StructArray> parseDataToStruct() {
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
};

//==============================================================================
//Mex Function
//==============================================================================
//==============================================================================
class MexFunction : public Function {
private:
    std::shared_ptr<matlab::engine::MATLABEngine> matlabPtr;
public:
    /* Constructor for the class. */
    MexFunction()
    {
        matlabPtr = getEngine();
    }

    /* Helper function to print output string on MATLAB command prompt. */
    void displayOnMATLAB(std::ostringstream stream)
    {
        ArrayFactory factory;
        matlabPtr->feval(matlab::engine::convertUTF8StringToUTF16String("fprintf"),0, std::vector<Array>
                ({ factory.createScalar(stream.str())}));
    }

    /* Helper function to generate an error message from given string,
     * and display it over MATLAB command prompt.
     */
    void displayError(std::string errorMessage)
    {
        ArrayFactory factory;
        matlabPtr->feval(matlab::engine::convertUTF8StringToUTF16String("error"),
                0, std::vector<Array>({
            factory.createScalar(errorMessage) }));
    }

    static vector<string> split(const string& str, const string& delim) {
        vector<string> tokens;
        size_t prev = 0, pos = 0;
        do
        {
            pos = str.find(delim, prev);
            if (pos == string::npos) pos = str.length();
            string token = str.substr(prev, pos-prev);
            if (!token.empty()) tokens.push_back(token);
            prev = pos + delim.length();
        }
        while (pos < str.length() && prev < str.length());
        return tokens;
    }

    static void getDataInLine(string stringInLine, string key, vector<double> &data) {
        std::vector<string> vString = split(stringInLine, " ");
        for (auto i = vString.cbegin(); i != vString.cend(); ++i)
        {
            string dataString = *i;
            if (dataString.find(key) == std::string::npos) {
                data.push_back(stod(dataString.c_str()));
            }
        }
    }

    //Room Name
    //Room Floor
    //isCeiling //determine whether this file is room ceiling or not
    static tuple<string, int, bool> parseRoomInformation(string fileName) {
      std::vector<string> vString = split(fileName, "_");
      string name = vString[0]; //-> get name
      int level = atoi(vString[1].c_str()); //-> get level
      bool isCeiling = vString.size() < 3 ? false : vString[2].at(0) == '0';
      return make_tuple(name, level, isCeiling);
    }

    static tuple<string, int, bool, ModelData> readSTLFile(string folderPath, string fileName) {
        tuple<string, int, bool> roomInfor = parseRoomInformation(fileName);
        string line;
        ifstream myfile (folderPath + "/" + fileName);
        ModelData data;

        if (myfile.is_open())
        {
            while ( getline (myfile,line) )
            {
                if (line.find(kVERTEX) != std::string::npos) {
                    getDataInLine(line, kVERTEX, data.vertexes);
                } else if (line.find(kCOLOR) != std::string::npos) {
                    getDataInLine(line, kCOLOR, data.colors);
                }
            }
            data.setColorsIfNotExists();
            myfile.close();
        }
        else {
          std::cout << "Unable to read file" + fileName << '\n';
        }

        return make_tuple(get<0>(roomInfor), get<1>(roomInfor),get<2>(roomInfor), data);
    }

    /* This is the gateway routine for the MEX-file. */
    void operator()(ArgumentList outputs, ArgumentList inputs)
    {
        checkArguments (outputs,inputs);

        ArrayFactory factory;
        StructArray const matlabStructArray = inputs[0];
        // checkStructureElements(matlabStructArray);
        auto listOfRooms = this->retrieveData(matlabStructArray);

        unsigned long resultSize = listOfRooms.size();
        StructArray result = factory.createStructArray({resultSize, 1},{"ceiling", "body", "name", "level"});

        unsigned long index = 0;
        std::for_each(listOfRooms.begin(), listOfRooms.end(), [&](RoomEntity room){
           tuple<CharArray, TypedArray<int>, StructArray, StructArray> parseData = room.parseDataToStruct();
           result[index]["name"] = get<0>(parseData);
           result[index]["level"] = get<1>(parseData);
           result[index]["ceiling"] = get<2>(parseData);
           result[index++]["body"] = get<3>(parseData);
        });

        outputs[0] = result;
    }

    std::vector<RoomEntity> retrieveData(const StructArray & matlabStructArray) {
      size_t numberOfFile = matlabStructArray.getNumberOfElements();            //Get number of file to read
      std::vector<RoomEntity> listOfRooms;
      //------------------------------------------------------------------------
      //setup vector of async task to read data
      //------------------------------------------------------------------------
      std::vector<std::future< tuple<string, int, bool, ModelData> >> vFuture;

      for (size_t entryIndex=0; entryIndex<numberOfFile; entryIndex++) {
          matlab::data::CharArray const nameCharArray = matlabStructArray[entryIndex][fName];
          matlab::data::CharArray const folderPathCharArray = matlabStructArray[entryIndex][fFolderPath];
          string fileName = nameCharArray.toAscii();
          if (fileName.find(".stl") != std::string::npos) {
            string folderPath = folderPathCharArray.toAscii();
            vFuture.push_back(std::async(readSTLFile, folderPath, fileName));
        }
      }
      //------------------------------------------------------------------------
      //wait and get data from async task
      //------------------------------------------------------------------------
      for(auto fut = vFuture.begin(); fut != vFuture.end(); fut++) {
          tuple<string, int, bool, ModelData> result = (*fut).get();
          string name = get<0>(result);
          int level = get<1>(result);
          bool isCeiling = get<2>(result);
          ModelData data = get<3>(result);

          RoomEntity room(name, level);
          this->addToListOfRooms(listOfRooms, room, data, isCeiling);
      }

      std::for_each(listOfRooms.begin(), listOfRooms.end(), [](RoomEntity& room) {
        room.ceiling.setFaces();
        room.body.setFaces();
      });
      return listOfRooms;
    }

    void addToListOfRooms(std::vector<RoomEntity> &listOfRooms, RoomEntity& newRoom, const ModelData& data, bool isCeiling)  {
      int n = listOfRooms.size();
      for(int i = 0; i < n; i++) {
        if (listOfRooms[i] == newRoom) {
          if (isCeiling)
            listOfRooms[i].ceiling.updateData(data);
          else
            listOfRooms[i].body.updateData(data);
          return;
        }
      }
      if (isCeiling)
        newRoom.ceiling = data;
      else
        newRoom.body = data;

      listOfRooms.push_back(newRoom);
    }

    /* Helper function to information about an empty field in the structure. */
    void emptyFieldInformation(std::string fieldName, size_t index) {
        std::ostringstream stream;
        stream<<"Field: "<<std::string(fieldName)<<" of the element at index: "
                <<index+1<<" is empty."<<std::endl;
        displayOnMATLAB(std::move(stream));
    }

    /* Helper function to information about an invalid field in the structure. */
    void invalidFieldInformation(std::string fieldName, size_t index) {
        std::ostringstream stream;
        stream<<"Field: "<<std::string(fieldName)<<" of the element at index: "
                <<index+1<<" contains wrong value."<<std::endl;
        displayOnMATLAB(std::move(stream));
    }

    /* Make sure that the passed structure has valid data. */
    void checkStructureElements(StructArray const & matlabStructArray) {
        std::ostringstream stream;
        size_t nfields = matlabStructArray.getNumberOfFields();
        auto fields = matlabStructArray.getFieldNames();
        size_t total_num_of_elements = matlabStructArray.getNumberOfElements();
        std::vector<std::string> fieldNames(fields.begin(), fields.end());

        /* Produce error if structure has more than 2 fields. */
        if(nfields != 3) {
            displayError("Struct must consist of 3 entries."
                    "(First: char array, Second: numeric double scalar).");
        }

        /* Walk through each structure element. */
        for (size_t entryIndex=0; entryIndex<total_num_of_elements; entryIndex++) {
            const Array structField1 =
                    matlabStructArray[entryIndex][fieldNames[0]];
            const Array structField2 =
                    matlabStructArray[entryIndex][fieldNames[1]];

            /* Produce error if name field in structure is empty. */
            if (structField1.isEmpty()) {
                emptyFieldInformation(fieldNames[0],entryIndex);
                displayError("Empty fields are not allowed in this program."
                        "This field must contain character array.");
            }

            /* Produce error if phone number field in structure is empty. */
            if(structField2.isEmpty()) {
                emptyFieldInformation(fieldNames[1],entryIndex);
                displayError("Empty fields are not allowed in this program."
                        "This field must contain numeric double scalar.");
            }

            /* Produce error if name is not a valid character array. */
            if(structField1.getType()!= ArrayType::CHAR) {
                invalidFieldInformation(fieldNames[0],entryIndex);
                displayError("This field must contain character array.");
            }
            /* Produce error if phone number is not a valid double scalar. */
            if (structField2.getType() != ArrayType::CHAR) {
                invalidFieldInformation(fieldNames[1],entryIndex);
                displayError("This field must contain character array.");
            }

            /* Produce error if phone number is not a valid double scalar. */
            if (structField2.getType() != ArrayType::DOUBLE
                    || structField2.getNumberOfElements() != 1) {
                invalidFieldInformation(fieldNames[1],entryIndex);
                displayError("This field must contain numeric double scalar.");
            }
        }
    }

    /* This function makes sure that user has provided structure as input,
     * and is not expecting more than one output in results.
     */
    void checkArguments(ArgumentList outputs, ArgumentList inputs) {
        if (inputs.size() != 1) {
            displayError("One input required.");
        }
        if (outputs.size() > 1) {
            displayError("Too many outputs specified.");
        }
        if (inputs[0].getType() != ArrayType::STRUCT) {
            displayError("Input must be a structure.");
        }
    }
};
