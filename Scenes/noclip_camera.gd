extends Camera3D

@export var mouse_sensitivity: float = 0.002
@export var move_speed: float = 10.0
@export var fast_speed_multiplier: float = 3.0
@export var slow_speed_multiplier: float = 0.3

var _velocity: Vector3 = Vector3.ZERO
var _speed_multiplier: float = 1.0


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		rotate_object_local(Vector3.RIGHT, -event.relative.y * mouse_sensitivity)

	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta: float) -> void:
	# Adjust speed with modifier keys or scroll wheel
	if Input.is_key_pressed(KEY_SHIFT):
		_speed_multiplier = fast_speed_multiplier
	elif Input.is_key_pressed(KEY_ALT):
		_speed_multiplier = slow_speed_multiplier
	else:
		_speed_multiplier = 1.0

	var input_dir := Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		input_dir.z -= 1
	if Input.is_key_pressed(KEY_S):
		input_dir.z += 1
	if Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_D):
		input_dir.x += 1
	if Input.is_key_pressed(KEY_E):
		input_dir.y += 1
	if Input.is_key_pressed(KEY_Q):
		input_dir.y -= 1

	input_dir = input_dir.normalized()
	
	var current_speed = move_speed * _speed_multiplier
	transform.origin += global_basis * input_dir * current_speed * delta
