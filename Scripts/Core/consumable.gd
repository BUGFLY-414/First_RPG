extends Item
## 消耗品类
class_name Consumable
enum Effect {
	HEAL,
	DMG,
	MANA,

}
@export var effect: Effect = Effect.HEAL
@export var value: int = 0

func use(user: Playerstats):
	match effect:
		Effect.HEAL:
			user.change_health(value)
			# 可选：显示漂浮文字等
		Effect.DMG:
			user.take_damage(value)
		Effect.MANA:
			pass
		_:
			print("未知效果")
	user.inventory.remove_item(self,1)
