extends CanvasLayer

## UI ปุ่มส่งเควส + ข้อความผลลัพธ์ ลอยตายตัวมุมขวาล่างของจอ
## ไม่ผูกกับตำแหน่งของกระดาษเควส เลยไม่ขยับตามตอนกระดาษกาง/หุบ/ลาก

## ลากโหนด QuestPaperSmall มาใส่ตรงนี้ใน Inspector
@export var quest_paper_path: NodePath

@onready var quest_paper: QuestPaperSmall = get_node(quest_paper_path)

@onready var submit_button: Button = $SubmitButton
@onready var result_label: Label = $ResultLabel


func _ready() -> void:
	submit_button.pressed.connect(_on_submit_pressed)

	if quest_paper:
		quest_paper.verdict_changed.connect(_on_verdict_changed)

	result_label.text = ""
	visible = false


func _process(_delta: float) -> void:
	# โชว์ปุ่มเฉพาะตอนกระดาษกางออกอยู่เท่านั้น
	visible = quest_paper != null and quest_paper.state == QuestPaperSmall.State.EXPANDED


## ปั้มตราใหม่ -> เคลียร์ข้อความผลเก่าทิ้ง ให้ลองส่งใหม่ได้
func _on_verdict_changed() -> void:
	result_label.text = ""


func _on_submit_pressed() -> void:
	if quest_paper == null:
		return

	var result: Dictionary = quest_paper.submit_quest()

	result_label.text = result.text
	result_label.modulate = result.color

	# ถ้ายังไม่ได้ปั้มตราเลย ไม่ต้องรอเปลี่ยนเควสใหม่ ให้ผู้เล่นปั้มก่อน
	if quest_paper.current_verdict == "":
		return

	# กันกดส่งซ้ำระหว่างรอเอกสารใหม่
	submit_button.disabled = true

	await get_tree().create_timer(3.0).timeout

	quest_paper.reset_to_closed_with_new_quest()
	result_label.text = ""
	submit_button.disabled = false
