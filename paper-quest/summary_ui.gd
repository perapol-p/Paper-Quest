extends CanvasLayer

## UI สรุปผลตอนจบวัน โผล่มาตอนลูกค้าครบจำนวนของวันนี้แล้ว (ดู day_manager.gd)

@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var correct_label: Label = $Panel/VBox/CorrectLabel
@onready var wrong_label: Label = $Panel/VBox/WrongLabel
@onready var restart_button: Button = $Panel/VBox/RestartButton


func _ready() -> void:
	visible = false
	restart_button.pressed.connect(_on_restart_pressed)
	DayManager.day_finished.connect(_on_day_finished)


func _on_day_finished(correct: int, wrong: int, total: int) -> void:
	title_label.text = "สรุปผลวันนี้ (ลูกค้า %d คน)" % total
	correct_label.text = "ทำถูก: %d คน" % correct
	wrong_label.text = "ทำผิด: %d คน" % wrong

	visible = true


func _on_restart_pressed() -> void:
	DayManager.start_new_day()
	get_tree().reload_current_scene()
