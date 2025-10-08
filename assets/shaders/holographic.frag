uniform vec2 resolution;
uniform float time;
varying vec2 vUv;

void main() {
  vec2 uv = vUv;
  float glow = sin(time + uv.x * 10.0) * cos(time + uv.y * 10.0) * 0.5 + 0.5;
  vec3 color = vec3(1.0, 0.41, 0.71) * glow; // #FF69B4
  gl_FragColor = vec4(color, 0.2);
}
