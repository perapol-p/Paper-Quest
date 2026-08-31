extends Node

## Autoload: DayManager
## จำกัดจำนวนลูกค้าต่อวัน พอครบจำนวนแล้วให้ยิง signal ออกไปสรุปผล (ถูกกี่คน / ผิดกี่คน)
## เกมวนทั้งหมด max_days วัน วันแรกมีลูกค้า base_customers คน แล้วเพิ่มทีละ
## customers_increment คนในแต่ละวันถัดไป พอจบวันสุดท้ายจะสรุปผลรวมทั้งเกม
## แล้วตัดสิน ending จาก % ที่ทำถูกทั้งหมด
##
## วิธีใช้:
##   DayManager.max_customers_per_day  -> จำนวนลูกค้าที่จะมาในวันนี้ (คำนวณอัตโนมัติจาก current_day)
##   DayManager.register_result(true/false) -> เรียกทุกครั้งที่ผู้เล่นส่งเควส (ถูก/ผิด)
##   DayManager.is_day_over()           -> true ถ้าครบจำนวนลูกค้าของวันนี้แล้ว
##   DayManager.day_finished            -> signal ยิงตอนลูกค้าคนสุดท้ายของวันถูกนับครบ
##   DayManager.advance_day()           -> ไปวันถัดไป (รีเซ็ตตัวนับรายวัน แต่เก็บผลรวมไว้)
##   DayManager.reset_game()            -> เริ่มเกมใหม่ทั้งหมดตั้งแต่วันที่ 1

## จำนวนวันทั้งหมดที่เล่น (loop) #55251
@export var max_days: int = 5

## จำนวนลูกค้าของวันแรก
@export var base_customers: int = 5

## จำนวนลูกค้าที่เพิ่มขึ้นในแต่ละวันถัดไป
@export var customers_increment: int = 1

## จำนวนลูกค้าที่จะให้บริการใน "วันนี้" (คำนวณใหม่ทุกครั้งที่เริ่มวัน)
var max_customers_per_day: int = 5

var current_day: int = 1

# วันที่จริงในเกม
var date_day: int = 14
var date_month: int = 9
var date_year: int = 1866

var customers_served: int = 0
var correct_count: int = 0
var wrong_count: int = 0

## ผลรวมสะสมตลอดทั้งเกม (ทุกวันรวมกัน) ใช้ตัดสิน ending ตอนจบวันสุดท้าย
var total_correct: int = 0
var total_wrong: int = 0
var total_customers: int = 0

## เปอร์เซ็นต์ทำถูกขั้นต่ำสำหรับแต่ละ ending
@export var good_end_threshold: float = 80.0
@export var normal_end_threshold: float = 50.0

## ยิงทุกครั้งที่นับผลลูกค้า 1 คนเสร็จ (ถูก/ผิด, จำนวนที่ให้บริการไปแล้ว, จำนวนทั้งหมดของวันนี้)
signal customer_counted(is_correct: bool, served: int, total: int)

## ยิงตอนลูกค้าคนสุดท้ายของวันถูกนับครบแล้ว -> ให้ UI ไปโชว์สรุปผลของวันนี้
## is_last_day บอกว่าวันนี้เป็นวันสุดท้ายของเกมหรือไม่ (ให้ UI ไปโชว์ ending แทนปุ่ม "วันต่อไป")
signal day_finished(correct_count: int, wrong_count: int, total: int, day: int, is_last_day: bool)

## ยิงตอนจบวันสุดท้ายของเกม พร้อมผลรวมทั้งหมดและ ending ที่ได้ ("good" / "normal" / "bad")
signal game_finished(total_correct: int, total_wrong: int, total_customers: int, ending: String)


func _ready() -> void:
	reset_game()


## เริ่มเกมใหม่ตั้งแต่วันที่ 1 รีเซ็ตทั้งตัวนับรายวันและผลรวมทั้งเกม
func reset_game() -> void:
	current_day = 1
	
	# วันที่จริงเริ่มต้น
	date_day = 14
	date_month = 9
	date_year = 1866
	
	total_correct = 0
	total_wrong = 0
	total_customers = 0
	start_new_day()


## เริ่มวันใหม่ (วันปัจจุบัน) รีเซ็ตตัวนับของวันนี้ และคำนวณจำนวนลูกค้าของวันนี้
## ตาม current_day (ไม่แตะผลรวมทั้งเกม)
func start_new_day() -> void:
	max_customers_per_day = base_customers + (current_day - 1) * customers_increment
	customers_served = 0
	correct_count = 0
	wrong_count = 0


## ไปวันถัดไป ถ้ายังไม่ครบ max_days ผลรวมทั้งเกมจะถูกเก็บไว้ต่อ
func advance_day() -> void:
	if current_day >= max_days:
		return

	current_day += 1
	date_day += 1
	start_new_day()


## เป็นวันสุดท้ายของเกมอยู่หรือไม่
func is_last_day() -> bool:
	return current_day >= max_days


## เรียกตอนผู้เล่นส่งเควส 1 ใบเสร็จ (ตัดสินแล้วว่าถูกหรือผิด)
func register_result(is_correct: bool) -> void:
	if is_day_over():
		return

	customers_served += 1
	total_customers += 1

	if is_correct:
		correct_count += 1
		total_correct += 1
	else:
		wrong_count += 1
		total_wrong += 1

	customer_counted.emit(is_correct, customers_served, max_customers_per_day)

	if is_day_over():
		var last_day := is_last_day()
		day_finished.emit(correct_count, wrong_count, max_customers_per_day, current_day, last_day)

		if last_day:
			var ending := calculate_ending()
			game_finished.emit(total_correct, total_wrong, total_customers, ending)


## ครบจำนวนลูกค้าของวันนี้แล้วหรือยัง
func is_day_over() -> bool:
	return customers_served >= max_customers_per_day


## % ที่ทำถูกรวมทั้งเกม (0-100)
func get_total_accuracy() -> float:
	if total_customers <= 0:
		return 0.0
	return float(total_correct) / float(total_customers) * 100.0


## ตัดสิน ending จาก % ทำถูกรวมทั้งเกม
## เกิน good_end_threshold (>80%) -> "good"
## ตั้งแต่ normal_end_threshold ถึง good_end_threshold (50-80%) -> "normal"
## ต่ำกว่า normal_end_threshold (<50%) -> "bad"
func calculate_ending() -> String:
	var accuracy := get_total_accuracy()

	if accuracy > good_end_threshold:
		return "good"
	elif accuracy >= normal_end_threshold:
		return "normal"
	else:
		return "bad"
