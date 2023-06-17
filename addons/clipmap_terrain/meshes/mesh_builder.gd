@tool
class_name ClipmapMeshBuilder

var resolution: int

var type: ClipmapMeshFactory.Type

var scale: float

var st: SurfaceTool

var spacing: float:
  get:
    return 1.0 / resolution

func _init(resolution: int, type: ClipmapMeshFactory.Type, scale: float):
  self.resolution = resolution
  self.type = type
  self.scale = scale
  self.st = SurfaceTool.new()

func build():
  st.clear()
  st.begin(Mesh.PRIMITIVE_TRIANGLES)
  if type == ClipmapMeshFactory.Type.CENTRE:
    generate_centre()
  elif type == ClipmapMeshFactory.Type.RING:
    generate_ring()
  elif type == ClipmapMeshFactory.Type.O:
    generate_o()
  elif type == ClipmapMeshFactory.Type.U:
    generate_u()
  elif type == ClipmapMeshFactory.Type.L:
    generate_l()
  else:
    return null
  return st.commit()

func generate_centre():
  for x in range(-3 * resolution, 3 * resolution):
    for z in range(-3 * resolution, 3 * resolution):
      quad(x, z)

func generate_o():
  for x in range(-4 * resolution, 4 * resolution):
    for z in range(-4 * resolution, -3 * resolution):
      quad(x, z)
      quad(x, -z - 1)
  for x in range(-4 * resolution, -3 * resolution):
    for z in range(-3 * resolution, 3 * resolution):
      quad(x, z)
      quad(-x - 1, z)

func generate_ring():
  for x in range(-3 * resolution, 3 * resolution):
    for z in range(-3 * resolution, -2 * resolution - 1):
      quad(x, z)
      quad(x, -z - 1)
  for x in range(-3 * resolution, -2 * resolution - 1):
    for z in range(-2 * resolution - 1, 2 * resolution + 1):
      quad(x, z)
      quad(-x - 1, z)
  quad(-2 * resolution - 1, -2 * resolution - 1)
  quad(2 * resolution, -2 * resolution - 1)
  quad(-2 * resolution - 1, 2 * resolution)
  quad(2 * resolution, 2 * resolution)
  for x in range(-2 * resolution, 2 * resolution):
    tri(x, -2 * resolution - 1, 0)
    tri(x, -2 * resolution - 1, 90)
    tri(x, -2 * resolution - 1, 180)
    tri(x, -2 * resolution - 1, 270)

func generate_u():
  for x in range(-4 * resolution, 4 * resolution):
    for z in range(-4 * resolution, -2 * resolution):
      quad(x, -z - 1)
  for x in range(-4 * resolution, -3 * resolution):
    for z in range(-4 * resolution, 2 * resolution):
      quad(x, z)
      quad(-x - 1, z)

func generate_l():
  for x in range(-4 * resolution, 4 * resolution):
    for z in range(-4 * resolution, -2 * resolution):
      quad(x, -z - 1)
  for x in range(-4 * resolution, -2 * resolution):
    for z in range(-4 * resolution, 2 * resolution):
      quad(-x - 1, z)

func tri(x: float, z: float, r: float):
  var vertices = [
    spacing * (Vector3(x, 0, z) + Vector3(0.0, 0.0, 0.0)),
    spacing * (Vector3(x, 0, z) + Vector3(0.5, 0.0, 1.0)),
    spacing * (Vector3(x, 0, z) + Vector3(0.0, 0.0, 1.0)),
    spacing * (Vector3(x, 0, z) + Vector3(0.0, 0.0, 0.0)),
    spacing * (Vector3(x, 0, z) + Vector3(1.0, 0.0, 0.0)),
    spacing * (Vector3(x, 0, z) + Vector3(0.5, 0.0, 1.0)),
    spacing * (Vector3(x, 0, z) + Vector3(1.0, 0.0, 0.0)),
    spacing * (Vector3(x, 0, z) + Vector3(1.0, 0.0, 1.0)),
    spacing * (Vector3(x, 0, z) + Vector3(0.5, 0.0, 1.0)),
  ]
  for vertex in vertices:
    vert(vertex.rotated(Vector3.UP, deg_to_rad(r)))

func quad(x: float, z: float):
  var vertices = [
    spacing * (Vector3(x, 0, z) + Vector3(0, 0, 0)),
    spacing * (Vector3(x, 0, z) + Vector3(1, 0, 0)),
    spacing * (Vector3(x, 0, z) + Vector3(0, 0, 1)),
    spacing * (Vector3(x, 0, z) + Vector3(1, 0, 0)),
    spacing * (Vector3(x, 0, z) + Vector3(1, 0, 1)),
    spacing * (Vector3(x, 0, z) + Vector3(0, 0, 1)),
  ]
  for vertex in vertices:
    vert(vertex)

func vert(v: Vector3):
  v.x *= scale
  v.z *= scale
  st.add_vertex(v)
