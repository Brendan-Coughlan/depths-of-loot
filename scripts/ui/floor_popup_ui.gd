extends CanvasLayer
class_name FloorPopupUI

@onready var popup_root: Control = $PopupRoot
@onready var background: TextureRect = $PopupRoot/Background
@onready var label: Label = $PopupRoot/Background/Label

var tween: Tween


func _ready() -> void:
	add_to_group("floor_popup_ui")

	# Important: this popup must keep working while the game tree is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	popup_root.process_mode = Node.PROCESS_MODE_ALWAYS
	background.process_mode = Node.PROCESS_MODE_ALWAYS
	label.process_mode = Node.PROCESS_MODE_ALWAYS

	popup_root.modulate.a = 0.0
	popup_root.visible = false


func show_floor_message(current_floor: int, max_floor: int) -> void:
	var floors_left: int = max_floor - current_floor

	if floors_left <= 0:
		label.text = "Final Floor\nFloor %d" % current_floor
	else:
		label.text = "Floor %d\n%d floors left" % [current_floor, floors_left]

	show_event_message(label.text)

	await get_tree().create_timer(3.0, true).timeout

	await hide_event_message()


func show_event_message(message: String) -> void:
	label.text = message

	popup_root.visible = true

	if tween != null:
		tween.kill()

	popup_root.modulate.a = 0.0

	tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(popup_root, "modulate:a", 1.0, 0.4)


func hide_event_message() -> void:
	if tween != null:
		tween.kill()

	tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(popup_root, "modulate:a", 0.0, 0.8)

	await tween.finished

	popup_root.visible = false
