extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogSystem.dialog_finished.connect(_on_dialog_finished)
	DialogSystem.start_dialog_from_file("res://Data/DialogData/prologue.json")

func _on_dialog_finished() -> void:
	SceneManager.change_scene_with_fade("res://Scenes/Levels/level_0.tscn")