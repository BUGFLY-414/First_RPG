extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



#跳转战斗场景
func _on_button_pressed() -> void:
	if Global.player == null:
		print("请先创建角色")
		return
	Global.return_scene = "res://Scenes/game_world.tscn"  #有待优化
	SceneManager.change_scene_with_fade("res://Scenes/battle_scene.tscn")

#跳转角色创建场景
func _on_button_2_pressed() -> void:
	SceneManager.change_scene_with_fade("res://Scenes/character_creation.tscn")


func _on_button_3_pressed() -> void:
	SceneManager.change_scene_with_fade("res://Scenes/dialog_test.tscn")


func _on_button_4_pressed() -> void:
	if Global.player == null:
		print("请先创建角色")
		return
	SceneManager.change_scene_with_fade("res://Scenes/event_test.tscn")


func _on_button_show_characterpanel_pressed() -> void:
	MainUI.refresh_all()
	MainUI.show()
	


func _on_button_5_pressed() -> void:
	SceneManager.change_scene_with_fade("res://Scenes/start_scene.tscn")
