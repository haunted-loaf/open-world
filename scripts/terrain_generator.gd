@tool
extends Node3D

@export var dirty = false

@export var data: TerrainData
@export var shaderfile: RDShaderFile
@export var resolution = 512
@export var shader: Shader

var image: Image
var texture: Texture2D

func _ready():
  pass

func _process(_delta):
  if dirty:
    dirty = false
    run()

@export var local_scale = 1.0

var t0: int
var t1: int

func tick():
  t0 = Time.get_ticks_usec()
  t1 = t0

func tock(msg: String):
  var t := Time.get_ticks_usec()
  # print(msg, ": ", t - t1)
  t1 = t

func run():
  if not data:
    return

  var instance := MeshInstance3D.new()
  var mesh := QuadMesh.new()
  mesh.flip_faces = true
  var mat := ShaderMaterial.new()
  mat.shader = self.shader
  instance.mesh = mesh
  instance.material_override = mat

  tick()

  var rd : RenderingDevice = RenderingServer.create_local_rendering_device()
  tock("Get rendering device")

  var spirv := shaderfile.get_spirv()
  tock("Get SPIRV")

  var shader := rd.shader_create_from_spirv(spirv)
  tock("Make shader")

  var tf := RDTextureFormat.new()
  tf.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
  tf.width = resolution
  tf.height = resolution
  tf.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
  tock("Specify texture")

  var tex := rd.texture_create(tf, RDTextureView.new()) as RID
  tock("Create teexture")

  var uniform1 := RDUniform.new()
  uniform1.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
  uniform1.binding = 0
  uniform1.add_id(tex)
  tock("Set up texture uniform")

  var pba := PackedByteArray()
  pba.resize(4 * 8)
  pba.encode_float(0, data.world_scale)
  pba.encode_float(4, data.height_scale)
  pba.encode_float(8, local_scale)
  pba.encode_u32(12, resolution)
  tock("Prepare buffer contents")

  for i in 1:

    print("Processing row ", i * 16, " of ", resolution)

    # var pbarid := rd.uniform_buffer_create(16)
    # rd.buffer_update(pbarid, 0, 4 * 4, pba)
    # tock("Create buffer")

    # var uniform2 := RDUniform.new()
    # uniform2.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
    # uniform2.binding = 1
    # uniform2.add_id(pbarid)
    # tock("Set up buffer uniform")

    var uniform_set := rd.uniform_set_create([uniform1], shader, 0)
    var pipe := rd.compute_pipeline_create(shader)
    var list := rd.compute_list_begin()
    tock("Creating pipeline")

    pba.encode_u32(20, i * 16)

    rd.compute_list_bind_compute_pipeline(list, pipe)
    rd.compute_list_bind_uniform_set(list, uniform_set, 0)
    rd.compute_list_set_push_constant(list, pba, 4 * 8)
    rd.compute_list_dispatch(list, resolution / 16, resolution / 16, 1)
    rd.compute_list_end()
    tock("Preparing pipeline")

    rd.submit()
    tock("Submitting pipeline")

    rd.sync()
    tock("Waiting for pipeline to run")
    
    rd.free_rid(uniform_set)
    rd.free_rid(pipe)

    await get_tree().process_frame

    # rd.free_rid(pbarid)

  var bytes := rd.texture_get_data(tex, 0)
  tock("Getting texture data")

  image = Image.create_from_data(resolution, resolution, false, Image.FORMAT_RGBAF, bytes)
  texture = ImageTexture.create_from_image(image)
  mat.set_shader_parameter("terrain_tex", texture)
  tock("Configuring nodes")

  rd.free_rid(shader)
  rd.free_rid(tex)
  rd.free()
  tock("Cleaning up")

  for child in get_children():
    child.queue_free()
  
  add_child(instance)
  # instance.set_owner(get_tree().edited_scene_root)
  
