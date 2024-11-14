#include <flutter/runtime_effect.glsl>

uniform float uTime; // TIME
uniform vec2 uSize;  // COMPONETE SIZE
uniform sampler2D uTexture; // COMPONETE TEXTURE

uniform sampler2D uNoise;
uniform vec2 scroll;
uniform vec4 toneColor;

out vec4 fragColor;

void main() {
  float distortion_strength = 0.01;
 
  vec2 uv = FlutterFragCoord().xy / uSize;

  vec2 scrolledUV = fract(uv + scroll * uTime);

  vec4 noise_col = texture(uNoise, scrolledUV);
  
  vec2 distorted_uv = uv + (noise_col.rg * 2.0 - 1.0) * distortion_strength;
  
  vec4 screen_col = texture(uTexture, distorted_uv);

  fragColor = mix(screen_col,toneColor,0.6);
}
