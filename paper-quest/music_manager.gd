extends Node2D

@onready var player: AudioStreamPlayer = $AudioStreamPlayer

var menu_music: AudioStream = preload("res://Assets/Sound/Music/MainMenu.mp3")
var game_music: AudioStream = preload("res://Assets/Sound/Music/InGameplay.mp3")
var badEnd_music: AudioStream = preload("res://Assets/Sound/Music/BadEnd.mp3")
var goodEnd_music: AudioStream = preload("res://Assets/Sound/Music/GoodEnd.mp3")
var normalEnd_music: AudioStream = preload("res://Assets/Sound/Music/NormalEnd.mp3")
var game_music2: AudioStream = preload("res://Assets/Sound/Music/InGameplay2.mp3")

func play_music(new_music: AudioStream) -> void:
	if player.stream == new_music and player.playing:
		return
		
	player.stream = new_music
	player.play()

func stop_music() -> void:
	player.stop()

func play_menu_music() -> void:
	play_music(menu_music)

func play_game_music() -> void:
	# ถ้ากำลังเล่นเพลง game_music อยู่แล้ว ไม่ต้องสุ่มใหม่
	if player.playing and (player.stream == game_music or player.stream == game_music2):
		return

	# ถ้ายังไม่ใช่เพลง game_music ให้สุ่มใหม่
	var random_music: AudioStream = [game_music, game_music2].pick_random()
	play_music(random_music)

func play_goodEnd_music() -> void:
	play_music(goodEnd_music)

func play_badEnd_music() -> void:
	play_music(badEnd_music)

func play_normalEnd_music() -> void:
	play_music(normalEnd_music)
