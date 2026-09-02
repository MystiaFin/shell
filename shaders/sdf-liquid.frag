#version 440

// QML and this uniform block intentionally support at most eight shapes.
#define MAX_SHAPES 8

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 surfaceSize;
    float edgeOffset;
    float connectionRadius;
    int shapeCount;
    vec4 shape0;
    vec4 shape1;
    vec4 shape2;
    vec4 shape3;
    vec4 shape4;
    vec4 shape5;
    vec4 shape6;
    vec4 shape7;
    float radius0;
    float radius1;
    float radius2;
    float radius3;
    float radius4;
    float radius5;
    float radius6;
    float radius7;
    vec4 liquidColor;
};

float roundedRectangleDistance(vec2 point, vec4 rectangle, float radius) {
    vec2 halfSize = rectangle.zw * 0.5;
    vec2 center = rectangle.xy + halfSize;
    float safeRadius = min(radius, min(halfSize.x, halfSize.y));
    vec2 offset = abs(point - center) - halfSize + safeRadius;

    return min(max(offset.x, offset.y), 0.0)
        + length(max(offset, vec2(0.0)))
        - safeRadius;
}

float smoothUnion(float first, float second, float radius) {
    float safeRadius = max(radius, 0.001);
    float blend = clamp(0.5 + 0.5 * (second - first) / safeRadius, 0.0, 1.0);

    return mix(second, first, blend) - safeRadius * blend * (1.0 - blend);
}

void main() {
    vec2 point = qt_TexCoord0 * surfaceSize;
    float edgeDistance = min(
        min(point.x, surfaceSize.x - point.x),
        min(point.y, surfaceSize.y - point.y)
    );
    float distance = edgeDistance + edgeOffset;

    if (shapeCount > 0) distance = smoothUnion(distance, roundedRectangleDistance(point, shape0, radius0), connectionRadius);
    if (shapeCount > 1) distance = smoothUnion(distance, roundedRectangleDistance(point, shape1, radius1), connectionRadius);
    if (shapeCount > 2) distance = smoothUnion(distance, roundedRectangleDistance(point, shape2, radius2), connectionRadius);
    if (shapeCount > 3) distance = smoothUnion(distance, roundedRectangleDistance(point, shape3, radius3), connectionRadius);
    if (shapeCount > 4) distance = smoothUnion(distance, roundedRectangleDistance(point, shape4, radius4), connectionRadius);
    if (shapeCount > 5) distance = smoothUnion(distance, roundedRectangleDistance(point, shape5, radius5), connectionRadius);
    if (shapeCount > 6) distance = smoothUnion(distance, roundedRectangleDistance(point, shape6, radius6), connectionRadius);
    if (shapeCount > 7) distance = smoothUnion(distance, roundedRectangleDistance(point, shape7, radius7), connectionRadius);

    float antialiasWidth = max(fwidth(distance), 0.001);
    float alpha = 1.0 - smoothstep(-antialiasWidth, antialiasWidth, distance);

    fragColor = vec4(liquidColor.rgb * alpha, liquidColor.a * alpha) * qt_Opacity;
}
