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

## ลากผ่านเปอร์เซ็นต์นี้ของหน้าจอแล้วเปิด
@export var open_zone_x_ratio: float = 0.55


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
# Ready
# =====================================================

func _ready() -> void:

	screen_size = get_viewport_rect().size
	home_position = position


	# =================================================
	# สุ่มข้อมูล
	# =================================================

	generate_persona()


	# =================================================
	# เก็บ Collision ของใบเล็ก
	# =================================================

	small_shape = collision_shape.shape.duplicate()


	# =================================================
	# สร้าง Collision ของใบใหญ่
	#
	# ใช้ขนาด Texture จริง × Scale ของ Sprite
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
	# ObjManager
	# =================================================

	var manager := get_parent()

	if manager and manager.has_signal("item_released"):
		manager.item_released.connect(_on_item_released)


# =====================================================
# สุ่มข้อมูลคน
# =====================================================

func generate_persona() -> void:

	var first_name = first_names.pick_random()
	var last_name = last_names.pick_random()

	var person_name = first_name + " " + last_name
	var person_class = classes.pick_random()
	var person_age = randi_range(18, 60)
	var person_id = randi_range(100000, 999999)
	var person_rank = ranks.pick_random()
	var person_guild = guilds.pick_random()


	# =================================================
	# สุ่มวันที่หมดอายุ
	# =================================================

	var expire_day = randi_range(1, 28)
	var expire_month = randi_range(1, 12)
	var expire_year = randi_range(2026, 2030)

	var expire_date = "%02d/%02d/%d" % [
		expire_day,
		expire_month,
		expire_year
	]


	# =================================================
	# แสดงข้อมูล
	# =================================================

	name_label.text = "Name: " + person_name
	class_label.text = "Class: " + person_class
	age_label.text = "Age: " + str(person_age)
	id_label.text = "ID: " + str(person_id)
	rank_label.text = "Rank: " + person_rank
	guild_label.text = "Guild: " + person_guild
	expire_label.text = "Expire: " + expire_date


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


	# =================================================
	# ย้ายไปตำแหน่งฝั่งขวา
	# เหมือน Quest Paper
	# =================================================

	position = Vector2(
		screen_size.x * ((1.0 + open_zone_x_ratio) * 0.5),
		screen_size.y * 0.5
	)


# =====================================================
# ปิด ID Card กลับเป็นใบเล็ก
# =====================================================

func _close() -> void:

	state = State.CLOSED

	_apply_closed_visual()


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
	# ใช้ขนาดเดียวกับ Sprite ใหญ่
	# หลังคำนวณ Texture × Scale
	# ---------------------------------------------

	collision_shape.shape = big_shape
