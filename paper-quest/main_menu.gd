extends Control

@export var game_scene_path: String = "res://main.tscn"

@onready var music_slider: HSlider = $MenuPanel/VBox/MusicRow/MusicSlider
@onready var sfx_slider: HSlider = $MenuPanel/VBox/SoundRow/SoundSlider
@onready var play_button: Button = $MenuPanel/VBox/PlayButton
@onready var quit_button: Button = $MenuPanel/VBox/QuitButton
@onready var credits_button: Button = $MenuPanel/VBox/CreditsButton

@onready var credits_overlay: Control = $CreditsOverlay
@onready var credits_close_button: Button = $CreditsOverlay/Panel/Margin/VBox/TopBar/CloseButton

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"

## true ถ้าเข้าหน้านี้มาจากการกดปุ่ม Pause ระหว่างเล่น (มีเกมค้างอยู่)
## -> โชว์ "เล่นต่อ" / "ออกเกม" แทน "PLAY" / "QUIT" และไม่รีเซ็ตเกมตอนเล่นต่อ
var _resuming: bool = false

func _ready() -> void:
	_setup_slider(music_slider, MUSIC_BUS)
	_setup_slider(sfx_slider, SFX_BUS)

	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	credits_overlay.visible = false
	credits_button.pressed.connect(_toggle_credits)
	credits_close_button.pressed.connect(_close_credits)
	credits_overlay.gui_input.connect(_on_credits_overlay_input)

	_resuming = PauseManager.is_paused_menu
	PauseManager.is_paused_menu = false

	if _resuming:
		play_button.text = "CONTINUE"
		quit_button.text = "QUIT"
	else:
		play_button.text = "PLAY"
		quit_button.text = "QUIT"
	
	MusicManager.stop_music()
	MusicManager.play_menu_music()
 


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
	if not _resuming:
		DayManager.reset_game()

func _on_quit_pressed() -> void:
	get_tree().quit()


func _toggle_credits() -> void:
	credits_overlay.visible = not credits_overlay.visible


func _close_credits() -> void:
	credits_overlay.visible = false


## ปิดหน้าต่างถ้าคลิกที่พื้นดำรอบนอกกรอบ (ไม่ใช่ในกรอบ Panel)
func _on_credits_overlay_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		credits_overlay.accept_event()
		_close_credits()
