extends Node2D
class_name DungeonExit

enum ExitMode {
	NEXT_FLOOR,
	RETURN_TO_SURFACE
}

@export var exit_mode: ExitMode = ExitMode.RETURN_TO_SURFACE
@export var surface_scene_path: String = "res://scenes/market.tscn"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interactable: Area2D = $Interactable
@onready var door_collision_shape: CollisionShape2D = $DoorBlocker/CollisionShape2D

var is_locked: bool = true
var is_open: bool = false


func _ready() -> void:
	add_to_group("dungeon_exit")

	if interactable == null:
		push_error("DungeonExit: Interactable node was not found.")
		return

	# Important:
	# The Interactable node must have your custom Interactable.gd attached.
	interactable.interact = _on_interact

	# Keep interactable enabled even when the door is locked.
	# The prompt can say "Defeat the boss first".
	interactable.is_interactable = true

	set_locked(is_locked)

	print("DungeonExit ready. Interactable script: ", interactable.get_script())


func set_locked(value: bool) -> void:
	is_locked = value

	if is_locked:
		close_door()
	else:
		open_door()


func close_door() -> void:
	is_open = false

	if interactable != null:
		# Do NOT set this to false.
		# If false, your InteractingComponent will not show the prompt.
		interactable.is_interactable = true
		interactable.interact_name = "Defeat the boss first"

	if animated_sprite != null:
		if animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation("closed"):
			animated_sprite.play("closed")
		else:
			push_warning("DungeonExit: Missing 'closed' animation.")

	set_door_collision_enabled(true)

	print("DungeonExit: Door closed. Interactable still enabled.")


func open_door() -> void:
	is_open = true

	if animated_sprite != null:
		if animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation("opening"):
			animated_sprite.play("opening")
			await animated_sprite.animation_finished

			if animated_sprite.sprite_frames.has_animation("open"):
				animated_sprite.play("open")

		elif animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation("open"):
			animated_sprite.play("open")

		else:
			push_warning("DungeonExit: Missing 'open' animation.")

	set_door_collision_enabled(false)

	if interactable != null:
		interactable.is_interactable = true

		match exit_mode:
			ExitMode.NEXT_FLOOR:
				interactable.interact_name = "Go to next floor"

			ExitMode.RETURN_TO_SURFACE:
				interactable.interact_name = "Return to surface"

	print("DungeonExit: Door opened. Interactable enabled. Text: ", interactable.interact_name)


func set_door_collision_enabled(enabled: bool) -> void:
	if door_collision_shape != null:
		door_collision_shape.disabled = not enabled


func _on_interact() -> void:
	print("DungeonExit: _on_interact called.")

	if is_locked or not is_open:
		print("DungeonExit: Door is still locked.")
		return

	match exit_mode:
		ExitMode.NEXT_FLOOR:
			go_to_next_floor()

		ExitMode.RETURN_TO_SURFACE:
			return_to_surface()


func go_to_next_floor() -> void:
	var level_manager = get_tree().get_first_node_in_group("level_manager")

	if level_manager != null and level_manager.has_method("next_floor"):
		level_manager.next_floor()
	else:
		push_warning("DungeonExit: LevelManager was not found.")


func return_to_surface() -> void:
	#print("DungeonExit: Returning to surface: ", surface_scene_path)

	#var main = get_tree().root.get_node_or_null("Main")
#
	#if main != null and main.has_method("load_scene"):
		#main.load_scene(surface_scene_path)
	#else:
		#push_warning("DungeonExit: Main was not found. Cannot return to surface.")
	get_tree().change_scene_to_file("res://scenes/ui/game_over_win_menu.tscn")
