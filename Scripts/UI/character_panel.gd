extends Panel

@onready var name_label = $VBoxContainer/NameLabel
@onready var hp_label = $VBoxContainer/HPLabel
@onready var atk_label = $VBoxContainer/AtkLabel
@onready var prt_label = $VBoxContainer/PrtLabel
@onready var coin_label = $VBoxContainer/CoinLabel
@onready var close_button = $VBoxContainer/CloseButton

func _ready():
	close_button.pressed.connect(_on_close_pressed)
	handle_close_button()
	refresh()

## 控制关闭按钮是否显示
func handle_close_button() -> void:
	var scene_name = get_tree().current_scene.name
	if scene_name == "BattleScene":
		close_button.visible = true   # 战斗场景中显示
	else:
		close_button.visible = false  # 地图场景中隐藏（整合UI自己有关闭）

##刷新数值
func refresh() -> void:
	var player = Global.player
	if not player:
		return
	name_label.text = "名称: " + player.name
	hp_label.text = "生命: %d/%d" % [player.health, player.max_health]
	# 使用 get_total_atk/get_total_prt 方法获取最终值（含装备）
	atk_label.text = "攻击力: %d" % player.get_total_atk()
	prt_label.text = "防御力: %d" % player.get_total_prt()
	coin_label.text = "金币: %d" % player.coin

func _on_close_pressed():
	hide()
