extends Node

var level_index = 0

var score: int = 0

var offscreen_distance:float = 350
var gap:float = 350
var shift_y:float = 220
var world_offset:float = 0.0

func pause():
	get_tree().set_pause(true)

func resume():
	get_tree().set_pause(false)

func exit():
	get_tree().quit()
