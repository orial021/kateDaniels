extends AnimationTree

var ANIMS : playerAnimationB = playerAnimationB.new()
var jump_path : String = "parameters/Jump/request"
var current_animation_state : String = ""

@onready var debug_panel: PanelContainer = $"../debugPanel"
@onready var player : Player = get_parent()
@onready var _state_machine : AnimationNodeStateMachinePlayback = get("parameters/StateMachine/playback")

func _process(_delta: float) -> void:
	state_machine()
		
	
func attacks(attackType: AttackBData.AttackType) -> void:
	match attackType:
		AttackBData.AttackType.ATTACK_REVERSE:
			_state_machine.travel(ANIMS.ATTACK_REVERSE)
		AttackBData.AttackType.ATTACK_ROUND_KICK:
			_state_machine.travel(ANIMS.ATTACK_ROUND_KICK)
		AttackBData.AttackType.ATTACK_SLASH:
			_state_machine.travel(ANIMS.ATTACK_SLASH)
		AttackBData.AttackType.ATTACK_DASH:
			_state_machine.travel(ANIMS.ATTACK_DASH)
		AttackBData.AttackType.ATTACK_ROUND:
			_state_machine.travel(ANIMS.ATTACK_ROUND)
	

	
func state_machine() -> void:
	match _state_machine.get_current_node():
		ANIMS.INIT:
			current_animation_state = ANIMS.INIT
		ANIMS.COMBAT_IDLE_1:
			current_animation_state = ANIMS.COMBAT_IDLE_1
					
		ANIMS.RUN:
			player.mov_speed = 300
			current_animation_state = ANIMS.RUN

		ANIMS.RUN_STRAFE_RIGHT:
			player.mov_speed = 300
			current_animation_state = ANIMS.RUN_STRAFE_RIGHT
			
		ANIMS.RUN_STRAFE_LEFT:
			player.mov_speed = 300
			current_animation_state = ANIMS.RUN_STRAFE_LEFT
			
		ANIMS.RUN_BACK:
			current_animation_state = ANIMS.RUN_BACK
			player.mov_speed = 300
				
		ANIMS.WALK:
			current_animation_state = ANIMS.WALK
		
		ANIMS.BLOCK_POSE:
			current_animation_state = ANIMS.BLOCK_POSE
				
		ANIMS.JUMP:
			current_animation_state = ANIMS.JUMP
			
func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		ANIMS.INIT:
			player.can_move = true
			

func _on_animation_tree_animation_started(anim_name: StringName) -> void:
	match anim_name:
		pass

			
