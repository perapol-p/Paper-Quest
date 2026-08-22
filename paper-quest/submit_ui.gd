extends CanvasLayer

## UI ปุ่มส่งเควส + ข้อความผลลัพธ์ ลอยตายตัวมุมขวาล่างของจอ
## ไม่ผูกกับตำแหน่งของกระดาษเควส เลยไม่ขยับตามตอนกระดาษกาง/หุบ/ลาก
## ค้างโชว์อยู่ตลอดเวลาเหมือนกระดิ่งฝั่งซ้าย (เป็นพรอปประจำที่ + ปุ่มกดส่งเควสในตัวเดียวกัน)
## กระดิ่งฝั่งซ้าย (SubmitButtonLeft) เป็นปุ่มโปร่งใสซ้อนทับพรอปตกแต่งเดิม -> กดส่งเควสได้เหมือนกัน

## ลากโหนด QuestPaperSmall มาใส่ตรงนี้ใน Inspector
@export var quest_paper_path: NodePath

@onready var quest_paper: QuestPaperSmall = get_node(quest_paper_path)

@onready var submit_button: BaseButton = $SubmitButton
@onready var submit_button_left: BaseButton = $SubmitButtonLeft
@onready var result_label: Label = $ResultLabel


func _ready() -> void:
	submit_button.pressed.connect(_on_submit_pressed)
	submit_button_left.pressed.connect(_on_submit_pressed)

	if quest_paper:
		quest_paper.verdict_changed.connect(_on_verdict_changed)

	result_label.text = ""
	visible = true


## ปั้มตราใหม่ -> เคลียร์ข้อความผลเก่าทิ้ง ให้ลองส่งใหม่ได้
func _on_verdict_changed() -> void:
	result_label.text = ""


func _on_submit_pressed() -> void:
	if quest_paper == null:
		return

	# ปุ่มค้างโชว์อยู่ตลอด แต่ยังกดส่งได้จริงเฉพาะตอนกระดาษกางออกอยู่เท่านั้น
	if quest_paper.state != QuestPaperSmall.State.EXPANDED:
		return

	# วันนี้ครบจำนวนลูกค้าแล้ว ไม่ให้ส่งเควสเพิ่ม (กำลังโชว์สรุปผลอยู่)
	if DayManager.is_day_over():
		return

	var result: Dictionary = quest_paper.submit_quest()

	# ถ้ายังไม่ได้ปั้มตราเลย ให้บอกผู้เล่นก่อน (ไม่นับเป็นการส่งเควส)
	# ข้อความสีขาวเสมอ (ไม่ไล่สีตาม result.color แล้ว กันทับกระดิ่งจนอ่านไม่ออก)
	if quest_paper.current_verdict == "":
		result_label.text = result.text
		return

	# ไม่โชว์ว่าถูกหรือผิดตอนนี้ ให้ไปดูสรุปรวมตอนจบวันแทน
	result_label.text = ""

	# นับผลลูกค้าคนนี้ (ถูก/ผิด) เข้าสรุปของวัน
	if result.has("correct"):
		DayManager.register_result(result.correct)

	# กันกดส่งซ้ำระหว่างรอเอกสารใหม่
	submit_button.disabled = true
	submit_button_left.disabled = true

	await get_tree().create_timer(1.0).timeout

	# หุบกระดาษ + บัตร กลับเป็นใบเล็กพร้อมกัน (ยังไม่สุ่มข้อมูลใหม่)
	# ข้อมูลใหม่ (เควส + บัตร) จะถูกสุ่มพร้อมกันตอนลูกค้าคนใหม่เดินมาถึงโต๊ะ
	# ดู npc_manager.gd -> _on_npc_arrived()
	quest_paper.close_paper()

	var id_card = get_tree().current_scene.get_node_or_null("ObjMananger/IDcard")
	if id_card:
		id_card.close_card()

	#NPC เก่าเดินออก แล้ว NPC ใหม่จะ spawn ตามมา
	var npc_manager = get_tree().current_scene.get_node("NPCManager")
	npc_manager.finish_current_npc()
	
	result_label.text = ""
	submit_button.disabled = false
	submit_button_left.disabled = false
