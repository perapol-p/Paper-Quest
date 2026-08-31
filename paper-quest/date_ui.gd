extends CanvasLayer

@onready var date_label: Label = $Control/VBoxContainer/DateLabel


func _ready() -> void:
	MusicManager.play_game_music()
	update_date()


func update_date() -> void:
	date_label.text = "%d/%d/%d" % [
		DayManager.date_day,
		DayManager.date_month,
		DayManager.date_year
	]


func get_current_date() -> Dictionary:
	return {
		"day": DayManager.date_day,
		"month": DayManager.date_month,
		"year": DayManager.date_year
	}
