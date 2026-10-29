extends Node2D

@onready var player_atb_bar: ProgressBar = $UI/Player/ATBProgressBar
@onready var monster_atb_bar: ProgressBar = $UI/Monster/ATBProgressBar
@onready var player_state_label: Label = $UI/Player/StateLabel
@onready var label = $UI/Label
@onready var monster_hp_bar: ProgressBar = $UI/Monster/ProgressBar2
@onready var player_hp_bar: ProgressBar = $UI/Player/ProgressBar
@onready var label_monster_name: Label = $UI/Monster/Label3
@onready var m_hp: Label = $UI/Monster/HP
@onready var p_hp: Label = $UI/Player/HP
@onready var bag_panel = $UI/BagPanel
@onready var bm = $BattleManager

var player: Playerstats = null
var monster: Monsterstats = null

enum STATE {
	WAITING,
	PLAYER_ACTING,
	WIN,
	LOSE
}

var state = STATE.WAITING

func _ready() -> void:
	# 修复了先判空再赋值的 Bug，必须先赋值
	player = Global.player
	if player == null:
		print("玩家不存在")
		return

	bag_panel.player = player
	monster = Global.battle_monster

	# 注册 ATB 单位并连接信号
	bm.register(player)
	bm.register(monster)
	bm.turn_ready.connect(on_turn_ready)
	bm.cast_finished.connect(_on_cast_finished)

	player.action = null
	update_hp_bar()
	label.text = ""

func _process(_delta: float) -> void:
	if player == null: return
	
	# ================= 玩家 UI 更新 =================
	# 1. 充能条 / 施法条 复用
	if player.is_casting:
		# 正在施法：进度条变橙色，显示施法进度百分比
		player_atb_bar.value = (player.cast_gauge / player.cast_time) * 100.0
		player_atb_bar.modulate = Color(1.0, 0.6, 0.2) # 橙色
		player_state_label.text = "施法中: " + player.pending_action
	else:
		# 正在充能：进度条变回白色，显示充能进度
		player_atb_bar.value = player.atb_gauge
		player_atb_bar.modulate = Color(1.0, 1.0, 1.0) # 白色
		
		if state == STATE.PLAYER_ACTING:
			player_state_label.text = "等待指令"
		else:
			player_state_label.text = "充能中..."
			
	# ================= 怪物 UI 更新 =================
	if monster == null: return
	if monster.is_casting:
		monster_atb_bar.value = (monster.cast_gauge / monster.cast_time) * 100.0
		monster_atb_bar.modulate = Color(1.0, 0.2, 0.2) # 红色代表怪物施法
	else:
		monster_atb_bar.value = monster.atb_gauge
		monster_atb_bar.modulate = Color(1.0, 1.0, 1.0)
	

func add_text(text: String) -> void:
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
		player.inventory.add_item(item, amount)
		add_text("获得了" + item.name + "x" + str(amount))
	player.coin += monster.coin_reward
	add_text("获得了" + str(monster.coin_reward) + "金币")


func lose() -> void:
	add_text("游戏结束")
	Global.end_battle("lose")


func win() -> void:
	add_text("战斗胜利")
	add_reward()
	monster = null
	update_hp_bar()
	Global.end_battle("win")


func change_state(target_state: STATE) -> void:
	state = target_state
	if target_state == STATE.PLAYER_ACTING:
		add_text("玩家充能完毕，等待操作")
		if player.action == "defend":
			player.action = null


# 当充能满时，由 BattleManager 信号触发
func on_turn_ready(actor) -> void:
	if actor == player:
		change_state(STATE.PLAYER_ACTING)
	elif actor == monster:
		# 怪物充能满，进入 WAITING 状态防止玩家操作，然后怪物行动
		change_state(STATE.WAITING)
		bm.start_cast(monster, "attack", 1)

func _on_cast_finished(actor) -> void:
	# 如果施法中有人死了，就不结算了
	if actor.is_dead:
		bm.is_combat_active = true
		return

	if actor == player:
		match actor.pending_action:
			"attack":
				var damage = player.attack(monster)
				add_text("玩家攻击了" + monster.name + "，造成了" + str(damage) + "点伤害")
				update_hp_bar()
				if monster.is_dead:
					win()
					return # 死了就直接 return，不恢复时间轴了
			"defend":
				player.defend()
				player.action = "defend"
				add_text("玩家进入防御姿态")
			_:
				print("未知的玩家行动: ", actor.pending_action)
				
	elif actor == monster:
		# 怪物施法完成
		match actor.pending_action:
			"attack":
				var damage = monster.attack(player)
				add_text(monster.name + "攻击了玩家，造成了" + str(damage) + "点伤害")
				update_hp_bar()
				if player.is_dead:
					lose()
					return
			_:
				print("未知的怪物行动: ", actor.pending_action)

	# 只要没死人，施法完毕后就恢复时间轴
	bm.is_combat_active = true


func _on_attack_pressed() -> void:
	if state != STATE.PLAYER_ACTING: return
	# 玩家选完技能，不直接打了，去跑施法条
	add_text("玩家正在蓄力...")
	bm.start_cast(player, "attack", 0.7)
	change_state(STATE.WAITING) # 锁住按钮


func _on_item_pressed() -> void:
	if state != STATE.PLAYER_ACTING or player.is_dead:
		return
	bag_panel.refresh()
	bag_panel.show()


func _on_item_used() -> void:
	if state != STATE.PLAYER_ACTING:
		return

	# 用完道具消耗回合，恢复时间轴
	bm.is_combat_active = true
	change_state(STATE.WAITING)


func _on_defend_pressed() -> void:
	if state != STATE.PLAYER_ACTING or player.is_dead:
		return
	if monster == null:
		print("没有怪物")
		return

	player.defend()
	player.action = "defend"
	add_text("玩家减伤50%")

	# 防御完毕，恢复时间轴
	bm.is_combat_active = true
	change_state(STATE.WAITING)


func _on_quit_pressed() -> void:
	if state != STATE.PLAYER_ACTING:
		add_text("战斗中不能退出")
		return

	if monster == null:
		Global.end_battle("escape")
		return

	var chance = randi_range(0, 1)
	if chance == 1:
		Global.end_battle("escape")
	else:
		add_text("逃脱失败")
		# 逃跑失败，消耗回合，恢复时间轴
		bm.is_combat_active = true
		change_state(STATE.WAITING)
	
