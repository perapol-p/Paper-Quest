extends CanvasLayer

## UI สรุปผลตอนจบวัน โผล่มาตอนลูกค้าครบจำนวนของวันนี้แล้ว (ดู day_manager.gd)
## ถ้ายังไม่ใช่วันสุดท้าย -> ปุ่มจะเป็น "วันต่อไป" ไปวันถัดไป (ลูกค้าจะเพิ่มขึ้น)
## ถ้าเป็นวันสุดท้าย (วันที่ 5) -> โชว์ผลรวมทั้งเกมและ ending (ดี/กลาง/แย่) ปุ่มจะเป็น "เล่นใหม่"

@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var correct_label: Label = $Panel/VBox/CorrectLabel
@onready var wrong_label: Label = $Panel/VBox/WrongLabel
@onready var restart_button: Button = $Panel/VBox/RestartButton

var _waiting_for_final_restart: bool = false


func _ready() -> void:
	visible = false
	restart_button.pressed.connect(_on_restart_pressed)
	DayManager.day_finished.connect(_on_day_finished)


func _on_day_finished(correct: int, wrong: int, total: int, day: int, is_last_day: bool) -> void:
	if is_last_day:
		_show_final_ending()
	else:
		_show_day_summary(correct, wrong, total, day)

	visible = true


func _show_day_summary(correct: int, wrong: int, total: int, day: int) -> void:
	_waiting_for_final_restart = false

	title_label.text = "Day %d Summary (%d customers)" % [day, total]
	correct_label.text = "Correct: %d" % correct
	wrong_label.text = "Wrong: %d" % wrong
	restart_button.text = "Next Day"


func _show_final_ending() -> void:
	_waiting_for_final_restart = true

	var accuracy: float = DayManager.get_total_accuracy()
	var ending: String = DayManager.calculate_ending()

	var ending_text: String
	match ending:
		"good":
			ending_text = "Good End"
		"normal":
			ending_text = "Normal End"
		_:
			ending_text = "Bad End"

	title_label.text = "Game Over! (%s)" % ending_text
	correct_label.text = "Total Correct: %d / %d" % [DayManager.total_correct, DayManager.total_customers]
	wrong_label.text = "Accuracy: %.1f%%" % accuracy
	restart_button.text = "Summary"


func _on_restart_pressed() -> void:
	visible = false

	if _waiting_for_final_restart:
		get_tree().change_scene_to_file("res://ending_scence.tscn")
	else:
		DayManager.advance_day()
		get_tree().reload_current_scene()
