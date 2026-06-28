extends Control

func _on_button_pressed() -> void:
	SceneManager.change_scene_with_fade("Scenes/game_world.tscn")
	



func _on_start_pressed() -> void:
	Global.start_game()

func _on_close_pressed() -> void:
	get_tree().quit()
