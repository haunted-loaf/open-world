shader_type spatial;
render_mode world_vertex_coords;

uniform float world_size = 1.0;
uniform bool discard_negative_z = false;
uniform float height_scale = 1.0;

varying vec3 worldPos;

// #include "heights.gdshaderinc"
#include "utils.gdshaderinc"
#include "stochastic.gdshaderinc"

uniform sampler2D terrain_tex;
uniform sampler2D noise_tex;

float height(vec2 uv) {
  uv = uv / world_size + 0.5;
  uv.x = clamp(uv.x, 0, 1);
  uv.y = clamp(uv.y, 0, 1);
  return texture(terrain_tex, uv).r * height_scale;
}

// #define CENTROID_NORMALS 1
#define TEXTURE_NORMALS 1

#if defined(TEXTURE_NORMALS)

vec3 height_normal(vec2 uv) {
  uv = uv / world_size + 0.5;
  uv.x = clamp(uv.x, 0, 1);
  uv.y = clamp(uv.y, 0, 1);
  vec3 n = texture(terrain_tex, uv).yzw;
  return n;
}

#elif defined(CENTROID_NORMALS)

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

#endif

uniform sampler2D grass_albedo : source_color;
uniform sampler2D grass_normal : hint_normal;
uniform sampler2D grass_ao;
uniform sampler2D grass_roughness;

uniform sampler2D sand_albedo : source_color;
uniform sampler2D sand_normal : hint_normal;
uniform sampler2D sand_ao;
uniform sampler2D sand_roughness;

uniform sampler2D rock_albedo : source_color;
uniform sampler2D rock_normal : hint_normal;
uniform sampler2D rock_ao;
uniform sampler2D rock_roughness;

uniform sampler2D snow_albedo : source_color;
uniform sampler2D snow_normal : hint_normal;
uniform sampler2D snow_ao;
uniform sampler2D snow_roughness;

instance uniform vec3 extra_rotation_0;
instance uniform vec3 extra_rotation_1;
instance uniform vec3 extra_rotation_2;
instance uniform float level;

void vertex() {
  VERTEX.x = round(VERTEX.x);
  VERTEX.z = round(VERTEX.z);

  mat3 m = mat3(extra_rotation_0, extra_rotation_1, extra_rotation_2);
  // m = mat3(vec3(1, 0, 0), vec3(0, 1, 0), vec3(0, 0, 1));
  // UV = (m * VERTEX.xyz).xz;
  UV = VERTEX.xz;
  // UV *= world_size;
  UV2 = UV / 5.0;
  VERTEX += NORMAL * height(UV);
  // VERTEX.x += texture(noise_tex, UV / 1.0).r * 10.0 * VERTEX.y;
  m = inverse(MODELVIEW_NORMAL_MATRIX);
  NORMAL = vec3(0, 1, 0);
  TANGENT = m * vec3(1, 0, 0);
  BINORMAL = m * vec3(0, 0, 1);
  // UV = (m * VERTEX.xyz).xz;
  // worldPos = VERTEX.xyz;
}

#define MIXIN(t, albedo, roughness, normal, ao) \
  ALBEDO = mix(ALBEDO, textureStochastic(albedo, UV2).rgb, t); \
  ROUGHNESS = mix(ROUGHNESS, textureStochastic(roughness, UV2).r, t); \
  AO = mix(AO, textureStochastic(ao, UV2).r, t); \
  N = mix(N, UnpackNormal(textureStochastic(normal, UV2).rgb), t);

void fragment() {

	ROUGHNESS = 0.5;

  float h = height(UV);
  vec3 N = height_normal(UV);

  if (discard_negative_z && h < 0.0)
    discard;

  NORMAL = mat3(VIEW_MATRIX) * N;

  float rockiness = 1.0 - pow(clamp(N.y, 0, 1), 10.0);
  float sandiness = 1.0 - smoothstep(0.0, 3.0, h);
  float snowiness = smoothstep(48.0, 64.0, h);
  float snowiness2 = smoothstep(48.0, 96.0, h);

  N = vec3(0.5);

  MIXIN(1.0, grass_albedo, grass_roughness, grass_normal, grass_ao);
  MIXIN(snowiness, snow_albedo, snow_roughness, snow_normal, snow_ao);
  MIXIN(rockiness, rock_albedo, rock_roughness, rock_normal, rock_ao);
  MIXIN(snowiness2, snow_albedo, snow_roughness, snow_normal, snow_ao);
  MIXIN(sandiness, sand_albedo, sand_roughness, sand_normal, sand_ao);

  NORMAL_MAP = PackNormal(normalize(N));

}
