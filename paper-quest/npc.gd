extends CharacterBody2D

signal arrived
signal finished

@export var speed: float = 100.0

var target_position: Vector2
var walking := false
var leaving := false


func walk_to(target: Vector2) -> void:
	target_position = target
	walking = true
	leaving = false


func walk_out(target: Vector2) -> void:
	target_position = target
	walking = true
	leaving = true


func _physics_process(_delta: float) -> void:
	if not walking:
		return

	var distance := global_position.distance_to(target_position)

	if distance <= 5.0:
		global_position = target_position
		velocity = Vector2.ZERO
		walking = false

		if leaving:
			finished.emit()
			queue_free()
		else:
			arrived.emit()

		return

	var direction := global_position.direction_to(target_position)
	velocity = direction * speed

	move_and_slide()


func finish() -> void:
	finished.emit()
	queue_free()
