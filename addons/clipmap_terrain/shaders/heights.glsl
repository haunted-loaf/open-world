#[compute]
#version 450
#extension GL_GOOGLE_include_directive: require

layout(local_size_x = 16, local_size_y = 16) in;

layout(binding = 0, rgba32f) uniform image2D heights;

// layout(binding = 1) uniform Data {
//   float world_scale;
//   float height_scale;
//   float local_scale;
//   uint resolution;
// } data;

layout(push_constant) uniform Constants {
  float world_scale;
  float height_scale;
  float local_scale;
  uint resolution;
  ivec4 offset;
} data;

#define world_scale data.world_scale
#define height_scale data.height_scale

#include "heights.gdshaderinc"

// The code we want to execute in each invocation
void main() {
  ivec2 iuv = ivec2(gl_GlobalInvocationID.xy) + data.offset.xy;
  vec2 uv = vec2(iuv) / data.resolution - 0.5;
  float H = height(uv * data.local_scale);
  vec2 N = height_normal(uv * data.local_scale).xz;
  imageStore(heights, iuv, vec4(N, H, 1.0));
  // gl_GlobalInvocationID;
    // gl_GlobalInvocationID.x uniquely identifies this invocation across all work groups
    // my_data_buffer.data[gl_GlobalInvocationID.x] *= 2.0;
}
