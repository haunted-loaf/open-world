shader_type spatial;
render_mode world_vertex_coords;

// uniform sampler2D noisemap : filter_linear_mipmap_anisotropic;
// uniform sampler2D heightmap : filter_linear_mipmap_anisotropic;
// uniform sampler2D grass_albedo : filter_linear_mipmap_anisotropic;
// uniform sampler2D grass_normal : hint_normal, filter_linear_mipmap_anisotropic;

uniform float height_scale = 1.0;
uniform float world_scale = 1.0;

varying vec3 worldPos;

#include "heights.gdshaderinc"
#include "utils.gdshaderinc"

void vertex() {
  VERTEX.x = round(VERTEX.x * 10.0) / 10.0;
  VERTEX.z = round(VERTEX.z * 10.0) / 10.0;
  UV = 2.0 * UV / world_scale;
  UV2 = UV * 500.0;
  VERTEX += NORMAL * height(UV);
  mat3 m = inverse(MODELVIEW_NORMAL_MATRIX);
  TANGENT = m * vec3(0, 0, -1);
  BINORMAL = m * vec3(1, 0, 0);
  worldPos = VERTEX.xyz;
}

// uniform sampler2D sand_albedo : source_color;
// uniform sampler2D sand_normal;
// uniform sampler2D sand_ao;
// uniform sampler2D sand_height;
// uniform sampler2D sand_metal;
// uniform sampler2D sand_roughness;

// uniform sampler2D rock_albedo : source_color;
// uniform sampler2D rock_normal;
// uniform sampler2D rock_ao;
// uniform sampler2D rock_height;
// uniform sampler2D rock_metal;
// uniform sampler2D rock_roughness;

void fragment() {
	ROUGHNESS = 0.8;

  float h = height(UV);
  vec3 N = NORMAL;

  vec3 pos = worldPos;
  vec3 ts = vec3(1.0, 1.0, 0.0) / world_scale;
  float h1 = height(UV + ts.xz);
  float h2 = height(UV + ts.zy);
  float x1 = height(UV - ts.xz);
  float x2 = height(UV + ts.xz);
  float y1 = height(UV - ts.zy);
  float y2 = height(UV + ts.zy);
  N = normalize(vec3(x1 - x2, 2.0, y1 - y2));
  NORMAL = mat3(VIEW_MATRIX) * N;

  float slope = pow(clamp(N.y, 0, 1), 10.0);

  ALBEDO = mix(vec3(1, 0.9, 0.7) / 8.0, vec3(0.2, 0.3, 0.0) / 4.0, slope);
  ALBEDO = mix(vec3(1.0, 0.8, 0.3) / 2.0, ALBEDO, smoothstep(0.0, 3.0, h));
  ALBEDO = mix(ALBEDO, vec3(1.0, 1.0, 1.0) / 2.0, smoothstep(192.0, 256.0, h));
  ALBEDO = mix(ALBEDO, vec3(1.0, 0.7, 0.0) / 16.0, smoothstep(0.0, -64.0, h));

  // if (h <= 0.0) {
  //   ALBEDO = vec3(0.0, 0.0, 1.0);
  // }

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
