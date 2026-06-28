## 怪物类，定义怪物的名字，生命值，攻击力，防御力，金币奖励，掉落物等属性
extends Resource
class_name MonsterData


@export var name: String = ""
@export var max_health: int = 10
@export var base_atk: int = 5
@export var base_prt: int = 0
@export var coin_reward: int = 0
@export var drop_items: Array[DropItem] = []   # 以后扩展
