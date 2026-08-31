extends Node

## Autoload: PauseManager
## เก็บสถานะว่าตอนนี้กำลังเข้าเมนูหลักผ่านปุ่ม Pause อยู่หรือเปล่า
## เพื่อให้ main_menu.gd รู้ว่าต้องโชว์ปุ่ม "เล่นต่อ / ออกเกม"
## แทนปุ่ม "PLAY / QUIT" ตอนเปิดเกมใหม่

## true เมื่อกดปุ่ม Pause จากในเกม (ยังไม่จบเกม ไม่ต้องรีเซ็ต)
var is_paused_menu: bool = false
