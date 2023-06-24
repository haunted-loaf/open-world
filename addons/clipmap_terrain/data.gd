@tool
class_name TerrainData
extends Resource

var meshes = {}

@export var world_size = 1.0:
  set(value):
    if world_size != value:
      world_size = value

@export var world_height = 1.0:
  set(value):
    if world_height != value:
      world_height = value

@export var resolution = 10:
  set(value):
    value = clamp(value, 1, 20)
    if resolution != value:
      resolution = value
      update()

@export var cullable = false:
  set(value):
    if cullable != value:
      cullable = value
      update()

@export var texture: Texture2D:
  set(value):
    if value != texture:
      texture = value
      var image:= texture.get_image()
      texture_size = image.get_size()
      bytes = image.get_data()

@export var texture_size: Vector2i

var bytes: PackedByteArray
    
func update():
  meshes = {}
  changed.emit()

func get_mesh(type: ClipmapMeshBuilder.Type, scale: float) -> ArrayMesh:
  if not meshes.has(type):
    meshes[type] = {}
  if not meshes[type].has(scale):
    meshes[type][scale] = generate(type, scale)
  return meshes[type][scale]

func generate(type: ClipmapMeshBuilder.Type, scale: float) -> ArrayMesh:
  var builder = ClipmapMeshBuilder.new(resolution, type, scale)
  return builder.build()
