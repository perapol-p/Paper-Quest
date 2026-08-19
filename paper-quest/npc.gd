extends CharacterBody2D

signal arrived
signal finished

@onready var cloth = $Cloth
@onready var eye = $Eye
@onready var hair = $Hair

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



#random npc
var cloths = [
	preload("res://Assets/Export/Characters/Cloth/Male_Mage.png"),
	preload("res://Assets/Export/Characters/Cloth/Male_Ranger.png"),
	preload("res://Assets/Export/Characters/Cloth/Male_Worrier.png")]

var eyes = [
	preload("res://Assets/Export/Characters/Eyes/Blue/MaleB_Eye1.png"),
	preload("res://Assets/Export/Characters/Eyes/Blue/MaleB_Eye2.png"),
	preload("res://Assets/Export/Characters/Eyes/Blue/MaleB_Eye3.png"),
	preload("res://Assets/Export/Characters/Eyes/Brown/MaleBr_Eyes1.png"),
	preload("res://Assets/Export/Characters/Eyes/Brown/MaleBr_Eyes2.png"),
	preload("res://Assets/Export/Characters/Eyes/Brown/MaleBr_Eyes3.png"),
	preload("res://Assets/Export/Characters/Eyes/Red/MaleR_Eye1.png"),
	preload("res://Assets/Export/Characters/Eyes/Red/MaleR_Eye2.png"),
	preload("res://Assets/Export/Characters/Eyes/Red/MaleR_Eye3.png"),
	preload("res://Assets/Export/Characters/Eyes/Yellow/MaleY_Eye1.png"),
	preload("res://Assets/Export/Characters/Eyes/Yellow/MaleY_Eye2.png"),
	preload("res://Assets/Export/Characters/Eyes/Yellow/MaleY_Eye3.png")
]

var hairs = [
	preload("res://Assets/Export/Characters/Hair/Black/MaleBl_F_01.png"),
	preload("res://Assets/Export/Characters/Hair/Black/MaleBl_F_02.png"),
	preload("res://Assets/Export/Characters/Hair/Black/MaleBl_F_03.png"),
	preload("res://Assets/Export/Characters/Hair/Blue/MaleB_F_01.png"),
	preload("res://Assets/Export/Characters/Hair/Blue/MaleB_F_02.png"),
	preload("res://Assets/Export/Characters/Hair/Blue/MaleB_F_03.png"),
	preload("res://Assets/Export/Characters/Hair/Brown/MaleBr_F_01.png"),
	preload("res://Assets/Export/Characters/Hair/Brown/MaleBr_F_02.png"),
	preload("res://Assets/Export/Characters/Hair/Brown/MaleBr_F_03.png"),
	preload("res://Assets/Export/Characters/Hair/Green/MaleG_F_01.png"),
	preload("res://Assets/Export/Characters/Hair/Green/MaleG_F_02.png"),
	preload("res://Assets/Export/Characters/Hair/Green/MaleG_F_03.png"),
	preload("res://Assets/Export/Characters/Hair/Red/MaleR_F_01.png"),
	preload("res://Assets/Export/Characters/Hair/Red/MaleR_F_02.png"),
	preload("res://Assets/Export/Characters/Hair/Red/MaleR_F_03.png"),
	preload("res://Assets/Export/Characters/Hair/Yellow/MaleY_F_01.png"),
	preload("res://Assets/Export/Characters/Hair/Yellow/MaleY_F_02.png"),
	preload("res://Assets/Export/Characters/Hair/Yellow/MaleY_F_03.png"),
]

func random_npc():
	cloth.texture = cloths.pick_random()
	eye.texture = eyes.pick_random()
	hair.texture = hairs.pick_random()

func _ready() -> void:
	random_npc()
