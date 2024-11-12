#include <flutter/runtime_effect.glsl>

uniform float uTime;
uniform vec2 uSize;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
  vec2 scroll = vec2(0.5,0.2);
  vec2 uv = FlutterFragCoord().xy / uSize;
  vec4 color = texture(uTexture, uv);
 float gray = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));
  fragColor = vec4(vec3(gray), color.a);
}