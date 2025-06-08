extends CanvasLayer

@export var player : Player
@onready var attack_time: TextureRect = $Control/attackTime

func _ready() -> void:
	$Control/attackTime.visible = false
	
func _process(delta: float) -> void:
	$Control/MarginContainer/VBoxContainer/Health.text = "HP: " + str(player.lives)

func attackTime() -> void:
	$Control/attackTime.visible = true
	await get_tree().create_timer(0.4).timeout
	$Control/attackTime.visible = false
