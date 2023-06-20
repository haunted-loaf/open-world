@tool
class_name ClipmapLevel
extends Node3D

@export var dirty = false

@export var level: int = 0:
  set(value):
    if level != value:
      level = value
      dirty = true

@export var data: TerrainData:
  set(value):
    if data != value:
      data = value
      dirty = true

var c : ClipmapMeshInstance
var o : ClipmapMeshInstance
var u : ClipmapMeshInstance
var l : ClipmapMeshInstance

func _process(_delta):
  if dirty:
    dirty = false
    for node in get_children(true):
      node.queue_free()
    if level == 1:
      c = make_mesh(ClipmapMeshBuilder.Type.CENTRE, level)
    else:
      c = make_mesh(ClipmapMeshBuilder.Type.RING, level)
    o = make_mesh(ClipmapMeshBuilder.Type.O, level)
    u = make_mesh(ClipmapMeshBuilder.Type.U, level)
    l = make_mesh(ClipmapMeshBuilder.Type.L, level)
  c.visible = true
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

func make_mesh(type: ClipmapMeshBuilder.Type, level: float):
  var instance = ClipmapMeshInstance.make(data, type, pow(2, level - 1))
  instance.name = str(type)
  add_child(instance, false, INTERNAL_MODE_BACK)
  instance.set_owner(get_tree().edited_scene_root)
  return instance

func snap(bias: int) -> Vector3:
  var p := global_position
  var o := p.snapped(Vector3(bias * pow(2, level - 1), 0, bias * pow(2, level - 1)))
  return Vector3(o.x, p.y, o.z)

# var offset: Vector3:
#   get:
#     return global_position

# var level_scale:
#   get:
#     return pow(2, level - 1)

# func _ready():
#   dirty = true

# func _process(_delta):

#   var pos1: Vector3 = snap(1)
#   var pos2: Vector3 = snap(2)

#   c.global_position = Vector3(pos1.x, 0, pos1.z)
#   o.global_position = Vector3(pos2.x, 0, pos2.z)
#   l.global_position = Vector3(pos2.x, 0, pos2.z)
#   u.global_position = Vector3(pos2.x, 0, pos2.z)

#   if pos1 == pos2:
#     o.visible = true
#   elif pos1.x == pos2.x || pos1.z == pos2.z:
#     u.visible = true
#     if pos1.x < pos2.x:
#       u.rotation_degrees.y = 90
#     elif pos1.x > pos2.x:
#       u.rotation_degrees.y = -90
#     elif pos1.z < pos2.z:
#       u.rotation_degrees.y = 0
#     elif pos1.z > pos2.z:
#       u.rotation_degrees.y = 180
#   else:
#     l.visible = true
#     if pos1.x < pos2.x && pos1.z < pos2.z:
#       l.rotation_degrees.y = 0
#     elif pos1.x < pos2.x && pos1.z > pos2.z:
#       l.rotation_degrees.y = 90
#     elif pos1.x > pos2.x && pos1.z < pos2.z:
#       l.rotation_degrees.y = 270
#     elif pos1.x > pos2.x && pos1.z > pos2.z:
#       l.rotation_degrees.y = 180

# #   if material:
# #     $Center/Mesh.material_override = material
# #     $Ring/Mesh.material_override = material
# #     $O/Mesh.material_override = material
# #     $L/Mesh.material_override = material
# #     $U/Mesh.material_override = material
