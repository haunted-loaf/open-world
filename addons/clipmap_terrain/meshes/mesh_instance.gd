@tool
class_name ClipmapMeshInstance
extends MeshInstance3D

@export var type: ClipmapMeshFactory.Type:
  set(value):
    if type == value:
      return
    type = value
    dirty = true

@export var factory: ClipmapMeshFactory:
  set(value):
    if factory == value:
      return
    factory = value
    factory.changed.connect(_on_factory_changed)
    dirty = true

@export var mesh_scale: float = 1.0:
  set(value):
    if mesh_scale != value:
      mesh_scale = value
      dirty = true

@export var dirty = false

static func make(factory: ClipmapMeshFactory, type: ClipmapMeshFactory.Type, scale: float):
  var instance = ClipmapMeshInstance.new()
  instance.factory = factory
  instance.type = type
  instance.mesh_scale = scale
  return instance

func _process(_delta):
  top_level = true
  if not dirty:
    return
  dirty = false
  update()

func update():
  if not factory:
    return
  mesh = factory.get_mesh(type, mesh_scale)
  extra_cull_margin = 16384
  material_override = factory.material

func _on_factory_changed():
  dirty = true
