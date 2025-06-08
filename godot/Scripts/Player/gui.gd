extends CanvasLayer

@export var player : Player
@onready var attack_time: TextureRect = $Control/attackTime

func _ready() -> void:
	$Control/attackTime.visible = false
	
func _process(delta: float) -> void:
	$Control/MarginContainer/VBoxContainer/Health.text = "HP: " + str(player.lives)

func attackTime() -> void:
	$Control/attackTime.visible = true
	if player.target != null:
		Engine.set_time_scale(0.3)
		await get_tree().create_timer(0.4).timeout
		Engine.set_time_scale(1.0)

	$Control/attackTime.visible = false
