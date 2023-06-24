@tool
class_name ClipmapLevelStack
extends Node3D

@export var dirty = false

@export_node_path("Node3D") var follow: NodePath

@export var data: TerrainData:
  set(value):
    if data != value:
      data = value
      dirty = true

@export var count: int = 1:
  set(value):
    value = clamp(value, 1, 20)
    if count != value:
      count = value
      dirty = true

@export var material: Material

func _ready():
  dirty = true

func _process(_delta):
  if dirty:
    dirty = false
    for node in get_children(true):
      node.queue_free()
    if material:
      material.set_shader_parameter("terrain_tex", data.texture)
    for i in count:
      var level = ClipmapLevel.new() as ClipmapLevel
      level.level = i + 1
      level.data = data
      level.material = material
      level.follow = get_node(follow)
      add_child(level)
      # level.set_owner(get_tree().edited_scene_root)
