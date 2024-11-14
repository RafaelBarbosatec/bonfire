#include <flutter/runtime_effect.glsl>

uniform float uTime; // TIME
uniform vec2 uSize;  // COMPONETE SIZE
uniform sampler2D uTexture; // COMPONETE TEXTURE

uniform float distortionStrength;
uniform sampler2D uNoise;
uniform sampler2D uSecondNoise;
uniform vec2 scroll;
uniform vec4 toneColor;
uniform vec4 lightColor;
uniform float opacity;
uniform vec2 lightRange;

out vec4 fragColor;

void main() {
  vec2 scroll2 = scroll * -1;
 
  vec2 uv = FlutterFragCoord().xy / uSize;

  vec2 scrolledUV = fract(uv + scroll * uTime);
  vec2 scrolledUV2 = fract(uv + scroll2 * uTime);

  float depth = texture(uNoise,scrolledUV).r * texture(uSecondNoise,scrolledUV2 ).r;

  vec4 screen_col = texture(uTexture, uv + distortionStrength * vec2(depth));
  vec4 topLight = smoothstep(lightRange.x, lightRange.y, depth) * lightColor;
  fragColor = mix(screen_col+topLight ,toneColor, opacity);
}
