extends RigidBody3D

@export_group("Player Selection")
@export_enum("Player 1", "Player 2") var player: int = 0

@export_group("Movement")
@export var move_speed: float = 30.0
@export var jump_force: float = 20.0
@export var air_control: float = 0.8
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
@onready var anim: AnimationTree = %AnimationTree
@onready var anim_state_machine: AnimationNodeStateMachinePlayback = anim.get(
	"parameters/StateMachine/playback"
)


func _ready() -> void:
	# Lock rotation to prevent character from tipping over
	lock_rotation = true

	if player == 0:
		_skin.rotation.y = deg_to_rad(90)
		_last_input_direction = global_basis.x
	elif player == 1:
		_skin.rotation.y = deg_to_rad(-90)
		_last_input_direction = -global_basis.x


func _physics_process(delta: float) -> void:
	is_grounded = ground_check.is_colliding()

	var raw_input: Vector2
	if player == 0:
		raw_input = (
			Input
			. get_vector("player1_left", "player1_right", "player1_up", "player1_down", 0.4)
			. normalized()
		)
	else:
		raw_input = (
			Input
			. get_vector("player2_left", "player2_right", "player2_up", "player2_down", 0.4)
			. normalized()
		)

	move_direction = transform.basis * Vector3(raw_input.x, 0, raw_input.y).normalized()

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

	var is_just_jumping: bool

	if player == 0:
		is_just_jumping = Input.is_action_just_pressed("player1_jump")
	else:
		is_just_jumping = Input.is_action_just_pressed("player2_jump")

	if is_grounded and is_just_jumping:
		apply_central_impulse(Vector3.UP * jump_force)
		#_skin.jump()
		#_jump_sound.play()
		pass
	elif not is_grounded and velocity.y < 0:
		#_skin.fall()
		pass
	elif is_grounded:
		if ground_speed > 0.0:
			anim_state_machine.travel("running")
			pass
		else:
			anim_state_machine.travel("idle")
			pass

	#_dust_particles.emitting = is_on_floor() && ground_speed > 0.0

	#if is_on_floor() and not _was_on_floor_last_frame:
	#_landing_sound.play()

	_was_on_floor_last_frame = is_grounded
