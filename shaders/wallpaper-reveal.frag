#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 surfaceSize;
    vec2 revealCenter;
    float revealRadius;
    float edgeSoftness;
};

layout(binding = 1) uniform sampler2D source;

void main() {
    vec2 point = qt_TexCoord0 * surfaceSize;
    float distanceFromCenter = length(point - revealCenter);
    float alpha = 1.0 - smoothstep(
        revealRadius - edgeSoftness,
        revealRadius + edgeSoftness,
        distanceFromCenter
    );
    vec4 color = texture(source, qt_TexCoord0);

    fragColor = color * alpha * qt_Opacity;
}
