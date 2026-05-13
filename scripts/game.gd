extends Node

const DUNGEON_SCENE_PATH: String = "res://scenes/game.tscn"
const DUNGEON_MUSIC_SOURCE = preload("res://assets/Music&Sfx/dungeon.mp3")
const MARKET_MUSIC_SOURCE = preload("res://assets/Music&Sfx/market.mp3")

@onready var scene_holder = $SceneHolder
@onready var market_scene: String = "res://scenes/market.tscn"
@onready var game_scene: String = "res://scenes/game.tscn"

var background_music_player: AudioStreamPlayer
var dungeon_music: AudioStream
var market_music: AudioStream


func _ready():
	background_music_player = AudioStreamPlayer.new()
	background_music_player.name = "BackgroundMusicPlayer"
	add_child(background_music_player)

	dungeon_music = DUNGEON_MUSIC_SOURCE.duplicate()
	if dungeon_music is AudioStreamMP3:
		dungeon_music.loop = true

	market_music = MARKET_MUSIC_SOURCE.duplicate()
	if market_music is AudioStreamMP3:
		market_music.loop = true

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

	update_background_music(path)


func update_background_music(path: String) -> void:
	if path == market_scene:
		play_background_music(market_music)
	elif path == DUNGEON_SCENE_PATH:
		play_background_music(dungeon_music)
	else:
		stop_background_music()


func play_background_music(music: AudioStream) -> void:
	if background_music_player.stream != music:
		background_music_player.stream = music
		background_music_player.play()
		return

	if not background_music_player.playing:
		background_music_player.play()


func stop_background_music() -> void:
	if background_music_player.playing:
		background_music_player.stop()
