extends Node

@onready var player : Player = get_parent()
@onready var animations: AnimationTree = $"../AnimationTree"
var gui : CanvasLayer

func _ready() -> void:
	gui = player.gui

func _on_can_attack_timer_timeout() -> void:
	gui.attackTime()
	player.can_attack = true
	
func _on_attack_timer_timeout() -> void:
	player.last_attack = AttackData.AttackType.NULL
	player.attack_on_time = false
	$attackModeTimer.start()
	animations.attack_idle()

func _on_attack_mode_timer_timeout() -> void:
	player.attack_mode = false
	$SPTimer.start()
	animations.idle()

func _on_sp_timer_timeout() -> void:
	if GLOBAL.stamina < GLOBAL.max_stamina:
		GLOBAL.stamina += GLOBAL.max_stamina/100
	else:
		$SPTimer.stop()
