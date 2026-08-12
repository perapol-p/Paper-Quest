extends Node2D

func _ready() -> void:
	$StampHitBox.mouse_entered.connect(OnMouseStamp)
	
func OnMouseStamp() -> void:
	print("Mouse Entered")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Approve"):
		print("Z")
		spawnStamp()

func spawnStamp() -> void:
	var stamp := Sprite2D.new()
	stamp.texture = preload("res://Assets/Picture/Items/Stamp/Stamp_A.png")
	add_child(stamp)
	stamp.global_position = get_global_mouse_position()
