class_name AttackData extends Resource

enum AttackType {
	NULL,
	FIRST_ATTACK,
	SECOND_ATTACK,
	THIRD_ATTACK,
	AIR_ATTACK,
	PUNCH_UP
}

# Configuración base de ataques
@export var attacks_config: Dictionary = {
	AttackType.FIRST_ATTACK: {
		"base_damage_percent": 0.8,  # % del rango físico
		"cost": 10,
		"animation": "first_attack",
		"can_crit": true,
		"effect": "stun_chance",
		"value_effect": 0.1,
		"nature": GLOBAL.TYPE.PHYSICAL
	},
	AttackType.SECOND_ATTACK: {
		"base_damage_percent": 1.2,
		"cost": 15,
		"animation": "second_attack",
		"can_crit": true,
		"effect": "critical_upper",
		"value_effect": 2,
		"nature": GLOBAL.TYPE.PHYSICAL
	},
	AttackType.THIRD_ATTACK: {
		"base_damage_percent": 1.5,
		"cost": 20,
		"animation": "third_attack",
		"can_crit": true,
		"effect": "armor_piercing",
		"value_effect": 0.3,# Ignora 30% de defensa
		"nature": GLOBAL.TYPE.PHYSICAL
	},
	AttackType.AIR_ATTACK: {
		"base_damage_percent": 1.0,
		"cost": 12,
		"animation": "air_attack",
		"can_crit": false,
		"effect": "aoe_radius",
		"value_effect": 1.5, # Daño en área
		"nature": GLOBAL.TYPE.MAGICAL
	},
	AttackType.PUNCH_UP:{
		"base_damage_percent": 0.5,
		"cost": 12,
		"animation": "punch_up",
		"can_crit": false,
		"effect": "launch",
		"value_effect": 0.4,  
		"nature": GLOBAL.TYPE.PHYSICAL
	}
}
	
func get_damage(attack_type: AttackType) -> Dictionary:
	var damage = STATS.get_random_physical_damage()
	var skill = attacks_config.get(attack_type, {})
	damage *= skill.base_damage_percent
	var attack_nature = skill.nature
	var is_crit = false
	if skill.get("can_crit", false) and randf() <= STATS.derived_stats.critical_chance:
		damage *= 1.5 # 50% extra de dano
		is_crit = true
	var effect = skill.effect
	var value_effect = skill.value_effect
	if GLOBAL.current_wave == GLOBAL.WaveType.MAGIC:
		match attack_nature:
			GLOBAL.TYPE.PHYSICAL:
				damage *= 1.5
			GLOBAL.TYPE.MAGICAL:
				damage *= 0.8
			
	if GLOBAL.current_wave == GLOBAL.WaveType.TECH:
		match attack_nature:
			GLOBAL.TYPE.PHYSICAL:
				damage *= 0.8
			GLOBAL.TYPE.MAGICAL:
				damage *= 1.5
			
	var damage_info = {
		"damage": damage,
		"attack_nature": attack_nature,
		"is_critical": is_crit,
		"effect": effect,
		"value_effect": value_effect
}
	return damage_info

func get_animation(attack_type: AttackType) -> String:
	return attacks_config.get(attack_type, {}).get("animation", "")

func get_cost(attack_type: AttackType) -> bool:
	var skill = attacks_config.get(attack_type, {})
	var nature = skill.nature
	if nature == GLOBAL.TYPE.MAGICAL and GLOBAL.mana >= skill.cost:
		GLOBAL.mana -= skill.cost
		return true
	if nature == GLOBAL.TYPE.PHYSICAL and GLOBAL.stamina >= skill.cost:
		GLOBAL.stamina -= skill.cost
		return true
	return false

func get_type(attack_type: AttackType) -> bool:
	return attacks_config.get(attack_type, {}).get("physical", false)
	
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
