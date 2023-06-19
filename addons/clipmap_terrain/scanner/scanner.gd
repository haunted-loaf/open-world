@tool
extends Node3D
class_name ClipmapScanner

@export var dirty = false
@export var moved = false

@export var factory: ClipmapMeshFactory
@export var resolution = 7
@export var snap: float = 1.0

var texture: ViewportTexture
var rect: TextureRect
var viewport: SubViewport
var material: ShaderMaterial

func _ready():
  dirty = true

func _process(_delta):
  top_level = true
  var was_dirty = dirty
  if dirty:
    dirty = false
    # factory.shape_material.property_list_changed.connect(func(): dirty = true)
    for node in get_children():
      node.queue_free()
    viewport = null
    moved = true
  if not viewport:
    make_viewport()
  var new_position = get_parent().global_position.snapped(Vector3(snap, 0.0, snap)) * Vector3(1.0, 0.0, 1.0)
  if new_position != global_position:
    moved = true
  if moved:
    moved = false
    material.set_shader_parameter("scale", 0.5 * factory.world_scale / resolution)
    material.set_shader_parameter("position", new_position)
    await get_tree().process_frame
    global_position = new_position
    # global_position = Vector3(new_position.x, -height_offset, new_position.z)
    # collider.global_position.y = -height_offset;
    # var image = texture.get_image()

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
  rect = TextureRect.new()
  add_child(rect)
  rect.texture = texture
