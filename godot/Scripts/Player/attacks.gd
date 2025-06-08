class_name AttackData extends Resource

enum AttackType {
	NULL,
	FIRST_ATTACK,
	SECOND_ATTACK,
	THIRD_ATTACK,
	AIR_ATTACK
}

@export var damage_by_type: Dictionary = {
	AttackType.NULL: 0,
	AttackType.FIRST_ATTACK: 10,
	AttackType.SECOND_ATTACK: 15,
	AttackType.THIRD_ATTACK: 20,
	AttackType.AIR_ATTACK: 12
}

@export var animation_by_type: Dictionary = {
	AttackType.NULL: "",
	AttackType.FIRST_ATTACK: "first_attack",
	AttackType.SECOND_ATTACK: "second_attack",
	AttackType.THIRD_ATTACK: "third_attack",
	AttackType.AIR_ATTACK: "air_attack"
}

func get_damage(attack_type: AttackType) -> int:
	return damage_by_type.get(attack_type, 0)

func get_animation(attack_type: AttackType) -> String:
	return animation_by_type.get(attack_type, "")
