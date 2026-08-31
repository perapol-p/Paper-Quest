extends Node2D

@onready var player: AudioStreamPlayer = $AudioStreamPlayer

var bell_sfx: AudioStream = preload("res://Assets/Sound/Effect/Bell.mp3")
var bell_sfx2: AudioStream = preload("res://Assets/Sound/Effect/Bell2.mp3")
var id_slide: AudioStream = preload("res://Assets/Sound/Effect/ID_slide.mp3")
var quest_close: AudioStream = preload("res://Assets/Sound/Effect/Quest_close.mp3")
var quest_open: AudioStream = preload("res://Assets/Sound/Effect/Quest_open.mp3")
var stamp_sfx: AudioStream = preload("res://Assets/Sound/Effect/Stamp.mp3")

func play_sfx(sound: AudioStream) -> void:
	player.stream = sound
	player.play()

func play_bell_sfx() -> void:
	var random_bell : AudioStream = [bell_sfx,bell_sfx2].pick_random()
	play_sfx(random_bell)

func play_id_slide() -> void:
	play_sfx(id_slide)

func play_quest_close() -> void:
	play_sfx(quest_close)

func play_quest_open() -> void:
	play_sfx(quest_open)

func play_stamp_sfx() -> void:
	play_sfx(stamp_sfx)
