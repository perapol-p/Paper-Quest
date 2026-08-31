extends CanvasLayer

@onready var help_button: Button = $HelpButton
@onready var overlay: Control = $Overlay
@onready var close_button: Button = $Overlay/Panel/Margin/VBox/TopBar/CloseButton

func _ready() -> void:
	overlay.visible = false
	help_button.pressed.connect(_toggle_help)
	close_button.pressed.connect(_close_help)
	overlay.gui_input.connect(_on_overlay_input)


func _toggle_help() -> void:
	overlay.visible = not overlay.visible

	# ถ้าเพิ่งเปิด Help ขึ้นมา ให้เช็คว่ามีการลากตราค้างอยู่หรือเปล่า
	# (เผื่อผู้เล่นกดปุ่ม Help ขณะกำลังลากตราพอดี) แล้วบังคับดีดกลับฐานทันที
	if overlay.visible:
		_cancel_any_active_stamp_drag()


func _cancel_any_active_stamp_drag() -> void:
	var stamp_manager := get_tree().get_first_node_in_group("stamp_manager")
	if stamp_manager != null and stamp_manager.has_method("cancel_drag"):
		stamp_manager.cancel_drag()


func _close_help() -> void:
	overlay.visible = false


## ปิดหน้าต่างถ้าคลิกที่พื้นดำรอบนอกกรอบ (ไม่ใช่ในกรอบ Panel)
func _on_overlay_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		overlay.accept_event()
		_close_help()
