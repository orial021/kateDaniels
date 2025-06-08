extends Node

@onready var player : Player = get_parent()
@onready var animations: AnimationTree = $"../AnimationTree"


func _on_attack_timer_timeout() -> void:
	player.last_attack = AttackData.AttackType.NULL
	player.attack_on_time = false
	$attackModeTimer.start()
	animations.attack_idle()

func _on_attack_mode_timer_timeout() -> void:
	player.attack_mode = false
	animations.idle()
