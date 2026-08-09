extends Control
class_name QuestInspect

## หน้าตรวจสอบเควส (Quest Inspect Screen)
## เปิดขึ้นมาเมื่อคลิกที่ใบเควสที่ "วางอยู่บนโต๊ะแล้ว" (ส่งมาจากคนที่มาส่งเควส)
## จะแสดงข้อมูลเควส "ใบเดียวกัน" กับที่วางอยู่บนโต๊ะ/บอร์ด ไม่สุ่มใหม่ซ้ำอีกครั้ง
## แต่ถ้าเปิดหน้านี้ขึ้นมาลอย ๆ โดยไม่มีใครส่งข้อมูลมาให้ (data == null)
## จะสุ่มข้อมูลเควสขึ้นมาเองเพียงครั้งเดียวตอนเปิดหน้านี้ (เผื่อไว้ใช้ทดสอบ/เรียกตรง ๆ)
## แสดงผลอย่างเดียว ไม่มีปุ่ม Take/Turn ตามระบบเดิม
## เฉพาะตัวกระดาษ (PaperInfo) เท่านั้นที่ลากไปมาได้ — ดูโค้ดการลากใน paper_info.gd

var quest_data: QuestData

@onready var title_label: Label = $Center/Panel/PaperInfo/Content/VBox/TitleLabel
@onready var desc_label: Label = $Center/Panel/PaperInfo/Content/VBox/DescLabel
@onready var target_label: Label = $Center/Panel/PaperInfo/Content/VBox/TargetLabel
@onready var reward_label: Label = $Center/Panel/PaperInfo/Content/VBox/RewardLabel
@onready var rank_badge_label: Label = $Center/Panel/PaperInfo/Content/VBox/RankRow/RankBadge/RankBadgeLabel
@onready var rank_text_label: Label = $Center/Panel/PaperInfo/Content/VBox/RankRow/RankTextLabel
@onready var close_button: Button = $Center/Panel/CloseButton
@onready var dim: ColorRect = $Dim


func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	dim.gui_input.connect(_on_dim_gui_input)

	# ถ้ายังไม่มีใครกำหนดข้อมูลเควสมาให้ (เช่น เปิด scene นี้ตรง ๆ โดยไม่ผ่าน setup_data)
	# ให้สุ่มข้อมูลเควสขึ้นมาเองครั้งเดียวตอนเปิดหน้านี้ กันไว้เผื่อจอว่าง
	if quest_data == null:
		quest_data = QuestDatabase.generate_random_quest()
	_refresh()


## เรียกก่อน add_child ลง scene tree เพื่อบอกว่าใบเควสที่คลิกมามีข้อมูลอะไร
## จะได้แสดงข้อมูล "ใบเดียวกัน" กับที่วางอยู่บนโต๊ะ ไม่ใช่สุ่มใหม่
func setup_data(data: QuestData) -> void:
	quest_data = data
	if is_node_ready():
		_refresh()


func _refresh() -> void:
	title_label.text = quest_data.title
	desc_label.text = quest_data.description
	target_label.text = "เป้าหมาย: %s   x%d" % [quest_data.target_name, quest_data.target_count]
	reward_label.text = "รางวัล: %d Gold" % quest_data.reward_gold
	rank_badge_label.text = quest_data.quest_rank
	rank_text_label.text = "%s | %s" % [quest_data.category_text, quest_data.rank_text]


func _on_close_pressed() -> void:
	queue_free()


func _on_dim_gui_input(event: InputEvent) -> void:
	# คลิกพื้นหลังมืดรอบนอกเพื่อปิดหน้าตรวจสอบเควส
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		queue_free()
