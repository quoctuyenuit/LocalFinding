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

#define kCeiling "ceiling"
#define kBody "body"
#define kName "name"
#define kLevel "level"
#define kVertexes "vertex"
#define kColor "color"
#define kFaces "faces"


using namespace matlab::mex;
using namespace matlab::data;
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

    /* This is the gateway routine for the MEX-file. */
    void operator()(ArgumentList outputs, ArgumentList inputs)
    {
        // checkArguments (outputs,inputs);

        ArrayFactory factory;
        StructArray const matlabStructArray = inputs[0];
        matlab::data::TypedArray<double> doubleArray = inputs[1];
        int level = (int)doubleArray[0];
        std::cout << level << '\n';
        // checkStructureElements(matlabStructArray);
        size_t total_num_of_elements = matlabStructArray.getNumberOfElements();

        auto fields = matlabStructArray.getFieldNames();
        std::vector<std::string> fieldNames(fields.begin(), fields.end());

        std::for_each(fieldNames.begin(), fieldNames.end(), [](string name){ std::cout << name << '\n';});

        for (size_t entryIndex=0; entryIndex<total_num_of_elements; entryIndex++) {
          matlab::data::TypedArray<int32_t> levelArr = matlabStructArray[entryIndex][kLevel];
          matlab::data::CharArray nameArr = matlabStructArray[entryIndex][kName];
          matlab::data::StructArray bodyStruct = matlabStructArray[entryIndex][kBody];
          matlab::data::StructArray ceilingStruct = matlabStructArray[entryIndex][kCeiling];
          std::cout << levelArr[0] << '\n';
          // std::cout << nameArr.toAscii() << '\n';
        }

        outputs[0] = matlabStructArray;
    }

    void printExample(matlab::data::StructArray modelData) {
      size_t totle = modelData.getNumberOfElements();
      for (size_t entryIndex=0; entryIndex<total_num_of_elements; entryIndex++) {
        
      }
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
