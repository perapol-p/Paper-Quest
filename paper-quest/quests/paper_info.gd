extends Control
class_name PaperInfo

## ตัวใบเควส (กระดาษ + ข้อความ) ที่ลากไปมาได้เพียงส่วนนี้ส่วนเดียว
## ส่วนพื้นหลังโต๊ะ/ผ้ารองจาน (TableBG, Placemat) และปุ่มปิด จะไม่ขยับตาม

var dragging: bool = false
var drag_start_mouse: Vector2 = Vector2.ZERO
var drag_start_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_DRAG
	gui_input.connect(_on_gui_input)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_start_mouse = get_global_mouse_position()
			drag_start_pos = position
			accept_event()
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		var delta: Vector2 = get_global_mouse_position() - drag_start_mouse
		position = drag_start_pos + delta
		accept_event()
