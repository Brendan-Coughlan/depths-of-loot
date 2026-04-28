extends Camera2D

@export var player: Node2D

func _ready() -> void:
	enabled = true
	zoom = Vector2(4, 4)

func _process(_delta: float) -> void:
	if player:
		global_position = player.global_position
