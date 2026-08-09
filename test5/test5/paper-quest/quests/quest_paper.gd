extends Control
class_name QuestPaper

## กระดาษเควส 1 ใบ - แสดงข้อมูลที่สุ่มมาเท่านั้น (ไม่มีปุ่ม Take/Turn)
## คลิกที่ใบเควสเพื่อเปิด "หน้าตรวจสอบเควส" (QuestInspect)

signal quest_clicked(data: QuestData)

var quest_data: QuestData

@onready var title_label: Label = $Margin/VBox/TitleLabel
@onready var desc_label: Label = $Margin/VBox/DescLabel
@onready var target_label: Label = $Margin/VBox/TargetLabel
@onready var rank_label: Label = $Margin/VBox/RankLabel
@onready var reward_label: Label = $Margin/VBox/RewardLabel


func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if quest_data:
		_refresh()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		quest_clicked.emit(quest_data)


## เรียกเพื่อผูกกระดาษใบนี้กับข้อมูลเควสที่สุ่มมา
func setup(data: QuestData) -> void:
	quest_data = data
	if is_node_ready():
		_refresh()


func _refresh() -> void:
	title_label.text = quest_data.title
	desc_label.text = quest_data.description
	target_label.text = "%s   %dx" % [quest_data.target_name, quest_data.target_count]
	rank_label.text = "Rank %s | %s | %s" % [quest_data.quest_rank, quest_data.category_text, quest_data.rank_text]
	reward_label.text = "รางวัล: %d Gold" % quest_data.reward_gold
