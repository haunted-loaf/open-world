shader_type spatial;
uniform sampler2D depth_texture: hint_depth_texture, filter_linear_mipmap;
uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;

varying mat4 camera;
varying vec3 world_pos;

float fresnel(float amount, vec3 normal, vec3 view) {
  return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void vertex() {
  camera = INV_VIEW_MATRIX;
  world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
  float depth01 = textureLod(depth_texture, SCREEN_UV, 0.0).x;
  vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth01);
  vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
  vec3 view_position = view.xyz / view.w;
  vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
  vec3 world_position = world.xyz / view.w;
  float view_depth = -view_position.z;
  float depth = distance(world_position, world_pos);
  vec3 odepth = exp(-depth * 1.0 * vec3(0.9, 0.2, 0.1));

  float factor = 1.0 - fresnel(1.0, NORMAL, VIEW);

  ALBEDO = vec3(mix(0.0, 0.1, smoothstep(0.1, 0.0, abs(depth - 0.1))));
  SPECULAR = 1.0 - factor;
  ROUGHNESS = 0.0;
  EMISSION = factor * clamp(odepth, 0, 1) * texture(screen_texture, SCREEN_UV).rgb;

}
