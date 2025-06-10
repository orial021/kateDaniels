extends Node3D


@onready var env = $Settings/WorldEnvironment

func _ready() -> void:
	env.environment.volumetric_fog_enabled = false
	#await get_tree().create_timer(7).timeout
	#toggle_wave()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		toggle_wave()
		
func toggle_wave():
	GLOBAL.current_wave = GLOBAL.WaveType.MAGIC if GLOBAL.current_wave == GLOBAL.WaveType.TECH else GLOBAL.WaveType.TECH
	update_environment()
	
func update_environment():
	if GLOBAL.current_wave == GLOBAL.WaveType.MAGIC:
		env.environment.background_color = Color(0.2, 0, 0.3)
		env.environment.volumetric_fog_enabled = true
	if GLOBAL.current_wave == GLOBAL.WaveType.TECH:
		env.environment.background_color = Color(0.1, 0.1, 0.1)
		env.environment.volumetric_fog_enabled = false

func _on_wave_timer_timeout() -> void:
	toggle_wave()
