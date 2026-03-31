extends Node2D

enum States {IDLE, RUNNING, ATTACKING}
var state: States = States.IDLE

@onready var player_sprite: AnimatedSprite2D = get_parent().get_node("AnimatedSprite2D")

var last_direction := Vector2.DOWN

func set_state(new_state: States, direction: Vector2):
	if state != new_state:
		state = new_state
	
	match state:
		States.IDLE:
			handle_idle()
		States.RUNNING:
			handle_running(direction)
		States.ATTACKING:
			pass

func handle_idle():
	if abs(last_direction.x) > abs(last_direction.y):
		player_sprite.flip_h = last_direction.x < 0
		play_anim("idle_right")
	else:
		if last_direction.y < 0:
			play_anim("idle_up")
		else:
			play_anim("idle_down")

func handle_running(direction: Vector2):
	last_direction = direction
	
	if abs(direction.x) > abs(direction.y):
		player_sprite.flip_h = direction.x < 0
		play_anim("run_right")
	else:
		if direction.y < 0:
			play_anim("run_up")
		else:
			play_anim("run_down")

func play_anim(anim_name: String):
	if player_sprite.animation != anim_name:
		player_sprite.play(anim_name)
