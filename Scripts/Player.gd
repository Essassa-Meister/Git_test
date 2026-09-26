extends CharacterBody3D

@export var move_speed: float = 6.0
@export var jump_velocity: float = 6.5
@export var gravity: float = 18.0
@export var mouse_sensitivity: float = 0.0025
@export_range(-89, 89) var max_pitch: float = 75.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D

var yaw: float = 0.0
var pitch: float = 0.0

func _ready() -> void:
	_register_input_actions()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	position.y = 0.9
	camera.current = true
	camera_pivot.rotation.y = yaw
	camera_pivot.rotation.x = pitch

func _register_input_actions() -> void:
	var actions: Array = ["move_forward", "move_back", "move_left", "move_right", "jump"]
	for action in actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)

	_bind_key("move_forward", KEY_W)
	_bind_key("move_back", KEY_S)
	_bind_key("move_left", KEY_A)
	_bind_key("move_right", KEY_D)
	_bind_key("jump", KEY_SPACE)

func _bind_key(action: String, keycode: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	event.keycode = keycode
	event.pressed = true
	InputMap.action_add_event(action, event)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * mouse_sensitivity
		pitch = clamp(pitch - event.relative.y * mouse_sensitivity, deg_to_rad(-max_pitch), deg_to_rad(max_pitch))
		camera_pivot.rotation.y = yaw
		camera_pivot.rotation.x = pitch
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	if is_on_floor():
		if velocity.y < 0.0:
			velocity.y = 0.0
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
	else:
		velocity.y -= gravity * delta

	var move_dir := Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		move_dir.z -= 1.0
	if Input.is_action_pressed("move_back"):
		move_dir.z += 1.0
	if Input.is_action_pressed("move_left"):
		move_dir.x -= 1.0
	if Input.is_action_pressed("move_right"):
		move_dir.x += 1.0

	if move_dir.length() > 0.0:
		move_dir = move_dir.normalized()
		var forward := -camera_pivot.global_transform.basis.z
		var right := camera_pivot.global_transform.basis.x
		var desired_velocity := (forward * move_dir.z + right * move_dir.x) * move_speed
		velocity.x = desired_velocity.x
		velocity.z = desired_velocity.z
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed)
		velocity.z = move_toward(velocity.z, 0.0, move_speed)

	move_and_slide()
