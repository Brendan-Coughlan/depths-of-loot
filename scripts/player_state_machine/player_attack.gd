extends State
class_name PlayerAttack

const PLAYER_ATTACK_SFX = preload("res://assets/Music&Sfx/sfx/player_attack.mp3")

@export var player: Player
@export var player_sprite: AnimatedSprite2D
@export var player_hitboxes: Array[CollisionShape2D]

var player_attack_sfx_player: AudioStreamPlayer


func _ready() -> void:
	player_attack_sfx_player = AudioStreamPlayer.new()
	player_attack_sfx_player.name = "PlayerAttackSfxPlayer"
	player_attack_sfx_player.stream = PLAYER_ATTACK_SFX
	add_child(player_attack_sfx_player)


func enter() -> void:
	var dir := player.last_direction

	play_attack_sfx()
	play_attack_animation()
	if abs(dir.x) > abs(dir.y):
		if dir.x < 0:
			player_hitboxes[1].disabled = false
		else:
			player_hitboxes[0].disabled = false
	else:
		if dir.y < 0:
			player_hitboxes[2].disabled = false
		else:
			player_hitboxes[3].disabled = false
	await player_sprite.animation_finished
	if abs(dir.x) > abs(dir.y):
		if dir.x < 0:
			player_hitboxes[1].disabled = true
		else:
			player_hitboxes[0].disabled = true
	else:
		if dir.y < 0:
			player_hitboxes[2].disabled = true
		else:
			player_hitboxes[3].disabled = true
	Transitioned.emit(self, "idle")

func physics_update(_delta: float) -> void:
	var direction := Input.get_vector(
		"move_left", "move_right",
		"move_up", "move_down"
	)

	if direction != Vector2.ZERO:
		player.update_last_direction(direction)

func play_attack_animation() -> void:
	var dir := player.last_direction

	if abs(dir.x) > abs(dir.y):
		player_sprite.flip_h = dir.x < 0
		play_if_not_playing("attack_right")
	else:
		if dir.y < 0:
			play_if_not_playing("attack_up")
		else:
			play_if_not_playing("attack_down")

func play_if_not_playing(anim: String) -> void:
	if player_sprite.animation != anim:
		player_sprite.play(anim)


func play_attack_sfx() -> void:
	if player_attack_sfx_player == null:
		return

	player_attack_sfx_player.stop()
	player_attack_sfx_player.play()
