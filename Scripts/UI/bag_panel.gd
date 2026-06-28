extends Panel

@onready var item_list = $VBoxContainer/ItemList
@onready var label = $VBoxContainer/Label
@onready var use_button = $VBoxContainer/HBoxContainer/Use
@onready var close_button = $VBoxContainer/HBoxContainer/Close
@onready var coin_amount = $Coins/Amount
@onready var item_detail = $ItemDetailPanel

signal item_used

var player : Playerstats = null

func _ready() -> void:
	call_deferred("handle_close_button")

## 控制关闭按钮是否显示
func handle_close_button():
	var scene_name = get_tree().current_scene.name
	if scene_name == "BattleScene":
		close_button.visible = true   # 战斗场景中显示
	else:
		close_button.visible = false  # 地图场景中隐藏（整合UI自己有关闭）

## 更新UI
func refresh() -> void:
	item_list.clear()
	if player == null or player.inventory == null:
		return

	for entry in player.inventory.items:
		var item = entry["item"]
		var amount = entry["amount"]
		var text = item.name + " x" + str(amount)
		item_list.add_item(text)

	coin_amount.text = str(player.coin)


func _on_close_pressed() -> void:
	close()

func close() -> void:
	visible = false

func _on_use_pressed() -> void:
	var selected = item_list.get_selected_items()
	if selected.size() == 0:
		print("没有选中物品")
		return
	var index = selected[0]
	var entry = player.inventory.items[index]
	var item = entry["item"]
	use_item(item,player)
	

func use_item(item: Item, user: Playerstats) -> void:
	if user == null or item == null:
		print("错误：user或item是null。")
		return
	#战斗中不能换装备
	if get_tree().current_scene.name == "BattleScene" and item is Equipment:
		print("战斗中不能使用装备")
		return
	#检查物品有没有use方法（判断类型）
	if item.has_method("use"):
		item.use(player)
		item_used.emit()
		close()
		if get_tree().current_scene.has_method("_on_item_used"):
			get_tree().current_scene._on_item_used()
	else:
		print("该物品不能使用")
	

func _on_item_list_item_selected(_index: int) -> void:
	pass


func _on_item_detail_panel_item_used(item: Item, _amount: int) -> void:
	use_item(item,player)   
	item_used.emit()
	refresh()
	
	if get_tree().current_scene.name == "BattleScene":
		get_tree().current_scene._on_item_used()





func _on_item_list_item_activated(index: int) -> void:
	if index < 0:
		return
	var entry = player.inventory.items[index]
	item_detail.setup(entry.item,entry.amount)
	item_detail.show()
