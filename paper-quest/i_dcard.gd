extends Node2D

@onready var name_label = $CardUI/Name
@onready var class_label = $CardUI/Class
@onready var age_label = $CardUI/Age
@onready var id_label = $CardUI/IDNumber
@onready var rank_label = $CardUI/Rank
@onready var guild_label = $CardUI/GuildName
@onready var expire_label = $CardUI/ExpireDate


# -------------------------
# ข้อมูลสำหรับสุ่ม
# -------------------------

var first_names = [
	"Arthur","Alden","Asher","Bran","Caleb","Cedric","Dorian","Drake","Garret","Gideon","Hector","Jasper",
	"Julian","Kaelen","Lance","Logan","Lucian","Orson","Robin","Roderick","Rowan","Silas","Tristan","Vance",
	"Zephyr"
]

var last_names = [
	"Ashford","Belmont","Blackwood","Carter","Fletcher","Hawthorn","Ironwood","Kingsley","Mercer","Miller",
	"Montgomery","Oakheart","Ravencrest","Redford","Silverford","Smith","Sterling","Stormriver","Tanner",
	"Vance","Weaver","Windermere","Winterborne","Wright"
]

var classes = [
	"Warrior","Mage","Ranger","Rogue","Priest"
]

var ranks = [
	"F","E","D","C","B","A","S"
]

var guilds = [
	"67","SigmaBoy","RickRoll","HotDogWater"
]


# -------------------------
# เริ่มต้น
# -------------------------

func _ready():
	generate_persona()


# -------------------------
# สุ่มข้อมูลคน
# -------------------------

func generate_persona():

	var first_name = first_names.pick_random()
	var last_name = last_names.pick_random()

	var person_name = first_name + " " + last_name
	var person_class = classes.pick_random()
	var person_age = randi_range(18, 60)
	var person_id = randi_range(100000, 999999)
	var person_rank = ranks.pick_random()
	var person_guild = guilds.pick_random()

	# สุ่มวันที่หมดอายุ
	var expire_day = randi_range(1, 28)
	var expire_month = randi_range(1, 12)
	var expire_year = randi_range(2026, 2030)

	var expire_date = "%02d/%02d/%d" % [
		expire_day,expire_month,expire_year
	]


	# -------------------------
	# แสดงข้อมูลบน Card
	# -------------------------

	name_label.text = "Name: " + person_name

	class_label.text = "Class: " + person_class

	age_label.text = "Age: " + str(person_age)

	id_label.text = "ID: " + str(person_id)

	rank_label.text = "Rank: " + person_rank

	guild_label.text = "Guild: " + person_guild

	expire_label.text = "Expire: " + expire_date
