## 玩家数据类
class_name Playerstats extends Character

enum Slot {
	WEAPON,
	ARMOR,
	UNKNOWN
}

var equipments: Dictionary = {
	Slot.WEAPON: null,
	Slot.ARMOR: null,
	Slot.UNKNOWN: null
}
var inventory: Inventory
var coin: int = 0

func _init(n: String, m_hp: int, atk: int, b_prt: int = 0, inv: Inventory = null):
	super(n, m_hp, atk, b_prt)
	inventory = inv if inv else Inventory.new()

func get_total_atk() -> int:
	var base = super.get_total_atk()
	var weapon = equipments[Slot.WEAPON]
	if weapon:
		base += weapon.atk_bonus
	return base

func get_total_prt() -> int:
	var base = super.get_total_prt()
	var armor = equipments[Slot.ARMOR]
	if armor:
		base += armor.prt_bonus
	return base

func take_damage(damage: int):
	var actual_damage = super.take_damage(damage)
	if health <= 0:
		print("游戏结束")
		#get_tree().quit()
	return actual_damage

func equip(item: Equipment):
	var slot = item.slot
	if not equipments.has(slot):
		print("无效槽位")
		return
	
	var current_item = equipments[item.slot]
	if current_item == null:
		equipments[item.slot] = item
		inventory.remove_item(item, 1)
		print("你装备了 ", item.name, "！")
	else:
		# 移除了输入逻辑，默认执行替换操作
		equipments[item.slot] = item
		inventory.add_item(current_item, 1)
		inventory.remove_item(item, 1)
		print("你替换了装备，当前装备：", item.name, "！")

func get_coin(c: int) -> int:
	coin += c
	return c
