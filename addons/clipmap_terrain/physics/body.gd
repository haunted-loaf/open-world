@tool
extends StaticBody3D
class_name ClipmapBody

@export var dirty = false
@export var moved = false

@export var data: TerrainData
@export var resolution = 7
@export var collider_scale = 1.0
@export var height_offset = 0.0

var shape: HeightMapShape3D

var world_scale: float:
  get:
    return data.world_scale

var height_scale: float:
  get:
    return data.height_scale

var collider: CollisionShape3D
var viewport: SubViewport
var material: ShaderMaterial
var texture: ViewportTexture

@export var snap = 1.0

func _ready():
  dirty = true

func _process(_delta):
  top_level = true
  var was_dirty = dirty
  if dirty:
    dirty = false
    # data.shape_material.property_list_changed.connect(func(): dirty = true)
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
    material.set_shader_parameter("patch_size", resolution * collider_scale)
    material.set_shader_parameter("position", new_position)
    await get_tree().process_frame
    global_position = new_position
    var image = texture.get_image()
    if image:
      shape.map_width = resolution
      shape.map_depth = resolution
      var array = shape.map_data.duplicate()
      array.clear()
      for y in range(resolution):
        for x in range(resolution):
          var pixel = image.get_pixel(x, y).srgb_to_linear().r
          array.append(((2.0 * pixel - 1.0) * height_scale))
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
  material = data.shape_material.duplicate()
  mesh.material_override = material
  texture = viewport.get_texture()

func make_collider():
  collider = CollisionShape3D.new()
  add_child(collider)
  # collider.set_owner(get_tree().edited_scene_root)
  shape = HeightMapShape3D.new()
  collider.shape = shape
