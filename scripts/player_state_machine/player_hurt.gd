extends State
class_name PlayerHurt

const PLAYER_HURT_SFX = preload("res://assets/Music&Sfx/sfx/player_hurt.mp3")

@export var player: Player
@export var player_sprite: AnimatedSprite2D
@export var health: HealthComponent

var player_hurt_sfx_player: AudioStreamPlayer


func _ready() -> void:
	player_hurt_sfx_player = AudioStreamPlayer.new()
	player_hurt_sfx_player.name = "PlayerHurtSfxPlayer"
	player_hurt_sfx_player.stream = PLAYER_HURT_SFX
	add_child(player_hurt_sfx_player)


func enter() -> void:
	if player == null or player_sprite == null or health == null:
		push_warning("PlayerHurt: Missing player, sprite, or health reference.")
		Transitioned.emit(self, "idle")
		return

	health.invulnerable = true

	player.velocity = Vector2.ZERO
	player.move_and_slide()

	play_hurt_sfx()
	play_hurt_animation()

	await player_sprite.animation_finished

	health.invulnerable = false
	Transitioned.emit(self, "idle")

func play_hurt_animation() -> void:
	var dir := player.last_direction

	if abs(dir.x) > abs(dir.y):
		player_sprite.flip_h = dir.x < 0
		play_if_not_playing("hurt_right")
	else:
		if dir.y < 0:
			play_if_not_playing("hurt_up")
		else:
			play_if_not_playing("hurt_down")

func play_if_not_playing(anim: String) -> void:
	if player_sprite.animation != anim:
		player_sprite.play(anim)


func play_hurt_sfx() -> void:
	if player_hurt_sfx_player == null:
		return

	player_hurt_sfx_player.stop()
	player_hurt_sfx_player.play()
