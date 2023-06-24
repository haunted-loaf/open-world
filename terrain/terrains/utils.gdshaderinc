layout(local_size_x = 16, local_size_y = 16) in;

layout(binding = 0, rgba16f) restrict uniform image2D heights;

layout(push_constant) restrict uniform Constants {
  float world_scale;
  float height_scale;
  float local_scale;
  uint resolution;
  ivec4 offset;
} data;

float sdCircle (vec2 p, float r) {
  return length(p) - r;
}

float hash1(float n) { return fract(sin(n) * 1e4); }
float hash2(vec2 p) { return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x)))); }

float noise2(vec2 x) {
	vec2 i = floor(x);
	vec2 f = fract(x);
	float a = hash2(i);
	float b = hash2(i + vec2(1.0, 0.0));
	float c = hash2(i + vec2(0.0, 1.0));
	float d = hash2(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float noise(vec2 uv) {
  return noise2(uv);
}

float fbm(vec2 uv, int octaves, float gain, float thing) {
  float total = 0.0;
  float amp = 1.0;
  float zoom = 1.0;
  float range = 0.0;
  for (int i = 0; i < octaves; ++i) {
    float value = noise(uv * zoom + float(i));
    total += amp * value;
    range += amp;
    zoom *= 2.0;
    amp *= mix(1.0, min(value + 1.0, 2.0) * 0.5, thing);
    amp *= gain;
    uv = uv.yx;
  }
  return total / range;
}
