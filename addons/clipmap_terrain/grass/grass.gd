@tool
extends Node3D
class_name ClipmapGrass

@export var dirty = false
@export var moved = false

@export var data: TerrainData
@export var size = 64
@export var snap: float = 1.0
@export var count = 100

var material: ShaderMaterial
var instance: MultiMeshInstance3D

func _ready():
  dirty = true

func _process(_delta):
  top_level = true
  var was_dirty = dirty
  if dirty:
    dirty = false
    # data.shape_material.property_list_changed.connect(func(): dirty = true)
    for node in get_children():
      node.queue_free()
    instance = null
    moved = true
  if not instance:
    make_instance()
  var new_position = get_parent().global_position.snapped(Vector3(snap, 0.0, snap)) * Vector3(1.0, 0.0, 1.0)
  if new_position != global_position:
    moved = true
  if moved:
    moved = false
    global_position = new_position
  mesh.material.set_shader_parameter("world_scale", data.world_scale)
  mesh.material.set_shader_parameter("height_scale", data.height_scale)
  mesh.material.set_shader_parameter("position", get_parent().global_position)
  mesh.material.set_shader_parameter("size", size)
  # mesh.material.set_shader_parameter("position", global_position)

var multimesh: MultiMesh
var mesh: QuadMesh

func make_instance():
  instance = MultiMeshInstance3D.new()
  add_child(instance)
  # instance.top_level = true
  multimesh = MultiMesh.new()
  multimesh.transform_format = MultiMesh.TRANSFORM_3D
  instance.multimesh = multimesh
  mesh = QuadMesh.new()
  mesh.size = Vector2(1.0, 1.0);
  mesh.center_offset = Vector3(0.0, 0.5, 0.0);
  instance.multimesh.mesh = mesh
  multimesh.instance_count = count * count
  mesh.material = data.grass_material.duplicate()
  instance.extra_cull_margin = data.height_scale
  var i = 0
  for x in count:
    for z in count:
      var pos = Vector3(x - (count - 1) / 2.0, 0, z - (count - 1) / 2.0) / count * size
      multimesh.set_instance_transform(i, Transform3D(Basis.from_euler(Vector3(0, 0, 0)), pos))
      # multimesh.set_instance_transform(i + 1, Transform3D(Basis.from_euler(Vector3(0, deg_to_rad(-90), 0)), pos))
      i += 1
