#include <flutter/runtime_effect.glsl>

uniform float uTime; // TIME
uniform vec2 uSize;  // COMPONETE SIZE
uniform sampler2D uTexture; // COMPONETE TEXTURE

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  fragColor =  texture(uTexture, uv);
}