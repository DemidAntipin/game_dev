extends Node2D

@onready var spawn_point: Marker2D = $Marker2D

func _place_character(character: CharacterBody2D):
	character.global_position = spawn_point.global_position
