extends Node2D

func _ready() -> void:
	update_score()

func update_score():
	var score_label = $Panel/Label
	score_label.text = "Score: " + str(globals.score)
