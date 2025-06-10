extends Node
 
var axis : Vector2
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var high_cognition : bool = false
var health : int
var stamina : int
var mana : int
enum WaveType {MAGIC, TECH}
var current_wave: WaveType = WaveType.TECH

func get_axis() -> Vector2:
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	axis.y = int(Input.is_action_pressed("ui_up")) - int(Input.is_action_pressed("ui_down"))
	return axis.normalized()
