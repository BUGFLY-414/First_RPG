extends Resource
class_name Item

## 物品名
@export var name: String = ""
## 物品描述
@export var description: String = ""
## 物品图标
@export var icon: Texture = null

static func create(p_name: String, p_desc: String = "") -> Item:
	var item = Item.new()
	item.name = p_name
	item.description = p_desc
	return item
