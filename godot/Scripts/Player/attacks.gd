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
		"sp_cost": 10,
		"animation": "first_attack",
		"can_crit": true,
		"effect": "stun_chance",
		"value_effect": 0.1,
		"physical": true
	},
	AttackType.SECOND_ATTACK: {
		"base_damage_percent": 1.2,
		"sp_cost": 15,
		"animation": "second_attack",
		"can_crit": true,
		"effect": "critical_upper",
		"value_effect": 2,
		"physical": true
	},
	AttackType.THIRD_ATTACK: {
		"base_damage_percent": 1.5,
		"sp_cost": 20,
		"animation": "third_attack",
		"can_crit": true,
		"effect": "armor_piercing",
		"value_effect": 0.3,# Ignora 30% de defensa
		"physical": true
	},
	AttackType.AIR_ATTACK: {
		"base_damage_percent": 1.0,
		"sp_cost": 12,
		"animation": "air_attack",
		"can_crit": false,
		"effect": "aoe_radius",
		"value_effect": 1.5, # Daño en área
		"physical": false
	},
	AttackType.PUNCH_UP:{
		"base_damage_percent": 0.5,
		"sp_cost": 12,
		"animation": "punch_up",
		"can_crit": false,
		"effect": "launch",
		"value_effect": 0.4,  
		"physical": true
	}
}
	
func get_damage(attack_type: AttackType) -> Dictionary:
	var damage = STATS.get_random_physical_damage()
	var skill = attacks_config.get(attack_type, {})
	damage *= skill.base_damage_percent
	var is_physical = skill.physical
	var is_crit = false
	if skill.get("can_crit", false) and randf() <= STATS.derived_stats.critical_chance:
		damage *= 1.5 # 50% extra de dano
		is_crit = true
	var effect = skill.effect
	var value_effect = skill.value_effect
	if GLOBAL.current_wave == GLOBAL.WaveType.MAGIC:
		if not is_physical: #potenciado por la magia
			damage *= 1.5
		else:
			damage *= 0.8
			
	if GLOBAL.current_wave == GLOBAL.WaveType.TECH:
		if is_physical: # potenciado por la tecnologia
			damage *= 1.5
		else:
			damage *= 0.8
			
	var damage_info = {
		"damage": damage,
		"is_physical": is_physical,
		"is_critical": is_crit,
		"effect": effect,
		"value_effect": value_effect
}
	return damage_info

func get_animation(attack_type: AttackType) -> String:
	return attacks_config.get(attack_type, {}).get("animation", "")

func get_cost(attack_type: AttackType) -> bool:
	var skill = attacks_config.get(attack_type, {})
	var is_physical = skill.physical
	if not is_physical and GLOBAL.mana >= skill.sp_cost:
		GLOBAL.mana -= skill.sp_cost
		return true
	if is_physical and GLOBAL.stamina >= skill.sp_cost:
		GLOBAL.stamina -= skill.sp_cost
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
