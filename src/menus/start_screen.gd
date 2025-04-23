extends Control

signal start_pressed
signal exit_pressed


func _on_start_pressed() -> void:
	emit_signal("start_pressed")


func _on_exit_pressed() -> void:
	emit_signal("exit_pressed")
