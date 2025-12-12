extends Node

signal zero_score

var level_index = 0

var score: int = 0

var offscreen_distance:float = 350
var gap:float = 350
var shift_y:float = 220
var world_offset:float = 0.0

# Переменные для управления звуком
var muted_cutoff_hz = 300.0  # частота приглушенного звука на паузе

func pause():
	get_tree().set_pause(true)
	var lowpass = AudioEffectLowPassFilter.new()
	lowpass.cutoff_hz = muted_cutoff_hz
	AudioServer.add_bus_effect(0, lowpass)
	

func resume():
	get_tree().set_pause(false)
	for i in range(AudioServer.get_bus_effect_count(0)):
		AudioServer.remove_bus_effect(0, i)

func exit():
	get_tree().quit()

func null_score():
	score = 0
	zero_score.emit()
