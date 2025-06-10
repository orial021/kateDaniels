extends CanvasLayer

@export var player : Player
@onready var attack_time: TextureRect = $Control/attackTime
var current_wave : Array = [
	"MAGIC",
	"TECH"
]

func _ready() -> void:
	update_stats()
	$Control/attackTime.visible = false
	
func _process(_delta: float) -> void:
	%HPBar.max_value = STATS.derived_stats["max_hp"]
	%HPBar.value = GLOBAL.health
	%HPLabel.text = str(GLOBAL.health) + "/" + str(STATS.derived_stats["max_hp"])
	%SPBar.max_value = STATS.derived_stats["max_sp"]
	%SPBar.value = GLOBAL.stamina
	%SPLabel.text = str(GLOBAL.stamina) + "/" + str(STATS.derived_stats["max_sp"])
	%Wave.text = "WAVE:   " + current_wave[GLOBAL.current_wave]
	%MPBar.max_value = STATS.derived_stats["max_mp"]
	%MPBar.value = GLOBAL.mana
	%MPLabel.text = str(GLOBAL.mana) + "/" + str(STATS.derived_stats["max_mp"])

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_stats"):
		if $Control/stats.visible:
			$Control/stats.hide()
		else:
			$Control/stats.show()
		
func attackTime() -> void:
	if player.target != null:
		$Control/attackTime.visible = true
		Engine.set_time_scale(0.3)
		await get_tree().create_timer(0.4).timeout
		Engine.set_time_scale(1.0)
		$Control/attackTime.visible = false

func update_stats() -> void:
	# Daño
	%phyDamage.text = "⚔️ Daño físico: " + format_range(STATS.derived_stats["physical_damage"])
	%magDamage.text = "🔮 Daño mágico: " + format_range(STATS.derived_stats["magic_damage"])
	
	# Defensas
	%phyDefense.text = "🛡️ Def. física: " + str(STATS.derived_stats["physical_defense"])
	%magDefense.text = "✨ Def. mágica: " + str(STATS.derived_stats["magic_defense"])
	
	# Velocidades
	%attackSpeed.text = "⏱️ Vel. ataque: " + "%.1f" % STATS.derived_stats["attack_speed"] + "x"
	%movSpeed.text = "👟 Vel. movimiento: " + str(int(STATS.derived_stats["movement_speed"]))
	
	# Recursos
	%HP.text = "❤️ Salud: " + str(STATS.derived_stats["max_hp"])
	%MP.text = "🔵 Maná: " + str(STATS.derived_stats["max_mp"])
	%SP.text = "⚡ Stamina: " + str(STATS.derived_stats["max_sp"])
	
	# Probabilidades
	%criticalChance.text = "💥 Crítico: " + "%.1f" % (STATS.derived_stats["critical_chance"] * 100) + "%"
	%dodgeChance.text = "🌪️ Evasión: " + "%.1f" % (STATS.derived_stats["dodge_chance"] * 100) + "%"

func format_range(stat_range: Dictionary) -> String:
	return "%d-%d" % [stat_range.min, stat_range.max]
	
func _on_stats_pressed() -> void:
	if $Control/stats.visible:
		$Control/stats.hide()
	else:
		$Control/stats.show()
