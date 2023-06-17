class_name CharacterController
extends CharacterBody3D

@export var flying = false
@export var SPEED = 5.0
@export var ACCEL = 5.0
@export var BRAKE = 50.0
@export var JUMP_VELOCITY = 4.5

var double_tap_timer = 0.0
var double_tap_timeout = 1.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func rotation_to(from: Vector3, to: Vector3) -> Quaternion:
  var cross = from.cross(to)
  var dot = from.dot(to)
  var theta = atan2(cross.length(), dot)
  return Quaternion(cross.normalized(), theta)

func _physics_process(delta):
  var new_up = (global_position * -Vector3(1, 1, 0)).normalized()
  var cur_up = global_transform.basis.y.normalized()
  var rot = rotation_to(cur_up, new_up)
#  print(rot.get_angle())
  global_transform.basis = global_transform.basis.rotated(rot.get_axis().normalized(), rot.get_angle())
  velocity = velocity.rotated(rot.get_axis().normalized(), rot.get_angle())
  
#  look_at(global_position + global_transform.basis.z, (global_position * -Vector3(1, 1, 0)).normalized())
  double_tap_timer = max(0.0, double_tap_timer - delta)
  var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
  var up_down = Input.get_axis("move_down", "move_up")
  var direction = ($"Camera Base/Yaw".global_transform.basis * Vector3(input_dir.x, up_down, input_dir.y)).normalized() * SPEED
  if flying:
    position.y += sin(Time.get_ticks_msec() / 1000.0) / 1000.0
    if Input.is_action_just_pressed("move_down") or Input.is_action_just_pressed("move_up"):
      if double_tap_timer > 0.0:
#        flying = false
        double_tap_timer = 0.0
      else:
        double_tap_timer = double_tap_timeout
  else:
    if not is_on_floor():
      if Input.is_action_just_pressed("move_up"):
        if double_tap_timer > 0.0:
          flying = true
          double_tap_timer = 0.0
        else:
          double_tap_timer = double_tap_timeout
      direction.x = velocity.x
      direction.z = velocity.z
      velocity.y -= gravity * delta
    elif Input.is_action_just_pressed("move_jump"):
      velocity.y = JUMP_VELOCITY
    else:
      velocity.y = 0
    direction.y = velocity.y
  if direction.length() < velocity.length():
    velocity = velocity.move_toward(direction, delta * BRAKE)
  else:
    velocity = velocity.move_toward(direction, delta * ACCEL)
  move_and_slide()
