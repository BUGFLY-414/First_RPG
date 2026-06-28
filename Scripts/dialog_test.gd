extends Control

@onready var dialog= $DialogSystem

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialog.start_dialog_from_file("res://Data/DialogData/mytest.json")











func _on_button_pressed() -> void:
	SceneManager.change_scene_with_fade("res://Scenes/game_world.tscn")
