class_name EnemyStats extends Resource

@export_category("Core Stats")
@export var max_health: int = 30
@export var move_speed: int = 100
@export var rotation_speed: float = 10.0

@export_category("Defensive Stats")
@export var physical_defense: int = 5
@export var magic_defense: int = 3
@export_range(0.0, 1.0) var block_chance: float = 0.15
@export_range(0.0, 1.0) var dodge_chance: float = 0.1
@export_range(0.0, 1.0) var critical_resistance: float = 0.2

@export_category("Offensive Stats")
@export var physical_damage: int = 8
@export var magic_damage: int = 5
@export_range(0.0, 1.0) var critical_chance: float = 0.05
@export var attack_speed: float = 1.0

@export_category("Resistances")
@export_range(0.0, 1.0) var fire_resistance: float = 0.0
@export_range(0.0, 1.0) var ice_resistance: float = 0.0
@export_range(0.0, 1.0) var bleed_resistance: float = 0.0

# Método para calcular el daño recibido
func calculate_damage(incoming_damage: float, is_physical: bool, is_critical: bool) -> Dictionary:
	var defense = physical_defense if is_physical else magic_defense
	var base_reduction = defense * 0.1  # Cada punto de defensa reduce 10% del daño, considera el tipo de daño
	var damage : float = 0.0
	var dodged : bool = false
	var blocked : bool = false
	var critical : bool = is_critical
	# Probabilidades de defensa
	if randf() <= dodge_chance:
		dodged = true
		damage = 0.0  # ¡Esquivado!
	
	if randf() <= block_chance:
		blocked = true
		base_reduction += 0.5  # Bloqueo reduce 50% adicional
	if critical:
		if randf() <= critical_resistance:
			critical = false
	# Reducción de crítico
	var critical_multiplier = 1.5
	if is_critical:
		critical_multiplier = lerp(1.5, 1.0, critical_resistance)
	
	# Cálculo final
	damage = incoming_damage * critical_multiplier
	damage *= max(0.1, 1.0 - base_reduction)  # Mínimo 10% de daño
	var damage_info := {
		"damage": damage,
		"dodged": dodged,
		"blocked": blocked,
		"critical": is_critical
	}
	return damage_info
