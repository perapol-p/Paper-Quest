extends Node2D


# =========================================================
# Stamp ที่ผู้เล่นลาก
# =========================================================

@onready var stamp_a: Node2D = $StampA
@onready var stamp_d: Node2D = $StampD
@onready var stamp_guild: Node2D = $StampG


# =========================================================
# Area2D ของ Stamp
# =========================================================

@onready var stamp_a_area: Area2D = $StampA/Area2D
@onready var stamp_d_area: Area2D = $StampD/Area2D
@onready var stamp_guild_area: Area2D = $StampG/Area2D


# =========================================================
# Base ของ Stamp
# =========================================================

@onready var stamp_a_base: Node2D = $StampBases/StampABase
@onready var stamp_d_base: Node2D = $StampBases/StampDBase
@onready var stamp_guild_base: Node2D = $StampBases/StampGBase


# =========================================================
# HitBox บนกระดาษ
# =========================================================

@onready var stamp_hitbox: Area2D = $"../QuestPaperSmall/Appr_DeniedStampHitBox"

@onready var guild_stamp_hitbox: Area2D = $"../QuestPaperSmall/GuildStampHitBox"


# =========================================================
# ตัวแปรสำหรับการลาก
# =========================================================

var selected_stamp: Node2D = null

var dragging := false

# ใช้ตรวจว่าคลิกซ้ายรอบก่อนหน้าถูกกดอยู่หรือไม่
var mouse_was_pressed := false


# =========================================================
# Ready
# =========================================================

func _ready() -> void:

	# รับ Event จาก Stamp
	stamp_a_area.input_event.connect(_on_stamp_a_input)
	stamp_d_area.input_event.connect(_on_stamp_d_input)
	stamp_guild_area.input_event.connect(_on_stamp_guild_input)

	print("Stamp Manager Ready")


# =========================================================
# Stamp A Input
# =========================================================
#
# คลิกซ้าย  = ลาก
# คลิกขวา   = ปั้ม
# =========================================================

func _on_stamp_a_input(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:

	if not event is InputEventMouseButton:
		return


	# =====================================================
	# คลิกซ้าย = เริ่มลาก
	# =====================================================

	if event.button_index == MOUSE_BUTTON_LEFT:

		if event.pressed:

			selected_stamp = stamp_a

			dragging = true

			mouse_was_pressed = true

			print("เริ่มลาก Approve")


	# =====================================================
	# คลิกขวา = ปั้ม
	# =====================================================

	elif event.button_index == MOUSE_BUTTON_RIGHT:

		if event.pressed:

			print("คลิกขวา Approve")

			stamp_a_pressed()


# =========================================================
# Stamp D Input
# =========================================================
#
# คลิกซ้าย  = ลาก
# คลิกขวา   = ปั้ม
# =========================================================

func _on_stamp_d_input(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:

	if not event is InputEventMouseButton:
		return


	# =====================================================
	# คลิกซ้าย = เริ่มลาก
	# =====================================================

	if event.button_index == MOUSE_BUTTON_LEFT:

		if event.pressed:

			selected_stamp = stamp_d

			dragging = true

			mouse_was_pressed = true

			print("เริ่มลาก Denied")


	# =====================================================
	# คลิกขวา = ปั้ม
	# =====================================================

	elif event.button_index == MOUSE_BUTTON_RIGHT:

		if event.pressed:

			print("คลิกขวา Denied")

			stamp_d_pressed()


# =========================================================
# Stamp Guild Input
# =========================================================
#
# คลิกซ้าย  = ลาก
# คลิกขวา   = ปั้ม
# =========================================================

func _on_stamp_guild_input(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:

	if not event is InputEventMouseButton:
		return


	# =====================================================
	# คลิกซ้าย = เริ่มลาก
	# =====================================================

	if event.button_index == MOUSE_BUTTON_LEFT:

		if event.pressed:

			selected_stamp = stamp_guild

			dragging = true

			mouse_was_pressed = true

			print("เริ่มลาก Guild")


	# =====================================================
	# คลิกขวา = ปั้ม
	# =====================================================

	elif event.button_index == MOUSE_BUTTON_RIGHT:

		if event.pressed:

			print("คลิกขวา Guild")

			stamp_guild_pressed()


# =========================================================
# Process
# =========================================================

func _process(_delta: float) -> void:

	# =====================================================
	# กำลังลากด้วยคลิกซ้าย
	# =====================================================

	if dragging and selected_stamp != null:

		# ---------------------------------------------
		# ให้ Stamp ตามตำแหน่งเมาส์
		# ---------------------------------------------

		selected_stamp.global_position = get_global_mouse_position()


		# ---------------------------------------------
		# ตรวจว่าคลิกซ้ายยังถูกกดอยู่หรือไม่
		# ---------------------------------------------

		var mouse_pressed := Input.is_mouse_button_pressed(
			MOUSE_BUTTON_LEFT
		)


		# =================================================
		# จาก "กดซ้ายอยู่" → "ปล่อยซ้าย"
		# =================================================

		if mouse_was_pressed and not mouse_pressed:

			print("ปล่อย Stamp")


			# จำ Stamp ที่ปล่อย
			var released_stamp := selected_stamp


			# หยุดลาก
			dragging = false


			# =================================================
			# กลับ Base
			#
			# สำคัญ:
			# ตรงนี้ไม่เรียก check_stamp_position()
			#
			# เพราะการลากด้วยซ้ายไม่ใช่การปั้ม
			# =================================================

			if released_stamp == stamp_a:

				return_stamp_to_base(
					stamp_a,
					stamp_a_base
				)

			elif released_stamp == stamp_d:

				return_stamp_to_base(
					stamp_d,
					stamp_d_base
				)

			elif released_stamp == stamp_guild:

				return_stamp_to_base(
					stamp_guild,
					stamp_guild_base
				)


			# ล้างตัวที่เลือก
			selected_stamp = null


		# จำสถานะคลิกซ้าย
		mouse_was_pressed = mouse_pressed


	# =====================================================
	# ไม่ได้ลาก
	# =====================================================

	else:

		mouse_was_pressed = Input.is_mouse_button_pressed(
			MOUSE_BUTTON_LEFT
		)


# =========================================================
# =========================================================
# ระบบปั้ม Stamp
# =========================================================
# =========================================================


# =========================================================
# กดขวา Approve
# =========================================================

func stamp_a_pressed() -> void:

	# ตรวจว่า Stamp อยู่ตรง HitBox หรือไม่

	if stamp_a_area.overlaps_area(stamp_hitbox):

		print("Approve ถูกตำแหน่ง")

		spawn_approve_stamp()

	else:

		print("Approve ไม่ได้อยู่ตรง HitBox")


# =========================================================
# กดขวา Denied
# =========================================================

func stamp_d_pressed() -> void:

	# ตรวจว่า Stamp อยู่ตรง HitBox หรือไม่

	if stamp_d_area.overlaps_area(stamp_hitbox):

		print("Denied ถูกตำแหน่ง")

		spawn_denied_stamp()

	else:

		print("Denied ไม่ได้อยู่ตรง HitBox")


# =========================================================
# กดขวา Guild
# =========================================================

func stamp_guild_pressed() -> void:

	# ตรวจว่า Stamp อยู่ตรง Guild HitBox หรือไม่

	if stamp_guild_area.overlaps_area(guild_stamp_hitbox):

		print("Guild ถูกตำแหน่ง")

		spawn_guild_stamp()

	else:

		print("Guild ไม่ได้อยู่ตรง HitBox")


# =========================================================
# Spawn APPROVE
# =========================================================

func spawn_approve_stamp() -> void:

	var stamp := Sprite2D.new()


	stamp.texture = preload(
		"res://Assets/Picture/Items/Stamp/Approve.png"
	)


	var paper := $"../QuestPaperSmall"


	paper.add_child(stamp)


	# ตำแหน่งที่ปั้ม
	stamp.global_position = stamp_a.global_position


	# ส่งให้ Paper จัดการ Stamp
	paper.add_stamp(stamp)


	print("Spawn Approve Stamp")


# =========================================================
# Spawn DENIED
# =========================================================

func spawn_denied_stamp() -> void:

	var stamp := Sprite2D.new()


	stamp.texture = preload(
		"res://Assets/Picture/Items/Stamp/Denied.png"
	)


	var paper := $"../QuestPaperSmall"


	paper.add_child(stamp)


	# ตำแหน่งที่ปั้ม
	stamp.global_position = stamp_d.global_position


	# ส่งให้ Paper จัดการ Stamp
	paper.add_stamp(stamp)


	print("Spawn Denied Stamp")


# =========================================================
# Spawn GUILD
# =========================================================

func spawn_guild_stamp() -> void:

	var stamp := Sprite2D.new()


	stamp.texture = preload(
		"res://Assets/Picture/Items/Stamp/Guild.png"
	)


	var paper := $"../QuestPaperSmall"


	paper.add_child(stamp)


	# ตำแหน่งที่ปั้ม
	stamp.global_position = stamp_guild.global_position


	# ส่งให้ Paper จัดการ Stamp
	paper.add_stamp(stamp)


	print("Spawn Guild Stamp")


# =========================================================
# ลอยกลับ Base
# =========================================================

func return_stamp_to_base(
	stamp: Node2D,
	base: Node2D
) -> void:

	var tween := create_tween()


	tween.set_trans(
		Tween.TRANS_QUAD
	)


	tween.set_ease(
		Tween.EASE_OUT
	)


	tween.tween_property(
		stamp,
		"global_position",
		base.global_position,
		0.35
	)
