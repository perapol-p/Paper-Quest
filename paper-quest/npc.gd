extends CharacterBody2D

signal arrived
signal finished

@onready var cloth = $Cloth
@onready var eye = $Eye
@onready var front_hair = $FrontHair
@onready var back_hair =$BackHair

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

var cloth_classes = [
	"Mage",
	"Ranger",
	"Warrior"
]

var npc_class: String = ""

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
	{
	"front" :preload("res://Assets/Export/Characters/Hair/Black/MaleBl_F_01.png"),
	"back"  :preload("res://Assets/Export/Characters/Hair/Black/MaleBl_B_01.png") 
	},{
	"front" :preload("res://Assets/Export/Characters/Hair/Black/MaleBl_F_02.png"),
	"back" :preload("res://Assets/Export/Characters/Hair/Black/MaleBl_B_02.png")
	},{
	"front" :preload("res://Assets/Export/Characters/Hair/Black/MaleBl_F_03.png"),
	"back"  :preload("res://Assets/Export/Characters/Hair/Black/MaleBl_B_03.png")
	},{
	"front" :preload("res://Assets/Export/Characters/Hair/Blue/MaleB_F_01.png"),
	"back"  :preload("res://Assets/Export/Characters/Hair/Blue/MaleB_B_01.png")
	},{
	"front" :preload("res://Assets/Export/Characters/Hair/Blue/MaleB_F_02.png"),
	"back"  :preload("res://Assets/Export/Characters/Hair/Blue/MaleB_B_02.png"),
	},{
	"front" :preload("res://Assets/Export/Characters/Hair/Blue/MaleB_F_03.png"),
	"back"  :preload("res://Assets/Export/Characters/Hair/Blue/MaleB_B_03.png")
	},{
	"front" :preload("res://Assets/Export/Characters/Hair/Brown/MaleBr_F_01.png"),
	"back"  :preload("res://Assets/Export/Characters/Hair/Brown/MaleBr_B_01.png")
	},{
	"front" :preload("res://Assets/Export/Characters/Hair/Brown/MaleBr_F_02.png"),
	"back"  :preload("res://Assets/Export/Characters/Hair/Brown/MaleBr_B_02.png")
	},{
	"front" :preload("res://Assets/Export/Characters/Hair/Brown/MaleBr_F_03.png"),
	"back"  :preload("res://Assets/Export/Characters/Hair/Brown/MaleBr_B_03.png")
	},{
	"front" :preload("res://Assets/Export/Characters/Hair/Green/MaleG_F_01.png"),
	"back"  :preload("res://Assets/Export/Characters/Hair/Green/MaleG_B_01.png")
	},{
	"front" :preload("res://Assets/Export/Characters/Hair/Green/MaleG_F_02.png"),
	"back"  :preload("res://Assets/Export/Characters/Hair/Green/MaleG_B_02.png")
	},{
	"front" :preload("res://Assets/Export/Characters/Hair/Green/MaleG_F_03.png"),
	"back"  :preload("res://Assets/Export/Characters/Hair/Green/MaleG_B_03.png")
	},{
	"front" :preload("res://Assets/Export/Characters/Hair/Red/MaleR_F_01.png"),
	"back"  :preload("res://Assets/Export/Characters/Hair/Red/MaleR_B_01.png")
	},{
	"front" :preload("res://Assets/Export/Characters/Hair/Red/MaleR_F_02.png"),
	"back"  :preload("res://Assets/Export/Characters/Hair/Red/MaleR_B_02.png")
	},{
	"front" :preload("res://Assets/Export/Characters/Hair/Red/MaleR_F_03.png"),
	"back"  :preload("res://Assets/Export/Characters/Hair/Red/MaleR_B_03.png")
	},{
	"front" :preload("res://Assets/Export/Characters/Hair/Yellow/MaleY_F_01.png"),
	"back"  :preload("res://Assets/Export/Characters/Hair/Yellow/MaleY_B_01.png")
	},{
	"front" :preload("res://Assets/Export/Characters/Hair/Yellow/MaleY_F_02.png"),
	"back"  :preload("res://Assets/Export/Characters/Hair/Yellow/MaleY_B_02.png")
	},{
	"front" :preload("res://Assets/Export/Characters/Hair/Yellow/MaleY_F_03.png"),
	"back"  :preload("res://Assets/Export/Characters/Hair/Yellow/MaleY_B_03.png")
	},{
	"front" :preload("res://Assets/Export/Characters/Hair/Bald/Male_F_00.png"),
	"back" :preload("res://Assets/Export/Characters/Hair/Bald/Male_B_00.png")
	}
]

func random_npc() -> void:
	var index := randi_range(0, cloths.size() - 1)

	cloth.texture = cloths[index]
	npc_class = cloth_classes[index]

	eye.texture = eyes.pick_random()

	var select_hair = hairs.pick_random()
	front_hair.texture = select_hair["front"]
	back_hair.texture = select_hair["back"]

func get_npc_class() -> String:
	return npc_class

func _ready() -> void:
	random_npc()
