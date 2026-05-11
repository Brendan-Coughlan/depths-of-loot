extends Camera2D

@export var player: Node2D

func _ready() -> void:
	resolve_player()
	enabled = true
	zoom = Vector2(0.25, 0.25)

func _process(_delta: float) -> void:
	if not is_instance_valid(player):
		resolve_player()

	if player == null:
		return

	global_position = player.global_position


func resolve_player() -> void:
	player = get_tree().get_first_node_in_group("player") as Node2D
