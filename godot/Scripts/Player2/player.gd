extends CharacterBody3D
class_name Player

@export_category("Combat Settings")
@export var stats : StatsSystem = StatsSystem.new()
@export var mov_speed : float = STATS.derived_stats["movement_speed"]
@export var mouse_sensitivity := 0.05
@export var jump_force := 7.0
#@export var attack_cooldown := 0.2 # TODO
@export_category("references")
@export var gui: CanvasLayer
const JUMP_FORCE = 7

#region vars
'''NODOS'''
var attack_data : AttackBData = AttackBData.new()
#@onready var debug_panel: PanelContainer = $debugPanel
@onready var animations: AnimationTree = $AnimationTree
@onready var HEAD: Node3D = $head

'''ESTADOS'''
var is_dead : bool = false
var is_vulnerable : bool = true
var jumping : bool = false
var can_move : bool = true
var is_unsheathed : bool = false

'''ATAQUE'''
var can_attack := true
var attack_mode : bool = true
var attack_on_time : bool = false
var last_attack : AttackBData.AttackType = AttackBData.AttackType.NULL
var target : Enemy

func _ready() -> void:
	$AnimationTree.active = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	HEAD.set_rotation_degrees(Vector3.ZERO)
	GLOBAL.health = STATS.derived_stats["max_hp"]
	GLOBAL.stamina = STATS.derived_stats["max_sp"]
	GLOBAL.mana = STATS.derived_stats["max_mp"]

func _physics_process(delta: float) -> void:
	#debug_panel.write(velocity.y)
	velocity.y -= get_physics_process_delta_time() * GLOBAL.gravity
	if can_move:
		HEAD.rotation.x = clamp(HEAD.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		if not is_dead:
			motion_ctrl(delta)
			anim_ctrl()
			if jumping:
				jumping = false
				velocity.y = JUMP_FORCE
	move_and_slide()
		
func _input(event: InputEvent) -> void:
	handle_high_cognition(event)
	handle_pause(event)
	handle_weapon_togle(event)
	handle_attack_input(event)
	if event.is_action_pressed("ui_jump"):
		jump_ctrl()
				
func handle_high_cognition(event:InputEvent) -> void:
	if event.is_action_pressed("ui_cogn"):
		GLOBAL.high_cognition = !GLOBAL.high_cognition
		
func handle_pause(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and event.is_action_pressed("ui_shot"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func handle_weapon_togle(event: InputEvent) -> void:
	if event.is_action_pressed("ui_change_weapon"):
		if is_unsheathed:
			is_unsheathed = false
			mov_speed = 120
		else:
			is_unsheathed = true
			mov_speed = 300
			
func handle_attack_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_shot") and is_unsheathed and can_attack:
		$Settings/attackModeTimer.stop()
		var next_attack = get_next_attack_type()
		if next_attack != AttackBData.AttackType.NULL:
			execute_attack(next_attack)
			
	if event.is_action_pressed("ui_punch") and can_attack and is_on_floor():
		$Settings/attackModeTimer.stop()
		execute_attack(AttackBData.AttackType.ATTACK_ROUND)
		
func get_next_attack_type() -> AttackBData.AttackType:
	if not is_on_floor():
		return AttackBData.AttackType.ATTACK_DASH
		
	match last_attack:
		AttackBData.AttackType.NULL:
			return AttackBData.AttackType.ATTACK_REVERSE
		AttackBData.AttackType.ATTACK_REVERSE:
			return AttackBData.AttackType.ATTACK_ROUND_KICK
		AttackBData.AttackType.ATTACK_ROUND_KICK:
			return AttackBData.AttackType.ATTACK_SLASH
		AttackBData.AttackType.ATTACK_SLASH:
			return AttackBData.AttackType.ATTACK_REVERSE
		_:
			return AttackBData.AttackType.ATTACK_REVERSE
			
func execute_attack(attack_type: AttackBData.AttackType) -> void:
	if attack_data.get_cost(attack_type):
		last_attack = attack_type
		attack_on_time = true
		attack_mode = true
		can_attack = false
		
		match attack_type:
			
			AttackBData.AttackType.ATTACK_REVERSE:
				$Settings.use_attack_time(1.6, true) # tiempo para poder volver a atacar, antes de este tiempo el click no vale
				$Settings/endAttackTimer.start(1.8) # tiempo limite para volver a atacar
				animations.attacks(AttackBData.AttackType.ATTACK_REVERSE) # genera la animacion del ataque
				await get_tree().create_timer(0.8).timeout #espera un tiempo hardcodeado para afectar al enemigo
				apply_damage(AttackBData.AttackType.ATTACK_REVERSE) # aplica el dano al enemigo en el momento exacto del contacto
			AttackBData.AttackType.ATTACK_ROUND_KICK:
				$Settings.use_attack_time(1.1, true)
				$Settings/endAttackTimer.start(1.3)
				animations.attacks(AttackBData.AttackType.ATTACK_ROUND_KICK)
				await get_tree().create_timer(0.4).timeout
				apply_damage(AttackBData.AttackType.ATTACK_ROUND_KICK)
			AttackBData.AttackType.ATTACK_SLASH:
				$Settings.use_attack_time(1.6, true)
				$Settings/endAttackTimer.start(1.8)
				animations.attacks(AttackBData.AttackType.ATTACK_SLASH)
				await get_tree().create_timer(0.38).timeout
				apply_damage(AttackBData.AttackType.ATTACK_SLASH)
			AttackBData.AttackType.ATTACK_DASH:
				$Settings.use_attack_time(1.0, true)
				$Settings/endAttackTimer.start(1.2)
				animations.attacks(AttackBData.AttackType.ATTACK_DASH)
				await get_tree().create_timer(0.48).timeout
				apply_damage(AttackBData.AttackType.ATTACK_DASH)
			AttackBData.AttackType.ATTACK_ROUND:
				$Settings.use_attack_time(1.2, true)
				$Settings/endAttackTimer.start(1.6)
				animations.attacks(AttackBData.AttackType.ATTACK_ROUND)
				await get_tree().create_timer(0.6).timeout
				apply_damage(AttackBData.AttackType.ATTACK_ROUND)
				
	
func apply_damage(attack_type : AttackBData.AttackType) -> void:
	if target and !target.is_dead:
		var kill = target.damage_ctrl(attack_data.get_damage(attack_type))
		if kill:
			get_a_kill()
			
func get_a_kill() -> void:
	await get_tree().create_timer(3.0).timeout
	GLOBAL.current_experience += 8
	if GLOBAL.current_experience >= GLOBAL.next_level_experience:
		level_up()
		
func level_up():
	$GPUParticles3D.emitting = true
	GLOBAL.current_experience -= GLOBAL.next_level_experience
	GLOBAL.level += 1
	GLOBAL.next_level_experience = int(GLOBAL.next_level_experience * 1.5)
	STATS.update_base_stats()
	gui.update_stats()
	GLOBAL.health = STATS.derived_stats["max_hp"]
	GLOBAL.stamina = STATS.derived_stats["max_sp"]
	GLOBAL.mana = STATS.derived_stats["max_mp"]
	gui.level_up()
	
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		HEAD.rotation_degrees.x -= event.relative.y * -mouse_sensitivity
		rotation_degrees.y -= event.relative.x * mouse_sensitivity

func motion_ctrl(delta) -> void:
	var direction = GLOBAL.get_axis().rotated(rotation.y)
	direction = Vector3(direction.x, 0, direction.y)
	
	if is_on_floor():
		
		velocity.x = direction.x * -mov_speed * delta
		velocity.z = direction.z * mov_speed * delta
		
func anim_ctrl() ->void:
	pass
	#$"Rig/Skeleton3D/2H_Sword/2H_Sword".visible = is_unsheathed
	#$"Rig/Skeleton3D/Back/2H_Sword".visible = !is_unsheathed
			
func jump_ctrl() -> void:
	animations.jump_start()

func _on_attack_area_body_entered(body: Node3D) -> void:
	if body is Enemy:
		target = body
		
func _on_attack_area_body_exited(body: Node3D) -> void:
	if body is Enemy:
		target = null
