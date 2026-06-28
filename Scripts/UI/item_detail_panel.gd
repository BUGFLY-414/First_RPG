extends Control

@onready var name_label = $Panel/VBoxContainer/Name
@onready var desc_label = $Panel/VBoxContainer/Description
@onready var effect_label = $Panel/VBoxContainer/Effect
@onready var amount_label = $Panel/Amount
@onready var use_btn = $Panel/VBoxContainer/HBoxContainer/Use
@onready var close_btn = $Panel/VBoxContainer/HBoxContainer/Close
@onready var icon = $Panel/TextureRect

## 在详情界面使用物品时发出
signal item_used(item: Item, amount: int)   

var player : Playerstats = Global.player
var current_item :Item
var current_amount : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setup(item: Item, amount: int) -> void:
	current_item = item
	current_amount = amount
	name_label.text = item.name
	desc_label.text = item.description
	effect_label.text = ""      #物品、装备、等效果描述，以后加
	amount_label.text = "数量:" + str(amount)
	icon.texture = item.icon
	

func _on_close_pressed() -> void:
	hide()

func _on_use_pressed() -> void:
	#print("详情界面 - player 是：", player)   #调试用
	if current_item == null:
		return

	#if not current_item.has_method("use"):
	#	print("该物品无法使用")
	#	return
	
	#current_item.use(player)
	item_used.emit(current_item, current_amount) 
	hide()

		
