## 玩家的实体，处理移动，动画，互动等，应该包含Playerstats作为属性数据
class_name PlayerController
extends CharacterBody2D

@onready var animated_sp: AnimatedSprite2D = $AnimatedSprite2D
@onready var interact: CanvasLayer = $Interact
@onready var label: Label = $Interact/Control/Label
@onready var key_animation: AnimatedSprite2D = $Interact/Control/Container/KeyAnimation


##玩家状态
var stats: Playerstats

##移动速度
@export var speed = 70
## 输入方向
var input_dir:Vector2  
##交互对象
var is_interacting_with :Array[Interactable] = []
##控制是否可以移动
var can_move :bool= true
##判断是否正在对话，用于在对话时隐藏按键提示
var dialog_active: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not is_interacting_with.is_empty() and not dialog_active:
		is_interacting_with.back().interact()

func _ready() -> void:
	stats = Global.player if Global.player else null
	interact.hide()
	DialogSystem.dialog_started.connect(_on_dialog_started)
	DialogSystem.dialog_finished.connect(_on_dialog_finished)

## 决定方向和速度
func get_dir():
	if not can_move:
		return
	# Input.get_vector() 会处理方向键（包括对角线）并返回一个归一化的向量
	input_dir = Input.get_vector("left", "right", "up", "down")
	velocity = input_dir * speed


func handle_animation():
	if input_dir == Vector2.ZERO:
		if animated_sp.is_playing():      #(没做idle动画)
			animated_sp.stop()
			animated_sp.frame = 1
	else:
		#根据移动方向选择动画
		if input_dir.x > 0:
			animated_sp.play("walk_right")
		elif input_dir.x < 0:
			animated_sp.play("walk_left")
		elif input_dir.y > 0:
			animated_sp.play("walk_down")
		elif input_dir.y < 0:
			animated_sp.play("walk_up")

func refresh_interact_ui():
	if dialog_active:
		interact.hide()
	else:
		interact.visible = not is_interacting_with.is_empty()	
	
func _physics_process(_delta):
	get_dir() 
	handle_animation()
	move_and_slide()  # 执行移动并与碰撞体交互

#region 互动文本处理
func register_interactable(v:Interactable) -> void:
	print("register called")
	if v in is_interacting_with:
		return
	is_interacting_with.append(v)
	update_interact_text()
	refresh_interact_ui()

func unregister_interactable(v:Interactable) -> void:
	is_interacting_with.erase(v)
	update_interact_text()
	refresh_interact_ui()

func update_interact_text():
	if is_interacting_with.is_empty():
		label.visible = false
		return
	var nearest = is_interacting_with.back()
	key_animation.play(nearest.get_interact_key())  ###播放动画，动画名必须是大写字母且位于AnimatedSprite2D中
	label.text = nearest.get_current_text()
	label.visible = true

func _on_dialog_started() -> void:	
	dialog_active = true
	can_move = false
	refresh_interact_ui()
	animated_sp.stop()  # 强制切回待机动画
	animated_sp.frame = 1
	

func _on_dialog_finished() -> void:
	dialog_active = false
	can_move = true
	refresh_interact_ui()
	

#endregion
