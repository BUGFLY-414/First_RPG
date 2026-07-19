extends Node

var player:Playerstats = null  ## 玩家数据
var battle_monster:Monsterstats = null  ## 战斗中的怪物数据
var battle_monster_id: String = ""  ## 战斗中的怪物ID
var defeated_monsters: Array[String] = [] ##被击败的怪物(的ID）
var return_scene: String = ""  ## 战斗结束后返回的场景路径


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

##跳转到游戏世界的场景可以直接用scene manager写，但是我懒得改了
func start_game() -> void:
	SceneManager.change_scene_with_fade("res://Scenes/Levels/prologue.tscn")


func start_battle(monster:Monsterstats, id :String ,entry_scene: String) -> void:
	battle_monster = monster
	battle_monster_id = id
	return_scene = entry_scene
	SceneManager.change_scene_with_fade("res://Scenes/battle_scene.tscn")


func end_battle(result: String) -> void:
	# 统一处理战斗结束后的怪物数据清理
	var current_monster_id = battle_monster_id
	battle_monster = null
	battle_monster_id = ""
	
	match result:
		"win" :			
			defeated_monsters.append(current_monster_id)  # 存怪物场景的唯一ID
			SceneManager.change_scene_with_fade(return_scene)
	
		"lose" :
			SceneManager.change_scene_with_fade("res://Scenes/game_over.tscn")

		"escape" :
			SceneManager.change_scene_with_fade(return_scene)
	
	return_scene = ""

