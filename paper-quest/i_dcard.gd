extends Node2D


# =====================================================
# UI
# =====================================================

@onready var card_ui: Control = $CardUI

@onready var name_label: Label = $CardUI/Name
@onready var class_label: Label = $CardUI/Class
@onready var age_label: Label = $CardUI/Age
@onready var id_label: Label = $CardUI/IDNumber
@onready var rank_label: Label = $CardUI/Rank
@onready var guild_label: Label = $CardUI/GuildName
@onready var expire_label: Label = $CardUI/ExpireDate


# =====================================================
# Sprite
# =====================================================

@onready var id_card_big: Sprite2D = $IdCardBig
@onready var id_card_small: Sprite2D = $IdCardSmall


# =====================================================
# Collision
# =====================================================

@onready var collision_shape: CollisionShape2D = $CardHitBox/CollisionShape2D

var small_shape: Shape2D
var big_shape: RectangleShape2D


# =====================================================
# State
# =====================================================

enum State {
	CLOSED,
	EXPANDED
}

var state: State = State.CLOSED


# =====================================================
# ตำแหน่ง / การเปิด
# =====================================================

var screen_size: Vector2
var home_position: Vector2

## ต้องลากผ่านเปอร์เซ็นต์นี้ของหน้าจอแล้วเปิด
## 0.32 ~= ขอบซ้ายของโต๊ะจริงในฉาก
@export var open_zone_x_ratio: float = 0.32


# =====================================================
# ข้อมูลสำหรับสุ่ม
# =====================================================

var first_names = [
	"Arthur","Alden","Asher","Bran","Caleb","Cedric","Dorian","Drake",
	"Garret","Gideon","Hector","Jasper","Julian","Kaelen","Lance",
	"Logan","Lucian","Orson","Robin","Roderick","Rowan","Silas",
	"Tristan","Vance","Zephyr"
]

var last_names = [
	"Ashford","Belmont","Blackwood","Carter","Fletcher","Hawthorn",
	"Ironwood","Kingsley","Mercer","Miller","Montgomery","Oakheart",
	"Ravencrest","Redford","Silverford","Smith","Sterling",
	"Stormriver","Tanner","Vance","Weaver","Windermere",
	"Winterborne","Wright"
]

var classes = [
	"Warrior",
	"Mage",
	"Ranger",
	"Rogue",
	"Priest"
]

var ranks = [
	"F","E","D","C","B","A","S"
]

var guilds = [
	"67","SigmaBoy","RickRoll","HotDogWater"
]


# =====================================================
# ข้อมูลลูกค้าปัจจุบัน
#
# สำคัญ:
# ตัวแปรพวกนี้ต้องเป็นตัวแปรของ Node
# เพื่อให้ QuestPaperSmall สามารถอ่านข้อมูลจาก ID Card ได้
# =====================================================

var person_name: String = ""
var person_class: String = ""
var person_age: int = 0
var person_id: int = 0
var person_rank: String = ""
var person_guild: String = ""

var expire_day: int = 0
var expire_month: int = 0
var expire_year: int = 0


# =====================================================
# Ready
# =====================================================

func _ready() -> void:

	screen_size = get_viewport_rect().size
	home_position = position


	# =================================================
	# สุ่มข้อมูลลูกค้า
	# =================================================

	generate_persona()


	# =================================================
	# เก็บ Collision ของใบเล็ก
	# =================================================

	small_shape = collision_shape.shape.duplicate()


	# =================================================
	# สร้าง Collision ของใบใหญ่
	#
	# Texture จริง × Scale ของ Sprite
	# =================================================

	big_shape = RectangleShape2D.new()

	var big_size: Vector2 = (
		id_card_big.texture.get_size()
		* id_card_big.scale.abs()
	)

	big_shape.size = big_size


	# =================================================
	# เริ่มต้นเป็นใบเล็ก
	# =================================================

	_apply_closed_visual()


	# =================================================
	# ซ่อนไว้ก่อน
	# จนกว่าจะมีลูกค้ามายืนที่โต๊ะ
	# =================================================

	visible = false


	# =================================================
	# ObjManager
	# =================================================

	var manager := get_parent()

	if manager and manager.has_signal("item_released"):
		manager.item_released.connect(_on_item_released)


# =====================================================
# สุ่มข้อมูลคน
# =====================================================

func generate_persona(npc_class_from_npc: String = "") -> void:

	# =================================================
	# สุ่มข้อมูลพื้นฐาน
	# =================================================

	var first_name: String = first_names.pick_random()
	var last_name: String = last_names.pick_random()

	person_name = first_name + " " + last_name
	if npc_class_from_npc != "":
		person_class = npc_class_from_npc
	else:
		person_class = classes.pick_random()
	person_age = randi_range(18, 60)
	person_id = randi_range(100000, 999999)
	person_rank = ranks.pick_random()
	person_guild = guilds.pick_random()


	# =================================================
	# สุ่มวันที่หมดอายุ
	# =================================================

	expire_day = randi_range(1, 28)
	expire_month = randi_range(1, 12)
	expire_year = randi_range(1863, 1869)


	# =================================================
	# สร้างข้อความวันที่
	# =================================================

	var expire_date := "%02d/%02d/%d" % [
		expire_day,
		expire_month,
		expire_year
	]


	# =================================================
	# แสดงข้อมูลบน ID Card
	# =================================================

	name_label.text = "Name: " + person_name
	class_label.text = "Class: " + person_class
	age_label.text = "Age: " + str(person_age)
	id_label.text = "ID: " + str(person_id)
	rank_label.text = "Rank: " + person_rank
	guild_label.text = "Guild: " + person_guild
	expire_label.text = "Expire: " + expire_date


# =====================================================
# Reset Card
#
# เรียกเมื่อลูกค้าคนใหม่มาถึง
# =====================================================

func reset_card(npc_class_from_npc: String = "") -> void:

	generate_persona(npc_class_from_npc)

	if state == State.EXPANDED:
		_close()

	visible = true


# =====================================================
# ปิดบัตรแล้วซ่อนไปเลย
#
# ใช้ตอนส่งเควสเสร็จ
# =====================================================

func close_card() -> void:

	if state == State.EXPANDED:
		_close()

	visible = false


# =====================================================
# ตรวจสอบว่า Rank ของลูกค้าเพียงพอหรือไม่
#
# ตัวอย่าง:
#
# Quest ต้องการ B
# ลูกค้า B -> ผ่าน
# ลูกค้า A -> ผ่าน
# ลูกค้า S -> ผ่าน
# ลูกค้า C -> ไม่ผ่าน
#
# F < E < D < C < B < A < S
# =====================================================

func is_rank_sufficient(required_rank: String) -> bool:

	var rank_order := {
		"F": 0,
		"E": 1,
		"D": 2,
		"C": 3,
		"B": 4,
		"A": 5,
		"S": 6
	}

	if not rank_order.has(person_rank):
		return false

	if not rank_order.has(required_rank):
		return false

	return rank_order[person_rank] >= rank_order[required_rank]


# =====================================================
# ตรวจสอบวันหมดอายุ
#
# current_day / current_month / current_year
# คือวันที่ปัจจุบันจาก Date UI
#
# ถ้าวันปัจจุบัน <= วันหมดอายุ
# ถือว่ายังไม่หมดอายุ
# =====================================================

func is_not_expired(
	current_day: int,
	current_month: int,
	current_year: int
) -> bool:

	var current_date: int = (
		current_year * 10000
		+ current_month * 100
		+ current_day
	)

	var expire_date: int = (
		expire_year * 10000
		+ expire_month * 100
		+ expire_day
	)

	return current_date <= expire_date


# =====================================================
# ตรวจตอนปล่อย Item
# =====================================================

func _on_item_released(item: Node) -> void:

	if item != self:
		return


	# =================================================
	# ตรวจว่าลากผ่านเส้นเปิดหรือยัง
	# =================================================

	var past_line: bool = (
		global_position.x >= screen_size.x * open_zone_x_ratio
	)


	# =================================================
	# ใบเล็ก + ผ่านเส้น
	# -> เปิด
	# =================================================

	if state == State.CLOSED and past_line:

		_expand()


	# =================================================
	# ใบใหญ่ + กลับก่อนเส้น
	# -> ปิด
	# =================================================

	elif state == State.EXPANDED and not past_line:

		_close()


# =====================================================
# เปิด ID Card เป็นใบใหญ่
# =====================================================

func _expand() -> void:

	state = State.EXPANDED

	_apply_expanded_visual()
	SfxManager.play_id_slide()

	# =================================================
	# กางออกตรงจุดที่ปล่อยเมาส์
	# =================================================

	var half_size: Vector2 = big_shape.size * 0.5

	position = Vector2(
		clamp(
			position.x,
			half_size.x,
			screen_size.x - half_size.x
		),
		clamp(
			position.y,
			half_size.y,
			screen_size.y - half_size.y
		)
	)


# =====================================================
# ปิด ID Card กลับเป็นใบเล็ก
# =====================================================

func _close() -> void:

	state = State.CLOSED

	_apply_closed_visual()
	SfxManager.play_id_slide()

	# =================================================
	# กลับตำแหน่งเดิม
	# =================================================

	position = home_position


# =====================================================
# Visual ใบเล็ก
# =====================================================

func _apply_closed_visual() -> void:

	# ---------------------------------------------
	# Sprite
	# ---------------------------------------------

	id_card_small.visible = true
	id_card_big.visible = false


	# ---------------------------------------------
	# UI
	# ---------------------------------------------

	card_ui.visible = false


	# ---------------------------------------------
	# Collision
	# ---------------------------------------------

	collision_shape.shape = small_shape


# =====================================================
# Visual ใบใหญ่
# =====================================================

func _apply_expanded_visual() -> void:

	# ---------------------------------------------
	# Sprite
	# ---------------------------------------------

	id_card_small.visible = false
	id_card_big.visible = true


	# ---------------------------------------------
	# UI
	# ---------------------------------------------

	card_ui.visible = true


	# ---------------------------------------------
	# Collision
	# ---------------------------------------------

	collision_shape.shape = big_shape
