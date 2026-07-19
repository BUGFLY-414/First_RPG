extends Node2D

func _ready():
	var monsters = get_tree().get_nodes_in_group("alive_monsters") # 获取所有标记为"alive_monsters"组的节点
	for monster in monsters: # 遍历所有怪物
		if monster.monster_id in Global.defeated_monsters: # 检查怪物的ID是否存在于已被击败的怪物列表中
			monster.queue_free() # 将标记为已击败的怪物从场景中移除
			# 从活着的怪物组里移除
			monster.remove_from_group("alive_monsters")


func _on_monster_player_detected() -> void:
	pass # Replace with function body.
