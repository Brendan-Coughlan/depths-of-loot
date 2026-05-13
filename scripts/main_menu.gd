extends Control

const MAIN_MENU_MUSIC_SOURCE = preload("res://assets/Music&Sfx/mainMenu.mp3")

var background_music_player: AudioStreamPlayer
var main_menu_music: AudioStream


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	background_music_player = AudioStreamPlayer.new()
	background_music_player.name = "BackgroundMusicPlayer"
	add_child(background_music_player)

	main_menu_music = MAIN_MENU_MUSIC_SOURCE.duplicate()
	if main_menu_music is AudioStreamMP3:
		main_menu_music.loop = true

	background_music_player.stream = main_menu_music
	background_music_player.play()

func _process(delta: float) -> void:
	pass

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_settings_pressed() -> void:
	print("Options pressed")

func _on_quit_pressed() -> void:
	get_tree().quit()
