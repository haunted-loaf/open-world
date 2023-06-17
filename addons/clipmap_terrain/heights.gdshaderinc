
global uniform sampler2D noise_map : filter_linear;

float hash1(float n) { return fract(sin(n) * 1e4); }
float hash2(vec2 p) { return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x)))); }


float noise2(vec2 x) {
	vec2 i = floor(x);
	vec2 f = fract(x);

	// Four corners in 2D of a tile
	float a = hash2(i);
	float b = hash2(i + vec2(1.0, 0.0));
	float c = hash2(i + vec2(0.0, 1.0));
	float d = hash2(i + vec2(1.0, 1.0));

	// Simple 2D lerp using smoothstep envelope between the values.
	// return vec3(mix(mix(a, b, smoothstep(0.0, 1.0, f.x)),
	//			mix(c, d, smoothstep(0.0, 1.0, f.x)),
	//			smoothstep(0.0, 1.0, f.y)));

	// Same code, with the clamps in smoothstep and common subexpressions
	// optimized away.
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float noise(vec2 uv) {
  return noise2(uv);
  // return texture(sampler, uv);
}

float S(float x) {
  return 1.0 / (1.0 + exp(-x));
}

float fbm(vec2 uv, int octaves, float gain, float thing) {
  float total = 0.0;
  float amp = 1.0;
  float zoom = 1.0;
  float range = 0.0;
  for (int i = 0; i < octaves; ++i) {
    float sample = noise(uv * zoom + float(i));
    total += amp * sample;
    range += amp;
    zoom *= 2.0;
    amp *= mix(1.0, min(sample + 1.0, 2.0) * 0.5, thing);
    amp *= gain;
    uv = uv.yx;
  }
  return total / range;
}

float smax(float a, float b)
{
  // return max(a, b);
  float k = 0.01;
  return log(exp(k * a) + exp(k * b)) / k;
}

float height(vec2 uv) {
  // float h = S(10.0 * (fbm(noise_map, uv.xy * 0.1, 3, 1.0) * -2.0 + 1.0));
  float h = fbm(uv * 10.0, 6, 0.4, 0.5) * -2.0 + 1.0;
  h = S(5.0 * h);
  h = height_scale * h;
  h += 8.0 * fbm(uv * 400.0, 6, 0.5, 0.0);
  // h = smax(
  //   h,
  //   height_scale / 3.0 + 16.0 * (fbm(uv * 200.0, 1, 0.5, 0.0) * -2.0 + 1.0)
  // );
  return h;
  // float v2 = fbm(uv.yx * 100.0, 8, 0.0);
  // float h = 0.0;
  // h += h1 * height_scale * 4.0;
  // h += h2 * 32.0;
  // return h;
}
