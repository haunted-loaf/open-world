@tool
class_name ClipmapMeshBuilder

var resolution: int

var spacing: float:
  get:
    return 1.0 / resolution

func _init(resolution: int):
  self.resolution = resolution

func build(type: ClipmapMeshFactory.Type):
  var st = SurfaceTool.new()
  st.begin(Mesh.PRIMITIVE_TRIANGLES)
  if type == ClipmapMeshFactory.Type.CENTRE:
    generate_centre(st)
  elif type == ClipmapMeshFactory.Type.RING:
    generate_ring(st)
  elif type == ClipmapMeshFactory.Type.O:
    generate_o(st)
  elif type == ClipmapMeshFactory.Type.U:
    generate_u(st)
  elif type == ClipmapMeshFactory.Type.L:
    generate_l(st)
  else:
    return null
  st.generate_normals()
  return st.commit()

func generate_centre(st: SurfaceTool):
  for x in range(-3 * resolution, 3 * resolution):
    for z in range(-3 * resolution, 3 * resolution):
      quad(st, x, z)

func generate_o(st: SurfaceTool):
  for x in range(-4 * resolution, 4 * resolution):
    for z in range(-4 * resolution, -3 * resolution):
      quad(st, x, z)
      quad(st, x, -z - 1)
  for x in range(-4 * resolution, -3 * resolution):
    for z in range(-3 * resolution, 3 * resolution):
      quad(st, x, z)
      quad(st, -x - 1, z)

func generate_ring(st: SurfaceTool):
  for x in range(-3 * resolution, 3 * resolution):
    for z in range(-3 * resolution, -2 * resolution - 1):
      quad(st, x, z)
      quad(st, x, -z - 1)
  for x in range(-3 * resolution, -2 * resolution - 1):
    for z in range(-2 * resolution - 1, 2 * resolution + 1):
      quad(st, x, z)
      quad(st, -x - 1, z)
  quad(st, -2 * resolution - 1, -2 * resolution - 1)
  quad(st, 2 * resolution, -2 * resolution - 1)
  quad(st, -2 * resolution - 1, 2 * resolution)
  quad(st, 2 * resolution, 2 * resolution)
  for x in range(-2 * resolution, 2 * resolution):
    tri(st, x, -2 * resolution - 1, 0)
    tri(st, x, -2 * resolution - 1, 90)
    tri(st, x, -2 * resolution - 1, 180)
    tri(st, x, -2 * resolution - 1, 270)

func generate_u(st: SurfaceTool):
  for x in range(-4 * resolution, 4 * resolution):
    for z in range(-4 * resolution, -2 * resolution):
      quad(st, x, -z - 1)
  for x in range(-4 * resolution, -3 * resolution):
    for z in range(-4 * resolution, 2 * resolution):
      quad(st, x, z)
      quad(st, -x - 1, z)

func generate_l(st: SurfaceTool):
  for x in range(-4 * resolution, 4 * resolution):
    for z in range(-4 * resolution, -2 * resolution):
      quad(st, x, -z - 1)
  for x in range(-4 * resolution, -2 * resolution):
    for z in range(-4 * resolution, 2 * resolution):
      quad(st, -x - 1, z)

func tri(st: SurfaceTool, x: float, z: float, r: float):
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
    vert(st, vertex.rotated(Vector3.UP, deg_to_rad(r)))

func quad(st: SurfaceTool, x: float, z: float):
  var vertices = [
    spacing * (Vector3(x, 0, z) + Vector3(0, 0, 0)),
    spacing * (Vector3(x, 0, z) + Vector3(1, 0, 0)),
    spacing * (Vector3(x, 0, z) + Vector3(0, 0, 1)),
    spacing * (Vector3(x, 0, z) + Vector3(1, 0, 0)),
    spacing * (Vector3(x, 0, z) + Vector3(1, 0, 1)),
    spacing * (Vector3(x, 0, z) + Vector3(0, 0, 1)),
  ]
  for vertex in vertices:
    vert(st, vertex)

func vert(st: SurfaceTool, v: Vector3):
  v.y -= 100.0
  st.add_vertex(v)
