extends CharacterBody3D
class_name Enemy

# --- VARIABLES ---
@export var player: Player
@export var max_health := 30
@export var move_speed := 200
@export var rotation_speed := 10.0

var health : int
var player_detected : bool = false
var can_move := false
var is_dead := false

func _ready() -> void:
	$SubViewport/ProgressBar.max_value = max_health
	health = max_health
	
func _process(delta: float) -> void:
	update_health_display()
	
func _physics_process(delta):
	velocity.y -= get_physics_process_delta_time() * GLOBAL.gravity
	if is_dead:
		return
	
	handle_movement(delta)
	move_and_slide()
	
func handle_movement(delta : float) -> void:
	if !player_detected or !can_move or !player:
		return
		
	else:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * move_speed * delta
	
		if velocity.length() > 0.1:
			rotate_towards_player(direction, delta)
		
func rotate_towards_player(direction: Vector3, delta: float) -> void:
	var target_angle = atan2(direction.x, direction.z)
	rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)
	
func update_health_display() -> void:
	$Label3D.text = "LIFE: " + str(health)
	$SubViewport/ProgressBar.value = health
	
func damage_ctrl(damage : int) -> void:
	if is_dead:
		return
		
	health -= damage
	$AnimationPlayer.play("Hit_B")
	
	if health <= 0:
		die()

func die() -> void:
	is_dead = true
	can_move = false
	velocity.y = 0
	$AnimationPlayer.play_backwards("Skeletons_Awaken_Floor")
	$CollisionShape3D.set_deferred("disabled", true)

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
			can_move = true

func _on_area_detection_body_entered(body: Node3D) -> void:
	if body is Player:
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
