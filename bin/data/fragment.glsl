#version 330 core
out vec4 FragColor;

in vec3 v_normal;
in vec3 v_fragPos;
in vec2 v_texCoord;

uniform vec3 u_viewPos;
uniform int u_lightBlueEnabled;
uniform int u_materialMode;
uniform int u_shaderActive;

void main() {
    vec3 N = normalize(v_normal);
    vec3 V = normalize(u_viewPos - v_fragPos);

    vec3 matAmbient;
    vec3 matDiffuse;
    vec3 matSpecular;
    float matShininess;

    // ---------------------------------------------------------
    // Materiales
    // ---------------------------------------------------------
    if (u_materialMode == 0) {
        // Material A (El ambiente DEBE ser 0 por rúbrica)
        matAmbient  = vec3(0.0, 0.0, 0.0);
        matDiffuse  = vec3(0.50, 0.50, 0.50);
        matSpecular = vec3(0.70, 0.70, 0.70);
        matShininess = 32.0;
    } else {
        // Material B
        matAmbient  = vec3(0.23125, 0.23125, 0.23125);
        matDiffuse  = vec3(0.2775, 0.2775, 0.2775);
        matSpecular = vec3(0.773911, 0.773911, 0.773911);
        matShininess = 89.6;
    }

    // ---------------------------------------------------------
    // Textura: Escala ajustada al multiplicador 90x del modelo
    // ---------------------------------------------------------
    if (u_shaderActive == 1) {
        float scale = 0.20; //muevele aca
        int check = int(floor(v_fragPos.x * scale) + floor(v_fragPos.y * scale) + floor(v_fragPos.z * scale)) % 2;
        if (check == 0) {
            matDiffuse *= vec3(0.3, 0.4, 0.3); // Verde
        } else {
            matDiffuse *= vec3(0.9, 0.8, 0.6); // Crema
        }
    }

    vec3 finalLighting = vec3(0.0);

    // ---------------------------------------------------------
    // LUZ 1: Luz Blanca Frontal-Derecha
    // ---------------------------------------------------------
    vec3 l1Pos = vec3(300.0, 400.0, 500.0); // AQUI
    vec3 l1Color = vec3(1.0, 1.0, 1.0); 
    
    vec3 ambient1 = l1Color * matAmbient;
    vec3 l1Dir = normalize(l1Pos - v_fragPos);
    float diff1 = max(dot(N, l1Dir), 0.0);
    vec3 diffuse1 = l1Color * (diff1 * matDiffuse);
    
    vec3 h1 = normalize(l1Dir + V);
    float spec1 = pow(max(dot(N, h1), 0.0), matShininess);
    vec3 specular1 = l1Color * (spec1 * matSpecular);
    
    finalLighting += (ambient1 + diffuse1 + specular1);

    // ---------------------------------------------------------
    // LUZ 2: Luz Azul Frontal-Izquierda (Rellena las sombras negras)
    // ---------------------------------------------------------
    if (u_lightBlueEnabled == 1) {
        vec3 l2Pos = vec3(-300.0, 200.0, 400.0); // Del lado opuesto a la luz blanca
        vec3 l2Color = vec3(0.2, 0.2, 1.2); 
        
        vec3 ambient2 = l2Color * matAmbient;
        vec3 l2Dir = normalize(l2Pos - v_fragPos);
        float diff2 = max(dot(N, l2Dir), 0.0);
        vec3 diffuse2 = l2Color * (diff2 * matDiffuse);
        
        vec3 h2 = normalize(l2Dir + V);
        float spec2 = pow(max(dot(N, h2), 0.0), matShininess);
        vec3 specular2 = l2Color * (spec2 * matSpecular);
        
        finalLighting += (ambient2 + diffuse2 + specular2);
    }

    // ---------------------------------------------------------
    // Salida Final con Gamma Original
    // ---------------------------------------------------------
    if (u_shaderActive == 0) {
        FragColor = vec4(matDiffuse, 1.0);
    } else {
        vec3 gammaCorrected = pow(finalLighting, vec3(1.0 / 2.2));
        FragColor = vec4(gammaCorrected, 1.0);
    }
}