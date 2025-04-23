extends Control

var player1_score: int = 0:
	set(value):
		player1_score_label.text = str(value)
		player1_score = value

var player2_score: int = 0:
	set(value):
		player2_score_label.text = str(value)
		player2_score = value

@onready var player1_score_label: Label = %P1ScoreLabel
@onready var player2_score_label: Label = %P2ScoreLabel


func _on_stage_player_1_scored() -> void:
	player1_score += 1


func _on_stage_player_2_scored() -> void:
	player2_score += 1
