extends Node2D

var speed: int = 0
var max_speed: int = 250
@onready var shield_sprite: Sprite2D = get_node("ship_area/ShipSprite/shield")
@onready var flame_sprite: Sprite2D = get_node("ship_area/ShipSprite/flame")

@onready var shield_recovery: Timer = get_node("ship_area/ShipSprite/shield/recovery_time")
var shield_is_active: bool = true
var player_is_immune: bool = false
var blink_interval: float = 0.2
var damage_recieved_time: float = 0.0
var blink_timer: float = 0.0
@onready var ship_sprite: Sprite2D = get_node("ship_area/ShipSprite")

func _ready() -> void:
	shield_recovery.timeout.connect(_on_shield_recovered)

func _process(delta: float) -> void:
	var label: Label = get_node("PositionLabel")
	label.text = "Position %v" % position
	if Input.is_action_pressed("ui_left"):
		rotation -= 0.1
	if Input.is_action_pressed("ui_right"):
		rotation += 0.1
	if Input.is_action_pressed("ui_up"):
		speed += 5
		if speed >= max_speed:
			speed = max_speed
	if Input.is_action_pressed("ui_down"):
		speed -= 5
		if speed <= 0:
			speed = 0
	var x = 0.1 * cos(rotation + PI/2)
	var y = 0.1 * sin(rotation + PI/2)
	position += speed * delta * Vector2(x, y).normalized()
	flame_sprite.scale = Vector2(1, float(speed)/float(max_speed))*3
	
	if player_is_immune:
		var current_time = Time.get_ticks_msec()
		if current_time - damage_recieved_time > 3000:
			player_is_immune = false
			ship_sprite.visible = true
		else:
			blink_timer -= delta
			if blink_timer <= 0:
				ship_sprite.visible = !ship_sprite.visible
				blink_timer = blink_interval
	
func damage():
	if shield_is_active:
		shield_sprite.visible = false
		shield_is_active = false
		shield_recovery.start()
	else:
		if !player_is_immune:
			player_is_immune = true
			blink_timer = 0
			damage_recieved_time = Time.get_ticks_msec()
		
func _on_shield_recovered():
	shield_is_active = true
	shield_sprite.visible = true
	
