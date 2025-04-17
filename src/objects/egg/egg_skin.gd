extends Node3D

@onready var _skin: MeshInstance3D = %Sphere

@onready var _texture_1: Texture2D = preload("uid://cnt573igd4nsm") as Texture2D
@onready var _texture_2: Texture2D = preload("uid://dbnjk5vqnjn3u") as Texture2D
@onready var _texture_3: Texture2D = preload("uid://cki4ta2hw5qfh") as Texture2D


func _ready() -> void:
	var texture_idx: int = randi_range(0, 2)

	set_texture(texture_idx)


func set_texture(texture_idx: int) -> void:
	var texture: Texture2D

	match texture_idx:
		0:
			texture = _texture_1
		1:
			texture = _texture_2
		2:
			texture = _texture_3

	var material: StandardMaterial3D = _skin.get_surface_override_material(0)

	material.albedo_texture = texture
