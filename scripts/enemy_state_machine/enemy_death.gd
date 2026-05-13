extends State
class_name EnemyDeath

const SKELETON_DIE_SFX = preload("res://assets/Music&Sfx/sfx/skeleton_die.mp3")
const STONE_TITAN_DIE_SFX = preload("res://assets/Music&Sfx/sfx/stone_titan_die.mp3")

@export var enemy: Enemy
@export var enemy_sprite: AnimatedSprite2D

func enter() -> void:
	enemy.velocity = Vector2.ZERO
	play_death_sfx()
	
	if enemy_sprite:
		play_death_animation()
		await enemy_sprite.animation_finished
		print("Enemy is dead")
		enemy.queue_free()
		
	else:
		print("Enemy sprite not found")

func physics_update(_delta: float) -> void:
	enemy.velocity = Vector2.ZERO

func play_death_animation() -> void:
	var dir : Vector2 = enemy.last_direction
	
	if abs(dir.x) > abs(dir.y):
		enemy_sprite.flip_h = dir.x < 0
		play_if_not_playing("death_right")
	else:
		if dir.y < 0:
			play_if_not_playing("death_up")
		else:
			play_if_not_playing("death_down")

func play_if_not_playing(anim: String) -> void:
	if enemy_sprite.animation != anim:
		enemy_sprite.play(anim)


func play_death_sfx() -> void:
	var death_sfx := get_death_sfx()

	if death_sfx == null:
		return

	var sfx_player := AudioStreamPlayer.new()
	sfx_player.stream = death_sfx
	sfx_player.finished.connect(sfx_player.queue_free)
	get_tree().root.add_child(sfx_player)
	sfx_player.play()


func get_death_sfx() -> AudioStream:
	var enemy_scene_name := enemy.scene_file_path.get_file().get_basename()
	var enemy_name := enemy.name.to_lower()

	match enemy_scene_name:
		"boneblade_stalker", "undead_sentinel":
			return SKELETON_DIE_SFX
		"stone_titan":
			return STONE_TITAN_DIE_SFX

	if enemy_name.contains("boneblade") or enemy_name.contains("undead"):
		return SKELETON_DIE_SFX

	if enemy_name.contains("stone") and enemy_name.contains("titan"):
		return STONE_TITAN_DIE_SFX

	return null
