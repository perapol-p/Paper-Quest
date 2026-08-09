extends Node2D
class_name QuestPaperSmall

## กระดาษเควสใบเล็กที่วางอยู่บนโต๊ะฝั่งซ้าย
## ลากไปวางที่ "โต๊ะ" ฝั่งขวาของจอ -> จะกางออกเป็นกระดาษใบใหญ่ (Paper info) วางอยู่บนโต๊ะนั้นทันที
## ลากกระดาษใบใหญ่กลับมาฝั่งซ้าย -> จะหุบกลับเป็นใบเล็กที่ตำแหน่งเดิม (ปิด)

const PaperSmallTexture := preload("res://Assets/Picture/Items/Small/Paper_Small.png")
const PaperBigTexture := preload("res://Assets/Picture/Items/Big/Paper.png")

## ต้องลากไปเกินสัดส่วนนี้ของความกว้างจอ (0-1) ถึงจะกางออก / หุบกลับ
## 0.5 = ครึ่งจอ ตรงกับเส้นแบ่งโต๊ะฝั่งขวา
@export_range(0.0, 1.0) var open_zone_x_ratio: float = 0.5

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

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var info_panel: Control = $InfoPanel
@onready var title_label: Label = $InfoPanel/Content/VBox/TitleLabel
@onready var desc_label: Label = $InfoPanel/Content/VBox/DescLabel
@onready var target_label: Label = $InfoPanel/Content/VBox/TargetLabel
@onready var reward_label: Label = $InfoPanel/Content/VBox/RewardLabel
@onready var rank_label: Label = $InfoPanel/Content/VBox/RankLabel


func _ready() -> void:
	screen_size = get_viewport_rect().size
	home_position = position

	if quest_data == null:
		quest_data = QuestDatabase.generate_random_quest()

	small_shape.size = collision_shape.shape.size
	var big_size := PaperBigTexture.get_size() * expanded_scale
	expanded_shape.size = big_size

	_apply_closed_visual()
	_refresh_labels()

	# ObjMananger (พ่อของ item ลากได้ทุกตัว) จะยิง signal นี้ตอนปล่อยเมาส์
	var manager := get_parent()
	if manager and manager.has_signal("item_released"):
		manager.item_released.connect(_on_item_released)


## เรียกก่อน add_child เพื่อกำหนดข้อมูลเควสของใบนี้ (ถ้าไม่เรียกจะสุ่มเองตอน _ready)
func setup(data: QuestData) -> void:
	quest_data = data


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
	position = Vector2(screen_size.x * ((1.0 + open_zone_x_ratio) * 0.5), screen_size.y * 0.5)


func _close() -> void:
	state = State.CLOSED
	_apply_closed_visual()
	position = home_position


func _apply_closed_visual() -> void:
	sprite.texture = PaperSmallTexture
	sprite.scale = closed_scale
	collision_shape.shape = small_shape
	info_panel.visible = false


func _apply_expanded_visual() -> void:
	sprite.texture = PaperBigTexture
	sprite.scale = expanded_scale
	collision_shape.shape = expanded_shape
	info_panel.visible = true

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
