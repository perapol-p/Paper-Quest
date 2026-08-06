extends Control

## บอร์ดแสดงเควส: สุ่มเควสมาแสดงอัตโนมัติตอนเปิดฉาก (ไม่มีปุ่มสุ่ม / ไม่มีปุ่ม Take-Turn)
## คลิกใบเควสบนบอร์ด -> เด้งไปหน้าตรวจสอบเควส (QuestInspect) ซึ่งจะสุ่มเควสของตัวเองขึ้นมาใหม่ครั้งเดียว

const QuestPaperScene := preload("res://quests/quest_paper.tscn")
const QuestInspectScene := preload("res://quests/quest_inspect.tscn")

## จำนวนเควสที่จะสุ่มมาแสดงบนบอร์ดตอนเริ่ม
@export var quest_count: int = 6

@onready var quest_container: FlowContainer = $ScrollContainer/QuestContainer


func _ready() -> void:
	refresh_board()


## สุ่มเควสชุดใหม่มาแสดงแทนของเดิมทั้งหมด
func refresh_board() -> void:
	for child in quest_container.get_children():
		child.queue_free()

	var batch: Array[QuestData] = QuestDatabase.generate_quest_batch(quest_count)
	for quest in batch:
		spawn_quest(quest)


func spawn_quest(data: QuestData) -> void:
	var paper: QuestPaper = QuestPaperScene.instantiate()
	quest_container.add_child(paper)
	paper.setup(data)
	paper.quest_clicked.connect(_on_quest_paper_clicked)


## เมื่อคลิกใบเควสบนบอร์ด ให้เปิดหน้าตรวจสอบเควสขึ้นมาแบบ overlay เต็มจอ
## ส่งข้อมูลเควส "ใบเดียวกัน" กับที่คลิกไปแสดง ไม่สุ่มใหม่ซ้ำอีกรอบ
func _on_quest_paper_clicked(data: QuestData) -> void:
	var inspect: QuestInspect = QuestInspectScene.instantiate()
	inspect.setup_data(data)
	get_tree().current_scene.add_child(inspect)
