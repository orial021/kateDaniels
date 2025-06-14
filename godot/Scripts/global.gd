extends Node
 
var axis : Vector2
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var high_cognition : bool = false
var level : int = 1
var health : float
var stamina : float
var mana : float
var current_experience : int = 0
var next_level_experience : int = 20
var current_wave: WaveType = WaveType.TECH
enum WaveType {MAGIC, TECH}
enum TYPE {
	PHYSICAL,
	MAGICAL,
	HYBRID
}

func get_axis() -> Vector2:
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	axis.y = int(Input.is_action_pressed("ui_up")) - int(Input.is_action_pressed("ui_down"))
	return axis.normalized()
