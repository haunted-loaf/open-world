@tool
class_name TerrainGenerator
extends Node3D

@export var data: TerrainData
@export var compute_shader: RDShaderFile
@export var resolution = 512
@export var state = "Idle"
@export var terrain_name = "terrain"
@export_dir var resource_dir

var thread: Thread

@export var generate = false:
  set(value):
    if value:
      thread = Thread.new()
      thread.start(_generate)

func _generate():
  if not compute_shader:
    return null

  state = "Preparing"

  var rd := RenderingServer.create_local_rendering_device()
  var spirv := compute_shader.get_spirv()
  var shader := rd.shader_create_from_spirv(spirv)

  var tf := RDTextureFormat.new()
  tf.format = RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT
  tf.width = resolution
  tf.height = resolution
  tf.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
  
  var rd_texture := rd.texture_create(tf, RDTextureView.new()) as RID

  var uniform1 := RDUniform.new()
  uniform1.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
  uniform1.binding = 0
  uniform1.add_id(rd_texture)

  var pba := PackedByteArray()
  pba.resize(4 * 8)
  pba.encode_float(0, data.world_size)
  pba.encode_float(4, data.world_height)
  pba.encode_float(8, data.world_size)
  pba.encode_u32(12, resolution)

  var uniform_set := rd.uniform_set_create([uniform1], shader, 0)
  var pipe := rd.compute_pipeline_create(shader)
  var list := rd.compute_list_begin()

  rd.compute_list_bind_compute_pipeline(list, pipe)
  rd.compute_list_bind_uniform_set(list, uniform_set, 0)
  rd.compute_list_set_push_constant(list, pba, 4 * 8)
  rd.compute_list_dispatch(list, resolution / 16, resolution / 16, 1)
  rd.compute_list_end()

  rd.submit()
  
  state = "Computing"
  rd.sync()
  
  state = "Fetching data"
  var bytes := rd.texture_get_data(rd_texture, 0)

  state = "Building image"
  var image := Image.create_from_data(resolution, resolution, false, Image.FORMAT_RGBAH, bytes)

  state = "Generating mipmaps"
  image.generate_mipmaps()

  state = "Saving image"
  image.save_exr("%s/%s.exr" % [resource_dir, terrain_name])

  state = "Creating texture"
  var texture := ImageTexture.create_from_image(image)

  state = "Creating material"
  var mat := StandardMaterial3D.new()
  mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
  mat.albedo_texture = texture

  state = "Creating mesh instance"
  var instance := MeshInstance3D.new()
  instance.material_override = mat
  instance.mesh = QuadMesh.new()

  state = "The old switcheroo"
  for child in get_children():
    child.queue_free()
  add_child(instance)

  state = "Tidying up"
  rd.free_rid(pipe)
  rd.free_rid(uniform_set)
  rd.free_rid(rd_texture)
  rd.free_rid(shader)
  rd.free()

  call_deferred("finish")

func finish():
  state = "Finished"
  thread.wait_to_finish()
  thread = null
