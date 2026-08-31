extends Node2D

@onready var good_end = $GoodEndScence
@onready var bad_end = $BadEndScence
@onready var normal_end = $NormalEndScence

func _ready() -> void:
	good_end.hide()
	bad_end.hide()
	normal_end.hide()
	
	var ending := DayManager.calculate_ending()
	
	match ending:
		"good":
			good_end.show()
			MusicManager.stop_music()
			MusicManager.play_goodEnd_music()
		"normal":
			normal_end.show()
			MusicManager.stop_music()
			MusicManager.play_normalEnd_music()
		"bad":
			bad_end.show()
			MusicManager.stop_music()
			MusicManager.play_badEnd_music()

func _on_return_main_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
