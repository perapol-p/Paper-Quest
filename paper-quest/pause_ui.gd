extends CanvasLayer

## Pause UI ใหม่: กดปุ่ม Pause แล้วเกม "หยุดชั่วคราว" (paused) แทนที่จะเด้งกลับหน้าแรกทันที
## มีให้ปรับเสียง Music / SFX อยู่ในหน้านี้ด้วย พร้อมปุ่ม Continue (เล่นต่อ) และ Menu (กลับหน้าหลัก)

@onready var pause_button: Button = $PauseButton
@onready var overlay: Control = $Overlay
@onready var continue_button: Button = $Overlay/Panel/Margin/VBox/ButtonRow/ContinueButton
@onready var menu_button: Button = $Overlay/Panel/Margin/VBox/ButtonRow/MenuButton
@onready var music_slider: HSlider = $Overlay/Panel/Margin/VBox/MusicRow/MusicSlider
@onready var sfx_slider: HSlider = $Overlay/Panel/Margin/VBox/SoundRow/SoundSlider

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"


func _ready() -> void:
	# ต้อง Always ไม่งั้นปุ่มในนี้จะกดไม่ได้ตอนเกม paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	overlay.visible = false

	pause_button.pressed.connect(_toggle_pause)
	continue_button.pressed.connect(_on_continue_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	overlay.gui_input.connect(_on_overlay_input)

	_setup_slider(music_slider, MUSIC_BUS)
	_setup_slider(sfx_slider, SFX_BUS)


func _toggle_pause() -> void:
	if overlay.visible:
		_resume_game()
	else:
		_open_pause()


func _open_pause() -> void:
	overlay.visible = true
	get_tree().paused = true

	# กันบัคเดียวกับ Help: ถ้ากำลังลากตราอยู่พอดีตอนกด Pause ให้ดีดกลับฐานทันที
	var stamp_manager := get_tree().get_first_node_in_group("stamp_manager")
	if stamp_manager != null and stamp_manager.has_method("cancel_drag"):
		stamp_manager.cancel_drag()


func _resume_game() -> void:
	overlay.visible = false
	get_tree().paused = false


func _on_continue_pressed() -> void:
	_resume_game()


## กลับหน้าหลัก: ยกเลิก pause ก่อนเปลี่ยนฉากเสมอ ไม่งั้นหน้าหลักจะค้างเป็น paused ไปด้วย
func _on_menu_pressed() -> void:
	get_tree().paused = false
	PauseManager.is_paused_menu = true
	get_tree().change_scene_to_file("res://main_menu.tscn")


## ปิดหน้าต่าง (เล่นต่อ) ถ้าคลิกที่พื้นดำรอบนอกกรอบ (ไม่ใช่ในกรอบ Panel)
func _on_overlay_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		overlay.accept_event()
		_resume_game()


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
