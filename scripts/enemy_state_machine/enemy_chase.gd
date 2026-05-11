extends State
class_name EnemyChase

@export var enemy: Enemy
@export var enemy_sprite: AnimatedSprite2D

var level_manager: Node = null
var waypoint_reached_distance: float = 12.0
var direct_chase_distance: float = 64.0
var stuck_attack_distance: float = 64.0
var stuck_time_to_attack: float = 0.18
var stuck_movement_epsilon: float = 0.5
var stuck_time: float = 0.0
var previous_position: Vector2 = Vector2.ZERO


func enter() -> void:
	if enemy == null:
		enemy = owner as Enemy

	if enemy_sprite == null and enemy != null:
		enemy_sprite = enemy.get_node_or_null("AnimatedSprite2D")

	if enemy != null and enemy.target == null:
		enemy.find_player()

	level_manager = get_tree().get_first_node_in_group("level_manager")
	stuck_time = 0.0
	previous_position = enemy.global_position

	play_run_animation()


func physics_update(_delta: float) -> void:
	if enemy == null:
		return

	if enemy.target == null:
		enemy.find_player()
		return

	var distance := enemy.global_position.distance_to(enemy.target.global_position)

	# Too far away: go back to idle
	if distance > enemy.chase_stop_range:
		Transitioned.emit(self, "idle")
		return

	# Close enough: attack
	if get_attack_handoff_distance() <= enemy.attack_range:
		enemy.velocity = Vector2.ZERO
		enemy.move_and_slide()
		Transitioned.emit(self, "attack")
		return

	var direction := get_chase_direction()

	if direction == Vector2.ZERO:
		enemy.velocity = Vector2.ZERO
		if get_attack_handoff_distance() <= stuck_attack_distance:
			Transitioned.emit(self, "attack")
		return

	previous_position = enemy.global_position
	enemy.velocity = direction * enemy.movement_speed
	enemy.update_last_direction(direction)
	enemy.move_and_slide()

	if should_attack_when_stuck(_delta):
		enemy.velocity = Vector2.ZERO
		Transitioned.emit(self, "attack")
		return

	play_run_animation()


func exit() -> void:
	if enemy != null:
		enemy.velocity = Vector2.ZERO


func get_chase_direction() -> Vector2:
	if enemy == null or enemy.target == null:
		return Vector2.ZERO

	if level_manager == null:
		level_manager = get_tree().get_first_node_in_group("level_manager")

	if enemy.global_position.distance_to(enemy.target.global_position) <= direct_chase_distance:
		return enemy.global_position.direction_to(enemy.target.global_position)

	if level_manager != null and level_manager.has_method("get_path_between_global_positions"):
		var path: Array = level_manager.get_path_between_global_positions(
			enemy.global_position,
			enemy.target.global_position
		)

		if path.size() > 1:
			var waypoint_index := 1

			while waypoint_index < path.size() - 1:
				var waypoint := path[waypoint_index] as Vector2

				if enemy.global_position.distance_to(waypoint) > waypoint_reached_distance:
					break

				waypoint_index += 1

			return enemy.global_position.direction_to(path[waypoint_index] as Vector2)

	return enemy.global_position.direction_to(enemy.target.global_position)


func should_attack_when_stuck(delta: float) -> bool:
	if enemy == null or enemy.target == null:
		return false

	if get_attack_handoff_distance() > stuck_attack_distance:
		stuck_time = 0.0
		return false

	var moved_distance := previous_position.distance_to(enemy.global_position)

	if moved_distance <= stuck_movement_epsilon:
		stuck_time += delta
	else:
		stuck_time = 0.0

	return stuck_time >= stuck_time_to_attack


func get_attack_handoff_distance() -> float:
	if enemy == null or enemy.target == null:
		return INF

	var root_distance := enemy.global_position.distance_to(enemy.target.global_position)
	var enemy_origin := enemy.get_node_or_null("AttackOrigin") as Marker2D
	var player_target := enemy.target.get_node_or_null("TargetPoint") as Marker2D

	if enemy_origin == null or player_target == null:
		return root_distance

	var marker_distance := enemy_origin.global_position.distance_to(player_target.global_position)
	return min(root_distance, marker_distance)


func play_run_animation() -> void:
	if enemy == null or enemy_sprite == null:
		return

	var dir := enemy.last_direction

	if abs(dir.x) > abs(dir.y):
		enemy_sprite.flip_h = dir.x < 0
		play_if_not_playing("run_right")
	else:
		enemy_sprite.flip_h = false

		if dir.y < 0:
			play_if_not_playing("run_up")
		else:
			play_if_not_playing("run_down")


func play_if_not_playing(anim: String) -> void:
	if enemy_sprite == null:
		return

	if enemy_sprite.animation != anim:
		enemy_sprite.play(anim)
