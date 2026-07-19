extends Character
class_name Monsterstats

var drop_table: Array = []
var coin_reward: int = 0

func _init(new_name: String = "", new_max_health: int = 10, new_base_atk: int = 0, new_base_prt: int = 0, new_drop_table: Array = [], new_coin_reward: int = 0):
	super._init(new_name, new_max_health, new_base_atk, new_base_prt)
	drop_table = new_drop_table if new_drop_table.size() > 0 else []
	coin_reward = new_coin_reward

func get_drops() -> Array:
	print("drop_table size: ", drop_table.size())
	for drop in drop_table:
		print("drop prob: ", drop.prob, " item: ", drop.item)
	var reward: Array = []
	for drop in drop_table:
		if randf() < drop.prob:
			var amount = randi_range(drop.min_amount, drop.max_amount)
			reward.append([drop.item, amount])
	return reward

static func create_from_data(data:MonsterData) -> Monsterstats:
	var m = Monsterstats.new()
	m.name = data.name
	m.max_health = data.max_health
	m.base_atk = data.base_atk
	m.base_prt = data.base_prt
	m.drop_table = data.drop_items
	m.coin_reward = data.coin_reward
	m.health = m.max_health
	return m

