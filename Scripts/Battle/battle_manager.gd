extends Node

signal turn_ready(actor) # 角色回合准备好了
signal cast_finished(actor)   # 施法完了

var combatants: Array = [] # 战斗参与者数组
var is_combat_active: bool = true

func register(actor) -> void: # 注册战斗参与者
	combatants.append(actor)
	actor.atb_gauge = 0.0 # 重置角色的ATB（Active Time Battle）能量条为0
	print("注册：", actor.name, " 速度=", actor.speed)

func _process(delta: float) -> void:
	if not is_combat_active:
		return

	for actor in combatants:
		if actor.is_dead:
			continue
			
		# 如果角色正在施法，就跑施法条
		if actor.is_casting:
			actor.cast_gauge += 1 * delta
			if actor.cast_gauge >= actor.cast_time:
				# 施法条跑满了！
				actor.is_casting = false
				actor.cast_gauge = 0.0
				print("施法完成: ", actor.name)
				cast_finished.emit(actor) # 通知外面去扣血
				return # 一次只处理一个事件
				
		# 如果没在施法，就跑充能条
		else:
			actor.atb_gauge += 5 * actor.speed * delta
			if actor.atb_gauge >= 100.0:
				actor.atb_gauge = 0.0
				is_combat_active = false
				print("充能满: ", actor.name)
				turn_ready.emit(actor)
				return

# 当玩家或怪物选好技能后，调用这个函数开始跑施法条
func start_cast(actor, action_name: String, time_needed: float):
	actor.pending_action = action_name
	actor.cast_time = time_needed
	actor.cast_gauge = 0.0
	actor.is_casting = true
	is_combat_active = true # 恢复时间，让施法条跑起来
