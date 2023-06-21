shader_type spatial;

uniform sampler2D terrain_tex;

const float world_scale = 8192.0;
const float height_scale = 256.0;

const float SURFACE_DST = 0.1;
const float MAX_DIST = 10.0;
const int MAX_ITERS = 1000;
const int SEC_ITERS = 100;

vec4 sample(vec2 uv) {
  return texture(terrain_tex, uv + 0.5);
}

vec4 raymarch(inout vec3 pos, vec3 dir) {
	vec3 rd = dir;
	vec3 ro = pos;
  float d = 0.5;
  float last_d = 0.0;
  for (int i = 0; i < MAX_ITERS; ++i) {
    pos = ro + rd * d;
    vec2 uv = pos.xz;
    uv = clamp(uv, -0.5, 0.5);
    vec4 s = sample(uv) * vec4(1.0, 1.0, 0.005, 1.0);
    if (pos.y < s.z) {
      float ds = (d - last_d) / float(SEC_ITERS);
      d = last_d;
      for (int j = 0; j < SEC_ITERS; ++j) {
        pos = ro + rd * d;
        d += ds;
        vec2 uv = pos.xz / 10.0;
        vec4 s = sample(uv / 1.0) * vec4(1.0, 1.0, 0.005, 1.0);
        if (pos.y < s.z)
          return s;
      }
      return vec4(1e9);
    }
    last_d = d;
    d += 0.1;
  }
  return vec4(1e9);
}

void fragment() {
  vec3 pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
  vec3 dir = (mat3(INV_VIEW_MATRIX) * -VIEW).xyz;
  vec4 result = raymarch(pos, dir);
  if (result.w < 1e9) {
  } else {
    discard;
  }
  NORMAL = (VIEW_MATRIX * vec4(normalize(vec3(result.x, 0.001, result.y)), 0.0)).xyz;
	vec4 ndc = PROJECTION_MATRIX * VIEW_MATRIX * vec4(pos, 1.0);
	float depth = (ndc.z / ndc.w);
  DEPTH = depth;
  ROUGHNESS = 0.5;
  ALBEDO = vec3(1.0, 1.0, 1.0);
  if (result.z < 0.2)
    ALBEDO = vec3(0.6, 1.0, 0.2) / 3.0;
  if (result.z < 0.01)
    ALBEDO = vec3(1.0, 1.0, 0.5) / 3.0;
  if (length(result.xy) > 0.3)
    ALBEDO = vec3(0.5, 0.5, 0.5);
}
