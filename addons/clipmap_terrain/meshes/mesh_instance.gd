@tool
class_name ClipmapMeshInstance
extends MeshInstance3D

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
    data.changed.connect(_on_data_changed)
    dirty = true

@export var mesh_scale: float = 1.0:
  set(value):
    if mesh_scale != value:
      mesh_scale = value
      dirty = true

@export var dirty = false

static func make(data: TerrainData, type: ClipmapMeshBuilder.Type, scale: float):
  var instance = ClipmapMeshInstance.new()
  data.data = data
  data.type = type
  data.scale = Vector3(scale, 1, scale)
  return instance

func _process(_delta):
  top_level = true
  set_layer_mask_value(2, false)
  if not dirty:
    return
  dirty = false
  update()

func update():
  if not data:
    return
  mesh = data.get_mesh(type, mesh_scale)
  extra_cull_margin = 16384
  material_override = data.material

func _on_data_changed():
  dirty = true
