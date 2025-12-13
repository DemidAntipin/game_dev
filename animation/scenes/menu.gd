extends Node2D

signal level_changed
	
func _resume() -> void:
	Globals.resume()
	hide()
	
func _exit() -> void:
	get_tree().quit()

func _volume_changed(value:float):
	var bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_linear(bus, value)
	
func update_levels(levels: Array):
	var options = $CenterContainer/VBoxContainer/OptionButton
	for level in levels:
		options.add_item(level)
		

func _on_option_button_item_selected(index: int) -> void:
	_resume()
	var options = $CenterContainer/VBoxContainer/OptionButton
	level_changed.emit(options.get_item_text(index))
