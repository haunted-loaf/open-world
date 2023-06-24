@tool
class_name HeightSource
extends Resource

@export var world_size = 8192.0
@export var world_height = 256.0

@export var resolution = 512

@export var texture: Texture2D:
  set(value):
    if value != texture:
      texture = value
      bytes = texture.get_image().get_data()

var bytes: PackedByteArray
