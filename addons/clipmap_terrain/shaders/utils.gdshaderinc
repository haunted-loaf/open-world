
vec3 UnpackNormal(vec3 n) {
  return n * 2.0 - 1.0;
}

vec3 PackNormal(vec3 n) {
  return n * 0.5 + 0.5;
}

vec3 MixNormal(vec3 n1, vec3 n2) {
  n1 = PackNormal(n1);
  n2 = PackNormal(n2);
  n1 = n1 * vec3( 2, 2, 2) + vec3(-1, -1, 1);
  n2 = n2 * vec3(-2, -2, 2) + vec3( 1, 1, 1);
  return n1 * dot(n1, n2) / n1.z - n2;
}
