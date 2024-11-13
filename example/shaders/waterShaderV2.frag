#include <flutter/runtime_effect.glsl>

uniform float uTime; // TIME
uniform vec2 uSize;  // COMPONETE SIZE
uniform sampler2D uTexture; // COMPONETE TEXTURE

uniform sampler2D uNoise;
uniform sampler2D uSecondNoise;
uniform vec2 scroll;
uniform vec4 toneColor;

out vec4 fragColor;

void main() {
  vec2 scroll2 = scroll * -1;
  float distortion_strength = 0.01;
 
  vec2 uv = FlutterFragCoord().xy / uSize;

  vec2 scrolledUV = fract(uv + scroll * uTime);
  vec2 scrolledUV2 = fract(uv + scroll2 * uTime);

  float depth = texture(uNoise,scrolledUV +scroll).r * texture(uSecondNoise,scrolledUV2 +scroll).r;

  vec4 screen_col = texture(uTexture, uv +distortion_strength * vec2(depth));
  vec4 light_color = vec4(1.0, 1.0, 1.0, 1.0);
  vec4 topLight = smoothstep(0.4,0.5,depth) * light_color;
  fragColor = mix(screen_col+topLight ,toneColor,0.7);
}
