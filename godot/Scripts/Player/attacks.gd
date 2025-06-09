class_name AttackData extends Resource

enum AttackType {
	NULL,
	FIRST_ATTACK,
	SECOND_ATTACK,
	THIRD_ATTACK,
	AIR_ATTACK
}

# Configuración base de ataques
@export var attacks_config: Dictionary = {
	AttackType.FIRST_ATTACK: {
		"base_damage_percent": 0.8,  # % del rango físico
		"sp_cost": 10,
		"animation": "first_attack",
		"can_crit": true,
		"stun_chance": 0.1
	},
	AttackType.SECOND_ATTACK: {
		"base_damage_percent": 1.2,
		"sp_cost": 15,
		"animation": "second_attack",
		"can_crit": true,
		"combo_required": AttackType.FIRST_ATTACK
	},
	AttackType.THIRD_ATTACK: {
		"base_damage_percent": 1.5,
		"sp_cost": 20,
		"animation": "third_attack",
		"can_crit": true,
		"armor_piercing": 0.3  # Ignora 30% de defensa
	},
	AttackType.AIR_ATTACK: {
		"base_damage_percent": 1.0,
		"sp_cost": 12,
		"animation": "air_attack",
		"can_crit": false,
		"aoe_radius": 1.5  # Daño en área
	}
}
	
func get_damage(attack_type: AttackType) -> int:
	var damage = STATS.get_random_physical_damage()
	var skill = attacks_config.get(attack_type, {})
	damage *= skill.get("base_damage_percent", 1.0)
	
	var is_crit := false
	if skill.get("can_crit", false) and randf() <= STATS.derived_stats.critical_chance:
		damage *= 1.5 # 50% extra de dano
		is_crit = true
	
	var sp_cost = skill.get("sp_cost", 0)
	return damage

func get_animation(attack_type: AttackType) -> String:
	return attacks_config.get(attack_type, {}).get("animation", "")

func get_cost(attack_type: AttackType) -> int:
	return attacks_config.get(attack_type, {}).get("sp_cost", 0)

#region TODO
var effects = {
	"bleed_chance": 0.2,
	"bleed_damage": 3,
	"bleed_duration": 5
}
#if WorldManager.current_wave == MAGIC:
	#damage *= 1.2  # Bonus en oleada mágica
var combo_multiplier = {
	"sequence": "[FIRST_ATTACK, SECOND_ATTACK, THIRD_ATTACK]",
	"bonus": 1.5
}
#endregion
