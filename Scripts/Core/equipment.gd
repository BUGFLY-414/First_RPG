class_name Equipment extends Item

enum Slot {
	WEAPON,
	ARMOR,
	UNKNOWN
}
@export var slot: Slot = Slot.UNKNOWN
@export var atk_bonus: int = 0
@export var prt_bonus: int = 0


func use(user: Playerstats):
	"""使用装备"""
	user.equip(self)
