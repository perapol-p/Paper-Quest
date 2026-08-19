extends Node2D
class_name QuestPaperSmall

## กระดาษเควสใบเล็กที่วางอยู่บนโต๊ะฝั่งซ้าย
## ลากไปวางที่ "โต๊ะ" ฝั่งขวาของจอ -> จะกางออกเป็นกระดาษใบใหญ่ (Paper info) วางอยู่บนโต๊ะนั้นทันที
## ลากกระดาษใบใหญ่กลับมาฝั่งซ้าย -> จะหุบกลับเป็นใบเล็กที่ตำแหน่งเดิม (ปิด)

const PaperSmallTexture := preload("res://Assets/Picture/Items/Small/Paper_Small.png")
const PaperBigTexture := preload("res://Assets/Picture/Items/Big/Paper.png")

## ตรากิลด์ของจริง
const GuildRealTexture := preload("res://Assets/Picture/Items/Stamp/Guild.png")

## ตรากิลด์ปลอม (สุ่มเลือก 1 จากรายการนี้เวลาที่ is_guild_authentic == false)
const GuildFakeTextures: Array[Texture2D] = [
	preload("res://Assets/Export/Items/Stamp/WGuild1.png"),
	preload("res://Assets/Export/Items/Stamp/WGuild2.png"),
]

## ต้องลากไปเกินสัดส่วนนี้ของความกว้างจอ (0-1) ถึงจะกางออก / หุบกลับ
## 0.32 ~= ขอบซ้ายของโต๊ะจริงในฉาก แค่ลากไปแตะขอบโต๊ะก็เปิดเลย
@export_range(0.0, 1.0) var open_zone_x_ratio: float = 0.32

## ขนาด sprite ตอนหุบ (ใบเล็ก) และตอนกางออก (ใบใหญ่)
@export var closed_scale: Vector2 = Vector2(2.5, 2.5)
@export var expanded_scale: Vector2 = Vector2(1.6, 1.6)

## ระยะขอบของกล่องข้อความ เทียบกับขนาด sprite ตอนกางออก (พิกเซล)
@export var expanded_content_margin: float = 24.0

enum State { CLOSED, EXPANDED }

var quest_data: QuestData
var screen_size: Vector2
var state: State = State.CLOSED
var home_position: Vector2

var small_shape := RectangleShape2D.new()
var expanded_shape := RectangleShape2D.new()

var stamps: Array[Sprite2D] = []

## ตราปั้ม Approve/Denied ที่ปั้มไว้ล่าสุด (มีได้แค่อันเดียวบนกระดาษ)
var current_result_stamp: Sprite2D = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var info_panel: Control = $InfoPanel
@onready var title_label: Label = $InfoPanel/Content/VBox/TitleLabel
@onready var desc_label: Label = $InfoPanel/Content/VBox/DescLabel
@onready var target_label: Label = $InfoPanel/Content/VBox/TargetLabel
@onready var reward_label: Label = $InfoPanel/Content/VBox/RewardLabel
@onready var rank_label: Label = $InfoPanel/Content/VBox/RankLabel

@onready var stamp_hitbox: Area2D = $Appr_DeniedStampHitBox
@onready var guild_stamp_hitbox: Area2D = $GuildStampHitBox

## ตรากิลด์ที่แปะติดอยู่บนกระดาษเควสอยู่แล้วตั้งแต่แรก ไม่ต้องปั้มเอง
@onready var guild_stamp_visual: Sprite2D = $GuildStampHitBox/GuildStampVisual

## verdict ล่าสุดที่ผู้เล่นปั้ม ("" = ยังไม่ได้ปั้ม, "approve" หรือ "denied")
var current_verdict: String = ""

## ยิงทุกครั้งที่ผู้เล่นปั้มตราใหม่ (ให้ UI ปุ่มส่งเควสรู้ว่าต้องเคลียร์ข้อความผลเก่า)
signal verdict_changed

func _ready() -> void:
	screen_size = get_viewport_rect().size
	home_position = position


	if quest_data == null:
		quest_data = QuestDatabase.generate_random_quest()

	_apply_guild_stamp()

	small_shape.size = collision_shape.shape.size
	var big_size := PaperBigTexture.get_size() * expanded_scale
	expanded_shape.size = big_size

	_apply_closed_visual()
	_refresh_labels()

	# ซ่อนไว้ก่อน จนกว่าจะมีลูกค้ามายืนที่โต๊ะ
	# (ดู npc_manager.gd -> _on_npc_arrived)
	visible = false

	# ObjMananger (พ่อของ item ลากได้ทุกตัว) จะยิง signal นี้ตอนปล่อยเมาส์
	var manager := get_parent()
	if manager and manager.has_signal("item_released"):
		manager.item_released.connect(_on_item_released)


## เรียกก่อน add_child เพื่อกำหนดข้อมูลเควสของใบนี้ (ถ้าไม่เรียกจะสุ่มเองตอน _ready)
func setup(data: QuestData) -> void:
	quest_data = data


## แปะรูปตรากิลด์ตามค่า quest_data.is_guild_authentic
## true  -> ตราจริง (Guild.png)
## false -> ตราปลอม (สุ่ม 1 แบบจาก GuildFakeTextures)
func _apply_guild_stamp() -> void:
	if quest_data == null:
		return

	if quest_data.is_guild_authentic:
		guild_stamp_visual.texture = GuildRealTexture
	else:
		var fake_index := randi() % GuildFakeTextures.size()
		guild_stamp_visual.texture = GuildFakeTextures[fake_index]


func _on_item_released(item: Node) -> void:
	if item != self:
		return

	var past_line: bool = global_position.x >= screen_size.x * open_zone_x_ratio

	if state == State.CLOSED and past_line:
		_expand()
	elif state == State.EXPANDED and not past_line:
		_close()


func _expand() -> void:
	state = State.EXPANDED
	_apply_expanded_visual()
	_refresh_labels()

	# กางออกตรงจุดที่ปล่อยเมาส์เลย (position ปัจจุบันคือจุดที่ลากมาปล่อย)
	# กันไม่ให้ใบใหญ่ล้นขอบจอ ถ้าปล่อยใกล้ขอบเกินไป
	var half_size: Vector2 = expanded_shape.size * 0.5
	position = Vector2(
		clamp(position.x, half_size.x, screen_size.x - half_size.x),
		clamp(position.y, half_size.y, screen_size.y - half_size.y)
	)


func _close() -> void:
	state = State.CLOSED
	_apply_closed_visual()
	position = home_position


func _apply_closed_visual() -> void:
	sprite.texture = PaperSmallTexture
	sprite.scale = closed_scale
	collision_shape.shape = small_shape
	info_panel.visible = false

	guild_stamp_visual.visible = false

	for stamp in stamps:
		stamp.visible = false


func _apply_expanded_visual() -> void:
	sprite.texture = PaperBigTexture
	sprite.scale = expanded_scale
	collision_shape.shape = expanded_shape
	info_panel.visible = true

	guild_stamp_visual.visible = true

	for stamp in stamps:
		stamp.visible = true

	var half_size: Vector2 = PaperBigTexture.get_size() * expanded_scale * 0.5
	var margin: float = expanded_content_margin

	info_panel.position = -half_size + Vector2(margin, margin)
	info_panel.size = half_size * 2.0 - Vector2(margin, margin) * 2.0



func _refresh_labels() -> void:
	if quest_data == null:
		return
	title_label.text = quest_data.title
	desc_label.text = quest_data.description
	target_label.text = "เป้าหมาย: %s   x%d" % [quest_data.target_name, quest_data.target_count]
	reward_label.text = "รางวัล: %d Gold" % quest_data.reward_gold
	rank_label.text = "Rank %s | %s | %s" % [quest_data.quest_rank, quest_data.category_text, quest_data.rank_text]


#Stamp
## verdict: "approve" หรือ "denied" -> เก็บไว้ตัดสินตอนกดปุ่ม "ส่งเควส"
func add_stamp(stamp: Sprite2D, verdict: String = "") -> void:

	# =====================================================
	# ปั้มได้แค่อันเดียว ถ้ามีตราเก่าอยู่ ให้ลบทิ้งก่อน
	# แล้วค่อยแปะตราใหม่แทนที่
	# =====================================================

	if current_result_stamp != null and is_instance_valid(current_result_stamp):
		stamps.erase(current_result_stamp)
		current_result_stamp.queue_free()

	current_result_stamp = stamp

	stamps.append(stamp)

	if state == State.CLOSED:
		stamp.visible = false
	else:
		stamp.visible = true

	if verdict != "":
		current_verdict = verdict
		verdict_changed.emit()


## เรียกจากปุ่ม "ส่งเควส" (อยู่นอกกระดาษ มุมขวาล่างของจอ)
## คืนค่า Dictionary {text: String, color: Color} ให้ UI เอาไปโชว์
func submit_quest() -> Dictionary:

	if quest_data == null:
		return {"text": "", "color": Color.WHITE}

	# ยังไม่ได้ปั้มตรา Approve/Denied เลย
	if current_verdict == "":
		return {
			"text": "Stamp It First!",
			"color": Color(0.541, 0.157, 0.145),
		}

	var should_approve: bool = quest_data.is_guild_authentic
	var player_approved: bool = current_verdict == "approve"
	var correct: bool = player_approved == should_approve

	if correct:
		return {
			"text": "Success!",
			"color": Color(0.15, 0.5, 0.15),
			"correct": true,
		}
	else:
		return {
			"text": "Failure!",
			"color": Color(0.7, 0.1, 0.1),
			"correct": false,
		}


## เปลี่ยนเป็นเควสใหม่บนกระดาษใบเดิม (สุ่ม quest_data + ตรากิลด์ใหม่ทั้งหมด)
## เรียกจาก SubmitUI หลังรอ 3 วินาทีนับจากกดส่งเควส
func load_new_quest() -> void:

	quest_data = QuestDatabase.generate_random_quest()
	current_verdict = ""

	# ลบตรา Approve/Denied เก่าที่เคยปั้มไว้ทิ้ง
	if current_result_stamp != null and is_instance_valid(current_result_stamp):
		stamps.erase(current_result_stamp)
		current_result_stamp.queue_free()
		current_result_stamp = null

	_apply_guild_stamp()
	_refresh_labels()


## เหมือน load_new_quest() แต่หุบกระดาษกลับเป็นใบเล็กที่ตำแหน่งเดิมด้วย
## ใช้ตอนลูกค้าคนใหม่เดินมาถึงโต๊ะแล้ว (ดู npc_manager.gd -> _on_npc_arrived)
func reset_to_closed_with_new_quest() -> void:
	load_new_quest()
	_close()
	# มีเควสใหม่แล้ว -> โชว์กระดาษบนโต๊ะ
	visible = true


## หุบกระดาษกลับแล้วซ่อนไปเลย ไม่สุ่มเควสใหม่
## ใช้ตอนส่งเควสเสร็จ (ลูกค้าเก่ายังเดินออกไม่ถึง ยังไม่ต้องสุ่มข้อมูลใหม่)
func close_paper() -> void:
	_close()
	visible = false
