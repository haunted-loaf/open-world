shader_type spatial;
render_mode cull_disabled;
// render_mode world_vertex_coords;

uniform sampler2D tex : repeat_disable;
uniform float world_scale = 4096.0;
uniform float height_scale = 256.0;
uniform vec3 position;
uniform float size;

#include "heights.gdshaderinc"

varying float h;
varying float random;
varying float _height;
varying vec3 N;
varying float t;

vec2 rotate(vec2 uv, vec2 pivot, float angle) {
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						           vec2(cos(angle), sin(angle)));
	uv = rotation * (uv - pivot) + pivot;
	return uv;
}

vec2 snap2(vec2 v, vec2 s) {
  return round(v * s) / s;
}

void vertex() {
  vec3 centrePos = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
  VERTEX.xz += fract(centrePos.xz);

  vec3 worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
  
  h = height(centrePos.xz);

  centrePos.xz = snap2(centrePos.xz, vec2(1.0));
  worldPos.xz = snap2(worldPos.xz, vec2(1.0));
  VERTEX.xz += 5.0 * hash2(centrePos.xz) - 1.0;

  float fade = distance(centrePos, position) / size;
  VERTEX *= 1.0 - smoothstep(0.4, 0.6, fade);

  if (h > 20.0)
    VERTEX *= 0.0;
  VERTEX *= mix(0.9, 1.0, hash2(worldPos.xz));
  VERTEX *= smoothstep(0.0, 2.0, h);
  VERTEX.xz = rotate(VERTEX.xz, vec2(0), h * 1000.0);
  VERTEX.x += 0.1 * sin(TIME) * pow(VERTEX.y, 1.0);
  VERTEX.z += 0.01 * sin(10.0 * TIME) * pow(VERTEX.y, 1.0);

  worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
  float h2 = height(worldPos.xz);
  VERTEX.y += h2 - 0.1;

  // VERTEX.y += 1.4;
  // VERTEX.y *= 1.0;

  // fade = 1.0;
  // float n = hash2(centrePos.xz + 1.0);
  // float nx = fract(n * 1000.0);
  // float nz = trunc(n * 1000.0) / 1000.0;
  // VERTEX.x += nx / 1.0;
  // VERTEX.z += nz / 1.0;
  // VERTEX.xz = rotate(VERTEX.xz, vec2(0), n);

  // float t = TIME + noise(centrePos.xz * 100.0);
  // VERTEX.x += (VERTEX.y + 0.5) * sin(t * 0.2) * 0.2;
  // VERTEX.z += (VERTEX.y + 0.5) * sin(t * 0.5) * 0.1;
  // VERTEX.y += h;
  // VERTEX.y *= mix(0.1, 1.0, smoothstep(1.5, 1.8, h));

  // vec3 ts = vec3(1.0, 1.0, 0.0);
  // float h1 = height(pos + ts.xz);
  // float h2 = height(pos + ts.zy);
  // float x1 = height(pos - ts.xz);
  // float x2 = height(pos + ts.xz);
  // float y1 = height(pos - ts.zy);
  // float y2 = height(pos + ts.zy);
  // N = normalize(vec3(x1 - x2, 2.0, y1 - y2));

  // random = 0.5 * pow(n, 2.0);

  // float rockiness = 1.0 - pow(clamp(N.y, 0, 1), 10.0);
  // float sandiness = 1.0 - smoothstep(0.0, 3.0, h);
  // float snowiness = smoothstep(48.0, 64.0, h);
  // float snowiness2 = smoothstep(48.0, 96.0, h);

  // if (rockiness > random)
  //   VERTEX.y -= 1000.0;

  _height = h;
}

void fragment() {

  float rockiness = 1.0 - pow(clamp(N.y, 0, 1), 10.0);
  float sandiness = 1.0 - smoothstep(0.0, 3.0, h);
  float snowiness = smoothstep(48.0, 64.0, h);
  float snowiness2 = smoothstep(48.0, 96.0, h);

  // if (sandiness > random)
  //   discard;
  // if (snowiness > random)
  //   discard;
  // if (snowiness2 > random)
  //   discard;
  // if (rockiness > 0.5)
  //   discard;

  ALBEDO = mix(
    vec3(1.0, 0.9, 0.5) / 5.0,
    vec3(0.8, 1.0, 0.3) / 5.0,
    smoothstep(1.5, 5.0, _height) // + t
  );
	// ALPHA = fade * texture(tex, UV).a;
  // samplerState wrap_mode = sampler
  if (texture(tex, UV).a < 0.1)
    discard;
  // NORMAL = -NORMAL;
  // if (fade < 0.0)
  //   discard;

  // AO = 1.0 - UV.y;
}

void light() {
    DIFFUSE_LIGHT = vec3(1) * abs(dot(NORMAL, LIGHT)) * ATTENUATION * ALBEDO;
    // DIFFUSE_LIGHT += 10.0;
}
