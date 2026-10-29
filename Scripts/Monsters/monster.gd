extends CharacterBody2D
class_name MonsterController
##导出变量
@export var data: MonsterData = null ##怪物数据
@export var monster_id: String = "" ##唯一标识符
##变量

var stats:Monsterstats = null ##怪物属性
var return_scene_path: String = "" ##返回场景路径
##信号
signal player_detected	 

func _ready() -> void:
	stats = Monsterstats.create_from_data(data) 

	add_to_group("alive_monsters")
	print("怪物已加入组，ID:", monster_id)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_detected.emit()
		return_scene_path = get_tree().current_scene.scene_file_path
		Global.start_battle(stats ,monster_id ,return_scene_path)

