extends Node

@export var npc_scene: PackedScene

@onready var spawn_point: Marker2D = $NPCSpawnPoint
@onready var desk_point: Marker2D = $NPCDeskPoint
@onready var exit_point: Marker2D = $NPCExitPoint
@onready var npc_container: Node2D = $NPCContainer
@onready var id_card = get_node_or_null("../ObjMananger/IDcard")
@onready var quest_paper = get_node_or_null("../ObjMananger/QuestPaperSmall")

var current_npc = null


func _ready() -> void:
	call_deferred("spawn_npc")


func spawn_npc() -> void:
	if current_npc != null:
		return

	# ครบจำนวนลูกค้าของวันนี้แล้ว ไม่ต้องเรียกลูกค้าคนใหม่มาอีก
	if DayManager.is_day_over():
		return

	current_npc = npc_scene.instantiate()
	npc_container.add_child(current_npc)

	current_npc.global_position = spawn_point.global_position

	current_npc.arrived.connect(_on_npc_arrived)
	current_npc.finished.connect(_on_npc_finished)

	current_npc.walk_to(desk_point.global_position)

	print("NPC spawned")


func _on_npc_arrived() -> void:
	print("NPC arrived at desk")

	# =====================================================
	# ยืนรอแปปนึงก่อน ค่อยมีกระดาษ + บัตรโผล่มาบนโต๊ะ
	# =====================================================

	await get_tree().create_timer(0.6).timeout

	if id_card:
		id_card.reset_card(current_npc.get_npc_class())

	if quest_paper:
		quest_paper.reset_to_closed_with_new_quest()


func finish_current_npc() -> void:
	if current_npc == null:
		return

	# ให้ NPC เดินออก
	current_npc.walk_out(exit_point.global_position)


func _on_npc_finished() -> void:
	print("NPC left")

	current_npc = null

	await get_tree().create_timer(1.0).timeout

	spawn_npc()
