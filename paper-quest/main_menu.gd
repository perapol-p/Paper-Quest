extends Control

@export var game_scene_path: String = "res://main.tscn"

@onready var music_slider: HSlider = $MenuPanel/VBox/MusicRow/MusicSlider
@onready var sfx_slider: HSlider = $MenuPanel/VBox/SoundRow/SoundSlider
@onready var play_button: Button = $MenuPanel/VBox/PlayButton
@onready var quit_button: Button = $MenuPanel/VBox/QuitButton

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"

func _ready() -> void:
	_setup_slider(music_slider, MUSIC_BUS)
	_setup_slider(sfx_slider, SFX_BUS)

	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _setup_slider(slider: HSlider, bus_name: String) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		slider.editable = false
		return

	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01

	var db := AudioServer.get_bus_volume_db(bus_idx)
	slider.value = db_to_linear(db) if db > -80.0 else 0.0

	slider.value_changed.connect(func(value: float) -> void:
		var linear: float = value
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear) if linear > 0.0 else -80.0)
		AudioServer.set_bus_mute(bus_idx, linear <= 0.0)
	)


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(game_scene_path)


func _on_quit_pressed() -> void:
	get_tree().quit()
