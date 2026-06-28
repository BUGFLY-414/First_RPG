# 物品栏类
class_name Inventory extends RefCounted
var items: Array = [] # 结构: [{"item": Item, "amount": int}]

func _init(init_items: Array = []):
	items = init_items if init_items else []

func add_item(item: Item, amount: int):
	if amount <= 0:
		return
	
	for entry in items:
		if entry.item.name == item.name:
			entry.amount += amount
			print("获得 ", item.name, " x", amount, "，现有 ", entry.amount, " 个")
			return
	
	items.append({"item": item, "amount": amount})
	print("获得新物品：", item.name, " x", amount, "，现有 ", amount, " 个")

func remove_item(item: Item, amount: int):
	if amount <= 0:
		print("错误：remove_item()的数量不合法")
		return
	
	for entry in items:
		if entry.item.name == item.name:
			if entry.amount < amount:
				print("数量不足")
				return
			if entry.amount >= amount:
				entry.amount -= amount
				print("已移除", amount, "个", item.name)
				if entry.amount == 0:
					items.erase(entry)
				return
	print("物品不存在")

func add_rewards(rewards: Array):
	# rewards 格式: Array[DropItem]
	for drop in rewards:
		# 这里的逻辑稍微调整，因为Python代码里传入的是 (Item, amount)
		# 但根据Monster类，get_drops返回的是 (Item, amount)
		# 假设传入的rewards是 Array[[Item, int]]
		if drop.size() >= 2:
			add_item(drop[0], drop[1])

func show(detail: bool = false):
	if not detail:
		print("物品栏：")
		for entry in items:
			print(entry.item.name, " x ", entry.amount)
	else:
		print("物品栏详情：")
		var line = "------------------------------"
		for entry in items:
			if entry.item is Equipment:
				print(line, "\n", entry.item.name, " ,\n描述： ", entry.item.description, "\n槽位： ", entry.item.slot, "\n攻击力加成： ", entry.item.atk_bonus, "\n防御力加成： ", entry.item.prt_bonus, "\n数量： ", entry.amount, "\n", line)
			else:
				print(line, "\n", entry.item.name, " ,\n描述： ", entry.item.description, "\n数量： ", entry.amount, "\n", line)

func use_item(user: Playerstats):
	if items.is_empty():
		print("物品栏为空")
		return
	
	for entry in items:
		if entry.amount > 0:
			if entry.item is Equipment or entry.item is Consumable:
				entry.item.use(user)
				return
			else:
				print("该物品无法使用")
	print("没有可用的物品")
