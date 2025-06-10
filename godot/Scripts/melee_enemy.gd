extends CharacterBody3D
class_name Enemy

# --- VARIABLES ---
@export var stats: EnemyStats = EnemyStats.new()
@export var player: Player
@export var move_speed : int
@export var rotation_speed := 10.0

var health : int
var player_detected : bool = false
var can_move := false
var is_dead := false
var received_effect := []

func _ready() -> void:
	if stats:
		$SubViewport/ProgressBar.max_value = stats.max_health
		health = stats.max_health
		move_speed = stats.move_speed
	
func _process(_delta: float) -> void:
	update_health_display()
	
func _physics_process(delta):
	if is_dead:
		return
	if is_on_floor():
		handle_movement(delta)
	else:
		velocity.y -= GLOBAL.gravity/100
	move_and_slide()
	
func handle_movement(delta : float) -> void:
	if !player_detected or !can_move or !player:
		return
		
	else:
		var direction := (player.global_position - global_position).normalized()
		velocity = direction * move_speed * delta
	
		if velocity.length() > 0.1:
			rotate_towards_player(direction, delta)
		
func rotate_towards_player(direction: Vector3, delta: float) -> void:
	var target_angle = atan2(direction.x, direction.z)
	rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)
	
func update_health_display() -> void:
	$Label3D.text = "LIFE: " + str(health)
	$SubViewport/ProgressBar.value = health
	
func damage_ctrl(damage_info : Dictionary) -> void:
	if is_dead:
		return
	if not is_on_floor():
		velocity.y = 100
	var final_damage = stats.calculate_damage(
		damage_info["damage"],
		damage_info["is_physical"],
		damage_info["is_critical"],
		)
	received_effect = [
		damage_info.effect,
		damage_info.value_effect
	]
	apply_effect(received_effect)
	print("efectos: ", received_effect[0])
	health -= final_damage
	display_damage(final_damage, damage_info.is_critical)
	$AnimationPlayer.play("Hit_B")
	
	if health <= 0:
		die()
func apply_effect(effects : Array) -> void:
	match effects[0]:
		"launch":
			if randf() <= effects[1]:
				velocity.y = 150
	move_and_slide()
	
func die() -> void:
	is_dead = true
	can_move = false
	velocity.y = 0
	$AnimationPlayer.play_backwards("Skeletons_Awaken_Floor")
	$CollisionShape3D.set_deferred("disabled", true)

func display_damage(amount: float, is_critical: bool) -> void:
	var this_position = global_position + Vector3(0, 3.5, 0)
	$damageLabel.global_position = this_position
	$damageLabel.text = str(int(amount))
	$damageLabel.modulate = Color.RED if is_critical else Color.WHITE
	$damageLabel.scale = Vector3(1.0, 1.0, 1) if is_critical else Vector3(0.5, 0.5, 1)
	$damageLabel.show()
	var new_scale = Vector3(1.5, 1.5, 1.0) if is_critical else Vector3(1.0, 1.0, 1)
	
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property($damageLabel, "global_position", Vector3(this_position.x, (this_position.y + 0.3), this_position.z), 0.7)
	tween.parallel().tween_property($damageLabel, "scale", new_scale, 0.7)
	tween.tween_property($damageLabel, "modulate", Color.TRANSPARENT, 0.3)
	tween.tween_callback($damageLabel.hide)
	
func _on_animation_player_animation_started(anim_name: StringName) -> void:
	match anim_name:
		"Hit_B":
			can_move = false
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"Skeletons_Awaken_Floor":
			if is_dead:
				$AnimationPlayer.play("Skeletons_Inactive_Floor_Pose")
			else:
				$AnimationPlayer.play("Walking_D_Skeletons")
				can_move = true
		"Hit_B":
			if not is_dead:
				$AnimationPlayer.play("Idle_Combat")
				can_move = true

func _on_area_detection_body_entered(body: Node3D) -> void:
	if body is Player and not is_dead:
		if not player_detected:
			$AnimationPlayer.play("Skeletons_Awaken_Floor")
			player_detected = true
		else:
			$AnimationPlayer.play("Walking_D_Skeletons")
			can_move = true
	
func _on_area_detection_body_exited(body: Node3D) -> void:
	if body is Player and not is_dead:
		$AnimationPlayer.play("Idle_Combat")
		velocity = Vector3.ZERO
		can_move = false
		
func _on_area_target_body_entered(body: Node3D) -> void:
	if body is Player and not is_dead:
		velocity = Vector3.ZERO
		can_move = false
		$AnimationPlayer.play("Idle_Combat")

func _on_area_target_body_exited(body: Node3D) -> void:
	if body is Player and not is_dead:
		can_move = true
		$AnimationPlayer.play("Walking_D_Skeletons")
