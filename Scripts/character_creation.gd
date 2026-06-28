extends Panel

@onready var chr_name = $CenterContainer/MarginContainer/VBoxContainer/Name/LineEdit
@onready var chr_hp = $CenterContainer/MarginContainer/VBoxContainer/AttributeArrangement/HP/SpinBox
@onready var chr_atk = $CenterContainer/MarginContainer/VBoxContainer/AttributeArrangement/ATK/SpinBox
@onready var chr_prt = $CenterContainer/MarginContainer/VBoxContainer/AttributeArrangement/PRT/SpinBox
@onready var initial_item = $CenterContainer/MarginContainer/VBoxContainer/InitialItem/OptionButton

var item_map = {
	0: preload("res://Data/ItemData/Item/gel.tres"),
	1: preload("res://Data/ItemData/Item/rag.tres"),
	2: preload("res://Data/ItemData/Consumable/health_potion.tres"),
	3: preload("uid://cdfqd624tbab8"),   #suit的uid
}


func get_attributes():
	return {
		"name": chr_name.text,
		"hp": chr_hp.value,
		"atk": chr_atk.value,
		"prt": chr_prt.value
	}
	
func quit():
	SceneManager.change_scene_with_fade_in("res://Scenes/game_world.tscn")

func _on_quit_pressed() -> void:
	quit()


func _on_creat_pressed() -> void:
	var index = initial_item.selected if initial_item.selected != -1 else 0
	var item = item_map[index]

	var inv :Inventory = Inventory.new()
	var attrs = get_attributes()
	var player:Playerstats = Playerstats.new(attrs["name"], attrs["hp"], attrs["atk"], attrs["prt"], inv)
	Global.player = player
	player.inventory.add_item(item,1)
	quit()
