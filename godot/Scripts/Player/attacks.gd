class_name AttackData extends Resource

@export var name: Dictionary = {
	FIRST_ATTACK = "first_attack",
	SECOND_ATTACK = "second_attack",
	THIRD_ATTACK = "third_attack",
	AIR_ATTACK = "air_attack"
}
@export var damage: int
@export var animation: String

var current_attack: AttackData
