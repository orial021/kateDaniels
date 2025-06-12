extends CharacterBody3D
class_name Enemy

# --- VARIABLES ---
@export var stats: EnemyStats = EnemyStats.new()
@export var player: Player
@export var move_speed : int
@export var rotation_speed := 10.0
@export var current_state : int = STATES.WAITING
@export var previous_state : int = STATES.WAITING
enum STATES {
	WAITING,
	IDLE,
	CHASING,
	COMBATING,
	ATTACKING,
	LAUNCHED,
	HURT,
	LIED,
	DEAD
}

var gravity = GLOBAL.gravity
var health : int
var player_detected : bool = false
var can_move := false
var is_dead := false
var is_launched := false
var received_effect := []
var animation_current : String

func _ready() -> void:
	if stats:
		$SubViewport/ProgressBar.max_value = stats.max_health
		health = stats.max_health
		move_speed = stats.move_speed
	
func _process(_delta: float) -> void:
	update_health_display()
	
func _physics_process(delta):
	animation_current = $AnimationPlayer.current_animation
	velocity.y -= get_physics_process_delta_time() * GLOBAL.gravity
	if is_on_floor():
		
		if current_state == STATES.CHASING:
			handle_movement(delta)
	move_and_slide()
	
func _set_state(new_state: int) -> void:
	if new_state == current_state:
		return
	if current_state == STATES.DEAD:
		return
		
	# lógica de salida del estado actual
	match current_state:
		STATES.WAITING:
			$AnimationPlayer.play("Skeletons_Awaken_Floor")
			player_detected = true
			
		STATES.CHASING:
			pass
			
		STATES.COMBATING:
			pass
			
		STATES.ATTACKING:
			pass
			
		STATES.LAUNCHED:
			is_launched = false
			
		STATES.HURT:
			can_move = true
			
		STATES.LIED:
			pass
			
	previous_state = current_state
	current_state = new_state

	match new_state:
		STATES.WAITING:
			$AnimationPlayer.play("Skeletons_Inactive_Floor_Pose")
			
		STATES.IDLE:
			pass
			
		STATES.CHASING:
			$AnimationPlayer.play("Walking_D_Skeletons")
			can_move = true
			
		STATES.COMBATING:
			velocity.x = 0
			velocity.z = 0
			can_move = false
			$AnimationPlayer.play("Idle_Combat")
			
		STATES.ATTACKING:
			$AnimationPlayer.play("Unarmed_Melee_Attack_Punch_A")
			
		STATES.LAUNCHED:
			is_launched = true
			$AnimationPlayer.play("Lie_Pose")
			
		STATES.HURT:
			can_move = false
			$AnimationPlayer.play("Hit_B")
			
		STATES.LIED:
			$AnimationPlayer.play("Lie_Pose")
			
		STATES.DEAD:
			$AnimationPlayer.play_backwards("Skeletons_Awaken_Floor")
			is_dead = true
			can_move = false
			velocity.y = 0
			$CollisionShape3D.set_deferred("disabled", true)
			set_physics_process(false)
			
func handle_movement(delta : float) -> void:
	var direction := (player.global_position - global_position).normalized()
	if player_detected:
		if velocity.length() > 0.1:
			rotate_towards_player(direction, delta)
		if current_state == STATES.CHASING:
			velocity = direction * move_speed * delta
			
func rotate_towards_player(direction: Vector3, delta: float) -> void:
	var target_angle = atan2(direction.x, direction.z)
	rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)
	
func update_health_display() -> void:
	$Label3D.text = "LIFE: " + str(health)
	$SubViewport/ProgressBar.value = health
	
func damage_ctrl(damage_info : Dictionary) -> void:
	if current_state == STATES.LAUNCHED:
		launched(0.6)
	var final_damage = stats.calculate_damage(damage_info.damage, damage_info.is_physical, damage_info.is_critical)
	received_effect = [
		damage_info.effect,
		damage_info.value_effect
	]
	
	_set_state(STATES.HURT)
	apply_effect(received_effect)
	
	health -= final_damage.damage
	display_damage(final_damage.damage, final_damage.critical, damage_info.is_physical, final_damage.dodged, final_damage.blocked)
	if health <= 0:
		_set_state(STATES.DEAD)
		
func apply_effect(effects : Array) -> void:
	match effects[0]:
		"launch":
			#if randf() <= effects[1]:
			if randf() <= 1: #TEST
				launched(1.0)

func display_damage(amount: float, is_critical: bool, is_physical: bool, dodged : bool, blocked : bool) -> void:
	var this_position = global_position + Vector3(0, 3.5, 0)
	$damageLabel.global_position = this_position
	if not is_physical:
		$damageLabel.modulate = Color.BLUE
	else:
		$damageLabel.modulate = Color.WHITE
	if dodged:
		$damageLabel.text = "ESQUIVADO"
	if is_critical:
		$damageLabel.modulate = Color.RED
	if blocked:
		$damageLabel.text = "BLOQUEADO\n" + str(int(amount))
	else:
		$damageLabel.text = str(int(amount))
	$damageLabel.scale = Vector3(1.0, 1.0, 1) if is_critical else Vector3(0.5, 0.5, 1)
	$damageLabel.show()
	var new_scale = Vector3(1.5, 1.5, 1.0) if is_critical else Vector3(1.0, 1.0, 1)
	
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property($damageLabel, "global_position", Vector3(this_position.x, (this_position.y + 0.3), this_position.z), 0.7)
	tween.parallel().tween_property($damageLabel, "scale", new_scale, 0.7)
	tween.tween_property($damageLabel, "modulate", Color.TRANSPARENT, 0.3)
	tween.parallel().tween_property($damageLabel, "outline_modulate", Color.TRANSPARENT, 0.3)
	tween.tween_callback($damageLabel.hide)
	
func launched(power : float) -> void:
	_set_state(STATES.LAUNCHED)
	#$AnimationPlayer.play("Hit_B", -1, 0.1)
	velocity.y = 8 * power
	
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"Skeletons_Awaken_Floor":
			if not is_dead:
				_set_state(STATES.CHASING)
		"Hit_B":
			if not is_launched:
				_set_state(STATES.COMBATING)

func _on_area_detection_body_entered(body: Node3D) -> void:
	if body is Player and not is_dead:
		if not player_detected:
			_set_state(STATES.IDLE)
		else:
			_set_state(STATES.CHASING)
			
	
func _on_area_detection_body_exited(body: Node3D) -> void:
	if body is Player and not is_dead:
		_set_state(STATES.COMBATING)
		
func _on_area_target_body_entered(body: Node3D) -> void:
	if body is Player:
		_set_state(STATES.COMBATING)

func _on_area_target_body_exited(body: Node3D) -> void:
	if body is Player and is_on_floor():
		_set_state(STATES.CHASING)
