@tool
extends StaticBody3D
class_name ClipmapBody

@export var dirty = false
@export var moved = false

@export var factory: ClipmapMeshFactory
@export var resolution = 7
@export var collider_scale = 1.0

var shape: HeightMapShape3D

var world_scale: float:
  get:
    return factory.world_scale

var height_scale: float:
  get:
    return factory.height_scale

var collider: CollisionShape3D
var viewport: SubViewport
var material: ShaderMaterial
var texture: ViewportTexture

@export var snap = 1.0

func _ready():
  dirty = true

func _process(_delta):
  var was_dirty = dirty
  if dirty:
    dirty = false
    # factory.shape_material.property_list_changed.connect(func(): dirty = true)
    for node in get_children():
      node.queue_free()
    collider = null
    viewport = null
    moved = true
  if not collider:
    make_collider()
  if not viewport:
    make_viewport()
  var new_position = get_parent().global_position.snapped(Vector3(snap, 0.0, snap)) * Vector3(1.0, 0.0, 1.0)
  if new_position != global_position:
    moved = true
  if moved:
    moved = false
    material.set_shader_parameter("scale", 0.5 * world_scale / resolution / collider_scale)
    material.set_shader_parameter("position", new_position)
    await get_tree().process_frame
    global_position = new_position
    var image = texture.get_image()
    if image:
      var array = PackedFloat32Array()
      for y in range(resolution):
        for x in range(resolution):
          var pixel = image.get_pixel(x, y)
          pixel = pixel.srgb_to_linear()
          array.append((pixel.r * height_scale) / collider_scale)
      shape.set_map_data(array)

func make_viewport():
  viewport = SubViewport.new()
  viewport.own_world_3d = true
  viewport.size = Vector2i(resolution, resolution)
  var camera = Camera3D.new()
  camera.projection = Camera3D.PROJECTION_ORTHOGONAL
  camera.translate(Vector3(0, 0, 0.5))
  var mesh = MeshInstance3D.new()
  var quad = QuadMesh.new()
  mesh.mesh = quad
  add_child(viewport)
  viewport.add_child(camera)
  viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
  viewport.add_child(mesh)
  material = factory.shape_material.duplicate()
  mesh.material_override = material
  texture = viewport.get_texture()

func make_collider():
  collider = CollisionShape3D.new()
  add_child(collider)
  shape = HeightMapShape3D.new()
  shape.map_width = resolution
  shape.map_depth = resolution
  collider.shape = shape

# @export var dirty = false

# @export var snap = 1.0:
#   set(value):
#     if snap != value:
#       dirty = true
#       snap = value

# @export var resolution: int:
#   set(value):
#     if resolution != value:
#       dirty = true
#       resolution = value

# @export var collider_scale: float = 1.0:
#   set(value):
#     if collider_scale != value:
#       dirty = true
#       collider_scale = value

# @export var height_scale: float:
#   set(value):
#     if height_scale != value:
#       dirty = true
#       height_scale = value

# @export var world_scale: float:
#   set(value):
#     if world_scale != value:
#       dirty = true
#       world_scale = value

# @export var heightmap: ViewportTexture:
#   set(value):
#     if heightmap != value:
#       dirty = true
#       heightmap = value

# var image: Image

# @export var position_fudge = Vector2(-4.0, -4.0):
#   set(value):
#     if position_fudge != value:
#       dirty = true
#       position_fudge = value

# @export var height_fudge = 0.0:
#   set(value):
#     if height_fudge != value:
#       dirty = true
#       height_fudge = value

# func _ready():
#   dirty = true

# func make_shape():
#   scale = Vector3(collider_scale, collider_scale, collider_scale)
#   var mat = $SubViewport/MeshInstance3D.material_override as ShaderMaterial
#   if mat:
#     mat.set_shader_parameter("scale", 0.5 * world_scale / resolution / collider_scale)
#     mat.set_shader_parameter("world_scale", world_scale)
#     mat.set_shader_parameter("height_scale", height_scale)
#     mat.set_shader_parameter("position", global_position)
#   var sv = $SubViewport as SubViewport
#   if sv:
#     sv.render_target_update_mode = SubViewport.UPDATE_ONCE
#     sv.size = Vector2i(resolution, resolution)
#   await get_tree().process_frame
#   if not $CollisionShape3D.shape:
#     $CollisionShape3D.shape = HeightMapShape3D.new()
#   $CollisionShape3D.shape.map_width = resolution
#   $CollisionShape3D.shape.map_depth = resolution
#   image = heightmap.get_image()
#   var array = PackedFloat32Array()
#   for y in range(resolution):
#     for x in range(resolution):
#       var pixel = image.get_pixel(x, y)
#       pixel = pixel.srgb_to_linear()
#       array.append((pixel.r * height_scale + height_fudge) / collider_scale)
#   $CollisionShape3D.shape.set_map_data(array)
