extends Node2D

signal item_released(item)

var item_being_drag
var screen_size

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
			#Raycast check for item
		else:
			if item_being_drag:
				item_released.emit(item_being_drag)
			item_being_drag = null

func raycast_check_item():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = 1
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		print(result[0].collider.get_parent())
		return result[0].collider.get_parent()
	return null
