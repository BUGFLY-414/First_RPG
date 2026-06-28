extends Node

var player:Playerstats = null
var battle_monster:Monster = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

##跳转到游戏世界的场景可以直接用scene manager写，但是我懒得改了
func start_game() -> void:
	SceneManager.change_scene_with_fade("res://Scenes/Levels/prologue.tscn")
