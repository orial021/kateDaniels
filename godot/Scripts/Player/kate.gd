extends CharacterBody3D
class_name Player

@export_category("Combat Settings")
@export var speed := 300.0
@export var sheathed_speed := 120.0
@export var mouse_sensitivity := 0.05
@export var jump_force := 7.0
@export var attack_cooldown := 0.2
@export_category("references")
@export var gui: CanvasLayer
const JUMP_FORCE = 7

#region vars
'''NODOS'''
var attack_data : AttackData = AttackData.new()
@onready var debug_panel: PanelContainer = $debugPanel
@onready var animations: AnimationTree = $AnimationTree
@onready var HEAD: Node3D = $Head

'''ESTADOS'''
var is_dead : bool = false
var lives : int = 5
var is_vulnerable : bool = true
var jumping : bool = false
var can_move : bool = true
var is_unsheathed : bool = false

'''ATAQUE'''
var can_attack := true
var attack_mode : bool = true
var attack_on_time : bool = false
var last_attack : AttackData.AttackType = AttackData.AttackType.NULL
var target : Enemy


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	HEAD.set_rotation_degrees(Vector3.ZERO)

func _physics_process(delta: float) -> void:
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
	handle_pause(event)
	handle_weapon_togle(event)
	handle_attack_input(event)
	if event.is_action_pressed("ui_jump"):
		jump_ctrl(1.0)
				
func handle_pause(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and event.is_action_pressed("ui_shot"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func handle_weapon_togle(event: InputEvent) -> void:
	if event.is_action_pressed("ui_change_weapon"):
		if is_unsheathed:
			is_unsheathed = false
			speed = 120
		else:
			is_unsheathed = true
			speed = 300
			
func handle_attack_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_shot") and is_unsheathed and can_attack:
		var next_attack = get_next_attack_type()
		if next_attack != AttackData.AttackType.NULL:
			execute_attack(next_attack)
	
func get_next_attack_type() -> AttackData.AttackType:
	if not is_on_floor():
		return AttackData.AttackType.AIR_ATTACK
		
	match last_attack:
		AttackData.AttackType.NULL:
			return AttackData.AttackType.FIRST_ATTACK
		AttackData.AttackType.FIRST_ATTACK:
			return AttackData.AttackType.SECOND_ATTACK
		AttackData.AttackType.SECOND_ATTACK:
			return AttackData.AttackType.THIRD_ATTACK
		AttackData.AttackType.THIRD_ATTACK:
			return AttackData.AttackType.FIRST_ATTACK
		_:
			return AttackData.AttackType.NULL
			
func execute_attack(attack_type: AttackData.AttackType) -> void:
	last_attack = attack_type
	attack_on_time = true
	attack_mode = true
	can_attack = false
	
	match attack_type:
		AttackData.AttackType.FIRST_ATTACK:
			$Settings/canAttackTimer.start(1.4)
			$Settings/attackTimer.start(1.8)
			animations.first_attack()
			await get_tree().create_timer(0.8).timeout
			apply_damage(attack_data.get_damage(attack_type))
		AttackData.AttackType.SECOND_ATTACK:
			$Settings/canAttackTimer.start(0.9)
			$Settings/attackTimer.start(1.3)
			animations.second_attack()
			await get_tree().create_timer(0.4).timeout
			apply_damage(attack_data.get_damage(attack_type))
		AttackData.AttackType.THIRD_ATTACK:
			$Settings/canAttackTimer.start(1.4)
			$Settings/attackTimer.start(1.8)
			animations.third_attack()
			await get_tree().create_timer(0.38).timeout
			apply_damage(attack_data.get_damage(attack_type))
		AttackData.AttackType.AIR_ATTACK:
			await get_tree().create_timer(0.38).timeout
			apply_damage(attack_data.get_damage(attack_type))
			animations.air_attack()
	
func apply_damage(damage: int) -> void:
	if target and !target.is_dead:
		target.damage_ctrl(damage)
		
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		HEAD.rotation_degrees.x -= event.relative.y * -mouse_sensitivity
		rotation_degrees.y -= event.relative.x * mouse_sensitivity

func motion_ctrl(delta) -> void:
	var direction = GLOBAL.get_axis().rotated(rotation.y)
	direction = Vector3(direction.x, 0, direction.y)
	
	if is_on_floor():
		
		velocity.x = direction.x * -speed * delta
		velocity.z = direction.z * speed * delta
		
func anim_ctrl() ->void:
	$"Rig/Skeleton3D/2H_Sword/2H_Sword".visible = is_unsheathed
	$"Rig/Skeleton3D/Back/2H_Sword".visible = !is_unsheathed
			
func jump_ctrl(power : float) -> void:
	animations.jump_start()

func _on_attack_area_body_entered(body: Node3D) -> void:
	if body is Enemy:
		target = body
		
func _on_attack_area_body_exited(body: Node3D) -> void:
	if body is Enemy:
		target = null
