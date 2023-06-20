shader_type spatial;
render_mode world_vertex_coords;

uniform float height_scale = 1.0;
uniform float world_scale = 1.0;

varying vec3 worldPos;

#include "heights.gdshaderinc"
#include "utils.gdshaderinc"
#include "stochastic.gdshaderinc"

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

void vertex() {
  UV = VERTEX.xz;
  UV2 = UV;
  VERTEX.y = height(UV);
  mat3 m = inverse(MODELVIEW_NORMAL_MATRIX);
  NORMAL = vec3(0, 1, 0);
  TANGENT = m * vec3(1, 0, 0);
  BINORMAL = m * vec3(0, 0, 1);
  worldPos = VERTEX.xyz;
}

#define MIXIN(t, albedo, roughness, normal, ao) \
  ALBEDO = mix(ALBEDO, textureStochastic(albedo, UV2).rgb, t); \
  ROUGHNESS = mix(ROUGHNESS, textureStochastic(roughness, UV2).r, t); \
  AO = mix(AO, textureStochastic(ao, UV2).r, t); \
  NORMAL_MAP = mix(NORMAL_MAP, UnpackNormal(textureStochastic(normal, UV2).rgb), t);

void fragment() {

	ROUGHNESS = 0.5;

  float h = height(UV);

  vec3 N = NORMAL;
  vec3 ts = vec3(1.0, 1.0, 0.0);
  float h1 = height(UV + ts.xz);
  float h2 = height(UV + ts.zy);
  float x1 = height(UV - ts.xz);
  float x2 = height(UV + ts.xz);
  float y1 = height(UV - ts.zy);
  float y2 = height(UV + ts.zy);
  N = normalize(vec3(x1 - x2, 2.0, y1 - y2));
  NORMAL = mat3(VIEW_MATRIX) * N;

  float rockiness = 1.0 - pow(clamp(N.y, 0, 1), 10.0);
  float sandiness = 1.0 - smoothstep(0.0, 3.0, h);
  float snowiness = smoothstep(48.0, 64.0, h);
  float snowiness2 = smoothstep(48.0, 96.0, h);

  MIXIN(1.0, grass_albedo, grass_roughness, grass_normal, grass_ao);
  MIXIN(snowiness, snow_albedo, snow_roughness, snow_normal, snow_ao);
  MIXIN(rockiness, rock_albedo, rock_roughness, rock_normal, rock_ao);
  MIXIN(snowiness2, snow_albedo, snow_roughness, snow_normal, snow_ao);
  MIXIN(sandiness, sand_albedo, sand_roughness, sand_normal, sand_ao);

  // ALBEDO = mix(vec3(1, 0.9, 0.7) / 8.0, vec3(0.2, 0.3, 0.0) / 4.0, slope);
  // ALBEDO = mix(vec3(1.0, 0.8, 0.3) / 2.0, ALBEDO, smoothstep(0.0, 3.0, h));
  // ALBEDO = mix(ALBEDO, vec3(1.0, 1.0, 1.0) / 2.0, smoothstep(192.0, 256.0, h));
  // ALBEDO = mix(ALBEDO, vec3(1.0, 0.7, 0.0) / 16.0, smoothstep(0.0, -64.0, h));

  // ALBEDO     = texture(grass_albedo, UV2).rgb;
  // ROUGHNESS  = texture(grass_roughness, UV2).r;
  // AO         = texture(grass_ao, UV2).r;
  // NORMAL_MAP = UnpackNormal(texture(grass_normal, UV2).rgb);

  NORMAL_MAP = PackNormal(normalize(NORMAL_MAP));

  // METALLIC = mix(texture(rock_metal, UV2).r, texture(sand_metal, UV2).r, pow(clamp(N.y, 0, 1), 5.0));
  // ROUGHNESS = mix(texture(rock_roughness, UV2).r, texture(sand_roughness, UV2).r, pow(clamp(N.y, 0, 1), 5.0));

  // NORMAL_MAP =
  // // PackNormal(MixNormal(
  // //   UnpackNormal(NORMAL_MAP),
  // //   normalize(UnpackNormal(
  //     texture(sand_normal, UV2).grb //) + vec3(0, 0, -2))
  // // ))
  // ;
}
