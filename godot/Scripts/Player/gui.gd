extends CanvasLayer

@export var player : Player
@onready var attack_time: TextureRect = $Control/attackTime
var current_wave : Array = [
	"MAGIC",
	"TECH"
]

func _ready() -> void:
	$Control/attackTime.visible = false
	
func _process(delta: float) -> void:
	
	%HPBar.max_value = GLOBAL.max_health
	%HPBar.value = GLOBAL.health
	%HPLabel.text = str(GLOBAL.health) + "/" + str(GLOBAL.max_health)
	%SPBar.max_value = GLOBAL.max_stamina
	%SPBar.value = GLOBAL.stamina
	%SPLabel.text = str(GLOBAL.stamina) + "/" + str(GLOBAL.max_stamina)
	%Wave.text = "WAVE:   " + current_wave[GLOBAL.current_wave]

func attackTime() -> void:
	if player.target != null:
		$Control/attackTime.visible = true
		Engine.set_time_scale(0.3)
		await get_tree().create_timer(0.4).timeout
		Engine.set_time_scale(1.0)
		$Control/attackTime.visible = false
