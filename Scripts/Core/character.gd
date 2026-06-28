## 角色类
extends RefCounted
class_name Character

var max_health: int
var name: String
var health: int
var base_atk: int
var temp_atk: int = 0
var base_prt: int
var temp_prt: int = 0
var action= null
var is_dead = false
var is_defending = false

func _init(new_name: String , new_max_health: int, new_base_atk: int, new_base_prt: int = 0):
	max_health = new_max_health
	name = new_name
	health = new_max_health
	base_atk = new_base_atk
	base_prt = new_base_prt

func get_total_prt() -> int:
	return base_prt + temp_prt

func get_total_atk() -> int:
	return base_atk + temp_atk

# 改变各基本量的方法
func change_max_health(value: int) -> int:
	max_health += value
	return max_health

func change_health(value: int) -> int:
	health += value
	if health > max_health:
		health = max_health
	elif health < 0:
		health = 0        
		is_dead = true    # 设置死亡标志
	return health

func change_base_atk(value: int) -> int:
	base_atk += value
	return base_atk

func change_base_prt(value: int) -> int:
	base_prt += value
	return base_prt

func change_temp_prt(value: int) -> int:
	temp_prt += value
	return temp_prt

func take_damage(damage: int) -> int:
	var actual_damage: int = max(1, damage - get_total_prt())
	if is_defending:
		actual_damage = max(1, actual_damage * 0.5)
		is_defending = false        #如果将来要做一回合受到多次伤害的话，就把这段改了，在主回合控制流程中设定防御状态

	change_health(-actual_damage)
	# 可选：受伤输出信息     #移植后改为ui层实现
	#print(name, " 受到了 ", actual_damage, " 点伤害！")
	if health <= 0:
		#print(name,"倒下了。" )
		pass
	return actual_damage

func attack(target: Character) -> int:
	var damage: int = get_total_atk()
	#print(name,"攻击了" ,target.name,"造成了",damage,"点伤害！")
	return target.take_damage(damage)

func defend() :
	is_defending = true
