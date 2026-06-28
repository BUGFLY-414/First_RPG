## 互动类，把这个Area2D挂载到需要互动的物体上，在进入区域时玩家屏幕应该会显示互动提示，按键就可以出触发互动内容
class_name Interactable
extends Area2D

signal interacted

@export var dialog_path: String = ""  ##互动对话的内容，应该是json文件路径
@export var dialog_start_id: String = "start" ##对话开始时的id
@export var default_text:String = "互动" ##交互时显示的动作名称
var custom_text:String = "" ##暂时没什么用
@export var interact_key = "E" ## 必须是大写英文字母
@export var lock_movement := true ##是否锁定玩家移动,但是这块逻辑有问题，暂时都是默认锁的

func _ready() -> void:
	#collision_layer = 0
	#collision_mask = 0
	#set_collision_mask_value(2,true)   ##直接在编辑器里设置
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)

##打印互动对象日志，发送互动信号
func interact():
	if not is_inside_tree():
		return

	if dialog_path != "" :
		print("[含对话互动] {name} {default_text}")
		DialogSystem.start_dialog_from_file(dialog_path,dialog_start_id)
	else :
		print("[互动] {name} {default_text}")

	interacted.emit()



func get_interact_key() -> String:
	return interact_key

func get_current_text() -> String:
	return custom_text if custom_text != "" else default_text

func set_custom_text(text:String):
	custom_text = text

func on_body_entered(body:Node2D) -> void :
	if body is PlayerController:
		body.register_interactable(self)

func on_body_exited(body:Node2D) -> void :
	if body is PlayerController:
		body.unregister_interactable(self)
