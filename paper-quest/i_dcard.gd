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
# ค่าถ่วงน้ำหนักความสุ่ม (แก้ปัญหา "ผิดเยอะกว่าถูก")
#
# ปัญหาเดิม: เกมมี 3 จุดตรวจ (Rank / วันหมดอายุ / ตรากิลด์)
# ที่สุ่ม "แยกกันเอง" แบบไม่รู้จักกัน (independent random)
# ทำให้โอกาสที่ทุกจุดจะ "ถูกต้องครบ" (ควร Approve) ต่ำมาก
# เพราะต้องคูณความน่าจะเป็นของทั้ง 3 จุดเข้าด้วยกัน
# เช่นเดิม Rank พอ ~50%, วันหมดอายุยังไม่หมด ~50%, ตราแท้ 70%
# -> โอกาส Approve จริง ๆ เหลือแค่ ~17.5% ที่เหลือคือ Denied ล้วน ๆ
# ผลคือผู้เล่นเจอเคส "ต้อง Denied" ถี่กว่า "ต้อง Approve" มาก
# และรู้สึกว่าทำไมกดไปกด Approve บ่อย ๆ แล้วผิดตลอด
#
# วิธีแก้: ยังคงสุ่มอยู่ (ไม่ fix ตายตัว) แต่ "ถ่วงน้ำหนัก" แต่ละจุดตรวจ
# ให้เอนไปทาง "ถูกต้อง" (ควร Approve) มากกว่าเดิม โดยตั้งเป้าไว้ที่จุดละ ~80%
# เมื่อคูณกันทั้ง 3 จุด (0.8 * 0.8 * 0.8 ≈ 51%) จะทำให้เคส Approve
# มีสัดส่วนมากกว่าเคส Denied เล็กน้อย เกมจะรู้สึก "ถูกมากกว่าผิด" ตามที่ต้องการ
# แต่ยังคงมีเคส Denied ปนอยู่พอสมควรให้ต้องตรวจสอบจริง ไม่ใช่กด Approve มั่ว ๆ ได้ทุกที
#
# ปรับค่าพวกนี้ได้อิสระ (0.0 - 1.0) เพื่อคุมความยาก/ความเป็นธรรมของเกม
# =====================================================

## โอกาสที่ Rank ของลูกค้าจะ "พอ" กับเควสที่ต้องทำ (rank_order[person_rank] >= rank_order[required_rank])
const RANK_SUFFICIENT_CHANCE: float = 0.8

## โอกาสที่บัตรจะ "ยังไม่หมดอายุ" เทียบกับวันที่ปัจจุบันในเกม
const EXPIRE_VALID_CHANCE: float = 0.8

const RANK_ORDER := {
	"F": 0, "E": 1, "D": 2, "C": 3, "B": 4, "A": 5, "S": 6
}


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

func generate_persona(npc_class_from_npc: String = "", required_rank: String = "") -> void:

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
	person_rank = _pick_person_rank(required_rank)
	person_guild = guilds.pick_random()


	# =================================================
	# สุ่มวันที่หมดอายุ (ถ่วงน้ำหนักด้วย EXPIRE_VALID_CHANCE)
	# =================================================

	var should_be_valid: bool = randf() < EXPIRE_VALID_CHANCE
	_generate_expire_date(should_be_valid)


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
# สุ่ม Rank ของลูกค้า โดยถ่วงน้ำหนักด้วย RANK_SUFFICIENT_CHANCE
# ให้เอนไปทาง "พอ" กับ required_rank บ่อยกว่า "ไม่พอ"
#
# ถ้าไม่ได้ส่ง required_rank มา (หรือค่าไม่ถูกต้อง) จะสุ่มแบบเดิม (uniform)
# =====================================================

func _pick_person_rank(required_rank: String) -> String:

	if not RANK_ORDER.has(required_rank):
		return ranks.pick_random()

	var req_idx: int = RANK_ORDER[required_rank]

	var sufficient_ranks: Array = []
	var insufficient_ranks: Array = []

	for r in ranks:
		if RANK_ORDER[r] >= req_idx:
			sufficient_ranks.append(r)
		else:
			insufficient_ranks.append(r)

	var want_sufficient: bool = randf() < RANK_SUFFICIENT_CHANCE

	if want_sufficient and sufficient_ranks.size() > 0:
		return sufficient_ranks.pick_random()

	if not want_sufficient and insufficient_ranks.size() > 0:
		return insufficient_ranks.pick_random()

	# กรณี fallback (เช่น required_rank = "F" จะไม่มี rank ที่ "ไม่พอ" เลย)
	# ก็ปล่อยให้ได้ rank ที่พอไปเลย ยังนับเป็นเคสถูกต้องอยู่ดี
	if sufficient_ranks.size() > 0:
		return sufficient_ranks.pick_random()

	return ranks.pick_random()


# =====================================================
# สุ่มวันหมดอายุ โดยถ่วงน้ำหนักว่าจะ "ยังไม่หมดอายุ" (valid)
# หรือ "หมดอายุแล้ว" (invalid) เทียบกับวันปัจจุบันในเกม (DayManager)
# =====================================================

func _generate_expire_date(valid: bool) -> void:

	var cur_day: int = DayManager.date_day
	var cur_month: int = DayManager.date_month
	var cur_year: int = DayManager.date_year

	if valid:
		# สุ่มปีตั้งแต่ปีปัจจุบัน ถึงปีปัจจุบัน + 3 ปี (รับประกันไม่หมดอายุ)
		expire_year = randi_range(cur_year, cur_year + 3)

		if expire_year == cur_year:
			expire_month = randi_range(cur_month, 12)
			if expire_month == cur_month:
				expire_day = randi_range(cur_day, 28)
			else:
				expire_day = randi_range(1, 28)
		else:
			expire_month = randi_range(1, 12)
			expire_day = randi_range(1, 28)
	else:
		# สุ่มปีตั้งแต่ปีปัจจุบัน - 3 ปี ถึงปีปัจจุบัน (รับประกันหมดอายุแล้ว)
		expire_year = randi_range(cur_year - 3, cur_year)

		if expire_year == cur_year:
			expire_month = randi_range(1, cur_month)
			if expire_month == cur_month:
				# กันกรณี cur_day == 1 จะไม่มีวันที่ "น้อยกว่า" เหลือ
				expire_day = randi_range(1, max(cur_day - 1, 1))
			else:
				expire_day = randi_range(1, 28)
		else:
			expire_month = randi_range(1, 12)
			expire_day = randi_range(1, 28)


# =====================================================
# Reset Card
#
# เรียกเมื่อลูกค้าคนใหม่มาถึง
# =====================================================

func reset_card(npc_class_from_npc: String = "", required_rank: String = "") -> void:

	generate_persona(npc_class_from_npc, required_rank)

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
