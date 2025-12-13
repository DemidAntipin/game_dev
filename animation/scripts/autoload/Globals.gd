extends Node

var max_health = 5

func pause():
	get_tree().set_pause(true)
	
func resume():
	get_tree().set_pause(false)
