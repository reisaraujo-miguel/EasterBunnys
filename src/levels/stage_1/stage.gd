extends Node3D

@onready var player1: RigidBody3D = %Player1
@onready var player2: RigidBody3D = %Player2
@onready var egg: RigidBody3D = %Egg
@onready var player1_spawn: Marker3D = %Player1Spawn
@onready var player2_spawn: Marker3D = %Player2Spawn
@onready var egg_spawn: Marker3D = %EggSpawn

signal player1_scored
signal player2_scored


func _on_ground_respawn(id: StringName) -> void:
	if id == "player 1":
		respawn_player_1()
	elif id == "player 2":
		respawn_player_2()
	elif id == "egg":
		respawn_egg()
	else:
		pass  # Any other case we don't care about


func respawn_player_1() -> void:
	player1.global_position = player1_spawn.global_position


func respawn_player_2() -> void:
	player2.global_position = player2_spawn.global_position


func respawn_egg() -> void:
	egg.global_position = egg_spawn.global_position


func respawn_all() -> void:
	respawn_player_1()
	respawn_player_2()
	respawn_egg()


func _on_player_1_flag_body_entered(body: Node3D) -> void:
	if body.is_in_group("egg"):
		emit_signal("player1_scored")
		respawn_all()


func _on_player_2_flag_body_entered(body: Node3D) -> void:
	if body.is_in_group("egg"):
		emit_signal("player2_scored")
		respawn_all()
