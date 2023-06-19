@tool
extends Node3D
class_name ClipmapGrass2

@export var dirty = false

func _process(_delta):
  if dirty:
    run()
    dirty = false

func run():
  var rd := RenderingServer.create_local_rendering_device()
  var file : RDShaderFile = load("res://addons/clipmap_terrain/shaders/heights.glsl")
  var spirv : RDShaderSPIRV = file.get_spirv()
  print(spirv.compile_error_compute)
  var shader := rd.shader_create_from_spirv(spirv)
  # var input := PackedFloat32Array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
  # var input_bytes := input.to_byte_array()
  # var buffer := rd.storage_buffer_create(input_bytes.size(), input_bytes)
  # var uniform := RDUniform.new()
  # uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
  # uniform.binding = 0
  # uniform.add_id(buffer)
  # var uniform_set := rd.uniform_set_create([uniform], shader, 0)
  # var pipeline := rd.compute_pipeline_create(shader)
  # var list := rd.compute_list_begin()
  # rd.compute_list_bind_compute_pipeline(list, pipeline)
  # rd.compute_list_bind_uniform_set(list, uniform_set, 0)
  # rd.compute_list_dispatch(list, 5, 1, 1)
  # rd.compute_list_end()
  # rd.submit()
  # rd.sync()
  # var output_bytes := rd.buffer_get_data(buffer)
  # var output := output_bytes.to_float32_array()
  # print("Input: ", input)
  # print("Output: ", output)

# @export var moved = false

# @export var factory: ClipmapMeshFactory
# @export var size = 64
# @export var snap: float = 1.0
# @export var count = 100

# var material: ShaderMaterial
# var instance: MultiMeshInstance3D

# func _ready():
#   dirty = true

# func _process(_delta):
#   top_level = true
#   var was_dirty = dirty
#   if dirty:
#     dirty = false
#     # factory.shape_material.property_list_changed.connect(func(): dirty = true)
#     for node in get_children():
#       node.queue_free()
#     instance = null
#     moved = true
#   if not instance:
#     make_instance()
#   var new_position = get_parent().global_position.snapped(Vector3(snap, 0.0, snap)) * Vector3(1.0, 0.0, 1.0)
#   if new_position != global_position:
#     moved = true
#   if moved:
#     moved = false
#     global_position = new_position
#     factory.grass_material.set_shader_parameter("world_scale", factory.world_scale)
#     factory.grass_material.set_shader_parameter("height_scale", factory.height_scale)
#     factory.grass_material.set_shader_parameter("fade_distance", size / 2)
#   mesh.material.set_shader_parameter("position", get_parent().global_position)

# var multimesh: MultiMesh
# var mesh: QuadMesh

# func make_instance():
#   instance = MultiMeshInstance3D.new()
#   add_child(instance)
#   # instance.top_level = true
#   multimesh = MultiMesh.new()
#   multimesh.transform_format = MultiMesh.TRANSFORM_3D
#   instance.multimesh = multimesh
#   mesh = QuadMesh.new()
#   mesh.size = Vector2(1.0, 1.0);
#   instance.multimesh.mesh = mesh
#   multimesh.instance_count = count * count
#   mesh.material = factory.grass_material
#   var i = 0
#   for x in count:
#     for z in count:
#       var pos = Vector3(x - (count - 1) / 2.0, 0, z - (count - 1) / 2.0) / count * size
#       multimesh.set_instance_transform(i, Transform3D(Basis.from_euler(Vector3(0, 0, 0)), pos))
#       # multimesh.set_instance_transform(i + 1, Transform3D(Basis.from_euler(Vector3(0, deg_to_rad(-90), 0)), pos))
#       i += 1
