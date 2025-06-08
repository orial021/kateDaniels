extends Node3D

enum WaveType {MAGIC, TECH}
var current_wave: WaveType = WaveType.TECH
@onready var env = $WorldEnvironment

func _ready() -> void:
	env.environment.volumetric_fog_enabled = false
	#await get_tree().create_timer(7).timeout
	#print("ola magica")
	#toggle_wave()
	
func toggle_wave():
	current_wave = WaveType.MAGIC if current_wave == WaveType.TECH else WaveType.TECH
	update_environment()
	
func update_environment():
	if current_wave == WaveType.MAGIC:
		env.environment.background_color = Color(0.2, 0, 0.3)
		env.environment.volumetric_fog_enabled = true
		
	else:
		env.environment.background_color = Color(0.1, 0.1, 0.1)
		env.environment.fog_enabled = false
