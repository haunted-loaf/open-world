shader_type spatial;
render_mode unshaded;

uniform float world_scale = 1.0;
uniform float height_scale = 1.0;
uniform float patch_size = 1.0;
uniform vec4 position = vec4(0.0);

#include "heights.gdshaderinc"

void fragment() {
  vec2 world_pos = position.xz + (UV - 0.5) * patch_size;
  vec2 map_pos = world_pos;
  float h = height(map_pos) / height_scale;
  h = clamp(0.5 * h + 0.5, 0.0, 1.0);
  SPECULAR = 0.0;
  ALBEDO = vec3(h);
}
