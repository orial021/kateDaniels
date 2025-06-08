extends CharacterBody3D
class_name Player
@onready var debug_panel: PanelContainer = $debugPanel
@onready var animations: AnimationTree = $AnimationTree

#region vars
@onready var gui: CanvasLayer
@onready var HEAD: Node3D = $Head
@export var is_dead : bool = false
@export var lives : int = 5
@export var is_vulnerable : bool = true
@export var jumping : bool = false
var can_move : bool = true
var is_unsheathed : bool = false
var attack_mode : bool = true
var attack_on_time : bool = false

var mouse_sensitivity : float = 0.05
var speed = 300
var last_attack : AttackData.AttackType = AttackData.AttackType.NULL
var target : Enemy

const JUMP_FORCE = 7

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
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and event.is_action_pressed("ui_shot"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_jump"):
		jump_ctrl(1.0)
		
	if event.is_action_pressed("ui_change_weapon"):
		if is_unsheathed:
			is_unsheathed = false
			speed = 120
		else:
			is_unsheathed = true
			speed = 300
	if event.is_action_pressed("ui_shot") and is_unsheathed:
		if is_on_floor():
			if last_attack == AttackData.AttackType.NULL:
				attack_ctrl(AttackData.AttackType.FIRST_ATTACK)
			elif last_attack == AttackData.AttackType.FIRST_ATTACK and attack_on_time:
				attack_ctrl(AttackData.AttackType.SECOND_ATTACK)
			elif last_attack == AttackData.AttackType.SECOND_ATTACK and attack_on_time:
				attack_ctrl(AttackData.AttackType.THIRD_ATTACK)
		else:
			attack_ctrl(AttackData.AttackType.AIR_ATTACK)
				
func attack_ctrl(attack_type: AttackData.AttackType) -> void:
	last_attack = attack_type
	debug_panel.write(attack_on_time)
	attack_on_time = true
	attack_mode = true
	$Settings/attackTimer.start()
	$Settings/canAttackTimer.start() # realmente no esta implementado, implementar para disminuir el punto donde se puede hacer click
	
	match attack_type:
		AttackData.AttackType.FIRST_ATTACK:
			print("primer ataque")
			animations.first_attack()
			await get_tree().create_timer(0.5).timeout
			execute_damage(10)
		AttackData.AttackType.SECOND_ATTACK:
			print("segundo ataque")
			animations.second_attack()
			await get_tree().create_timer(0.5).timeout
			execute_damage(15)
		AttackData.AttackType.THIRD_ATTACK:
			print("tercer ataque")
			animations.third_attack()
		AttackData.AttackType.AIR_ATTACK:
			print("ataque aereo")
			await get_tree().create_timer(0.5).timeout
			execute_damage(20)
			animations.air_attack()
	

func execute_damage(damage: int) -> void:
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
