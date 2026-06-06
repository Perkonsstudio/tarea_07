#include "ofApp.h"

void ofApp::setup() {
    ofSetBackgroundColor(15, 15, 15);
    ofSetWindowShape(1024, 768); // Cumple con creces las dimensiones mínimas
    ofEnableDepthTest();

    // 1. Carga el modelo OBJ
    myModel.loadModel("bunny.obj", true);
    myModel.setScaleNormalization(false);
    myModel.setRotation(0, 180, 0, 1, 0); 
    mesh = myModel.getMesh(0);

    // normales del OBJ
    if (mesh.getNormals().empty() && mesh.getNumVertices() >= 3) {
        for (size_t i = 0; i < mesh.getNumVertices(); i++) {
            mesh.addNormal(glm::vec3(0.0f, 0.0f, 1.0f)); // Vector base temporal
        }
        for (size_t i = 0; i < mesh.getNumVertices(); i += 3) {
            if (i + 2 < mesh.getNumVertices()) {
                glm::vec3 v0 = mesh.getVertex(i);
                glm::vec3 v1 = mesh.getVertex(i + 1);
                glm::vec3 v2 = mesh.getVertex(i + 2);
                
                // Producto cruz para obtener la normal perpendicular a la cara
                glm::vec3 arista1 = v1 - v0;
                glm::vec3 arista2 = v2 - v0;
                glm::vec3 normalCalculada = glm::normalize(glm::cross(arista1, arista2));
                
                mesh.setNormal(i, normalCalculada);
                mesh.setNormal(i + 1, normalCalculada);
                mesh.setNormal(i + 2, normalCalculada);
            }
        }
    }

    // 2. Cargar el par de Shaders
    shader.load(ofToDataPath("vertex.glsl"), ofToDataPath("fragment.glsl"));

    // Inicializar estados
    cameraMode = 0;
    lightBlueEnabled = 1; // La luz azul inicia encendida
    materialMode = 0;     // Inicia con Material A
    shaderActive = 1;     // Inicia con iluminación sofisticada activa

    // 3. orientaciones de cámara
    cameraPositions[0] = glm::vec3(0.0f, 150.0f, 450.0f);  // Frente elevado
    cameraPositions[1] = glm::vec3(400.0f, 100.0f, 250.0f); // Lateral derecha
    cameraPositions[2] = glm::vec3(0.0f, 450.0f, 10.0f);   // Vista Zenital
    cameraLookAt = glm::vec3(0.0f, 50.0f, 0.0f);            // Centro del modelo
}

void ofApp::update() {
}

void ofApp::draw() {    
    // Configurar matrices de vista y proyección en perspectiva
    ofCamera cam;
    cam.setFov(45.0f);
    cam.setPosition(cameraPositions[cameraMode]);
    cam.lookAt(cameraLookAt, glm::vec3(0, 1, 0));

    cam.begin();
    shader.begin();

    // Matrices de escalado para que el modelo se aprecie a la distancia de la cámara
    glm::mat4 scaleMatrix = glm::scale(glm::vec3(90.0f, 90.0f, 90.0f));//AQUI
    glm::mat4 modelMatrix = glm::translate(glm::vec3(0, -50.0f, 0)) * scaleMatrix;
    
    glm::mat4 viewMatrix = cam.getModelViewMatrix();
    glm::mat4 projectionMatrix = cam.getProjectionMatrix();
    glm::mat4 modelViewProjectionMatrix = projectionMatrix * viewMatrix * modelMatrix;

    shader.setUniformMatrix4f("u_modelMatrix", modelMatrix);
    shader.setUniformMatrix4f("u_modelViewProjectionMatrix", modelViewProjectionMatrix);
    shader.setUniform3f("u_viewPos", cameraPositions[cameraMode]);

    shader.setUniform1i("u_lightBlueEnabled", lightBlueEnabled);
    shader.setUniform1i("u_materialMode", materialMode);
    shader.setUniform1i("u_shaderActive", shaderActive);

    // Dibuja la geometría
    //myModel.drawFaces();
    mesh.draw();

    shader.end();
    cam.end();
}

void ofApp::keyPressed(int key) {
    // Control de cámaras
    if (key == '1') cameraMode = 0;
    if (key == '2') cameraMode = 1;
    if (key == '3') cameraMode = 2;

    // Control de encendido/apagado de Luz Azul
    if (key == 'L' || key == 'l') {
        lightBlueEnabled = (lightBlueEnabled == 1) ? 0 : 1;
    }

    // Alternar propiedades de Materiales A y B
    if (key == 'M' || key == 'm') {
        materialMode = (materialMode == 0) ? 1 : 0;
    }

    // Activar/Desactivar Shader de textura e iluminación
    if (key == 'S' || key == 's') {
        shaderActive = (shaderActive == 1) ? 0 : 1;
    }
}