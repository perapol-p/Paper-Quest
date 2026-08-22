extends Node2D

signal item_released(item)

var item_being_drag
var screen_size

## z_index เดิมของสิ่งที่กำลังลากอยู่ (เก็บไว้คืนค่าตอนปล่อย)
var dragged_item_original_z: int = 0

## ยกของที่กำลังจับอยู่ขึ้นไปอยู่บนสุดของทุกอย่างเสมอ (สูงกว่ากระดาษ/บัตร/กระดิ่ง/ตราปั้มทั้งหมด)
const HELD_Z_INDEX: int = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if item_being_drag:
		var mouse_pos = get_global_mouse_position()
		item_being_drag.position = Vector2(clamp(mouse_pos.x,0,screen_size.x),clamp(mouse_pos.y,0,screen_size.y))



func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var item = raycast_check_item()
			if item:
				item_being_drag = item
				# กำลังจับอยู่ -> ยกขึ้นบนสุด บังทุกอย่างที่ขวางอยู่
				dragged_item_original_z = item.z_index
				item.z_index = HELD_Z_INDEX
			#Raycast check for item
		else:
			if item_being_drag:
				# ปล่อยแล้ว -> คืนระดับ z_index เดิมก่อนจับ
				item_being_drag.z_index = dragged_item_original_z
				item_released.emit(item_being_drag)
			item_being_drag = null

func raycast_check_item():
	var space_state = get_world_2d().direct_space_state
	var mouse_pos = get_global_mouse_position()

	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = mouse_pos
	parameters.collide_with_areas = true
	parameters.collision_mask = 1
	# เอาผลลัพธ์มาให้หมด (ไม่ตัดที่ 32 อันแรกเวลาฮิตบอคซ้อนกันเยอะ)
	parameters.collide_with_bodies = false

	var result = space_state.intersect_point(parameters, 32)

	if result.size() == 0:
		return null

	if result.size() == 1:
		return result[0].collider.get_parent()

	# =====================================================
	# ฮิตบอคหลายชิ้นซ้อนทับกันตรงจุดนี้
	# -> เลือกชิ้นที่ "ตำแหน่งจริง" (global_position) ใกล้เมาส์ที่สุด
	#    แทนที่จะสุ่มเอาชิ้นแรกที่ physics engine คืนมา
	# =====================================================

	var best_item = null
	var best_dist := INF

	for r in result:
		var item = r.collider.get_parent()
		if item == null:
			continue

		var dist: float = item.global_position.distance_squared_to(mouse_pos)

		if dist < best_dist:
			best_dist = dist
			best_item = item

	if best_item:
		print(best_item)

	return best_item
