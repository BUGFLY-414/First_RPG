extends Node2D

@onready var label = $UI/Label
@onready var monster_hp_bar: ProgressBar = $UI/Monster/ProgressBar2
@onready var player_hp_bar: ProgressBar = $UI/Player/ProgressBar
@onready var label_monster_name: Label = $UI/Monster/Label3
@onready var m_hp: Label = $UI/Monster/HP
@onready var p_hp: Label = $UI/Player/HP
@onready var bag_panel = $UI/BagPanel


var inv :Inventory = Inventory.new()
var player:Playerstats = Global.player


var monster : Monster = null
enum STATE{
	PLAYER_TURN,
	ENEMY_TURN,
	WIN,
	LOSE
}

var state = STATE.PLAYER_TURN

func _ready() -> void:
	if player == null:
		print("玩家不存在")
		return
	monster = Global.battle_monster 
	bag_panel.player = player
	player.action = null
	update_hp_bar()
	label.text = ""
	

func add_text(text:String) -> void:
	label.text += text + "\n"

func update_hp_bar() -> void:
	if monster == null:
		label_monster_name.text = ""
		m_hp.text = ""
		return
	label_monster_name.text = monster.name + "生命:"
	monster_hp_bar.max_value = monster.max_health
	player_hp_bar.max_value = player.max_health
	player_hp_bar.value = player.health
	monster_hp_bar.value = monster.health
	p_hp.text = str(player.health)
	m_hp.text = str(monster.health)
	
func add_reward() -> void:
	print("add reward")
	for drop in monster.get_drops():
		var item = drop[0]
		var amount = drop[1]
		player.inventory.add_item(item,amount)
		add_text("获得了"+item.name+"x"+str(amount))
	player.coin += monster.coin_reward
	add_text("获得了"+str(monster.coin_reward)+"金币")

func lose() -> void:
	add_text("游戏结束")
	SceneManager.change_scene_with_fade_in("res://Scenes/game_over.tscn")

func win():
	add_text("战斗胜利")
	add_reward()
	monster = null
	Global.battle_monster = null
	update_hp_bar()
	SceneManager.change_scene_with_fade("res://Scenes/game_world.tscn")
		
	
func enemy_turn(enemy:Monster = null) -> void:
	if state != STATE.ENEMY_TURN or enemy.is_dead:
		print("不是敌人回合")
		return
	var damage = enemy.attack(player)

	print( enemy.name, " base atk: ", enemy.base_atk)
	print("Player total prt: ", player.get_total_prt())
	print("Actual damage dealt: ", damage)

	add_text( enemy.name + "攻击了玩家，造成了" + str(damage) + "点伤害")
	update_hp_bar()

	if player.is_dead:
		change_state(STATE.LOSE)
		lose()
	else:
		change_state(STATE.PLAYER_TURN)

func change_state(target_state:STATE) -> void:
	if target_state == STATE.PLAYER_TURN:
		add_text("玩家回合")
		if player.action == "defend":
			player.action = null
	
	if target_state == STATE.ENEMY_TURN:
		if monster == null :
			print("没有怪物")
			return
			
	add_text(monster.name +"回合") 
	state = target_state


func _on_attack_pressed() -> void:
	if monster == null:
		print("没有怪物")
		return
	if state != STATE.PLAYER_TURN or player.is_dead:
		return

	var damage = player.attack(monster)
	add_text("玩家攻击了" + monster.name + "，造成了"+str(damage)+"点伤害")
	update_hp_bar()

	if monster.is_dead:
		change_state(STATE.WIN)  #没有考虑多怪物的情况
		win()
	
		return

	change_state(STATE.ENEMY_TURN)
	enemy_turn(monster)

func _on_item_pressed() -> void:
	if state != STATE.PLAYER_TURN or player.is_dead:
		return
	bag_panel.refresh()
	bag_panel.show()

func _on_item_used() -> void:
	if state != STATE.PLAYER_TURN :
		return
	#if monster != null and monster.is_dead:   #给伤害性道具加一个判断
		#change_state(STATE.WIN)
		#win()
		#return
	change_state(STATE.ENEMY_TURN)
	enemy_turn(monster)
	

func _on_defend_pressed() -> void:
	if monster == null:
		print("没有怪物")
		return
	if state != STATE.PLAYER_TURN or player.is_dead:
		return
	player.defend()
	player.action = "defend"
	add_text("玩家减伤50%")
	change_state(STATE.ENEMY_TURN)
	enemy_turn(monster)

func _on_quit_pressed() -> void:
	if monster == null:
		SceneManager.change_scene_with_fade_in("res://Scenes/game_world.tscn")
		return
	if state != STATE.PLAYER_TURN :
		add_text("战斗中不能退出")
	var chance = randi_range(0,1)
	if chance == 1:
		SceneManager.change_scene_with_fade_in("res://Scenes/game_world.tscn")
	if chance == 0:
		add_text("逃脱失败")
		change_state(STATE.ENEMY_TURN)
		enemy_turn(monster)
		
		
	
	
