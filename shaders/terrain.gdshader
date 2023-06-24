shader_type spatial;

uniform sampler2D terrain_tex;

vec3 blend(vec3 from, vec3 to, float start, float end, float t) {
  if (t < start)
    return from;
  if (t > end)
    return to;
  return mix(from, to, smoothstep(start, end, t));
}

void fragment() {
  vec4 sample = texture(terrain_tex, UV);
  float height = sample.b;
  if (height < 0.0) {
    height = -height;
    ALBEDO = vec3(0.0, 0.0, 0.1);
    ALBEDO = blend(vec3(0.0, 0.1, 0.3), ALBEDO, 1.0, 10.0, height);
    ALBEDO = blend(vec3(0.0, 1.0, 1.0), ALBEDO, 0.0, 3.0, height);
    ROUGHNESS = 0.1;
  } else {
    ALBEDO = sample.rgb;
    ALBEDO = vec3(0.5);
    NORMAL_MAP = sample.rgb * 0.5 + 0.5;
    NORMAL_MAP_DEPTH = 1.0;
    ROUGHNESS = 0.5;
    ALBEDO = vec3(1.0, 1.0, 1.0);
    ALBEDO = blend(vec3(0.2, 0.3, 0.1) / 4.0, ALBEDO, 30.0, 60.0, height);
    ALBEDO = blend(vec3(0.1, 0.3, 0.0) / 4.0, ALBEDO, 10.0, 30.0, height);
    ALBEDO = blend(vec3(0.1, 0.3, 0.0) / 4.0, ALBEDO, 3.0, 10.0, height);
    ALBEDO = blend(vec3(0.1, 0.3, 0.0), ALBEDO, 1.0, 3.0, height);
    ALBEDO = blend(vec3(0.3, 0.3, 0.1), ALBEDO, 0.0, 1.0, height);
  }
}
