extends CanvasLayer
class_name FloorPopupUI

@onready var popup_root: Control = $PopupRoot
@onready var background: TextureRect = $PopupRoot/Background
@onready var label: Label = $PopupRoot/Background/Label

var tween: Tween


func _ready() -> void:
	popup_root.modulate.a = 0.0
	popup_root.visible = false

	await get_tree().create_timer(1.0).timeout
	show_floor_message(3, 10)

func show_floor_message(current_floor: int, max_floor: int) -> void:
	var floors_left: int = max_floor - current_floor

	if floors_left <= 0:
		label.text = "Final Floor\nFloor %d" % current_floor
	else:
		label.text = "Floor %d\n%d floors left" % [current_floor, floors_left]

	popup_root.visible = true

	if tween != null:
		tween.kill()

	popup_root.modulate.a = 0.0

	tween = create_tween()
	tween.tween_property(popup_root, "modulate:a", 1.0, 0.4)
	tween.tween_interval(3.0)
	tween.tween_property(popup_root, "modulate:a", 0.0, 0.8)
	tween.finished.connect(_on_tween_finished)


func _on_tween_finished() -> void:
	popup_root.visible = false
