@tool
class_name ClipmapMeshCullableInstance
extends Node3D

@export var type: ClipmapMeshBuilder.Type:
  set(value):
    if type == value:
      return
    type = value
    dirty = true

@export var data: TerrainData:
  set(value):
    if data == value:
      return
    data = value
    data.changed.connect(_on_factory_changed)
    dirty = true

@export var mesh_scale: float = 1.0:
  set(value):
    if mesh_scale != value:
      mesh_scale = value
      dirty = true

@export var dirty = false

var color: Color = Color.WHITE

func _process(_delta):
  top_level = true
  # set_layer_mask_value(2, false)
  if dirty:
    dirty = false
    for node in get_children(true):
      node.queue_free()
    update()

func update():
  if not data:
    return

  if data.cullable:
    if type == ClipmapMeshBuilder.Type.CENTRE:
      name = "Centre"
      hide()
      color = Color.CYAN
      for x in range(-3, 3):
        for z in range(-3, 3):
          plane(Vector3(x, 0, z))

    if type == ClipmapMeshBuilder.Type.RING:
      name = "Ring"
      hide()
      color = Color.PURPLE
      # non_cullable()

    if type == ClipmapMeshBuilder.Type.O:
      name = "O-Ring"
      hide()
      color = Color.RED
      for i in range(-3, 4):
        for p in [Vector3(i, 0, -4), Vector3(i - 1, 0, 3), Vector3(-4, 0, i - 1), Vector3(3, 0, i)]:
          plane(p)

    if type == ClipmapMeshBuilder.Type.U:
      name = "U-Piece"
      hide()
      color = Color.GREEN
      for i in range(-4, 4):
        for p in [Vector3(-4, 0, i), Vector3(3, 0, i)]:
          plane(p)
      for i in range(-3, 3):
        for p in [Vector3(i, 0, 3), Vector3(i, 0, 2)]:
          plane(p)

    if type == ClipmapMeshBuilder.Type.L:
      name = "L-Piece"
      hide()
      color = Color.BLUE
      for i in range(-4, 4):
        for p in [Vector3(2, 0, i), Vector3(3, 0, i)]:
          plane(p)
      for i in range(-4, 3):
        for p in [Vector3(i, 0, 3), Vector3(i, 0, 2)]:
          plane(p)

  else:
    non_cullable()

func non_cullable():
  post_process(data.get_mesh(type, mesh_scale))

func plane(p: Vector3):
  var mesh := PlaneMesh.new()
  mesh.size = Vector2(1, 1)
  mesh.subdivide_width = data.resolution - 1
  mesh.subdivide_depth = data.resolution - 1
  post_process(mesh, p + Vector3(0.5, 0, 0.5))

func post_process(mesh: Mesh, pos = Vector3.ZERO):
  var instance := MeshInstance3D.new()
  add_child(instance)
  instance.mesh = mesh
  var mat := data.terrain_material as ShaderMaterial
  instance.material_override = mat
  instance.position = pos
  # var aabb := instance.get_aabb()
  # aabb.size.y = data.height_scale
  # instance.custom_aabb = aabb
  mat.set_shader_parameter("TINT", color)
  return instance

func _on_factory_changed():
  dirty = true

static func make(data: TerrainData, type: ClipmapMeshBuilder.Type, scale: float):
  var instance = ClipmapMeshInstance.new()
  instance.data = data
  instance.type = type
  instance.scale = Vector3(1 * scale, 1, 1 * scale)
  return instance
