class_name Vfx
extends RefCounted

## เอฟเฟกต์ particle แบบสี่เหลี่ยมจัตุรัสล้วนๆ (ไม่ใช้รูปภาพ)
## เรียกใช้จากที่ไหนก็ได้ เช่น: Vfx.square_burst(get_tree().current_scene, global_position, Color.GREEN)

static func square_burst(
	parent: Node,
	global_pos: Vector2,
	color: Color,
	amount: int = 18,
	speed: float = 130.0,
	lifetime: float = 0.7,
	square_size: float = 7.0
) -> void:

	var p := CPUParticles2D.new()
	parent.add_child(p)

	p.global_position = global_pos
	p.z_index = 100

	# ไม่ใส่ texture -> Godot จะวาด particle เป็นสี่เหลี่ยมจัตุรัสธรรมดา
	p.texture = null

	p.emitting = false
	p.one_shot = true
	p.amount = amount
	p.lifetime = lifetime
	p.explosiveness = 0.9
	p.randomness = 0.5
	p.speed_scale = 1.0

	p.direction = Vector2.UP
	p.spread = 180.0

	p.initial_velocity_min = speed * 0.35
	p.initial_velocity_max = speed

	# หน่วงความเร็วลงเรื่อยๆ แทนที่จะพุ่งตรงแข็งๆ ทำให้ดูพริ้วช้าลงตอนท้าย
	p.damping_min = 60.0
	p.damping_max = 140.0

	# แรงโน้มถ่วงเบาๆ พอให้ร่วงลงตามธรรมชาติ ไม่ดิ่งแรง
	p.gravity = Vector2(0, 90)

	# หมุนตัวไปมาระหว่างลอย + แกว่งเป็นวงเล็กๆ (ทำให้ดูพริ้วไม่แข็ง)
	p.angle_min = 0.0
	p.angle_max = 360.0
	p.angular_velocity_min = -260.0
	p.angular_velocity_max = 260.0
	p.orbit_velocity_min = -0.6
	p.orbit_velocity_max = 0.6
	p.tangential_accel_min = -50.0
	p.tangential_accel_max = 50.0

	# ขนาดสุ่มหลายเกรด ดูมีมิติกว่าขนาดเดียวล้วน
	p.scale_amount_min = square_size * 0.45
	p.scale_amount_max = square_size * 1.15

	var scale_curve := Curve.new()
	scale_curve.add_point(Vector2(0.0, 0.4))
	scale_curve.add_point(Vector2(0.15, 1.0))
	scale_curve.add_point(Vector2(1.0, 0.0))
	p.scale_amount_curve = scale_curve

	p.color = color
	p.hue_variation_min = -0.04
	p.hue_variation_max = 0.04

	# จางหายไปตอนท้าย แทนที่จะหายวับตัดฉับ
	var fade := Gradient.new()
	fade.set_color(0, Color(color.r, color.g, color.b, 1.0))
	fade.set_color(1, Color(color.r, color.g, color.b, 0.0))
	p.color_ramp = fade

	p.emitting = true

	# ---------------------------------------------------------
	# ชุดที่ 2: สะเก็ดเล็กๆ ลอยพริ้วช้าๆ ตามหลัง เพิ่มความอลังการ
	# ---------------------------------------------------------
	var p2 := CPUParticles2D.new()
	parent.add_child(p2)
	p2.global_position = global_pos
	p2.z_index = 100
	p2.texture = null
	p2.emitting = false
	p2.one_shot = true
	p2.amount = int(amount * 0.5)
	p2.lifetime = lifetime * 1.4
	p2.explosiveness = 0.7
	p2.randomness = 0.6
	p2.direction = Vector2.UP
	p2.spread = 180.0
	p2.initial_velocity_min = speed * 0.1
	p2.initial_velocity_max = speed * 0.35
	p2.damping_min = 20.0
	p2.damping_max = 50.0
	p2.gravity = Vector2(0, 30)
	p2.angle_min = 0.0
	p2.angle_max = 360.0
	p2.angular_velocity_min = -140.0
	p2.angular_velocity_max = 140.0
	p2.orbit_velocity_min = -1.0
	p2.orbit_velocity_max = 1.0
	p2.scale_amount_min = square_size * 0.2
	p2.scale_amount_max = square_size * 0.45
	p2.scale_amount_curve = scale_curve
	p2.color = color
	p2.color_ramp = fade
	p2.emitting = true

	# ลบตัวเองทิ้งหลัง particle เล่นจบ กันโหนดค้างในซีน
	var max_life: float = max(lifetime, p2.lifetime)
	var cleanup_timer := parent.get_tree().create_timer(max_life + 0.2)
	cleanup_timer.timeout.connect(func() -> void:
		if is_instance_valid(p):
			p.queue_free()
		if is_instance_valid(p2):
			p2.queue_free()
	)
