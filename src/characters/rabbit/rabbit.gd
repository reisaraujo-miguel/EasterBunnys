extends RigidBody3D

@export_group("Movement")
@export var move_speed: float = 50.0
@export var jump_force: float = 10.0
@export var air_control: float = 0.3

@export var ground_ray_length: float = 1.2

@export var rotation_speed: float = 12.0

var is_grounded: bool = false
var move_direction: Vector3 = Vector3.ZERO
var _was_on_floor_last_frame: bool = true

@onready var _last_input_direction: Vector3 = global_basis.z
@onready var _skin: Node3D = %RabbitSkin
@onready var ground_check: RayCast3D = %RayCast3D
#@onready var _landing_sound: AudioStreamPlayer3D = %LandingSound
#@onready var _jump_sound: AudioStreamPlayer3D = %JumpSound
#@onready var _dust_particles: GPUParticles3D = %DustParticles


func _ready() -> void:
	# Lock rotation to prevent character from tipping over
	lock_rotation = true


func _physics_process(delta: float) -> void:
	is_grounded = ground_check.is_colliding()

	# Calculate movement input and align it to the camera's direction.
	var raw_input: Vector2 = Input.get_vector(
		"move_right", "move_left", "move_down", "move_up", 0.4
	)

	# Should be projected onto the ground plane.
	move_direction = transform.basis * Vector3(raw_input.x, 0, raw_input.y).normalized()

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
