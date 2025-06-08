extends Node
 
var axis : Vector2
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var high_cognition : bool = false
var max_health := 100
var health : int
var max_stamina := 100
var stamina : int
enum WaveType {MAGIC, TECH}
var current_wave: WaveType = WaveType.TECH

func _ready() -> void:
	health = max_health
	stamina = max_stamina

func get_axis() -> Vector2:
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	axis.y = int(Input.is_action_pressed("ui_up")) - int(Input.is_action_pressed("ui_down"))
	return axis.normalized()
