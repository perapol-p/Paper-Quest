extends Node2D

func _ready() -> void:
	
	$"../QuestInspect/Center/Panel/Paper/StampHitBox".mouse_entered.connect(OnMouseStamp)
	
func OnMouseStamp() -> void:
	print("Mouse Entered")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("rightClick"):
		print("right")
		spawnStamp()

func spawnStamp() -> void:
	var stamp := Sprite2D.new()
	stamp.texture = preload("res://Assets/Picture/Items/Stamp/Denied.png")
	add_child(stamp)
	stamp.global_position = get_global_mouse_position()
