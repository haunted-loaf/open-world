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

var follow: Node3D

var material: Material

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
  if not c or not o or not l or not u:
    return
  c.visible = true
  o.visible = false
  l.visible = false
  u.visible = false
  var pos1: Vector3 = snap(1)
  var pos2: Vector3 = snap(2)
  c.global_position = Vector3(pos1.x, global_position.y, pos1.z)
  o.global_position = Vector3(pos2.x, global_position.y, pos2.z)
  l.global_position = Vector3(pos2.x, global_position.y, pos2.z)
  u.global_position = Vector3(pos2.x, global_position.y, pos2.z)
  pos1 = global_transform.basis * pos1
  pos2 = global_transform.basis * pos2
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
  instance.material = material
  add_child(instance, false, INTERNAL_MODE_BACK)
  # instance.set_owner(get_tree().edited_scene_root)
  return instance

func snap(bias: int) -> Vector3:
  var p := follow.global_position
  var o := p.snapped(Vector3(bias * pow(2, level - 1), 0, bias * pow(2, level - 1)))
  return Vector3(o.x, p.y, o.z)
