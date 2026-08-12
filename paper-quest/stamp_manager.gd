extends Node2D


# =========================
# Stamp ที่ผู้เล่นลาก
# =========================

@onready var stamp_a: Node2D = $StampA
@onready var stamp_d: Node2D = $StampD

@onready var stamp_a_area: Area2D = $StampA/Area2D
@onready var stamp_d_area: Area2D = $StampD/Area2D



# =========================
# จุดที่ต้องวางตรา
# =========================

@onready var stamp_hitbox: Area2D = $"../QuestPaperSmall/StampHitBox"


# =========================
# ตัวแปร
# =========================

var selected_stamp: Node2D = null
var dragging := false
var stamp_in_position := false

var original_position_a: Vector2
var original_position_d: Vector2


func _ready() -> void:

	# จำตำแหน่งเดิม
	original_position_a = stamp_a.global_position
	original_position_d = stamp_d.global_position

	# รับการคลิกของ StampA / StampD
	stamp_a_area.input_event.connect(_on_stamp_a_input)
	stamp_d_area.input_event.connect(_on_stamp_d_input)
	print($"../QuestPaperSmall/StampHitBox")

# =========================================================
# Stamp A
# =========================================================

func _on_stamp_a_input(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_RIGHT:

			if event.pressed:

				selected_stamp = stamp_a
				dragging = true

				print("เริ่มลาก Approve")


			else:

				dragging = false

				check_stamp_position()


# =========================================================
# Stamp D
# =========================================================

func _on_stamp_d_input(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_RIGHT:

			if event.pressed:

				selected_stamp = stamp_d
				dragging = true

				print("เริ่มลาก Denied")


			else:

				dragging = false

				check_stamp_position()


# =========================================================
# ลาก Stamp ตามเมาส์
# =========================================================

func _process(_delta: float) -> void:

	if dragging and selected_stamp != null:

		selected_stamp.global_position = get_global_mouse_position()


# =========================================================
# ตรวจว่า Stamp อยู่ตรง HitBox หรือไม่
# =========================================================

func check_stamp_position() -> void:
	if selected_stamp == null:
		return

	var stamp_area: Area2D

	if selected_stamp == stamp_a:
		stamp_area = stamp_a_area

	elif selected_stamp == stamp_d:
		stamp_area = stamp_d_area

	else:
		return

	if stamp_area.overlaps_area(stamp_hitbox):

		stamp_in_position = true

		print("วางตราตรง HitBox แล้ว")

		if selected_stamp == stamp_a:
			spawn_approve_stamp()

		elif selected_stamp == stamp_d:
			spawn_denied_stamp()

	else:

		stamp_in_position = false

		print("วางตราไม่ตรง HitBox")

		if selected_stamp == stamp_a:
			stamp_a.global_position = original_position_a

		elif selected_stamp == stamp_d:
			stamp_d.global_position = original_position_d



# =========================================================
# Spawn รอยตรา APPROVE ลงกระดาษ
# =========================================================

func spawn_approve_stamp() -> void:
	var stamp := Sprite2D.new()

	stamp.texture = preload(
		"res://Assets/Picture/Items/Stamp/Approve.png"
	)

	var paper := $"../QuestPaperSmall"

	paper.add_child(stamp)

	stamp.global_position = stamp_a.global_position

	paper.add_stamp(stamp)

	print("Spawn Approve Stamp")


# =========================================================
# Spawn รอยตรา DENIED ลงกระดาษ
# =========================================================

func spawn_denied_stamp() -> void:
	var stamp := Sprite2D.new()

	stamp.texture = preload(
		"res://Assets/Picture/Items/Stamp/Denied.png"
	)

	var paper := $"../QuestPaperSmall"

	paper.add_child(stamp)

	stamp.global_position = stamp_d.global_position

	paper.add_stamp(stamp)

	print("Spawn Denied Stamp")
