extends Node2D

signal score
signal danger

var obstacle_textures: Array = [preload("res://assets/cat_paw_1.png"), preload("res://assets/cat_paw_2.png"), preload("res://assets/cat_paw_3.png"), preload("res://assets/cat_paw_4.png")]

var rmd = RandomNumberGenerator.new()

func _ready() -> void:
	var texture_index = randi_range(0, obstacle_textures.size()-1)
	get_node('top_pipe/obstacle_background').texture = obstacle_textures[texture_index]
	get_node('bottom_pipe/obstacle_background').texture = obstacle_textures[texture_index]

func _on_score_area_body_entered(body: Node2D) -> void:
	if body.name == "bird":
		globals.score+=1
		score.emit()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "bird":
		$top_pipe/AnimationPlayer.play("game_over")
		$bottom_pipe/AnimationPlayer.play("game_over")
		danger.emit()
