extends CanvasLayer

@onready var pause_button: Button = $PauseButton

func _ready() -> void:
	pause_button.pressed.connect(_on_pause_pressed)


## กดปุ่ม Pause -> พาไปหน้าแรกของเกม (Main Menu) โดยตั้งค่าไว้ว่ามาจากการ Pause
## เพื่อให้หน้าแรกโชว์ตัวเลือก "เล่นต่อ" / "ออกเกม" แทน "PLAY" / "QUIT"
func _on_pause_pressed() -> void:
	PauseManager.is_paused_menu = true
	get_tree().change_scene_to_file("res://main_menu.tscn")
