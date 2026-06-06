#pragma once
#include "ofMain.h"
#include "ofxAssimpModelLoader.h"

class ofApp : public ofBaseApp {
public:
    void setup();
    void update();
    void draw();
    void keyPressed(int key);

    ofShader shader;
    ofMesh mesh; // 
    ofxAssimpModelLoader myModel;

    int cameraMode;          
    int lightBlueEnabled;    
    int materialMode;        
    int shaderActive;        

    glm::vec3 cameraPositions[3];
    glm::vec3 cameraLookAt;
};