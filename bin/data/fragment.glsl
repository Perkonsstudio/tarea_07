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
    // =========================================================
    // 1. CALCULO DE NORMALES
    // =========================================================
    vec3 N = v_normal;
    
    // Si el OBJ no mandó normales (el vector mide casi 0), usamos cálculo de derivadas en GPU
    if (length(N) < 0.1) {
        N = cross(dFdx(v_fragPos), dFdy(v_fragPos));
    }
    N = normalize(N);

    vec3 V = normalize(u_viewPos - v_fragPos);

    // Si el modelo está "volteado" y la normal apunta hacia adentro, la forzamos hacia la cámara
    if (dot(N, V) < 0.0) {
        N = -N;
    }

    // =========================================================
    // 2. CONFIGURACIÓN DE MATERIALES
    // =========================================================
    vec3 matAmbient;
    vec3 matDiffuse;
    vec3 matSpecular;
    float matShininess;

    if (u_materialMode == 0) {
        // Material A
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

    // =========================================================
    // 3. TEXTURA PROCEDURAL
    // =========================================================
    if (u_shaderActive == 1) {
        float scale = 0.05; 
        int check = int(floor(v_fragPos.x * scale) + floor(v_fragPos.y * scale) + floor(v_fragPos.z * scale)) % 2;
        if (check == 0) {
            matDiffuse *= vec3(0.3, 0.4, 0.3); // Verde
        } else {
            matDiffuse *= vec3(0.9, 0.8, 0.6); // Crema
        }
    }

    vec3 finalLighting = vec3(0.0);

    // =========================================================
    // LUZ 1: Luz Blanca (Siempre Encendida)
    // =========================================================
    vec3 l1Pos = vec3(300.0, 400.0, 500.0); 
    vec3 l1Color = vec3(1.0, 1.0, 1.0); 
    
    vec3 ambient1 = l1Color * matAmbient;
    vec3 l1Dir = normalize(l1Pos - v_fragPos);
    
    // Ahora dot(N, L) nunca fallará gracias a nuestro bloque blindado
    float diff1 = max(dot(N, l1Dir), 0.0);
    vec3 diffuse1 = l1Color * (diff1 * matDiffuse);
    
    vec3 h1 = normalize(l1Dir + V);
    float spec1 = pow(max(dot(N, h1), 0.0), matShininess);
    vec3 specular1 = l1Color * (spec1 * matSpecular);
    
    finalLighting += (ambient1 + diffuse1 + specular1);

    // =========================================================
    // LUZ 2: Luz Azul Interactiva
    // =========================================================
    if (u_lightBlueEnabled == 1) {
        vec3 l2Pos = vec3(-300.0, 200.0, 400.0); 
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

    // =========================================================
    // SALIDA Y GAMMA
    // =========================================================
    if (u_shaderActive == 0) {
        FragColor = vec4(matDiffuse, 1.0);
    } else {
        vec3 gammaCorrected = pow(finalLighting, vec3(1.0 / 2.2));
        FragColor = vec4(gammaCorrected, 1.0);
    }
}