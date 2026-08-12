@tool
extends Node2D

@export_node_path("Control") var paper_path: NodePath
@export_node_path("Area2D") var hitbox_path: NodePath


func _process(_delta: float) -> void:
	if paper_path.is_empty() or hitbox_path.is_empty():
		return

	var paper := get_node_or_null(paper_path) as Control
	var hitbox := get_node_or_null(hitbox_path) as Area2D

	if paper == null or hitbox == null:
		return

	hitbox.global_position = paper.global_position
