extends Node2D


# =========================================================
# Stamp ที่ผู้เล่นลาก
# =========================================================

@onready var stamp_a: Node2D = $StampA
@onready var stamp_d: Node2D = $StampD


# =========================================================
# Area2D ของ Stamp
# =========================================================

@onready var stamp_a_area: Area2D = $StampA/Area2D
@onready var stamp_d_area: Area2D = $StampD/Area2D


# =========================================================
# Base ของ Stamp
# =========================================================

@onready var stamp_a_base: Node2D = $StampBases/StampABase
@onready var stamp_d_base: Node2D = $StampBases/StampDBase


# =========================================================
# HitBox บนกระดาษ
# =========================================================

@onready var stamp_hitbox: Area2D = $"../QuestPaperSmall/Appr_DeniedStampHitBox"


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

	# เข้ากลุ่มไว้ให้ UI อื่น (เช่น HelpUI) หาเจอและสั่งยกเลิกการลากได้
	add_to_group("stamp_manager")

	print("Stamp Manager Ready")


# =========================================================
# ยกเลิกการลาก (เรียกจากภายนอก เช่น ตอนเปิด Help UI)
#
# ป้องกันบัค: ถ้าผู้เล่นกำลังลากตราอยู่พอดีตอนกด Help
# แล้วสถานะ dragging/mouse_was_pressed หลุด sync กัน
# ทำให้ตราค้างไม่กลับฐาน จึงบังคับดีดกลับฐานทันทีตรงนี้
# =========================================================

func cancel_drag() -> void:

	if not dragging or selected_stamp == null:
		return

	print("ยกเลิกการลาก (ถูกขัดจังหวะ) -> ดีดตรากลับฐาน")

	var stamp_to_return := selected_stamp

	dragging = false
	selected_stamp = null
	mouse_was_pressed = false

	if stamp_to_return == stamp_a:
		return_stamp_to_base(stamp_a, stamp_a_base)
	elif stamp_to_return == stamp_d:
		return_stamp_to_base(stamp_d, stamp_d_base)


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
			SfxManager.play_stamp_sfx()


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
			SfxManager.play_stamp_sfx()


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


	# ส่งให้ Paper จัดการ Stamp (verdict = approve เพื่อตรวจว่าตรากิลด์จริงหรือปลอม)
	paper.add_stamp(stamp, "approve")


	# เอฟเฟกต์ particle สี่เหลี่ยมสีเขียวตอนปั้ม Approve สำเร็จ
	Vfx.square_burst(
		get_tree().current_scene,
		stamp.global_position,
		Color(0.4, 0.9, 0.4)
	)


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


	# ส่งให้ Paper จัดการ Stamp (verdict = denied เพื่อตรวจว่าตรากิลด์จริงหรือปลอม)
	paper.add_stamp(stamp, "denied")


	# เอฟเฟกต์ particle สี่เหลี่ยมสีแดงตอนปั้ม Denied สำเร็จ
	Vfx.square_burst(
		get_tree().current_scene,
		stamp.global_position,
		Color(0.9, 0.3, 0.3)
	)


	print("Spawn Denied Stamp")


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
