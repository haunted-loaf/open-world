extends Node
class_name MouseLook

@export var yawNode: Node3D
@export var pitchNode: Node3D
@export var dollyNode: Node3D

@export var initialZoom : float = 0
@export var maxZoom : float = 5
@export var minZoom : float = 0
@export var zoomStep : float = 2
@export var verticalSensitivity : float = 0.002
@export var horizontalSensitivity : float = 0.002
@export var camLerpSpeed : float = 16.0
@export var lean : float = 0

@onready var _curZoom : float = initialZoom

var _rotation : Vector3 = Vector3(0, 0, 0)
var mouseGrabbed : bool = false

func _ready() -> void:
  set_process_priority(1000)
  _curZoom = dollyNode.position.z
  lean = dollyNode.position.x
  _rotation.x = pitchNode.rotation.x
  _rotation.y = yawNode.rotation.y
  apply()

var mouse_position : Vector2 = Vector2.ZERO

func _input(event):
  if mouseGrabbed and event is InputEventMouseMotion:
    _rotation.y -= event.relative.x * horizontalSensitivity
    _rotation.y = wrapf(_rotation.y,0.0,TAU)
    _rotation.x -= event.relative.y * verticalSensitivity
    _rotation.x = wrapf(_rotation.x,0.0,TAU)

func _process(_delta):
  if Input.is_action_pressed("look_escape"):
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    mouseGrabbed = false
  if Input.is_action_just_released("look_zoom_in"):
    if abs(lean) > 0:
      lean = 0
    elif _curZoom > minZoom:
      _curZoom -= zoomStep
  if Input.is_action_just_released("look_zoom_out"):
    if _curZoom < maxZoom:
      _curZoom += zoomStep
    elif lean == 0:
      lean = 1
    else:
      lean = -lean
  if Input.is_action_just_pressed("look_toggle"):
    var focus_haver = get_node("FocusHaver") as Control
    if focus_haver:
      focus_haver.grab_focus()
      focus_haver.release_focus()
    mouseGrabbed = true
    mouse_position = get_viewport().get_mouse_position()
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
  if Input.is_action_just_released("look_toggle"):
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    Input.warp_mouse(mouse_position)
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    mouseGrabbed = false

func _physics_process(_delta) -> void:
  apply()

func apply():
  dollyNode.position.z = _curZoom
  dollyNode.position.x = lean
  pitchNode.rotation.x = _rotation.x
  yawNode.rotation.y = _rotation.y
