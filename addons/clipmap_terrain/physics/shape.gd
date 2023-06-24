@tool
extends CollisionShape3D
class_name TerrainShape3D

@export var dirty = false
@export var moved = false

@export_node_path("Node3D") var follow: NodePath

@export var data: TerrainData:
  set(value):
    if data != value:
      if data:
        data.changed.disconnect(_on_height_source_generated)
      data = value
      if data:
        data.changed.connect(_on_height_source_generated)

@export var resolution = 16
@export var collider_scale = 1.0
@export var height_scale = 1.0
@export var discard_negative_z = false

@export var snap = 1.0

func _ready():
  dirty = true
  shape = null

func _on_height_source_generated():
  dirty = true

func _process(_delta):
  var was_dirty = dirty
  if dirty:
    dirty = false
    moved = true
  if not shape:
    shape = HeightMapShape3D.new()
  if not has_node(follow):
    return
  var new_position = get_node(follow).global_position.snapped(Vector3(snap, 0.0, snap)) * Vector3(1.0, 0.0, 1.0)
  new_position.y = global_position.y
  position.y = 0
  if new_position != global_position:
    moved = true
  if moved:
    moved = false
    var bytes = data.bytes as PackedByteArray
    if len(bytes) > 0:
      shape.map_width = resolution
      shape.map_depth = resolution
      var array = shape.map_data.duplicate()
      array.clear()
      var i := 0
      for y in range(resolution):
        for x in range(resolution):
          var uv = Vector2(x, y)
          uv /= resolution - 1
          uv -= Vector2(0.5, 0.5);
          uv *= resolution * collider_scale
          uv += Vector2(new_position.x, new_position.z)
          uv /= data.world_size
          uv += Vector2(0.5, 0.5)
          uv *= Vector2(data.texture_size)
          uv = floor(uv)
          if uv.x >= 0 and uv.y >= 0 and uv.y < data.texture_size.x and uv.x < data.texture_size.y:
            i = floori(uv.y) * data.texture_size.x + floori(uv.x)
            var z = bytes.decode_half(i * 8) / collider_scale * height_scale
            if discard_negative_z and z < 0.0:
              array.append(NAN)
            else:
              array.append(z)
          else:
            array.append(NAN)
          # float H = height(uv * data.local_scale + data.position);
          # var uv = Vector2(x, y)
          # array.append(image.get_pixel().r)
          i += 2
        shape.set_map_data(array)
      scale = Vector3(collider_scale, collider_scale, collider_scale)
      global_position.x = new_position.x
      global_position.z = new_position.z
