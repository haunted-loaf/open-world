#[compute]
#version 450
#extension GL_GOOGLE_include_directive: require

#include "../terrains/utils.gdshaderinc"

float height(vec2 uv) {
  float h = fbm(uv / 1000.0, 10, 0.5, 0.0) * -2.0 + 1.0;
  if (h > 0.0)
    h = sign(h) * max(abs(h) / 10.0, pow(abs(h), 3.0));
  else
    h = -pow(abs(h), 1.5);
  h *= data.height_scale;
  // h -= pow(length(uv), 0.5) - 30.0;
  h -= 5.0;
  // h += 1.0 * fbm(uv * 100.0, 8, 0.7, 0.0);
  h = mix(-100, h, smoothstep(0.0, 512.0, -sdCircle(uv, 4096.0)));
  return h;
}

vec3 height_normal(vec2 uv) {
  vec3 ts = vec3(1.0, 1.0, 0.0);
  float h1 = height(uv + ts.xz);
  float h2 = height(uv + ts.zy);
  float x1 = height(uv - ts.xz);
  float x2 = height(uv + ts.xz);
  float y1 = height(uv - ts.zy);
  float y2 = height(uv + ts.zy);
  return normalize(vec3(x1 - x2, 2.0, y1 - y2));
}

// The code we want to execute in each invocation
void main() {
  ivec2 iuv = ivec2(gl_GlobalInvocationID.xy) + data.offset.xy;
  vec2 uv = vec2(iuv) / data.resolution - 0.5;
  float H = height(uv * data.world_scale);
  vec3 N = height_normal(uv * data.world_scale);
  imageStore(heights, iuv, vec4(H, N));
  // gl_GlobalInvocationID;
  // gl_GlobalInvocationID.x uniquely identifies this invocation across all work groups
  // my_data_buffer.data[gl_GlobalInvocationID.x] *= 2.0;
}
