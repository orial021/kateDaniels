extends AnimationTree

var ANIMS : playerAnimation = playerAnimation.new()
var jump_path : String = "parameters/Jump/request"
var current_animation_state : String = ""
@onready var debug_panel: PanelContainer = $"../debugPanel"

@onready var player : Player = get_parent()
@onready var _state_machine : AnimationNodeStateMachinePlayback = get("parameters/StateMachine/playback")

func _process(delta: float) -> void:
	debug_panel.write(player.last_attack)
	state_machine()
		
func cheer() -> void:
	_state_machine.travel(ANIMS.CHEER)

func idle() -> void:
	_state_machine.travel(ANIMS.IDLE)
	
func run() -> void:
	if player.is_unsheathed:
		_state_machine.travel(ANIMS.RUN)

func run_right() -> void:
	if player.is_unsheathed:
		_state_machine.travel(ANIMS.RUN_RIGHT)
	
func run_left() -> void:
	if player.is_unsheathed:
		_state_machine.travel(ANIMS.RUN_LEFT)
	
func walk_back() -> void:
	_state_machine.travel(ANIMS.WALK_BACK)
	
func first_attack() -> void:
	_state_machine.travel(ANIMS.FIRST_ATTACK)
		
func second_attack() -> void:
	_state_machine.travel(ANIMS.SECOND_ATTACK)
	
func third_attack() -> void:
	_state_machine.travel(ANIMS.THIRD_ATTACK)
	
func walk() -> void:
	if not player.is_unsheathed:
		_state_machine.travel(ANIMS.WALK)
	
func attack_idle() -> void:
	_state_machine.travel(ANIMS.ATTACK_IDLE)
	
func jump() -> void:
	set(jump_path, true)
	
func state_machine() -> void:
	match _state_machine.get_current_node():
		ANIMS.CHEER:
			current_animation_state = ANIMS.CHEER
		
		ANIMS.IDLE:
			current_animation_state = ANIMS.IDLE
			#if player.velocity.y > 0:
				#jump()
			match player.is_unsheathed:
				true:
					if GLOBAL.get_axis().y > 0:
						run()
					if GLOBAL.get_axis().x > 0 or GLOBAL.get_axis().x > 0 and GLOBAL.get_axis().x > 0:
						run_right()
					if GLOBAL.get_axis().x < 0 or GLOBAL.get_axis().x > 0 and GLOBAL.get_axis().x < 0:
						run_left()
					if GLOBAL.get_axis().y < 0:
						walk_back()
				false:
					if GLOBAL.get_axis().y > 0 or GLOBAL.get_axis().x != 0:
						walk()
					if GLOBAL.get_axis().y < 0:
						walk_back()
					
		ANIMS.RUN:
			player.speed = 300
			current_animation_state = ANIMS.RUN
			if GLOBAL.get_axis() == Vector2.ZERO:
				idle()
			if GLOBAL.get_axis().x > 0 or GLOBAL.get_axis().y > 0 and GLOBAL.get_axis().x > 0:
				run_right()
			if GLOBAL.get_axis().x < 0 or GLOBAL.get_axis().y > 0 and GLOBAL.get_axis().x < 0:
				run_left()
			if GLOBAL.get_axis().y < 0:
				walk_back()
			#if player.velocity.y > 0:
				#jump()
			if not player.is_unsheathed:
				walk()

		ANIMS.RUN_RIGHT:
			player.speed = 300
			current_animation_state = ANIMS.RUN_RIGHT
			if GLOBAL.get_axis() == Vector2.ZERO:
				idle()
			if GLOBAL.get_axis().y > 0:
				if GLOBAL.get_axis().x == 0:
					run()
				if GLOBAL.get_axis().x < 0:
					run_left()
			if GLOBAL.get_axis().y < 0:
				walk_back()
			#if player.velocity.y > 0:
				#jump()
			
		ANIMS.RUN_LEFT:
			player.speed = 300
			current_animation_state = ANIMS.RUN_LEFT
			if GLOBAL.get_axis() == Vector2.ZERO:
				idle()
			if GLOBAL.get_axis().y > 0:
				if GLOBAL.get_axis().x == 0:
					run()
				if GLOBAL.get_axis().x > 0:
					run_right()
			if GLOBAL.get_axis().y < 0:
				walk_back()
			#if player.velocity.y > 0:
				#jump()
			
		ANIMS.WALK_BACK:
			current_animation_state = ANIMS.WALK_BACK
			player.speed = 120
			if GLOBAL.get_axis() == Vector2.ZERO:
				idle()
			if GLOBAL.get_axis().y > 0:
				run()
			if GLOBAL.get_axis().x > 0 or GLOBAL.get_axis().y > 0 and GLOBAL.get_axis().x > 0:
				run_right()
			if GLOBAL.get_axis().x < 0 or GLOBAL.get_axis().y > 0 and GLOBAL.get_axis().x < 0:
				run_left()
			#if player.velocity.y > 0:
				#jump()
				
		ANIMS.WALK:
			current_animation_state = ANIMS.WALK
			player.speed = 120
			if GLOBAL.get_axis() == Vector2.ZERO:
				idle()
			if GLOBAL.get_axis().y < 0:
				walk_back()
			#if player.velocity.y > 0:
				#jump()
			if player.is_unsheathed:
				run()
		
		ANIMS.ATTACK_IDLE:
			current_animation_state = ANIMS.ATTACK_IDLE
			if GLOBAL.get_axis().y > 0:
				run()
			if GLOBAL.get_axis().x > 0 or GLOBAL.get_axis().y > 0 and GLOBAL.get_axis().x > 0:
				run_right()
			if GLOBAL.get_axis().x < 0 or GLOBAL.get_axis().y > 0 and GLOBAL.get_axis().x < 0:
				run_left()
			if GLOBAL.get_axis().y < 0:
				walk_back()
				

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		ANIMS.CHEER:
			player.can_move = true

func _on_animation_tree_animation_started(anim_name: StringName) -> void:
	match anim_name:
		ANIMS.JUMP:
			current_animation_state = ANIMS.JUMP
			set(jump_path, false)
			if GLOBAL.get_axis() == Vector2.ZERO:
				idle()
			if GLOBAL.get_axis().y > 0:
				run()
			if GLOBAL.get_axis().x > 0 or GLOBAL.get_axis().y > 0 and GLOBAL.get_axis().x > 0:
				run_right()
			if GLOBAL.get_axis().x < 0 or GLOBAL.get_axis().y > 0 and GLOBAL.get_axis().x < 0:
				run_left()
			if GLOBAL.get_axis().y < 0:
				walk_back()
			
