extends Node
class_name StatsSystem
# === STATS BASE ===
enum PrimaryStats {
	STRENGTH,       # Fuerza (Daño físico/HP)							peso equipamiento
	DEXTERITY,      # Destreza (Precisión/Velocidad ataque)				dano critico
	INTELLIGENCE,   # Inteligencia (Daño mágico/MP)						resistencia a hechizos
	ENDURANCE,      # Resistencia (Defensa física/Stamina)				reduccion dano fisico
	WILLPOWER,      # Voluntad (Defensa mágica/Resistencia a efectos)	duracion efectos negativos
	AGILITY         # Agilidad (Evasión/Velocidad movimiento)			tasa de golpes consecutivos
}

# Diccionario de stats base (puntos asignables)
var base_stats := {
	PrimaryStats.STRENGTH: 4 + GLOBAL.level,
	PrimaryStats.DEXTERITY: 4 + GLOBAL.level,
	PrimaryStats.INTELLIGENCE: 4 + GLOBAL.level,
	PrimaryStats.ENDURANCE: 4 + GLOBAL.level,
	PrimaryStats.WILLPOWER: 4 + GLOBAL.level,
	PrimaryStats.AGILITY: 4 + GLOBAL.level
}

# === STATS DERIVADOS ===
var derived_stats := {
	"physical_damage": {"min": 10, "max": 15},
	"magic_damage": {"min": 5, "max": 10},
	"physical_defense": 5,
	"magic_defense": 5,
	"attack_speed": 1.0,
	"movement_speed": 300,
	"max_hp": 100,
	"max_mp": 50.0,
	"max_sp": 100,
	"critical_chance": 0.4,
	"dodge_chance": 0.1
}

# === INICIALIZACIÓN ===
func _ready():
	update_derived_stats()

# === CÁLCULOS AUTOMÁTICOS ===
func update_derived_stats():
	# FÍSICO
	derived_stats.physical_damage.min = base_stats[PrimaryStats.STRENGTH] * 2
	derived_stats.physical_damage.max = base_stats[PrimaryStats.STRENGTH] * 3
	derived_stats.max_hp = 80 + (base_stats[PrimaryStats.STRENGTH] * 10)
	
	# MAGIA
	derived_stats.magic_damage.min = base_stats[PrimaryStats.INTELLIGENCE] * 1.5
	derived_stats.magic_damage.max = base_stats[PrimaryStats.INTELLIGENCE] * 2
	derived_stats.max_mp = 30 + (base_stats[PrimaryStats.INTELLIGENCE] * 5)
	
	# DEFENSAS
	derived_stats.physical_defense = base_stats[PrimaryStats.ENDURANCE] * 2
	derived_stats.magic_defense = base_stats[PrimaryStats.WILLPOWER] * 2
	
	# MOVIMIENTO/ATAQUE
	derived_stats.attack_speed = 1.0 + (base_stats[PrimaryStats.DEXTERITY] * 0.03)
	derived_stats.movement_speed = 300 + (base_stats[PrimaryStats.AGILITY] * 10)
	derived_stats.dodge_chance = min(0.3, base_stats[PrimaryStats.AGILITY] * 0.02)
	
	# STAMINA
	derived_stats.max_sp = 80 + (base_stats[PrimaryStats.ENDURANCE] * 4)

# === MÉTODOS DE ACCESO ===
func get_stat_display_name(stat: PrimaryStats) -> String:
	var names = {
		PrimaryStats.STRENGTH: "Fuerza",
		PrimaryStats.DEXTERITY: "Destreza",
		PrimaryStats.INTELLIGENCE: "Inteligencia",
		PrimaryStats.ENDURANCE: "Resistencia",
		PrimaryStats.WILLPOWER: "Voluntad",
		PrimaryStats.AGILITY: "Agilidad"
	}
	return names.get(stat, "Desconocido")

func get_random_physical_damage() -> float:
	return randf_range(derived_stats.physical_damage.min, derived_stats.physical_damage.max)

# === NIVEL UP ===
func level_up(stat: PrimaryStats):
	base_stats[stat] += 1
	update_derived_stats()
	emit_signal("stats_updated")  # Conectar a la UI
