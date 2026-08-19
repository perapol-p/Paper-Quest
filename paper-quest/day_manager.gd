extends Node

## Autoload: DayManager
## จำกัดจำนวนลูกค้าต่อวัน พอครบจำนวนแล้วให้ยิง signal ออกไปสรุปผล (ถูกกี่คน / ผิดกี่คน)
##
## วิธีใช้:
##   DayManager.max_customers_per_day  -> ตั้งจำนวนลูกค้าที่จะมาในวันนี้ (ตั้งค่าได้ใน Inspector หรือแก้ตรงนี้)
##   DayManager.register_result(true/false) -> เรียกทุกครั้งที่ผู้เล่นส่งเควส (ถูก/ผิด)
##   DayManager.is_day_over()           -> true ถ้าครบจำนวนลูกค้าของวันนี้แล้ว
##   DayManager.day_finished            -> signal ยิงตอนลูกค้าคนสุดท้ายของวันถูกนับครบ
##   DayManager.start_new_day()         -> รีเซ็ตค่านับใหม่ (เผื่อกดเล่นใหม่)

## จำนวนลูกค้าที่จะให้บริการในหนึ่งวัน ปรับได้ตามต้องการ
@export var max_customers_per_day: int = 5

var customers_served: int = 0
var correct_count: int = 0
var wrong_count: int = 0

## ยิงทุกครั้งที่นับผลลูกค้า 1 คนเสร็จ (ถูก/ผิด, จำนวนที่ให้บริการไปแล้ว, จำนวนทั้งหมดของวันนี้)
signal customer_counted(is_correct: bool, served: int, total: int)

## ยิงตอนลูกค้าคนสุดท้ายของวันถูกนับครบแล้ว -> ให้ UI ไปโชว์สรุปผล
signal day_finished(correct_count: int, wrong_count: int, total: int)


func _ready() -> void:
	start_new_day()


## เริ่มวันใหม่ รีเซ็ตตัวนับทั้งหมด
func start_new_day() -> void:
	customers_served = 0
	correct_count = 0
	wrong_count = 0


## เรียกตอนผู้เล่นส่งเควส 1 ใบเสร็จ (ตัดสินแล้วว่าถูกหรือผิด)
func register_result(is_correct: bool) -> void:
	if is_day_over():
		return

	customers_served += 1

	if is_correct:
		correct_count += 1
	else:
		wrong_count += 1

	customer_counted.emit(is_correct, customers_served, max_customers_per_day)

	if is_day_over():
		day_finished.emit(correct_count, wrong_count, max_customers_per_day)


## ครบจำนวนลูกค้าของวันนี้แล้วหรือยัง
func is_day_over() -> bool:
	return customers_served >= max_customers_per_day
