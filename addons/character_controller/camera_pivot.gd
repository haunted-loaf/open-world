extends Node3D

func _ready():
  top_level = true

func _process(delta):
  global_position = get_parent().global_position
