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
    if data:
      data.changed.disconnect(_on_data_changed)
    data = value
    if data:
      data.changed.connect(_on_data_changed)
    dirty = true

@export var mesh_scale: float = 1.0:
  set(value):
    if mesh_scale != value:
      mesh_scale = value
      dirty = true

@export var dirty = false

var material: Material

static func make(data: TerrainData, type: ClipmapMeshBuilder.Type, scale: float):
  var instance = ClipmapMeshInstance.new()
  instance.data = data
  instance.type = type
  instance.scale = Vector3(scale, 1, scale)
  return instance

func _process(_delta):
  set_layer_mask_value(2, false)
  set_instance_shader_parameter("extra_rotation_0", get_parent().global_transform.basis[0])
  set_instance_shader_parameter("extra_rotation_1", get_parent().global_transform.basis[1])
  set_instance_shader_parameter("extra_rotation_2", get_parent().global_transform.basis[2])
  if not dirty:
    return
  dirty = false
  update()

func update():
  if not data:
    return
  mesh = data.get_mesh(type, mesh_scale)
  extra_cull_margin = 16384
  self.ignore_occlusion_culling = true
  # var aabb := get_aabb()
  # aabb.size.y = 2 * data.world_height
  # custom_aabb = aabb
  material_override = material

func _on_data_changed():
  dirty = true
