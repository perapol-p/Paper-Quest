extends Node

## Autoload: QuestDatabase
## ระบบสุ่มข้อมูลเควส อิงตาม Rank F -> S (ยิ่ง Rank สูง ยิ่งยาก รางวัลยิ่งเยอะ)
##
## วิธีใช้:
##   QuestDatabase.generate_random_quest()          -> สุ่มเควส 1 ใบ (สุ่ม rank ตามน้ำหนักด้วย)
##   QuestDatabase.generate_random_quest("C")        -> สุ่มเควส 1 ใบ เฉพาะ Rank C
##   QuestDatabase.generate_quest_batch(5)           -> สุ่มเควสหลายใบพร้อมกัน (ติดบอร์ด)

var rng := RandomNumberGenerator.new()

const RANKS: Array[String] = ["F", "E", "D", "C", "B", "A", "S"]

## น้ำหนักการสุ่ม rank (rank ต่ำเจอบ่อย, rank สูงเจอยาก) เรียงตาม RANKS ด้านบน
const RANK_WEIGHTS: Array[int] = [30, 22, 18, 14, 8, 5, 3]

## ช่วงรางวัล gold ต่อ rank (min, max) — อิงจากตารางเควสอ้างอิง
const REWARD_RANGE: Dictionary = {
	"F": [12, 25],
	"E": [15, 30],
	"D": [25, 30],
	"C": [30, 100],
	"B": [100, 300],
	"A": [300, 500],
	"S": [600, 1300],
}

## นิยามชนิดเควสแต่ละแบบ: target pool, template ชื่อเควส, template รายละเอียด, ช่วงจำนวนเป้าหมาย
## ใส่ %s แทนชื่อเป้าหมายในไตเติล/รายละเอียด
var quest_type_defs: Dictionary = {
	"hunt": {
		"category_text": "ล่ามอนสเตอร์",
		"targets": ["หมาป่าเงิน", "หมาป่าดำ", "ก็อบลิน", "สไลม์พิษ", "แมงมุมยักษ์", "โครงกระดูก", "ค้างคาวยักษ์", "หมีป่าคลั่ง"],
		"titles": ["ล่า%s", "กำจัด%s", "ปราบ%s", "ไล่ล่า%s"],
		"descs": [
			"หมู่บ้านขอความช่วยเหลือ %s กำลังก่อความเดือดร้อนให้ชาวบ้าน ช่วยจัดการให้หน่อย",
			"มี %s ปรากฏตัวใกล้หมู่บ้าน ชาวบ้านหวาดกลัวมาก ต้องการนักผจญภัยไปจัดการโดยด่วน",
			"%s ได้ทำลายพืชผลของชาวบ้านไปมาก ช่วยตามล่าและกำจัดทีเถอะ",
			"พรานล่าสัตว์รายงานว่าพบฝูง %s เพิ่มจำนวนขึ้นผิดปกติ อาจเป็นอันตรายต่อผู้เดินทาง",
		],
		"reward_item_suffix": "x%d ชิ้น",
		"target_count": [3, 20],
	},
	"delivery": {
		"category_text": "ค้นหา & ส่งมอบ",
		"targets": ["แมวเวทมนตร์ขนฟู", "สัตว์เลี้ยงพลัดหลง", "เอกสารสำคัญ", "เด็กหลงทาง"],
		"titles": ["ตามหา%s", "ค้นหา%s", "ตามล่า%s"],
		"descs": [
			"%s หายตัวไปในเขตป่าด้านหลังเมือง ช่วยตามหาแล้วนำกลับมาส่งกิลด์ด้วย",
			"มีคนแจ้งว่าพบ %s เร่ร่อนอยู่แถวชานเมือง ช่วยตามหาและพากลับมาอย่างปลอดภัย",
		],
		"reward_item_suffix": "x1 ตัว",
		"target_count": [1, 1],
	},
	"gather": {
		"category_text": "รวบรวมวัตถุดิบ",
		"targets": ["สมุนไพรเรืองแสง", "เห็ดพิษ", "แร่เหล็ก", "สมุนไพรฟื้นฟู", "หนังหมาป่า", "ผลึกเวทมนตร์", "ไม้โบราณ", "ขนนกอินทรี"],
		"titles": ["จัดหา%s", "รวบรวม%s", "เก็บ%s"],
		"descs": [
			"นักแปรธาตุต้องการ \"%s\" ไปปรุงยาสมานแผลให้กองทหาร ช่วยรวบรวมมาส่งด้วย",
			"ร้านค้าในเมืองต้องการ %s จำนวนมาก เพื่อนำไปใช้ผลิตสินค้าขาย ใครหามาส่งได้จะได้รับรางวัลตอบแทน",
			"หัวหน้ากิลด์อยากได้ %s ไว้เก็บสะสม ใครหามาส่งได้จะได้รับรางวัลงาม",
			"ชาวบ้านเดือดร้อนเพราะขาดแคลน %s กรุณาช่วยรวบรวมมาส่งโดยด่วน",
		],
		"reward_item_suffix": "x%d ต้น",
		"target_count": [5, 20],
	},
	"purge": {
		"category_text": "กวาดล้าง",
		"targets": ["สไลม์พิษ", "หมาป่าเงิน", "กอบลินซุ่มโจมตี", "แมงมุมยักษ์", "กองเกวียนพาณิชย์ที่ถูกซุ่ม"],
		"titles": ["ปราบ%s", "ล่าฝูง%s", "กำจัดรัง%s", "กู้คืน%s"],
		"descs": [
			"%s ขยายพันธุ์ปนเปื้อนในแหล่งน้ำใช้ของเมือง ช่วยลดจำนวนพวกมันก่อนน้ำใช้ไม่ได้",
			"พวกมันตั้งแคมป์ซุ่มโจมตีคนเดินทางบริเวณชายป่า ช่วยกวาดล้างพวกมันแล้วนำหลักฐานกลับมา",
			"กองเกวียนพาณิชย์ถูกซุ่มโจมตีและยึดเสบียงไป ช่วยนำกลับคืนสู่กิลด์",
		],
		"reward_item_suffix": "x%d ชิ้น",
		"target_count": [5, 20],
	},
	"defend": {
		"category_text": "ป้องกัน / ตั้งรับ",
		"targets": ["ค่ายพักยามค่ำคืน", "ประตูเมืองชั้นนอก", "หมู่บ้านชายแดน"],
		"titles": ["ป้องกัน%s", "ตั้งรับ%s", "คุ้มกัน%s"],
		"descs": [
			"กองทหารต้องการคนช่วยยามเฝ้าระวัง%sชั่วคราวจากการโจมตีของฝูงโอร์ค (ยืนยันผ่านตรานักผจญภัย)",
		],
		"reward_item_suffix": "",
		"target_count": [1, 1],
	},
	"boss": {
		"category_text": "ล่าบอส",
		"targets": ["ราชาโครงกระดูกสุสานโบราณ", "หัวหน้าเผ่านักรบออร์ค", "มังกรแดงแห่งภูเขาไฟเพลิง"],
		"titles": ["สังหาร%s", "กวาดล้าง%s", "สยบ%s"],
		"descs": [
			"ไอศาตราวุธชั่วร้ายปลุกสุสานใต้ดินขึ้นมา จงไปกำจัดราชาโครงกระดูกก่อนมันจะรวบรวมกองทัพ",
			"หัวหน้าเผ่านักรบออร์คกำลังสะสมกำลังพลเตรียมบุกเมือง จงตัดกำลังพวกมันล่วงหน้า",
			"\"มังกรแดงเพลิง\" ตื่นจากการหลับใหลบนยอดภูเขาไฟ พ่นเพลิงแผดเผาเส้นทางการค้า สภาเมืองต้องการนักผจญภัยที่อาจหาญไปสยบ",
		],
		"reward_item_suffix": "x1 ชิ้น",
		"target_count": [1, 1],
	},
	"demon": {
		"category_text": "ล่าปีศาจระดับสูง",
		"targets": ["จอมบงการสายเลือด", "ปีศาจระดับสูงผู้ใช้เวทมนตร์สลักอักขระ", "ขุนพลปีศาจแห่งตาชั่ง", "ปีศาจผู้คิดค้นเทสังหารมนุษย์โบราณ"],
		"titles": ["เผชิญหน้า%s", "ทำลาย%s", "ปราบ%s", "สลาย%s"],
		"descs": [
			"ปีศาจแฝงตัวเข้ามาในเมืองใช้เวทเปลี่ยนเลือดคนเป็นศาสตราวุธ จงเปิดโปงและกำจัดมัน",
			"พบเห็นปีศาจระดับสูงผู้ใช้เวทมนตร์พร้อมกวัดดาบเวทมนตร์สลักอักขระ จงหาทางเจาะม่านพลังและกำจัดมันลงให้ได้",
			"\"ออรา แห่งผู้บันเทียง\" ใช้ตาชั่งแห่งการเชื่อฟังบงการกองทัพปีศวนไร้ศิรษะ จงสยบตาชั่งเวทมนตร์ของนาง",
			"ปีศาจผู้คิดค้นเทสังหารมนุษย์กำลังจะหลุดจากผนึก จงรีบไปกำจัดมันก่อนสายเกินไป",
		],
		"reward_item_suffix": "x1 ชิ้น",
		"target_count": [1, 1],
	},
}

## rank แต่ละอันเปิดใช้ quest_type ไหนได้บ้าง (จำกัดความยากให้เข้ากับ rank)
var rank_type_pool: Dictionary = {
	"F": ["hunt", "delivery", "gather"],
	"E": ["hunt", "gather"],
	"D": ["hunt", "gather", "purge"],
	"C": ["purge", "defend", "hunt"],
	"B": ["boss"],
	"A": ["purge", "boss"],
	"S": ["boss", "demon"],
}

var rank_pool: Array[String] = ["1 คน", "2 คน+", "3 คน+"]

## โอกาสที่ตรากิลด์บนใบเควสจะเป็นของจริง (0.0 - 1.0)
## ปรับจาก 0.7 -> 0.8 เพื่อให้เข้าชุดกับ RANK_SUFFICIENT_CHANCE / EXPIRE_VALID_CHANCE ใน i_dcard.gd
## (ดูคอมเมนต์ใหญ่ในไฟล์นั้นว่าทำไมต้อง 0.8 ทั้ง 3 ค่า)
const GUILD_AUTHENTIC_CHANCE: float = 0.8


func _ready() -> void:
	rng.randomize()


## สุ่มเควส 1 ใบ ถ้าไม่ระบุ rank จะสุ่ม rank ตามน้ำหนัก RANK_WEIGHTS ให้เอง
func generate_random_quest(forced_rank: String = "") -> QuestData:
	var quest := QuestData.new()

	var rank: String = forced_rank if forced_rank in RANKS else _pick_random_rank()
	quest.quest_rank = rank

	var type_pool: Array = rank_type_pool.get(rank, ["hunt"])
	var chosen_type: String = type_pool[rng.randi_range(0, type_pool.size() - 1)]
	_fill_quest(quest, chosen_type)

	quest.rank_text = rank_pool[rng.randi_range(0, rank_pool.size() - 1)]

	var range_arr: Array = REWARD_RANGE.get(rank, [10, 20])
	quest.reward_gold = rng.randi_range(range_arr[0], range_arr[1])
	# ปัดรางวัลให้ลงตัวเป็นเลข 5 (ดูเป็นตัวเลขทองแบบในเกม)
	quest.reward_gold = int(round(quest.reward_gold / 5.0)) * 5

	# สุ่มว่าตรากิลด์บนใบเควสนี้เป็นของจริงหรือปลอม
	quest.is_guild_authentic = rng.randf() < GUILD_AUTHENTIC_CHANCE

	return quest


## สุ่มเควสหลายใบพร้อมกัน เช่นเอาไปติดบอร์ดรับเควส
func generate_quest_batch(count: int, forced_rank: String = "") -> Array[QuestData]:
	var result: Array[QuestData] = []
	for i in range(count):
		result.append(generate_random_quest(forced_rank))
	return result


func _pick_random_rank() -> String:
	var total: int = 0
	for w in RANK_WEIGHTS:
		total += w
	var roll: int = rng.randi_range(1, total)
	var acc: int = 0
	for i in range(RANKS.size()):
		acc += RANK_WEIGHTS[i]
		if roll <= acc:
			return RANKS[i]
	return RANKS[0]


func _fill_quest(quest: QuestData, quest_type: String) -> void:
	var def: Dictionary = quest_type_defs[quest_type]
	quest.quest_type = quest_type
	quest.category_text = def["category_text"]

	var targets: Array = def["targets"]
	var target: String = targets[rng.randi_range(0, targets.size() - 1)]
	quest.target_name = target

	var count_range: Array = def["target_count"]
	quest.target_count = rng.randi_range(count_range[0], count_range[1])

	var titles: Array = def["titles"]
	quest.title = String(titles[rng.randi_range(0, titles.size() - 1)]) % target

	var descs: Array = def["descs"]
	quest.description = String(descs[rng.randi_range(0, descs.size() - 1)]) % target
