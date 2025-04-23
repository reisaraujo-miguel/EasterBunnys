extends Node3D

signal respawn(id: StringName)


func _on_respawn_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player 1"):
		emit_signal("respawn", "player 1")
	elif body.is_in_group("player 2"):
		emit_signal("respawn", "player 2")
	elif body.is_in_group("egg"):
		emit_signal("respawn", "egg")
	else:
		pass  # Any other case we don't care about
