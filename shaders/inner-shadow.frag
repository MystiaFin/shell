#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 surfaceSize;
    float cornerRadius;
    float shadowSize;
    vec4 shadowColor;
};

float roundedRectangleDistance(vec2 point, vec2 size, float radius) {
    vec2 halfSize = size * 0.5;
    float safeRadius = min(radius, min(halfSize.x, halfSize.y));
    vec2 offset = abs(point - halfSize) - halfSize + safeRadius;

    return min(max(offset.x, offset.y), 0.0)
        + length(max(offset, vec2(0.0)))
        - safeRadius;
}

void main() {
    vec2 point = qt_TexCoord0 * surfaceSize;
    float distance = roundedRectangleDistance(point, surfaceSize, cornerRadius);
    float antialiasWidth = max(fwidth(distance), 0.001);
    float inside = 1.0 - smoothstep(-antialiasWidth, antialiasWidth, distance);
    float shadow = 1.0 - smoothstep(0.0, max(shadowSize, 0.001), -distance);
    float alpha = shadowColor.a * inside * shadow;

    fragColor = vec4(shadowColor.rgb * alpha, alpha) * qt_Opacity;
}
