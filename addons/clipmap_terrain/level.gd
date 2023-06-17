@tool
class_name ClipmapLevel
extends Node3D

@export var level: int = 0:
  set(value):
    if level != value:
      level = value
      dirty = true

@export var factory: ClipmapMeshFactory:
  set(value):
    if factory != value:
      factory = value
      dirty = true

var c : ClipmapMeshInstance
var o : ClipmapMeshInstance
var u : ClipmapMeshInstance
var l : ClipmapMeshInstance

var offset: Vector3:
  get:
    return global_position

var level_scale:
  get:
    return pow(2, level - 1)

@export var dirty = false

func _ready():
  dirty = true

func make_mesh(type: ClipmapMeshFactory.Type, scale: float):
  var instance = ClipmapMeshInstance.make(factory, type, scale)
  instance.name = str(type)
  add_child(instance, false, INTERNAL_MODE_BACK)
  return instance

func _process(_delta):
  if dirty:
    dirty = false
    for node in get_children(true):
      node.queue_free()
    if level == 1:
      c = make_mesh(ClipmapMeshFactory.Type.CENTRE, level_scale)
    else:
      c = make_mesh(ClipmapMeshFactory.Type.RING, level_scale)
    o = make_mesh(ClipmapMeshFactory.Type.O, level_scale)
    u = make_mesh(ClipmapMeshFactory.Type.U, level_scale)
    l = make_mesh(ClipmapMeshFactory.Type.L, level_scale)
  
  o.visible = false
  l.visible = false
  u.visible = false

  var pos1: Vector3 = snap(1)
  var pos2: Vector3 = snap(2)

  c.global_position = Vector3(pos1.x, 0, pos1.z)
  o.global_position = Vector3(pos2.x, 0, pos2.z)
  l.global_position = Vector3(pos2.x, 0, pos2.z)
  u.global_position = Vector3(pos2.x, 0, pos2.z)

  if pos1 == pos2:
    o.visible = true
  elif pos1.x == pos2.x || pos1.z == pos2.z:
    u.visible = true
    if pos1.x < pos2.x:
      u.rotation_degrees.y = 90
    elif pos1.x > pos2.x:
      u.rotation_degrees.y = -90
    elif pos1.z < pos2.z:
      u.rotation_degrees.y = 0
    elif pos1.z > pos2.z:
      u.rotation_degrees.y = 180
  else:
    l.visible = true
    if pos1.x < pos2.x && pos1.z < pos2.z:
      l.rotation_degrees.y = 0
    elif pos1.x < pos2.x && pos1.z > pos2.z:
      l.rotation_degrees.y = 90
    elif pos1.x > pos2.x && pos1.z < pos2.z:
      l.rotation_degrees.y = 270
    elif pos1.x > pos2.x && pos1.z > pos2.z:
      l.rotation_degrees.y = 180

#   if material:
#     $Center/Mesh.material_override = material
#     $Ring/Mesh.material_override = material
#     $O/Mesh.material_override = material
#     $L/Mesh.material_override = material
#     $U/Mesh.material_override = material

func snap(bias: int) -> Vector3:
  var o = offset.snapped(Vector3(bias * level_scale, 0, bias * level_scale))
  return Vector3(o.x, offset.y, o.z)
