extends Node

@onready var scene_holder = $SceneHolder
@onready var market_scene: String = "res://scenes/market.tscn"
@onready var game_scene: String = "res://scenes/game.tscn"

func _ready():
	if Game.player == null:
		var player_scene = preload("res://scenes/player.tscn")
		Game.player = player_scene.instantiate()

	add_child(Game.player)
	
	load_scene(market_scene)

func load_scene(path: String, player_position: Vector2 = Vector2(0, 0)):
	if scene_holder.get_child_count() > 0:
		scene_holder.get_child(0).queue_free()

	Game.player.position = player_position
	var scene = load(path).instantiate()
	scene_holder.add_child(scene)
