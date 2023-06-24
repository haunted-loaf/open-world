@tool
extends Node3D

@export_node_path("Node3D") var follow: NodePath

func _process(delta):
  if has_node(follow):
    global_position.x = get_node(follow).global_position.x
    global_position.z = get_node(follow).global_position.z
