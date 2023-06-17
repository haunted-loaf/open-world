shader_type spatial;
render_mode unshaded;

uniform float world_scale = 1.0;
uniform float scale = 1.0;
uniform float height_scale = 1.0;
uniform vec4 position = vec4(0.0);

#include "heights.gdshaderinc"

void fragment() {
  SPECULAR = 0.0;
	ALBEDO = vec3(height((UV - 0.5) / scale + 2.0 * position.xz / world_scale) / height_scale);
}
