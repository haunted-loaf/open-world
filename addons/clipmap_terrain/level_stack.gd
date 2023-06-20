@tool
class_name ClipmapLevelStack
extends Node3D

@export var dirty = false

@export var follow: Node3D

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

func _process(_delta):
  if follow:
    global_position = follow.global_position * Vector3(1, 0, 1)
  if dirty:
    dirty = false
    for node in get_children(true):
      node.queue_free()
    for i in count:
      var level = ClipmapLevel.new() as ClipmapLevel
      level.level = i + 1
      level.data = data
      add_child(level)
      # level.set_owner(get_tree().edited_scene_root)
