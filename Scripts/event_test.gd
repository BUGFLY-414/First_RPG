extends Node2D



var slime_data = preload("res://Data/MonsterData/slime.tres")
var goblin_data = preload("res://Data/MonsterData/goblin.tres")

var dialog_data = [
	{"id": "battle", "speaker": "", "text": "你走着走着，突然被怪物伏击了！", "next_id": ""},
	{"id": "chest", "speaker": "", "text": "你找到了一个宝箱！里面有一些金币。", "next_id": ""},
	{"id": "", "speaker": "", "text": "", "next_id": ""},
	]

var entries = DialogData.load_from_dict(dialog_data)

func random_event():
	var result = randi_range(0,1)
	match result:
		0:event_battle()
		1:event_chest()

	


func event_battle():
	DialogSystem.start_dialog(entries,"battle")
	await DialogSystem.dialog_finished
	var monster = Monsterstats.create_from_data(goblin_data)
	Global.battle_monster = monster
	Global.return_scene = get_tree().current_scene.scene_file_path
	SceneManager.change_scene_with_fade("res://Scenes/battle_scene.tscn")

func event_chest():
	DialogSystem.start_dialog(entries,"chest")
	await DialogSystem.dialog_finished
	var gold_bonus = randi_range(1,5)
	Global.player.coin += gold_bonus
	print(Global.player.coin)
	SceneManager.change_scene_with_fade("res://Scenes/game_world.tscn")

	



func _ready():
	random_event()
