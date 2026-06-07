#version 330 core

// Estas ubicaciones son obligatorias en openFrameworks
layout (location = 0) in vec4 position;
layout (location = 2) in vec3 normal;
layout (location = 3) in vec2 texcoord;

uniform mat4 u_modelMatrix;
uniform mat4 u_modelViewProjectionMatrix;

out vec3 v_normal;
out vec3 v_fragPos;
out vec2 v_texCoord;

void main() {
    v_fragPos = vec3(u_modelMatrix * position);
    
    // Cálculo matemáticamente estricto de la matriz normal para evitar deformación por escala
    mat3 normalMatrix = transpose(inverse(mat3(u_modelMatrix)));
    v_normal = normalize(normalMatrix * normal);
    
    v_texCoord = texcoord;
    
    gl_Position = u_modelViewProjectionMatrix * position;
}