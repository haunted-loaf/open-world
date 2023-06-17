@tool
class_name ClipmapMeshFactory
extends Resource

enum Type {
  CENTRE,
  RING,
  O,
  L,
  U,
}

var meshes = {}

@export var material: ShaderMaterial:
  set(value):
    if material != value:
      material = value
      update()

@export var shape_material: ShaderMaterial:
  set(value):
    if shape_material != value:
      shape_material = value
      update()

@export var world_scale = 1.0:
  set(value):
    if world_scale != value:
      if material:
        material.set_shader_parameter("world_scale", value)
      if shape_material:
        shape_material.set_shader_parameter("world_scale", value)
      world_scale = value

@export var height_scale = 1.0:
  set(value):
    if height_scale != value:
      if material:
        material.set_shader_parameter("height_scale", value)
      if shape_material:
        shape_material.set_shader_parameter("height_scale", value)
      height_scale = value

@export var resolution = 10:
  set(value):
    value = clamp(value, 1, 20)
    if resolution != value:
      resolution = value
      update()

func update():
  meshes = {}
  changed.emit()

func get_mesh(type: Type, scale: float):
  if not meshes.has(type):
    meshes[type] = {}
  if not meshes[type].has(scale):
    meshes[type][scale] = generate(type, scale)
  return meshes[type][scale]

func generate(type: Type, scale: float):
  var builder = ClipmapMeshBuilder.new(resolution, type, scale)
  return builder.build()
