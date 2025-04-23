extends Node

@onready var stage_scene: PackedScene = preload("uid://c6dxex3xegd5p")
@onready var start_screen: Control = %StartScreen


func _on_start_screen_start_pressed() -> void:
	start_screen.hide()

	var stage: Node3D = stage_scene.instantiate()
	add_child(stage)


func _on_start_screen_exit_pressed() -> void:
	get_tree().quit()
