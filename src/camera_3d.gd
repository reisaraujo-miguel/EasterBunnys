extends Camera3D

@export_group("Player References")
@export var player1_path: NodePath
@export var player2_path: NodePath

@export_group("Camera Settings")
@export_enum("Overhead", "Angled") var camera_style: int = 0
@export var min_distance: float = 8.0  # Minimum camera distance/size
@export var max_distance: float = 30.0  # Maximum camera distance/size
@export var distance_margin: float = 2.0  # Extra margin to add to required distance
@export var smoothing: float = 2.0  # How smoothly the camera moves
@export var angle_degrees: float = 60.0

@onready var player1: RigidBody3D = %Player1
@onready var player2: RigidBody3D = %Player2

var current_distance: float


func _ready() -> void:
	# Make sure we found both players
	if !player1 or !player2:
		push_error("Dynamic Camera: Could not find player nodes!")

	# Initialize distance
	current_distance = min_distance


func _process(delta: float) -> void:
	if !player1 or !player2:
		return

	# Calculate the midpoint between players
	var midpoint: Vector3 = (player1.global_position + player2.global_position) / 2

	# Calculate the distance between players
	var player_distance: float = player1.global_position.distance_to(player2.global_position)

	# Calculate desired camera distance based on player separation
	var desired_distance: float = clamp(
		player_distance + distance_margin, min_distance, max_distance
	)

	# Smoothly adjust current distance
	current_distance = lerp(current_distance, desired_distance, smoothing * delta)

	# For angled view, position based on camera angle
	var angle_rad: float = deg_to_rad(angle_degrees)
	var height: float = sin(angle_rad) * current_distance
	var horizontal_distance: float = cos(angle_rad) * current_distance

	# Position camera at an angle from the midpoint
	var target_position: Vector3 = Vector3(
		midpoint.x, midpoint.y + height, midpoint.z - horizontal_distance
	)  # Camera looks in negative Z direction

	# Smoothly move camera to target position
	global_position = global_position.lerp(target_position, smoothing * delta)
