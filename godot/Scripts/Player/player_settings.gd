extends Node

@onready var player : Player = get_parent()
@onready var animations: AnimationTree = $"../AnimationTree"
var gui : CanvasLayer
var attack_time : bool = true
var stamina_regen_multipliers := [
	1,
	2
]
var mana_regen_multipliers := [
	2,
	1
]

func _ready() -> void:
	gui = player.gui

func use_attack_time(time: float, use : bool = true) -> void:
	attack_time = use
	$canAttackTimer.start(time)
	
func _on_can_attack_timer_timeout() -> void: # activa el ralentizado y permite volver a atacar
	if attack_time:
		gui.attackTime()
	player.can_attack = true
	attack_time = true
	
func _on_end_attack_timer_timeout() -> void: # fin de los combos
	player.last_attack = AttackData.AttackType.NULL
	player.attack_on_time = false
	$attackModeTimer.start()
	animations.attack_idle()

func _on_attack_mode_timer_timeout() -> void: # fin del modo de ataque
	player.attack_mode = false
	$SPTimer.start()
	animations.idle()

func _on_sp_timer_timeout() -> void:
	if not player.attack_mode:
		if GLOBAL.stamina < STATS.derived_stats.max_sp:
			GLOBAL.stamina += STATS.derived_stats.max_sp/100 * stamina_regen_multipliers[GLOBAL.current_wave]
		if GLOBAL.mana < STATS.derived_stats.max_mp:
			GLOBAL.mana += (STATS.derived_stats.max_mp * mana_regen_multipliers[GLOBAL.current_wave])/50
	else:
		$SPTimer.stop()
