class_name EnemyStats extends Resource

@export_category("Core Stats")
@export var max_health: int = 30
@export var move_speed: int = 200
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
func calculate_damage(incoming_damage: float, is_physical: bool, is_critical: bool) -> float:
	var defense = physical_defense if is_physical else magic_defense
	var base_reduction = defense * 0.1  # Cada punto de defensa reduce 10% del daño
	
	# Probabilidades de defensa
	if randf() <= dodge_chance:
		return 0.0  # ¡Esquivado!
	
	if randf() <= block_chance:
		base_reduction += 0.5  # Bloqueo reduce 50% adicional
	
	# Reducción de crítico
	var critical_multiplier = 1.5
	if is_critical:
		critical_multiplier = lerp(1.5, 1.0, critical_resistance)
	
	# Cálculo final
	var damage = incoming_damage * critical_multiplier
	damage *= max(0.1, 1.0 - base_reduction)  # Mínimo 10% de daño
	
	return damage
