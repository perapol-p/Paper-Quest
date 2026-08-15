extends Resource
class_name QuestData

## ประเภทเควส: "hunt", "delivery", "gather", "boss", "demon", "defend", "purge"
@export var quest_type: String = "hunt"

## Rank ความยากของเควส: F, E, D, C, B, A, S
@export var quest_rank: String = "F"

## หมวดหมู่ประเภท (ข้อความแสดงผล) เช่น "ล่ามอนสเตอร์", "ล่าบอส"
@export var category_text: String = ""

@export var title: String = ""
@export var description: String = ""

## ชื่อมอนสเตอร์ หรือ ชื่อไอเทม ที่เป็นเป้าหมายของเควส
@export var target_name: String = ""
@export var target_count: int = 1

## ข้อความเงื่อนไข rank เช่น "1 คน" หรือ "2 คน+"
@export var rank_text: String = "1 คน"

@export var reward_gold: int = 10

## สถานะเควส: "available", "taken", "completed"
@export var state: String = "available"

## ตรากิลด์บนใบเควสนี้เป็นของจริงหรือไม่ (false = ตราปลอม)
## ผู้เล่นต้องสังเกตแล้วตัดสินใจกด Approve (จริง) หรือ Denied (ปลอม)
@export var is_guild_authentic: bool = true
