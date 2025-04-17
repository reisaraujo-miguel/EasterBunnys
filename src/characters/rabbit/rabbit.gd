extends RigidBody3D

@export_group("Movement")
@export var move_speed: float = 50.0
@export var jump_force: float = 10.0
@export var air_control: float = 0.3

@export var ground_ray_length: float = 1.2

@export var rotation_speed: float = 12.0
@export var stopping_speed: float = 1.0

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity: float = 0.25
@export var tilt_upper_limit: float = PI / 3.0
@export var tilt_lower_limit: float = -PI / 8.0

var is_grounded: bool = false
var move_direction: Vector3 = Vector3.ZERO
var _was_on_floor_last_frame: bool = true
var _camera_input_direction: Vector2 = Vector2.ZERO

@onready var _last_input_direction: Vector3 = global_basis.z
@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
@onready var _skin: Node3D = %RabbitSkin
@onready var ground_check: RayCast3D = %RayCast3D
#@onready var _landing_sound: AudioStreamPlayer3D = %LandingSound
#@onready var _jump_sound: AudioStreamPlayer3D = %JumpSound
#@onready var _dust_particles: GPUParticles3D = %DustParticles


func _ready() -> void:
	# Lock rotation to prevent character from tipping over
	lock_rotation = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	var player_is_using_mouse: bool = (
		event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if player_is_using_mouse:
		_camera_input_direction.x = -(event as InputEventMouseMotion).relative.x * mouse_sensitivity
		_camera_input_direction.y = -(event as InputEventMouseMotion).relative.y * mouse_sensitivity


func _physics_process(delta: float) -> void:
	is_grounded = ground_check.is_colliding()

	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, tilt_lower_limit, tilt_upper_limit)
	_camera_pivot.rotation.y += _camera_input_direction.x * delta

	_camera_input_direction = Vector2.ZERO

	# Calculate movement input and align it to the camera's direction.
	var raw_input: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_up", "move_down", 0.4
	)

	# Should be projected onto the ground plane.
	var forward: Vector3 = _camera.global_basis.z
	var right: Vector3 = _camera.global_basis.x

	move_direction = forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()

	# To not orient the character too abruptly, we filter movement inputs we
	# consider when turning the skin. This also ensures we have a normalized
	# direction for the rotation basis.
	if move_direction.length() > 0.2:
		_last_input_direction = move_direction

	var target_angle: float = Vector3.BACK.signed_angle_to(_last_input_direction, Vector3.UP)
	_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)

	var velocity: Vector3 = move_direction * move_speed
	if is_grounded:
		apply_central_force(velocity)
	else:
		apply_central_force(velocity * air_control)

	# Character animations and visual effects.
	var ground_speed: float = Vector2(velocity.x, velocity.z).length()
	var is_just_jumping: bool = Input.is_action_just_pressed("jump")
	if is_just_jumping:
		apply_central_impulse(Vector3.UP * jump_force)
		#_skin.jump()
		#_jump_sound.play()
		pass
	elif not is_grounded and velocity.y < 0:
		#_skin.fall()
		pass
	elif is_grounded:
		if ground_speed > 0.0:
			#_skin.move()
			pass
		else:
			#_skin.idle()
			pass

	#_dust_particles.emitting = is_on_floor() && ground_speed > 0.0

	#if is_on_floor() and not _was_on_floor_last_frame:
	#_landing_sound.play()

	_was_on_floor_last_frame = is_grounded
